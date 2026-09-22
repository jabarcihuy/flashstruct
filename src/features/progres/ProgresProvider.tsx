import { useCallback, useMemo, useState, type ReactNode } from 'react';
import { ProgresContext, type ProgresContextValue } from './context';
import {
  bacaProgres,
  catatHariAktif,
  hapusProgres,
  pastikanProgresModul,
  tulisProgres,
} from './store';
import { progresKosong, type HasilQuiz, type ProgresGlobal, type StatusKartu } from './schema';

/**
 * Provider progres.
 *
 * Membaca progres dari localStorage saat pertama render, lalu
 * menyediakan fungsi untuk memperbaruinya. Setiap perubahan langsung
 * ditulis ke localStorage.
 *
 * Alasan memakai Context, bukan TanStack Query: progres adalah data
 * LOKAL pengguna, bukan data server. Tidak ada jaringan yang terlibat,
 * jadi cache query tidak memberi manfaat.
 */

/** Cek apakah localStorage bisa dipakai (bisa gagal di mode privat Safari) */
function cekPenyimpanan(): boolean {
  try {
    const kunci = '__uji_storage__';
    localStorage.setItem(kunci, '1');
    localStorage.removeItem(kunci);
    return true;
  } catch {
    return false;
  }
}

/**
 * Baca progres awal secara sinkron saat inisialisasi state.
 *
 * Dibaca langsung (bukan di useEffect) supaya render pertama sudah
 * punya data yang benar. Ini menghindari render kosong lalu render
 * berisi, yang menyebabkan kedipan dan peringatan lint.
 *
 * Aman dipanggil saat server render karena dicek dengan typeof window.
 */
function progresAwal(): { progres: ProgresGlobal; tersedia: boolean } {
  if (typeof window === 'undefined') {
    return { progres: progresKosong(), tersedia: true };
  }

  const tersedia = cekPenyimpanan();
  if (!tersedia) return { progres: progresKosong(), tersedia: false };

  return { progres: catatHariAktif(bacaProgres()), tersedia: true };
}

export function ProgresProvider({ children }: { children: ReactNode }) {
  // Inisialisasi langsung — tidak perlu useEffect untuk memuat
  const [awal] = useState(progresAwal);
  const [progres, setProgres] = useState<ProgresGlobal>(awal.progres);

  /**
   * Perbarui progres: terapkan fungsi, simpan ke localStorage.
   *
   * Memakai bentuk fungsional agar tidak ada race condition saat
   * beberapa pembaruan terjadi berurutan.
   */
  const perbarui = useCallback((fn: (sebelumnya: ProgresGlobal) => ProgresGlobal) => {
    setProgres((sebelumnya) => {
      const baru = catatHariAktif(fn(sebelumnya));
      tulisProgres(baru);
      return baru;
    });
  }, []);

  /* =========================================================
     Operasi
     ========================================================= */

  const ambilModul = useCallback((modulId: string) => progres.modul[modulId], [progres.modul]);

  const tandaiBagianDibaca = useCallback(
    (modulId: string, bagianSlug: string) => {
      perbarui((p) => {
        const { progres: p2, modul } = pastikanProgresModul(p, modulId);
        if (modul.bagianDibaca.includes(bagianSlug)) return p2;

        return {
          ...p2,
          modul: {
            ...p2.modul,
            [modulId]: { ...modul, bagianDibaca: [...modul.bagianDibaca, bagianSlug] },
          },
        };
      });
    },
    [perbarui],
  );

  const tandaiModulSelesai = useCallback(
    (modulId: string) => {
      perbarui((p) => {
        const { progres: p2, modul } = pastikanProgresModul(p, modulId);
        if (modul.tahap1Selesai) return p2;
        return {
          ...p2,
          modul: { ...p2.modul, [modulId]: { ...modul, tahap1Selesai: true } },
        };
      });
    },
    [perbarui],
  );

  const batalkanModulSelesai = useCallback(
    (modulId: string) => {
      perbarui((p) => {
        const modul = p.modul[modulId];
        if (!modul) return p;
        return {
          ...p,
          modul: { ...p.modul, [modulId]: { ...modul, tahap1Selesai: false } },
        };
      });
    },
    [perbarui],
  );

  const simpanHasilSesiKartu = useCallback(
    (modulId: string, hasil: Record<string, boolean>) => {
      perbarui((p) => {
        const { progres: p2, modul } = pastikanProgresModul(p, modulId);
        const sekarang = Date.now();
        const kartuBaru: Record<string, StatusKartu> = { ...modul.kartu };

        for (const [kartuId, ingat] of Object.entries(hasil)) {
          const lama = kartuBaru[kartuId];
          kartuBaru[kartuId] = {
            kartuId,
            jumlahIngat: (lama?.jumlahIngat ?? 0) + (ingat ? 1 : 0),
            jumlahLupa: (lama?.jumlahLupa ?? 0) + (ingat ? 0 : 1),
            terakhirDilihat: sekarang,
          };
        }

        return {
          ...p2,
          modul: { ...p2.modul, [modulId]: { ...modul, kartu: kartuBaru } },
        };
      });
    },
    [perbarui],
  );

  const tandaiFlashcardSelesai = useCallback(
    (modulId: string) => {
      perbarui((p) => {
        const { progres: p2, modul } = pastikanProgresModul(p, modulId);
        if (modul.tahap2Selesai) return p2;
        return {
          ...p2,
          modul: { ...p2.modul, [modulId]: { ...modul, tahap2Selesai: true } },
        };
      });
    },
    [perbarui],
  );

  const simpanHasilQuiz = useCallback(
    (modulId: string, hasil: HasilQuiz) => {
      perbarui((p) => {
        const { progres: p2, modul } = pastikanProgresModul(p, modulId);
        return {
          ...p2,
          modul: {
            ...p2.modul,
            [modulId]: { ...modul, riwayatQuiz: [...modul.riwayatQuiz, hasil] },
          },
        };
      });
    },
    [perbarui],
  );

  const tandaiQuizSelesai = useCallback(
    (modulId: string) => {
      perbarui((p) => {
        const { progres: p2, modul } = pastikanProgresModul(p, modulId);
        if (modul.tahap3Selesai) return p2;
        return {
          ...p2,
          modul: { ...p2.modul, [modulId]: { ...modul, tahap3Selesai: true } },
        };
      });
    },
    [perbarui],
  );

  const ambilStatusKartu = useCallback(
    (modulId: string, kartuId: string) => progres.modul[modulId]?.kartu[kartuId],
    [progres.modul],
  );

  const resetProgres = useCallback(() => {
    hapusProgres();
    setProgres(progresKosong());
  }, []);

  const gantiProgres = useCallback((baru: ProgresGlobal) => {
    tulisProgres(baru);
    setProgres(baru);
  }, []);

  const nilai = useMemo<ProgresContextValue>(
    () => ({
      progres,
      sedangMemuat: false,
      ambilModul,
      tandaiBagianDibaca,
      tandaiModulSelesai,
      batalkanModulSelesai,
      simpanHasilSesiKartu,
      tandaiFlashcardSelesai,
      simpanHasilQuiz,
      tandaiQuizSelesai,
      ambilStatusKartu,
      resetProgres,
      gantiProgres,
      penyimpananTersedia: awal.tersedia,
    }),
    [
      progres,
      ambilModul,
      tandaiBagianDibaca,
      tandaiModulSelesai,
      batalkanModulSelesai,
      simpanHasilSesiKartu,
      tandaiFlashcardSelesai,
      simpanHasilQuiz,
      tandaiQuizSelesai,
      ambilStatusKartu,
      resetProgres,
      gantiProgres,
      awal.tersedia,
    ],
  );

  return <ProgresContext.Provider value={nilai}>{children}</ProgresContext.Provider>;
}
