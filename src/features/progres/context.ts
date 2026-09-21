import { createContext, useContext } from 'react';
import type { HasilQuiz, ProgresGlobal, ProgresModul, StatusKartu } from './schema';

/**
 * Context progres.
 *
 * Dipisah dari komponen agar lint Fast Refresh bersih
 * (file yang hanya mengekspor komponen saja).
 */

export interface ProgresContextValue {
  /** Seluruh progres pengguna */
  progres: ProgresGlobal;
  /** Apakah progres sedang dimuat dari localStorage */
  sedangMemuat: boolean;

  /** Ambil progres satu modul */
  ambilModul: (modulId: string) => ProgresModul | undefined;

  /** Tandai satu bagian modul sudah dibaca */
  tandaiBagianDibaca: (modulId: string, bagianSlug: string) => void;

  /** Tandai tahap 1 (modul) selesai */
  tandaiModulSelesai: (modulId: string) => void;

  /** Batalkan tanda selesai modul */
  batalkanModulSelesai: (modulId: string) => void;

  /**
   * Simpan hasil sesi flashcard.
   * Kartu yang ditandai "Ingat" menambah jumlahIngat, "Lupa" menambah jumlahLupa.
   */
  simpanHasilSesiKartu: (modulId: string, hasil: Record<string, boolean>) => void;

  /** Tandai tahap 2 (flashcard) selesai */
  tandaiFlashcardSelesai: (modulId: string) => void;

  /** Simpan hasil quiz */
  simpanHasilQuiz: (modulId: string, hasil: HasilQuiz) => void;

  /** Tandai tahap 3 (quiz) selesai */
  tandaiQuizSelesai: (modulId: string) => void;

  /** Ambil status satu kartu */
  ambilStatusKartu: (modulId: string, kartuId: string) => StatusKartu | undefined;

  /** Hapus semua progres */
  resetProgres: () => void;

  /** Ganti seluruh progres (untuk impor) */
  gantiProgres: (progres: ProgresGlobal) => void;

  /** Apakah penyimpanan tersedia (false di mode privat) */
  penyimpananTersedia: boolean;
}

export const ProgresContext = createContext<ProgresContextValue | null>(null);

/** Hook untuk mengakses progres */
export function useProgres(): ProgresContextValue {
  const ctx = useContext(ProgresContext);
  if (!ctx) {
    throw new Error('useProgres harus dipakai di dalam ProgresProvider');
  }
  return ctx;
}
