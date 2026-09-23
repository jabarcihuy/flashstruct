import { Eye, RotateCcw } from 'lucide-react';
import { cn } from '@/lib/cn';
import { CodeBlock } from '@/components/code/CodeBlock';
import { Badge } from '@/components/ui/Card';
import { LABEL_TIPE_KARTU, LABEL_TOPIK } from '@/lib/constants';
import { barisKonten } from '@/lib/format';
import type { KartuDenganModul, TopikModul } from '@/types/database';

/**
 * Kartu flashcard dengan animasi flip.
 *
 * Keputusan desain penting (docs/03-DESIGN-SYSTEM.md §6.3):
 *   - Tinggi kartu TETAP. Kalau tinggi berubah saat flip, mata
 *     kehilangan posisi dan pengalaman terasa gelisah.
 *   - Konten panjang di-scroll DI DALAM kartu, tidak memanjangkan kartu.
 *   - Tombol penilaian HANYA muncul setelah dibalik — memaksa
 *     membaca jawaban dulu.
 *   - prefers-reduced-motion: flip diganti pergantian langsung.
 */

interface FlashcardProps {
  kartu: KartuDenganModul;
  terbuka: boolean;
  keluar: boolean;
  arahKeluar: 1 | -1;
  /** Nomor kartu saat ini (1-based) */
  nomor: number;
  total: number;
  onBalik: () => void;
}

export function Flashcard({
  kartu,
  terbuka,
  keluar,
  arahKeluar,
  nomor,
  total,
  onBalik,
}: FlashcardProps) {
  const warnaTopik = `var(--topik-${kartu.modul.topik})`;

  return (
    <div
      className={cn(
        'flashcard relative w-full max-w-[560px]',
        terbuka && 'terbuka',
        // Animasi masuk/keluar
        'transition-[opacity,transform] duration-150 ease-out',
        keluar && (arahKeluar === 1 ? 'translate-x-10 opacity-0' : '-translate-x-10 opacity-0'),
      )}
      // Keluar lebih cepat dari masuk — membuat UI terasa responsif
      style={{ transitionDuration: keluar ? '160ms' : '200ms' }}
    >
      {/* Wadah flip — tinggi tetap agar tidak bergeser saat dibalik */}
      <div className="flashcard-inner h-[min(420px,65dvh)] min-h-[320px]">
        {/* ---------- Sisi depan ---------- */}
        <div
          className={cn(
            'flashcard-face flashcard-front absolute inset-0 flex flex-col',
            'rounded-md border border-border bg-surface p-6 shadow-[var(--shadow-md)] sm:p-8',
          )}
        >
          <KepalaKartu
            warnaTopik={warnaTopik}
            topik={kartu.modul.topik}
            tipe={kartu.card_type}
            nomor={nomor}
            total={total}
          />

          {/* Pertanyaan — bisa di-scroll kalau panjang */}
          <div className="flex min-h-0 flex-1 items-center justify-center overflow-y-auto py-4">
            <p className="whitespace-pre-wrap text-center text-xl font-semibold leading-snug text-fg sm:text-2xl">
              {barisKonten(kartu.depan)}
            </p>
          </div>

          {/* Tombol balik — seluruh kartu juga bisa diklik */}
          <button
            type="button"
            onClick={onBalik}
            className={cn(
              'mt-4 inline-flex h-12 w-full cursor-pointer items-center justify-center gap-2',
              'rounded-md border border-border-strong bg-surface-raised',
              'text-sm font-medium text-fg transition-colors duration-150',
              'hover:bg-surface',
            )}
          >
            <Eye className="size-4" aria-hidden="true" />
            Lihat Jawaban
            <span className="hidden text-xs text-fg-muted sm:inline">(Spasi)</span>
          </button>
        </div>

        {/* ---------- Sisi belakang ---------- */}
        <div
          className={cn(
            'flashcard-face flashcard-back absolute inset-0 flex flex-col',
            'rounded-md border border-border bg-surface p-6 shadow-[var(--shadow-md)] sm:p-8',
          )}
        >
          <KepalaKartu
            warnaTopik={warnaTopik}
            topik={kartu.modul.topik}
            tipe={kartu.card_type}
            nomor={nomor}
            total={total}
          />

          {/* Jawaban — bisa di-scroll */}
          <div className="flex min-h-0 flex-1 flex-col overflow-y-auto py-4">
            <p className="whitespace-pre-wrap text-base leading-relaxed text-fg sm:text-lg">
              {barisKonten(kartu.belakang)}
            </p>

            {/* Blok kode kalau kartu punya kode */}
            {kartu.kode && (
              <div className="mt-3">
                <CodeBlock
                  kode={barisKonten(kartu.kode)}
                  bahasa={kartu.bahasa_kode ?? undefined}
                  className="my-0"
                />
              </div>
            )}
          </div>

          {/* Petunjuk penilaian */}
          <p className="mt-3 text-center text-xs text-fg-muted">
            Nilai dirimu sendiri — jujur lebih bermanfaat
          </p>
        </div>
      </div>
    </div>
  );
}

/** Kepala kartu: label topik, tipe kartu, dan posisi */
function KepalaKartu({
  warnaTopik,
  topik,
  tipe,
  nomor,
  total,
}: {
  warnaTopik: string;
  topik: TopikModul;
  tipe: string;
  nomor: number;
  total: number;
}) {
  return (
    <div className="flex items-start justify-between gap-3">
      <div className="flex flex-wrap items-center gap-2">
        <Badge warna={warnaTopik}>{LABEL_TOPIK[topik]}</Badge>
        <span className="text-xs text-fg-muted">{LABEL_TIPE_KARTU[tipe]}</span>
      </div>
      <span className="shrink-0 font-mono text-xs tabular-nums text-fg-muted">
        {nomor} / {total}
      </span>
    </div>
  );
}

/**
 * Petunjuk keyboard.
 *
 * Ditampilkan hanya di desktop, karena keyboard fisik jarang dipakai
 * di HP. Di mobile, petunjuk ini hanya menambah kebisingan visual.
 */
export function PetunjukKeyboard({ terbuka }: { terbuka: boolean }) {
  return (
    <div className="hidden text-center text-xs text-fg-muted md:block">
      {terbuka ? (
        <span>
          <TombolKecil>1</TombolKecil> Lupa · <TombolKecil>2</TombolKecil> Ingat ·{' '}
          <TombolKecil>Esc</TombolKecil> Keluar
        </span>
      ) : (
        <span>
          <TombolKecil>Spasi</TombolKecil> untuk membalik kartu
        </span>
      )}
    </div>
  );
}

/** Tombol kecil untuk menampilkan tombol keyboard */
function TombolKecil({ children }: { children: React.ReactNode }) {
  return (
    <kbd className="rounded border border-border bg-surface-raised px-1.5 py-0.5 font-mono text-[11px] text-fg">
      {children}
    </kbd>
  );
}

/** Ikon untuk tombol ulangi */
export const IkonUlangi = RotateCcw;
