import { useState } from 'react'

export function useToast() {
  const [toast, setToast] = useState(null)
  function show(message, type = 'success') {
    setToast({ message, type })
    setTimeout(() => setToast(null), 3500)
  }
  return { toast, show }
}
