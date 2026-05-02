import { Link, NavLink } from 'react-router-dom'

export default function Layout({ children }) {
  return (
    <div className="shell">
      <aside className="sidebar">
        <Link to="/" className="brand">
          <span className="brand-mark">CO</span>
          <div>
            <strong>Campaign Orchestrator</strong>
            <small>Databricks App</small>
          </div>
        </Link>
        <nav className="nav">
          <NavLink to="/" end className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
            Campanhas
          </NavLink>
        </nav>
      </aside>
      <div className="content">
        <header className="topbar">
          <div>
            <h1>Gestão de campanhas</h1>
          </div>
        </header>
        {children}
      </div>
    </div>
  )
}
