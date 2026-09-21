import { z } from 'zod';

/**
 * Skema progres pengguna.
 *
 * Semua progres disimpan di localStorage. Skema ini memvalidasi data
 * saat DIBACA, karena localStorage bisa:
 *   - rusak (data terpotong)
 *   - diubah manual lewat DevTools
 *   - berasal dari versi aplikasi yang lebih lama
 *
 * Tanpa validasi, satu data rusak bisa membuat aplikasi crash dengan
 * error yang sulit dilacak.
 *
 * Rincian: docs/04-ARSITEKTUR-TEKNIS.md §3.6
 */

/* =========================================================
   Versi skema
   Kalau bentuk data berubah, naikkan angka ini. Data lama akan
   diabaikan dengan aman, bukan menyebabkan crash.
   ========================================================= */

export const VERSI_PROGRES = 1;

/* =========================================================
   Status kartu
   ========================================================= */

export const StatusKartuSchema = z.object({
  kartuId: z.string().min(1),
  /** Berapa kali ditandai "Ingat" */
  jumlahIngat: z.number().int().min(0),
  /** Berapa kali ditandai "Lupa" */
  jumlahLupa: z.number().int().min(0),
  /** Epoch ms terakhir dilihat */
  terakhirDilihat: z.number().int().min(0),
});

export type StatusKartu = z.infer<typeof StatusKartuSchema>;

/* =========================================================
   Hasil quiz
   ========================================================= */

export const HasilQuizSchema = z.object({
  /** Epoch ms kapan quiz dikerjakan */
  waktu: z.number().int().min(0),
  /** Nilai 0-100 */
  skor: z.number().int().min(0).max(100),
  jumlahBenar: z.number().int().min(0),
  jumlahSoal: z.number().int().min(1),
});

export type HasilQuiz = z.infer<typeof HasilQuizSchema>;

/* =========================================================
   Progres per modul
   ========================================================= */

export const ProgresModulSchema = z.object({
  modulId: z.string().min(1),
  tahap1Selesai: z.boolean(),
  tahap2Selesai: z.boolean(),
  tahap3Selesai: z.boolean(),
  /** Slug bagian yang sudah dibaca (untuk syarat 80%) */
  bagianDibaca: z.array(z.string()),
  /** Status tiap kartu, dikunci oleh kartuId */
  kartu: z.record(z.string(), StatusKartuSchema),
  /** Riwayat quiz, terbaru di akhir */
  riwayatQuiz: z.array(HasilQuizSchema),
});

export type ProgresModul = z.infer<typeof ProgresModulSchema>;

/* =========================================================
   Progres global
   ========================================================= */

export const ProgresGlobalSchema = z.object({
  versi: z.literal(VERSI_PROGRES),
  /** Progres tiap modul, dikunci oleh modulId */
  modul: z.record(z.string(), ProgresModulSchema),
  /** Tanggal aktivitas (format YYYY-MM-DD) untuk perhitungan streak */
  hariAktif: z.array(z.string()),
  /** Epoch ms terakhir diperbarui */
  terakhirDiperbarui: z.number().int().min(0),
});

export type ProgresGlobal = z.infer<typeof ProgresGlobalSchema>;

/* =========================================================
   Nilai awal
   ========================================================= */

/** Progres kosong untuk pengguna baru */
export function progresKosong(): ProgresGlobal {
  return {
    versi: VERSI_PROGRES,
    modul: {},
    hariAktif: [],
    terakhirDiperbarui: Date.now(),
  };
}

/** Progres kosong untuk satu modul */
export function progresModulKosong(modulId: string): ProgresModul {
  return {
    modulId,
    tahap1Selesai: false,
    tahap2Selesai: false,
    tahap3Selesai: false,
    bagianDibaca: [],
    kartu: {},
    riwayatQuiz: [],
  };
}

/* =========================================================
   Skema ekspor/impor
   ========================================================= */

/**
 * Berkas ekspor punya pembungkus agar bisa dibedakan dari berkas lain.
 * Versi aplikasi dicatat untuk diagnosis.
 */
export const BerkasEksporSchema = z.object({
  jenis: z.literal('flashstruct-progres'),
  versi: z.number().int().positive(),
  dieksporPada: z.number().int().min(0),
  data: ProgresGlobalSchema,
});

export type BerkasEkspor = z.infer<typeof BerkasEksporSchema>;
