import { KUNCI_PROGRES } from '@/lib/constants';
import {
  BerkasEksporSchema,
  ProgresGlobalSchema,
  progresKosong,
  progresModulKosong,
  VERSI_PROGRES,
  type BerkasEkspor,
  type ProgresGlobal,
  type ProgresModul,
} from './schema';
import { kunciTanggal, MAKS_HARI_AKTIF } from './util';

/**
 * Baca/tulis progres ke localStorage.
 *
 * Prinsip yang dipegang:
 *   1. JANGAN pernah mempercayai localStorage — isinya bisa diubah
 *      manual, rusak, atau dari versi aplikasi yang lebih lama.
 *   2. Fungsi baca TIDAK PERNAH melempar error — selalu kembalikan
 *      nilai yang aman.
 *   3. Data rusak DISIMPAN sebagai salinan untuk diagnosis, jangan
 *      langsung dibuang.
 *
 * Rincian: docs/04-ARSITEKTUR-TEKNIS.md §3.6
 */

/** Apakah localStorage tersedia? Bisa gagal di mode privat Safari. */
function storageTersedia(): boolean {
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
 * Baca progres dari localStorage.
 *
 * Tidak pernah melempar error. Jika data tidak valid, kembalikan
 * progres kosong dan simpan salinan data rusak untuk diagnosis.
 */
export function bacaProgres(): ProgresGlobal {
  if (!storageTersedia()) {
    return progresKosong();
  }

  let mentah: string | null;
  try {
    mentah = localStorage.getItem(KUNCI_PROGRES);
  } catch {
    return progresKosong();
  }

  // Belum ada data — pengguna baru
  if (!mentah) return progresKosong();

  let terurai: unknown;
  try {
    terurai = JSON.parse(mentah);
  } catch {
    simpanDataRusak(mentah, 'json-tidak-valid');
    return progresKosong();
  }

  const hasil = ProgresGlobalSchema.safeParse(terurai);

  if (!hasil.success) {
    simpanDataRusak(mentah, 'skema-tidak-cocok');
    return progresKosong();
  }

  return hasil.data;
}

/**
 * Tulis progres ke localStorage.
 *
 * Mengembalikan true jika berhasil. Gagal menyimpan TIDAK fatal —
 * tema dan sesi tetap berjalan, hanya progres yang hilang saat refresh.
 */
export function tulisProgres(progres: ProgresGlobal): boolean {
  if (!storageTersedia()) return false;

  try {
    const data = { ...progres, terakhirDiperbarui: Date.now() };
    localStorage.setItem(KUNCI_PROGRES, JSON.stringify(data));
    return true;
  } catch {
    // Kuota penuh atau storage diblokir
    return false;
  }
}

/**
 * Simpan salinan data rusak untuk diagnosis.
 *
 * Berguna saat ada laporan bug — data asli bisa diperiksa.
 * Maksimal 3 salinan agar tidak memenuhi kuota.
 */
function simpanDataRusak(isi: string, sebab: string): void {
  if (!storageTersedia()) return;

  try {
    const kunci = `${KUNCI_PROGRES}:rusak:${sebab}:${Date.now()}`;
    localStorage.setItem(kunci, isi);

    // Bersihkan salinan lama — sisakan maksimal 3
    const semuaKunci = Object.keys(localStorage).filter((k) =>
      k.startsWith(`${KUNCI_PROGRES}:rusak:`),
    );

    if (semuaKunci.length > 3) {
      semuaKunci
        .sort()
        .slice(0, semuaKunci.length - 3)
        .forEach((k) => localStorage.removeItem(k));
    }
  } catch {
    // Gagal menyimpan salinan tidak fatal
  }
}

/** Hapus progres sepenuhnya */
export function hapusProgres(): boolean {
  if (!storageTersedia()) return false;
  try {
    localStorage.removeItem(KUNCI_PROGRES);
    return true;
  } catch {
    return false;
  }
}

/* =========================================================
   Operasi per modul
   ========================================================= */

/** Ambil progres satu modul, atau undefined jika belum dimulai */
export function ambilProgresModul(
  progres: ProgresGlobal,
  modulId: string,
): ProgresModul | undefined {
  return progres.modul[modulId];
}

/**
 * Pastikan progres modul ada, buat baru jika belum.
 * Mengembalikan progres global yang sudah diperbarui (immutable).
 */
export function pastikanProgresModul(
  progres: ProgresGlobal,
  modulId: string,
): { progres: ProgresGlobal; modul: ProgresModul } {
  const ada = progres.modul[modulId];
  if (ada) return { progres, modul: ada };

  const baru = progresModulKosong(modulId);
  return {
    progres: { ...progres, modul: { ...progres.modul, [modulId]: baru } },
    modul: baru,
  };
}

/* =========================================================
   Hari aktif (untuk streak)
   ========================================================= */

/**
 * Catat bahwa pengguna aktif hari ini.
 *
 * Menyimpan daftar tanggal unik (YYYY-MM-DD). Dibatasi
 * MAKS_HARI_AKTIF agar tidak tumbuh tanpa batas.
 */
export function catatHariAktif(progres: ProgresGlobal): ProgresGlobal {
  const hariIni = kunciTanggal(Date.now());

  if (progres.hariAktif.includes(hariIni)) return progres;

  const diperbarui = [...progres.hariAktif, hariIni]
    .sort()
    .slice(-MAKS_HARI_AKTIF);

  return { ...progres, hariAktif: diperbarui };
}

/* =========================================================
   Ekspor / impor
   ========================================================= */

/** Buat berkas ekspor dari progres saat ini */
export function buatBerkasEkspor(progres: ProgresGlobal): BerkasEkspor {
  return {
    jenis: 'flashstruct-progres',
    versi: VERSI_PROGRES,
    dieksporPada: Date.now(),
    data: progres,
  };
}

/**
 * Baca berkas impor.
 *
 * Memvalidasi dengan Zod sebelum menerapkan. Mengembalikan objek
 * dengan `berhasil` agar pemanggil bisa menampilkan pesan yang tepat.
 */
export function bacaBerkasImpor(
  isi: string,
): { berhasil: true; progres: ProgresGlobal } | { berhasil: false; pesan: string } {
  let terurai: unknown;
  try {
    terurai = JSON.parse(isi);
  } catch {
    return { berhasil: false, pesan: 'Berkas bukan JSON yang valid.' };
  }

  const hasil = BerkasEksporSchema.safeParse(terurai);

  if (!hasil.success) {
    return {
      berhasil: false,
      pesan: 'Berkas tidak dikenali. Pastikan ini berkas ekspor FlashStruct.',
    };
  }

  // Terima versi lama, tapi tolak versi yang lebih baru
  if (hasil.data.versi > VERSI_PROGRES) {
    return {
      berhasil: false,
      pesan: `Berkas berasal dari versi aplikasi yang lebih baru (v${hasil.data.versi}). Perbarui aplikasi dulu.`,
    };
  }

  return { berhasil: true, progres: hasil.data.data };
}

/** Unduh progres sebagai berkas JSON */
export function unduhProgres(progres: ProgresGlobal): void {
  const berkas = buatBerkasEkspor(progres);
  const isi = JSON.stringify(berkas, null, 2);
  const blob = new Blob([isi], { type: 'application/json' });

  const tanggal = kunciTanggal(Date.now());
  const url = URL.createObjectURL(blob);

  const tautan = document.createElement('a');
  tautan.href = url;
  tautan.download = `flashstruct-progres-${tanggal}.json`;
  document.body.appendChild(tautan);
  tautan.click();
  document.body.removeChild(tautan);

  URL.revokeObjectURL(url);
}
