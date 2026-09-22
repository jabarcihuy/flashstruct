# QA Project Context — FlashStruct

> Sumber kebenaran untuk semua skill QA. Dibuat 2026-07-10 dari
> hasil deteksi kode + wawancara. Perbarui bila stack atau target berubah.

---

## Product

- **Name:** FlashStruct
- **Type:** Aplikasi web edukasi (media pembelajaran), bukan SaaS — tanpa autentikasi, tanpa pembayaran
- **Description:** Aplikasi belajar Struktur Data berbasis flashcard untuk mahasiswa Teknik Informatika, dengan 3 tahap terkunci berurutan: Pahami → Hafalkan → Buktikan.
- **URLs:**
  - Production: belum deploy
  - Staging: tidak ada
  - Development: http://localhost:5173
- **Key User Flows** (diurutkan berdasarkan risiko):
  1. **Membaca modul** — buka modul, baca 4-6 bagian, tandai bagian selesai. Tahap 1 selesai bila 80% bagian dibaca.
  2. **Sesi flashcard** — kartu muncul berurutan sesuai algoritma prioritas, pengguna menilai diri "Ingat"/"Lupa". Tahap 2 selesai bila semua kartu tuntas.
  3. **Quiz modul** — 10 soal pilihan ganda, skor dihitung, tahap 3 selesai bila skor ≥ ambang.
  4. **Penguncian tahap** — tahap 2 terkunci sampai tahap 1 selesai; tahap 3 terkunci sampai tahap 2 selesai. Ini inti produk.
  5. **Dashboard** — ringkasan progres, streak harian, rekomendasi modul berikutnya.
  6. **Reset progres** — dialog konfirmasi ganda, menghapus localStorage.
  7. **Ekspor/impor progres** — berkas JSON dengan validasi Zod saat impor.
  8. **Ganti tema** — terang / gelap / ikut sistem, disimpan di localStorage.

---

## Tech Stack

### Frontend
- **Framework:** React 19.3 + React Router 7.18
- **Language:** TypeScript 6.0
- **Styling:** Tailwind CSS 4.3 (token via `@theme` di `src/styles/global.css`)
- **State Management:** TanStack Query 5.103 (server state) + React Context (tema, progres)
- **Animasí:** Motion 13.4
- **Kode highlighting:** Shiki 4.4 (`shiki/core` + engine JS, hanya cpp & python)

### Backend
- **Framework:** tidak ada server sendiri — aplikasi memanggil Supabase langsung dari browser
- **Language:** SQL (PostgreSQL) untuk skema & data
- **API Style:** PostgREST (via `@supabase/supabase-js` 2.116)

### Database
- **Primary:** Supabase PostgreSQL (project ref `lxvoedfjecmmwfrfhbah`)
- **Cache:** tidak ada
- **ORM:** tidak ada — query langsung via supabase-js, validasi respons dengan Zod

### Hosting
- **Platform:** Vercel Hobby (rencana; belum deploy)
- **CDN:** Vercel Edge (bawaan)
- **Monitoring:** tidak ada

---

## Test Stack

### E2E / Integration
- **Framework:** Playwright 1.63 (baru dipasang untuk QA ini)
- **Config Location:** belum ada `playwright.config.ts`
- **Test Directory:** belum ada
- **Status:** 0 test E2E

### Unit / Component
- **Framework:** Vitest 5.0.1 + @testing-library/react + jsdom
- **Config Location:** `vite.config.ts` (blok `test`)
- **Test Directory:** berdampingan dengan sumber (`src/**/*.test.ts[x]`)
- **Jumlah:** 17 berkas, 307 test, semua lulus
- **Catatan:** `@vitest/coverage-v8` BELUM terpasang — coverage tidak terukur

### API Testing
- **Framework:** tidak ada

### Visual Testing
- **Tool:** tidak ada (tidak ada baseline screenshot)

### Performance
- **Tool:** tidak ada
- **Catatan:** bundle terukur manual — `index` 105 KB gzip, `cpp` 70 KB gzip, total ~330 KB gzip

### Accessibility
- **Tool:** @axe-core/playwright 4.11 (baru dipasang untuk QA ini)
- **Status:** 0 pelanggaran WCAG 2.2 AA di 4 kombinasi (terang/gelap × mobile/desktop)

---

## CI/CD

- **Platform:** GitHub Actions
- **Config Location:** `.github/workflows/ci.yml`
- **Test Pipeline:** dua job berurutan
  - `kualitas` (<1 menit): typecheck, lint, format:check, unit test — **memblokir**
  - `e2e` (~6 menit): Playwright di Chromium + Firefox, 99 test — **memblokir**
- **Trigger:** push ke `main`, pull request, dan `workflow_dispatch` (manual)
- **Artifacts:** `playwright-report/` + `test-results/` disimpan 7 hari saat gagal
- **Deployment:** manual (Vercel, belum dikonfigurasi)

**Status:** CI hijau dengan E2E **berjalan penuh**. Secrets Supabase
(`VITE_SUPABASE_URL`, `VITE_SUPABASE_PUBLISHABLE_KEY`) sudah diset di
repository. Bila secrets dihapus, job E2E otomatis DILEWATI dengan
peringatan — bukan gagal — dan menampilkan cara mengaktifkannya lagi.

**Durasi terukur (run 35751095163):**
- Job `kualitas`: 32 detik
- Job `e2e`: 5 menit 57 detik

---

## Environments

### Development
- **URL:** http://localhost:5173
- **Characteristics:** Vite dev server, hot reload, terhubung ke Supabase PRODUKSI (tidak ada DB terpisah untuk dev)
- **Risiko:** perubahan data uji bisa mengenai data produksi. Seed SQL diuji dulu di PostgreSQL lokal (port 5466) sebelum diterapkan.

### Staging
- **Tidak ada.**

### Production
- **Belum deploy.**

---

## Quality Goals

- **Unit Test Coverage Target:** belum ada target; 307 test ada tapi coverage belum diukur
- **E2E Coverage:** 5 jalur kritis (membaca modul, flashcard, quiz, penguncian tahap, dashboard)
- **Flakiness Threshold:** <2% (target; belum ada data)
- **Max Test Suite Duration:**
  - Unit: < 15 detik (terukur 10,5 detik)
  - E2E: < 5 menit
- **Key Metrics:**
  - Unit test pass rate 100%
  - 0 pelanggaran WCAG 2.2 AA
  - 0 error konsol di semua halaman
  - Bundle produksi < 400 KB gzip

---

## Risk Areas

> Dinilai dengan Impact × Likelihood. Dipakai `risk-based-testing` dan
> `test-strategy` untuk memprioritaskan cakupan.

| Area | Risk Level | Business Impact | Notes |
|------|-----------|-----------------|-------|
| Penguncian 3 tahap (`src/features/progres/aturan.ts`) | **Critical** | Siswa bisa lompat tahap; inti produk rusak | Logika murni, teruji unit (aturan.test.ts). BELUM ada E2E — jalur UI tidak diverifikasi |
| Konten Supabase (206 kartu, 183 soal) | **Critical** | Materi salah = siswa belajar hal yang salah | Sudah ada pemeriksa konten SQL (9 pemeriksaan). Risiko: seed dijalankan dua kali → duplikat |
| Progres di localStorage (`flashstruct:progres:v1`) | **High** | Data hilang/korup = siswa kehilangan progres | Divalidasi Zod saat baca. Risiko: kuota penuh, mode privat, data versi lama |
| Algoritma prioritas kartu (`src/features/flashcard/prioritas.ts`) | **High** | Urutan kartu salah = pengalaman belajar buruk | Teruji unit. Belum diuji dengan data progres nyata bervolume besar |
| Tema terang/gelap | **Medium** | Kontras gagal = teks tidak terbaca | Audit axe: 0 pelanggaran. Baru diperbaiki setelah menemukan 129 kegagalan kontras |
| Pemuatan konten dari Supabase | **Medium** | Gagal muat = halaman kosong tanpa penjelasan | Ada state loading/error. Perlu diverifikasi jalur gagalnya |

---

## Team

- **QA Engineers:** 0 (solo developer)
- **Total Developers:** 1
- **Dev/QA Ratio:** ∞ (solo)
- **Process:** tidak formal — kerja per milestone (M0-M9), commit terstruktur
- **QA Involvement:** developer menulis semua test
- **Team Maturity:** startup (early product, QA baru dibangun)

**Ownership model:** developer memiliki semua test. Fokus pada automation berbiaya rendah (Vitest + Playwright) dan gerbang CI, bukan regresi manual.

---

## Conventions

### Test Files
- **Naming Pattern:** `*.test.ts[x]` untuk unit; `*.spec.ts` untuk E2E (rencana)
- **Co-located or Separate:** unit berdampingan dengan sumber; E2E di `e2e/` (rencana)

### Selectors (E2E)
- **Strategy:** prioritaskan peran ARIA (`getByRole`) karena sekaligus menguji aksesibilitas
- **Fallback:** `data-testid` untuk elemen tanpa peran jelas (kartu flashcard, opsi quiz)
- **Naming Convention:** `data-testid="flashcard-tombol-ingat"` — kebab-case, bahasa Indonesia (konsisten dengan kode)

### Branching
- **Strategy:** trunk-based — commit langsung ke `main`
- **PR Requirements:** tidak ada (solo); commit message konvensional (`content(m9):`, `chore:`, `fix:`)

### Test Data
- **Strategy:** unit test pakai factory inline; E2E menyiapkan state lewat `localStorage` sebelum halaman dimuat (`addInitScript`)
- **Cleanup:** tiap test E2E memakai konteks browser bersih (isolasi bawaan Playwright)

---

## Additional Notes

### Batasan yang Sudah Diketahui
- **WebKit tidak bisa dijalankan** di mesin ini (library sistem tidak tersedia). Uji lintas browser terbatas pada Chromium + Firefox.
- **Tidak ada environment staging** — aplikasi dev memakai Supabase produksi.
- **Coverage belum terukur** — `@vitest/coverage-v8` belum terpasang.

### Standar yang Diterapkan
- **WCAG 2.2 AA** — diverifikasi dengan axe-core, 0 pelanggaran
- **Tanpa emoji** di UI/konten/dokumen — pakai ikon Lucide SVG
- **Mobile dan desktop sama-sama prioritas penuh** — bukan mobile-first, keduanya setara

### Status QA (2026-07-10)
- **Unit test:** 17 berkas, 307 test, semua lulus
- **E2E:** 6 spec, 21 test case, 99 test di 3 mesin, semua lulus (lokal)
- **Aksesibilitas:** 0 pelanggaran WCAG 2.2 AA di 2 tema
- **CI:** hijau, E2E berjalan penuh (99 test, ~6 menit)

### Temuan Audit Terakhir (2026-07-10)
Audit QA menemukan dan memperbaiki:
1. 129 kegagalan kontras di dark mode (token `--link`, `--topik-struct`, `--topik-pointer` terlalu gelap)
2. Tombol danger pakai `text-white` hardcoded → token `--on-danger`
3. Badge tint 14% menurunkan kontras → 6%
4. Skip link tidak memindahkan fokus (`<main>` tanpa `tabIndex={-1}`)
5. Blok kode & tabel bisa di-scroll tapi tidak bisa difokus keyboard
6. Tema Shiki `github-dark` gagal kontras (3.05:1) → `github-dark-high-contrast` (11.12:1)

Semua perbaikan sudah diverifikasi: 307 unit test lulus, 0 pelanggaran axe,
0 error konsol, Chromium + Firefox identik.
