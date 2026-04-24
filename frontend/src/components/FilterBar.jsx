export default function FilterBar({ filters, setFilters, onReload }) {
  return (
    <div className="filter-bar card">
      <input
        placeholder="Buscar campanha"
        value={filters.search}
        onChange={(e) => setFilters((prev) => ({ ...prev, search: e.target.value }))}
      />
      <select
        value={filters.status}
        onChange={(e) => setFilters((prev) => ({ ...prev, status: e.target.value }))}
      >
        <option value="">Todos status</option>
        <option value="PREPARACAO">Preparação</option>
        <option value="SEGMENTACAO">Segmentação</option>
        <option value="ATIVACAO">Ativação</option>
        <option value="ATIVO">Ativo</option>
        <option value="PAUSADO">Pausado</option>
        <option value="CONCLUIDO">Concluído</option>
        <option value="CANCELADO">Cancelado</option>
      </select>
      <input
        placeholder="Tema"
        value={filters.theme}
        onChange={(e) => setFilters((prev) => ({ ...prev, theme: e.target.value }))}
      />
      <button className="btn" onClick={onReload}>Aplicar</button>
    </div>
  );
}
