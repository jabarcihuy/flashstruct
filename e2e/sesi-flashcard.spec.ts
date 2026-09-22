import { test, expect, type Page } from '@playwright/test';

/**
 * Jalur kritis #3: SESI FLASHCARD (tahap Hafalkan).
 *
 * Risiko HIGH (skor 12) — algoritma prioritas menentukan kartu mana yang
 * muncul lebih dulu, dan penilaian menentukan kartu mana yang diulang.
 *
 * PERILAKU YANG DIVERIFIKASI (penting untuk dipahami):
 * progres kartu disimpan SEKALI saat sesi selesai (`fase === 'selesai'`),
 * bukan per penilaian. Jadi test tidak boleh mengharapkan localStorage
 * berubah setelah menilai satu kartu — itu bukan cara aplikasi bekerja.
 *
 * Rincian: src/features/flashcard/useSesiFlashcard.ts:78-93
 */

const KUNCI_PROGRES = 'flashstruct:progres:v1';

interface InfoModul {
  slug: string;
  id: string;
  jumlahKartu: number;
}

async function ambilModulPertama(page: Page): Promise<InfoModul> {
  const janji = page.waitForResponse(
    (r) => r.url().includes('/rest/v1/modul') && r.status() === 200,
    { timeout: 25_000 },
  );
  await page.goto('/materi');
  const respons = await janji;
  const data = (await respons.json()) as Array<{
    id: string;
    slug: string;
    flashcard: unknown[];
  }>;
  expect(data.length).toBeGreaterThan(0);
  return {
    slug: data[0]!.slug,
    id: data[0]!.id,
    jumlahKartu: data[0]!.flashcard?.length ?? 0,
  };
}

/** Buka kunci tahap 2 dengan menandai tahap 1 selesai. */
async function bukaTahap2(page: Page, info: InfoModul) {
  await page.goto('/');
  await page.waitForTimeout(1000);
  await page.evaluate(
    ({ kunci, id }) => {
      localStorage.setItem(
        kunci,
        JSON.stringify({
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
        }),
      );
    },
    { kunci: KUNCI_PROGRES, id: info.id },
  );
}

/** Balik kartu yang sedang tampil. */
async function balikKartu(page: Page) {
  const tombol = page.getByRole('button', { name: /lihat jawaban|buka|balik/i });
  await expect(tombol.first()).toBeVisible({ timeout: 12_000 });
  await tombol.first().click();
  await page.waitForTimeout(800);
}

test.describe('Sesi flashcard', () => {
  test('kartu muncul dan bisa dibalik untuk melihat jawaban', async ({ page }) => {
    const info = await ambilModulPertama(page);
    await bukaTahap2(page, info);

    await page.goto(`/soal/flashcard/${info.slug}`);
    await page.waitForTimeout(3500);

    const isi = await page.locator('body').innerText();
    expect(isi.length).toBeGreaterThan(50);

    await balikKartu(page);

    // Setelah dibalik, tombol penilaian muncul
    await expect(page.getByRole('button', { name: /ingat/i }).first()).toBeVisible({
      timeout: 10_000,
    });
    await expect(page.getByRole('button', { name: /lupa/i }).first()).toBeVisible();
  });

  test('tombol penilaian TIDAK muncul sebelum kartu dibalik', async ({ page }) => {
    const info = await ambilModulPertama(page);
    await bukaTahap2(page, info);

    await page.goto(`/soal/flashcard/${info.slug}`);
    await page.waitForTimeout(3500);

    // Ini aturan desain: pengguna harus membaca jawaban dulu
    await expect(page.getByRole('button', { name: /^ingat/i })).toHaveCount(0);
    await expect(page.getByRole('button', { name: /^lupa/i })).toHaveCount(0);
  });

  test('sesi bisa diselesaikan dan progres tersimpan', async ({ page }) => {
    // Sesi penuh butuh waktu: tiap kartu ~1,9 detik (baca + animasi keluar).
    // 20 kartu ≈ 40 detik, jadi timeout dinaikkan dari bawaan 30 detik.
    test.setTimeout(180_000);

    const info = await ambilModulPertama(page);
    await bukaTahap2(page, info);

    await page.goto(`/soal/flashcard/${info.slug}`);
    await page.waitForTimeout(3500);

    // Selesaikan seluruh kartu dengan menilai "Ingat"
    const maksimal = info.jumlahKartu;
    let dinilai = 0;

    for (let i = 0; i < maksimal; i++) {
      const tombolIngat = page.getByRole('button', { name: /^ingat/i });
      if ((await tombolIngat.count()) === 0) {
        // Kartu belum dibalik — balik dulu
        const tombolBuka = page.getByRole('button', { name: /lihat jawaban/i });
        if ((await tombolBuka.count()) === 0) break; // sesi sudah selesai
        await tombolBuka.first().click();
        await page.waitForTimeout(700);
      }
      if ((await tombolIngat.count()) === 0) break;
      await tombolIngat.first().click();
      dinilai++;
      await page.waitForTimeout(1000);
    }

    expect(dinilai, 'harus berhasil menilai setidaknya satu kartu').toBeGreaterThan(0);

    // Setelah sesi selesai, progres tersimpan
    await page.waitForTimeout(2500);
    const progres = await page.evaluate(
      (k) => JSON.parse(localStorage.getItem(k) ?? '{}'),
      KUNCI_PROGRES,
    );
    const kartuTercatat = Object.keys(progres.modul?.[info.id]?.kartu ?? {}).length;

    expect(dinilai, 'seluruh kartu harus ternilai').toBe(maksimal);
    expect(kartuTercatat, 'sesi selesai harus menyimpan progres kartu').toBeGreaterThan(0);
  });
});
