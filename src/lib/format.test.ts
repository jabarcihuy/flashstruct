import { describe, it, expect } from 'vitest';
import { durasi, kunciTanggal, persen, selisihHari, urutkan, acak } from './format';

describe('persen', () => {
  it('membulatkan ke bilangan bulat', () => {
    expect(persen(82.4)).toBe('82%');
    expect(persen(82.6)).toBe('83%');
    expect(persen(0)).toBe('0%');
    expect(persen(100)).toBe('100%');
  });
});

describe('durasi', () => {
  it('memformat di bawah satu jam sebagai M:SS', () => {
    expect(durasi(480)).toBe('8:00');
    expect(durasi(65)).toBe('1:05');
    expect(durasi(5)).toBe('0:05');
  });

  it('memformat satu jam atau lebih sebagai H:MM:SS', () => {
    expect(durasi(3600)).toBe('1:00:00');
    expect(durasi(3930)).toBe('1:05:30');
  });
});

describe('selisihHari', () => {
  it('menghitung selisih hari dan selalu positif', () => {
    const satuHari = 24 * 60 * 60 * 1000;
    expect(selisihHari(0, satuHari)).toBe(1);
    expect(selisihHari(satuHari, 0)).toBe(1);
    expect(selisihHari(0, satuHari * 7)).toBe(7);
  });
});

describe('kunciTanggal', () => {
  it('menghasilkan format YYYY-MM-DD dengan padding', () => {
    const d = new Date(2026, 0, 5); // 5 Januari 2026
    expect(kunciTanggal(d.getTime())).toBe('2026-01-05');
  });
});

describe('urutkan', () => {
  it('mengurutkan berdasarkan kolom urutan', () => {
    const input = [{ urutan: 3 }, { urutan: 1 }, { urutan: 2 }];
    expect(urutkan(input).map((x) => x.urutan)).toEqual([1, 2, 3]);
  });

  it('tidak mengubah array asli', () => {
    const input = [{ urutan: 2 }, { urutan: 1 }];
    const salinan = [...input];
    urutkan(input);
    expect(input).toEqual(salinan);
  });

  it('menangani null dan undefined dengan aman', () => {
    expect(urutkan(null)).toEqual([]);
    expect(urutkan(undefined)).toEqual([]);
  });
});

describe('acak', () => {
  it('mempertahankan semua elemen', () => {
    const input = [1, 2, 3, 4, 5];
    expect(acak(input).slice().sort()).toEqual([1, 2, 3, 4, 5]);
  });

  it('tidak mengubah array asli', () => {
    const input = [1, 2, 3, 4, 5];
    const salinan = [...input];
    acak(input);
    expect(input).toEqual(salinan);
  });
});
