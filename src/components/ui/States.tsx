import type { ReactNode } from 'react';
import { AlertTriangle, Inbox, RefreshCw } from 'lucide-react';
import { Button } from './Button';
import { cn } from '@/lib/cn';

/**
 * Keadaan kosong.
 *
 * Selalu punya tiga bagian: ikon, penjelasan, dan aksi.
 * Halaman kosong tanpa arah membuat pengguna bingung.
 */
export function EmptyState({
  judul,
  pesan,
  aksi,
  ikon,
  className,
}: {
  judul: string;
  pesan: string;
  aksi?: ReactNode;
  ikon?: ReactNode;
  className?: string;
}) {
  return (
    <div className={cn('flex flex-col items-center gap-4 py-16 text-center', className)}>
      <div className="text-fg-muted" aria-hidden="true">
        {ikon ?? <Inbox className="size-12" strokeWidth={1.5} />}
      </div>
      <div>
        <h2 className="text-xl font-semibold text-fg">{judul}</h2>
        <p className="mx-auto mt-2 max-w-md text-fg-muted">{pesan}</p>
      </div>
      {aksi}
    </div>
  );
}

/**
 * Keadaan error.
 *
 * Aturan pesan: sebutkan apa yang gagal, kemungkinan penyebab,
 * dan apa yang bisa dilakukan. Jangan tampilkan kode error mentah.
 */
export function ErrorState({
  judul,
  pesan,
  onCobaLagi,
  className,
}: {
  judul: string;
  pesan: string;
  onCobaLagi?: () => void;
  className?: string;
}) {
  return (
    <div
      role="alert"
      className={cn('flex flex-col items-center gap-4 py-16 text-center', className)}
    >
      <AlertTriangle className="size-12 text-danger" strokeWidth={1.5} aria-hidden="true" />
      <div>
        <h2 className="text-xl font-semibold text-fg">{judul}</h2>
        <p className="mx-auto mt-2 max-w-md text-fg-muted">{pesan}</p>
      </div>
      {onCobaLagi && (
        <Button varian="secondary" onClick={onCobaLagi} ikonKiri={<RefreshCw className="size-4" aria-hidden="true" />}>
          Coba lagi
        </Button>
      )}
    </div>
  );
}

/** Skeleton dengan tinggi yang sama dengan konten akhir (cegah CLS) */
export function Skeleton({ className }: { className?: string }) {
  return (
    <div
      className={cn('animate-pulse rounded-md bg-surface-raised', className)}
      aria-hidden="true"
    />
  );
}
