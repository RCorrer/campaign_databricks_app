import { Link } from "react-router-dom";

export default function Layout({ title, children }) {
  return (
    <div className="app-shell">
      <header className="app-header">
        <div>
          <Link to="/" className="brand">Campaign CRM/CDP</Link>
          <p className="brand-subtitle">Databricks App</p>
        </div>
        <nav>
          <Link className="nav-link" to="/">Dashboard</Link>
          <Link className="nav-link" to="/campaigns/new/preparation">Nova campanha</Link>
        </nav>
      </header>
      <main className="page-shell">
        <div className="page-title-row">
          <h1>{title}</h1>
        </div>
        {children}
      </main>
    </div>
  );
}
