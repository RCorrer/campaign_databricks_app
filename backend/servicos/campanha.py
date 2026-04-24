from __future__ import annotations

import json
from uuid import uuid4

from backend.configuracoes.configuracao import configuracao
from backend.modelos.contratos import (
    AtivacaoPayload,
    BriefingPayload,
    CampanhaAtualizacao,
    CampanhaCriacao,
    ResumoCampanha,
    SegmentacaoPayload,
    MudancaStatusPayload,
)
from backend.repositorios.databricks_sql import repositorio_sql
from backend.servicos.construtor_consulta import ServicoConstrutorConsulta
from backend.utilitarios.json_utils import carregar_array, carregar_json
from backend.utilitarios.sql import array_sql, data_ou_nulo, literal

ROTULOS_STATUS = {
    "PREPARACAO": "Preparação",
    "SEGMENTACAO": "Segmentação",
    "ATIVACAO": "Ativação",
    "ATIVO": "Ativo",
    "PAUSADO": "Pausado",
    "CONCLUIDO": "Concluído",
    "ENCERRADO": "Encerrado",
    "CANCELADO": "Cancelado",
}

TRANSICOES_PERMITIDAS = {
    "PREPARACAO": ["SEGMENTACAO", "CANCELADO"],
    "SEGMENTACAO": ["PREPARACAO", "ATIVACAO", "CANCELADO"],
    "ATIVACAO": ["SEGMENTACAO", "ATIVO", "CANCELADO"],
    "ATIVO": ["PAUSADO", "CONCLUIDO", "ENCERRADO", "CANCELADO"],
    "PAUSADO": ["ATIVO", "ENCERRADO", "CANCELADO"],
    "CONCLUIDO": [],
    "ENCERRADO": [],
    "CANCELADO": [],
}


class ServicoCampanha:
    def __init__(self) -> None:
        self.construtor = ServicoConstrutorConsulta()

    def carregar_demo(self) -> list[dict]:
        return self.listar_campanhas()

    def listar_campanhas(self) -> list[dict]:
        linhas = repositorio_sql.executar(f"""
            SELECT id_campanha,
                   nome_campanha,
                   tema,
                   objetivo,
                   descricao,
                   status,
                   CAST(data_inicio AS STRING) AS data_inicio,
                   CAST(data_fim AS STRING) AS data_fim,
                   versao_atual
              FROM {configuracao.ns_aplicacao}.campanha_cabecalho
             ORDER BY atualizado_em DESC, criado_em DESC
        """)
        return [self._resumo_linha(linha) for linha in linhas]

    def criar_campanha(self, payload: CampanhaCriacao) -> ResumoCampanha:
        id_campanha = f"CMP-{uuid4().hex[:10].upper()}"
        repositorio_sql.executar_script([
            f"""
            INSERT INTO {configuracao.ns_aplicacao}.campanha_cabecalho (
                id_campanha, nome_campanha, tema, objetivo, estrategia, descricao,
                status, periodicidade, data_inicio, data_fim, maximo_impactos_mes,
                grupo_controle_habilitado, versao_atual, criado_em, atualizado_em,
                criado_por, atualizado_por
            ) VALUES (
                {literal(id_campanha)}, {literal(payload.nome)}, {literal(payload.tema)},
                {literal(payload.objetivo)}, {literal(payload.estrategia)}, {literal(payload.descricao)},
                'PREPARACAO', {literal(payload.periodicidade)}, {data_ou_nulo(payload.data_inicio)},
                {data_ou_nulo(payload.data_fim)}, {payload.maximo_impactos_mes},
                {literal(payload.grupo_controle_habilitado)}, 1, current_timestamp(), current_timestamp(),
                current_user(), current_user()
            )
            """,
            self._sql_historico_status(id_campanha, None, "PREPARACAO", "Criação da campanha"),
            self._sql_auditoria(id_campanha, "CAMPANHA_CRIADA", payload.model_dump()),
        ])
        return ResumoCampanha(
            id_campanha=id_campanha,
            nome=payload.nome,
            status="PREPARACAO",
            data_inicio=payload.data_inicio,
            data_fim=payload.data_fim,
            versao=1,
        )

    def atualizar_campanha(self, id_campanha: str, payload: CampanhaAtualizacao) -> dict:
        self._garantir_campanha(id_campanha)
        repositorio_sql.executar_script([
            f"""
            UPDATE {configuracao.ns_aplicacao}.campanha_cabecalho
               SET nome_campanha = {literal(payload.nome)},
                   tema = {literal(payload.tema)},
                   objetivo = {literal(payload.objetivo)},
                   estrategia = {literal(payload.estrategia)},
                   descricao = {literal(payload.descricao)},
                   periodicidade = {literal(payload.periodicidade)},
                   data_inicio = {data_ou_nulo(payload.data_inicio)},
                   data_fim = {data_ou_nulo(payload.data_fim)},
                   maximo_impactos_mes = {payload.maximo_impactos_mes},
                   grupo_controle_habilitado = {literal(payload.grupo_controle_habilitado)},
                   atualizado_em = current_timestamp(),
                   atualizado_por = current_user()
             WHERE id_campanha = {literal(id_campanha)}
            """,
            self._sql_auditoria(id_campanha, "CAMPANHA_ATUALIZADA", payload.model_dump()),
        ])
        return self.obter_campanha(id_campanha)

    def excluir_campanha(self, id_campanha: str) -> dict:
        self._garantir_campanha(id_campanha)
        objetos = repositorio_sql.executar(f"""
            SELECT objeto_ativacao
              FROM {configuracao.ns_aplicacao}.campanha_ativacao_versao
             WHERE id_campanha = {literal(id_campanha)}
               AND objeto_ativacao IS NOT NULL
        """)
        comandos = []
        for linha in objetos:
            objeto = linha.get("objeto_ativacao")
            if objeto:
                comandos.append(f"DROP TABLE IF EXISTS {objeto}")
                comandos.append(f"DROP VIEW IF EXISTS {objeto}")
        comandos += [
            f"DELETE FROM {configuracao.ns_execucao}.campanha_publico WHERE id_campanha = {literal(id_campanha)}",
            f"DELETE FROM {configuracao.ns_execucao}.campanha_log_execucao WHERE id_campanha = {literal(id_campanha)}",
            f"DELETE FROM {configuracao.ns_aplicacao}.campanha_ativacao_versao WHERE id_campanha = {literal(id_campanha)}",
            f"DELETE FROM {configuracao.ns_aplicacao}.campanha_segmentacao_versao WHERE id_campanha = {literal(id_campanha)}",
            f"DELETE FROM {configuracao.ns_aplicacao}.campanha_briefing_versao WHERE id_campanha = {literal(id_campanha)}",
            f"DELETE FROM {configuracao.ns_aplicacao}.campanha_historico_status WHERE id_campanha = {literal(id_campanha)}",
            f"DELETE FROM {configuracao.ns_aplicacao}.campanha_evento_auditoria WHERE id_campanha = {literal(id_campanha)}",
            f"DELETE FROM {configuracao.ns_aplicacao}.campanha_cabecalho WHERE id_campanha = {literal(id_campanha)}",
        ]
        repositorio_sql.executar_script(comandos)
        return {"excluida": True, "id_campanha": id_campanha}

    def obter_campanha(self, id_campanha: str) -> dict:
        linhas = repositorio_sql.executar(f"""
            SELECT *
              FROM {configuracao.ns_aplicacao}.vw_definicao_atual_campanha
             WHERE id_campanha = {literal(id_campanha)}
        """)
        if not linhas:
            raise KeyError(id_campanha)
        linha = linhas[0]
        status = linha.get("status")
        return {
            "id_campanha": linha["id_campanha"],
            "nome": linha.get("nome_campanha"),
            "tema": linha.get("tema"),
            "objetivo": linha.get("objetivo"),
            "estrategia": linha.get("estrategia"),
            "descricao": linha.get("descricao"),
            "status": status,
            "rotulo_status": ROTULOS_STATUS.get(status, status),
            "transicoes_permitidas": self._transicoes_permitidas(status),
            "data_inicio": linha.get("data_inicio"),
            "data_fim": linha.get("data_fim"),
            "versao": int(linha.get("versao_atual") or 1),
            "briefing": {
                "desafio": linha.get("desafio"),
                "resultado_negocio_esperado": linha.get("resultado_negocio_esperado"),
                "canais": carregar_array(linha.get("canais")),
                "restricoes": carregar_array(linha.get("restricoes")),
                "regras_negocio": carregar_array(linha.get("regras_negocio")),
                "observacoes": linha.get("observacoes"),
            },
            "segmentacao": {
                "codigo_publico_inicial": linha.get("codigo_publico_inicial"),
                "view_publico_inicial": linha.get("view_publico_inicial"),
                "grupos_inclusao_nativa": carregar_json(linha.get("regras_inclusao_nativa_json"), []),
                "grupos_exclusao_nativa": carregar_json(linha.get("regras_exclusao_nativa_json"), []),
                "grupos_inclusao": carregar_json(linha.get("regras_inclusao_json"), []),
                "grupos_exclusao": carregar_json(linha.get("regras_exclusao_json"), []),
                "sql_previa": linha.get("sql_previa"),
                "publico_estimado": linha.get("publico_estimado"),
            },
            "ativacao": {
                "modo_materializacao": linha.get("modo_materializacao"),
                "objeto_ativacao": linha.get("objeto_ativacao"),
                "sql_ativacao": linha.get("sql_ativacao"),
                "data_inicio_vigencia": linha.get("data_inicio_vigencia"),
                "data_fim_vigencia": linha.get("data_fim_vigencia"),
                "status_ativacao": linha.get("status_ativacao"),
            },
        }

    def salvar_briefing(self, id_campanha: str, payload: BriefingPayload) -> dict:
        versao = self._versao_atual(id_campanha)
        self._garantir_campanha(id_campanha)
        repositorio_sql.executar_script([
            f"DELETE FROM {configuracao.ns_aplicacao}.campanha_briefing_versao WHERE id_campanha = {literal(id_campanha)} AND versao_id = {versao}",
            f"""
            INSERT INTO {configuracao.ns_aplicacao}.campanha_briefing_versao (
                id_campanha, versao_id, desafio, resultado_negocio_esperado, canais,
                restricoes, regras_negocio, observacoes, criado_em, criado_por
            ) VALUES (
                {literal(id_campanha)}, {versao}, {literal(payload.desafio)},
                {literal(payload.resultado_negocio_esperado)}, {array_sql(payload.canais)},
                {array_sql(payload.restricoes)}, {array_sql(payload.regras_negocio)},
                {literal(payload.observacoes)}, current_timestamp(), current_user()
            )
            """,
            f"UPDATE {configuracao.ns_aplicacao}.campanha_cabecalho SET atualizado_em = current_timestamp(), atualizado_por = current_user() WHERE id_campanha = {literal(id_campanha)}",
            self._sql_auditoria(id_campanha, "BRIEFING_SALVO", payload.model_dump()),
        ])
        return self.obter_campanha(id_campanha)

    def salvar_segmentacao(self, id_campanha: str, payload: SegmentacaoPayload) -> dict:
        versao = self._versao_atual(id_campanha)
        self._garantir_campanha(id_campanha)
        codigo_publico = payload.codigo_publico_inicial.strip().lower()
        sql_previa = self.construtor.montar_sql_previa(payload)
        publico_estimado = repositorio_sql.escalar(f"SELECT COUNT(*) AS total FROM ({sql_previa}) q", 0)
        repositorio_sql.executar_script([
            f"DELETE FROM {configuracao.ns_aplicacao}.campanha_segmentacao_versao WHERE id_campanha = {literal(id_campanha)} AND versao_id = {versao}",
            f"""
            INSERT INTO {configuracao.ns_aplicacao}.campanha_segmentacao_versao (
                id_campanha, versao_id, codigo_publico_inicial, view_publico_inicial,
                regras_inclusao_nativa_json, regras_exclusao_nativa_json,
                regras_inclusao_json, regras_exclusao_json, sql_previa,
                publico_estimado, criado_em, criado_por
            ) VALUES (
                {literal(id_campanha)}, {versao}, {literal(codigo_publico)},
                {literal(payload.view_publico_inicial)},
                {literal(json.dumps([g.model_dump() for g in payload.grupos_inclusao_nativa], ensure_ascii=False))},
                {literal(json.dumps([g.model_dump() for g in payload.grupos_exclusao_nativa], ensure_ascii=False))},
                {literal(json.dumps([g.model_dump() for g in payload.grupos_inclusao], ensure_ascii=False))},
                {literal(json.dumps([g.model_dump() for g in payload.grupos_exclusao], ensure_ascii=False))},
                {literal(sql_previa)}, {int(publico_estimado or 0)}, current_timestamp(), current_user()
            )
            """,
            f"UPDATE {configuracao.ns_aplicacao}.campanha_cabecalho SET status = 'SEGMENTACAO', atualizado_em = current_timestamp(), atualizado_por = current_user() WHERE id_campanha = {literal(id_campanha)}",
            self._sql_historico_status(id_campanha, None, "SEGMENTACAO", payload.observacao_versao or "Segmentação salva"),
            self._sql_auditoria(id_campanha, "SEGMENTACAO_SALVA", payload.model_dump() | {"codigo_publico_inicial": codigo_publico}),
        ])
        return self.obter_campanha(id_campanha)

    def ativar(self, id_campanha: str, payload: AtivacaoPayload) -> dict:
        versao = self._versao_atual(id_campanha)
        self._garantir_campanha(id_campanha)
        linhas = repositorio_sql.executar(f"""
            SELECT view_publico_inicial, sql_previa, codigo_publico_inicial
              FROM {configuracao.ns_aplicacao}.campanha_segmentacao_versao
             WHERE id_campanha = {literal(id_campanha)}
               AND versao_id = {versao}
             LIMIT 1
        """)
        if not linhas:
            raise RuntimeError("Salve a segmentação antes de ativar a campanha")
        segmentacao = linhas[0]
        modo_materializacao = payload.modo_materializacao.upper()
        if modo_materializacao not in {"TABLE", "VIEW"}:
            raise ValueError("modo_materializacao deve ser TABLE ou VIEW")
        objeto = f"{configuracao.ns_execucao}.publico_{id_campanha.lower().replace('-', '_')}_v{versao}"
        select_publico = f"""
            SELECT {literal(id_campanha)} AS id_campanha,
                   {versao} AS versao_segmentacao,
                   cpf_cnpj,
                   current_timestamp() AS data_segmentacao,
                   {data_ou_nulo(payload.data_inicio_vigencia)} AS data_inicio_vigencia,
                   {data_ou_nulo(payload.data_fim_vigencia)} AS data_fim_vigencia,
                   'ATIVA' AS status_publico,
                   {literal(segmentacao.get('codigo_publico_inicial'))} AS origem_publico,
                   {literal(modo_materializacao)} AS modo_materializacao,
                   {literal(payload.modo_execucao)} AS modo_execucao
              FROM ({segmentacao['sql_previa']}) src
        """
        ddl = f"CREATE OR REPLACE {modo_materializacao} {objeto} AS {select_publico}"
        if modo_materializacao == "TABLE":
            ddl = f"CREATE OR REPLACE TABLE {objeto} AS {select_publico}"
        repositorio_sql.executar_script([
            ddl,
            f"DELETE FROM {configuracao.ns_execucao}.campanha_publico WHERE id_campanha = {literal(id_campanha)} AND versao_segmentacao = {versao}",
            f"INSERT INTO {configuracao.ns_execucao}.campanha_publico {select_publico}",
            f"DELETE FROM {configuracao.ns_execucao}.campanha_log_execucao WHERE id_campanha = {literal(id_campanha)} AND versao_segmentacao = {versao}",
            f"""
            INSERT INTO {configuracao.ns_execucao}.campanha_log_execucao (
                id_campanha, versao_segmentacao, executado_em, modo_execucao,
                modo_materializacao, objeto_saida, total_registros,
                objeto_snapshot, status_execucao, mensagem_erro
            )
            SELECT {literal(id_campanha)}, {versao}, current_timestamp(),
                   {literal(payload.modo_execucao)}, {literal(modo_materializacao)},
                   {literal(objeto)}, COUNT(*), NULL, 'SUCESSO', NULL
              FROM {objeto}
            """,
            f"DELETE FROM {configuracao.ns_aplicacao}.campanha_ativacao_versao WHERE id_campanha = {literal(id_campanha)} AND versao_id = {versao}",
            f"""
            INSERT INTO {configuracao.ns_aplicacao}.campanha_ativacao_versao (
                id_campanha, versao_id, modo_materializacao, objeto_ativacao,
                sql_ativacao, data_inicio_vigencia, data_fim_vigencia,
                status_ativacao, ativado_em, ativado_por
            ) VALUES (
                {literal(id_campanha)}, {versao}, {literal(modo_materializacao)},
                {literal(objeto)}, {literal(ddl)}, {data_ou_nulo(payload.data_inicio_vigencia)},
                {data_ou_nulo(payload.data_fim_vigencia)}, 'ATIVO', current_timestamp(), current_user()
            )
            """,
            f"UPDATE {configuracao.ns_aplicacao}.campanha_cabecalho SET status = 'ATIVO', atualizado_em = current_timestamp(), atualizado_por = current_user() WHERE id_campanha = {literal(id_campanha)}",
            self._sql_historico_status(id_campanha, None, "ATIVO", "Campanha ativada"),
            self._sql_auditoria(id_campanha, "CAMPANHA_ATIVADA", payload.model_dump() | {"objeto_saida": objeto}),
        ])
        return self.obter_campanha(id_campanha)

    def alterar_status(self, id_campanha: str, payload: MudancaStatusPayload) -> dict:
        self._garantir_campanha(id_campanha)
        status_atual = repositorio_sql.escalar(
            f"SELECT status FROM {configuracao.ns_aplicacao}.campanha_cabecalho WHERE id_campanha = {literal(id_campanha)}",
            "PREPARACAO",
        )
        permitidos = self._transicoes_permitidas(status_atual)
        if payload.novo_status not in permitidos:
            raise ValueError(f"Transição inválida: {status_atual} -> {payload.novo_status}")
        repositorio_sql.executar_script([
            f"UPDATE {configuracao.ns_aplicacao}.campanha_cabecalho SET status = {literal(payload.novo_status)}, atualizado_em = current_timestamp(), atualizado_por = current_user() WHERE id_campanha = {literal(id_campanha)}",
            self._sql_historico_status(id_campanha, status_atual, payload.novo_status, payload.motivo),
            self._sql_auditoria(id_campanha, "STATUS_ALTERADO", payload.model_dump()),
        ])
        return self.obter_campanha(id_campanha)

    def _garantir_campanha(self, id_campanha: str) -> None:
        existe = repositorio_sql.escalar(
            f"SELECT COUNT(*) FROM {configuracao.ns_aplicacao}.campanha_cabecalho WHERE id_campanha = {literal(id_campanha)}",
            0,
        )
        if int(existe or 0) == 0:
            raise KeyError(id_campanha)

    def _versao_atual(self, id_campanha: str) -> int:
        versao = repositorio_sql.escalar(
            f"SELECT versao_atual FROM {configuracao.ns_aplicacao}.campanha_cabecalho WHERE id_campanha = {literal(id_campanha)}",
            1,
        )
        return int(versao or 1)

    def _sql_historico_status(self, id_campanha: str, status_origem: str | None, status_destino: str, motivo: str | None) -> str:
        return f"""
            INSERT INTO {configuracao.ns_aplicacao}.campanha_historico_status (
                id_campanha, status_origem, status_destino, motivo_alteracao, alterado_em, alterado_por
            ) VALUES (
                {literal(id_campanha)}, {literal(status_origem)}, {literal(status_destino)},
                {literal(motivo)}, current_timestamp(), current_user()
            )
        """

    def _sql_auditoria(self, id_campanha: str, nome_evento: str, payload: dict) -> str:
        return f"""
            INSERT INTO {configuracao.ns_aplicacao}.campanha_evento_auditoria (
                id_campanha, nome_evento, payload_json, evento_em, usuario_evento
            ) VALUES (
                {literal(id_campanha)}, {literal(nome_evento)},
                {literal(json.dumps(payload, ensure_ascii=False))}, current_timestamp(), current_user()
            )
        """

    def _transicoes_permitidas(self, status: str | None) -> list[str]:
        return TRANSICOES_PERMITIDAS.get(status or "PREPARACAO", [])

    def _resumo_linha(self, linha: dict) -> dict:
        status = linha.get("status")
        return {
            "id_campanha": linha["id_campanha"],
            "nome": linha.get("nome_campanha"),
            "tema": linha.get("tema"),
            "objetivo": linha.get("objetivo"),
            "descricao": linha.get("descricao"),
            "status": status,
            "rotulo_status": ROTULOS_STATUS.get(status, status),
            "data_inicio": linha.get("data_inicio"),
            "data_fim": linha.get("data_fim"),
            "versao": int(linha.get("versao_atual") or 1),
            "transicoes_permitidas": self._transicoes_permitidas(status),
        }


servico_campanha = ServicoCampanha()
