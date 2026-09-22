import type { Highlighter } from 'shiki';

/**
 * Inisialisasi Shiki (highlighter kode).
 *
 * Mengapa Shiki: memakai mesin TextMate yang sama dengan VS Code,
 * sehingga pewarnaan kode PERSIS seperti editor. Untuk aplikasi yang
 * mengajarkan kode, akurasi bukan kemewahan — ini bagian dari materi.
 *
 * Ukurannya besar (± 300 KB), jadi:
 *   1. Dimuat dinamis (impor dinamis) — tidak masuk bundle awal
 *   2. Singleton — dibuat sekali, bukan per komponen
 *   3. Hanya 2 bahasa dan 2 tema — bukan semua
 *
 * Rincian: docs/04-ARSITEKTUR-TEKNIS.md §1.2
 */

let janjiHighlighter: Promise<Highlighter> | null = null;

/** Tema Shiki yang dipakai */
const TEMA_TERANG = 'github-light';
const TEMA_GELAP = 'github-dark';

/** Bahasa yang didukung — hanya yang dipakai proyek ini */
const BAHASA = ['cpp', 'python'] as const;

export type BahasaDidukung = (typeof BAHASA)[number];

/** Nama bahasa untuk ditampilkan */
export const LABEL_BAHASA: Record<BahasaDidukung, string> = {
  cpp: 'C++',
  python: 'Python',
};

/**
 * Ambil highlighter, buat jika belum ada.
 *
 * Mengembalikan Promise yang sama untuk semua pemanggil, sehingga
 * Shiki hanya dimuat dan diinisialisasi sekali.
 */
export function ambilHighlighter(): Promise<Highlighter> {
  if (!janjiHighlighter) {
    janjiHighlighter = import('shiki').then(({ createHighlighter }) =>
      createHighlighter({
        themes: [TEMA_TERANG, TEMA_GELAP],
        langs: [...BAHASA],
      }),
    );
  }
  return janjiHighlighter;
}

/** Cek apakah sebuah string adalah bahasa yang didukung */
export function bahasaDidukung(nama: string | undefined): nama is BahasaDidukung {
  return BAHASA.includes(nama as BahasaDidukung);
}

/** Nama tema Shiki sesuai tema aplikasi */
export function temaShiki(tema: 'terang' | 'gelap'): string {
  return tema === 'gelap' ? TEMA_GELAP : TEMA_TERANG;
}

/**
 * Hasilkan HTML berwarna dari kode.
 *
 * Mengembalikan null jika gagal — pemanggil harus menampilkan kode
 * tanpa warna sebagai fallback, bukan pesan error. Kode tetap terbaca
 * walau tanpa pewarnaan.
 */
export async function warnaiKode(
  kode: string,
  bahasa: string | undefined,
  tema: 'terang' | 'gelap',
): Promise<string | null> {
  try {
    const highlighter = await ambilHighlighter();

    // Bahasa yang tidak didukung: tampilkan sebagai teks biasa
    const lang = bahasaDidukung(bahasa) ? bahasa : 'text';

    return highlighter.codeToHtml(kode, {
      lang,
      theme: temaShiki(tema),
    });
  } catch {
    return null;
  }
}
