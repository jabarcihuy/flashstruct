/**
 * Perbaikan capture: halaman hasil quiz.
 *
 * Masalah pada percobaan sebelumnya:
 *   - Opsi jawaban adalah <button> TANPA aria-label, jadi
 *     locator('button[aria-label^="Jawaban"]') tidak menemukan apa pun.
 *   - Tombol lanjut ("Soal Berikutnya" / "Lihat Hasil") ada di
 *     UmpanBalik.tsx dan hanya muncul SETELAH soal dijawab.
 *
 * Selektor yang benar:
 *   - Opsi  : div[role="group"][aria-label="Pilihan jawaban"] > button
 *   - Lanjut: button yang berisi teks "Soal Berikutnya" / "Lihat Hasil"
 *
 * Cara pakai: node scripts/capture-manual-fix.mjs
 */

import { chromium } from 'playwright';
import path from 'node:path';

const BASE = process.env.MANUAL_BASE_URL ?? 'http://localhost:5173';
const OUT = path.resolve('manual/img');
const KUNCI_PROGRES = 'flashstruct:progres:v1';
const KUNCI_TEMA = 'flashstruct:tema';

async function ambilModulPertama(page) {
  const janji = page.waitForResponse(
    (r) => r.url().includes('/rest/v1/modul') && r.status() === 200,
    { timeout: 30_000 },
  );
  await page.goto(`${BASE}/materi`, { waitUntil: 'domcontentloaded' });
  const data = await (await janji).json();
  return { id: data[0].id, slug: data[0].slug, judul: data[0].judul };
}

function progresTahap2Selesai(modul) {
  return {
    versi: 1,
    modul: {
      [modul.id]: {
        modulId: modul.id,
        tahap1Selesai: true,
        tahap2Selesai: true,
        tahap3Selesai: false,
        bagianDibaca: [],
        kartu: {},
        riwayatQuiz: [],
      },
    },
    hariAktif: [new Date().toISOString().slice(0, 10)],
    terakhirDiperbarui: Date.now(),
  };
}

async function matikanAnimasi(page) {
  await page.addStyleTag({
    content: `*, *::before, *::after {
      animation-duration: 0s !important; animation-delay: 0s !important;
      transition-duration: 0s !important; transition-delay: 0s !important;
    }`,
  });
  await page.waitForTimeout(300);
}

async function utama() {
  const browser = await chromium.launch({ headless: true });
  const konteks = await browser.newContext({
    viewport: { width: 1440, height: 900 },
    deviceScaleFactor: 1.5,
    locale: 'id-ID',
  });
  const page = await konteks.newPage();

  const modul = await ambilModulPertama(page);
  console.log(`Modul: ${modul.judul}\n`);

  /* ============ Hasil quiz + analisis topik ============ */
  await page.addInitScript(
    ({ kp, kt, p }) => {
      localStorage.setItem(kt, 'terang');
      localStorage.setItem(kp, JSON.stringify(p));
    },
    { kp: KUNCI_PROGRES, kt: KUNCI_TEMA, p: progresTahap2Selesai(modul) },
  );

  await page.goto(`${BASE}/soal/quiz/${modul.slug}`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(3500);

  // Grup opsi jawaban — selektor sesuai SoalPilihanGanda.tsx baris 71
  const grupOpsi = page.locator('div[role="group"][aria-label="Pilihan jawaban"]');
  const tombolLanjut = page.getByRole('button', { name: /soal berikutnya|lihat hasil/i });

  for (let i = 0; i < 15; i++) {
    // 1. Jawab: klik opsi pertama
    const opsi = grupOpsi.locator('button');
    if ((await opsi.count()) > 0) {
      await opsi.first().click({ force: true }).catch(() => {});
      await page.waitForTimeout(700);
    }

    // 2. Lanjut: klik "Soal Berikutnya" atau "Lihat Hasil"
    if ((await tombolLanjut.count()) > 0) {
      const teks = (await tombolLanjut.first().innerText().catch(() => '')).trim();
      await tombolLanjut.first().click({ force: true }).catch(() => {});
      await page.waitForTimeout(900);

      if (/lihat hasil/i.test(teks)) {
        console.log(`  soal ke-${i + 1}: klik "Lihat Hasil"`);
        break;
      }
    } else {
      await page.waitForTimeout(600);
    }
  }

  await page.waitForTimeout(2500);
  const isi = await page.locator('body').innerText();
  const diHalamanHasil = /analisis per topik/i.test(isi);
  console.log(`  status: ${diHalamanHasil ? 'HALAMAN HASIL ✓' : 'BUKAN halaman hasil ✗'}`);

  if (!diHalamanHasil) {
    throw new Error('Gagal mencapai halaman hasil quiz — periksa selektor');
  }

  await matikanAnimasi(page);
  await page.screenshot({ path: path.join(OUT, '21-quiz-hasil.png'), fullPage: false });
  console.log('  ✓ 21-quiz-hasil.png');

  // Scroll ke bagian analisis per topik
  await page.evaluate(() => {
    const h = [...document.querySelectorAll('h2')].find((x) =>
      /analisis per topik/i.test(x.textContent ?? ''),
    );
    h?.scrollIntoView({ block: 'start' });
  });
  await page.waitForTimeout(1200);
  await page.screenshot({ path: path.join(OUT, '22-quiz-analisis-topik.png'), fullPage: false });
  console.log('  ✓ 22-quiz-analisis-topik.png');

  await browser.close();
  console.log('\nSelesai.');
}

utama().catch((e) => {
  console.error('GAGAL:', e.message);
  process.exit(1);
});
