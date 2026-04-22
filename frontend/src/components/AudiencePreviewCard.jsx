export default function AudiencePreviewCard({ preview }) {
  if (!preview) return null;
  return (
    <div className="card">
      <h3>Preview</h3>
      <p><strong>Clientes estimados:</strong> {preview.estimated_count}</p>
      <details>
        <summary>SQL gerado</summary>
        <pre className="sql-preview">{preview.sql_preview}</pre>
      </details>
    </div>
  );
}
