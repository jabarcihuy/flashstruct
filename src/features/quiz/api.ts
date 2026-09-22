import { supabase } from '@/lib/supabase';
import type { SoalDenganOpsi } from '@/types/database';
import { SoalDenganOpsiSchema, validasiArray } from '@/features/materi/schema';

/**
 * Query soal quiz untuk satu modul.
 *
 * Mengambil soal beserta opsi jawabannya dalam SATU request
 * (foreign key embedding Supabase).
 *
 * Catatan keamanan: kunci jawaban (`opsi_soal.benar`) terkirim ke
 * client. Ini DISADARI dan DITERIMA — aplikasi ini alat belajar,
 * bukan ujian. Menyembunyikan jawaban dari mahasiswa yang ingin
 * belajar tidak memberi manfaat.
 * Rincian: docs/README.md §Ringkasan Keputusan
 */

export async function ambilSoalModul(slugModul: string): Promise<SoalDenganOpsi[]> {
  const { data, error } = await supabase
    .from('soal')
    .select(
      `
      id,
      modul_id,
      pertanyaan,
      kode,
      bahasa_kode,
      tipe,
      card_type,
      penjelasan,
      urutan,
      modul!inner ( slug ),
      opsi_soal ( id, soal_id, label, teks, benar, urutan )
    `,
    )
    .eq('modul.slug', slugModul)
    .order('urutan');

  if (error) {
    throw new Error(`Gagal memuat soal: ${error.message}`);
  }

  return validasiArray(SoalDenganOpsiSchema, data, 'ambilSoalModul');
}
