export default function RuleGroupCard({
  title,
  rules,
  setRules,
  fields,
  themes,
  withTheme = false,
}) {
  function addRule() {
    const firstField = fields[0]?.value || "";
    setRules([...rules, withTheme ? { theme: themes[0]?.value || "", field: firstField, operator: "=", value: "" } : { field: firstField, operator: "=", value: "" }]);
  }

  function updateRule(index, patch) {
    setRules(rules.map((item, idx) => (idx === index ? { ...item, ...patch } : item)));
  }

  function removeRule(index) {
    setRules(rules.filter((_, idx) => idx !== index));
  }

  return (
    <div className="card">
      <div className="section-title-row">
        <h3>{title}</h3>
        <button className="btn btn-secondary" onClick={addRule}>Adicionar regra</button>
      </div>
      <div className="rules-list">
        {rules.length === 0 && <p className="muted">Nenhuma regra adicionada.</p>}
        {rules.map((rule, index) => (
          <div className="rule-row" key={index}>
            {withTheme && (
              <select value={rule.theme} onChange={(e) => updateRule(index, { theme: e.target.value })}>
                {themes.map((theme) => <option key={theme.value} value={theme.value}>{theme.label}</option>)}
              </select>
            )}
            <select value={rule.field} onChange={(e) => updateRule(index, { field: e.target.value })}>
              {fields.map((field) => <option key={field.value} value={field.value}>{field.label}</option>)}
            </select>
            <select value={rule.operator} onChange={(e) => updateRule(index, { operator: e.target.value })}>
              <option value="=">=</option>
              <option value="!=">!=</option>
              <option value=">">{">"}</option>
              <option value=">=">{">="}</option>
              <option value="<">{"<"}</option>
              <option value="<=">{"<="}</option>
              <option value="LIKE">LIKE</option>
            </select>
            <input value={rule.value} onChange={(e) => updateRule(index, { value: e.target.value })} />
            <button className="btn btn-danger" onClick={() => removeRule(index)}>Remover</button>
          </div>
        ))}
      </div>
    </div>
  );
}
