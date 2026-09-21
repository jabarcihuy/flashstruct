import { describe, it, expect, beforeEach, vi, afterEach } from 'vitest';
import {
  bacaProgres,
  tulisProgres,
  hapusProgres,
  pastikanProgresModul,
  catatHariAktif,
  bacaBerkasImpor,
  buatBerkasEkspor,
} from './store';
import { progresKosong, progresModulKosong, VERSI_PROGRES } from './schema';
import { KUNCI_PROGRES } from '@/lib/constants';

beforeEach(() => {
  localStorage.clear();
});

afterEach(() => {
  vi.restoreAllMocks();
});

describe('bacaProgres', () => {
  it('mengembalikan progres kosong saat belum ada data', () => {
    const p = bacaProgres();
    expect(p.versi).toBe(VERSI_PROGRES);
    expect(p.modul).toEqual({});
    expect(p.hariAktif).toEqual([]);
  });

  it('membaca progres yang tersimpan', () => {
    const asli = progresKosong();
    tulisProgres(asli);
    const dibaca = bacaProgres();
    expect(dibaca.versi).toBe(VERSI_PROGRES);
  });

  it('TIDAK crash saat JSON rusak', () => {
    localStorage.setItem(KUNCI_PROGRES, 'ini bukan json{{{');
    expect(() => bacaProgres()).not.toThrow();
    expect(bacaProgres().modul).toEqual({});
  });

  it('menyimpan salinan data rusak untuk diagnosis', () => {
    localStorage.setItem(KUNCI_PROGRES, 'ini bukan json{{{');
    bacaProgres();

    const salinan = Object.keys(localStorage).filter((k) =>
      k.startsWith(`${KUNCI_PROGRES}:rusak:`),
    );
    expect(salinan.length).toBe(1);
  });

  it('TIDAK crash saat skema tidak cocok', () => {
    localStorage.setItem(KUNCI_PROGRES, JSON.stringify({ versi: 999, aneh: true }));
    expect(() => bacaProgres()).not.toThrow();
    expect(bacaProgres().modul).toEqual({});
  });

  it('menolak versi yang tidak dikenal', () => {
    localStorage.setItem(
      KUNCI_PROGRES,
      JSON.stringify({ versi: 99, modul: {}, hariAktif: [], terakhirDiperbarui: 0 }),
    );
    expect(bacaProgres().versi).toBe(VERSI_PROGRES);
  });

  it('membatasi salinan data rusak maksimal 3', () => {
    for (let i = 0; i < 6; i++) {
      localStorage.setItem(KUNCI_PROGRES, `rusak-${i}`);
      bacaProgres();
    }

    const salinan = Object.keys(localStorage).filter((k) =>
      k.startsWith(`${KUNCI_PROGRES}:rusak:`),
    );
    expect(salinan.length).toBeLessThanOrEqual(3);
  });

  it('tetap berfungsi walau localStorage gagal dibaca', () => {
    vi.spyOn(Storage.prototype, 'getItem').mockImplementation(() => {
      throw new Error('storage diblokir');
    });
    expect(() => bacaProgres()).not.toThrow();
  });
});

describe('tulisProgres', () => {
  it('mengembalikan true saat berhasil', () => {
    expect(tulisProgres(progresKosong())).toBe(true);
  });

  it('memperbarui terakhirDiperbarui', () => {
    const p = { ...progresKosong(), terakhirDiperbarui: 0 };
    tulisProgres(p);
    expect(bacaProgres().terakhirDiperbarui).toBeGreaterThan(0);
  });

  it('mengembalikan false tanpa crash saat kuota penuh', () => {
    vi.spyOn(Storage.prototype, 'setItem').mockImplementation(() => {
      throw new Error('QuotaExceededError');
    });
    expect(() => tulisProgres(progresKosong())).not.toThrow();
  });
});

describe('hapusProgres', () => {
  it('menghapus progres', () => {
    tulisProgres(progresKosong());
    expect(hapusProgres()).toBe(true);
    expect(localStorage.getItem(KUNCI_PROGRES)).toBeNull();
  });
});

describe('pastikanProgresModul', () => {
  it('membuat progres modul baru jika belum ada', () => {
    const { progres, modul } = pastikanProgresModul(progresKosong(), 'm1');
    expect(modul.modulId).toBe('m1');
    expect(progres.modul['m1']).toBeDefined();
  });

  it('tidak menimpa progres modul yang sudah ada', () => {
    const awal = {
      ...progresKosong(),
      modul: { m1: { ...progresModulKosong('m1'), tahap1Selesai: true } },
    };
    const { modul } = pastikanProgresModul(awal, 'm1');
    expect(modul.tahap1Selesai).toBe(true);
  });

  it('tidak mengubah objek asli (immutable)', () => {
    const awal = progresKosong();
    pastikanProgresModul(awal, 'm1');
    expect(awal.modul['m1']).toBeUndefined();
  });
});

describe('catatHariAktif', () => {
  it('menambahkan hari ini jika belum ada', () => {
    const hasil = catatHariAktif(progresKosong());
    expect(hasil.hariAktif.length).toBe(1);
  });

  it('tidak menambahkan duplikat', () => {
    const sekali = catatHariAktif(progresKosong());
    const dua = catatHariAktif(sekali);
    expect(dua.hariAktif.length).toBe(1);
  });

  it('menyimpan dalam urutan terurut', () => {
    const awal = { ...progresKosong(), hariAktif: ['2026-01-01', '2026-01-03'] };
    const hasil = catatHariAktif(awal);
    const terurut = [...hasil.hariAktif].sort();
    expect(hasil.hariAktif).toEqual(terurut);
  });
});

describe('ekspor dan impor', () => {
  it('membuat berkas ekspor dengan pembungkus yang benar', () => {
    const berkas = buatBerkasEkspor(progresKosong());
    expect(berkas.jenis).toBe('flashstruct-progres');
    expect(berkas.versi).toBe(VERSI_PROGRES);
    expect(berkas.data.versi).toBe(VERSI_PROGRES);
  });

  it('menerima berkas ekspor yang valid', () => {
    const berkas = buatBerkasEkspor(progresKosong());
    const hasil = bacaBerkasImpor(JSON.stringify(berkas));
    expect(hasil.berhasil).toBe(true);
  });

  it('menolak berkas yang bukan JSON', () => {
    const hasil = bacaBerkasImpor('bukan json');
    expect(hasil.berhasil).toBe(false);
    if (!hasil.berhasil) expect(hasil.pesan).toMatch(/JSON/i);
  });

  it('menolak JSON yang bukan berkas FlashStruct', () => {
    const hasil = bacaBerkasImpor(JSON.stringify({ halo: 'dunia' }));
    expect(hasil.berhasil).toBe(false);
    if (!hasil.berhasil) expect(hasil.pesan).toMatch(/tidak dikenali/i);
  });

  it('menolak berkas dari versi yang lebih baru', () => {
    const berkas = { ...buatBerkasEkspor(progresKosong()), versi: VERSI_PROGRES + 5 };
    const hasil = bacaBerkasImpor(JSON.stringify(berkas));
    expect(hasil.berhasil).toBe(false);
    if (!hasil.berhasil) expect(hasil.pesan).toMatch(/versi/i);
  });

  it('menolak berkas dengan data progres yang rusak', () => {
    const rusak = {
      jenis: 'flashstruct-progres',
      versi: 1,
      dieksporPada: Date.now(),
      data: { versi: 1, modul: 'bukan objek' },
    };
    const hasil = bacaBerkasImpor(JSON.stringify(rusak));
    expect(hasil.berhasil).toBe(false);
  });
});
