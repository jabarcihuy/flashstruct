import { describe, it, expect } from 'vitest';
import {
  reducerQuiz,
  stateAwal,
  soalSekarang,
  soalTerakhir,
  susunSoal,
  opsiBenar,
  jawabanBenar,
  hitungHasil,
  hitungAkurasiTopik,
  topikTerlemah,
  type StateQuiz,
} from './sesi';
import type { OpsiSoal, SoalDenganOpsi, TipeKartu } from '@/types/database';

/* =========================================================
   Helper
   ========================================================= */

function opsi(label: string, benar = false): OpsiSoal {
  return { id: `o-${label}`, soal_id: 's1', label, teks: `Teks ${label}`, benar, urutan: 1 };
}

function soal(id: string, cardType: TipeKartu = 'ISTILAH', benar = 'C'): SoalDenganOpsi {
  return {
    id,
    modul_id: 'm1',
    pertanyaan: `Pertanyaan ${id}`,
    kode: null,
    bahasa_kode: null,
    tipe: 'PG',
    card_type: cardType,
    penjelasan: `Penjelasan ${id}`,
    urutan: 1,
    modul: { slug: 'array-dasar' },
    opsi_soal: [opsi('A'), opsi('B'), opsi(benar, true), opsi('D')],
  };
}

const DUA_SOAL = [soal('s1'), soal('s2')];

/** Jalankan urutan aksi */
function jalankan(awal: StateQuiz, aksiList: Parameters<typeof reducerQuiz>[1][]): StateQuiz {
  return aksiList.reduce((s, a) => reducerQuiz(s, a), awal);
}

/* =========================================================
   State machine
   ========================================================= */

describe('stateAwal', () => {
  it('dimulai di fase kerjakan dengan indeks 0', () => {
    const s = stateAwal(DUA_SOAL);
    expect(s.fase).toBe('kerjakan');
    expect(s.indeks).toBe(0);
    expect(s.jawaban).toEqual({});
    expect(s.sudahDijawab).toBe(false);
  });
});

describe('reducerQuiz — INIT', () => {
  it('mengisi soal saat state kosong', () => {
    const s = reducerQuiz(stateAwal([]), { tipe: 'INIT', soal: DUA_SOAL });
    expect(s.soal).toHaveLength(2);
  });

  it('tidak menimpa soal yang sudah ada', () => {
    const s = reducerQuiz(stateAwal(DUA_SOAL), { tipe: 'INIT', soal: [soal('x')] });
    expect(s.soal).toHaveLength(2);
  });
});

describe('reducerQuiz — JAWAB', () => {
  it('mencatat jawaban dan menandai sudah dijawab', () => {
    const s = reducerQuiz(stateAwal(DUA_SOAL), { tipe: 'JAWAB', soalId: 's1', label: 'C' });

    expect(s.jawaban).toEqual({ s1: 'C' });
    expect(s.sudahDijawab).toBe(true);
  });

  it('TIDAK bisa mengganti jawaban', () => {
    const s = jalankan(stateAwal(DUA_SOAL), [
      { tipe: 'JAWAB', soalId: 's1', label: 'A' },
      { tipe: 'JAWAB', soalId: 's1', label: 'C' },
    ]);

    expect(s.jawaban.s1).toBe('A');
  });

  it('mengabaikan jawaban untuk soal yang tidak sedang tampil', () => {
    const s = reducerQuiz(stateAwal(DUA_SOAL), { tipe: 'JAWAB', soalId: 's2', label: 'C' });
    expect(s.jawaban).toEqual({});
  });
});

describe('reducerQuiz — LANJUT', () => {
  it('TIDAK lanjut sebelum menjawab', () => {
    const s = reducerQuiz(stateAwal(DUA_SOAL), { tipe: 'LANJUT' });
    expect(s.indeks).toBe(0);
  });

  it('lanjut ke soal berikutnya setelah menjawab', () => {
    const s = jalankan(stateAwal(DUA_SOAL), [
      { tipe: 'JAWAB', soalId: 's1', label: 'C' },
      { tipe: 'LANJUT' },
    ]);

    expect(s.indeks).toBe(1);
    expect(s.sudahDijawab).toBe(false);
  });

  it('selesai setelah soal terakhir dijawab', () => {
    const s = jalankan(stateAwal(DUA_SOAL), [
      { tipe: 'JAWAB', soalId: 's1', label: 'C' },
      { tipe: 'LANJUT' },
      { tipe: 'JAWAB', soalId: 's2', label: 'C' },
      { tipe: 'LANJUT' },
    ]);

    expect(s.fase).toBe('selesai');
  });
});

describe('soalSekarang & soalTerakhir', () => {
  it('mengembalikan soal pertama di awal', () => {
    expect(soalSekarang(stateAwal(DUA_SOAL))?.id).toBe('s1');
  });

  it('soalTerakhir true di soal terakhir', () => {
    const s = { ...stateAwal(DUA_SOAL), indeks: 1 };
    expect(soalTerakhir(s)).toBe(true);
  });

  it('soalTerakhir false di soal pertama', () => {
    expect(soalTerakhir(stateAwal(DUA_SOAL))).toBe(false);
  });
});

/* =========================================================
   Penyusunan soal
   ========================================================= */

describe('susunSoal', () => {
  it('membatasi jumlah soal sesuai JUMLAH_SOAL_QUIZ', () => {
    const bank = Array.from({ length: 25 }, (_, i) => soal(`s${i}`));
    expect(susunSoal(bank)).toHaveLength(10);
  });

  it('mempertahankan semua soal jika kurang dari batas', () => {
    const bank = [soal('s1'), soal('s2')];
    expect(susunSoal(bank)).toHaveLength(2);
  });

  it('mengacak urutan opsi di setiap soal', () => {
    const bank = [soal('s1')];
    const hasil = susunSoal(bank);

    // Opsi harus tetap lengkap 4 buah
    expect(hasil[0]?.opsi_soal).toHaveLength(4);
  });

  it('tidak mengubah array asli', () => {
    const bank = [soal('s1'), soal('s2')];
    const salinan = bank.map((s) => s.id);

    susunSoal(bank);

    expect(bank.map((s) => s.id)).toEqual(salinan);
  });

  it('menangani bank kosong', () => {
    expect(susunSoal([])).toEqual([]);
  });
});

/* =========================================================
   Penilaian
   ========================================================= */

describe('opsiBenar', () => {
  it('mengembalikan opsi dengan benar=true', () => {
    expect(opsiBenar(soal('s1'))?.label).toBe('C');
  });

  it('mengembalikan undefined jika tidak ada opsi benar', () => {
    const rusak = { ...soal('s1'), opsi_soal: [opsi('A'), opsi('B')] };
    expect(opsiBenar(rusak)).toBeUndefined();
  });
});

describe('jawabanBenar', () => {
  it('true jika label cocok', () => {
    expect(jawabanBenar(soal('s1'), 'C')).toBe(true);
  });

  it('false jika label berbeda', () => {
    expect(jawabanBenar(soal('s1'), 'A')).toBe(false);
  });

  it('false jika belum menjawab', () => {
    expect(jawabanBenar(soal('s1'), undefined)).toBe(false);
  });
});

describe('hitungHasil', () => {
  it('menghitung skor dengan benar', () => {
    const bank = [soal('s1'), soal('s2'), soal('s3'), soal('s4')];
    const s: StateQuiz = {
      ...stateAwal(bank),
      jawaban: { s1: 'C', s2: 'A', s3: 'C', s4: 'D' }, // 2 benar dari 4
    };

    const hasil = hitungHasil(s);

    expect(hasil.jumlahBenar).toBe(2);
    expect(hasil.jumlahSoal).toBe(4);
    expect(hasil.skor).toBe(50);
    expect(hasil.lulus).toBe(false);
  });

  it('lulus jika skor >= 70', () => {
    const bank = [soal('s1'), soal('s2'), soal('s3')];
    const s: StateQuiz = {
      ...stateAwal(bank),
      jawaban: { s1: 'C', s2: 'C', s3: 'A' }, // 2 dari 3 = 67%
    };

    // 2/3 = 66.67 -> dibulatkan 67, belum lulus
    expect(hitungHasil(s).skor).toBe(67);
    expect(hitungHasil(s).lulus).toBe(false);
  });

  it('lulus tepat di ambang 70', () => {
    const bank = Array.from({ length: 10 }, (_, i) => soal(`s${i}`));
    const jawaban: Record<string, string> = {};
    // 7 benar, 3 salah
    bank.forEach((s, i) => {
      jawaban[s.id] = i < 7 ? 'C' : 'A';
    });

    const hasil = hitungHasil({ ...stateAwal(bank), jawaban });

    expect(hasil.skor).toBe(70);
    expect(hasil.lulus).toBe(true);
  });

  it('skor 0 jika tidak ada jawaban benar', () => {
    const bank = [soal('s1')];
    const s: StateQuiz = { ...stateAwal(bank), jawaban: { s1: 'A' } };

    expect(hitungHasil(s).skor).toBe(0);
  });

  it('skor 0 untuk sesi kosong', () => {
    expect(hitungHasil(stateAwal([])).skor).toBe(0);
  });
});

/* =========================================================
   Analisis topik
   ========================================================= */

describe('hitungAkurasiTopik', () => {
  it('menghitung akurasi per tipe kartu', () => {
    const bank = [soal('s1', 'MEMORI'), soal('s2', 'MEMORI'), soal('s3', 'TRACING')];
    const s: StateQuiz = {
      ...stateAwal(bank),
      jawaban: { s1: 'C', s2: 'A', s3: 'C' }, // MEMORI 1/2, TRACING 1/1
    };

    const hasil = hitungAkurasiTopik(s);

    const memori = hasil.find((h) => h.cardType === 'MEMORI');
    const tracing = hasil.find((h) => h.cardType === 'TRACING');

    expect(memori?.benar).toBe(1);
    expect(memori?.total).toBe(2);
    expect(memori?.persen).toBe(50);
    expect(tracing?.persen).toBe(100);
  });

  it('mengurutkan dari TERLEMAH', () => {
    const bank = [soal('s1', 'MEMORI'), soal('s2', 'TRACING'), soal('s3', 'JEBAKAN')];
    const s: StateQuiz = {
      ...stateAwal(bank),
      jawaban: { s1: 'C', s2: 'A', s3: 'A' }, // MEMORI 100%, TRACING 0%, JEBAKAN 0%
    };

    const hasil = hitungAkurasiTopik(s);

    // Yang terlemah harus di depan
    expect(hasil[0]?.persen).toBeLessThanOrEqual(hasil[hasil.length - 1]?.persen ?? 100);
  });

  it('mengategorikan lemah di bawah 50%', () => {
    const bank = [soal('s1', 'MEMORI'), soal('s2', 'MEMORI')];
    const s: StateQuiz = { ...stateAwal(bank), jawaban: { s1: 'A', s2: 'A' } };

    expect(hitungAkurasiTopik(s)[0]?.kategori).toBe('lemah');
  });

  it('mengategorikan cukup di 50-79%', () => {
    const bank = [soal('s1', 'MEMORI'), soal('s2', 'MEMORI')];
    const s: StateQuiz = { ...stateAwal(bank), jawaban: { s1: 'C', s2: 'A' } };

    expect(hitungAkurasiTopik(s)[0]?.kategori).toBe('cukup');
  });

  it('mengategorikan kuat di 80% ke atas', () => {
    const bank = Array.from({ length: 5 }, (_, i) => soal(`s${i}`, 'MEMORI'));
    const jawaban: Record<string, string> = {};
    bank.forEach((s, i) => {
      jawaban[s.id] = i < 4 ? 'C' : 'A'; // 4 dari 5 = 80%
    });

    const hasil = hitungAkurasiTopik({ ...stateAwal(bank), jawaban });

    expect(hasil[0]?.persen).toBe(80);
    expect(hasil[0]?.kategori).toBe('kuat');
  });

  it('mengembalikan array kosong untuk sesi kosong', () => {
    expect(hitungAkurasiTopik(stateAwal([]))).toEqual([]);
  });
});

describe('topikTerlemah', () => {
  it('mengembalikan topik dengan kategori lemah', () => {
    const akurasi = [
      {
        cardType: 'MEMORI' as TipeKartu,
        benar: 0,
        total: 2,
        persen: 0,
        kategori: 'lemah' as const,
      },
      {
        cardType: 'TRACING' as TipeKartu,
        benar: 2,
        total: 2,
        persen: 100,
        kategori: 'kuat' as const,
      },
    ];

    expect(topikTerlemah(akurasi)?.cardType).toBe('MEMORI');
  });

  it('null jika tidak ada yang lemah', () => {
    const akurasi = [
      {
        cardType: 'MEMORI' as TipeKartu,
        benar: 2,
        total: 2,
        persen: 100,
        kategori: 'kuat' as const,
      },
    ];

    expect(topikTerlemah(akurasi)).toBeNull();
  });

  it('null untuk array kosong', () => {
    expect(topikTerlemah([])).toBeNull();
  });
});
