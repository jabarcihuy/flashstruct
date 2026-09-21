import { createContext, useContext } from 'react';

export type TipeToast = 'sukses' | 'info' | 'peringatan' | 'error';

export interface ToastContextValue {
  tampilkan: (pesan: string, tipe?: TipeToast) => void;
}

export const ToastContext = createContext<ToastContextValue | null>(null);

export function useToast() {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error('useToast harus dipakai di dalam ToastProvider');
  return ctx;
}

/** Maksimal notifikasi bertumpuk (docs/03-DESIGN-SYSTEM.md §6.7) */
export const MAKS_TOAST = 3;

/** Durasi tampil otomatis dalam milidetik */
export const DURASI_TOAST_MS = 4000;
