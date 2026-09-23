/**
 * Capture screenshot untuk Manual Book FlashStruct.
 *
 * Mengambil tangkapan layar dari aplikasi yang sedang berjalan
 * (http://localhost:5173) untuk dipakai di manual book PDF.
 *
 * Cara pakai:
 *   node scripts/capture-manual.mjs
 *
 * Prasyarat: dev server harus sudah jalan (`npm run dev`).
 *
 * Catatan penting:
 *   - Beberapa state (sesi flashcard, hasil quiz, dashboard berprogres)
 *     membutuhkan progres. Progres disuntik lewat localStorage dengan
 *     pola yang sama seperti e2e/penguncian-tahap.spec.ts.
 *   - Modul ID diambil dari respons jaringan Supabase saat runtime,
 *     bukan ditulis manual, agar tidak basi saat konten berubah.
 */

import { chromium } from 'playwright';
import { mkdir, writeFile } from 'node:fs/promises';
import path from 'node:path';

const BASE = process.env.MANUAL_BASE_URL ?? 'http://localhost:5173';
const OUT = path.resolve('manual/img');
const KUNCI_PROGRES = 'flashstruct:progres:v1';
const KUNCI_TEMA = 'flashstruct:tema';

/** Daftar screenshot yang dihasilkan — dipakai untuk laporan akhir */
const hasil = [];

/**
 * Ambil ID + slug modul pertama langsung dari respons Supabase.
 * Sama seperti pola di e2e/penguncian-tahap.spec.ts.
 */
async function ambilModulPertama(page) {
  const janji = page.waitForResponse(
    (r) => r.url().includes('/rest/v1/modul') && r.status() === 200,
    { timeout: 30_000 },
  );
  await page.goto(`${BASE}/materi`, { waitUntil: 'domcontentloaded' });
  const respons = await janji;
  const data = await respons.json();

  if (!Array.isArray(data) || data.length === 0) {
    throw new Error('Supabase tidak mengembalikan modul — periksa koneksi/kredensial');
  }

  // Ambil modul pertama DAN modul ketiga (untuk variasi topik struct)
  return {
    pertama: { id: data[0].id, slug: data[0].slug, judul: data[0].judul },
    ketiga: data[2]
      ? { id: data[2].id, slug: data[2].slug, judul: data[2].judul }
      : { id: data[0].id, slug: data[0].slug, judul: data[0].judul },
    semua: data.map((m) => ({ id: m.id, slug: m.slug, judul: m.judul })),
  };
}

/** Bentuk progres valid — mengikuti skema di src/features/progres/schema.ts */
function buatProgres(modul, opsi = {}) {
  const {
    tahap1 = false,
    tahap2 = false,
    tahap3 = false,
    denganKartu = false,
    denganQuiz = false,
  } = opsi;

  const kartu = {};
  if (denganKartu) {
    // Isi status kartu agar dashboard menampilkan "kartu dikuasai"
    for (let i = 1; i <= 12; i++) {
      kartu[`kartu-contoh-${i}`] = {
        kartuId: `kartu-contoh-${i}`,
        jumlahIngat: 2,
        jumlahLupa: 0,
        terakhirDilihat: Date.now() - i * 3600_000,
      };
    }
  }

  const riwayatQuiz = denganQuiz
    ? [
        { waktu: Date.now() - 86_400_000, skor: 60, jumlahBenar: 6, jumlahSoal: 10 },
        { waktu: Date.now() - 3600_000, skor: 80, jumlahBenar: 8, jumlahSoal: 10 },
      ]
    : [];

  return {
    versi: 1,
    modul: {
      [modul.id]: {
        modulId: modul.id,
        tahap1Selesai: tahap1,
        tahap2Selesai: tahap2,
        tahap3Selesai: tahap3,
        bagianDibaca: tahap1 ? ['apa-itu-array', 'tiga-ciri-array'] : [],
        kartu,
        riwayatQuiz,
      },
    },
    // Hari aktif berurutan agar streak tampil (3 hari)
    hariAktif: [0, 1, 2].map((n) => {
      const d = new Date(Date.now() - n * 86_400_000);
      return d.toISOString().slice(0, 10);
    }),
    terakhirDiperbarui: Date.now(),
  };
}

/** Pasang progres + tema sebelum halaman dimuat */
async function siapkan(page, { progres, tema = 'terang' } = {}) {
  await page.addInitScript(
    ({ kp, kt, t, p }) => {
      localStorage.setItem(kt, t);
      if (p) localStorage.setItem(kp, JSON.stringify(p));
      else localStorage.removeItem(kp);
    },
    { kp: KUNCI_PROGRES, kt: KUNCI_TEMA, t: tema, p: progres ?? null },
  );
}

/** Tangkap satu screenshot penuh halaman */
async function tangkap(page, nama, { fullPage = true, tunggu = 2500 } = {}) {
  await page.waitForTimeout(tunggu);
  // Matikan animasi agar tidak ada elemen setengah muncul di gambar
  await page.addStyleTag({
    content: `*, *::before, *::after {
      animation-duration: 0s !important;
      animation-delay: 0s !important;
      transition-duration: 0s !important;
      transition-delay: 0s !important;
    }`,
  });
  await page.waitForTimeout(300);

  const berkas = path.join(OUT, `${nama}.png`);
  await page.screenshot({ path: berkas, fullPage });
  hasil.push(nama);
  console.log(`  ✓ ${nama}.png`);
}

async function utama() {
  await mkdir(OUT, { recursive: true });

  const browser = await chromium.launch({ headless: true });
  const konteks = await browser.newContext({
    viewport: { width: 1440, height: 900 },
    deviceScaleFactor: 1.5, // tajam untuk cetak
    locale: 'id-ID',
  });
  const page = await konteks.newPage();

  console.log('Mengambil ID modul dari Supabase…');
  const modul = await ambilModulPertama(page);
  console.log(`  modul pertama: ${modul.pertama.judul}`);
  console.log(`  modul ketiga : ${modul.ketiga.judul}`);

  /* ============================================================
     BAB 1 — Pengenalan (landing page)
     ============================================================ */
  console.log('\nBab 1 — Pengenalan');
  await siapkan(page, {});
  await page.goto(`${BASE}/`, { waitUntil: 'networkidle' });
  await tangkap(page, '01-landing-hero', { tunggu: 3000 });

  // Bagian cara kerja + kurikulum (scroll ke bawah, tangkap bagian itu)
  await page.evaluate(() => {
    document.querySelector('#cara-kerja')?.scrollIntoView({ block: 'start' });
  });
  await tangkap(page, '02-landing-cara-kerja', { fullPage: false, tunggu: 1200 });

  await page.evaluate(() => {
    document.querySelector('#kurikulum')?.scrollIntoView({ block: 'start' });
  });
  await tangkap(page, '03-landing-kurikulum', { fullPage: false, tunggu: 1200 });

  /* ============================================================
     BAB 2 — Memulai (navigasi + tema)
     ============================================================ */
  console.log('\nBab 2 — Memulai');
  await siapkan(page, { progres: buatProgres(modul.pertama) });
  await page.goto(`${BASE}/dashboard`, { waitUntil: 'networkidle' });
  await tangkap(page, '04-dashboard-terang', { tunggu: 3000 });

  // Header desktop (potongan atas)
  await page.evaluate(() => window.scrollTo(0, 0));
  await tangkap(page, '05-header-desktop', { fullPage: false, tunggu: 800 });

  // Tema gelap
  await siapkan(page, { progres: buatProgres(modul.pertama), tema: 'gelap' });
  await page.goto(`${BASE}/dashboard`, { waitUntil: 'networkidle' });
  await tangkap(page, '06-dashboard-gelap', { tunggu: 3000 });

  /* ============================================================
     BAB 3 — Tahap 1: Pahami
     ============================================================ */
  console.log('\nBab 3 — Pahami');
  await siapkan(page, { progres: buatProgres(modul.pertama) });
  await page.goto(`${BASE}/materi`, { waitUntil: 'networkidle' });
  await tangkap(page, '07-materi-daftar', { tunggu: 3000 });

  await page.goto(`${BASE}/materi/${modul.pertama.slug}`, { waitUntil: 'networkidle' });
  await tangkap(page, '08-modul-baca-atas', { tunggu: 4000 });

  // Scroll ke tengah modul (blok kode + tabel)
  await page.evaluate(() => window.scrollTo(0, 1400));
  await tangkap(page, '09-modul-blok-kode', { fullPage: false, tunggu: 1500 });

  await page.evaluate(() => window.scrollTo(0, 2800));
  await tangkap(page, '10-modul-tabel-callout', { fullPage: false, tunggu: 1500 });

  // Panel akhir modul (tombol Tandai Selesai)
  await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
  await tangkap(page, '11-modul-tandai-selesai', { fullPage: false, tunggu: 2000 });

  /* ============================================================
     BAB 4 — Tahap 2: Hafalkan
     ============================================================ */
  console.log('\nBab 4 — Hafalkan');
  // Terkunci (tahap 1 belum selesai)
  await siapkan(page, { progres: buatProgres(modul.pertama) });
  await page.goto(`${BASE}/soal`, { waitUntil: 'networkidle' });
  await tangkap(page, '12-soal-daftar-terkunci', { tunggu: 3000 });

  await page.goto(`${BASE}/soal/flashcard/${modul.pertama.slug}`, { waitUntil: 'networkidle' });
  await tangkap(page, '13-flashcard-terkunci', { tunggu: 3000 });

  // Sesi aktif (tahap 1 selesai)
  await siapkan(page, { progres: buatProgres(modul.pertama, { tahap1: true }) });
  await page.goto(`${BASE}/soal/flashcard/${modul.pertama.slug}`, { waitUntil: 'networkidle' });
  await tangkap(page, '14-flashcard-sesi-depan', { tunggu: 3500 });

  // Balik kartu
  const tombolBalik = page.getByRole('button', { name: /lihat jawaban|buka|balik/i });
  if ((await tombolBalik.count()) > 0) {
    await tombolBalik.first().click();
    await tangkap(page, '15-flashcard-sesi-belakang', { tunggu: 1500 });
  }

  // Nilai kartu (Ingat) beberapa kali untuk sampai ringkasan
  for (let i = 0; i < 24; i++) {
    const balik = page.getByRole('button', { name: /lihat jawaban|buka|balik/i });
    const ingat = page.getByRole('button', { name: /^ingat|sudah ingat/i });
    const lupa = page.getByRole('button', { name: /^lupa|belum/i });

    if ((await balik.count()) > 0 && (await balik.first().isVisible().catch(() => false))) {
      await balik.first().click().catch(() => {});
      await page.waitForTimeout(500);
    }
    if ((await ingat.count()) > 0 && (await ingat.first().isVisible().catch(() => false))) {
      // Tandai lupa di 2 kartu pertama agar putaran ulang muncul
      if (i === 0 || i === 1) {
        await lupa.first().click().catch(() => {});
      } else {
        await ingat.first().click().catch(() => {});
      }
      await page.waitForTimeout(800);
    } else {
      break;
    }
  }

  const isiSesi = await page.locator('body').innerText();
  if (/putaran|ulang/i.test(isiSesi) && !/selesai/i.test(isiSesi.slice(0, 200))) {
    await tangkap(page, '16-flashcard-putaran-ulang', { tunggu: 1200 });
    // Mulai ulangan
    const mulaiUlang = page.getByRole('button', { name: /ulang/i });
    if ((await mulaiUlang.count()) > 0) {
      await mulaiUlang.first().click().catch(() => {});
      await page.waitForTimeout(1500);
    }
  }

  // Selesaikan semua kartu ulangan
  for (let i = 0; i < 24; i++) {
    const balik = page.getByRole('button', { name: /lihat jawaban|buka|balik/i });
    const ingat = page.getByRole('button', { name: /^ingat|sudah ingat/i });
    if ((await balik.count()) > 0 && (await balik.first().isVisible().catch(() => false))) {
      await balik.first().click().catch(() => {});
      await page.waitForTimeout(400);
    }
    if ((await ingat.count()) > 0 && (await ingat.first().isVisible().catch(() => false))) {
      await ingat.first().click().catch(() => {});
      await page.waitForTimeout(700);
    } else {
      break;
    }
  }
  await tangkap(page, '17-flashcard-ringkasan', { tunggu: 2000 });

  /* ============================================================
     BAB 5 — Tahap 3: Buktikan
     ============================================================ */
  console.log('\nBab 5 — Buktikan');
  // Quiz terkunci (tahap 2 belum selesai)
  await siapkan(page, { progres: buatProgres(modul.pertama, { tahap1: true }) });
  await page.goto(`${BASE}/soal/quiz/${modul.pertama.slug}`, { waitUntil: 'networkidle' });
  await tangkap(page, '18-quiz-terkunci', { tunggu: 3000 });

  // Sesi quiz aktif (tahap 2 selesai)
  await siapkan(page, { progres: buatProgres(modul.pertama, { tahap1: true, tahap2: true }) });
  await page.goto(`${BASE}/soal/quiz/${modul.pertama.slug}`, { waitUntil: 'networkidle' });
  await tangkap(page, '19-quiz-soal-1', { tunggu: 3500 });

  // Jawab soal pertama untuk menampilkan umpan balik
  // Jawab soal pertama untuk menampilkan umpan balik.
  // Selektor: opsi jawaban adalah <button> tanpa aria-label, berada di dalam
  // grup ber-label "Pilihan jawaban" (lihat src/features/quiz/SoalPilihanGanda.tsx).
  const opsiTombol = page.getByRole('button').filter({ hasText: /^[A-D]/ });
  if ((await opsiTombol.count()) > 0) {
    await opsiTombol.first().click().catch(() => {});
    await page.waitForTimeout(1200);
    await tangkap(page, '20-quiz-umpan-balik', { tunggu: 800 });
  }

  // Selesaikan 10 soal untuk mencapai hasil
  for (let i = 0; i < 14; i++) {
    const lanjut = page.getByRole('button', { name: /lanjut|soal berikut|berikutnya/i });
    if ((await lanjut.count()) > 0 && (await lanjut.first().isVisible().catch(() => false))) {
      await lanjut.first().click().catch(() => {});
      await page.waitForTimeout(700);
    }
    const opsiKlik = page.getByRole('button').filter({ hasText: /^[A-D]/ });
    if ((await opsiKlik.count()) > 0) {
      await opsiKlik.first().click().catch(() => {});
      await page.waitForTimeout(700);
    }
    const selesai = await page.getByText(/hasil|skor|nilai/i).count();
    if (selesai > 0 && i > 8) break;
  }
  await tangkap(page, '21-quiz-hasil', { tunggu: 2500 });

  // Scroll ke analisis topik
  await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
  await tangkap(page, '22-quiz-analisis-topik', { fullPage: false, tunggu: 1200 });

  /* ============================================================
     BAB 6 — Dashboard
     ============================================================ */
  console.log('\nBab 6 — Dashboard');
  const progresLengkap = buatProgres(modul.pertama, {
    tahap1: true,
    tahap2: true,
    tahap3: true,
    denganKartu: true,
    denganQuiz: true,
  });
  // Tambah modul ketiga dengan progres sebagian untuk variasi daftar
  progresLengkap.modul[modul.ketiga.id] = {
    modulId: modul.ketiga.id,
    tahap1Selesai: true,
    tahap2Selesai: false,
    tahap3Selesai: false,
    bagianDibaca: [],
    kartu: {},
    riwayatQuiz: [],
  };

  await siapkan(page, { progres: progresLengkap });
  await page.goto(`${BASE}/dashboard`, { waitUntil: 'networkidle' });
  await tangkap(page, '23-dashboard-rekomendasi', { tunggu: 3500 });

  await page.evaluate(() => window.scrollTo(0, 700));
  await tangkap(page, '24-dashboard-ringkasan', { fullPage: false, tunggu: 1200 });

  await page.evaluate(() => window.scrollTo(0, 1500));
  await tangkap(page, '25-dashboard-daftar-modul', { fullPage: false, tunggu: 1200 });

  await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
  await tangkap(page, '26-dashboard-statistik', { fullPage: false, tunggu: 1500 });

  /* ============================================================
     BAB 7 — Video
     ============================================================ */
  console.log('\nBab 7 — Video');
  await page.goto(`${BASE}/video`, { waitUntil: 'networkidle' });
  await tangkap(page, '27-video-galeri', { tunggu: 3500 });

  // Buka pemutar jika ada
  const kartuVideo = page.locator('button').filter({ hasText: /putar|tonton/i });
  if ((await kartuVideo.count()) > 0) {
    await kartuVideo.first().click().catch(() => {});
    await tangkap(page, '28-video-pemutar', { tunggu: 2500 });
  }

  /* ============================================================
     BAB 8 — Progres & Pengaturan
     ============================================================ */
  console.log('\nBab 8 — Progres & Pengaturan');
  await siapkan(page, { progres: progresLengkap });
  await page.goto(`${BASE}/dashboard`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(3000);

  // Bagian pengaturan ada di bawah dashboard
  await page.evaluate(() => {
    const h = [...document.querySelectorAll('h2')].find((x) =>
      /pengaturan/i.test(x.textContent ?? ''),
    );
    h?.scrollIntoView({ block: 'start' });
  });
  await tangkap(page, '29-pengaturan', { fullPage: false, tunggu: 1500 });

  // Dialog reset (konfirmasi ganda)
  const tombolReset = page.getByRole('button', { name: /reset semua progres/i });
  if ((await tombolReset.count()) > 0) {
    await tombolReset.first().click().catch(() => {});
    await page.waitForTimeout(1200);
    await tangkap(page, '30-dialog-reset', { fullPage: false, tunggu: 1000 });
    // Tutup dialog
    await page.keyboard.press('Escape').catch(() => {});
    await page.waitForTimeout(800);
  }

  /* ============================================================
     BAB 9 — Pemecahan Masalah
     ============================================================ */
  console.log('\nBab 9 — Pemecahan masalah');
  // Halaman 404 sebagai contoh "tautan salah"
  await page.goto(`${BASE}/halaman-yang-tidak-ada`, { waitUntil: 'networkidle' });
  await tangkap(page, '31-halaman-404', { fullPage: false, tunggu: 2000 });

  /* ============================================================
     MOBILE — navigasi bawah
     ============================================================ */
  console.log('\nMobile — navigasi');
  const konteksMobile = await browser.newContext({
    viewport: { width: 390, height: 844 },
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
    locale: 'id-ID',
  });
  const pageMobile = await konteksMobile.newPage();
  await pageMobile.addInitScript(
    ({ kp, kt, p }) => {
      localStorage.setItem(kt, 'terang');
      if (p) localStorage.setItem(kp, JSON.stringify(p));
    },
    { kp: KUNCI_PROGRES, kt: KUNCI_TEMA, p: progresLengkap },
  );

  await pageMobile.goto(`${BASE}/dashboard`, { waitUntil: 'networkidle' });
  await pageMobile.waitForTimeout(3000);
  await pageMobile.screenshot({ path: path.join(OUT, '32-mobile-dashboard.png'), fullPage: false });
  hasil.push('32-mobile-dashboard');
  console.log('  ✓ 32-mobile-dashboard.png');

  await pageMobile.goto(`${BASE}/materi`, { waitUntil: 'networkidle' });
  await pageMobile.waitForTimeout(2500);
  await pageMobile.screenshot({ path: path.join(OUT, '33-mobile-materi.png'), fullPage: false });
  hasil.push('33-mobile-materi');
  console.log('  ✓ 33-mobile-materi.png');

  await pageMobile.goto(`${BASE}/materi/${modul.pertama.slug}`, { waitUntil: 'networkidle' });
  await pageMobile.waitForTimeout(3500);
  await pageMobile.screenshot({ path: path.join(OUT, '34-mobile-baca-modul.png'), fullPage: false });
  hasil.push('34-mobile-baca-modul');
  console.log('  ✓ 34-mobile-baca-modul.png');

  // Flashcard mobile
  await pageMobile.goto(`${BASE}/soal/flashcard/${modul.pertama.slug}`, { waitUntil: 'networkidle' });
  await pageMobile.waitForTimeout(3000);
  await pageMobile.screenshot({ path: path.join(OUT, '35-mobile-flashcard.png'), fullPage: false });
  hasil.push('35-mobile-flashcard');
  console.log('  ✓ 35-mobile-flashcard.png');

  await konteksMobile.close();
  await browser.close();

  // Tulis daftar hasil untuk dipakai build script
  await writeFile(
    path.join(OUT, 'daftar.json'),
    JSON.stringify({ dibuat: new Date().toISOString(), modul, gambar: hasil }, null, 2),
  );

  console.log(`\nSelesai — ${hasil.length} screenshot tersimpan di manual/img/`);
}

utama().catch((err) => {
  console.error('\nGAGAL:', err.message);
  process.exit(1);
});
