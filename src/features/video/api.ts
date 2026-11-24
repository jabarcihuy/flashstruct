import { supabase } from '@/lib/supabase';
import type { VideoDenganModul } from '@/types/database';
import { VideoDenganModulSchema, validasiArray } from '@/features/materi/schema';
import type { Bahasa } from '@/app/BahasaProvider';

/**
 * Query video untuk halaman Video.
 *
 * Mengambil semua video beserta info modulnya, agar bisa dikelompokkan
 * per topik dan ditautkan ke modul asalnya.
 */
export async function ambilSemuaVideo(bahasa: Bahasa = 'id'): Promise<VideoDenganModul[]> {
  const { data, error } = await supabase
    .from('video')
    .select(
      `
      id,
      modul_id,
      youtube_id,
       judul,
       judul_en,
       deskripsi,
       deskripsi_en,
      durasi_detik,
      urutan,
       modul!inner ( slug, judul, judul_en, topik, urutan )
    `,
    )
    .order('urutan');

  if (error) {
    throw new Error(`Gagal memuat video: ${error.message}`);
  }

  const rows = (data ?? []) as unknown as Array<
    VideoDenganModul & {
      judul_en?: string | null;
      deskripsi_en?: string | null;
      modul: VideoDenganModul['modul'] & { judul_en?: string | null };
    }
  >;
  const lokal = rows.map((video) => ({
    ...video,
    judul: bahasa === 'en' ? (video.judul_en ?? video.judul) : video.judul,
    deskripsi: bahasa === 'en' ? (video.deskripsi_en ?? video.deskripsi) : video.deskripsi,
    modul: {
      ...video.modul,
      judul: bahasa === 'en' ? (video.modul.judul_en ?? video.modul.judul) : video.modul.judul,
    },
  }));
  return validasiArray(VideoDenganModulSchema, lokal, 'ambilSemuaVideo');
}
