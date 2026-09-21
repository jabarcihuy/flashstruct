/**
 * Tipe data hasil query Supabase.
 *
 * Ditulis manual (bukan hasil generate) agar bisa dibaca dan
 * disesuaikan. Bentuknya mengikuti skema di docs/05-SKEMA-DATABASE.md §3.
 */

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
   Baris tabel (bentuk dasar, tanpa relasi)
   ========================================================= */

export interface Modul {
  id: string;
  slug: string;
  judul: string;
  topik: TopikModul;
  deskripsi: string;
  estimasi_menit: number;
  urutan: number;
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
   Hasil query dengan relasi (embedding)
   ========================================================= */

/** Modul + jumlah anak, untuk halaman daftar materi */
export interface ModulRingkas extends Modul {
  bagian_modul: { id: string }[] | null;
  flashcard: { id: string }[] | null;
  soal: { id: string }[] | null;
}

/** Modul lengkap dengan isi bagian dan video, untuk halaman baca */
export interface ModulLengkap extends Modul {
  bagian_modul: BagianModul[] | null;
  video: Video[] | null;
}

/** Kartu dengan info modulnya, untuk sesi flashcard */
export interface KartuDenganModul extends Flashcard {
  modul: { slug: string; judul: string; topik: TopikModul };
}

/** Soal dengan opsi dan info modul, untuk sesi quiz */
export interface SoalDenganOpsi extends Soal {
  modul: { slug: string };
  opsi_soal: OpsiSoal[] | null;
}

/** Video dengan info modulnya, untuk halaman video */
export interface VideoDenganModul extends Video {
  modul: {
    slug: string;
    judul: string;
    topik: TopikModul;
    urutan: number;
  };
}
