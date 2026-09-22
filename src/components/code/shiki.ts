/**
 * Inisialisasi Shiki (highlighter kode).
 *
 * Mengapa Shiki: memakai mesin TextMate yang sama dengan VS Code,
 * sehingga pewarnaan kode PERSIS seperti editor. Untuk aplikasi yang
 * mengajarkan kode, akurasi bukan kemewahan — ini bagian dari materi.
 *
 * PERFORMA — INI PENTING:
 *
 * Impor `'shiki'` biasa memuat SEMUA bahasa (± 100 bahasa termasuk
 * emacs-lisp dan wolfram), menambah ratusan KB yang tidak terpakai.
 * Terukur: satu chunk bahasa saja 768 KB mentah.
 *
 * Yang dipakai di sini:
 *   - Impor dinamis dari `shiki/core` (bukan bundle penuh)
 *   - Hanya engine JavaScript, bukan WASM (WASM 608 KB)
 *   - Hanya 2 bahasa: cpp dan python
 *   - Hanya 2 tema: github-light dan github-dark
 *
 * Rincian: docs/04-ARSITEKTUR-TEKNIS.md §1.2
 */

import type { HighlighterCore } from 'shiki/core';

/** Tema Shiki yang dipakai */
const TEMA_TERANG = 'github-light';
const TEMA_GELAP = 'github-dark';

/** Bahasa yang didukung — hanya yang dipakai proyek ini */
export const BAHASA_DIDUKUNG = ['cpp', 'python'] as const;
export type BahasaDidukung = (typeof BAHASA_DIDUKUNG)[number];

/** Nama bahasa untuk ditampilkan */
export const LABEL_BAHASA: Record<BahasaDidukung, string> = {
  cpp: 'C++',
  python: 'Python',
};

let janjiHighlighter: Promise<HighlighterCore> | null = null;

/**
 * Ambil highlighter, buat jika belum ada.
 *
 * Mengembalikan Promise yang sama untuk semua pemanggil, sehingga
 * Shiki hanya dimuat dan diinisialisasi sekali.
 */
export function ambilHighlighter(): Promise<HighlighterCore> {
  if (!janjiHighlighter) {
    janjiHighlighter = buatHighlighter();
  }
  return janjiHighlighter;
}

async function buatHighlighter(): Promise<HighlighterCore> {
  // Impor terpisah agar bundler hanya menyertakan yang dipakai
  const [{ createHighlighterCore }, engineJs, temaTerang, temaGelap, cpp, python] =
    await Promise.all([
      import('shiki/core'),
      import('shiki/engine/javascript'),
      import('@shikijs/themes/github-light'),
      import('@shikijs/themes/github-dark'),
      import('@shikijs/langs/cpp'),
      import('@shikijs/langs/python'),
    ]);

  return createHighlighterCore({
    themes: [temaTerang.default, temaGelap.default],
    langs: [cpp.default, python.default],
    engine: engineJs.createJavaScriptRegexEngine(),
  });
}

/** Cek apakah sebuah string adalah bahasa yang didukung */
export function bahasaDidukung(nama: string | undefined): nama is BahasaDidukung {
  return BAHASA_DIDUKUNG.includes(nama as BahasaDidukung);
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
    if (!bahasaDidukung(bahasa)) return null;

    return highlighter.codeToHtml(kode, {
      lang: bahasa,
      theme: temaShiki(tema),
    });
  } catch {
    return null;
  }
}
