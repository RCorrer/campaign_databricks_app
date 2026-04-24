# Fluxo da campanha

## 1. Preparação
- Cadastro inicial da campanha
- Definição de objetivo, tema, canais e vigência
- Refinamento do briefing
- Registro de regras de negócio

## 2. Segmentação
### Aba: Universo inicial
Seleciona a view base do público.

### Aba: Inclusão
Adiciona regras positivas.
Exemplo:
- Assunto: Elegibilidade
- Entidade: `vw_elegibilidade_cliente`
- Campo: `produto`
- Operador: `EQUALS`
- Valor: `CREDITO_PESSOAL`

### Aba: Exclusão
Remove públicos não desejados.
Exemplo:
- Assunto: Relacionamento
- Campo: `status_conta`
- Valor: `INATIVA`

## 3. Ativação
- Gera SQL final
- Cria tabela/view de audiência
- Salva metadados da execução
- Controla período ativo por data inicial e final

## 4. Operação
- Ativo
- Pausado
- Concluído
- Encerrado
- Cancelado
