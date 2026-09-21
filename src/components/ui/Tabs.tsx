import { useId, useRef, useState, type KeyboardEvent, type ReactNode } from 'react';
import { cn } from '@/lib/cn';

/* =========================================================
   Tabs
   Dipakai untuk tab bahasa C++ / Python di blok kode.

   Mengikuti pola WAI-ARIA Tabs: panah kiri/kanan memindah tab,
   Home/End ke tab pertama/terakhir.
   ========================================================= */

export interface ItemTab {
  /** Nilai unik tab */
  nilai: string;
  /** Label yang terlihat */
  label: string;
  /** Konten tab */
  konten: ReactNode;
}

interface TabsProps {
  item: ItemTab[];
  /** Tab yang aktif saat pertama dirender */
  awal?: string;
  className?: string;
}

export function Tabs({ item, awal, className }: TabsProps) {
  const idDasar = useId();
  const [aktif, setAktif] = useState(awal ?? item[0]?.nilai ?? '');
  const refTombol = useRef<(HTMLButtonElement | null)[]>([]);

  const indeksAktif = item.findIndex((t) => t.nilai === aktif);

  function pindah(arah: 1 | -1 | 'awal' | 'akhir') {
    if (item.length === 0) return;
    let baru: number;
    if (arah === 'awal') baru = 0;
    else if (arah === 'akhir') baru = item.length - 1;
    else baru = (indeksAktif + arah + item.length) % item.length;

    const tab = item[baru];
    if (!tab) return;
    setAktif(tab.nilai);
    refTombol.current[baru]?.focus();
  }

  function onKeyDown(e: KeyboardEvent<HTMLDivElement>) {
    switch (e.key) {
      case 'ArrowRight':
        e.preventDefault();
        pindah(1);
        break;
      case 'ArrowLeft':
        e.preventDefault();
        pindah(-1);
        break;
      case 'Home':
        e.preventDefault();
        pindah('awal');
        break;
      case 'End':
        e.preventDefault();
        pindah('akhir');
        break;
    }
  }

  const tabAktif = item[indeksAktif];

  return (
    <div className={className}>
      <div
        role="tablist"
        aria-label="Pilih bahasa"
        onKeyDown={onKeyDown}
        className="flex flex-wrap gap-1 border-b border-border"
      >
        {item.map((t, i) => {
          const dipilih = t.nilai === aktif;
          return (
            <button
              key={t.nilai}
              ref={(el) => {
                refTombol.current[i] = el;
              }}
              type="button"
              role="tab"
              id={`${idDasar}-tab-${t.nilai}`}
              aria-selected={dipilih}
              aria-controls={`${idDasar}-panel-${t.nilai}`}
              tabIndex={dipilih ? 0 : -1}
              onClick={() => setAktif(t.nilai)}
              className={cn(
                'relative -mb-px cursor-pointer rounded-t-md px-4 text-sm',
                // Tinggi 44px di mobile (target sentuh), lebih rapat di desktop
                'flex h-11 items-center md:h-9',
                'transition-colors duration-150',
                dipilih
                  ? 'border-b-2 border-primary font-semibold text-fg'
                  : 'border-b-2 border-transparent text-fg-muted hover:text-fg',
              )}
            >
              {t.label}
            </button>
          );
        })}
      </div>

      {tabAktif && (
        <div
          role="tabpanel"
          id={`${idDasar}-panel-${tabAktif.nilai}`}
          aria-labelledby={`${idDasar}-tab-${tabAktif.nilai}`}
          tabIndex={0}
          className="pt-3"
        >
          {tabAktif.konten}
        </div>
      )}
    </div>
  );
}
