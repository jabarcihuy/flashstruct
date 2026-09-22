import type { ProgresModul } from './schema';

/**
 * Aturan penguncian tiga tahap.
 *
 * INI LOGIKA INTI PRODUK. Diimplementasikan di satu tempat agar tidak
 * ada perbedaan perilaku antar halaman.
 *
 * Aturan:
 *   Tahap 1 (Pahami)   : selalu tersedia
 *   Tahap 2 (Hafalkan) : tersedia jika tahap 1 selesai
 *   Tahap 3 (Buktikan) : tersedia jika tahap 2 selesai
 *
 * Rincian: docs/01-PRD.md §3, docs/04-ARSITEKTUR-TEKNIS.md §3.5
 */

export type StatusTahap = 'terkunci' | 'tersedia' | 'selesai';

export type NomorTahap = 1 | 2 | 3;

/** Label tampilan tiap tahap */
export const LABEL_TAHAP: Record<NomorTahap, string> = {
  1: 'Pahami',
  2: 'Hafalkan',
  3: 'Buktikan',
};

/**
 * Tentukan status sebuah tahap untuk satu modul.
 *
 * @param progres Progres modul, atau undefined jika belum dimulai
 * @param tahap   Nomor tahap (1, 2, atau 3)
 */
export function statusTahap(progres: ProgresModul | undefined, tahap: NomorTahap): StatusTahap {
  // Modul yang belum dimulai: hanya tahap 1 yang tersedia
  if (!progres) {
    return tahap === 1 ? 'tersedia' : 'terkunci';
  }

  const sudahSelesai = [progres.tahap1Selesai, progres.tahap2Selesai, progres.tahap3Selesai];

  // Tahap yang sudah selesai berstatus 'selesai', bukan 'tersedia'
  if (sudahSelesai[tahap - 1]) return 'selesai';

  // Tahap n tersedia jika tahap n-1 sudah selesai
  const prasyaratTerpenuhi = tahap === 1 || sudahSelesai[tahap - 2];

  return prasyaratTerpenuhi ? 'tersedia' : 'terkunci';
}

/**
 * Status ketiga tahap sekaligus — untuk indikator di kartu modul.
 */
export function statusSemuaTahap(
  progres: ProgresModul | undefined,
): [StatusTahap, StatusTahap, StatusTahap] {
  return [statusTahap(progres, 1), statusTahap(progres, 2), statusTahap(progres, 3)];
}

/**
 * Alasan mengapa sebuah tahap terkunci.
 *
 * Harus menjelaskan ALASAN, bukan sekadar "terkunci". Pengguna perlu
 * tahu apa yang harus dilakukan untuk membukanya.
 */
export function alasanTerkunci(tahap: 2 | 3): string {
  if (tahap === 2) {
    return 'Selesaikan modul ini dulu sebelum mulai menghafal.';
  }
  return 'Selesaikan semua kartu dulu sebelum mengerjakan quiz.';
}

/**
 * Tentukan tahap mana yang sebaiknya dikerjakan berikutnya.
 *
 * Dipakai Dashboard untuk merekomendasikan langkah berikutnya.
 * Mengembalikan null jika semua tahap sudah selesai.
 */
export function tahapBerikutnya(progres: ProgresModul | undefined): NomorTahap | null {
  for (const tahap of [1, 2, 3] as const) {
    if (statusTahap(progres, tahap) === 'tersedia') return tahap;
  }
  return null;
}

/**
 * Cek apakah modul sudah tuntas (ketiga tahap selesai).
 *
 * Dipakai untuk statistik "modul selesai" di Dashboard.
 * Menghitung hanya dari tahap 3 akan memberi gambaran yang terlalu
 * optimistis, jadi ketiganya harus diperiksa.
 */
export function modulTuntas(progres: ProgresModul | undefined): boolean {
  if (!progres) return false;
  return progres.tahap1Selesai && progres.tahap2Selesai && progres.tahap3Selesai;
}

/**
 * Hitung persentase progres modul (0-100).
 *
 * Setiap tahap berbobot sama (33,3%). Dipakai untuk bar progres
 * di kartu modul.
 */
export function persenProgresModul(progres: ProgresModul | undefined): number {
  if (!progres) return 0;

  const selesai = [progres.tahap1Selesai, progres.tahap2Selesai, progres.tahap3Selesai].filter(
    Boolean,
  ).length;

  return Math.round((selesai / 3) * 100);
}

/**
 * Tentukan langkah berikutnya beserta alasannya.
 *
 * Dipakai untuk kartu rekomendasi di Dashboard. Mengembalikan
 * aksi yang konkret, bukan sekadar "lanjutkan".
 */
export interface Rekomendasi {
  tahap: NomorTahap;
  aksi: string;
  ctaLabel: string;
  alasan: string;
}

export function rekomendasiModul(
  progres: ProgresModul | undefined,
  info: { judul: string; estimasiMenit: number; jumlahKartu: number },
): Rekomendasi | null {
  const tahap = tahapBerikutnya(progres);
  if (tahap === null) return null;

  if (tahap === 1) {
    return {
      tahap: 1,
      aksi: 'Baca Modul',
      ctaLabel: 'Baca Modul',
      alasan: `Belum kamu mulai. Baca modulnya dulu, sekitar ${info.estimasiMenit} menit.`,
    };
  }

  if (tahap === 2) {
    return {
      tahap: 2,
      aksi: 'Flashcard',
      ctaLabel: 'Mulai Flashcard',
      alasan: `Kamu sudah membaca modulnya. Sekarang hafalkan konsepnya dengan ${info.jumlahKartu} kartu.`,
    };
  }

  return {
    tahap: 3,
    aksi: 'Quiz',
    ctaLabel: 'Mulai Quiz',
    alasan: 'Semua kartu sudah kamu kuasai. Buktikan dengan 10 soal.',
  };
}
