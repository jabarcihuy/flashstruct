import type { ReactNode } from 'react';
import { cn } from '@/lib/cn';

/** Kartu dasar — dipakai di seluruh aplikasi */
export function Card({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <div
      className={cn(
        'rounded-lg border border-border bg-surface shadow-[var(--shadow-sm)]',
        className,
      )}
    >
      {children}
    </div>
  );
}

/** Badge label kecil */
export function Badge({
  children,
  warna,
  className,
}: {
  children: ReactNode;
  /** Warna topik atau semantik */
  warna?: string;
  className?: string;
}) {
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold',
        'uppercase tracking-wide',
        className,
      )}
      /**
       * Tint 6% — BUKAN 14% seperti sebelumnya.
       *
       * Latar yang di-tint dengan warna teksnya sendiri akan MENURUNKAN
       * kontras. Terukur: pada tint 14%, kombinasi terburuk hanya 4.07:1
       * (gagal WCAG AA). Tint 6% adalah nilai tertinggi yang tetap lolos
       * di SEMUA kombinasi warna topik x permukaan x tema (terendah 4.54:1).
       */
      style={
        warna
          ? {
              color: warna,
              backgroundColor: `color-mix(in srgb, ${warna} 6%, transparent)`,
              // Border memberi definisi bentuk tanpa menurunkan kontras teks
              border: `1px solid color-mix(in srgb, ${warna} 28%, transparent)`,
            }
          : undefined
      }
    >
      {children}
    </span>
  );
}

/** Judul halaman dengan deskripsi opsional */
export function PageHeader({
  judul,
  deskripsi,
  aksi,
}: {
  judul: string;
  deskripsi?: string;
  aksi?: ReactNode;
}) {
  return (
    <div className="mb-6 flex flex-wrap items-start justify-between gap-4 md:mb-8">
      <div className="min-w-0">
        <h1 className="text-3xl font-bold text-fg md:text-4xl">{judul}</h1>
        {deskripsi && <p className="mt-2 text-fg-muted">{deskripsi}</p>}
      </div>
      {aksi && <div className="shrink-0">{aksi}</div>}
    </div>
  );
}
