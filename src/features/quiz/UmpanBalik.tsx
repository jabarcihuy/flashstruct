import { Check, Info, X } from 'lucide-react';
import { cn } from '@/lib/cn';
import type { SoalDenganOpsi } from '@/types/database';
import { opsiBenar } from './sesi';

/**
 * Umpan balik setelah menjawab soal.
 *
 * Muncul SEGERA setelah menjawab, bukan di akhir quiz. Alasannya:
 * mengetahui kesalahan tepat setelah terjadi adalah saat paling
 * efektif untuk memperbaiki pemahaman.
 *
 * Aturan penting: penjelasan menjelaskan mengapa jawaban benar itu
 * benar, dan mengapa pengecoh salah. Bukan sekadar "jawabannya C".
 *
 * Rincian: docs/02-KURIKULUM.md §5.2
 */

interface UmpanBalikProps {
  soal: SoalDenganOpsi;
  /** Label opsi yang dipilih pengguna */
  dipilih: string;
  onLanjut: () => void;
  /** Apakah ini soal terakhir */
  soalTerakhir: boolean;
}

export function UmpanBalik({ soal, dipilih, onLanjut, soalTerakhir }: UmpanBalikProps) {
  const benar = opsiBenar(soal);
  const betul = benar?.label === dipilih;

  return (
    <div
      role="status"
      aria-live="polite"
      className={cn(
        'rounded-lg border-2 p-4 sm:p-5',
        betul ? 'border-success bg-success/5' : 'border-danger bg-danger/5',
      )}
    >
      {/* Kepala: status */}
      <div className="flex items-center gap-2">
        {betul ? (
          <>
            <Check className="size-5 text-success" aria-hidden="true" />
            <p className="font-semibold text-success">Jawaban benar</p>
          </>
        ) : (
          <>
            <X className="size-5 text-danger" aria-hidden="true" />
            <p className="font-semibold text-danger">Jawaban salah</p>
          </>
        )}
      </div>

      {/* Jika salah, tampilkan jawaban benar */}
      {!betul && benar && (
        <p className="mt-3 text-sm text-fg">
          <span className="font-medium">Jawaban benar: </span>
          <span className="font-semibold">
            {benar.label}. {benar.teks}
          </span>
        </p>
      )}

      {/* Penjelasan */}
      <div className="mt-4 border-t border-border pt-4">
        <p className="mb-2 flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wide text-fg-muted">
          <Info className="size-3.5" aria-hidden="true" />
          Penjelasan
        </p>
        <p className="whitespace-pre-wrap text-sm leading-relaxed text-fg">{soal.penjelasan}</p>
      </div>

      {/* Tombol lanjut */}
      <button
        type="button"
        onClick={onLanjut}
        className={cn(
          'mt-5 inline-flex h-12 w-full cursor-pointer items-center justify-center gap-2 rounded-lg',
          'bg-primary text-base font-medium text-on-primary',
          'transition-opacity duration-150 hover:opacity-90',
        )}
      >
        {soalTerakhir ? 'Lihat Hasil' : 'Soal Berikutnya'}
        <span className="hidden text-xs opacity-70 md:inline">(Enter)</span>
      </button>
    </div>
  );
}
