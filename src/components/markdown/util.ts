/**
 * Utilitas markdown dan callout.
 *
 * Dipisah dari komponen agar lint Fast Refresh bersih
 * (file yang hanya mengekspor komponen saja).
 */

export type TipeCallout = 'info' | 'perhatian' | 'bahaya' | 'tips';

/** Ubah penanda teks menjadi tipe callout */
export function tipeDariPenanda(penanda: string): TipeCallout | null {
  const p = penanda.trim().toUpperCase();
  if (p === 'INFO') return 'info';
  if (p === 'PERHATIAN' || p === 'WARNING') return 'perhatian';
  if (p === 'BAHAYA' || p === 'DANGER') return 'bahaya';
  if (p === 'TIPS' || p === 'TIP') return 'tips';
  return null;
}

/** Buat id dari judul heading — untuk anchor daftar isi */
export function slugHeading(teks: string): string {
  return teks
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-');
}
