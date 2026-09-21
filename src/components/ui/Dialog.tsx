import { useEffect, useRef, type ReactNode } from 'react';
import { createPortal } from 'react-dom';
import { X } from 'lucide-react';
import { cn } from '@/lib/cn';

/* =========================================================
   Dialog / Modal

   Persyaratan aksesibilitas yang dipenuhi:
   - Fokus terkunci di dalam dialog saat terbuka
   - Fokus kembali ke pemicu saat ditutup
   - Escape menutup dialog
   - Scroll body dikunci
   - role="dialog" + aria-modal + aria-labelledby
   ========================================================= */

interface DialogProps {
  terbuka: boolean;
  onTutup: () => void;
  judul: string;
  deskripsi?: string;
  children: ReactNode;
  /** Sembunyikan tombol tutup — untuk dialog yang wajib dijawab */
  tanpaTombolTutup?: boolean;
  ukuran?: 'sm' | 'md' | 'lg';
  className?: string;
}

const UKURAN = {
  sm: 'max-w-sm',
  md: 'max-w-lg',
  lg: 'max-w-3xl',
} as const;

export function Dialog({
  terbuka,
  onTutup,
  judul,
  deskripsi,
  children,
  tanpaTombolTutup = false,
  ukuran = 'md',
  className,
}: DialogProps) {
  const refDialog = useRef<HTMLDivElement>(null);
  const refPemicu = useRef<Element | null>(null);

  // Simpan elemen yang membuka dialog agar fokus bisa dikembalikan
  useEffect(() => {
    if (terbuka) {
      refPemicu.current = document.activeElement;
    } else if (refPemicu.current instanceof HTMLElement) {
      refPemicu.current.focus();
      refPemicu.current = null;
    }
  }, [terbuka]);

  // Kunci scroll body + tangani Escape
  useEffect(() => {
    if (!terbuka) return;

    const overflowAsli = document.body.style.overflow;
    document.body.style.overflow = 'hidden';

    function onKeyDown(e: globalThis.KeyboardEvent) {
      if (e.key === 'Escape') {
        e.preventDefault();
        onTutup();
        return;
      }

      // Perangkap fokus: Tab tidak boleh keluar dari dialog
      if (e.key !== 'Tab' || !refDialog.current) return;

      const bisaDifokus = refDialog.current.querySelectorAll<HTMLElement>(
        'a[href], button:not([disabled]), textarea, input, select, [tabindex]:not([tabindex="-1"])',
      );
      if (bisaDifokus.length === 0) return;

      const pertama = bisaDifokus[0]!;
      const terakhir = bisaDifokus[bisaDifokus.length - 1]!;

      if (e.shiftKey && document.activeElement === pertama) {
        e.preventDefault();
        terakhir.focus();
      } else if (!e.shiftKey && document.activeElement === terakhir) {
        e.preventDefault();
        pertama.focus();
      }
    }

    document.addEventListener('keydown', onKeyDown);
    return () => {
      document.body.style.overflow = overflowAsli;
      document.removeEventListener('keydown', onKeyDown);
    };
  }, [terbuka, onTutup]);

  // Pindahkan fokus ke dalam dialog saat dibuka
  useEffect(() => {
    if (!terbuka) return;
    const timer = window.setTimeout(() => {
      const target = refDialog.current?.querySelector<HTMLElement>(
        '[data-autofokus], button, a[href], input',
      );
      target?.focus();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [terbuka]);

  if (!terbuka) return null;

  return createPortal(
    <div className="fixed inset-0 z-50 flex items-end justify-center p-0 sm:items-center sm:p-4">
      {/* Lapisan gelap — klik untuk menutup */}
      <div
        className="absolute inset-0 bg-black/50 backdrop-blur-[2px]"
        onClick={onTutup}
        aria-hidden="true"
      />

      <div
        ref={refDialog}
        role="dialog"
        aria-modal="true"
        aria-labelledby="judul-dialog"
        aria-describedby={deskripsi ? 'deskripsi-dialog' : undefined}
        className={cn(
          'relative w-full rounded-t-xl border border-border bg-surface shadow-[var(--shadow-md)]',
          'sm:rounded-xl',
          'max-h-[90dvh] overflow-y-auto',
          UKURAN[ukuran],
          className,
        )}
      >
        <div className="flex items-start justify-between gap-4 p-4 pb-0 sm:p-6 sm:pb-0">
          <div className="min-w-0">
            <h2 id="judul-dialog" className="text-xl font-semibold text-fg">
              {judul}
            </h2>
            {deskripsi && (
              <p id="deskripsi-dialog" className="mt-1 text-sm text-fg-muted">
                {deskripsi}
              </p>
            )}
          </div>

          {!tanpaTombolTutup && (
            <button
              type="button"
              onClick={onTutup}
              aria-label="Tutup dialog"
              className={cn(
                'inline-flex size-11 shrink-0 cursor-pointer items-center justify-center rounded-md',
                'text-fg-muted transition-colors duration-150 hover:bg-surface-raised hover:text-fg',
                'sm:size-9',
              )}
            >
              <X className="size-5" aria-hidden="true" />
            </button>
          )}
        </div>

        <div className="p-4 sm:p-6">{children}</div>
      </div>
    </div>,
    document.body,
  );
}
