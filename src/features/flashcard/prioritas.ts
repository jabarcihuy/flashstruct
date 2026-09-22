import type { KartuDenganModul } from '@/types/database';
import type { StatusKartu } from '@/features/progres/schema';
import { MAKS_KARTU_PER_SESI } from '@/lib/constants';
import { acak } from '@/lib/format';

/**
 * Algoritma pengurutan prioritas kartu.
 *
 * INI INTI METODE PEMBELAJARAN. Urutan yang benar membuat pengulangan
 * terarah: kartu yang sering lupa muncul lebih dulu, kartu yang sudah
 * dikuasai muncul belakangan.
 *
 * Urutan prioritas (docs/01-PRD.md §3 Tahap 2):
 *   1. Kartu dengan "Lupa" paling sering      (prioritas tertinggi)
 *   2. Kartu yang belum pernah dilihat
 *   3. Kartu dengan "Ingat" paling lama tidak dilihat
 *   4. Kartu yang sudah sering "Ingat"        (prioritas terendah)
 *
 * Algoritma ini SENGAJA sederhana, bukan SM-2 penuh seperti Anki.
 * Alasannya: pengguna harus bisa menjawab "kenapa kartu ini muncul
 * lagi?" — jawabannya karena dia sebelumnya menandainya lupa.
 */

/** Bobot prioritas — semakin tinggi, semakin awal muncul */
const PRIORITAS = {
  SERING_LUPA: 400,
  BELUM_PERNAH: 300,
  LAMA_TIDAK_DILIHAT: 200,
  SUDAH_DIKUASAI: 100,
} as const;

/**
 * Hitung skor prioritas satu kartu.
 *
 * Skor lebih tinggi = muncul lebih awal.
 */
export function hitungPrioritas(status: StatusKartu | undefined, sekarang = Date.now()): number {
  // Belum pernah dilihat — prioritas tinggi
  if (!status || status.terakhirDilihat === 0) {
    return PRIORITAS.BELUM_PERNAH;
  }

  // Pernah ditandai lupa — prioritas tertinggi
  if (status.jumlahLupa > 0) {
    // Semakin sering lupa, semakin tinggi.
    // Dikali 10 agar selisih antar kartu terlihat jelas,
    // tapi tidak pernah melebihi kategori di atasnya.
    return PRIORITAS.SERING_LUPA + Math.min(status.jumlahLupa * 10, 99);
  }

  // Sudah pernah ingat tanpa lupa
  const hariSejakDilihat = (sekarang - status.terakhirDilihat) / (24 * 60 * 60 * 1000);

  if (hariSejakDilihat >= 1) {
    // Semakin lama tidak dilihat, semakin tinggi prioritasnya.
    // Dibatasi 99 agar tidak melampaui kategori "sering lupa".
    return PRIORITAS.LAMA_TIDAK_DILIHAT + Math.min(Math.floor(hariSejakDilihat), 99);
  }

  // Baru saja diingat — prioritas terendah
  return PRIORITAS.SUDAH_DIKUASAI;
}

/**
 * Susun deck untuk satu sesi.
 *
 * Langkah:
 *   1. Hitung prioritas setiap kartu
 *   2. Urutkan dari prioritas tertinggi
 *   3. Untuk skor yang sama, acak agar tidak selalu urutan sama
 *   4. Ambil maksimal MAKS_KARTU_PER_SESI kartu
 */
export function susunDeck(
  kartu: KartuDenganModul[],
  statusKartu: Record<string, StatusKartu>,
  sekarang = Date.now(),
): KartuDenganModul[] {
  const denganSkor = kartu.map((k) => ({
    kartu: k,
    skor: hitungPrioritas(statusKartu[k.id], sekarang),
  }));

  // Acak dulu, lalu urutkan stabil berdasarkan skor.
  // Cara ini membuat kartu dengan skor sama tetap acak,
  // tapi kartu berskor tinggi selalu di depan.
  const diacak = acak(denganSkor);

  diacak.sort((a, b) => b.skor - a.skor);

  return diacak.slice(0, MAKS_KARTU_PER_SESI).map((x) => x.kartu);
}

/**
 * Ringkas alasan sebuah kartu muncul di sesi — untuk ditampilkan ke
 * pengguna agar algoritmanya tidak terasa seperti keacakan.
 */
export function alasanPrioritas(status: StatusKartu | undefined, sekarang = Date.now()): string {
  if (!status || status.terakhirDilihat === 0) {
    return 'Belum pernah kamu lihat';
  }

  if (status.jumlahLupa > 0) {
    return `Pernah kamu tandai lupa ${status.jumlahLupa}x`;
  }

  const hari = Math.floor((sekarang - status.terakhirDilihat) / (24 * 60 * 60 * 1000));
  if (hari >= 1) {
    return `Terakhir dilihat ${hari} hari lalu`;
  }

  return 'Sudah kamu kuasai';
}

/** Info ringkas tentang komposisi deck — untuk ditampilkan sebelum sesi */
export interface KomposisiDeck {
  total: number;
  belumPernah: number;
  seringLupa: number;
  perluDiulang: number;
  sudahDikuasai: number;
}

export function hitungKomposisi(
  kartu: KartuDenganModul[],
  statusKartu: Record<string, StatusKartu>,
  sekarang = Date.now(),
): KomposisiDeck {
  let belumPernah = 0;
  let seringLupa = 0;
  let perluDiulang = 0;
  let sudahDikuasai = 0;

  for (const k of kartu) {
    const s = statusKartu[k.id];

    if (!s || s.terakhirDilihat === 0) {
      belumPernah += 1;
    } else if (s.jumlahLupa > 0) {
      seringLupa += 1;
    } else {
      const hari = (sekarang - s.terakhirDilihat) / (24 * 60 * 60 * 1000);
      if (hari >= 1) perluDiulang += 1;
      else sudahDikuasai += 1;
    }
  }

  return { total: kartu.length, belumPernah, seringLupa, perluDiulang, sudahDikuasai };
}
