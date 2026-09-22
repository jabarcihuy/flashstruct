import { useCallback, useEffect, useMemo, useReducer, useRef } from 'react';
import { useQuery } from '@tanstack/react-query';
import { ambilKartuModul } from './api';
import {
  hitungRingkasan,
  kartuSekarang,
  reducerSesi,
  stateAwal,
  type RingkasanSesi,
  type StateSesi,
} from './sesi';
import { susunDeck } from './prioritas';
import { useProgres } from '@/features/progres/context';
import { MAKS_KARTU_PER_SESI } from '@/lib/constants';

/**
 * Hook sesi flashcard.
 *
 * Menggabungkan:
 *   - Query kartu dari Supabase
 *   - Pengurutan berdasarkan prioritas
 *   - State machine sesi
 *   - Kontrol keyboard
 *   - Penyimpanan hasil ke progres
 *
 * Sesi disimpan di MEMORI, bukan localStorage per kartu. Menulis 20
 * kali dalam satu sesi itu lambat dan tidak perlu. Yang disimpan hanya
 * hasil akhir. Konsekuensinya: menutup tab di tengah sesi menghilangkan
 * sesi — ini diterima (docs/04-ARSITEKTUR-TEKNIS.md §3.3).
 */

/** Durasi animasi kartu keluar — harus sama dengan CSS */
const DURASI_KELUAR_MS = 160;

export function useSesiFlashcard(slugModul: string) {
  const { ambilModul, simpanHasilSesiKartu, tandaiFlashcardSelesai } = useProgres();

  const [state, dispatch] = useReducer(reducerSesi, undefined, () => stateAwal([]));

  // Query kartu dari Supabase
  const {
    data: semuaKartu,
    isPending,
    isError,
    error,
    refetch,
  } = useQuery({
    queryKey: ['flashcard', slugModul],
    queryFn: () => ambilKartuModul(slugModul),
    enabled: Boolean(slugModul),
  });

  const modulId = semuaKartu?.[0]?.modul_id ?? '';
  const statusKartu = ambilModul(modulId)?.kartu ?? {};

  // Sudah pernah disusun deck-nya? Cegah penyusunan ulang yang akan
  // mengacak urutan kartu di tengah sesi.
  const sudahDisusun = useRef(false);

  /**
   * Susun deck lalu kirim ke reducer lewat aksi INIT.
   *
   * Deck disusun di dalam effect (bukan saat render) karena penyusunan
   * melibatkan pengacakan — kalau dilakukan saat render, urutannya akan
   * berubah setiap render dan sesi menjadi tidak stabil.
   */
  useEffect(() => {
    if (!semuaKartu || sudahDisusun.current) return;
    if (semuaKartu.length === 0) return;

    sudahDisusun.current = true;
    const deck = susunDeck(semuaKartu, statusKartu);
    dispatch({ tipe: 'INIT', kartu: deck });
    // statusKartu sengaja tidak jadi dependency: deck hanya disusun sekali
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [semuaKartu]);

  // Simpan hasil saat sesi selesai
  const sudahDisimpan = useRef(false);
  useEffect(() => {
    if (state.fase !== 'selesai') return;
    if (!modulId || sudahDisimpan.current) return;
    if (Object.keys(state.hasil).length === 0) return;

    sudahDisimpan.current = true;
    simpanHasilSesiKartu(modulId, state.hasil);

    const ringkasan = hitungRingkasan(state.hasil);
    // Tahap 2 selesai hanya jika SEMUA kartu minimal sekali "Ingat"
    if (ringkasan.semuaDikuasai) {
      tandaiFlashcardSelesai(modulId);
    }
  }, [state.fase, state.hasil, modulId, simpanHasilSesiKartu, tandaiFlashcardSelesai]);

  // Setelah animasi keluar selesai, lanjut ke kartu berikutnya
  useEffect(() => {
    if (!state.keluar) return;
    const timer = window.setTimeout(() => {
      dispatch({ tipe: 'KARTU_KELUAR_SELESAI' });
    }, DURASI_KELUAR_MS);
    return () => window.clearTimeout(timer);
  }, [state.keluar]);

  const kartu = kartuSekarang(state);
  const ringkasan = useMemo(() => hitungRingkasan(state.hasil), [state.hasil]);

  /* =========================================================
     Aksi
     ========================================================= */

  const balik = useCallback(() => dispatch({ tipe: 'BALIK' }), []);

  const nilai = useCallback(
    (ingat: boolean) => {
      if (!kartu) return;
      dispatch({ tipe: 'NILAI', kartuId: kartu.id, ingat });
    },
    [kartu],
  );

  const mulaiUlangan = useCallback(() => dispatch({ tipe: 'MULAI_ULANGAN' }), []);
  const lewatiUlangan = useCallback(() => dispatch({ tipe: 'LEWATI_ULANGAN' }), []);

  /* =========================================================
     Kontrol keyboard
     ========================================================= */

  useEffect(() => {
    function onKeyDown(e: KeyboardEvent) {
      // Jangan tangkap tombol kalau fokus ada di input
      const target = e.target as HTMLElement;
      if (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA') return;

      // Spasi/Enter: balik kartu
      if (e.key === ' ' || e.key === 'Enter') {
        e.preventDefault();
        if (!state.terbuka) balik();
        return;
      }

      // Hanya bisa menilai setelah kartu dibalik
      if (!state.terbuka || state.keluar) return;

      if (e.key === '1' || e.key === 'ArrowLeft') {
        e.preventDefault();
        nilai(false);
      } else if (e.key === '2' || e.key === 'ArrowRight') {
        e.preventDefault();
        nilai(true);
      }
    }

    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [state.terbuka, state.keluar, balik, nilai]);

  return {
    state,
    kartu,
    ringkasan,
    /**
     * Siap kalau query SUDAH SELESAI.
     *
     * Jangan tunggu deck tersusun — kalau modul tidak punya kartu,
     * deck akan kosong selamanya dan halaman stuck di skeleton.
     * Halaman yang menangani kasus "tidak ada kartu" lewat
     * `jumlahKartuTotal === 0`.
     */
    isPending,
    isError,
    error,
    refetch,
    balik,
    nilai,
    mulaiUlangan,
    lewatiUlangan,
    modulId,
    jumlahKartuTotal: semuaKartu?.length ?? 0,
    maksKartuPerSesi: MAKS_KARTU_PER_SESI,
  };
}

export type { StateSesi, RingkasanSesi };
