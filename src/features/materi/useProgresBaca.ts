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
        const tinggiLayar = window.innerHeight;
        for (const e of entri) {
          if (!e.isIntersecting) continue;
          const slug = e.target.getAttribute('data-bagian-slug');
          if (!slug) continue;

          const rect = e.boundingClientRect;
          // Kasus 1: rasio keterlihatan >= 35%
          const rasioCukup = e.intersectionRatio >= 0.35;
          // Kasus 2: bagian panjang (tinggi > 60% viewport) dan sedang berada di area baca layar
          const bagianPanjang = rect.height >= tinggiLayar * 0.6;
          const aktifDiLayar =
            bagianPanjang && rect.top <= tinggiLayar * 0.6 && rect.bottom >= tinggiLayar * 0.25;

          if (rasioCukup || aktifDiLayar) {
            tandai(slug);
          }
        }
      },
      { threshold: [0.1, 0.25, 0.4, 0.6], rootMargin: '0px 0px -5% 0px' },
    );

    refPengamat.current = pengamat;

    const elemen = document.querySelectorAll<HTMLElement>('[data-bagian-slug]');
    elemen.forEach((el) => pengamat.observe(el));

    // Pemeriksa scroll untuk menangani bagian panjang & mendeteksi scroll ke akhir halaman
    function periksaPosisiScroll() {
      const tinggiLayar = window.innerHeight;
      const daftarElemen = document.querySelectorAll<HTMLElement>('[data-bagian-slug]');

      daftarElemen.forEach((el) => {
        const slug = el.getAttribute('data-bagian-slug');
        if (!slug) return;
        const rect = el.getBoundingClientRect();
        // Bagian sedang berada di fokus baca (tengah layar)
        if (rect.top <= tinggiLayar * 0.55 && rect.bottom >= tinggiLayar * 0.2) {
          tandai(slug);
        }
      });

      // Bila pengguna sudah scroll mendekati bagian bawah halaman, tandai bagian terakhir
      const sudahDiDasar =
        window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 150;
      if (sudahDiDasar && daftarElemen.length > 0) {
        const bagianAkhir = daftarElemen[daftarElemen.length - 1]?.getAttribute('data-bagian-slug');
        if (bagianAkhir) tandai(bagianAkhir);
      }
    }

    window.addEventListener('scroll', periksaPosisiScroll, { passive: true });
    // Periksa segera posisi awal setelah render
    periksaPosisiScroll();

    return () => {
      pengamat.disconnect();
      window.removeEventListener('scroll', periksaPosisiScroll);
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
