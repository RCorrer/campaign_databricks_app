import { Link } from 'react-router-dom'

export default function Layout({ children }) {
  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand">CRM/CDP</div>
        <p className="brand-subtitle">Orquestrador de Campanhas</p>
        <nav>
          <Link to="/">Painel</Link>
        </nav>
      </aside>
      <main className="main-content">{children}</main>
    </div>
  )
}
