/**
 * Nilai tetap yang dipakai lintas fitur.
 *
 * Nilai di sini HARUS sama dengan yang tertulis di:
 *   - docs/01-PRD.md §3
 *   - docs/02-KURIKULUM.md §4.3, §5.4
 * Jika salah satu berubah, ubah keduanya.
 */

/** Maksimal kartu per sesi flashcard (PRD §3 Tahap 2) */
export const MAKS_KARTU_PER_SESI = 20;

/** Jumlah soal per quiz (PRD §3 Tahap 3) */
export const JUMLAH_SOAL_QUIZ = 10;

/** Nilai minimum untuk lulus quiz (PRD §3 Tahap 3) */
export const AMBANG_LULUS_QUIZ = 70;

/** Persentase modul yang harus dibaca sebelum bisa ditandai selesai */
export const PERSEN_MINIMAL_BACA = 80;

/** Ambang akurasi topik untuk kategorisasi (02-KURIKULUM §5.4) */
export const AMBANG_TOPIK_LEMAH = 50;
export const AMBANG_TOPIK_CUKUP = 80;

/** Kunci localStorage — sertakan versi agar migrasi aman */
export const KUNCI_PROGRES = 'flashstruct:progres:v1';
export const KUNCI_TEMA = 'flashstruct:tema';

/** ID placeholder pada seed lama; bukan video pembelajaran yang sesuai judulnya. */
export const YOUTUBE_ID_VIDEO_CONTOH = 'dQw4w9WgXcQ';

/** Batas nilai streak agar tidak menampilkan angka aneh */
export const MAKS_STREAK = 999;

/** Label tampilan untuk tipe kartu (dipakai di analisis topik) */
export const LABEL_TIPE_KARTU: Record<string, string> = {
  ISTILAH: 'Istilah',
  SINTAKS: 'Sintaks',
  TRACING: 'Tracing',
  BANDING: 'Perbandingan',
  JEBAKAN: 'Jebakan',
  MEMORI: 'Memori',
  KAPAN: 'Kapan Dipakai',
};

/** Label tampilan untuk topik */
export const LABEL_TOPIK = {
  array: 'Array',
  struct: 'Struct',
  pointer: 'Pointer',
} as const satisfies Record<string, string>;
