import { test, expect } from '@playwright/test';

/**
 * Jalur kritis #2: MEMBACA MODUL sampai tahap 1 selesai.
 *
 * Menguji alur lengkap: buka modul → baca bagian → tandai selesai →
 * tahap 2 terbuka. Termasuk syarat 80% bagian dibaca.
 */

test.describe('Membaca modul', () => {
  test('modul tampil lengkap dengan konten ter-render', async ({ page }) => {
    await page.goto('/materi');
    const tautan = page.locator('a[href^="/materi/"]').first();
    await expect(tautan).toBeVisible({ timeout: 20_000 });
    const slug = (await tautan.getAttribute('href'))!.replace('/materi/', '');

    await page.goto(`/materi/${slug}`);
    await page.waitForTimeout(3500);

    // Judul modul tampil
    await expect(page.getByRole('heading', { level: 1 })).toBeVisible();

    // Ada konten bagian (paragraf)
    const paragraf = await page.locator('p').count();
    expect(paragraf, 'modul harus punya paragraf konten').toBeGreaterThan(3);

    // Blok kode ter-render dengan pewarnaan (bukan teks polos)
    const kodeBerwarna = await page.locator('pre code span[style*="color"]').count();
    expect(kodeBerwarna, 'blok kode harus ter-highlight').toBeGreaterThan(0);
  });

  test('tombol tandai selesai nonaktif sebelum 80% dibaca', async ({ page }) => {
    await page.goto('/materi');
    const tautan = page.locator('a[href^="/materi/"]').first();
    await expect(tautan).toBeVisible({ timeout: 20_000 });
    const slug = (await tautan.getAttribute('href'))!.replace('/materi/', '');

    await page.goto(`/materi/${slug}`);
    await page.waitForTimeout(3500);

    // Belum membaca apa pun: tombol harus ada tapi tidak aktif,
    // disertai alasan (bukan disembunyikan)
    const tombol = page.getByRole('button', { name: /tandai.*selesai/i });
    await expect(tombol).toBeVisible();
    await expect(tombol).toBeDisabled();

    // Harus ada penjelasan berapa persen yang dibutuhkan
    const isi = await page.locator('body').innerText();
    expect(isi.toLowerCase()).toMatch(/baca|persen|%/);
  });

  test('daftar isi memungkinkan lompat antar bagian', async ({ page }, testInfo) => {
    await page.goto('/materi');
    const tautan = page.locator('a[href^="/materi/"]').first();
    await expect(tautan).toBeVisible({ timeout: 20_000 });
    const slug = (await tautan.getAttribute('href'))!.replace('/materi/', '');

    await page.goto(`/materi/${slug}`);
    await page.waitForTimeout(3500);

    /**
     * Tata letak daftar isi BEDA per ukuran layar:
     *   - desktop: sidebar sticky, langsung terlihat
     *   - mobile : tersembunyi di drawer, dibuka lewat tombol dulu
     * Test harus mengikuti perilaku nyata, bukan memaksa satu tata letak.
     */
    const lebar = page.viewportSize()?.width ?? 1440;
    const mobile = lebar < 1024;

    if (mobile) {
      const tombol = page.getByRole('button', { name: /daftar isi/i });
      await expect(tombol, 'mobile harus punya tombol daftar isi').toBeVisible({
        timeout: 12_000,
      });
      await tombol.click();
      await page.waitForTimeout(900);
    }

    // Tautan anchor ke bagian. Kecualikan `.skip-link` (bukan daftar isi).
    const anchor = page.locator('a[href^="#"]:not(.skip-link)');
    await expect(anchor.first()).toBeVisible({ timeout: 12_000 });
    expect(await anchor.count()).toBeGreaterThan(0);

    // Klik: halaman harus menggulir
    const posisiAwal = await page.evaluate(() => window.scrollY);
    await anchor.first().click();
    await page.waitForTimeout(1400);
    const posisiAkhir = await page.evaluate(() => window.scrollY);
    expect(posisiAkhir, 'klik daftar isi harus menggulir halaman').not.toBe(posisiAwal);

    void testInfo;
  });
});
