import { describe, it, expect } from 'vitest';
import {
  ModulSchema,
  FlashcardSchema,
  SoalSchema,
  ModulRingkasSchema,
  validasi,
  validasiArray,
} from './schema';

const MODUL_VALID = {
  id: '2cedce5a-76fc-4f63-b4c1-5b1abc561332',
  slug: 'array-dasar',
  judul: 'Dasar Array & Indeks',
  topik: 'array',
  deskripsi: 'Memori berurutan, indeks, dan batas array.',
  estimasi_menit: 12,
  urutan: 1,
};

describe('ModulSchema', () => {
  it('menerima data yang valid', () => {
    expect(() => ModulSchema.parse(MODUL_VALID)).not.toThrow();
  });

  it('menolak topik yang tidak dikenal', () => {
    expect(() => ModulSchema.parse({ ...MODUL_VALID, topik: 'linked-list' })).toThrow();
  });

  it('menolak id yang bukan UUID', () => {
    expect(() => ModulSchema.parse({ ...MODUL_VALID, id: 'bukan-uuid' })).toThrow();
  });

  it('menolak estimasi_menit nol atau negatif', () => {
    expect(() => ModulSchema.parse({ ...MODUL_VALID, estimasi_menit: 0 })).toThrow();
    expect(() => ModulSchema.parse({ ...MODUL_VALID, estimasi_menit: -5 })).toThrow();
  });

  it('menolak slug kosong', () => {
    expect(() => ModulSchema.parse({ ...MODUL_VALID, slug: '' })).toThrow();
  });
});

describe('FlashcardSchema', () => {
  const kartuValid = {
    id: '11111111-1111-4111-8111-111111111111',
    modul_id: MODUL_VALID.id,
    depan: 'Apa itu array?',
    belakang: 'Kumpulan elemen bertipe sama.',
    card_type: 'ISTILAH',
    kode: null,
    bahasa_kode: null,
    urutan: 1,
  };

  it('menerima kartu tanpa kode', () => {
    expect(() => FlashcardSchema.parse(kartuValid)).not.toThrow();
  });

  it('menerima kartu dengan kode dan bahasa', () => {
    const denganKode = {
      ...kartuValid,
      kode: 'int arr[5];',
      bahasa_kode: 'cpp',
    };
    expect(() => FlashcardSchema.parse(denganKode)).not.toThrow();
  });

  it('menolak card_type yang tidak dikenal', () => {
    expect(() => FlashcardSchema.parse({ ...kartuValid, card_type: 'NGARANG' })).toThrow();
  });

  it('menolak bahasa_kode yang tidak dikenal', () => {
    expect(() =>
      FlashcardSchema.parse({ ...kartuValid, kode: 'x', bahasa_kode: 'java' }),
    ).toThrow();
  });
});

describe('SoalSchema', () => {
  const soalValid = {
    id: '22222222-2222-4222-8222-222222222222',
    modul_id: MODUL_VALID.id,
    pertanyaan: 'Berapa sizeof(int arr[5])?',
    kode: null,
    bahasa_kode: null,
    tipe: 'PG',
    card_type: 'MEMORI',
    penjelasan: '5 elemen x 4 byte = 20 byte.',
    urutan: 1,
  };

  it('menerima soal pilihan ganda tanpa kode', () => {
    expect(() => SoalSchema.parse(soalValid)).not.toThrow();
  });

  it('menolak tipe soal yang tidak dikenal', () => {
    expect(() => SoalSchema.parse({ ...soalValid, tipe: 'ESAI' })).toThrow();
  });

  it('menolak penjelasan kosong', () => {
    expect(() => SoalSchema.parse({ ...soalValid, penjelasan: '' })).toThrow();
  });
});

describe('ModulRingkasSchema', () => {
  it('menerima modul dengan relasi terisi', () => {
    const data = {
      ...MODUL_VALID,
      bagian_modul: [{ id: '33333333-3333-4333-8333-333333333333' }],
      flashcard: [{ id: '44444444-4444-4444-8444-444444444444' }],
      soal: [],
    };
    expect(() => ModulRingkasSchema.parse(data)).not.toThrow();
  });

  it('menerima modul tanpa relasi (null)', () => {
    const data = { ...MODUL_VALID, bagian_modul: null, flashcard: null, soal: null };
    expect(() => ModulRingkasSchema.parse(data)).not.toThrow();
  });
});

describe('helper validasi', () => {
  it('mengembalikan data saat valid', () => {
    const hasil = validasi(ModulSchema, MODUL_VALID, 'uji');
    expect(hasil.slug).toBe('array-dasar');
  });

  it('melempar error dengan konteks saat tidak valid', () => {
    expect(() => validasi(ModulSchema, { ...MODUL_VALID, topik: 'salah' }, 'ambilModul')).toThrow(
      /Data tidak valid dari ambilModul/,
    );
  });

  it('membatasi pesan error maksimal 3 masalah', () => {
    const rusak = { id: 'x', slug: '', judul: '', topik: 'y', deskripsi: 1, estimasi_menit: -1 };
    try {
      validasi(ModulSchema, rusak, 'uji');
      throw new Error('seharusnya melempar');
    } catch (e) {
      const pesan = (e as Error).message;
      // Pesan tidak boleh kepanjangan — maksimal 3 masalah dipisah ";"
      expect(pesan.split(';').length).toBeLessThanOrEqual(3);
    }
  });

  it('validasiArray memvalidasi setiap elemen', () => {
    const data = [MODUL_VALID, { ...MODUL_VALID, id: 'bukan-uuid' }];
    expect(() => validasiArray(ModulSchema, data, 'uji')).toThrow(/Data tidak valid/);
  });

  it('validasiArray menerima array kosong', () => {
    expect(validasiArray(ModulSchema, [], 'uji')).toEqual([]);
  });
});
