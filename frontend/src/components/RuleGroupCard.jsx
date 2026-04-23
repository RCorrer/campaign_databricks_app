export default function RuleGroupCard({ group, index }) {
  return (
    <div className="rule-card">
      <div className="rule-card-header">
        <strong>{group.name || `Grupo ${index + 1}`}</strong>
        <span>{group.conditions.length} condição(ões)</span>
      </div>
      <div className="rule-list">
        {group.conditions.map((condition, conditionIndex) => (
          <div key={conditionIndex} className="rule-line">
            <span>{condition.source_scope === 'THEMATIC' ? (condition.theme || 'Tema') : 'Público inicial'}</span>
            <strong>{condition.field}</strong>
            <span>{condition.operator}</span>
            <code>{Array.isArray(condition.value) ? condition.value.join(', ') : String(condition.value)}</code>
            {condition.entity ? <small className="muted">{condition.entity}</small> : null}
          </div>
        ))}
      </div>
    </div>
  )
}
