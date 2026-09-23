/**
 * Build Manual Book FlashStruct → PDF.
 *
 * Cara pakai:
 *   node scripts/build-manual.mjs
 *
 * Alur:
 *   1. Baca semua berkas HTML di manual/konten/ secara berurutan
 *   2. Rakit menjadi satu dokumen HTML lengkap dengan CSS dan font
 *   3. Buka di Chromium headless, cetak ke PDF ukuran A4
 *   4. Laporkan jumlah halaman dan ukuran berkas
 *
 * Prasyarat: screenshot sudah ada di manual/img/ (jalankan
 * scripts/capture-manual.mjs lebih dulu bila belum).
 */

import { chromium } from 'playwright';
import { readFile, writeFile, readdir, stat } from 'node:fs/promises';
import path from 'node:path';

const ROOT = path.resolve('.');
const DIR_KONTEN = path.join(ROOT, 'manual/konten');
const DIR_IMG = path.join(ROOT, 'manual/img');
const KELUARAN = path.join(ROOT, 'manual/FlashStruct-Manual-Book.pdf');

/** Urutan bab — sesuai nama berkas, diurutkan alfabetis */
async function bacaKonten() {
  const berkas = (await readdir(DIR_KONTEN)).filter((f) => f.endsWith('.html')).sort();

  if (berkas.length === 0) {
    throw new Error(`Tidak ada berkas HTML di ${DIR_KONTEN}`);
  }

  const bagian = [];
  for (const f of berkas) {
    const isi = await readFile(path.join(DIR_KONTEN, f), 'utf8');
    bagian.push({ nama: f, isi });
    console.log(`  ✓ ${f} (${(isi.length / 1024).toFixed(1)} KB)`);
  }

  return bagian;
}

/** Periksa semua gambar yang direferensikan benar-benar ada */
async function periksaGambar(html) {
  const rujukan = [...html.matchAll(/src="img\/([^"]+)"/g)].map((m) => m[1]);
  const unik = [...new Set(rujukan)];

  let ada = 0;
  const hilang = [];

  for (const nama of unik) {
    try {
      await stat(path.join(DIR_IMG, nama));
      ada += 1;
    } catch {
      hilang.push(nama);
    }
  }

  console.log(`  gambar dirujuk: ${unik.length} | ada: ${ada} | hilang: ${hilang.length}`);

  if (hilang.length > 0) {
    console.warn(`  PERINGATAN — gambar tidak ditemukan:\n    ${hilang.join('\n    ')}`);
  }

  return { ada, hilang, total: unik.length };
}

/** Rakit dokumen HTML lengkap */
function rakitDokumen(konten, css) {
  const judul = 'FlashStruct — Manual Book';

  return `<!doctype html>
<html lang="id">
<head>
<meta charset="utf-8" />
<title>${judul}</title>
<style>
${css}
</style>
</head>
<body>
${konten}
</body>
</html>`;
}

async function utama() {
  console.log('Membangun Manual Book FlashStruct\n');

  // 1. Baca CSS
  const css = await readFile(path.join(ROOT, 'manual/gaya.css'), 'utf8');
  console.log(`CSS: ${(css.length / 1024).toFixed(1)} KB`);

  // 2. Baca konten
  console.log('\nMembaca konten:');
  const bagian = await bacaKonten();
  const kontenGabung = bagian.map((b) => b.isi).join('\n\n');

  // 3. Periksa gambar
  console.log('\nMemeriksa gambar:');
  const { hilang } = await periksaGambar(kontenGabung);

  // 4. Rakit HTML
  const html = rakitDokumen(kontenGabung, css);
  const berkasSementara = path.join(ROOT, 'manual/.rakitan.html');
  await writeFile(berkasSementara, html, 'utf8');
  console.log(`\nHTML rakitan: ${(html.length / 1024).toFixed(1)} KB`);

  // 5. Cetak ke PDF
  console.log('\nMencetak PDF…');
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  // Muat lewat file:// supaya font relatif dan gambar lokal bisa diakses
  await page.goto(`file://${berkasSementara}`, { waitUntil: 'networkidle' });

  // Tunggu font benar-benar siap sebelum mencetak — tanpa ini,
  // PDF bisa memakai font fallback dan hasilnya berbeda dari yang dilihat.
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(1500);

  await page.pdf({
    path: KELUARAN,
    format: 'A4',
    printBackground: true,
    margin: { top: '20mm', right: '18mm', bottom: '22mm', left: '18mm' },
    displayHeaderFooter: true,
    headerTemplate: `
      <div style="width:100%; font-size:7.5pt; color:#52627b;
                  font-family:'Encode Sans',sans-serif; padding:0 18mm;
                  display:flex; justify-content:space-between;">
        <span>FlashStruct — Manual Book</span>
      </div>`,
    footerTemplate: `
      <div style="width:100%; font-size:7.5pt; color:#52627b;
                  font-family:'Encode Sans',sans-serif; padding:0 18mm;
                  display:flex; justify-content:space-between;">
        <span>Panduan Penggunaan</span>
        <span>Halaman <span class="pageNumber"></span> dari <span class="totalPages"></span></span>
      </div>`,
  });

  await browser.close();

  // 6. Laporan
  const info = await stat(KELUARAN);
  const pdfBuffer = await readFile(KELUARAN);

  // Hitung halaman dari objek /Type /Page di dalam PDF
  const teksPdf = pdfBuffer.toString('latin1');
  const jumlahHalaman = (teksPdf.match(/\/Type\s*\/Page[^s]/g) ?? []).length;

  console.log('\n' + '─'.repeat(50));
  console.log(`PDF  : ${path.relative(ROOT, KELUARAN)}`);
  console.log(`Ukuran: ${(info.size / 1024 / 1024).toFixed(2)} MB`);
  console.log(`Halaman: ${jumlahHalaman}`);
  if (hilang.length > 0) {
    console.log(`Gambar hilang: ${hilang.length}`);
  }
  console.log('─'.repeat(50));
  console.log('\nSelesai.');
}

utama().catch((e) => {
  console.error('\nGAGAL:', e.message);
  process.exit(1);
});
