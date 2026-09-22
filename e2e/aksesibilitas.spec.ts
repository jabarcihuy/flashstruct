import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

/**
 * Aksesibilitas: WCAG 2.2 AA di seluruh halaman utama.
 *
 * Dijalankan di kedua tema karena kontras berbeda jauh antar tema —
 * audit pertama menemukan 129 kegagalan kontras yang HANYA muncul
 * di mode gelap. Menguji satu tema saja akan melewatkannya.
 *
 * Catatan penting: axe hanya menangkap 30-40% masalah aksesibilitas.
 * Lulus axe bukan berarti bebas masalah — uji keyboard manual tetap
 * diperlukan (lihat e2e/keyboard.spec.ts).
 */

const HALAMAN = [
  { path: '/', nama: 'Beranda' },
  { path: '/materi', nama: 'Daftar Materi' },
  { path: '/soal', nama: 'Daftar Soal' },
  { path: '/dashboard', nama: 'Dashboard' },
  { path: '/video', nama: 'Video' },
];

const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'];

for (const tema of ['terang', 'gelap'] as const) {
  test.describe(`Aksesibilitas — tema ${tema}`, () => {
    test.beforeEach(async ({ page }) => {
      // Tema harus diset SEBELUM aplikasi dimuat, agar token CSS
      // sudah benar saat render pertama.
      await page.addInitScript((t) => {
        localStorage.setItem('flashstruct:tema', t);
      }, tema);
    });

    for (const { path, nama } of HALAMAN) {
      test(`${nama} tidak punya pelanggaran WCAG 2.2 AA`, async ({ page }) => {
        await page.goto(path, { waitUntil: 'networkidle' });
        await page.waitForTimeout(2500);

        // Pastikan tema benar-benar diterapkan — kalau tidak, test
        // ini diam-diam menguji tema terang dua kali.
        const temaAktif = await page.evaluate(
          () => document.documentElement.dataset.theme,
        );
        expect(temaAktif, `tema harus "${tema}"`).toBe(tema);

        const hasil = await new AxeBuilder({ page }).withTags(TAGS).analyze();

        const ringkas = hasil.violations.map((v) => ({
          id: v.id,
          impact: v.impact,
          jumlah: v.nodes.length,
          contoh: v.nodes[0]?.target?.join(' '),
        }));

        expect(
          hasil.violations,
          `Pelanggaran di ${nama} (${tema}):\n${JSON.stringify(ringkas, null, 2)}`,
        ).toEqual([]);
      });
    }

    test(`Halaman modul tidak punya pelanggaran WCAG 2.2 AA (${tema})`, async ({ page }) => {
      // Halaman modul punya konten paling kompleks: kode, tabel,
      // callout. Diuji terpisah karena slug-nya dinamis.
      await page.goto('/materi');
      const tautan = page.locator('a[href^="/materi/"]').first();
      await expect(tautan).toBeVisible({ timeout: 20_000 });
      const slug = (await tautan.getAttribute('href'))!.replace('/materi/', '');

      await page.goto(`/materi/${slug}`, { waitUntil: 'networkidle' });
      await page.waitForTimeout(3000);

      const hasil = await new AxeBuilder({ page }).withTags(TAGS).analyze();
      const ringkas = hasil.violations.map((v) => ({
        id: v.id,
        impact: v.impact,
        jumlah: v.nodes.length,
        contoh: v.nodes[0]?.target?.join(' '),
      }));

      expect(
        hasil.violations,
        `Pelanggaran di halaman modul (${tema}):\n${JSON.stringify(ringkas, null, 2)}`,
      ).toEqual([]);
    });
  });
}

test.describe('Aksesibilitas — keyboard', () => {
  test('skip link memindahkan fokus ke konten utama', async ({ page }) => {
    await page.goto('/');
    await page.waitForTimeout(2000);

    await page.keyboard.press('Tab');
    const pertama = await page.evaluate(() => ({
      tag: document.activeElement?.tagName,
      teks: document.activeElement?.textContent?.trim().slice(0, 40),
    }));
    expect(pertama.teks).toMatch(/lewati ke konten utama/i);

    await page.keyboard.press('Enter');
    await page.waitForTimeout(900);

    // Fokus harus PINDAH ke <main>, bukan hanya menggulir.
    // Tanpa tabIndex={-1} di <main>, fokus jatuh ke <body> dan skip
    // link tidak berguna bagi pengguna keyboard.
    const fokus = await page.evaluate(() => {
      const el = document.activeElement;
      return { tag: el?.tagName, id: el?.getAttribute('id') };
    });
    expect(fokus.tag, 'fokus harus pindah ke MAIN').toBe('MAIN');
    expect(fokus.id).toBe('konten-utama');
  });

  test('semua elemen ter-fokus punya indikator visual', async ({ page }) => {
    await page.goto('/materi');
    await page.waitForTimeout(2500);

    const tanpaIndikator: string[] = [];

    for (let i = 0; i < 15; i++) {
      await page.keyboard.press('Tab');
      const info = await page.evaluate(() => {
        const el = document.activeElement;
        if (!el || el === document.body) return null;
        const cs = getComputedStyle(el);
        const punyaOutline = cs.outlineStyle !== 'none' && parseFloat(cs.outlineWidth) > 0;
        const punyaShadow = cs.boxShadow !== 'none';
        return {
          tag: el.tagName,
          teks: (el.textContent || el.getAttribute('aria-label') || '').trim().slice(0, 30),
          ok: punyaOutline || punyaShadow,
        };
      });
      if (info && !info.ok) tanpaIndikator.push(`${info.tag} "${info.teks}"`);
    }

    expect(tanpaIndikator, 'semua elemen ter-fokus harus terlihat indikatornya').toEqual([]);
  });

  test('blok kode bisa difokus keyboard untuk digulir', async ({ page }) => {
    await page.goto('/materi');
    const tautan = page.locator('a[href^="/materi/"]').first();
    await expect(tautan).toBeVisible({ timeout: 20_000 });
    const slug = (await tautan.getAttribute('href'))!.replace('/materi/', '');

    await page.goto(`/materi/${slug}`);
    await page.waitForTimeout(3500);

    // Blok kode yang bisa di-scroll horizontal harus bisa difokus.
    // Tanpa tabIndex, pengguna keyboard tidak bisa menggulir kode panjang.
    const adaRegionKode = await page.locator('[role="region"][aria-label*="Kode"]').count();
    expect(adaRegionKode, 'blok kode harus jadi region yang bisa difokus').toBeGreaterThan(0);
  });
});
