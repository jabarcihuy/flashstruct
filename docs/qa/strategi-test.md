# Strategi Test — FlashStruct

> Dibuat 2026-07-10 · Pemilik: jabaricihuy (solo dev) · Kalibrasi: **startup**
>
> Dokumen hidup. Tinjau ulang setiap kuartal, atau saat: ada area produk
> baru, ganti stack, atau ada bug lolos ke produksi.

---

## 1. Ruang Lingkup & Tujuan

### Dalam lingkup
- **Kode aplikasi** — React 19, TypeScript, seluruh `src/`
- **Logika inti** — penguncian 3 tahap, algoritma prioritas kartu, progres localStorage
- **Alur pengguna kritis** — 5 jalur (baca modul, flashcard, quiz, penguncian, dashboard)
- **Konten** — 206 kartu, 183 soal di Supabase (validasi skema, bukan isi)
- **Aksesibilitas** — WCAG 2.2 AA
- **Peramban** — Chromium, Firefox (WebKit tidak tersedia di mesin ini)
- **Perangkat** — mobile 390px dan desktop 1440px, keduanya prioritas setara

### Di luar lingkup
- **Kinerja beban tinggi** — aplikasi tanpa backend sendiri; beban ada di Supabase, di luar kendali kita
- **Uji penetrasi** — RLS Supabase sudah dikonfigurasi; audit keamanan terpisah
- **Visual regression (pixel-diff)** — belum sepadan biayanya untuk 1 developer
- **WebKit/Safari** — tidak bisa dijalankan di mesin ini (library sistem tidak tersedia)
- **Uji multi-bahasa** — produk hanya bahasa Indonesia

### Tujuan terukur
| # | Tujuan | Target | Tenggat | Cara ukur |
|---|--------|--------|---------|-----------|
| 1 | Cegah regresi logika inti | 100% test lulus di CI | 2 minggu | GitHub Actions |
| 2 | Verifikasi 5 jalur kritis | 5 spec E2E, 0 flaky | 4 minggu | `npx playwright test` |
| 3 | Jaga aksesibilitas | 0 pelanggaran WCAG 2.2 AA | sudah tercapai, jaga | axe-core di CI |
| 4 | Deteksi regresi konten | 0 temuan pemeriksa konten | sudah tercapai, jaga | SQL di seed |
| 5 | Umpan balik cepat | CI < 3 menit | 2 minggu | Durasi workflow |

---

## 2. Level & Jenis Test

| Level | Memvalidasi | Pemilik | Framework | Jumlah saat ini | Target | Frekuensi |
|-------|-------------|---------|-----------|-----------------|--------|-----------|
| **Unit** | Logika murni: penguncian tahap, prioritas kartu, skema Zod, format | dev | Vitest 5.0 | 307 test / 17 berkas | 350+ | Setiap push |
| **Komponen** | Render + interaksi komponen UI | dev | Testing Library | tercakup di atas | — | Setiap push |
| **E2E** | 5 jalur kritis lewat UI nyata | dev | Playwright 1.63 | **0** | 5 spec | Setiap push (terpisah) |
| **Aksesibilitas** | WCAG 2.2 AA | dev | axe-core/playwright | 0 (dijalankan manual) | 1 spec | Setiap push |
| **Konten** | Skema & kelengkapan data Supabase | dev | SQL (psql) | 9 pemeriksaan | 9 | Sebelum seed |
| **Performa** | Waktu muat, fps, ukuran bundle | dev | manual | ad-hoc | — | Per rilis |

**Tidak dipakai (dengan alasan):**
- **Contract test** — tidak ada layanan internal, hanya Supabase (pihak ketiga, diuji via E2E)
- **Visual regression** — biaya baseline maintenance tinggi untuk solo dev
- **Chaos engineering** — tidak ada infrastruktur terdistribusi

---

## 3. Analisis Piramida Test

### Bentuk saat ini

```
        E2E         0 test        (0%)     <- LUBANG
    Komponen        ~120 test    (30%)
       Unit         ~190 test    (70%)
```

**Diagnosis: hourglass** — unit banyak, E2E nol, lapisan tengah tipis.
Aplikasi punya 307 test tapi **tidak satu pun menyentuh browser nyata**.
Semua verifikasi UI sejauh ini dilakukan manual lewat skrip Playwright ad-hoc
yang tidak tersimpan sebagai test.

**Konsekuensi terukur:** audit QA hari ini menemukan **6 bug UI nyata**
(kontras dark mode, skip link mati, blok kode tak bisa difokus keyboard)
yang **tidak terdeteksi** oleh 307 unit test. Ini bukti langsung biaya dari
lubang E2E.

### Bentuk target

```
        E2E         5 spec       (5%)     <- 5 jalur kritis saja
    Komponen        ~120 test   (25%)
       Unit         ~350 test   (70%)
```

Rasio sehat untuk startup: 70% unit, 25% komponen, 5% E2E.
E2E **dibatasi 5 spec** — hanya jalur yang kegagalannya membuat produk
tidak berguna. Semua yang bisa diuji di level bawah, diuji di level bawah.

### Rencana aksi
1. **Tulis 5 spec E2E** untuk jalur kritis (lihat §4) — prioritas tertinggi
2. **Tambah a11y ke CI** — axe-core berjalan di 4 kombinasi (terang/gelap × mobile/desktop)
3. **Ukur coverage** — pasang `@vitest/coverage-v8`, target 80% pada `src/features/progres/` dan `src/features/flashcard/` (logika inti)
4. **Jangan tambah E2E** melebihi 5 spec kecuali ada jalur kritis baru

---

## 4. Matriks Risiko

Dinilai Impact (1-5) × Likelihood (1-5). Skor 1-25.

| Area | Impact | Likelihood | Skor | Band | Aksi |
|------|--------|-----------|------|------|------|
| Penguncian 3 tahap | 5 | 3 | **15** | CRITICAL | E2E wajib + unit (sudah ada) |
| Konten Supabase (206 kartu, 183 soal) | 4 | 3 | **12** | HIGH | Pemeriksa SQL (sudah ada) + cek duplikat seed |
| Progres localStorage | 4 | 3 | **12** | HIGH | Unit (sudah ada) + E2E jalur reset |
| Algoritma prioritas kartu | 3 | 4 | **12** | HIGH | Unit (sudah ada), tambah test volume besar |
| Tema & kontras | 3 | 3 | **9** | MEDIUM | axe-core di CI |
| Pemuatan konten gagal | 4 | 2 | **8** | MEDIUM | E2E jalur error |
| Ukuran bundle | 2 | 2 | **4** | LOW | Cek manual per rilis |

### 5 Spec E2E yang Ditulis (dari jalur kritis)

| # | Spec | Menguji | Risiko yang ditutup |
|---|------|---------|---------------------|
| 1 | `penguncian-tahap.spec.ts` | Tahap 2 terkunci sebelum tahap 1 selesai; tahap 3 terkunci sebelum tahap 2 selesai | CRITICAL (15) |
| 2 | `baca-modul.spec.ts` | Buka modul → baca bagian → tandai selesai → tahap 1 terbuka | CRITICAL (15) |
| 3 | `sesi-flashcard.spec.ts` | Kartu muncul → nilai Ingat/Lupa → progres tersimpan | HIGH (12) |
| 4 | `quiz.spec.ts` | Kerjakan 10 soal → skor muncul → tahap 3 selesai | HIGH (12) |
| 5 | `progres-persisten.spec.ts` | Progres bertahan setelah reload; reset menghapus; data korup tidak crash | HIGH (12) |

**Kriteria lulus tiap spec:** alur selesai tanpa error konsol, state akhir benar,
dan tidak ada overflow horizontal di mobile 390px.

**Kriteria keluar (exit criteria):**
- 5 spec lulus di Chromium **dan** Firefox
- 0 flaky dalam 20 kali jalan berturut-turut
- Total durasi E2E < 5 menit

---

## 5. Gerbang Kualitas CI

### Gerbang 1 — Setiap push/PR (wajib lulus)
```bash
npm run typecheck    # tsc --noEmit
npm run lint         # oxlint
npm run test         # vitest run (307+ test)
```
**Durasi target:** < 3 menit (terukur: typecheck 3s + lint 1s + test 11s ≈ 15 detik)

### Gerbang 2 — Setiap push (paralel, tidak memblokir)
```bash
npx playwright test  # 5 spec E2E + a11y
```
**Durasi target:** < 5 menit

### Gerbang 3 — Sebelum seed konten (manual)
```bash
psql -d uji_m9 -f supabase/seeds/00N_*.sql
# lalu jalankan 9 pemeriksa konten
```
**Wajib 0 temuan sebelum diterapkan ke Supabase.**

### Yang memblokir deploy
- Gerbang 1 gagal → **blokir**
- Gerbang 2 gagal → **blokir** (jalur kritis rusak)
- Gerbang 3 ada temuan → **blokir** (konten salah mengajari siswa)

---

## 6. Lingkungan

| Lingkungan | URL | Basis data | Catatan |
|-----------|-----|-----------|---------|
| Dev | localhost:5173 | **Supabase produksi** | Risiko: data uji mengenai produksi |
| Uji SQL | localhost:5466 | PostgreSQL lokal (`uji_m9`) | Seed diuji di sini dulu |
| Staging | — | — | Tidak ada |
| Produksi | belum deploy | Supabase produksi | — |

**Risiko lingkungan:** dev memakai Supabase produksi. Karena aplikasi hanya
membaca (tanpa autentikasi, tanpa tulis dari klien), risikonya rendah.
Seed ditulis manual via MCP setelah lolos uji lokal.

**Rekomendasi ke depan:** buat Supabase project terpisah untuk dev bila
mulai ada operasi tulis dari klien.

---

## 7. KPI & Pelacakan

| KPI | Target | Frekuensi | Cara ukur |
|-----|--------|-----------|-----------|
| Unit test pass rate | 100% | Setiap push | GitHub Actions |
| Jumlah test | Naik, tidak turun | Bulanan | `vitest run` |
| Coverage logika inti | ≥80% | Bulanan | `vitest --coverage` |
| E2E flaky rate | <2% | Bulanan | Riwayat Playwright |
| Durasi CI | <3 menit | Setiap push | GitHub Actions |
| Pelanggaran WCAG AA | 0 | Setiap push | axe-core |
| Bug lolos ke produksi | 0 | Per rilis | Manual |
| Error konsol di halaman | 0 | Setiap push | E2E assertion |

---

## 8. Prioritas Pengerjaan

### Fase 1 — Fondasi (minggu 1-2)
1. Buat `playwright.config.ts` (Chromium + Firefox, baseURL, webServer)
2. Tulis 5 spec E2E dari §4
3. Buat `.github/workflows/ci.yml` — typecheck + lint + unit test
4. Tambah job E2E (terpisah, boleh `continue-on-error` saat awal)

### Fase 2 — Ukur (minggu 3-4)
5. Pasang `@vitest/coverage-v8`, ukur baseline
6. Naikkan coverage logika inti ke 80%
7. Tambah spec a11y (axe di 4 kombinasi) ke E2E

### Fase 3 — Jaga (berkelanjutan)
8. Tinjau KPI bulanan
9. Perbarui strategi tiap kuartal
10. Tambah E2E **hanya** bila ada jalur kritis baru

---

## 9. Yang Sudah Bekerja Baik (dipertahankan)

- **Logika inti di modul terpisah** — `aturan.ts`, `prioritas.ts`, `sesi.ts` murni dan mudah diuji. Inilah alasan 307 unit test bisa ada tanpa E2E.
- **Validasi Zod saat baca** — data localStorage korup tidak membuat aplikasi crash
- **Pemeriksa konten SQL** — 9 pemeriksaan menangkap soal tanpa jawaban benar, opsi tidak 4, kartu kurang
- **Verifikasi kode materi** — setiap contoh C++/Python dikompilasi sebelum masuk konten
- **Token desain** — kontras terverifikasi di `tokens.css` dengan rasio tercatat

---

## 10. Batasan & Asumsi

- **WebKit tidak teruji** — Safari iOS tidak diverifikasi. Bila target pengguna memakai iPhone, ini risiko yang perlu ditutup (mesin dengan library WebKit, atau BrowserStack).
- **Tidak ada staging** — perubahan diuji langsung terhadap data produksi.
- **Solo dev** — tidak ada QA terpisah; semua test ditulis developer.
- **Coverage belum terukur** — 307 test ada, tapi tidak diketahui berapa persen kode tercakup.

---

## Riwayat Revisi

| Tanggal | Perubahan | Alasan |
|---------|-----------|--------|
| 2026-07-10 | Versi awal | Fondasi QA dibangun lewat `qa-start` |
