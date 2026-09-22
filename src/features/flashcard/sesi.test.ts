import { describe, it, expect } from 'vitest';
import {
  reducerSesi,
  stateAwal,
  kartuSekarang,
  kartuLupa,
  hitungRingkasan,
  type StateSesi,
} from './sesi';
import type { KartuDenganModul } from '@/types/database';

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

const TIGA_KARTU = [kartu('a'), kartu('b'), kartu('c')];

/** Jalankan urutan aksi dan kembalikan state akhir */
function jalankan(awal: StateSesi, aksiList: Parameters<typeof reducerSesi>[1][]): StateSesi {
  return aksiList.reduce((s, a) => reducerSesi(s, a), awal);
}

describe('stateAwal', () => {
  it('dimulai di fase kerjakan, kartu pertama, belum terbuka', () => {
    const s = stateAwal(TIGA_KARTU);

    expect(s.fase).toBe('kerjakan');
    expect(s.indeks).toBe(0);
    expect(s.terbuka).toBe(false);
    expect(s.hasil).toEqual({});
    expect(s.putaran).toBe(0);
  });
});

describe('reducerSesi — INIT', () => {
  it('mengisi deck saat state masih kosong', () => {
    const kosong = stateAwal([]);
    const s = reducerSesi(kosong, { tipe: 'INIT', kartu: TIGA_KARTU });

    expect(s.kartu).toHaveLength(3);
    expect(s.indeks).toBe(0);
  });

  it('TIDAK menimpa deck yang sudah ada', () => {
    const sudahAda = stateAwal(TIGA_KARTU);
    const s = reducerSesi(sudahAda, { tipe: 'INIT', kartu: [kartu('x')] });

    expect(s.kartu).toHaveLength(3);
  });
});

describe('reducerSesi — BALIK', () => {
  it('membalik kartu', () => {
    const s = reducerSesi(stateAwal(TIGA_KARTU), { tipe: 'BALIK' });
    expect(s.terbuka).toBe(true);
  });

  it('tidak membalik dua kali', () => {
    const sekali = reducerSesi(stateAwal(TIGA_KARTU), { tipe: 'BALIK' });
    const dua = reducerSesi(sekali, { tipe: 'BALIK' });

    expect(dua.terbuka).toBe(true);
  });

  it('tidak membalik saat kartu sedang keluar', () => {
    const s = jalankan(stateAwal(TIGA_KARTU), [
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'a', ingat: true },
      { tipe: 'BALIK' }, // harus diabaikan
    ]);

    expect(s.terbuka).toBe(true); // tetap terbuka, tidak berubah
  });
});

describe('reducerSesi — NILAI', () => {
  it('TIDAK menilai sebelum kartu dibalik', () => {
    const s = reducerSesi(stateAwal(TIGA_KARTU), {
      tipe: 'NILAI',
      kartuId: 'a',
      ingat: true,
    });

    expect(s.hasil).toEqual({});
  });

  it('mencatat hasil setelah kartu dibalik', () => {
    const s = jalankan(stateAwal(TIGA_KARTU), [
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'a', ingat: true },
    ]);

    expect(s.hasil).toEqual({ a: true });
    expect(s.keluar).toBe(true);
    expect(s.arahKeluar).toBe(1);
  });

  it('mencatat arah keluar ke kiri saat lupa', () => {
    const s = jalankan(stateAwal(TIGA_KARTU), [
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'a', ingat: false },
    ]);

    expect(s.arahKeluar).toBe(-1);
  });
});

describe('reducerSesi — alur lengkap', () => {
  it('berpindah ke kartu berikutnya setelah animasi keluar', () => {
    const s = jalankan(stateAwal(TIGA_KARTU), [
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'a', ingat: true },
      { tipe: 'KARTU_KELUAR_SELESAI' },
    ]);

    expect(s.indeks).toBe(1);
    expect(s.terbuka).toBe(false);
    expect(s.keluar).toBe(false);
  });

  it('menyelesaikan sesi setelah semua kartu dinilai', () => {
    const s = jalankan(stateAwal(TIGA_KARTU), [
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'a', ingat: true },
      { tipe: 'KARTU_KELUAR_SELESAI' },
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'b', ingat: true },
      { tipe: 'KARTU_KELUAR_SELESAI' },
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'c', ingat: true },
      { tipe: 'KARTU_KELUAR_SELESAI' },
    ]);

    expect(s.fase).toBe('selesai');
  });

  it('masuk fase putaran ulang jika ada kartu lupa', () => {
    const s = jalankan(stateAwal(TIGA_KARTU), [
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'a', ingat: false },
      { tipe: 'KARTU_KELUAR_SELESAI' },
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'b', ingat: true },
      { tipe: 'KARTU_KELUAR_SELESAI' },
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'c', ingat: true },
      { tipe: 'KARTU_KELUAR_SELESAI' },
    ]);

    expect(s.fase).toBe('putaran-ulang');
  });

  it('langsung selesai jika tidak ada kartu lupa', () => {
    const s = jalankan(stateAwal([kartu('a')]), [
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'a', ingat: true },
      { tipe: 'KARTU_KELUAR_SELESAI' },
    ]);

    expect(s.fase).toBe('selesai');
  });
});

describe('reducerSesi — putaran ulang', () => {
  function sampaiPutaranUlang(): StateSesi {
    return jalankan(stateAwal(TIGA_KARTU), [
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'a', ingat: false },
      { tipe: 'KARTU_KELUAR_SELESAI' },
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'b', ingat: true },
      { tipe: 'KARTU_KELUAR_SELESAI' },
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'c', ingat: false },
      { tipe: 'KARTU_KELUAR_SELESAI' },
    ]);
  }

  it('menyusun ulang deck berisi HANYA kartu lupa', () => {
    const s = reducerSesi(sampaiPutaranUlang(), { tipe: 'MULAI_ULANGAN' });

    expect(s.fase).toBe('kerjakan');
    expect(s.kartu).toHaveLength(2);
    expect(s.kartu.map((k) => k.id).sort()).toEqual(['a', 'c']);
  });

  it('menaikkan nomor putaran', () => {
    const s = reducerSesi(sampaiPutaranUlang(), { tipe: 'MULAI_ULANGAN' });
    expect(s.putaran).toBe(1);
  });

  it('mempertahankan hasil lama agar ringkasan mencerminkan seluruh sesi', () => {
    const s = reducerSesi(sampaiPutaranUlang(), { tipe: 'MULAI_ULANGAN' });
    expect(s.hasil).toEqual({ a: false, b: true, c: false });
  });

  it('reset indeks dan status terbuka', () => {
    const s = reducerSesi(sampaiPutaranUlang(), { tipe: 'MULAI_ULANGAN' });
    expect(s.indeks).toBe(0);
    expect(s.terbuka).toBe(false);
  });

  it('hanya SATU putaran ulang — putaran kedua langsung selesai', () => {
    const putaran1 = reducerSesi(sampaiPutaranUlang(), { tipe: 'MULAI_ULANGAN' });

    // Nilai dua kartu, keduanya masih lupa
    const selesai = jalankan(putaran1, [
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'a', ingat: false },
      { tipe: 'KARTU_KELUAR_SELESAI' },
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'c', ingat: false },
      { tipe: 'KARTU_KELUAR_SELESAI' },
    ]);

    // Tidak masuk putaran ulang lagi
    expect(selesai.fase).toBe('selesai');
  });

  it('bisa melewati putaran ulang', () => {
    const s = reducerSesi(sampaiPutaranUlang(), { tipe: 'LEWATI_ULANGAN' });
    expect(s.fase).toBe('selesai');
  });

  it('MULAI_ULANGAN diabaikan kalau bukan di fase putaran ulang', () => {
    const s = reducerSesi(stateAwal(TIGA_KARTU), { tipe: 'MULAI_ULANGAN' });
    expect(s.fase).toBe('kerjakan');
  });
});

describe('kartuSekarang', () => {
  it('mengembalikan kartu pertama di awal', () => {
    expect(kartuSekarang(stateAwal(TIGA_KARTU))?.id).toBe('a');
  });

  it('mengembalikan null jika indeks di luar batas', () => {
    const s = { ...stateAwal(TIGA_KARTU), indeks: 99 };
    expect(kartuSekarang(s)).toBeNull();
  });
});

describe('kartuLupa', () => {
  it('mengembalikan kartu yang ditandai lupa', () => {
    const s = jalankan(stateAwal(TIGA_KARTU), [
      { tipe: 'BALIK' },
      { tipe: 'NILAI', kartuId: 'a', ingat: false },
      { tipe: 'KARTU_KELUAR_SELESAI' },
    ]);

    expect(kartuLupa(s).map((k) => k.id)).toEqual(['a']);
  });

  it('kosong jika tidak ada yang lupa', () => {
    expect(kartuLupa(stateAwal(TIGA_KARTU))).toEqual([]);
  });
});

describe('hitungRingkasan', () => {
  it('menghitung statistik dengan benar', () => {
    const r = hitungRingkasan({ a: true, b: false, c: true, d: true });

    expect(r.total).toBe(4);
    expect(r.ingat).toBe(3);
    expect(r.lupa).toBe(1);
    expect(r.akurasi).toBe(75);
    expect(r.semuaDikuasai).toBe(false);
  });

  it('semuaDikuasai true jika tidak ada yang lupa', () => {
    const r = hitungRingkasan({ a: true, b: true });
    expect(r.semuaDikuasai).toBe(true);
  });

  it('semuaDikuasai false untuk hasil kosong', () => {
    const r = hitungRingkasan({});
    expect(r.semuaDikuasai).toBe(false);
    expect(r.total).toBe(0);
    expect(r.akurasi).toBe(0);
  });

  it('akurasi 100 jika semua ingat', () => {
    const r = hitungRingkasan({ a: true, b: true, c: true });
    expect(r.akurasi).toBe(100);
  });
});
