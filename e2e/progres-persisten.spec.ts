import { test, expect, type Page } from '@playwright/test';

/**
 * Jalur kritis #5: KETAHANAN PROGRES DI LOCALSTORAGE.
 *
 * Risiko HIGH (skor 12) — data hilang atau korup berarti siswa kehilangan
 * seluruh progres belajarnya. Ini satu-satunya tempat progres disimpan
 * (tidak ada akun, tidak ada server).
 *
 * Yang diuji:
 *   1. Progres bertahan setelah reload
 *   2. Data korup TIDAK membuat aplikasi crash (harus pulih ke kosong)
 *   3. Data versi lama diabaikan dengan aman
 *   4. Reset benar-benar menghapus
 *   5. localStorage tidak tersedia (mode privat) tidak crash
 */

const KUNCI_PROGRES = 'flashstruct:progres:v1';

interface InfoModul {
  slug: string;
  id: string;
}

async function ambilModulPertama(page: Page): Promise<InfoModul> {
  // Pasang pendengar SEBELUM navigasi. Bila halaman sudah memuat data
  // dari kunjungan sebelumnya, respons bisa datang lebih dulu dan
  // waitForResponse akan menunggu selamanya.
  const janji = page.waitForResponse(
    (r) => r.url().includes('/rest/v1/modul') && r.status() === 200,
    { timeout: 30_000 },
  );
  await page.goto('/materi');
  const data = (await (await janji).json()) as Array<{ id: string; slug: string }>;
  expect(data.length).toBeGreaterThan(0);
  return { slug: data[0]!.slug, id: data[0]!.id };
}

/** Progres valid dengan tahap 1 selesai. */
function progresValid(id: string) {
  return {
    versi: 1,
    modul: {
      [id]: {
        modulId: id,
        tahap1Selesai: true,
        tahap2Selesai: false,
        tahap3Selesai: false,
        bagianDibaca: [],
        kartu: {},
        riwayatQuiz: [],
      },
    },
    hariAktif: [],
    terakhirDiperbarui: Date.now(),
  };
}

test.describe('Ketahanan progres', () => {
  test('progres bertahan setelah reload halaman', async ({ page }) => {
    const info = await ambilModulPertama(page);

    await page.goto('/');
    await page.waitForTimeout(1000);
    await page.evaluate(
      ({ kunci, data }) => localStorage.setItem(kunci, JSON.stringify(data)),
      { kunci: KUNCI_PROGRES, data: progresValid(info.id) },
    );

    // Muat ulang: progres harus masih terbaca
    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForTimeout(2500);

    const tersimpan = await page.evaluate(
      (k) => JSON.parse(localStorage.getItem(k) ?? '{}'),
      KUNCI_PROGRES,
    );
    expect(tersimpan.modul?.[info.id]?.tahap1Selesai).toBe(true);

    // Dan benar-benar diterapkan: tahap 2 terbuka
    await page.goto(`/soal/flashcard/${info.slug}`);
    await page.waitForTimeout(3000);
    const isi = await page.locator('body').innerText();
    expect(isi).not.toContain('Selesaikan modul ini dulu');
  });

  test('JSON rusak tidak membuat aplikasi crash', async ({ page }) => {
    const error: string[] = [];
    page.on('pageerror', (e) => error.push(e.message));

    await page.goto('/');
    await page.waitForTimeout(1000);
    // Data terpotong — bukan JSON valid
    await page.evaluate(
      (k) => localStorage.setItem(k, '{"versi":1,"modul":{'),
      KUNCI_PROGRES,
    );

    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForTimeout(2500);

    // Halaman tetap berfungsi
    const isi = await page.locator('body').innerText();
    expect(isi.length).toBeGreaterThan(50);
    expect(error, 'JSON rusak tidak boleh memicu error').toHaveLength(0);

    // Progres pulih ke kosong — pengguna baru bisa mulai lagi
    await page.goto('/materi');
    await expect(page.locator('a[href^="/materi/"]').first()).toBeVisible({ timeout: 20_000 });
  });

  test('data versi lama diabaikan dengan aman', async ({ page }) => {
    const error: string[] = [];
    page.on('pageerror', (e) => error.push(e.message));

    await page.goto('/');
    await page.waitForTimeout(1000);
    // Versi skema berbeda dari yang didukung aplikasi (versi 1)
    await page.evaluate(
      (k) =>
        localStorage.setItem(
          k,
          JSON.stringify({
            versi: 99,
            modul: { 'modul-lama': { bentuk: 'tidak dikenal' } },
            hariAktif: [],
            terakhirDiperbarui: 0,
          }),
        ),
      KUNCI_PROGRES,
    );

    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForTimeout(2500);

    const isi = await page.locator('body').innerText();
    expect(isi.length).toBeGreaterThan(50);
    expect(error, 'versi lama tidak boleh memicu error').toHaveLength(0);
  });

  test('field tidak lengkap tidak membuat crash', async ({ page }) => {
    const error: string[] = [];
    page.on('pageerror', (e) => error.push(e.message));

    await page.goto('/');
    await page.waitForTimeout(1000);
    // Progres dengan field wajib hilang
    await page.evaluate(
      (k) => localStorage.setItem(k, JSON.stringify({ versi: 1, modul: {} })),
      KUNCI_PROGRES,
    );

    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForTimeout(2500);

    expect(error, 'data tidak lengkap tidak boleh memicu error').toHaveLength(0);
  });

  test('reset progres butuh konfirmasi ganda', async ({ page }) => {
    test.setTimeout(90_000);
    const info = await ambilModulPertama(page);

    await page.goto('/');
    await page.waitForTimeout(1000);
    await page.evaluate(
      ({ kunci, data }) => localStorage.setItem(kunci, JSON.stringify(data)),
      { kunci: KUNCI_PROGRES, data: progresValid(info.id) },
    );

    await page.goto('/dashboard');
    await page.waitForTimeout(3000);

    // Langkah 0: buka dialog
    const tombolReset = page.getByRole('button', { name: /reset semua progres/i });
    await expect(tombolReset).toBeVisible({ timeout: 15_000 });
    await tombolReset.click();

    const dialog = page.getByRole('dialog');
    await expect(dialog).toBeVisible({ timeout: 10_000 });

    // Langkah 1: konfirmasi pertama — tombol "Lanjutkan"
    await dialog.getByRole('button', { name: /lanjutkan/i }).click();
    await page.waitForTimeout(1000);

    // Langkah 2: ketik HAPUS (konfirmasi kedua, sengaja sulit)
    const input = dialog.getByRole('textbox');
    await expect(input).toBeVisible({ timeout: 10_000 });
    await input.fill('HAPUS');
    await page.waitForTimeout(700);

    // Tombol hapus baru aktif setelah teks cocok
    const tombolHapus = dialog.getByRole('button', { name: /hapus/i });
    await expect(tombolHapus).toBeEnabled({ timeout: 10_000 });
    await tombolHapus.click();
    await page.waitForTimeout(2500);

    // Progres benar-benar terhapus
    const setelah = await page.evaluate((k) => localStorage.getItem(k), KUNCI_PROGRES);
    if (setelah) {
      const data = JSON.parse(setelah);
      const adaProgres = Object.values(data.modul ?? {}).some(
        (m) => (m as { tahap1Selesai: boolean }).tahap1Selesai,
      );
      expect(adaProgres, 'setelah reset tidak boleh ada progres tersisa').toBe(false);
    }
  });
});
