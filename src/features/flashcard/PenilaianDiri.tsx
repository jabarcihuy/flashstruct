import { Check, X } from 'lucide-react';
import { cn } from '@/lib/cn';

/**
 * Tombol penilaian diri: Lupa / Ingat.
 *
 * HANYA muncul setelah kartu dibalik. Sebelum dibalik tidak ada tombol —
 * ini memaksa pengguna membaca jawaban dulu sebelum menilai diri.
 *
 * Warna: Lupa memakai `--danger` (merah), Ingat memakai `--success`
 * (hijau). Keduanya disertai ikon, bukan warna saja, agar tetap jelas
 * bagi pengguna dengan gangguan penglihatan warna.
 */

interface PenilaianDiriProps {
  onNilai: (ingat: boolean) => void;
  /** Nonaktifkan saat kartu sedang keluar */
  nonaktif?: boolean;
}

export function PenilaianDiri({ onNilai, nonaktif = false }: PenilaianDiriProps) {
  return (
    <div className="flex w-full max-w-[560px] gap-3">
      <button
        type="button"
        onClick={() => onNilai(false)}
        disabled={nonaktif}
        className={cn(
          'flex h-14 flex-1 cursor-pointer items-center justify-center gap-2 rounded-md',
          'border-2 border-danger/40 bg-danger/10 font-semibold text-danger',
          'transition-colors duration-150 hover:bg-danger/20',
          'disabled:cursor-not-allowed disabled:opacity-50',
        )}
      >
        <X className="size-5" aria-hidden="true" />
        Lupa
        <span className="hidden text-xs font-normal opacity-70 md:inline">(1)</span>
      </button>

      <button
        type="button"
        onClick={() => onNilai(true)}
        disabled={nonaktif}
        className={cn(
          'flex h-14 flex-1 cursor-pointer items-center justify-center gap-2 rounded-md',
          'border-2 border-success/40 bg-success/10 font-semibold text-success',
          'transition-colors duration-150 hover:bg-success/20',
          'disabled:cursor-not-allowed disabled:opacity-50',
        )}
      >
        <Check className="size-5" aria-hidden="true" />
        Ingat
        <span className="hidden text-xs font-normal opacity-70 md:inline">(2)</span>
      </button>
    </div>
  );
}
