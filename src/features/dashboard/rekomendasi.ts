import type { ModulRingkas } from '@/types/database';
import type { ProgresGlobal, ProgresModul } from '@/features/progres/schema';
import { modulTuntas, statusTahap, type NomorTahap } from '@/features/progres/aturan';

/**
 * Logika rekomendasi Dashboard.
 *
 * Tujuan Dashboard: menjawab "apa yang harus saya kerjakan sekarang?"
 *
 * INI BUKAN halaman statistik. Statistik hanya pendukung. Fokus
 * utamanya adalah rekomendasi langkah berikutnya — dengan ALASAN,
 * bukan sekadar "lanjutkan".
 *
 * Rincian: docs/06-SPESIFIKASI-HALAMAN.md §3.3
 */

export interface Rekomendasi {
  modulId: string;
  modulSlug: string;
  modulJudul: string;
  tahap: NomorTahap;
  /** Label tombol */
  ctaLabel: string;
  /** Rute tujuan */
  ctaRute: string;
  /** Mengapa ini yang direkomendasikan */
  alasan: string;
  /** Kategori untuk ikon/warna */
  jenis: 'lanjutkan' | 'mulai' | 'selesai';
}

/**
 * Hitung rekomendasi berikutnya.
 *
 * Prioritas (docs/06-SPESIFIKASI-HALAMAN.md §3.3):
 *   1. Modul yang sedang dikerjakan (tahap 1 selesai, tahap 2 belum)
 *      — ini yang paling mungkin dilanjutkan
 *   2. Modul dengan tahap 2 selesai, tahap 3 belum
 *   3. Modul berikutnya yang belum dimulai
 *   4. null jika semua modul tuntas
 */
export function hitungRekomendasi(
  semuaModul: ModulRingkas[],
  progres: ProgresGlobal,
): Rekomendasi | null {
  // Urutkan modul sesuai urutan kurikulum
  const modulTerurut = [...semuaModul].sort((a, b) => a.urutan - b.urutan);

  // Prioritas 1: sedang di tahap 2 (paling mungkin dilanjutkan)
  for (const m of modulTerurut) {
    const p = progres.modul[m.id];
    if (p?.tahap1Selesai && !p?.tahap2Selesai) {
      const jumlahKartu = m.flashcard?.length ?? 0;
      return {
        modulId: m.id,
        modulSlug: m.slug,
        modulJudul: m.judul,
        tahap: 2,
        ctaLabel: 'Mulai Flashcard',
        ctaRute: `/soal/flashcard/${m.slug}`,
        alasan: `Kamu sudah membaca modulnya. Sekarang hafalkan konsepnya dengan ${jumlahKartu} kartu.`,
        jenis: 'lanjutkan',
      };
    }
  }

  // Prioritas 2: tahap 2 selesai, tahap 3 belum
  for (const m of modulTerurut) {
    const p = progres.modul[m.id];
    if (p?.tahap2Selesai && !p?.tahap3Selesai) {
      const jumlahSoal = m.soal?.length ?? 0;
      return {
        modulId: m.id,
        modulSlug: m.slug,
        modulJudul: m.judul,
        tahap: 3,
        ctaLabel: 'Mulai Quiz',
        ctaRute: `/soal/quiz/${m.slug}`,
        alasan: `Semua kartu sudah kamu kuasai. Buktikan dengan ${Math.min(jumlahSoal, 10)} soal.`,
        jenis: 'lanjutkan',
      };
    }
  }

  // Prioritas 3: modul berikutnya yang belum dimulai
  for (const m of modulTerurut) {
    if (!progres.modul[m.id]) {
      return {
        modulId: m.id,
        modulSlug: m.slug,
        modulJudul: m.judul,
        tahap: 1,
        ctaLabel: 'Baca Modul',
        ctaRute: `/materi/${m.slug}`,
        alasan: `Belum kamu mulai. Baca modulnya dulu, sekitar ${m.estimasi_menit} menit.`,
        jenis: 'mulai',
      };
    }
  }

  // Semua modul sudah dimulai — cari yang belum tuntas
  for (const m of modulTerurut) {
    const p = progres.modul[m.id];
    if (p && !modulTuntas(p)) {
      const tahap = cariTahapTersedia(p);
      if (tahap === null) continue;

      return buatRekomendasi(m, tahap, 'lanjutkan');
    }
  }

  // Semua tuntas
  return null;
}

/** Cari tahap yang tersedia untuk modul yang sedang dikerjakan */
function cariTahapTersedia(p: ProgresModul): NomorTahap | null {
  for (const t of [1, 2, 3] as const) {
    if (statusTahap(p, t) === 'tersedia') return t;
  }
  return null;
}

/** Buat objek rekomendasi dari modul dan tahap */
function buatRekomendasi(
  m: ModulRingkas,
  tahap: NomorTahap,
  jenis: Rekomendasi['jenis'],
): Rekomendasi {
  const jumlahKartu = m.flashcard?.length ?? 0;
  const jumlahSoal = m.soal?.length ?? 0;

  if (tahap === 1) {
    return {
      modulId: m.id,
      modulSlug: m.slug,
      modulJudul: m.judul,
      tahap: 1,
      ctaLabel: 'Baca Modul',
      ctaRute: `/materi/${m.slug}`,
      alasan: `Baca modulnya, sekitar ${m.estimasi_menit} menit.`,
      jenis,
    };
  }

  if (tahap === 2) {
    return {
      modulId: m.id,
      modulSlug: m.slug,
      modulJudul: m.judul,
      tahap: 2,
      ctaLabel: 'Mulai Flashcard',
      ctaRute: `/soal/flashcard/${m.slug}`,
      alasan: `Hafalkan ${jumlahKartu} kartu dari modul ini.`,
      jenis,
    };
  }

  return {
    modulId: m.id,
    modulSlug: m.slug,
    modulJudul: m.judul,
    tahap: 3,
    ctaLabel: 'Mulai Quiz',
    ctaRute: `/soal/quiz/${m.slug}`,
    alasan: `Buktikan pemahamanmu dengan ${Math.min(jumlahSoal, 10)} soal.`,
    jenis,
  };
}

/**
 * Urutkan modul untuk daftar di Dashboard.
 *
 * Modul yang sedang dikerjakan muncul paling atas — pengguna yang
 * membuka Dashboard ingin MELANJUTKAN, bukan mencari-cari.
 *
 * Bobot: 0 = sedang dikerjakan, 1 = belum dimulai, 2 = sudah selesai
 */
export function urutkanModulUntukDashboard(
  semuaModul: ModulRingkas[],
  progres: ProgresGlobal,
): ModulRingkas[] {
  function bobot(m: ModulRingkas): number {
    const p = progres.modul[m.id];
    if (!p) return 1;
    if (modulTuntas(p)) return 2;
    return 0;
  }

  return [...semuaModul].sort((a, b) => {
    const selisih = bobot(a) - bobot(b);
    return selisih !== 0 ? selisih : a.urutan - b.urutan;
  });
}

/**
 * Statistik per topik untuk bar progres di Dashboard.
 */
export interface StatistikTopik {
  topik: 'array' | 'struct' | 'pointer';
  total: number;
  selesai: number;
  persen: number;
}

export function hitungProgresPerTopik(
  semuaModul: ModulRingkas[],
  progres: ProgresGlobal,
): StatistikTopik[] {
  const perTopik = new Map<'array' | 'struct' | 'pointer', { total: number; selesai: number }>();

  for (const m of semuaModul) {
    const stat = perTopik.get(m.topik) ?? { total: 0, selesai: 0 };
    stat.total += 1;
    if (modulTuntas(progres.modul[m.id])) stat.selesai += 1;
    perTopik.set(m.topik, stat);
  }

  const hasil: StatistikTopik[] = [];

  for (const [topik, stat] of perTopik) {
    hasil.push({
      topik,
      total: stat.total,
      selesai: stat.selesai,
      persen: stat.total > 0 ? Math.round((stat.selesai / stat.total) * 100) : 0,
    });
  }

  // Urutkan sesuai urutan kurikulum: array, struct, pointer
  const urutanTopik = { array: 1, struct: 2, pointer: 3 };
  return hasil.sort((a, b) => urutanTopik[a.topik] - urutanTopik[b.topik]);
}

/**
 * Cari modul dengan akurasi quiz terendah — untuk saran "ulangi yang lemah".
 *
 * Hanya mempertimbangkan modul yang sudah pernah dikerjakan quiz-nya.
 */
export function cariModulTerlemah(
  semuaModul: ModulRingkas[],
  progres: ProgresGlobal,
): { slug: string; judul: string; akurasi: number } | null {
  let terlemah: { slug: string; judul: string; akurasi: number } | null = null;

  for (const m of semuaModul) {
    const p = progres.modul[m.id];
    if (!p || p.riwayatQuiz.length === 0) continue;

    const skor = p.riwayatQuiz.map((q) => q.skor);
    const akurasi = Math.round(skor.reduce((a, b) => a + b, 0) / skor.length);

    if (!terlemah || akurasi < terlemah.akurasi) {
      terlemah = { slug: m.slug, judul: m.judul, akurasi };
    }
  }

  return terlemah;
}
