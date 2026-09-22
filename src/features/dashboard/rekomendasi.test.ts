import { describe, it, expect } from 'vitest';
import {
  hitungRekomendasi,
  hitungProgresPerTopik,
  urutkanModulUntukDashboard,
  cariModulTerlemah,
} from './rekomendasi';
import { progresKosong, progresModulKosong, type ProgresGlobal } from '@/features/progres/schema';
import type { ModulRingkas } from '@/types/database';

/* =========================================================
   Helper
   ========================================================= */

function modul(
  id: string,
  slug: string,
  topik: 'array' | 'struct' | 'pointer',
  urutan: number,
  jumlahKartu = 20,
  jumlahSoal = 18,
): ModulRingkas {
  return {
    id,
    slug,
    judul: `Modul ${slug}`,
    topik,
    deskripsi: 'Deskripsi',
    estimasi_menit: 12,
    urutan,
    bagian_modul: [{ id: 'b1' }],
    flashcard: Array.from({ length: jumlahKartu }, (_, i) => ({ id: `k${i}` })),
    soal: Array.from({ length: jumlahSoal }, (_, i) => ({ id: `s${i}` })),
  };
}

const MODUL = [
  modul('m1', 'array-dasar', 'array', 1),
  modul('m2', 'array-lanjut', 'array', 2),
  modul('m3', 'struct-dasar', 'struct', 3),
  modul('m4', 'pointer-dasar', 'pointer', 4),
];

function denganProgres(progres: Record<string, Partial<ReturnType<typeof progresModulKosong>>>): ProgresGlobal {
  const p = progresKosong();
  for (const [id, partial] of Object.entries(progres)) {
    p.modul[id] = { ...progresModulKosong(id), ...partial };
  }
  return p;
}

/* =========================================================
   Rekomendasi
   ========================================================= */

describe('hitungRekomendasi', () => {
  it('menyarankan modul pertama untuk pengguna baru', () => {
    const r = hitungRekomendasi(MODUL, progresKosong());

    expect(r?.modulSlug).toBe('array-dasar');
    expect(r?.tahap).toBe(1);
    expect(r?.jenis).toBe('mulai');
  });

  it('alasan menyebutkan estimasi menit', () => {
    const r = hitungRekomendasi(MODUL, progresKosong());
    expect(r?.alasan).toMatch(/12 menit/);
  });

  it('PRIORITAS 1: modul tahap 1 selesai, tahap 2 belum', () => {
    const p = denganProgres({
      m2: { tahap1Selesai: true },
    });

    const r = hitungRekomendasi(MODUL, p);

    // m2 sedang dikerjakan — harus direkomendasikan walau m1 belum dimulai
    expect(r?.modulSlug).toBe('array-lanjut');
    expect(r?.tahap).toBe(2);
    expect(r?.jenis).toBe('lanjutkan');
  });

  it('PRIORITAS 2: modul tahap 2 selesai, tahap 3 belum', () => {
    const p = denganProgres({
      m1: { tahap1Selesai: true, tahap2Selesai: true },
    });

    const r = hitungRekomendasi(MODUL, p);

    expect(r?.modulSlug).toBe('array-dasar');
    expect(r?.tahap).toBe(3);
  });

  it('PRIORITAS 1 lebih diutamakan dari PRIORITAS 2', () => {
    const p = denganProgres({
      m1: { tahap1Selesai: true, tahap2Selesai: true }, // prioritas 2
      m3: { tahap1Selesai: true }, // prioritas 1
    });

    const r = hitungRekomendasi(MODUL, p);

    expect(r?.modulSlug).toBe('struct-dasar');
    expect(r?.tahap).toBe(2);
  });

  it('alasan selalu ada dan menjelaskan', () => {
    const kasus = [
      progresKosong(),
      denganProgres({ m1: { tahap1Selesai: true } }),
      denganProgres({ m1: { tahap1Selesai: true, tahap2Selesai: true } }),
    ];

    for (const p of kasus) {
      const r = hitungRekomendasi(MODUL, p);
      expect(r?.alasan.length).toBeGreaterThan(20);
    }
  });

  it('null jika semua modul tuntas', () => {
    const p = denganProgres({
      m1: { tahap1Selesai: true, tahap2Selesai: true, tahap3Selesai: true },
      m2: { tahap1Selesai: true, tahap2Selesai: true, tahap3Selesai: true },
      m3: { tahap1Selesai: true, tahap2Selesai: true, tahap3Selesai: true },
      m4: { tahap1Selesai: true, tahap2Selesai: true, tahap3Selesai: true },
    });

    expect(hitungRekomendasi(MODUL, p)).toBeNull();
  });

  it('null untuk daftar modul kosong', () => {
    expect(hitungRekomendasi([], progresKosong())).toBeNull();
  });

  it('mengikuti urutan kurikulum, bukan urutan array', () => {
    const terbalik = [...MODUL].reverse();
    const r = hitungRekomendasi(terbalik, progresKosong());

    // Harus tetap modul urutan 1
    expect(r?.modulSlug).toBe('array-dasar');
  });
});

/* =========================================================
   Pengurutan
   ========================================================= */

describe('urutkanModulUntukDashboard', () => {
  it('modul sedang dikerjakan muncul paling atas', () => {
    const p = denganProgres({
      m3: { tahap1Selesai: true },
    });

    const hasil = urutkanModulUntukDashboard(MODUL, p);

    expect(hasil[0]?.id).toBe('m3');
  });

  it('modul belum dimulai di tengah', () => {
    const p = denganProgres({
      m1: { tahap1Selesai: true, tahap2Selesai: true, tahap3Selesai: true },
    });

    const hasil = urutkanModulUntukDashboard(MODUL, p);

    // m1 selesai harus di bawah yang belum dimulai
    const posisiM1 = hasil.findIndex((m) => m.id === 'm1');
    const posisiM2 = hasil.findIndex((m) => m.id === 'm2');
    expect(posisiM2).toBeLessThan(posisiM1);
  });

  it('dalam kelompok yang sama, urut sesuai kurikulum', () => {
    const hasil = urutkanModulUntukDashboard(MODUL, progresKosong());
    expect(hasil.map((m) => m.id)).toEqual(['m1', 'm2', 'm3', 'm4']);
  });

  it('tidak mengubah array asli', () => {
    const salinan = MODUL.map((m) => m.id);
    urutkanModulUntukDashboard(MODUL, progresKosong());
    expect(MODUL.map((m) => m.id)).toEqual(salinan);
  });
});

/* =========================================================
   Progres per topik
   ========================================================= */

describe('hitungProgresPerTopik', () => {
  it('menghitung total dan selesai per topik', () => {
    const p = denganProgres({
      m1: { tahap1Selesai: true, tahap2Selesai: true, tahap3Selesai: true },
    });

    const hasil = hitungProgresPerTopik(MODUL, p);

    const array = hasil.find((h) => h.topik === 'array');
    const struct = hasil.find((h) => h.topik === 'struct');

    expect(array?.total).toBe(2);
    expect(array?.selesai).toBe(1);
    expect(array?.persen).toBe(50);
    expect(struct?.total).toBe(1);
    expect(struct?.selesai).toBe(0);
  });

  it('mengurutkan sesuai urutan kurikulum: array, struct, pointer', () => {
    const hasil = hitungProgresPerTopik(MODUL, progresKosong());
    expect(hasil.map((h) => h.topik)).toEqual(['array', 'struct', 'pointer']);
  });

  it('hanya modul TUNTAS yang dihitung selesai', () => {
    const p = denganProgres({
      m1: { tahap1Selesai: true }, // baru tahap 1
    });

    const hasil = hitungProgresPerTopik(MODUL, p);
    const array = hasil.find((h) => h.topik === 'array');

    expect(array?.selesai).toBe(0);
  });

  it('kosong untuk daftar modul kosong', () => {
    expect(hitungProgresPerTopik([], progresKosong())).toEqual([]);
  });
});

/* =========================================================
   Modul terlemah
   ========================================================= */

describe('cariModulTerlemah', () => {
  it('null jika belum ada riwayat quiz', () => {
    expect(cariModulTerlemah(MODUL, progresKosong())).toBeNull();
  });

  it('mengembalikan modul dengan akurasi terendah', () => {
    const p = denganProgres({
      m1: { riwayatQuiz: [{ waktu: 1, skor: 90, jumlahBenar: 9, jumlahSoal: 10 }] },
      m3: { riwayatQuiz: [{ waktu: 2, skor: 40, jumlahBenar: 4, jumlahSoal: 10 }] },
    });

    const hasil = cariModulTerlemah(MODUL, p);

    expect(hasil?.slug).toBe('struct-dasar');
    expect(hasil?.akurasi).toBe(40);
  });

  it('menghitung rata-rata dari beberapa percobaan', () => {
    const p = denganProgres({
      m1: {
        riwayatQuiz: [
          { waktu: 1, skor: 100, jumlahBenar: 10, jumlahSoal: 10 },
          { waktu: 2, skor: 50, jumlahBenar: 5, jumlahSoal: 10 },
        ],
      },
    });

    expect(cariModulTerlemah(MODUL, p)?.akurasi).toBe(75);
  });

  it('mengabaikan modul tanpa riwayat quiz', () => {
    const p = denganProgres({
      m1: { tahap1Selesai: true },
      m2: { riwayatQuiz: [{ waktu: 1, skor: 80, jumlahBenar: 8, jumlahSoal: 10 }] },
    });

    expect(cariModulTerlemah(MODUL, p)?.slug).toBe('array-lanjut');
  });
});
