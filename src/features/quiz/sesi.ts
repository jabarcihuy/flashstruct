import type { OpsiSoal, SoalDenganOpsi, TipeKartu } from '@/types/database';
import { JUMLAH_SOAL_QUIZ } from '@/lib/constants';
import { acak, urutkan } from '@/lib/format';

/**
 * State machine sesi quiz.
 *
 * Dipisah dari komponen agar transisi state terlihat di satu tempat
 * dan bisa diuji tanpa merender apa pun.
 *
 * Alur:
 *   kerjakan -> (umpan balik) -> kerjakan -> ... -> selesai
 *
 * Rincian: docs/04-ARSITEKTUR-TEKNIS.md §3.4
 */

export type FaseQuiz = 'kerjakan' | 'selesai';

export interface StateQuiz {
  fase: FaseQuiz;
  /** Soal yang dikerjakan di sesi ini */
  soal: SoalDenganOpsi[];
  /** Indeks soal saat ini */
  indeks: number;
  /** Jawaban yang dipilih: soalId -> label opsi ('A'..'D') */
  jawaban: Record<string, string>;
  /** Apakah soal saat ini sudah dijawab (umpan balik ditampilkan) */
  sudahDijawab: boolean;
}

export type AksiQuiz =
  | { tipe: 'INIT'; soal: SoalDenganOpsi[] }
  | { tipe: 'JAWAB'; soalId: string; label: string }
  | { tipe: 'LANJUT' };

/** Buat state awal */
export function stateAwal(soal: SoalDenganOpsi[] = []): StateQuiz {
  return {
    fase: 'kerjakan',
    soal,
    indeks: 0,
    jawaban: {},
    sudahDijawab: false,
  };
}

/** Soal yang sedang ditampilkan */
export function soalSekarang(state: StateQuiz): SoalDenganOpsi | null {
  return state.soal[state.indeks] ?? null;
}

/** Apakah ini soal terakhir */
export function soalTerakhir(state: StateQuiz): boolean {
  return state.indeks >= state.soal.length - 1;
}

/**
 * Reducer sesi quiz.
 *
 * Aturan penting:
 *   - JAWAB hanya bekerja sekali per soal (tidak bisa ganti jawaban)
 *   - LANJUT hanya bekerja setelah soal dijawab
 *   - Setelah soal terakhir, fase menjadi 'selesai'
 */
export function reducerQuiz(state: StateQuiz, aksi: AksiQuiz): StateQuiz {
  switch (aksi.tipe) {
    case 'INIT': {
      if (state.soal.length > 0) return state;
      return stateAwal(aksi.soal);
    }

    case 'JAWAB': {
      // Tidak bisa menjawab kalau sudah dijawab
      if (state.sudahDijawab) return state;
      // Pastikan yang dijawab adalah soal yang sedang tampil
      const sekarang = soalSekarang(state);
      if (!sekarang || sekarang.id !== aksi.soalId) return state;

      return {
        ...state,
        jawaban: { ...state.jawaban, [aksi.soalId]: aksi.label },
        sudahDijawab: true,
      };
    }

    case 'LANJUT': {
      if (!state.sudahDijawab) return state;

      const berikutnya = state.indeks + 1;

      if (berikutnya >= state.soal.length) {
        return { ...state, fase: 'selesai' };
      }

      return {
        ...state,
        indeks: berikutnya,
        sudahDijawab: false,
      };
    }

    default:
      return state;
  }
}

/* =========================================================
   Penyusunan soal
   ========================================================= */

/**
 * Pilih soal untuk satu sesi.
 *
 * Langkah:
 *   1. Acak urutan soal
 *   2. Ambil maksimal JUMLAH_SOAL_QUIZ soal
 *   3. Acak urutan opsi di setiap soal (agar tidak selalu A-B-C-D)
 *
 * Mengapa opsi diacak: kalau jawaban selalu di posisi yang sama,
 * mahasiswa bisa menebak tanpa memahami.
 */
export function susunSoal(bankSoal: SoalDenganOpsi[]): SoalDenganOpsi[] {
  const terpilih = acak(bankSoal).slice(0, JUMLAH_SOAL_QUIZ);

  return terpilih.map((s) => ({
    ...s,
    opsi_soal: acak(urutkan(s.opsi_soal)),
  }));
}

/* =========================================================
   Penilaian
   ========================================================= */

/** Ambil opsi yang benar dari sebuah soal */
export function opsiBenar(soal: SoalDenganOpsi): OpsiSoal | undefined {
  return soal.opsi_soal?.find((o) => o.benar);
}

/** Cek apakah jawaban pengguna benar */
export function jawabanBenar(soal: SoalDenganOpsi, labelDipilih: string | undefined): boolean {
  if (!labelDipilih) return false;
  const benar = opsiBenar(soal);
  return benar?.label === labelDipilih;
}

export interface HasilSesiQuiz {
  skor: number;
  jumlahBenar: number;
  jumlahSoal: number;
  lulus: boolean;
}

/**
 * Hitung hasil akhir sesi.
 *
 * Tahap 3 dianggap SELESAI apapun nilainya — memaksa nilai tinggi akan
 * membuat pengguna terjebak mengulang tanpa akhir. Ambang lulus hanya
 * dipakai untuk memberi saran.
 */
export function hitungHasil(state: StateQuiz): HasilSesiQuiz {
  let jumlahBenar = 0;

  for (const s of state.soal) {
    if (jawabanBenar(s, state.jawaban[s.id])) jumlahBenar += 1;
  }

  const jumlahSoal = state.soal.length;
  const skor = jumlahSoal > 0 ? Math.round((jumlahBenar / jumlahSoal) * 100) : 0;

  return {
    skor,
    jumlahBenar,
    jumlahSoal,
    lulus: skor >= 70,
  };
}

/* =========================================================
   Analisis per topik
   ========================================================= */

export type KategoriTopik = 'lemah' | 'cukup' | 'kuat';

export interface AkurasiTopik {
  cardType: TipeKartu;
  benar: number;
  total: number;
  persen: number;
  kategori: KategoriTopik;
}

/**
 * Hitung akurasi per tipe kartu (topik).
 *
 * Dipakai untuk memberi tahu pengguna BAGIAN MANA yang masih lemah,
 * bukan sekadar "nilaimu 60". Ini yang membuat quiz berguna sebagai
 * alat belajar, bukan hanya penilaian.
 *
 * Diurutkan dari TERLEMAH — yang perlu ditindaklanjuti muncul dulu.
 */
export function hitungAkurasiTopik(state: StateQuiz): AkurasiTopik[] {
  const perTopik = new Map<TipeKartu, { benar: number; total: number }>();

  for (const s of state.soal) {
    const stat = perTopik.get(s.card_type) ?? { benar: 0, total: 0 };
    stat.total += 1;

    if (jawabanBenar(s, state.jawaban[s.id])) {
      stat.benar += 1;
    }

    perTopik.set(s.card_type, stat);
  }

  const hasil: AkurasiTopik[] = [];

  for (const [cardType, stat] of perTopik) {
    const persen = stat.total > 0 ? Math.round((stat.benar / stat.total) * 100) : 0;

    hasil.push({
      cardType,
      benar: stat.benar,
      total: stat.total,
      persen,
      kategori: persen < 50 ? 'lemah' : persen < 80 ? 'cukup' : 'kuat',
    });
  }

  // Terlemah di atas — yang perlu ditindaklanjuti lebih dulu
  return hasil.sort((a, b) => a.persen - b.persen);
}

/** Topik paling lemah, atau null jika semua kuat */
export function topikTerlemah(akurasi: AkurasiTopik[]): AkurasiTopik | null {
  const lemah = akurasi.filter((a) => a.kategori === 'lemah');
  return lemah[0] ?? null;
}
