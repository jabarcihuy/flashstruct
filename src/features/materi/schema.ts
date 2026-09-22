import { z } from 'zod';

/**
 * Skema validasi untuk data dari Supabase.
 *
 * Mengapa perlu: database bisa berubah (konten diedit manual lewat
 * SQL Editor). Tanpa validasi, satu kesalahan ketik di database bisa
 * membuat aplikasi crash dengan error yang sulit dilacak.
 *
 * Dengan Zod, kegagalan terdeteksi di batas sistem dan pesannya jelas.
 */

/* =========================================================
   Enum
   ========================================================= */

export const TopikModulSchema = z.enum(['array', 'struct', 'pointer']);

export const TipeKartuSchema = z.enum([
  'ISTILAH',
  'SINTAKS',
  'TRACING',
  'BANDING',
  'JEBAKAN',
  'MEMORI',
  'KAPAN',
]);

export const TipeSoalSchema = z.enum(['PG', 'TRACE', 'ANALISIS']);

export const BahasaKodeSchema = z.enum(['cpp', 'python']);

/* =========================================================
   Baris tabel
   ========================================================= */

export const ModulSchema = z.object({
  id: z.uuid(),
  slug: z.string().min(1),
  judul: z.string().min(1),
  topik: TopikModulSchema,
  deskripsi: z.string(),
  estimasi_menit: z.number().int().positive(),
  urutan: z.number().int(),
});

export const BagianModulSchema = z.object({
  id: z.uuid(),
  modul_id: z.uuid(),
  slug: z.string().min(1),
  judul: z.string().min(1),
  konten_md: z.string(),
  urutan: z.number().int(),
});

export const VideoSchema = z.object({
  id: z.uuid(),
  modul_id: z.uuid(),
  youtube_id: z.string().length(11),
  judul: z.string().min(1),
  deskripsi: z.string().nullable(),
  durasi_detik: z.number().int().positive().nullable(),
  urutan: z.number().int(),
});

export const FlashcardSchema = z.object({
  id: z.uuid(),
  modul_id: z.uuid(),
  depan: z.string().min(1),
  belakang: z.string().min(1),
  card_type: TipeKartuSchema,
  kode: z.string().nullable(),
  bahasa_kode: BahasaKodeSchema.nullable(),
  urutan: z.number().int(),
});

export const SoalSchema = z.object({
  id: z.uuid(),
  modul_id: z.uuid(),
  pertanyaan: z.string().min(1),
  kode: z.string().nullable(),
  bahasa_kode: BahasaKodeSchema.nullable(),
  tipe: TipeSoalSchema,
  card_type: TipeKartuSchema,
  penjelasan: z.string().min(1),
  urutan: z.number().int(),
});

export const OpsiSoalSchema = z.object({
  id: z.uuid(),
  soal_id: z.uuid(),
  label: z.string(),
  teks: z.string(),
  benar: z.boolean(),
  urutan: z.number().int(),
});

/* =========================================================
   Hasil query dengan relasi
   ========================================================= */

export const ModulRingkasSchema = ModulSchema.extend({
  bagian_modul: z.array(z.object({ id: z.uuid() })).nullable(),
  flashcard: z.array(z.object({ id: z.uuid() })).nullable(),
  soal: z.array(z.object({ id: z.uuid() })).nullable(),
});

export const ModulLengkapSchema = ModulSchema.extend({
  bagian_modul: z.array(BagianModulSchema).nullable(),
  video: z.array(VideoSchema).nullable(),
});

export const KartuDenganModulSchema = FlashcardSchema.extend({
  modul: z.object({
    slug: z.string(),
    judul: z.string(),
    topik: TopikModulSchema,
  }),
});

export const SoalDenganOpsiSchema = SoalSchema.extend({
  modul: z.object({ slug: z.string() }),
  opsi_soal: z.array(OpsiSoalSchema).nullable(),
});

export const VideoDenganModulSchema = VideoSchema.extend({
  modul: z.object({
    slug: z.string(),
    judul: z.string(),
    topik: TopikModulSchema,
    urutan: z.number().int(),
  }),
});

/* =========================================================
   Helper validasi
   ========================================================= */

/**
 * Validasi data dengan pesan error yang berguna.
 *
 * Zod melempar error yang panjang dan sulit dibaca. Helper ini
 * mempersingkatnya agar bisa ditampilkan atau dilog dengan jelas.
 */
export function validasi<T>(schema: z.ZodType<T>, data: unknown, konteks: string): T {
  const hasil = schema.safeParse(data);

  if (!hasil.success) {
    const masalah = hasil.error.issues
      .slice(0, 3)
      .map((i) => `${i.path.join('.') || '(root)'}: ${i.message}`)
      .join('; ');

    throw new Error(`Data tidak valid dari ${konteks} — ${masalah}`);
  }

  return hasil.data;
}

/** Validasi array dengan pesan error yang berguna */
export function validasiArray<T>(schema: z.ZodType<T>, data: unknown, konteks: string): T[] {
  return validasi(z.array(schema), data, konteks);
}
