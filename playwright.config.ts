import { defineConfig, devices } from '@playwright/test';

/**
 * Konfigurasi Playwright untuk FlashStruct.
 *
 * Fokus: 5 jalur kritis + aksesibilitas. BUKAN suite E2E besar —
 * strategi test membatasi E2E pada 5 spec agar umpan balik tetap cepat
 * (lihat docs/qa/strategi-test.md §3).
 *
 * Dua mesin: Chromium dan Firefox. WebKit tidak tersedia di mesin
 * pengembangan ini (library sistem tidak lengkap), dicatat sebagai
 * risiko di dokumen strategi.
 */
export default defineConfig({
  testDir: './e2e',
  /**
   * Paralelisme DIBATASI, bukan karena test saling mengganggu (tiap test
   * punya konteks browser sendiri), tetapi karena semua test memanggil
   * Supabase yang sama. Terlalu banyak permintaan serentak membuat
   * Supabase membatasi laju, dan test gagal karena timeout jaringan —
   * bukan karena bug aplikasi.
   */
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: process.env.CI ? 2 : 3,
  reporter: process.env.CI ? [['github'], ['list']] : [['list']],

  use: {
    baseURL: 'http://localhost:5173',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1440, height: 900 } },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'], viewport: { width: 1440, height: 900 } },
    },
    {
      name: 'mobile-chromium',
      use: { ...devices['Pixel 7'] },
    },
  ],

  /**
   * Dev server dijalankan otomatis. `reuseExistingServer` agar saat
   * pengembangan tidak perlu memulai ulang setiap kali menjalankan test.
   */
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
    stdout: 'ignore',
    stderr: 'pipe',
  },
});
