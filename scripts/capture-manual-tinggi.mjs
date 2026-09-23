/**
 * Ambil ulang screenshot yang terlalu tinggi.
 *
 * Masalah: screenshot full-page (mis. 2160x7644 px) saat diletakkan di
 * halaman A4 akan meluber dan menimpa teks — terbukti pada pemeriksaan
 * PDF pertama.
 *
 * Solusi: ambil ulang pada ukuran viewport (bukan fullPage), sehingga
 * tingginya wajar dan bagian atas halaman tetap terlihat utuh.
 *
 * Cara pakai: node scripts/capture-manual-tinggi.mjs
 */

import { chromium } from 'playwright';
import path from 'node:path';

const BASE = process.env.MANUAL_BASE_URL ?? 'http://localhost:5173';
const OUT = path.resolve('manual/img');
const KUNCI_PROGRES = 'flashstruct:progres:v1';
const KUNCI_TEMA = 'flashstruct:tema';

/** Screenshot yang perlu diambil ulang dalam ukuran viewport */
const DAFTAR = [
  { nama: '01-landing-hero', url: '/', progres: false, scroll: 0 },
  { nama: '04-dashboard-terang', url: '/dashboard', progres: true, scroll: 0 },
  { nama: '06-dashboard-gelap', url: '/dashboard', progres: true, scroll: 0, tema: 'gelap' },
  { nama: '07-materi-daftar', url: '/materi', progres: true, scroll: 0 },
  { nama: '08-modul-baca-atas', url: null, progres: true, scroll: 0 }, // slug diisi runtime
  { nama: '12-soal-daftar-terkunci', url: '/soal', progres: true, scroll: 0 },
  { nama: '23-dashboard-rekomendasi', url: '/dashboard', progres: 'lengkap', scroll: 0 },
  { nama: '27-video-galeri', url: '/video', progres: false, scroll: 0 },
];

async function ambilModulPertama(page) {
  const janji = page.waitForResponse(
    (r) => r.url().includes('/rest/v1/modul') && r.status() === 200,
    { timeout: 30_000 },
  );
  await page.goto(`${BASE}/materi`, { waitUntil: 'domcontentloaded' });
  const data = await (await janji).json();
  return { id: data[0].id, slug: data[0].slug };
}

function progresSederhana(modul, lengkap = false) {
  const kartu = {};
  if (lengkap) {
    for (let i = 1; i <= 12; i++) {
      kartu[`kartu-contoh-${i}`] = {
        kartuId: `kartu-contoh-${i}`,
        jumlahIngat: 2,
        jumlahLupa: 0,
        terakhirDilihat: Date.now() - i * 3600_000,
      };
    }
  }

  return {
    versi: 1,
    modul: {
      [modul.id]: {
        modulId: modul.id,
        tahap1Selesai: lengkap,
        tahap2Selesai: lengkap,
        tahap3Selesai: lengkap,
        bagianDibaca: [],
        kartu,
        riwayatQuiz: lengkap
          ? [{ waktu: Date.now(), skor: 80, jumlahBenar: 8, jumlahSoal: 10 }]
          : [],
      },
    },
    hariAktif: lengkap
      ? [0, 1, 2].map((n) => new Date(Date.now() - n * 86_400_000).toISOString().slice(0, 10))
      : [],
    terakhirDiperbarui: Date.now(),
  };
}

async function utama() {
  const browser = await chromium.launch({ headless: true });

  console.log('Mengambil ulang screenshot tinggi dalam ukuran viewport\n');

  // Ambil slug modul dulu
  const konteksAwal = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const pageAwal = await konteksAwal.newPage();
  const modul = await ambilModulPertama(pageAwal);
  await konteksAwal.close();
  console.log(`Modul: ${modul.slug}\n`);

  for (const item of DAFTAR) {
    const url = item.nama === '08-modul-baca-atas' ? `/materi/${modul.slug}` : item.url;

    // Konteks baru per gambar agar localStorage bersih
    const konteks = await browser.newContext({
      viewport: { width: 1440, height: 900 },
      deviceScaleFactor: 1.5,
      locale: 'id-ID',
    });
    const page = await konteks.newPage();

    const p =
      item.progres === 'lengkap'
        ? progresSederhana(modul, true)
        : item.progres
          ? progresSederhana(modul, false)
          : null;

    await page.addInitScript(
      ({ kp, kt, t, pr }) => {
        localStorage.setItem(kt, t);
        if (pr) localStorage.setItem(kp, JSON.stringify(pr));
        else localStorage.removeItem(kp);
      },
      { kp: KUNCI_PROGRES, kt: KUNCI_TEMA, t: item.tema ?? 'terang', pr: p },
    );

    await page.goto(`${BASE}${url}`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(item.nama.includes('dashboard') ? 3500 : 2800);

    if (item.scroll > 0) {
      await page.evaluate((y) => window.scrollTo(0, y), item.scroll);
      await page.waitForTimeout(1000);
    }

    // Matikan animasi
    await page.addStyleTag({
      content: `*, *::before, *::after {
        animation-duration: 0s !important; animation-delay: 0s !important;
        transition-duration: 0s !important; transition-delay: 0s !important;
      }`,
    });
    await page.waitForTimeout(300);

    await page.screenshot({
      path: path.join(OUT, `${item.nama}.png`),
      fullPage: false,
    });
    console.log(`  ✓ ${item.nama}.png (viewport)`);

    await konteks.close();
  }

  await browser.close();
  console.log('\nSelesai.');
}

utama().catch((e) => {
  console.error('GAGAL:', e.message);
  process.exit(1);
});
