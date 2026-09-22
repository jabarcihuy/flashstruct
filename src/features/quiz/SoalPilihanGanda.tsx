import { Check, X } from 'lucide-react';
import { cn } from '@/lib/cn';
import { CodeBlock } from '@/components/code/CodeBlock';
import type { SoalDenganOpsi } from '@/types/database';
import { opsiBenar } from './sesi';

/**
 * Soal pilihan ganda (tipe PG, TRACE, dan ANALISIS).
 *
 * Perbedaan tipe:
 *   PG       : pertanyaan biasa tanpa kode
 *   TRACE    : ada blok kode, pengguna menentukan output
 *   ANALISIS : ada blok kode, pengguna menemukan penyebab bug
 *
 * Aturan visual umpan balik (docs/03-DESIGN-SYSTEM.md §2.9):
 *   Warna benar/salah SELALU disertai ikon dan teks — bukan warna saja,
 *   agar tetap jelas bagi pengguna dengan gangguan penglihatan warna.
 */

const LABEL_TIPE: Record<string, string> = {
  PG: 'Pilihan Ganda',
  TRACE: 'Tracing Kode',
  ANALISIS: 'Analisis Kesalahan',
};

interface SoalPilihanGandaProps {
  soal: SoalDenganOpsi;
  /** Label opsi yang dipilih, atau undefined */
  dipilih: string | undefined;
  /** Apakah sudah dijawab (umpan balik ditampilkan) */
  sudahDijawab: boolean;
  onPilih: (label: string) => void;
}

export function SoalPilihanGanda({
  soal,
  dipilih,
  sudahDijawab,
  onPilih,
}: SoalPilihanGandaProps) {
  const benar = opsiBenar(soal);
  const opsi = soal.opsi_soal ?? [];

  return (
    <div>
      {/* Label tipe soal */}
      <span className="inline-block rounded-full bg-surface-raised px-3 py-1 text-xs font-semibold uppercase tracking-wide text-fg-muted">
        {LABEL_TIPE[soal.tipe] ?? soal.tipe}
      </span>

      {/* Pertanyaan */}
      <p className="mt-3 text-lg font-medium leading-relaxed text-fg">{soal.pertanyaan}</p>

      {/* Blok kode — untuk soal TRACE dan ANALISIS */}
      {soal.kode && (
        <div className="mt-4">
          <CodeBlock
            kode={soal.kode}
            bahasa={soal.bahasa_kode ?? undefined}
            nomorBaris
            className="my-0"
          />
        </div>
      )}

      {/* Opsi jawaban */}
      <div className="mt-5 space-y-2.5" role="group" aria-label="Pilihan jawaban">
        {opsi.map((o, i) => {
          const iniDipilih = dipilih === o.label;
          const iniBenar = o.benar;

          // Tentukan gaya berdasarkan status
          let gaya = 'border-border bg-surface hover:border-border-strong';
          let status: 'benar' | 'salah' | 'jawaban-benar' | null = null;

          if (sudahDijawab) {
            if (iniDipilih && iniBenar) {
              gaya = 'border-success bg-success/10';
              status = 'benar';
            } else if (iniDipilih && !iniBenar) {
              gaya = 'border-danger bg-danger/10';
              status = 'salah';
            } else if (iniBenar) {
              gaya = 'border-success bg-success/10';
              status = 'jawaban-benar';
            } else {
              gaya = 'border-border bg-surface opacity-60';
            }
          } else if (iniDipilih) {
            gaya = 'border-primary bg-primary/10';
          }

          return (
            <button
              key={o.id}
              type="button"
              onClick={() => !sudahDijawab && onPilih(o.label)}
              disabled={sudahDijawab}
              aria-pressed={iniDipilih}
              className={cn(
                'flex w-full cursor-pointer items-start gap-3 rounded-lg border-2 p-4 text-left',
                'transition-colors duration-150',
                'disabled:cursor-default',
                gaya,
              )}
            >
              {/* Label opsi */}
              <span
                className={cn(
                  'flex size-7 shrink-0 items-center justify-center rounded-full text-sm font-semibold',
                  iniDipilih || (sudahDijawab && iniBenar)
                    ? 'bg-fg text-bg'
                    : 'bg-surface-raised text-fg-muted',
                )}
                aria-hidden="true"
              >
                {o.label}
              </span>

              {/* Teks opsi */}
              <span className="min-w-0 flex-1 pt-0.5 text-fg">
                <span className="block">{o.teks}</span>

                {/* Status: ikon + teks, bukan warna saja */}
                {status === 'benar' && (
                  <span className="mt-1.5 flex items-center gap-1 text-xs font-semibold text-success">
                    <Check className="size-3.5" aria-hidden="true" />
                    Jawabanmu benar
                  </span>
                )}
                {status === 'salah' && (
                  <span className="mt-1.5 flex items-center gap-1 text-xs font-semibold text-danger">
                    <X className="size-3.5" aria-hidden="true" />
                    Jawabanmu salah
                  </span>
                )}
                {status === 'jawaban-benar' && (
                  <span className="mt-1.5 flex items-center gap-1 text-xs font-semibold text-success">
                    <Check className="size-3.5" aria-hidden="true" />
                    Ini jawaban yang benar
                  </span>
                )}
              </span>

              {/* Nomor keyboard — hanya desktop */}
              {!sudahDijawab && (
                <kbd
                  className="hidden shrink-0 rounded border border-border bg-surface-raised px-1.5 py-0.5 font-mono text-[11px] text-fg-muted md:block"
                  aria-hidden="true"
                >
                  {i + 1}
                </kbd>
              )}
            </button>
          );
        })}
      </div>

      {/* Keterangan untuk pembaca layar */}
      {sudahDijawab && benar && (
        <p className="sr-only" role="status">
          Jawaban benar adalah {benar.label}: {benar.teks}
        </p>
      )}
    </div>
  );
}
