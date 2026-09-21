/**
 * Tipe database FlashStruct.
 *
 * Struktur ini sudah diverifikasi cocok dengan skema nyata di Supabase
 * (6 tabel, 4 enum). Tipe ditulis manual, bukan hasil generate, agar
 * bisa dibaca dan disesuaikan.
 *
 * Sumber kebenaran skema: supabase/migrations/001_initial_schema.sql
 */

/* =========================================================
   Enum
   ========================================================= */

export type TopikModul = 'array' | 'struct' | 'pointer';

export type TipeKartu =
  | 'ISTILAH'
  | 'SINTAKS'
  | 'TRACING'
  | 'BANDING'
  | 'JEBAKAN'
  | 'MEMORI'
  | 'KAPAN';

export type TipeSoal = 'PG' | 'TRACE' | 'ANALISIS';

export type BahasaKode = 'cpp' | 'python';

/* =========================================================
   Baris tabel (bentuk dasar)
   ========================================================= */

export interface Modul {
  id: string;
  slug: string;
  judul: string;
  topik: TopikModul;
  deskripsi: string;
  estimasi_menit: number;
  urutan: number;
  dibuat_pada: string;
  diperbarui_pada: string;
}

export interface BagianModul {
  id: string;
  modul_id: string;
  slug: string;
  judul: string;
  konten_md: string;
  urutan: number;
}

export interface Video {
  id: string;
  modul_id: string;
  youtube_id: string;
  judul: string;
  deskripsi: string | null;
  durasi_detik: number | null;
  urutan: number;
}

export interface Flashcard {
  id: string;
  modul_id: string;
  depan: string;
  belakang: string;
  card_type: TipeKartu;
  kode: string | null;
  bahasa_kode: BahasaKode | null;
  urutan: number;
}

export interface Soal {
  id: string;
  modul_id: string;
  pertanyaan: string;
  kode: string | null;
  bahasa_kode: BahasaKode | null;
  tipe: TipeSoal;
  card_type: TipeKartu;
  penjelasan: string;
  urutan: number;
}

export interface OpsiSoal {
  id: string;
  soal_id: string;
  label: string;
  teks: string;
  benar: boolean;
  urutan: number;
}

/* =========================================================
   Hasil query dengan relasi (embedding Supabase)
   ========================================================= */

/** Untuk halaman daftar materi — hanya butuh jumlah anak */
export interface ModulRingkas {
  id: string;
  slug: string;
  judul: string;
  topik: TopikModul;
  deskripsi: string;
  estimasi_menit: number;
  urutan: number;
  bagian_modul: { id: string }[] | null;
  flashcard: { id: string }[] | null;
  soal: { id: string }[] | null;
}

/** Untuk halaman baca modul */
export interface ModulLengkap {
  id: string;
  slug: string;
  judul: string;
  topik: TopikModul;
  deskripsi: string;
  estimasi_menit: number;
  urutan: number;
  bagian_modul: BagianModul[] | null;
  video: Video[] | null;
}

/** Untuk sesi flashcard */
export interface KartuDenganModul extends Flashcard {
  modul: { slug: string; judul: string; topik: TopikModul };
}

/** Untuk sesi quiz */
export interface SoalDenganOpsi extends Soal {
  modul: { slug: string };
  opsi_soal: OpsiSoal[] | null;
}

/** Untuk halaman video */
export interface VideoDenganModul extends Video {
  modul: {
    slug: string;
    judul: string;
    topik: TopikModul;
    urutan: number;
  };
}

/* =========================================================
   Tipe Supabase client
   ========================================================= */

/**
 * Definisi skema untuk Supabase client.
 *
 * Bentuknya mengikuti `Database` generic dari supabase-js agar
 * query mendapat type-safety. Ditulis manual karena kita tidak
 * memakai CLI codegen (tidak memakai Docker).
 */
export interface Database {
  public: {
    Tables: {
      modul: {
        Row: Modul;
        Insert: Omit<Modul, 'id' | 'dibuat_pada' | 'diperbarui_pada'> &
          Partial<Pick<Modul, 'id' | 'dibuat_pada' | 'diperbarui_pada'>>;
        Update: Partial<Modul>;
      };
      bagian_modul: {
        Row: BagianModul;
        Insert: Omit<BagianModul, 'id'> & Partial<Pick<BagianModul, 'id'>>;
        Update: Partial<BagianModul>;
      };
      video: {
        Row: Video;
        Insert: Omit<Video, 'id'> & Partial<Pick<Video, 'id'>>;
        Update: Partial<Video>;
      };
      flashcard: {
        Row: Flashcard;
        Insert: Omit<Flashcard, 'id'> & Partial<Pick<Flashcard, 'id'>>;
        Update: Partial<Flashcard>;
      };
      soal: {
        Row: Soal;
        Insert: Omit<Soal, 'id'> & Partial<Pick<Soal, 'id'>>;
        Update: Partial<Soal>;
      };
      opsi_soal: {
        Row: OpsiSoal;
        Insert: Omit<OpsiSoal, 'id'> & Partial<Pick<OpsiSoal, 'id'>>;
        Update: Partial<OpsiSoal>;
      };
    };
    Enums: {
      topik_modul: TopikModul;
      tipe_kartu: TipeKartu;
      tipe_soal: TipeSoal;
      bahasa_kode: BahasaKode;
    };
  };
}
