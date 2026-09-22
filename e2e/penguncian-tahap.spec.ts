import { test, expect, type Page } from '@playwright/test';

/**
 * Jalur kritis #1: PENGUNCIAN TIGA TAHAP.
 *
 * Ini logika inti produk (risiko CRITICAL, skor 15 di matriks risiko).
 * Kalau penguncian bocor, siswa bisa melompat langsung ke quiz tanpa
 * membaca modul — produk kehilangan maknanya.
 *
 * Yang diuji BUKAN fungsi `statusTahap()` (sudah teruji unit), tetapi
 * apakah aturan itu benar-benar DITEGAKKAN di UI: apakah siswa benar-benar
 * tidak bisa masuk ke tahap terkunci lewat URL langsung?
 *
 * CATATAN PENTING: progres dikunci oleh modul **UUID**, bukan slug.
 * UUID diambil dari respons jaringan Supabase saat halaman materi dimuat.
 */

const KUNCI_PROGRES = 'flashstruct:progres:v1';

interface InfoModul {
  slug: string;
  id: string;
}

/** Ambil slug + UUID modul pertama lewat respons jaringan Supabase. */
async function ambilModulPertama(page: Page): Promise<InfoModul> {
  const janji = page.waitForResponse(
    (r) => r.url().includes('/rest/v1/modul') && r.status() === 200,
    { timeout: 25_000 },
  );
  await page.goto('/materi');
  const respons = await janji;
  const data = (await respons.json()) as Array<{ id: string; slug: string }>;

  expect(data.length, 'Supabase harus mengembalikan modul').toBeGreaterThan(0);
  return { slug: data[0]!.slug, id: data[0]!.id };
}

/** Tulis progres langsung ke localStorage dalam format yang benar. */
async function setProgres(page: Page, info: InfoModul, extra: Record<string, unknown>) {
  await page.goto('/');
  await page.waitForTimeout(1000);
  await page.evaluate(
    ({ kunci, id, tambahan }) => {
      localStorage.setItem(
        kunci,
        JSON.stringify({
          versi: 1,
          modul: {
            [id]: {
              modulId: id,
              tahap1Selesai: false,
              tahap2Selesai: false,
              tahap3Selesai: false,
              bagianDibaca: [],
              kartu: {},
              riwayatQuiz: [],
              ...tambahan,
            },
          },
          hariAktif: [],
          terakhirDiperbarui: Date.now(),
        }),
      );
    },
    { kunci: KUNCI_PROGRES, id: info.id, tambahan: extra },
  );
}

test.describe('Penguncian tiga tahap', () => {
  test('tahap 2 terkunci saat modul belum dibaca', async ({ page }) => {
    const info = await ambilModulPertama(page);

    // Pengguna baru: belum ada progres sama sekali
    await page.goto(`/soal/flashcard/${info.slug}`);
    await page.waitForTimeout(2500);

    const isi = await page.locator('body').innerText();
    expect(isi).toContain('Selesaikan modul ini dulu');
    await expect(page.getByRole('button', { name: /^ingat/i })).toHaveCount(0);
  });

  test('tahap 3 terkunci saat kartu belum tuntas', async ({ page }) => {
    const info = await ambilModulPertama(page);
    await setProgres(page, info, { tahap1Selesai: true });

    await page.goto(`/soal/quiz/${info.slug}`);
    await page.waitForTimeout(2500);

    const isi = await page.locator('body').innerText();
    expect(isi).toContain('Selesaikan semua kartu dulu');
  });

  test('tahap 2 terbuka setelah tahap 1 selesai', async ({ page }) => {
    const info = await ambilModulPertama(page);
    await setProgres(page, info, { tahap1Selesai: true });

    await page.goto(`/soal/flashcard/${info.slug}`);
    await page.waitForTimeout(3000);

    const isi = await page.locator('body').innerText();
    expect(isi).not.toContain('Selesaikan modul ini dulu');
  });

  test('tahap 3 terbuka setelah tahap 2 selesai', async ({ page }) => {
    const info = await ambilModulPertama(page);
    await setProgres(page, info, { tahap1Selesai: true, tahap2Selesai: true });

    await page.goto(`/soal/quiz/${info.slug}`);
    await page.waitForTimeout(3000);

    const isi = await page.locator('body').innerText();
    expect(isi).not.toContain('Selesaikan semua kartu dulu');
  });
});
