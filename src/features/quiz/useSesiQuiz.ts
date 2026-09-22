import { useCallback, useEffect, useMemo, useReducer, useRef } from 'react';
import { useQuery } from '@tanstack/react-query';
import { ambilSoalModul } from './api';
import {
  hitungAkurasiTopik,
  hitungHasil,
  reducerQuiz,
  soalSekarang,
  soalTerakhir,
  stateAwal,
  susunSoal,
  type AkurasiTopik,
  type HasilSesiQuiz,
  type StateQuiz,
} from './sesi';
import { useProgres } from '@/features/progres/context';

/**
 * Hook sesi quiz.
 *
 * Menggabungkan:
 *   - Query soal dari Supabase
 *   - Pengacakan soal dan opsi
 *   - State machine sesi
 *   - Kontrol keyboard (1-4 pilih, Enter lanjut)
 *   - Penyimpanan hasil ke progres
 *
 * Sesi disimpan di memori, bukan localStorage. Yang disimpan hanya
 * hasil akhir.
 */
export function useSesiQuiz(slugModul: string) {
  const { simpanHasilQuiz, tandaiQuizSelesai } = useProgres();

  const [state, dispatch] = useReducer(reducerQuiz, undefined, () => stateAwal([]));
  const sudahDisusun = useRef(false);
  const sudahDisimpan = useRef(false);

  const {
    data: bankSoal,
    isPending,
    isError,
    error,
    refetch,
  } = useQuery({
    queryKey: ['quiz', slugModul],
    queryFn: () => ambilSoalModul(slugModul),
    enabled: Boolean(slugModul),
  });

  const modulId = bankSoal?.[0]?.modul_id ?? '';

  // Susun soal sekali saat bank soal pertama kali tersedia
  useEffect(() => {
    if (!bankSoal || sudahDisusun.current) return;
    if (bankSoal.length === 0) return;

    sudahDisusun.current = true;
    dispatch({ tipe: 'INIT', soal: susunSoal(bankSoal) });
  }, [bankSoal]);

  const hasil: HasilSesiQuiz = useMemo(() => hitungHasil(state), [state]);
  const akurasiTopik: AkurasiTopik[] = useMemo(() => hitungAkurasiTopik(state), [state]);

  // Simpan hasil saat sesi selesai
  useEffect(() => {
    if (state.fase !== 'selesai') return;
    if (!modulId || sudahDisimpan.current) return;
    if (state.soal.length === 0) return;

    sudahDisimpan.current = true;

    simpanHasilQuiz(modulId, {
      waktu: Date.now(),
      skor: hasil.skor,
      jumlahBenar: hasil.jumlahBenar,
      jumlahSoal: hasil.jumlahSoal,
    });

    // Tahap 3 SELALU dianggap selesai, apapun nilainya.
    // Memaksa nilai tinggi akan membuat pengguna terjebak mengulang.
    tandaiQuizSelesai(modulId);
  }, [state.fase, state.soal.length, modulId, hasil, simpanHasilQuiz, tandaiQuizSelesai]);

  const soal = soalSekarang(state);

  /* =========================================================
     Aksi
     ========================================================= */

  const jawab = useCallback(
    (label: string) => {
      if (!soal) return;
      dispatch({ tipe: 'JAWAB', soalId: soal.id, label });
    },
    [soal],
  );

  const lanjut = useCallback(() => dispatch({ tipe: 'LANJUT' }), []);

  /* =========================================================
     Kontrol keyboard
     ========================================================= */

  useEffect(() => {
    function onKeyDown(e: KeyboardEvent) {
      const target = e.target as HTMLElement;
      if (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA') return;

      // Sudah dijawab: Enter/Space untuk lanjut
      if (state.sudahDijawab) {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          lanjut();
        }
        return;
      }

      // Belum dijawab: 1-4 untuk pilih opsi
      const nomor = Number(e.key);
      if (nomor >= 1 && nomor <= 4) {
        const opsi = soal?.opsi_soal?.[nomor - 1];
        if (opsi) {
          e.preventDefault();
          jawab(opsi.label);
        }
      }
    }

    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [state.sudahDijawab, soal, jawab, lanjut]);

  return {
    state,
    soal,
    hasil,
    akurasiTopik,
    isPending,
    isError,
    error,
    refetch,
    jawab,
    lanjut,
    soalTerakhir: soalTerakhir(state),
    modulId,
    jumlahSoalBank: bankSoal?.length ?? 0,
    judulModul: bankSoal?.[0]?.modul.slug ?? '',
  };
}

export type { StateQuiz, HasilSesiQuiz, AkurasiTopik };
