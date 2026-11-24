import { supabase } from '@/lib/supabase';
import type { ModulLengkap, ModulRingkas } from '@/types/database';
import { ModulLengkapSchema, ModulRingkasSchema, validasi, validasiArray } from './schema';
import type { Bahasa } from '@/app/BahasaProvider';

/**
 * Query ke Supabase untuk fitur materi.
 *
 * Ini SATU-SATUNYA tempat query Supabase untuk fitur materi.
 * Komponen tidak boleh memanggil supabase langsung — semua lewat sini
 * agar mudah diuji dan diubah.
 *
 * Catatan: Supabase otomatis mendeteksi relasi dari foreign key dan
 * mendukung embedding bertingkat dalam SATU request. Ini menghilangkan
 * masalah N+1.
 */

/**
 * Ambil semua modul untuk halaman daftar materi.
 *
 * Hanya mengambil id dari tabel anak (bukan isinya) karena halaman
 * daftar hanya butuh JUMLAH bagian, kartu, dan soal. Mengambil konten
 * penuh akan memperlambat halaman tanpa manfaat.
 */
export async function ambilDaftarModul(bahasa: Bahasa = 'id'): Promise<ModulRingkas[]> {
  const { data, error } = await supabase
    .from('modul')
    .select(
      `
      id,
      slug,
       judul,
       judul_en,
      topik,
       deskripsi,
       deskripsi_en,
      estimasi_menit,
      urutan,
      bagian_modul ( id ),
      flashcard ( id ),
      soal ( id )
    `,
    )
    .order('urutan');

  if (error) {
    throw new Error(`Gagal memuat daftar modul: ${error.message}`);
  }

  const rows = (data ?? []) as unknown as Array<
    ModulRingkas & { judul_en?: string | null; deskripsi_en?: string | null }
  >;
  const lokal = rows.map((modul) => ({
    ...modul,
    judul: bahasa === 'en' ? (modul.judul_en ?? modul.judul) : modul.judul,
    deskripsi: bahasa === 'en' ? (modul.deskripsi_en ?? modul.deskripsi) : modul.deskripsi,
  }));
  return validasiArray(ModulRingkasSchema, lokal, 'ambilDaftarModul');
}

/**
 * Ambil satu modul lengkap dengan isi bagian dan videonya.
 *
 * Kartu dan soal TIDAK diambil di sini karena halaman baca modul
 * tidak menampilkannya. Mengambil 20 kartu + 20 soal yang tidak
 * dipakai hanya memperlambat halaman.
 */
export async function ambilModulLengkap(
  slug: string,
  bahasa: Bahasa = 'id',
): Promise<ModulLengkap | null> {
  const { data, error } = await supabase
    .from('modul')
    .select(
      `
      id,
      slug,
       judul,
       judul_en,
      topik,
       deskripsi,
       deskripsi_en,
      estimasi_menit,
      urutan,
       bagian_modul ( id, modul_id, slug, judul, judul_en, konten_md, konten_md_en, urutan ),
       video ( id, modul_id, youtube_id, judul, judul_en, deskripsi, deskripsi_en, durasi_detik, urutan )
    `,
    )
    .eq('slug', slug)
    .maybeSingle();

  if (error) {
    throw new Error(`Gagal memuat modul "${slug}": ${error.message}`);
  }

  if (!data) return null;

  const moduleRow = data as unknown as ModulLengkap & {
    judul_en?: string | null;
    deskripsi_en?: string | null;
  };
  const lokal = {
    ...moduleRow,
    judul: bahasa === 'en' ? (moduleRow.judul_en ?? moduleRow.judul) : moduleRow.judul,
    deskripsi:
      bahasa === 'en' ? (moduleRow.deskripsi_en ?? moduleRow.deskripsi) : moduleRow.deskripsi,
    bagian_modul: moduleRow.bagian_modul?.map((bagian) => ({
      ...bagian,
      judul: bahasa === 'en' ? (bagian.judul_en ?? bagian.judul) : bagian.judul,
      konten_md: bahasa === 'en' ? (bagian.konten_md_en ?? bagian.konten_md) : bagian.konten_md,
    })),
    video: moduleRow.video?.map((video) => ({
      ...video,
      judul: bahasa === 'en' ? (video.judul_en ?? video.judul) : video.judul,
      deskripsi: bahasa === 'en' ? (video.deskripsi_en ?? video.deskripsi) : video.deskripsi,
    })),
  };
  return validasi(ModulLengkapSchema, lokal, `ambilModulLengkap(${slug})`);
}
