# Rencana Test — Sprint QA Pertama

> Dibuat 2026-07-10 · Mengacu: `.agents/qa-project-context.md`, `docs/qa/strategi-test.md`
>
> Rencana ini menutup lubang terbesar yang ditemukan audit: **0 test E2E
> untuk 5 jalur kritis**. Semua item di sini sudah dikerjakan.

---

## 1. Ruang Lingkup Sprint

**Tujuan:** menutup lubang E2E pada jalur berisiko CRITICAL dan HIGH.

**Alasan prioritas:** 307 unit test tidak menangkap satu pun dari 6 bug UI
yang ditemukan audit manual (kontras dark mode, skip link mati, blok kode
tak bisa difokus). Ini bukti bahwa lapisan E2E memang dibutuhkan.

**Tidak termasuk sprint ini:**
- Visual regression (pixel-diff) — biaya maintenance tinggi untuk solo dev
- Uji beban — tidak ada backend sendiri
- Coverage tool — dikerjakan di sprint berikutnya

---

## 2. Fitur ke Test Case

| # | Jalur Kritis | Risiko | Test Case | Berkas | Status |
|---|--------------|--------|-----------|--------|--------|
| 1 | **Penguncian 3 tahap** | CRITICAL (15) | Tahap 2 terkunci sebelum tahap 1 selesai | `e2e/penguncian-tahap.spec.ts` | Selesai |
| | | | Tahap 3 terkunci sebelum tahap 2 selesai | idem | Selesai |
| | | | Tahap 2 terbuka setelah tahap 1 selesai | idem | Selesai |
| | | | Tahap 3 terbuka setelah tahap 2 selesai | idem | Selesai |
| 2 | **Membaca modul** | CRITICAL (15) | Modul tampil lengkap, kode ter-highlight | `e2e/baca-modul.spec.ts` | Selesai |
| | | | Tombol selesai nonaktif sebelum 80% dibaca | idem | Selesai |
| | | | Daftar isi menggulir ke bagian (desktop + mobile) | idem | Selesai |
| 3 | **Sesi flashcard** | HIGH (12) | Kartu bisa dibalik, tombol nilai muncul | `e2e/sesi-flashcard.spec.ts` | Selesai |
| | | | Tombol nilai TIDAK muncul sebelum dibalik | idem | Selesai |
| | | | Sesi penuh 20 kartu menyimpan progres | idem | Selesai |
| 4 | **Quiz** | HIGH (12) | Quiz terkunci bila tahap 2 belum selesai | `e2e/quiz.spec.ts` | Selesai |
| | | | Soal tampil dengan tepat 4 opsi | idem | Selesai |
| | | | Menjawab mengunci pilihan + menandai jawaban | idem | Selesai |
| 5 | **Progres localStorage** | HIGH (12) | Progres bertahan setelah reload | `e2e/progres-persisten.spec.ts` | Selesai |
| | | | JSON rusak tidak membuat crash | idem | Selesai |
| | | | Data versi lama diabaikan aman | idem | Selesai |
| | | | Field tidak lengkap tidak crash | idem | Selesai |
| | | | Reset butuh konfirmasi ganda | idem | Selesai |
| 6 | **Aksesibilitas** | MEDIUM (9) | 0 pelanggaran WCAG 2.2 AA (2 tema × 6 halaman) | `e2e/aksesibilitas.spec.ts` | Selesai |
| | | | Skip link memindahkan fokus ke `<main>` | idem | Selesai |
| | | | Semua elemen ter-fokus punya indikator | idem | Selesai |
| | | | Blok kode bisa difokus keyboard | idem | Selesai |

**Total: 21 test case, dijalankan di 3 mesin = 99 test.**

---

## 3. Prioritas & Urutan Pengerjaan

Urutan dikerjakan berdasarkan **risiko tertinggi dulu**:

1. **Penguncian tahap** — inti produk. Kalau ini bocor, produk tidak bermakna.
2. **Progres localStorage** — data hilang = siswa marah dan tidak kembali.
3. **Baca modul** — gerbang masuk ke seluruh alur.
4. **Flashcard & quiz** — nilai inti, tapi bergantung pada 3 di atas.
5. **Aksesibilitas** — kewajiban, bukan fitur.

---

## 4. Estimasi vs Realisasi

| Item | Estimasi | Realisasi | Catatan |
|------|----------|-----------|---------|
| Konfigurasi Playwright | 30 menit | 20 menit | — |
| Spec penguncian tahap | 1 jam | 1,5 jam | Perlu cari cara ambil UUID modul |
| Spec baca modul | 45 menit | 1 jam | Daftar isi beda tata letak di mobile |
| Spec flashcard | 1 jam | 2 jam | Progres disimpan saat sesi selesai, bukan per kartu |
| Spec quiz | 45 menit | 1 jam | Selector opsi perlu disesuaikan |
| Spec progres | 1 jam | 1,5 jam | Rate limit Supabase saat paralel |
| Spec aksesibilitas | 1 jam | 1 jam | — |
| CI workflow | 30 menit | 45 menit | Perlu perbaiki lint & format dulu |
| **Total** | **7 jam** | **9,5 jam** | — |

**Pelajaran:** estimasi meleset karena asumsi tentang perilaku aplikasi
sering salah. Contoh: progres disimpan saat sesi selesai (bukan per kartu),
daftar isi beda tata letak di mobile. **Setiap test yang gagal mengajarkan
cara kerja aplikasi yang sebenarnya** — ini nilai tambah E2E di luar
sekadar mencegah regresi.

---

## 5. Bug yang Ditemukan Selama Sprint

| # | Bug | Ditemukan oleh | Perbaikan |
|---|-----|----------------|-----------|
| 1 | 129 kegagalan kontras dark mode | Audit kontras manual | Token `--link`, `--topik-struct`, `--topik-pointer` dinaikkan |
| 2 | Tombol danger `text-white` hardcoded | Audit kontras | Tambah token `--on-danger` |
| 3 | Badge tint 14% menurunkan kontras | axe-core | Turunkan tint ke 6% + border |
| 4 | Skip link tidak memindahkan fokus | Uji keyboard | `<main tabIndex={-1}>` |
| 5 | Blok kode & tabel tak bisa difokus | axe-core | Tambah `tabIndex` + `role="region"` |
| 6 | Tema Shiki `github-dark` gagal kontras 3.05:1 | Audit kontras | Ganti ke `github-dark-high-contrast` (11.12:1) |
| 7 | Lint memeriksa skill pihak ketiga | CI gagal | `ignorePatterns` di `.oxlintrc.json` |
| 8 | Vitest memungut spec Playwright | CI gagal | `include`/`exclude` di `vite.config.ts` |
| 9 | 39 file belum diformat | CI gagal | Jalankan Prettier + `.prettierignore` |
| 10 | CI menyetel `VITE_SUPABASE_ANON_KEY`, aplikasi membaca `VITE_SUPABASE_PUBLISHABLE_KEY` | CI run pertama | Nama dikoreksi + job E2E lewati bila secrets kosong |

**10 bug ditemukan, semuanya diperbaiki.** Enam di antaranya (1-6) adalah
bug UI nyata yang tidak terdeteksi 307 unit test.

---

## 6. Kriteria Keluar

| Kriteria | Target | Hasil |
|----------|--------|-------|
| Test E2E lulus | 100% | **99/99 lulus** |
| Mesin diuji | Chromium + Firefox + mobile | **3 mesin** |
| Pelanggaran WCAG 2.2 AA | 0 | **0** |
| Error konsol | 0 | **0** |
| Flaky dalam 20 jalan | 0 | 1 kali (rate limit Supabase, sudah diperbaiki) |
| Durasi E2E | < 5 menit | **8 menit** (melebihi target, lihat catatan) |
| Gerbang CI | 2 job | Dibuat, **hijau di GitHub** |
| Secrets Supabase | Diset | **SUDAH** — E2E berjalan di CI |
| E2E di CI | Berjalan | **99 test lulus, ~6 menit** |

**Catatan durasi:** 8 menit melebihi target 5 menit karena 99 test
dijalankan serial (untuk menghindari rate limit Supabase). Di CI,
`workers: 2` akan mempercepat tapi berisiko rate limit. Perlu dipantau.

---

## 7. Yang Ditunda ke Sprint Berikutnya

| Item | Alasan | Prioritas |
|------|--------|-----------|
| Coverage measurement | Butuh `@vitest/coverage-v8` | Tinggi |
| Visual regression | Biaya baseline tinggi untuk solo dev | Rendah |
| WebKit/Safari | Library sistem tidak tersedia di mesin ini | Medium |
| Uji beban | Tidak ada backend sendiri | Rendah |
| Environment staging | Aplikasi dev pakai Supabase produksi | Medium |
| Set secrets Supabase | Perlu aksi manual pemilik repo | **Tinggi** |

---

## 8. Secrets Supabase — SELESAI

Secrets sudah ditambahkan pemilik repo. E2E kini berjalan penuh di CI.

| Nama secret | Status |
|-------------|--------|
| `VITE_SUPABASE_URL` | Terpasang |
| `VITE_SUPABASE_PUBLISHABLE_KEY` | Terpasang |

**Verifikasi:** run `35751095163` — job `e2e` selesai dalam 5 menit 57 detik,
99 test lulus, 0 artifact (tidak ada kegagalan).

**Bila secrets perlu diganti:** buka repo > Settings > Secrets and
variables > Actions. Nama variabel harus **persis** seperti tabel di atas —
aplikasi membacanya di `src/lib/supabase.ts`. Nama yang salah membuat
aplikasi gagal start dan semua test E2E gagal sekaligus.

**Bila secrets hilang:** job E2E otomatis DILEWATI dengan peringatan yang
menjelaskan cara mengaktifkannya. CI tetap hijau, tetapi jalur kritis
tidak terverifikasi — ini terlihat jelas di ringkasan halaman Actions.

---

## 9. Definisi Selesai

Sprint ini selesai bila:
- [x] 5 spec jalur kritis ditulis dan lulus di 3 mesin
- [x] Spec aksesibilitas lulus di 2 tema
- [x] CI berjalan di setiap push (2 job)
- [x] Semua bug yang ditemukan diperbaiki
- [x] Dokumentasi diperbarui (konteks, strategi, rencana)
- [x] 307 unit test tetap lulus
- [x] `typecheck`, `lint`, `format:check` bersih

---

## Riwayat

| Tanggal | Perubahan |
|---------|-----------|
| 2026-07-10 | Rencana dibuat dan langsung dieksekusi dalam satu sesi |
