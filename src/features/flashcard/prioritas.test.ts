import { describe, it, expect } from 'vitest';
import { hitungPrioritas, susunDeck, alasanPrioritas, hitungKomposisi } from './prioritas';
import type { KartuDenganModul } from '@/types/database';
import type { StatusKartu } from '@/features/progres/schema';

/** Tanggal tetap untuk uji deterministik */
const SEKARANG = new Date(2026, 5, 15, 10, 0, 0).getTime();
const HARI = 24 * 60 * 60 * 1000;

function kartu(id: string): KartuDenganModul {
  return {
    id,
    modul_id: 'm1',
    depan: `Depan ${id}`,
    belakang: `Belakang ${id}`,
    card_type: 'ISTILAH',
    kode: null,
    bahasa_kode: null,
    urutan: 1,
    modul: { slug: 'array-dasar', judul: 'Array', topik: 'array' },
  };
}

function status(partial: Partial<StatusKartu>): StatusKartu {
  return {
    kartuId: 'k',
    jumlahIngat: 0,
    jumlahLupa: 0,
    terakhirDilihat: SEKARANG,
    ...partial,
  };
}

describe('hitungPrioritas', () => {
  it('kartu belum pernah dilihat mendapat prioritas tinggi', () => {
    const skor = hitungPrioritas(undefined, SEKARANG);
    expect(skor).toBe(300);
  });

  it('kartu dengan terakhirDilihat 0 dianggap belum pernah', () => {
    const skor = hitungPrioritas(status({ terakhirDilihat: 0 }), SEKARANG);
    expect(skor).toBe(300);
  });

  it('kartu yang pernah lupa mendapat prioritas TERTINGGI', () => {
    const lupa = hitungPrioritas(status({ jumlahLupa: 1 }), SEKARANG);
    const belum = hitungPrioritas(undefined, SEKARANG);

    expect(lupa).toBeGreaterThan(belum);
  });

  it('semakin sering lupa, semakin tinggi prioritas', () => {
    const sekali = hitungPrioritas(status({ jumlahLupa: 1 }), SEKARANG);
    const lima = hitungPrioritas(status({ jumlahLupa: 5 }), SEKARANG);

    expect(lima).toBeGreaterThan(sekali);
  });

  it('kartu yang lama tidak dilihat lebih tinggi dari yang baru', () => {
    const lama = hitungPrioritas(
      status({ jumlahIngat: 3, terakhirDilihat: SEKARANG - 5 * HARI }),
      SEKARANG,
    );
    const baru = hitungPrioritas(
      status({ jumlahIngat: 3, terakhirDilihat: SEKARANG - 1000 }),
      SEKARANG,
    );

    expect(lama).toBeGreaterThan(baru);
  });

  it('kartu yang baru diingat mendapat prioritas TERENDAH', () => {
    const baruIngat = hitungPrioritas(
      status({ jumlahIngat: 1, terakhirDilihat: SEKARANG }),
      SEKARANG,
    );
    const belum = hitungPrioritas(undefined, SEKARANG);
    const lama = hitungPrioritas(
      status({ jumlahIngat: 1, terakhirDilihat: SEKARANG - 3 * HARI }),
      SEKARANG,
    );

    expect(baruIngat).toBeLessThan(belum);
    expect(baruIngat).toBeLessThan(lama);
  });

  it('prioritas lupa selalu di atas kategori lain walau lupa 100x', () => {
    const lupaBanyak = hitungPrioritas(status({ jumlahLupa: 100 }), SEKARANG);
    const belum = hitungPrioritas(undefined, SEKARANG);

    // Kategori lupa dibatasi 99 di atas 400 = maks 499
    expect(lupaBanyak).toBeLessThan(500);
    expect(lupaBanyak).toBeGreaterThan(belum);
  });
});

describe('susunDeck', () => {
  it('menyusun kartu lupa paling awal', () => {
    const kartuList = [kartu('a'), kartu('b'), kartu('c')];
    const statusKartu = {
      a: status({ jumlahIngat: 5, terakhirDilihat: SEKARANG }),
      b: status({ jumlahLupa: 3, terakhirDilihat: SEKARANG }),
      c: status({ jumlahIngat: 1, terakhirDilihat: SEKARANG - 5 * HARI }),
    };

    const deck = susunDeck(kartuList, statusKartu, SEKARANG);

    // b (lupa) harus paling awal
    expect(deck[0]?.id).toBe('b');
  });

  it('kartu belum pernah dilihat muncul sebelum yang sudah dikuasai', () => {
    const kartuList = [kartu('a'), kartu('b')];
    const statusKartu = {
      a: status({ jumlahIngat: 10, terakhirDilihat: SEKARANG }),
      // b tidak ada status = belum pernah
    };

    const deck = susunDeck(kartuList, statusKartu, SEKARANG);

    expect(deck[0]?.id).toBe('b');
  });

  it('membatasi jumlah kartu sesuai MAKS_KARTU_PER_SESI', () => {
    const kartuList = Array.from({ length: 30 }, (_, i) => kartu(`k${i}`));
    const deck = susunDeck(kartuList, {}, SEKARANG);

    expect(deck).toHaveLength(20);
  });

  it('mempertahankan semua kartu jika kurang dari batas', () => {
    const kartuList = [kartu('a'), kartu('b'), kartu('c')];
    const deck = susunDeck(kartuList, {}, SEKARANG);

    expect(deck).toHaveLength(3);
  });

  it('tidak mengubah array asli', () => {
    const kartuList = [kartu('a'), kartu('b')];
    const salinan = [...kartuList];

    susunDeck(kartuList, {}, SEKARANG);

    expect(kartuList).toEqual(salinan);
  });

  it('menangani deck kosong', () => {
    expect(susunDeck([], {}, SEKARANG)).toEqual([]);
  });
});

describe('alasanPrioritas', () => {
  it('menjelaskan kartu yang belum pernah dilihat', () => {
    expect(alasanPrioritas(undefined, SEKARANG)).toMatch(/belum pernah/i);
  });

  it('menyebutkan berapa kali ditandai lupa', () => {
    const alasan = alasanPrioritas(status({ jumlahLupa: 3 }), SEKARANG);
    expect(alasan).toMatch(/lupa 3x/i);
  });

  it('menyebutkan berapa hari sejak terakhir dilihat', () => {
    const alasan = alasanPrioritas(
      status({ jumlahIngat: 2, terakhirDilihat: SEKARANG - 4 * HARI }),
      SEKARANG,
    );
    expect(alasan).toMatch(/4 hari/i);
  });

  it('menandai kartu yang sudah dikuasai', () => {
    const alasan = alasanPrioritas(
      status({ jumlahIngat: 5, terakhirDilihat: SEKARANG }),
      SEKARANG,
    );
    expect(alasan).toMatch(/kuasai/i);
  });
});

describe('hitungKomposisi', () => {
  it('menghitung semua kategori dengan benar', () => {
    const kartuList = [kartu('a'), kartu('b'), kartu('c'), kartu('d')];
    const statusKartu = {
      b: status({ jumlahLupa: 1 }),
      c: status({ jumlahIngat: 1, terakhirDilihat: SEKARANG - 3 * HARI }),
      d: status({ jumlahIngat: 1, terakhirDilihat: SEKARANG }),
      // a tidak ada = belum pernah
    };

    const komposisi = hitungKomposisi(kartuList, statusKartu, SEKARANG);

    expect(komposisi.total).toBe(4);
    expect(komposisi.belumPernah).toBe(1);
    expect(komposisi.seringLupa).toBe(1);
    expect(komposisi.perluDiulang).toBe(1);
    expect(komposisi.sudahDikuasai).toBe(1);
  });

  it('semua nol untuk deck kosong', () => {
    const komposisi = hitungKomposisi([], {}, SEKARANG);
    expect(komposisi.total).toBe(0);
    expect(komposisi.belumPernah).toBe(0);
  });
});
