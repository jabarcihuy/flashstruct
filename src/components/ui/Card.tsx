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
      style={warna ? { color: warna, backgroundColor: `color-mix(in srgb, ${warna} 14%, transparent)` } : undefined}
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
