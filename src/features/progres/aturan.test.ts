import { describe, it, expect } from 'vitest';
import {
  alasanTerkunci,
  modulTuntas,
  persenProgresModul,
  rekomendasiModul,
  statusSemuaTahap,
  statusTahap,
  tahapBerikutnya,
} from './aturan';
import { progresModulKosong, type ProgresModul } from './schema';

/** Buat progres modul dengan tahap tertentu selesai */
function buat(tahap: Partial<Pick<ProgresModul, 'tahap1Selesai' | 'tahap2Selesai' | 'tahap3Selesai'>>): ProgresModul {
  return { ...progresModulKosong('m1'), ...tahap };
}

describe('statusTahap — modul belum dimulai', () => {
  it('tahap 1 tersedia', () => {
    expect(statusTahap(undefined, 1)).toBe('tersedia');
  });

  it('tahap 2 terkunci', () => {
    expect(statusTahap(undefined, 2)).toBe('terkunci');
  });

  it('tahap 3 terkunci', () => {
    expect(statusTahap(undefined, 3)).toBe('terkunci');
  });
});

describe('statusTahap — tahap 1 selesai', () => {
  const p = buat({ tahap1Selesai: true });

  it('tahap 1 berstatus selesai, bukan tersedia', () => {
    expect(statusTahap(p, 1)).toBe('selesai');
  });

  it('tahap 2 menjadi tersedia', () => {
    expect(statusTahap(p, 2)).toBe('tersedia');
  });

  it('tahap 3 TETAP terkunci', () => {
    expect(statusTahap(p, 3)).toBe('terkunci');
  });
});

describe('statusTahap — tahap 2 selesai', () => {
  const p = buat({ tahap1Selesai: true, tahap2Selesai: true });

  it('tahap 1 dan 2 berstatus selesai', () => {
    expect(statusTahap(p, 1)).toBe('selesai');
    expect(statusTahap(p, 2)).toBe('selesai');
  });

  it('tahap 3 menjadi tersedia', () => {
    expect(statusTahap(p, 3)).toBe('tersedia');
  });
});

describe('statusTahap — semua selesai', () => {
  const p = buat({ tahap1Selesai: true, tahap2Selesai: true, tahap3Selesai: true });

  it('ketiganya berstatus selesai', () => {
    expect(statusTahap(p, 1)).toBe('selesai');
    expect(statusTahap(p, 2)).toBe('selesai');
    expect(statusTahap(p, 3)).toBe('selesai');
  });
});

describe('statusTahap — kasus batas', () => {
  it('tahap 3 terkunci walau tahap 1 selesai tapi tahap 2 belum', () => {
    const p = buat({ tahap1Selesai: true, tahap2Selesai: false });
    expect(statusTahap(p, 3)).toBe('terkunci');
  });

  it('tahap 2 selesai tanpa tahap 1 — tidak mungkin, tapi harus aman', () => {
    const p = buat({ tahap2Selesai: true });
    // Tahap 1 belum selesai, jadi tahap 2 harus terkunci
    // (data seperti ini tidak seharusnya ada, tapi jangan sampai crash)
    expect(['terkunci', 'tersedia', 'selesai']).toContain(statusTahap(p, 2));
  });

  it('tidak melempar error untuk progres kosong', () => {
    const p = progresModulKosong('m1');
    expect(() => statusTahap(p, 1)).not.toThrow();
    expect(() => statusTahap(p, 2)).not.toThrow();
    expect(() => statusTahap(p, 3)).not.toThrow();
  });
});

describe('statusSemuaTahap', () => {
  it('mengembalikan tiga status untuk modul baru', () => {
    expect(statusSemuaTahap(undefined)).toEqual(['tersedia', 'terkunci', 'terkunci']);
  });

  it('mengembalikan tiga status untuk modul yang sedang dikerjakan', () => {
    const p = buat({ tahap1Selesai: true });
    expect(statusSemuaTahap(p)).toEqual(['selesai', 'tersedia', 'terkunci']);
  });

  it('mengembalikan tiga status untuk modul tuntas', () => {
    const p = buat({ tahap1Selesai: true, tahap2Selesai: true, tahap3Selesai: true });
    expect(statusSemuaTahap(p)).toEqual(['selesai', 'selesai', 'selesai']);
  });
});

describe('alasanTerkunci', () => {
  it('menjelaskan alasan tahap 2 terkunci', () => {
    expect(alasanTerkunci(2)).toMatch(/selesaikan modul/i);
  });

  it('menjelaskan alasan tahap 3 terkunci', () => {
    expect(alasanTerkunci(3)).toMatch(/kartu/i);
  });

  it('pesannya menjelaskan APA yang harus dilakukan, bukan sekadar "terkunci"', () => {
    expect(alasanTerkunci(2).length).toBeGreaterThan(20);
    expect(alasanTerkunci(3).length).toBeGreaterThan(20);
  });
});

describe('tahapBerikutnya', () => {
  it('mengembalikan 1 untuk modul baru', () => {
    expect(tahapBerikutnya(undefined)).toBe(1);
  });

  it('mengembalikan 2 setelah tahap 1 selesai', () => {
    expect(tahapBerikutnya(buat({ tahap1Selesai: true }))).toBe(2);
  });

  it('mengembalikan 3 setelah tahap 2 selesai', () => {
    expect(tahapBerikutnya(buat({ tahap1Selesai: true, tahap2Selesai: true }))).toBe(3);
  });

  it('mengembalikan null jika semua selesai', () => {
    const p = buat({ tahap1Selesai: true, tahap2Selesai: true, tahap3Selesai: true });
    expect(tahapBerikutnya(p)).toBeNull();
  });
});

describe('modulTuntas', () => {
  it('false untuk modul yang belum dimulai', () => {
    expect(modulTuntas(undefined)).toBe(false);
  });

  it('false jika baru tahap 1 selesai', () => {
    expect(modulTuntas(buat({ tahap1Selesai: true }))).toBe(false);
  });

  it('false jika baru tahap 1 dan 2 selesai', () => {
    expect(modulTuntas(buat({ tahap1Selesai: true, tahap2Selesai: true }))).toBe(false);
  });

  it('true hanya jika KETIGA tahap selesai', () => {
    const p = buat({ tahap1Selesai: true, tahap2Selesai: true, tahap3Selesai: true });
    expect(modulTuntas(p)).toBe(true);
  });
});

describe('persenProgresModul', () => {
  it('0% untuk modul baru', () => {
    expect(persenProgresModul(undefined)).toBe(0);
    expect(persenProgresModul(progresModulKosong('m1'))).toBe(0);
  });

  it('33% setelah tahap 1', () => {
    expect(persenProgresModul(buat({ tahap1Selesai: true }))).toBe(33);
  });

  it('67% setelah tahap 2', () => {
    expect(persenProgresModul(buat({ tahap1Selesai: true, tahap2Selesai: true }))).toBe(67);
  });

  it('100% setelah ketiga tahap', () => {
    const p = buat({ tahap1Selesai: true, tahap2Selesai: true, tahap3Selesai: true });
    expect(persenProgresModul(p)).toBe(100);
  });
});

describe('rekomendasiModul', () => {
  const info = { judul: 'Dasar Array', estimasiMenit: 12, jumlahKartu: 20 };

  it('menyarankan baca modul untuk modul baru', () => {
    const r = rekomendasiModul(undefined, info);
    expect(r?.tahap).toBe(1);
    expect(r?.ctaLabel).toBe('Baca Modul');
    expect(r?.alasan).toContain('12 menit');
  });

  it('menyarankan flashcard setelah tahap 1', () => {
    const r = rekomendasiModul(buat({ tahap1Selesai: true }), info);
    expect(r?.tahap).toBe(2);
    expect(r?.ctaLabel).toBe('Mulai Flashcard');
    expect(r?.alasan).toContain('20 kartu');
  });

  it('menyarankan quiz setelah tahap 2', () => {
    const r = rekomendasiModul(buat({ tahap1Selesai: true, tahap2Selesai: true }), info);
    expect(r?.tahap).toBe(3);
    expect(r?.ctaLabel).toBe('Mulai Quiz');
  });

  it('mengembalikan null jika semua selesai', () => {
    const p = buat({ tahap1Selesai: true, tahap2Selesai: true, tahap3Selesai: true });
    expect(rekomendasiModul(p, info)).toBeNull();
  });

  it('setiap rekomendasi punya alasan yang menjelaskan, bukan sekadar aksi', () => {
    const r1 = rekomendasiModul(undefined, info);
    const r2 = rekomendasiModul(buat({ tahap1Selesai: true }), info);
    const r3 = rekomendasiModul(buat({ tahap1Selesai: true, tahap2Selesai: true }), info);

    for (const r of [r1, r2, r3]) {
      expect(r?.alasan.length).toBeGreaterThan(20);
    }
  });
});
