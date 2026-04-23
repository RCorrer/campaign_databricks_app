# Arquitetura funcional

## Visão geral

A solução foi desenhada para rodar como **Databricks App** com:
- **React** para experiência no-code
- **FastAPI** para orquestração, versionamento e APIs
- **Databricks SQL Warehouse** para execução das queries de segmentação
- **Unity Catalog** para governança de tabelas, views e audiência ativada
- **Delta Tables** para persistência de metadados e snapshots de público

## Módulos

### 1. Campaign Workspace
Responsável por cadastro da campanha, briefing, vigência, objetivos, canais, limites e grupo de controle.

### 2. Briefing Studio
Permite refinar o briefing inicial, registrar hipóteses, observações e regras de negócio.

### 3. Segmentation Builder
Motor no-code inspirado em Data Cloud:
- universo inicial
- inclusão
- exclusão
- operadores por tipo de campo
- preview SQL
- versionamento das regras

### 4. Activation Engine
Materializa a audiência final em Delta table ou view e grava:
- data de segmentação
- vigência da ativação
- versão de regra aplicada

### 5. Lifecycle Manager
Controla transições de status.

## Regras de transição

| De | Para | Permitido? | Observação |
|---|---|---:|---|
| PREPARACAO | SEGMENTACAO | Sim | briefing refinado salvo |
| SEGMENTACAO | ATIVACAO | Sim | regra salva e validada |
| ATIVACAO | ATIVO | Sim | ativação executada |
| ATIVO | PAUSADO | Sim | pausa operacional |
| PAUSADO | ATIVO | Sim | reativação |
| ATIVO | CONCLUIDO | Sim | fim natural da vigência |
| ATIVO | ENCERRADO | Sim | fim manual antecipado |
| * | CANCELADO | Sim | cancelamento em qualquer etapa |

## Estratégia de persistência

### Metadados
Tudo que for configuração e histórico fica em `main.campaign_app`.

### Dados de negócio
As views e tabelas de origem ficam no schema de negócio, por exemplo `main.customer_360`, com junção por `cpf_cnpj`.

### De/Para semântico
O arquivo `config/semantic_mapping.yaml` traduz nomes técnicos em nomes de negócio consumidos na UI.

## Estratégia de segmentação

1. Escolher universo inicial
2. Aplicar inclusão
3. Aplicar exclusão
4. Gerar preview SQL
5. Salvar versão
6. Ativar

## Estratégia de reprocessamento

Se o briefing ou a segmentação mudarem após ativação:
- nova versão é criada
- versão anterior permanece auditável
- reativação gera nova audiência materializada
