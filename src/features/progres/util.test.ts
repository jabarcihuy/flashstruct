import { describe, it, expect } from 'vitest';
import {
  hitungStreak,
  hitungKartuDikuasai,
  hitungAkurasiQuiz,
  hitungModulSelesai,
  hitungStatistik,
  hitungStatistikModul,
  modulTerlemah,
  kunciTanggal,
} from './util';
import { progresKosong, progresModulKosong, type ProgresGlobal, type StatusKartu } from './schema';

/** Tanggal tetap untuk uji deterministik: 15 Juni 2026 */
const SEKARANG = new Date(2026, 5, 15, 10, 0, 0).getTime();

function kartu(ingat: number, lupa: number): StatusKartu {
  return { kartuId: 'k', jumlahIngat: ingat, jumlahLupa: lupa, terakhirDilihat: SEKARANG };
}

describe('kunciTanggal', () => {
  it('menghasilkan format YYYY-MM-DD dengan padding', () => {
    expect(kunciTanggal(new Date(2026, 0, 5).getTime())).toBe('2026-01-05');
    expect(kunciTanggal(new Date(2026, 11, 31).getTime())).toBe('2026-12-31');
  });
});

describe('hitungStreak', () => {
  it('0 untuk tanpa aktivitas', () => {
    expect(hitungStreak([], SEKARANG)).toBe(0);
  });

  it('1 jika hanya aktif hari ini', () => {
    expect(hitungStreak(['2026-06-15'], SEKARANG)).toBe(1);
  });

  it('3 untuk tiga hari berturut-turut sampai hari ini', () => {
    expect(hitungStreak(['2026-06-13', '2026-06-14', '2026-06-15'], SEKARANG)).toBe(3);
  });

  it('tetap menghitung walau hari ini belum aktif (mulai dari kemarin)', () => {
    expect(hitungStreak(['2026-06-13', '2026-06-14'], SEKARANG)).toBe(2);
  });

  it('0 jika kemarin dan hari ini sama-sama tidak aktif', () => {
    expect(hitungStreak(['2026-06-10', '2026-06-11'], SEKARANG)).toBe(0);
  });

  it('berhenti di celah pertama', () => {
    // Aktif 15, 14, lalu bolong 13, aktif lagi 12
    expect(hitungStreak(['2026-06-12', '2026-06-14', '2026-06-15'], SEKARANG)).toBe(2);
  });

  it('menangani pergantian bulan', () => {
    const akhirBulan = new Date(2026, 5, 1).getTime(); // 1 Juni 2026
    expect(hitungStreak(['2026-05-30', '2026-05-31', '2026-06-01'], akhirBulan)).toBe(3);
  });

  it('menangani pergantian tahun', () => {
    const awalTahun = new Date(2026, 0, 1).getTime(); // 1 Januari 2026
    expect(hitungStreak(['2025-12-31', '2026-01-01'], awalTahun)).toBe(2);
  });
});

describe('hitungKartuDikuasai', () => {
  it('0 untuk progres kosong', () => {
    expect(hitungKartuDikuasai(progresKosong())).toBe(0);
  });

  it('menghitung kartu yang pernah ingat dan tidak pernah lupa', () => {
    const p: ProgresGlobal = {
      ...progresKosong(),
      modul: {
        m1: {
          ...progresModulKosong('m1'),
          kartu: { k1: kartu(1, 0), k2: kartu(3, 0) },
        },
      },
    };
    expect(hitungKartuDikuasai(p)).toBe(2);
  });

  it('TIDAK menghitung kartu yang pernah lupa', () => {
    const p: ProgresGlobal = {
      ...progresKosong(),
      modul: {
        m1: {
          ...progresModulKosong('m1'),
          kartu: { k1: kartu(5, 1) },
        },
      },
    };
    expect(hitungKartuDikuasai(p)).toBe(0);
  });

  it('tidak menghitung kartu yang belum pernah ingat', () => {
    const p: ProgresGlobal = {
      ...progresKosong(),
      modul: { m1: { ...progresModulKosong('m1'), kartu: { k1: kartu(0, 0) } } },
    };
    expect(hitungKartuDikuasai(p)).toBe(0);
  });
});

describe('hitungAkurasiQuiz', () => {
  it('0 tanpa riwayat', () => {
    expect(hitungAkurasiQuiz(progresKosong())).toBe(0);
  });

  it('menghitung rata-rata skor', () => {
    const p: ProgresGlobal = {
      ...progresKosong(),
      modul: {
        m1: {
          ...progresModulKosong('m1'),
          riwayatQuiz: [
            { waktu: 1, skor: 80, jumlahBenar: 8, jumlahSoal: 10 },
            { waktu: 2, skor: 60, jumlahBenar: 6, jumlahSoal: 10 },
          ],
        },
      },
    };
    expect(hitungAkurasiQuiz(p)).toBe(70);
  });

  it('menggabungkan riwayat dari beberapa modul', () => {
    const p: ProgresGlobal = {
      ...progresKosong(),
      modul: {
        m1: {
          ...progresModulKosong('m1'),
          riwayatQuiz: [{ waktu: 1, skor: 100, jumlahBenar: 10, jumlahSoal: 10 }],
        },
        m2: {
          ...progresModulKosong('m2'),
          riwayatQuiz: [{ waktu: 2, skor: 50, jumlahBenar: 5, jumlahSoal: 10 }],
        },
      },
    };
    expect(hitungAkurasiQuiz(p)).toBe(75);
  });
});

describe('hitungModulSelesai', () => {
  it('0 untuk progres kosong', () => {
    expect(hitungModulSelesai(progresKosong())).toBe(0);
  });

  it('hanya menghitung modul dengan KETIGA tahap selesai', () => {
    const p: ProgresGlobal = {
      ...progresKosong(),
      modul: {
        m1: {
          ...progresModulKosong('m1'),
          tahap1Selesai: true,
          tahap2Selesai: true,
          tahap3Selesai: true,
        },
        m2: { ...progresModulKosong('m2'), tahap1Selesai: true },
      },
    };
    expect(hitungModulSelesai(p)).toBe(1);
  });
});

describe('hitungStatistik', () => {
  it('mengembalikan semua statistik nol untuk pengguna baru', () => {
    const s = hitungStatistik(progresKosong(), SEKARANG);
    expect(s).toEqual({ modulSelesai: 0, kartuDikuasai: 0, akurasiQuiz: 0, streak: 0 });
  });

  it('menghitung semua statistik sekaligus', () => {
    const p: ProgresGlobal = {
      ...progresKosong(),
      hariAktif: ['2026-06-14', '2026-06-15'],
      modul: {
        m1: {
          ...progresModulKosong('m1'),
          tahap1Selesai: true,
          tahap2Selesai: true,
          tahap3Selesai: true,
          kartu: { k1: kartu(2, 0) },
          riwayatQuiz: [{ waktu: 1, skor: 90, jumlahBenar: 9, jumlahSoal: 10 }],
        },
      },
    };
    const s = hitungStatistik(p, SEKARANG);
    expect(s.modulSelesai).toBe(1);
    expect(s.kartuDikuasai).toBe(1);
    expect(s.akurasiQuiz).toBe(90);
    expect(s.streak).toBe(2);
  });
});

describe('hitungStatistikModul', () => {
  it('semua nol untuk modul tanpa progres', () => {
    expect(hitungStatistikModul(undefined)).toEqual({
      kartuDikuasai: 0,
      kartuTotal: 0,
      akurasiQuiz: 0,
      jumlahPercobaan: 0,
    });
  });

  it('menghitung statistik satu modul', () => {
    const m = {
      ...progresModulKosong('m1'),
      kartu: { k1: kartu(1, 0), k2: kartu(2, 1), k3: kartu(0, 0) },
      riwayatQuiz: [
        { waktu: 1, skor: 80, jumlahBenar: 8, jumlahSoal: 10 },
        { waktu: 2, skor: 60, jumlahBenar: 6, jumlahSoal: 10 },
      ],
    };
    const s = hitungStatistikModul(m);
    expect(s.kartuDikuasai).toBe(1);
    expect(s.kartuTotal).toBe(3);
    expect(s.akurasiQuiz).toBe(70);
    expect(s.jumlahPercobaan).toBe(2);
  });
});

describe('modulTerlemah', () => {
  const info = new Map([
    ['m1', { slug: 'array-dasar', judul: 'Array Dasar' }],
    ['m2', { slug: 'pointer-dasar', judul: 'Pointer Dasar' }],
  ]);

  it('null jika tidak ada riwayat quiz', () => {
    expect(modulTerlemah(progresKosong(), info)).toBeNull();
  });

  it('mengembalikan modul dengan akurasi terendah', () => {
    const p: ProgresGlobal = {
      ...progresKosong(),
      modul: {
        m1: {
          ...progresModulKosong('m1'),
          riwayatQuiz: [{ waktu: 1, skor: 90, jumlahBenar: 9, jumlahSoal: 10 }],
        },
        m2: {
          ...progresModulKosong('m2'),
          riwayatQuiz: [{ waktu: 2, skor: 40, jumlahBenar: 4, jumlahSoal: 10 }],
        },
      },
    };
    const hasil = modulTerlemah(p, info);
    expect(hasil?.slug).toBe('pointer-dasar');
    expect(hasil?.akurasi).toBe(40);
  });

  it('mengabaikan modul yang tidak ada di info', () => {
    const p: ProgresGlobal = {
      ...progresKosong(),
      modul: {
        m99: {
          ...progresModulKosong('m99'),
          riwayatQuiz: [{ waktu: 1, skor: 10, jumlahBenar: 1, jumlahSoal: 10 }],
        },
      },
    };
    expect(modulTerlemah(p, info)).toBeNull();
  });
});
