import { supabase } from '@/lib/supabase';
import type { SoalDenganOpsi } from '@/types/database';
import { SoalDenganOpsiSchema, validasiArray } from '@/features/materi/schema';
import type { Bahasa } from '@/app/BahasaProvider';

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

export async function ambilSoalModul(
  slugModul: string,
  bahasa: Bahasa = 'id',
): Promise<SoalDenganOpsi[]> {
  const { data, error } = await supabase
    .from('soal')
    .select(
      `
      id,
      modul_id,
       pertanyaan,
       pertanyaan_en,
      kode,
      bahasa_kode,
      tipe,
      card_type,
       penjelasan,
       penjelasan_en,
      urutan,
      modul!inner ( slug ),
       opsi_soal ( id, soal_id, label, teks, teks_en, benar, urutan )
    `,
    )
    .eq('modul.slug', slugModul)
    .order('urutan');

  if (error) {
    throw new Error(`Gagal memuat soal: ${error.message}`);
  }

  const rows = (data ?? []) as unknown as Array<
    SoalDenganOpsi & {
      pertanyaan_en?: string | null;
      penjelasan_en?: string | null;
      opsi_soal: Array<
        NonNullable<SoalDenganOpsi['opsi_soal']>[number] & { teks_en?: string | null }
      > | null;
    }
  >;
  const lokal = rows.map((soal) => ({
    ...soal,
    pertanyaan: bahasa === 'en' ? (soal.pertanyaan_en ?? soal.pertanyaan) : soal.pertanyaan,
    penjelasan: bahasa === 'en' ? (soal.penjelasan_en ?? soal.penjelasan) : soal.penjelasan,
    opsi_soal: soal.opsi_soal?.map((opsi) => ({
      ...opsi,
      teks: bahasa === 'en' ? (opsi.teks_en ?? opsi.teks) : opsi.teks,
    })),
  }));
  return validasiArray(SoalDenganOpsiSchema, lokal, 'ambilSoalModul');
}
