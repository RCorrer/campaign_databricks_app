export default function StageCard({ title, status, children }) {
  return (
    <section className="stage-card">
      <div className="stage-header">
        <h3>{title}</h3>
        <span className="badge">{status}</span>
      </div>
      <div>{children}</div>
    </section>
  )
}
