import { useCallback, useState, type ReactNode } from 'react';
import { createPortal } from 'react-dom';
import { AlertTriangle, CheckCircle2, Info, X, XCircle } from 'lucide-react';
import { cn } from '@/lib/cn';
import {
  DURASI_TOAST_MS,
  MAKS_TOAST,
  ToastContext,
  type TipeToast,
} from './toast-context';

/* =========================================================
   Notifikasi (Toast)
   Sesuai docs/03-DESIGN-SYSTEM.md §6.7

   Aturan:
   - Muncul kanan bawah (desktop) atau atas (mobile)
   - Hilang otomatis setelah 4 detik, KECUALI tipe error
   - Maksimal 3 notifikasi bertumpuk
   ========================================================= */

interface Toast {
  id: number;
  tipe: TipeToast;
  pesan: string;
}

/** Penghitung ID — cukup untuk membedakan notifikasi dalam satu sesi */
let penghitungId = 0;

const IKON: Record<TipeToast, typeof Info> = {
  sukses: CheckCircle2,
  info: Info,
  peringatan: AlertTriangle,
  error: XCircle,
};

const WARNA: Record<TipeToast, string> = {
  sukses: 'var(--success)',
  info: 'var(--primary)',
  peringatan: 'var(--topik-pointer)',
  error: 'var(--danger)',
};

export function ToastProvider({ children }: { children: ReactNode }) {
  const [daftar, setDaftar] = useState<Toast[]>([]);

  const tutup = useCallback((id: number) => {
    setDaftar((prev) => prev.filter((t) => t.id !== id));
  }, []);

  const tampilkan = useCallback(
    (pesan: string, tipe: TipeToast = 'info') => {
      const id = ++penghitungId;
      setDaftar((prev) => [...prev, { id, tipe, pesan }].slice(-MAKS_TOAST));

      // Error harus ditutup manual — pengguna perlu waktu membacanya
      if (tipe !== 'error') {
        window.setTimeout(() => tutup(id), DURASI_TOAST_MS);
      }
    },
    [tutup],
  );

  return (
    <ToastContext.Provider value={{ tampilkan }}>
      {children}
      {createPortal(
        <div
          // Mobile: atas. Desktop: kanan bawah.
          className={cn(
            'pointer-events-none fixed inset-x-4 top-4 z-[60] flex flex-col gap-2',
            'sm:inset-x-auto sm:bottom-4 sm:right-4 sm:top-auto sm:w-80',
          )}
        >
          {daftar.map((t) => {
            const Ikon = IKON[t.tipe];
            const warna = WARNA[t.tipe];
            return (
              <div
                key={t.id}
                role={t.tipe === 'error' ? 'alert' : 'status'}
                aria-live={t.tipe === 'error' ? 'assertive' : 'polite'}
                className={cn(
                  'pointer-events-auto flex items-start gap-3 rounded-lg border bg-surface p-3',
                  'shadow-[var(--shadow-md)]',
                )}
                style={{ borderColor: warna }}
              >
                <Ikon className="mt-0.5 size-5 shrink-0" style={{ color: warna }} aria-hidden="true" />
                <p className="flex-1 text-sm text-fg">{t.pesan}</p>
                <button
                  type="button"
                  onClick={() => tutup(t.id)}
                  aria-label="Tutup notifikasi"
                  className="-m-1 shrink-0 cursor-pointer rounded p-1 text-fg-muted hover:text-fg"
                >
                  <X className="size-4" aria-hidden="true" />
                </button>
              </div>
            );
          })}
        </div>,
        document.body,
      )}
    </ToastContext.Provider>
  );
}
