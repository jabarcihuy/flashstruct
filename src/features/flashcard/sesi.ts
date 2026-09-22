import type { KartuDenganModul } from '@/types/database';

/**
 * State machine sesi flashcard.
 *
 * Dipisah dari komponen agar:
 *   - Semua transisi state terlihat di satu tempat
 *   - Tidak mungkin masuk ke state tidak valid
 *   - Bisa diuji tanpa merender komponen
 *
 * Alur:
 *   awal -> kerjakan -> (ulangan) -> selesai
 *
 * Rincian: docs/04-ARSITEKTUR-TEKNIS.md §3.3
 */

export type FaseSesi = 'kerjakan' | 'putaran-ulang' | 'selesai';

export interface StateSesi {
  fase: FaseSesi;
  /** Kartu yang dikerjakan di fase ini */
  kartu: KartuDenganModul[];
  /** Indeks kartu saat ini */
  indeks: number;
  /** Apakah kartu sedang dibalik (menampilkan jawaban) */
  terbuka: boolean;
  /** Hasil penilaian: kartuId -> ingat? */
  hasil: Record<string, boolean>;
  /** Putaran ke berapa (0 = sesi awal, 1 = ulangan) */
  putaran: number;
  /** Apakah kartu sedang dalam animasi keluar */
  keluar: boolean;
  /** Arah keluar: 1 = kanan (ingat), -1 = kiri (lupa) */
  arahKeluar: 1 | -1;
}

export type AksiSesi =
  | { tipe: 'INIT'; kartu: KartuDenganModul[] }
  | { tipe: 'BALIK' }
  | { tipe: 'NILAI'; kartuId: string; ingat: boolean }
  | { tipe: 'KARTU_KELUAR_SELESAI' }
  | { tipe: 'MULAI_ULANGAN' }
  | { tipe: 'LEWATI_ULANGAN' };

/** Buat state awal untuk sesi baru */
export function stateAwal(kartu: KartuDenganModul[]): StateSesi {
  return {
    fase: 'kerjakan',
    kartu,
    indeks: 0,
    terbuka: false,
    hasil: {},
    putaran: 0,
    keluar: false,
    arahKeluar: 1,
  };
}

/** Apakah sesi sudah diinisialisasi dengan kartu */
export function sesiKosong(state: StateSesi): boolean {
  return state.kartu.length === 0;
}

/** Kartu yang sedang ditampilkan, atau null jika sudah habis */
export function kartuSekarang(state: StateSesi): KartuDenganModul | null {
  return state.kartu[state.indeks] ?? null;
}

/** Kartu yang ditandai lupa di fase ini */
export function kartuLupa(state: StateSesi): KartuDenganModul[] {
  return state.kartu.filter((k) => state.hasil[k.id] === false);
}

/** Apakah sesi sudah selesai sepenuhnya (termasuk ulangan) */
export function sesiSelesai(state: StateSesi): boolean {
  return state.fase === 'selesai';
}

/** Apakah masih ada kartu yang perlu diulang */
export function masihAdaYangLupa(state: StateSesi): boolean {
  return kartuLupa(state).length > 0;
}

/**
 * Reducer sesi flashcard.
 *
 * Aturan penting:
 *   - BALIK hanya bekerja saat kartu belum terbuka
 *   - NILAI hanya bekerja saat kartu sudah terbuka
 *     (memaksa pengguna membaca jawaban dulu)
 *   - Putaran ulang hanya SATU kali
 */
export function reducerSesi(state: StateSesi, aksi: AksiSesi): StateSesi {
  switch (aksi.tipe) {
    case 'INIT': {
      // Inisialisasi deck — hanya sekali, saat state masih kosong
      if (state.kartu.length > 0) return state;
      return stateAwal(aksi.kartu);
    }

    case 'BALIK': {
      // Jangan balik kalau sedang animasi keluar
      if (state.keluar) return state;
      // Jangan balik dua kali
      if (state.terbuka) return state;
      return { ...state, terbuka: true };
    }

    case 'NILAI': {
      // Penilaian hanya setelah kartu dibalik
      if (!state.terbuka) return state;
      if (state.keluar) return state;

      return {
        ...state,
        hasil: { ...state.hasil, [aksi.kartuId]: aksi.ingat },
        keluar: true,
        arahKeluar: aksi.ingat ? 1 : -1,
      };
    }

    case 'KARTU_KELUAR_SELESAI': {
      if (!state.keluar) return state;

      const indeksBerikut = state.indeks + 1;
      const habis = indeksBerikut >= state.kartu.length;

      // Masih ada kartu di fase ini
      if (!habis) {
        return {
          ...state,
          indeks: indeksBerikut,
          terbuka: false,
          keluar: false,
        };
      }

      // Fase ini habis. Ada kartu lupa yang belum diulang?
      const adaYangLupa = Object.values(state.hasil).some((v) => v === false);
      const sudahPernahUlang = state.putaran >= 1;

      if (adaYangLupa && !sudahPernahUlang) {
        // Siapkan fase putaran ulang, tapi tunggu aksi MULAI_ULANGAN
        // agar pengguna sempat melihat layar transisi
        return { ...state, fase: 'putaran-ulang', keluar: false };
      }

      return { ...state, fase: 'selesai', keluar: false };
    }

    case 'MULAI_ULANGAN': {
      if (state.fase !== 'putaran-ulang') return state;

      const kartuUlang = kartuLupa(state);
      if (kartuUlang.length === 0) return { ...state, fase: 'selesai' };

      // Di putaran ulang, hasil lama tetap disimpan agar ringkasan
      // akhir mencerminkan seluruh sesi. Kartu yang lupa diulang.
      return {
        ...state,
        fase: 'kerjakan',
        kartu: kartuUlang,
        indeks: 0,
        terbuka: false,
        keluar: false,
        putaran: state.putaran + 1,
      };
    }

    case 'LEWATI_ULANGAN': {
      return { ...state, fase: 'selesai' };
    }

    default:
      return state;
  }
}

/* =========================================================
   Ringkasan sesi
   ========================================================= */

export interface RingkasanSesi {
  total: number;
  ingat: number;
  lupa: number;
  akurasi: number;
  /** Apakah semua kartu minimal sekali ditandai "Ingat" */
  semuaDikuasai: boolean;
}

/**
 * Hitung ringkasan dari hasil sesi.
 *
 * Catatan: `hasil` menyimpan nilai TERAKHIR tiap kartu. Kartu yang
 * lupa di putaran awal tapi ingat di putaran ulang dihitung "ingat".
 */
export function hitungRingkasan(hasil: Record<string, boolean>): RingkasanSesi {
  const nilai = Object.values(hasil);
  const total = nilai.length;
  const ingat = nilai.filter(Boolean).length;
  const lupa = total - ingat;

  return {
    total,
    ingat,
    lupa,
    akurasi: total > 0 ? Math.round((ingat / total) * 100) : 0,
    semuaDikuasai: total > 0 && lupa === 0,
  };
}
