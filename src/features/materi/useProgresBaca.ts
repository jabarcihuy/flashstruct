import { useCallback, useEffect, useRef, useState } from 'react';
import { useProgres } from '@/features/progres/context';
import { PERSEN_MINIMAL_BACA } from '@/lib/constants';

/**
 * Pelacakan progres baca modul.
 *
 * PRD mensyaratkan pengguna membuka minimal 80% bagian sebelum modul
 * bisa ditandai selesai. Ini mencegah "klik selesai tanpa membaca".
 *
 * Cara kerja: IntersectionObserver menandai bagian saat 60% isinya
 * terlihat. Ambang 60% dipilih karena menandai hanya karena 1 piksel
 * terlihat akan membuat pelacakan tidak berarti.
 *
 * Rincian: docs/06-SPESIFIKASI-HALAMAN.md §4.3
 */

/** Bagian dianggap dibaca setelah 60% terlihat */
const AMBANG_TERLIHAT = 0.6;

/**
 * Margin bawah: bagian terakhir tidak langsung ditandai saat halaman
 * dimuat. Pengguna harus benar-benar scroll ke sana.
 */
const MARGIN_BAWAH = '0px 0px -10% 0px';

interface HasilProgresBaca {
  /** Slug bagian yang sudah dibaca */
  bagianDibaca: string[];
  /** Persentase bagian yang sudah dibaca (0-100) */
  persen: number;
  /** Apakah sudah cukup untuk menandai modul selesai */
  cukupUntukSelesai: boolean;
  /** Jumlah bagian yang sudah dibaca */
  jumlahDibaca: number;
  /** Total bagian */
  jumlahBagian: number;
}

export function useProgresBaca(modulId: string, daftarSlugBagian: string[]): HasilProgresBaca {
  const { ambilModul, tandaiBagianDibaca } = useProgres();
  const refPengamat = useRef<IntersectionObserver | null>(null);

  // Paksa render ulang saat bagian dibaca bertambah
  const [, setPenanda] = useState(0);

  const bagianDibaca = ambilModul(modulId)?.bagianDibaca ?? [];

  // Kunci stabil untuk dependency — join dipakai agar array tidak
  // dianggap berubah setiap render (array baru = referensi baru).
  const kunciBagian = daftarSlugBagian.join(',');

  const tandai = useCallback(
    (slug: string) => {
      tandaiBagianDibaca(modulId, slug);
      setPenanda((n) => n + 1);
    },
    [modulId, tandaiBagianDibaca],
  );

  useEffect(() => {
    // IntersectionObserver tidak ada di lingkungan uji — lewati saja
    if (typeof IntersectionObserver === 'undefined') return;

    const pengamat = new IntersectionObserver(
      (entri) => {
        for (const e of entri) {
          if (!e.isIntersecting) continue;
          const slug = e.target.getAttribute('data-bagian-slug');
          if (slug) tandai(slug);
        }
      },
      { threshold: AMBANG_TERLIHAT, rootMargin: MARGIN_BAWAH },
    );

    refPengamat.current = pengamat;

    const elemen = document.querySelectorAll('[data-bagian-slug]');
    elemen.forEach((el) => pengamat.observe(el));

    return () => {
      pengamat.disconnect();
      refPengamat.current = null;
    };
  }, [modulId, kunciBagian, tandai]);

  const jumlahBagian = daftarSlugBagian.length;
  // Hanya hitung bagian yang memang ada di modul ini
  const dibacaValid = bagianDibaca.filter((s) => daftarSlugBagian.includes(s));
  const jumlahDibaca = dibacaValid.length;
  const persen = jumlahBagian > 0 ? Math.round((jumlahDibaca / jumlahBagian) * 100) : 0;

  return {
    bagianDibaca: dibacaValid,
    persen,
    cukupUntukSelesai: persen >= PERSEN_MINIMAL_BACA,
    jumlahDibaca,
    jumlahBagian,
  };
}
