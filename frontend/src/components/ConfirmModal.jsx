export default function ConfirmModal({ open, title, text, onConfirm, onCancel }) {
  if (!open) return null;
  return (
    <div className="modal-backdrop">
      <div className="modal-card">
        <h3>{title}</h3>
        <p>{text}</p>
        <div className="modal-actions">
          <button className="btn btn-secondary" onClick={onCancel}>Cancelar</button>
          <button className="btn btn-danger" onClick={onConfirm}>Confirmar</button>
        </div>
      </div>
    </div>
  );
}
