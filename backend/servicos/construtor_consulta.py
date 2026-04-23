from __future__ import annotations

from backend.configuracoes.configuracao import configuracao
from backend.modelos.contratos import GrupoRegra, SegmentacaoPayload
from backend.utilitarios.mapeamento import carregar_mapeamento

OPERADOR_SQL = {
    "IGUAL": "=",
    "DIFERENTE": "<>",
    "MAIOR": ">",
    "MAIOR_IGUAL": ">=",
    "MENOR": "<",
    "MENOR_IGUAL": "<=",
    "EM": "IN",
    "NAO_EM": "NOT IN",
    "CONTEM": "LIKE",
    "EQUALS": "=",
    "NOT_EQUALS": "<>",
    "GT": ">",
    "GTE": ">=",
    "LT": "<",
    "LTE": "<=",
    "IN": "IN",
    "NOT_IN": "NOT IN",
    "CONTAINS": "LIKE",
}


class ServicoConstrutorConsulta:
    def __init__(self) -> None:
        self.mapeamento = carregar_mapeamento(configuracao.caminho_mapeamento)

    def montar_sql_previa(self, segmentacao: SegmentacaoPayload) -> str:
        view_origem = segmentacao.view_publico_inicial
        inclusao_nativa = self._montar_clausula_nativa(segmentacao.grupos_inclusao_nativa, padrao_verdadeiro=True)
        exclusao_nativa = self._montar_clausula_nativa(segmentacao.grupos_exclusao_nativa, padrao_verdadeiro=False)
        inclusao_tematica = self._montar_clausula_tematica(segmentacao.grupos_inclusao, padrao_verdadeiro=True)
        exclusao_tematica = self._montar_clausula_tematica(segmentacao.grupos_exclusao, padrao_verdadeiro=False)
        return f"""
WITH publico_inicial AS (
    SELECT DISTINCT base.*
    FROM {view_origem} base
), publico_filtrado AS (
    SELECT DISTINCT base.cpf_cnpj
    FROM publico_inicial base
    WHERE {inclusao_nativa}
      AND NOT ({exclusao_nativa})
      AND {inclusao_tematica}
      AND NOT ({exclusao_tematica})
)
SELECT cpf_cnpj
FROM publico_filtrado
""".strip()

    def _montar_clausula_nativa(self, grupos: list[GrupoRegra], padrao_verdadeiro: bool) -> str:
        if not grupos:
            return "1 = 1" if padrao_verdadeiro else "1 = 0"
        partes = [self._montar_grupo(grupo, "base") for grupo in grupos if grupo.condicoes]
        if not partes:
            return "1 = 1" if padrao_verdadeiro else "1 = 0"
        return "(" + " OR ".join(partes) + ")"

    def _montar_clausula_tematica(self, grupos: list[GrupoRegra], padrao_verdadeiro: bool) -> str:
        if not grupos:
            return "1 = 1" if padrao_verdadeiro else "1 = 0"
        partes = [self._montar_exists(grupo) for grupo in grupos if grupo.condicoes]
        if not partes:
            return "1 = 1" if padrao_verdadeiro else "1 = 0"
        return "(" + " OR ".join(partes) + ")"

    def _montar_grupo(self, grupo: GrupoRegra, alias: str) -> str:
        partes = []
        for indice, condicao in enumerate(grupo.condicoes):
            conector = "" if indice == 0 else f" {condicao.conector_logico} "
            operador = OPERADOR_SQL.get(condicao.operador, "=")
            valor = self._formatar_valor(condicao.valor, condicao.operador)
            partes.append(f"{conector}{alias}.{condicao.campo} {operador} {valor}")
        return "(" + "".join(partes) + ")"

    def _montar_exists(self, grupo: GrupoRegra) -> str:
        primeira = grupo.condicoes[0]
        entidade = primeira.entidade or self._resolver_tabela_tema(primeira.tema)
        partes = []
        for indice, condicao in enumerate(grupo.condicoes):
            conector = "" if indice == 0 else f" {condicao.conector_logico} "
            operador = OPERADOR_SQL.get(condicao.operador, "=")
            valor = self._formatar_valor(condicao.valor, condicao.operador)
            partes.append(f"{conector}tema.{condicao.campo} {operador} {valor}")
        return f"EXISTS (SELECT 1 FROM {entidade} tema WHERE tema.cpf_cnpj = base.cpf_cnpj AND ({''.join(partes)}))"

    def _resolver_tabela_tema(self, chave_tema: str | None) -> str:
        for tema in self.mapeamento.get("temas", []):
            if tema.get("chave") == chave_tema:
                return tema["tabela"]
        raise ValueError(f"Tema não mapeado: {chave_tema}")

    def _formatar_valor(self, valor, operador: str) -> str:
        if operador in {"EM", "NAO_EM", "IN", "NOT_IN"} and isinstance(valor, list):
            return "(" + ", ".join(self._aspas(v) for v in valor) + ")"
        if operador in {"CONTEM", "CONTAINS"}:
            return self._aspas(f"%{valor}%")
        return self._aspas(valor)

    def _aspas(self, valor) -> str:
        if isinstance(valor, bool):
            return "true" if valor else "false"
        if isinstance(valor, (int, float)):
            return str(valor)
        if valor is None:
            return "NULL"
        return "'" + str(valor).replace("'", "''") + "'"
