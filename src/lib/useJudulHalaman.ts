import { useEffect } from 'react';

/**
 * Setel judul halaman (document.title).
 *
 * Penting untuk pengguna yang membuka banyak tab: judul harus bisa
 * dibedakan satu sama lain.
 *
 * @param judul       Judul halaman
 * @param tanpaSufiks Set true untuk judul yang sudah lengkap
 *                    (mis. halaman Home yang ingin judulnya berdiri sendiri)
 *
 * Rincian: docs/06-SPESIFIKASI-HALAMAN.md §7.4
 */
export function useJudulHalaman(judul: string, tanpaSufiks = false) {
  useEffect(() => {
    const sebelumnya = document.title;
    document.title = tanpaSufiks ? judul : `${judul} | FlashStruct`;

    return () => {
      document.title = sebelumnya;
    };
  }, [judul, tanpaSufiks]);
}
