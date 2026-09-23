import type { ReactNode } from 'react';
import { AlertTriangle, Info, Lightbulb } from 'lucide-react';
import { cn } from '@/lib/cn';
import type { TipeCallout } from './util';

/**
 * Callout untuk menyorot hal penting di modul.
 *
 * Dipakai lewat sintaks markdown:
 *   > [!INFO]      konteks tambahan
 *   > [!PERHATIAN] jebakan, kesalahan umum
 *   > [!BAHAYA]    undefined behavior, kehilangan data
 *   > [!TIPS]      cara mengingat, jalan pintas
 *
 * Aturan: maksimal DUA callout per bagian modul. Lebih dari itu,
 * tidak ada lagi yang menonjol (docs/03-DESIGN-SYSTEM.md §6.5).
 */

interface CalloutProps {
  tipe: TipeCallout;
  children: ReactNode;
  judul?: string;
}

const KONFIG: Record<
  TipeCallout,
  { ikon: typeof Info; label: string; warna: string; latar: string }
> = {
  info: {
    ikon: Info,
    label: 'Info',
    warna: 'var(--primary)',
    latar: 'color-mix(in srgb, var(--primary) 8%, transparent)',
  },
  perhatian: {
    ikon: AlertTriangle,
    label: 'Perhatian',
    warna: 'var(--topik-pointer)',
    latar: 'color-mix(in srgb, var(--topik-pointer) 10%, transparent)',
  },
  bahaya: {
    ikon: AlertTriangle,
    label: 'Bahaya',
    warna: 'var(--danger)',
    latar: 'color-mix(in srgb, var(--danger) 8%, transparent)',
  },
  tips: {
    ikon: Lightbulb,
    label: 'Tips',
    warna: 'var(--success)',
    latar: 'color-mix(in srgb, var(--success) 8%, transparent)',
  },
};

export function Callout({ tipe, children, judul }: CalloutProps) {
  const { ikon: Ikon, label, warna, latar } = KONFIG[tipe];

  return (
    <aside
      role="note"
      aria-label={judul ?? label}
      className={cn('my-5 rounded-lg border p-4')}
      style={{
        borderColor: `color-mix(in srgb, ${warna} 32%, transparent)`,
        backgroundColor: latar,
      }}
    >
      <div className="flex items-start gap-3">
        <Ikon className="mt-0.5 size-5 shrink-0" style={{ color: warna }} aria-hidden="true" />
        <div className="min-w-0 flex-1">
          <p className="mb-1 text-sm font-semibold" style={{ color: warna }}>
            {judul ?? label}
          </p>
          <div className="text-sm text-fg [&>p]:my-0 [&>p+p]:mt-2 [&>ul]:my-2 [&>ol]:my-2 [&>pre]:my-2">
            {children}
          </div>
        </div>
      </div>
    </aside>
  );
}

export type { TipeCallout };
