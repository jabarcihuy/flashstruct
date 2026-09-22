import { test, expect, type Page } from '@playwright/test';

/**
 * Jalur kritis #4: QUIZ (tahap Buktikan).
 *
 * Risiko HIGH (skor 12) — quiz menentukan apakah siswa lulus dan
 * riwayatnya dipakai untuk statistik akurasi per topik.
 *
 * Catatan desain: tahap 3 dianggap SELESAI apa pun nilainya. Yang
 * dikunci hanya pembukaan tahap, bukan kelulusannya.
 */

const KUNCI_PROGRES = 'flashstruct:progres:v1';

interface InfoModul {
  slug: string;
  id: string;
}

async function ambilModulPertama(page: Page): Promise<InfoModul> {
  const janji = page.waitForResponse(
    (r) => r.url().includes('/rest/v1/modul') && r.status() === 200,
    { timeout: 25_000 },
  );
  await page.goto('/materi');
  const data = (await (await janji).json()) as Array<{ id: string; slug: string }>;
  expect(data.length).toBeGreaterThan(0);
  return { slug: data[0]!.slug, id: data[0]!.id };
}

/** Buka kunci tahap 3 dengan menandai tahap 1 dan 2 selesai. */
async function bukaTahap3(page: Page, info: InfoModul) {
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
              tahap2Selesai: true,
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

test.describe('Quiz', () => {
  test('quiz terkunci bila tahap 2 belum selesai', async ({ page }) => {
    const info = await ambilModulPertama(page);

    // Hanya tahap 1 selesai
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

    await page.goto(`/soal/quiz/${info.slug}`);
    await page.waitForTimeout(3000);

    const isi = await page.locator('body').innerText();
    expect(isi).toContain('Selesaikan semua kartu dulu');
  });

  test('soal tampil dengan 4 opsi jawaban', async ({ page }) => {
    const info = await ambilModulPertama(page);
    await bukaTahap3(page, info);

    await page.goto(`/soal/quiz/${info.slug}`);
    await page.waitForTimeout(3500);

    const isi = await page.locator('body').innerText();
    expect(isi).not.toContain('Selesaikan semua kartu dulu');

    // Opsi jawaban dikelompokkan dalam role=group berlabel "Pilihan jawaban"
    const grup = page.getByRole('group', { name: /pilihan jawaban/i });
    await expect(grup).toBeVisible({ timeout: 12_000 });

    const opsi = grup.getByRole('button');
    const jumlahOpsi = await opsi.count();
    expect(jumlahOpsi, 'setiap soal harus punya 4 opsi').toBe(4);
  });

  test('menjawab soal menampilkan umpan balik dan mengunci pilihan', async ({ page }) => {
    const info = await ambilModulPertama(page);
    await bukaTahap3(page, info);

    await page.goto(`/soal/quiz/${info.slug}`);
    await page.waitForTimeout(3500);

    const grup = page.getByRole('group', { name: /pilihan jawaban/i });
    await expect(grup).toBeVisible({ timeout: 12_000 });
    const opsi = grup.getByRole('button');
    await opsi.first().click();
    await page.waitForTimeout(1600);

    // Setelah dijawab, semua opsi terkunci (tidak bisa ganti jawaban)
    const jumlahTerkunci = await grup.locator('button:disabled').count();
    expect(jumlahTerkunci, 'setelah menjawab, semua opsi harus terkunci').toBe(4);

    // Ada penanda status pada tombol yang dipilih
    const adaPenanda = await grup.locator('button[aria-pressed="true"]').count();
    expect(adaPenanda, 'opsi yang dipilih harus ditandai').toBe(1);
  });
});
