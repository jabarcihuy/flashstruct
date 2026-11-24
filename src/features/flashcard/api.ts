import { supabase } from '@/lib/supabase';
import type { KartuDenganModul } from '@/types/database';
import { KartuDenganModulSchema, validasiArray } from '@/features/materi/schema';
import type { Bahasa } from '@/app/BahasaProvider';

/**
 * Query kartu flashcard untuk sesi belajar.
 *
 * Mengambil semua kartu satu modul beserta info modulnya. Deck kartu
 * berlaku untuk satu modul secara utuh (bukan per bagian), sesuai
 * docs/01-PRD.md §3 Tahap 2.
 */

export async function ambilKartuModul(
  slugModul: string,
  bahasa: Bahasa = 'id',
): Promise<KartuDenganModul[]> {
  const { data, error } = await supabase
    .from('flashcard')
    .select(
      `
      id,
      modul_id,
       depan,
       depan_en,
       belakang,
       belakang_en,
      card_type,
      kode,
      bahasa_kode,
      urutan,
       modul!inner ( slug, judul, judul_en, topik )
    `,
    )
    .eq('modul.slug', slugModul)
    .order('urutan');

  if (error) {
    throw new Error(`Gagal memuat kartu: ${error.message}`);
  }

  const rows = (data ?? []) as unknown as Array<
    KartuDenganModul & {
      depan_en?: string | null;
      belakang_en?: string | null;
      modul: KartuDenganModul['modul'] & { judul_en?: string | null };
    }
  >;
  const lokal = rows.map((kartu) => ({
    ...kartu,
    depan: bahasa === 'en' ? (kartu.depan_en ?? kartu.depan) : kartu.depan,
    belakang: bahasa === 'en' ? (kartu.belakang_en ?? kartu.belakang) : kartu.belakang,
    modul: {
      ...kartu.modul,
      judul: bahasa === 'en' ? (kartu.modul.judul_en ?? kartu.modul.judul) : kartu.modul.judul,
    },
  }));
  return validasiArray(KartuDenganModulSchema, lokal, 'ambilKartuModul');
}
