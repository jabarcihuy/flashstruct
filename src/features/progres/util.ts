import type { ProgresGlobal, ProgresModul } from './schema';
import { modulTuntas } from './aturan';
import { kunciTanggal } from '@/lib/format';

/**
 * Utilitas progres: streak, statistik, dan perhitungan turunan.
 */

/** Batas jumlah hari aktif yang disimpan */
export const MAKS_HARI_AKTIF = 400;

/** Batas nilai streak agar tidak menampilkan angka aneh */
export const MAKS_STREAK = 999;

// kunciTanggal diambil dari lib/format.ts agar tidak ada duplikasi.
// Di-ekspor ulang supaya pemanggil tidak perlu tahu asalnya.
export { kunciTanggal };

/** Tambah n hari ke kunci tanggal */
function geserTanggal(kunci: string, deltaHari: number): string {
  const [tahun, bulan, hari] = kunci.split('-').map(Number);
  const d = new Date(tahun!, bulan! - 1, hari!);
  d.setDate(d.getDate() + deltaHari);
  return kunciTanggal(d.getTime());
}

/**
 * Hitung streak: berapa hari berturut-turut pengguna aktif.
 *
 * Dihitung mundur dari hari ini. Jika hari ini belum ada aktivitas,
 * hitungan dimulai dari kemarin — supaya streak tidak "putus" hanya
 * karena pengguna belum membuka aplikasi hari ini.
 *
 * Catatan: bergantung pada jam perangkat. Pengguna yang mengubah jam
 * bisa merusaknya. Ini dapat diterima — streak hanya motivasi, bukan
 * fitur keamanan (docs/06-SPESIFIKASI-HALAMAN.md §3.4).
 */
export function hitungStreak(hariAktif: string[], sekarang = Date.now()): number {
  if (hariAktif.length === 0) return 0;

  const himpunan = new Set(hariAktif);
  const hariIni = kunciTanggal(sekarang);

  // Mulai dari hari ini, atau kemarin jika hari ini belum aktif
  let kursor = himpunan.has(hariIni) ? hariIni : geserTanggal(hariIni, -1);

  if (!himpunan.has(kursor)) return 0;

  let streak = 0;
  while (himpunan.has(kursor) && streak < MAKS_STREAK) {
    streak += 1;
    kursor = geserTanggal(kursor, -1);
  }

  return streak;
}

/* =========================================================
   Statistik
   ========================================================= */

export interface StatistikProgres {
  modulSelesai: number;
  kartuDikuasai: number;
  akurasiQuiz: number;
  streak: number;
}

/**
 * Hitung kartu yang "dikuasai".
 *
 * Definisi: pernah ditandai "Ingat" DAN tidak pernah "Lupa".
 * Kartu yang masih sering lupa tidak dihitung walaupun pernah ingat.
 * Rincian: docs/06-SPESIFIKASI-HALAMAN.md §3.4
 */
export function hitungKartuDikuasai(progres: ProgresGlobal): number {
  let jumlah = 0;

  for (const modul of Object.values(progres.modul)) {
    for (const kartu of Object.values(modul.kartu)) {
      if (kartu.jumlahIngat > 0 && kartu.jumlahLupa === 0) {
        jumlah += 1;
      }
    }
  }

  return jumlah;
}

/**
 * Hitung akurasi quiz rata-rata.
 *
 * Rata-rata dari akurasi tiap percobaan, bukan rata-rata nilai akhir.
 * Dibatasi maksimal 20 percobaan terakhir agar data lama tidak
 * mendominasi.
 */
export function hitungAkurasiQuiz(progres: ProgresGlobal): number {
  const semuaSkor: number[] = [];

  for (const modul of Object.values(progres.modul)) {
    for (const quiz of modul.riwayatQuiz) {
      semuaSkor.push(quiz.skor);
    }
  }

  if (semuaSkor.length === 0) return 0;

  const terakhir = semuaSkor.slice(-20);
  const total = terakhir.reduce((a, b) => a + b, 0);

  return Math.round(total / terakhir.length);
}

/** Hitung berapa modul yang sudah tuntas (ketiga tahap selesai) */
export function hitungModulSelesai(progres: ProgresGlobal): number {
  return Object.values(progres.modul).filter((m) => modulTuntas(m)).length;
}

/** Hitung semua statistik sekaligus untuk Dashboard */
export function hitungStatistik(progres: ProgresGlobal, sekarang = Date.now()): StatistikProgres {
  return {
    modulSelesai: hitungModulSelesai(progres),
    kartuDikuasai: hitungKartuDikuasai(progres),
    akurasiQuiz: hitungAkurasiQuiz(progres),
    streak: hitungStreak(progres.hariAktif, sekarang),
  };
}

/* =========================================================
   Statistik per modul
   ========================================================= */

export interface StatistikModul {
  kartuDikuasai: number;
  kartuTotal: number;
  akurasiQuiz: number;
  jumlahPercobaan: number;
}

/** Statistik untuk satu modul */
export function hitungStatistikModul(modul: ProgresModul | undefined): StatistikModul {
  if (!modul) {
    return { kartuDikuasai: 0, kartuTotal: 0, akurasiQuiz: 0, jumlahPercobaan: 0 };
  }

  const semuaKartu = Object.values(modul.kartu);
  const dikuasai = semuaKartu.filter((k) => k.jumlahIngat > 0 && k.jumlahLupa === 0).length;

  const skor = modul.riwayatQuiz.map((q) => q.skor);
  const akurasi = skor.length > 0 ? Math.round(skor.reduce((a, b) => a + b, 0) / skor.length) : 0;

  return {
    kartuDikuasai: dikuasai,
    kartuTotal: semuaKartu.length,
    akurasiQuiz: akurasi,
    jumlahPercobaan: skor.length,
  };
}

/**
 * Cari modul dengan akurasi quiz terendah.
 *
 * Dipakai Dashboard untuk menyarankan "ulangi quiz terlemah".
 * Hanya mempertimbangkan modul yang sudah pernah dikerjakan quiz-nya.
 */
export function modulTerlemah(
  progres: ProgresGlobal,
  infoModul: Map<string, { slug: string; judul: string }>,
): { slug: string; judul: string; akurasi: number } | null {
  let terlemah: { slug: string; judul: string; akurasi: number } | null = null;

  for (const [modulId, modul] of Object.entries(progres.modul)) {
    if (modul.riwayatQuiz.length === 0) continue;

    const info = infoModul.get(modulId);
    if (!info) continue;

    const skor = modul.riwayatQuiz.map((q) => q.skor);
    const akurasi = Math.round(skor.reduce((a, b) => a + b, 0) / skor.length);

    if (!terlemah || akurasi < terlemah.akurasi) {
      terlemah = { slug: info.slug, judul: info.judul, akurasi };
    }
  }

  return terlemah;
}
