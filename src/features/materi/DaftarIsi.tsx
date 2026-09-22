import { useEffect, useState } from 'react';
import { Check, List, X } from 'lucide-react';
import { cn } from '@/lib/cn';
import type { BagianModul } from '@/types/database';

/**
 * Daftar isi modul.
 *
 * Dipecah menjadi DUA komponen terpisah agar tidak ada tumpang tindih
 * breakpoint:
 *   - TombolDaftarIsiMobile : tombol + drawer, HANYA untuk mobile
 *   - SidebarDaftarIsi      : sidebar sticky, HANYA untuk desktop
 *
 * Halaman yang memakainya bertanggung jawab menyembunyikan salah satu
 * lewat CSS. Ini lebih aman daripada satu komponen yang merender
 * keduanya, karena mudah tanpa sengaja membungkus keduanya dalam
 * wrapper yang menyembunyikan salah satunya.
 */

interface DaftarIsiProps {
  bagian: BagianModul[];
  bagianDibaca: string[];
  /** Slug bagian yang sedang terlihat di layar */
  bagianAktif?: string;
  /** Persentase progres baca */
  persen: number;
}

/* =========================================================
   Mobile: tombol + drawer
   ========================================================= */

export function TombolDaftarIsiMobile({
  bagian,
  bagianDibaca,
  bagianAktif,
  persen,
}: DaftarIsiProps) {
  const [terbuka, setTerbuka] = useState(false);

  return (
    <>
      <button
        type="button"
        onClick={() => setTerbuka(true)}
        className={cn(
          'inline-flex h-11 cursor-pointer items-center gap-2 rounded-md border border-border-strong px-3',
          'text-sm text-fg',
        )}
        aria-expanded={terbuka}
        aria-controls="daftar-isi-mobile"
      >
        <List className="size-4" aria-hidden="true" />
        Daftar Isi
        <span className="text-fg-muted">{persen}%</span>
      </button>

      {terbuka && (
        <DrawerDaftarIsi
          bagian={bagian}
          bagianDibaca={bagianDibaca}
          bagianAktif={bagianAktif}
          persen={persen}
          onTutup={() => setTerbuka(false)}
        />
      )}
    </>
  );
}

/* =========================================================
   Desktop: sidebar sticky
   ========================================================= */

export function SidebarDaftarIsi({ bagian, bagianDibaca, bagianAktif, persen }: DaftarIsiProps) {
  return (
    <nav
      aria-label="Daftar isi modul"
      className="sticky top-20 max-h-[calc(100dvh-6rem)] overflow-y-auto"
    >
      <p className="mb-3 text-xs font-semibold uppercase tracking-wide text-fg-muted">Daftar Isi</p>
      <ol className="space-y-1">
        {bagian.map((b, i) => (
          <ItemDaftarIsi
            key={b.id}
            bagian={b}
            nomor={i + 1}
            sudahDibaca={bagianDibaca.includes(b.slug)}
            aktif={bagianAktif === b.slug}
          />
        ))}
      </ol>
      <ProgresBaca persen={persen} />
    </nav>
  );
}

/* =========================================================
   Bagian dalam
   ========================================================= */

/** Satu item daftar isi */
function ItemDaftarIsi({
  bagian,
  nomor,
  sudahDibaca,
  aktif,
}: {
  bagian: BagianModul;
  nomor: number;
  sudahDibaca: boolean;
  aktif: boolean;
}) {
  return (
    <li>
      <a
        href={`#${bagian.slug}`}
        className={cn(
          'flex items-start gap-2 rounded-md px-2 py-1.5 text-sm no-underline',
          'transition-colors duration-150',
          aktif ? 'bg-surface-raised font-medium text-fg' : 'text-fg-muted hover:text-fg',
        )}
        aria-current={aktif ? 'location' : undefined}
      >
        <span className="mt-0.5 shrink-0" aria-hidden="true">
          {sudahDibaca ? (
            <Check className="size-4 text-success" />
          ) : (
            <span className="inline-flex size-4 items-center justify-center font-mono text-xs opacity-60">
              {nomor}
            </span>
          )}
        </span>
        <span className="min-w-0 flex-1">{bagian.judul}</span>
        <span className="sr-only">{sudahDibaca ? 'sudah dibaca' : 'belum dibaca'}</span>
      </a>
    </li>
  );
}

/** Bar progres baca */
function ProgresBaca({ persen }: { persen: number }) {
  return (
    <div className="mt-4 border-t border-border pt-3">
      <div className="mb-1.5 flex items-baseline justify-between text-xs">
        <span className="text-fg-muted">Progres baca</span>
        <span className="font-medium tabular-nums text-fg">{persen}%</span>
      </div>
      <div
        role="progressbar"
        aria-valuenow={persen}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-label="Progres baca modul"
        className="h-1.5 w-full overflow-hidden rounded-full bg-surface-raised"
      >
        <div
          className="h-full rounded-full bg-primary transition-[width] duration-300"
          style={{ width: `${persen}%` }}
        />
      </div>
    </div>
  );
}

/** Drawer daftar isi untuk mobile */
function DrawerDaftarIsi({
  bagian,
  bagianDibaca,
  bagianAktif,
  persen,
  onTutup,
}: DaftarIsiProps & { onTutup: () => void }) {
  // Kunci scroll body + Escape menutup
  useEffect(() => {
    const overflowAsli = document.body.style.overflow;
    document.body.style.overflow = 'hidden';

    function onKeyDown(e: KeyboardEvent) {
      if (e.key === 'Escape') onTutup();
    }
    document.addEventListener('keydown', onKeyDown);

    return () => {
      document.body.style.overflow = overflowAsli;
      document.removeEventListener('keydown', onKeyDown);
    };
  }, [onTutup]);

  return (
    <div className="fixed inset-0 z-50">
      <div className="absolute inset-0 bg-black/50" onClick={onTutup} aria-hidden="true" />
      <div
        id="daftar-isi-mobile"
        role="dialog"
        aria-modal="true"
        aria-label="Daftar isi modul"
        className="absolute inset-y-0 left-0 w-80 max-w-[85vw] overflow-y-auto bg-surface p-4 shadow-[var(--shadow-md)]"
      >
        <div className="mb-4 flex items-center justify-between">
          <p className="font-semibold text-fg">Daftar Isi</p>
          <button
            type="button"
            onClick={onTutup}
            aria-label="Tutup daftar isi"
            className="inline-flex size-11 cursor-pointer items-center justify-center rounded-md text-fg-muted hover:text-fg"
          >
            <X className="size-5" aria-hidden="true" />
          </button>
        </div>

        <ol className="space-y-1">
          {bagian.map((b, i) => (
            <ItemDaftarIsi
              key={b.id}
              bagian={b}
              nomor={i + 1}
              sudahDibaca={bagianDibaca.includes(b.slug)}
              aktif={bagianAktif === b.slug}
            />
          ))}
        </ol>

        <ProgresBaca persen={persen} />
      </div>
    </div>
  );
}
