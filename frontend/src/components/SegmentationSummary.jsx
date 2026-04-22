export default function SegmentationSummary({ segmentation }) {
  if (!segmentation) return null;
  return (
    <div className="card">
      <h3>Resumo da segmentação</h3>
      <p><strong>Público inicial:</strong> {segmentation.initial_audience_code || "-"}</p>
      <p><strong>Regras nativas:</strong> {segmentation.native_rules?.length || 0}</p>
      <p><strong>Inclusões:</strong> {segmentation.include_rules?.length || 0}</p>
      <p><strong>Exclusões:</strong> {segmentation.exclude_rules?.length || 0}</p>
      <p><strong>Estimativa:</strong> {segmentation.estimated_count || 0}</p>
    </div>
  );
}
