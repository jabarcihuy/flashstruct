import { supabase } from '@/lib/supabase';
import type { VideoDenganModul } from '@/types/database';
import { VideoDenganModulSchema, validasiArray } from '@/features/materi/schema';

/**
 * Query video untuk halaman Video.
 *
 * Mengambil semua video beserta info modulnya, agar bisa dikelompokkan
 * per topik dan ditautkan ke modul asalnya.
 */
export async function ambilSemuaVideo(): Promise<VideoDenganModul[]> {
  const { data, error } = await supabase
    .from('video')
    .select(
      `
      id,
      modul_id,
      youtube_id,
      judul,
      deskripsi,
      durasi_detik,
      urutan,
      modul!inner ( slug, judul, topik, urutan )
    `,
    )
    .order('urutan');

  if (error) {
    throw new Error(`Gagal memuat video: ${error.message}`);
  }

  return validasiArray(VideoDenganModulSchema, data, 'ambilSemuaVideo');
}
