import { supabase } from '@/lib/supabase';
import type { KartuDenganModul } from '@/types/database';
import { KartuDenganModulSchema, validasiArray } from '@/features/materi/schema';

/**
 * Query kartu flashcard untuk sesi belajar.
 *
 * Mengambil semua kartu satu modul beserta info modulnya. Deck kartu
 * berlaku untuk satu modul secara utuh (bukan per bagian), sesuai
 * docs/01-PRD.md §3 Tahap 2.
 */

export async function ambilKartuModul(slugModul: string): Promise<KartuDenganModul[]> {
  const { data, error } = await supabase
    .from('flashcard')
    .select(
      `
      id,
      modul_id,
      depan,
      belakang,
      card_type,
      kode,
      bahasa_kode,
      urutan,
      modul!inner ( slug, judul, topik )
    `,
    )
    .eq('modul.slug', slugModul)
    .order('urutan');

  if (error) {
    throw new Error(`Gagal memuat kartu: ${error.message}`);
  }

  return validasiArray(KartuDenganModulSchema, data, 'ambilKartuModul');
}
