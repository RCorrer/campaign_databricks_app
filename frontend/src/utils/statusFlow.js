export const statusTransitions = {
  RASCUNHO: ["PREPARACAO", "CANCELADO"],
  PREPARACAO: ["SEGMENTACAO", "CANCELADO"],
  SEGMENTACAO: ["ATIVACAO", "PREPARACAO", "CANCELADO"],
  ATIVACAO: ["ATIVO", "SEGMENTACAO", "CANCELADO"],
  ATIVO: ["PAUSADO", "CONCLUIDO", "ENCERRADO", "CANCELADO"],
  PAUSADO: ["ATIVO", "ENCERRADO", "CANCELADO"],
};

export function allowedTransitions(status) {
  return statusTransitions[status] || [];
}
