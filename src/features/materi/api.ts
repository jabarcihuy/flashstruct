import { supabase } from '@/lib/supabase';
import type { ModulLengkap, ModulRingkas } from '@/types/database';
import {
  ModulLengkapSchema,
  ModulRingkasSchema,
  validasi,
  validasiArray,
} from './schema';

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
export async function ambilDaftarModul(): Promise<ModulRingkas[]> {
  const { data, error } = await supabase
    .from('modul')
    .select(
      `
      id,
      slug,
      judul,
      topik,
      deskripsi,
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

  return validasiArray(ModulRingkasSchema, data, 'ambilDaftarModul');
}

/**
 * Ambil satu modul lengkap dengan isi bagian dan videonya.
 *
 * Kartu dan soal TIDAK diambil di sini karena halaman baca modul
 * tidak menampilkannya. Mengambil 20 kartu + 20 soal yang tidak
 * dipakai hanya memperlambat halaman.
 */
export async function ambilModulLengkap(slug: string): Promise<ModulLengkap | null> {
  const { data, error } = await supabase
    .from('modul')
    .select(
      `
      id,
      slug,
      judul,
      topik,
      deskripsi,
      estimasi_menit,
      urutan,
      bagian_modul ( id, modul_id, slug, judul, konten_md, urutan ),
      video ( id, modul_id, youtube_id, judul, deskripsi, durasi_detik, urutan )
    `,
    )
    .eq('slug', slug)
    .maybeSingle();

  if (error) {
    throw new Error(`Gagal memuat modul "${slug}": ${error.message}`);
  }

  if (!data) return null;

  return validasi(ModulLengkapSchema, data, `ambilModulLengkap(${slug})`);
}
