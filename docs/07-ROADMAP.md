# 07 — Roadmap & Rencana Kerja

> Urutan pengerjaan FlashStruct, dipecah menjadi milestone yang bisa diverifikasi.
> Status: `[DRAFT]` — estimasi perlu disesuaikan setelah 2 minggu pertama kerja nyata.

---

## 1. Prinsip Perencanaan

| Prinsip | Penerapan |
|---------|-----------|
| **Vertical slice, bukan horizontal layer** | Setiap milestone menghasilkan sesuatu yang bisa dipakai, bukan "backend selesai tapi UI kosong" |
| **Ketergantungan dulu** | Kerjakan yang tidak bergantung pada apa pun lebih awal |
| **Uji di milestone, bukan di akhir** | Setiap milestone punya kriteria "selesai" yang bisa dibuktikan |
| **Konten menyusul kode** | Satu modul contoh cukup untuk membangun seluruh UI; 9 modul sisanya diisi setelah UI stabil |
| **Tidak ada milestone tanpa output terlihat** | Kalau tidak bisa dilihat di browser, belum selesai |

**Alasan "konten menyusul kode":** menyusun 10 modul lengkap (206 kartu, 183 soal) membutuhkan waktu puluhan jam. Membangun UI dengan 1 modul contoh lebih cepat, dan setelah UI stabil, mengisi konten menjadi pekerjaan yang tidak lagi mengubah kode.

---

## 2. Peta Milestone

```
M0  Persiapan          Setup proyek, tooling, repository
 |
 v
M1  Fondasi Visual     Design token, komponen UI dasar
 |
 v
M2  Data               Skema database, Supabase, TanStack Query
 |
 v
M3  Progres            Skema Zod, store, aturan penguncian tahap
 |
 v
M4  Materi             Halaman Materi + Video (Tahap 1)
 |
 v
M5  Flashcard          Sesi flashcard lengkap (Tahap 2)
 |
 v
M6  Quiz               Sesi quiz + analisis topik (Tahap 3)
 |
 v
M7  Dashboard          Ringkasan progres + rekomendasi
 |
 v
M8  Home               Landing page
 |
 v
M9  Konten             Isi 9 modul sisanya
 |
 v
M10 Rilis              QA, performa, aksesibilitas, deploy
```

**Aturan penting:** jangan mulai milestone berikutnya sebelum kriteria "selesai" milestone saat ini terpenuhi. Melewati langkah ini menghasilkan utang teknis yang mahal.

---

## 3. Rincian Milestone

### M0 — Persiapan

**Tujuan:** proyek bisa dijalankan dengan satu perintah.

| # | Tugas | Output | Estimasi |
|---|-------|--------|----------|
| 0.1 | Buat repository + `.gitignore` | Repo ada | 15 mnt |
| 0.2 | Inisialisasi Vite + React + TypeScript | `npm run dev` jalan | 30 mnt |
| 0.3 | Pasang Tailwind CSS v4 | Kelas Tailwind berfungsi | 30 mnt |
| 0.4 | Pasang ESLint + Prettier | `npm run lint` jalan | 30 mnt |
| 0.5 | Pasang Vitest + Testing Library | `npm run test` jalan | 30 mnt |
| 0.6 | Konfigurasi alias `@/` di `tsconfig` + `vite.config` | Impor `@/lib/...` bekerja | 20 mnt |
| 0.7 | Buat `.env.example` | Template env ada | 10 mnt |
| 0.8 | Konfigurasi struktur folder dasar | Folder sesuai `04-ARSITEKTUR-TEKNIS.md` §2.2 | 30 mnt |
| 0.9 | Setup React Router dengan halaman kosong | Semua rute bisa dibuka | 45 mnt |

**Kriteria selesai:**
- [ ] `npm run dev` membuka aplikasi tanpa error
- [ ] `npm run build` menghasilkan `dist/` tanpa error
- [ ] `npm run lint` dan `npm run typecheck` bersih
- [ ] `npm run test` menjalankan (boleh 0 test)
- [ ] Semua rute di `04-ARSITEKTUR-TEKNIS.md` §5 bisa dibuka dan menampilkan judul halaman
- [ ] Alias `@/` berfungsi

**Total estimasi: ± 4 jam**

---

### M1 — Fondasi Visual

**Tujuan:** design system hidup sebagai kode, bukan hanya dokumen.

| # | Tugas | Output | Estimasi |
|---|-------|--------|----------|
| 1.1 | Tulis `styles/tokens.css` | Semua token dari `03-DESIGN-SYSTEM.md` §2.6 | 1 jam |
| 1.2 | Tulis `styles/global.css` | Reset, font, base style | 45 mnt |
| 1.3 | Konfigurasi tema Tailwind v4 dari token | Kelas `bg-surface` dll. bekerja | 45 mnt |
| 1.4 | Muat font Inter, JetBrains Mono, Space Grotesk | Font tampil benar | 30 mnt |
| 1.5 | Implementasi pengalih tema (terang/gelap/sistem) | Tema berganti dan tersimpan | 1,5 jam |
| 1.6 | Komponen `Button` (5 varian, 6 state) | Sesuai `03-DESIGN-SYSTEM.md` §6.1 | 1,5 jam |
| 1.7 | Komponen `Card`, `Badge`, `Progress` | Primitif siap | 1 jam |
| 1.8 | Komponen `Skeleton`, `EmptyState`, `ErrorState` | State kosong dan error siap | 1,5 jam |
| 1.9 | Komponen `Header`, `BottomNav` | Navigasi desktop + mobile | 2 jam |
| 1.10 | Komponen `Dialog` (dengan focus trap) | Modal siap | 2 jam |
| 1.11 | Komponen `Toast` | Notifikasi siap | 1,5 jam |
| 1.12 | Komponen `Tabs` | Tab bahasa siap | 1 jam |
| 1.13 | Halaman demo komponen (`/demo`) | Semua komponen terlihat | 1 jam |

**Kriteria selesai:**
- [ ] Semua token dari design system ada di `tokens.css`
- [ ] Tema terang dan gelap berfungsi di semua komponen
- [ ] Pengalih tema tersimpan setelah refresh
- [ ] Semua komponen punya state: default, hover, focus, disabled
- [ ] Cincin fokus terlihat pada semua elemen interaktif
- [ ] Halaman `/demo` menampilkan semua komponen di kedua tema
- [ ] Navigasi berfungsi di 375px dan 1440px
- [ ] Tidak ada scroll horizontal di 375px
- [ ] Tidak ada emoji di mana pun

**Total estimasi: ± 18 jam**

**Catatan:** halaman `/demo` dihapus sebelum rilis, atau dilindungi agar tidak diindeks.

---

### M2 — Data

**Tujuan:** konten dari database tampil di aplikasi.

| # | Tugas | Output | Estimasi |
|---|-------|--------|----------|
| 2.1 | Buat project Supabase | Project aktif | 20 mnt |
| 2.2 | Jalankan migrasi skema | Tabel dibuat | 45 mnt |
| 2.3 | Jalankan migrasi RLS | Grant + policy aktif | 30 mnt |
| 2.4 | **Verifikasi RLS dengan uji tulis** | Tulis ditolak | 30 mnt |
| 2.5 | Jalankan seed contoh dari `05-SKEMA-DATABASE.md` §6 | 8 kartu + 3 soal contoh | 30 mnt |
| 2.6 | Lengkapi modul `array-dasar` jadi 20 kartu + 18 soal | Modul pertama lengkap | 3 jam |
| 2.7 | Buat `lib/supabase.ts` | Client siap | 30 mnt |
| 2.8 | Definisikan tipe di `types/database.ts` | Tipe sesuai skema | 1 jam |
| 2.9 | Setup TanStack Query | Provider + konfigurasi | 45 mnt |
| 2.10 | Buat `features/materi/api.ts` + `hooks.ts` | Query materi | 1,5 jam |
| 2.11 | Validasi respons dengan Zod | Bentuk data terjamin | 1,5 jam |
| 2.12 | Halaman uji: tampilkan daftar modul mentah | Data tampil | 1 jam |

**Kriteria selesai:**
- [ ] Migrasi berjalan tanpa error di Supabase
- [ ] **Uji tulis ditolak** (bukti RLS aktif) — lihat `05-SKEMA-DATABASE.md` §4.4
- [ ] **Uji hapus ditolak**
- [ ] Modul `array-dasar` lengkap: 5 bagian, 20 kartu, 18 soal
- [ ] Pemeriksa konten mengembalikan 0 baris untuk modul ini
- [ ] Query `ambilDaftarModul()` mengembalikan data
- [ ] Data dari Supabase tampil di browser
- [ ] Error jaringan ditangani dengan `ErrorState`

**Total estimasi: ± 12,5 jam**

**Peringatan:** langkah 2.4 tidak boleh dilewati. Tanpa verifikasi, RLS mungkin "terlihat aktif" tapi tidak benar-benar melindungi.

**Catatan tentang seed:** seed di `05-SKEMA-DATABASE.md` §6 adalah **contoh minimal** (8 kartu, 3 soal) yang tujuannya membuktikan skema bekerja. Modul itu perlu dilengkapi menjadi 20 kartu dan 18 soal sesuai `02-KURIKULUM.md` §3.1.

**Opsional:** jika ingin memverifikasi migrasi di database lokal tanpa menyentuh Supabase, ikuti `09-PANDUAN-SETUP.md` §4 (memakai PostgreSQL lokal, tanpa Docker). Langkah ini menambah ± 1 jam tetapi memberi ketenangan sebelum menerapkan ke data nyata.

---

### M3 — Progres

**Tujuan:** progres pengguna tersimpan dan aturan penguncian bekerja.

Ini milestone paling kritis. Jika logika di sini salah, seluruh metode tiga tahap rusak.

| # | Tugas | Output | Estimasi |
|---|-------|--------|----------|
| 3.1 | Skema Zod progres (`features/progres/schema.ts`) | Validasi data | 1,5 jam |
| 3.2 | Store baca/tulis `localStorage` | Baca/tulis aman | 2 jam |
| 3.3 | `ProgresProvider` + `useProgres` | Context siap | 1,5 jam |
| 3.4 | **`aturan.ts`: `statusTahap`, `alasanTerkunci`** | Logika penguncian | 1 jam |
| 3.5 | **Uji `aturan.ts` lengkap** | 6+ test lulus | 2 jam |
| 3.6 | Fungsi tandai modul selesai | Update progres | 45 mnt |
| 3.7 | Fungsi simpan hasil sesi kartu | Update status kartu | 1,5 jam |
| 3.8 | Fungsi simpan hasil quiz | Riwayat quiz | 1 jam |
| 3.9 | Fungsi reset progres | Hapus dengan aman | 45 mnt |
| 3.10 | Fungsi ekspor/impor JSON | Backup progres | 2 jam |
| 3.11 | Perhitungan streak | Statistik | 1 jam |
| 3.12 | Uji: data korup di `localStorage` | Tidak crash | 1 jam |

**Kriteria selesai:**
- [ ] `statusTahap` lulus semua uji kasus, termasuk kasus batas
- [ ] Tahap 2 terkunci saat tahap 1 belum selesai
- [ ] Tahap 3 terkunci saat tahap 2 belum selesai
- [ ] Progres bertahan setelah browser ditutup dan dibuka
- [ ] Data korup di `localStorage` tidak membuat aplikasi crash
- [ ] Data korup disimpan sebagai salinan untuk diagnosis
- [ ] Reset progres bekerja dengan konfirmasi ganda
- [ ] Ekspor menghasilkan JSON yang bisa diimpor kembali
- [ ] Impor memvalidasi dengan Zod sebelum menerapkan

**Total estimasi: ± 18 jam**

---

### M4 — Materi

**Tujuan:** Tahap 1 berfungsi penuh.

| # | Tugas | Output | Estimasi |
|---|-------|--------|----------|
| 4.1 | Halaman daftar materi dengan filter topik | `/materi` jalan | 3 jam |
| 4.2 | Komponen `ModulCard` dengan 4 state | Sesuai design system §6.2 | 2,5 jam |
| 4.3 | Halaman baca modul (`/materi/:slug`) | Konten tampil | 3 jam |
| 4.4 | `MarkdownRenderer` + komponen kustom | Markdown tampil rapi | 3 jam |
| 4.5 | `Callout` (info/warning/danger/tip) | Callout berfungsi | 1,5 jam |
| 4.6 | Integrasi Shiki (lazy, singleton) | Kode berwarna | 2,5 jam |
| 4.7 | Komponen `CodeBlock` + tombol salin | Kode bisa disalin | 1,5 jam |
| 4.8 | Komponen `CodeTabs` (C++/Python) | Tab bahasa | 1,5 jam |
| 4.9 | `DaftarIsi` sidebar (desktop) | Navigasi bagian | 2 jam |
| 4.10 | `DaftarIsi` drawer (mobile) | Navigasi mobile | 1,5 jam |
| 4.11 | `useProgresBaca` dengan IntersectionObserver | Pelacakan baca | 2 jam |
| 4.12 | Tombol "Tandai Selesai" + validasi 80% | Gate tahap 1 | 1,5 jam |
| 4.13 | `PanelLanjut` (terkunci/dibuka) | Arah ke tahap 2 | 1 jam |
| 4.14 | Halaman Video dengan grid | `/video` jalan | 2,5 jam |
| 4.15 | `VideoPlayer` modal | Pemutar berfungsi | 2 jam |
| 4.16 | Halaman Video saat kosong | Empty state jujur | 45 mnt |

**Kriteria selesai:**
- [ ] Daftar materi menampilkan modul terkelompok per topik
- [ ] Filter topik berfungsi
- [ ] Modul bisa dibaca sampai habis
- [ ] Blok kode berwarna benar di kedua tema
- [ ] Tab C++/Python berfungsi dan bisa dioperasikan keyboard
- [ ] Tombol salin bekerja dan memberi umpan balik
- [ ] Progres baca bertambah saat scroll
- [ ] Tombol "Tandai Selesai" terkunci sampai 80%
- [ ] Teks tombol terkunci menyebutkan persentase saat ini
- [ ] Setelah selesai, panel menampilkan arah ke flashcard
- [ ] Halaman Video menampilkan video terkelompok
- [ ] Modal video bisa ditutup dengan Escape
- [ ] Scroll body terkunci saat modal terbuka
- [ ] Halaman kosong menampilkan pesan yang mengarahkan

**Total estimasi: ± 34 jam**

---

### M5 — Flashcard

**Tujuan:** Tahap 2 berfungsi penuh, termasuk penguncian ke Tahap 3.

| # | Tugas | Output | Estimasi |
|---|-------|--------|----------|
| 5.1 | Halaman pemilih mode (`/soal`) | Pilihan flashcard/quiz | 2,5 jam |
| 5.2 | Query kartu per modul | Data kartu | 1 jam |
| 5.3 | Algoritma pengurutan prioritas kartu | Kartu terurut | 2 jam |
| 5.4 | Uji algoritma pengurutan | Test lulus | 1,5 jam |
| 5.5 | `useSesiFlashcard` (reducer + state machine) | Logika sesi | 3 jam |
| 5.6 | Uji `useSesiFlashcard` | Test lulus | 2 jam |
| 5.7 | Komponen `Flashcard` + animasi flip CSS | Kartu bisa dibalik | 2,5 jam |
| 5.8 | `FlashcardFront` + `FlashcardBack` | Dua sisi kartu | 1,5 jam |
| 5.9 | `PenilaianDiri` (Lupa/Ingat) | Tombol penilaian | 1 jam |
| 5.10 | Kontrol keyboard (Space, 1, 2, Escape) | Keyboard penuh | 1,5 jam |
| 5.11 | Putaran ulang kartu lupa | Ulangan satu putaran | 1,5 jam |
| 5.12 | `RingkasanSesi` + statistik | Hasil sesi | 2 jam |
| 5.13 | Simpan hasil ke progres | Progres tersimpan | 1 jam |
| 5.14 | Dialog konfirmasi keluar | Cegah kehilangan | 1 jam |
| 5.15 | `prefers-reduced-motion` untuk flip | Aksesibilitas | 1 jam |
| 5.16 | State kosong (modul tanpa kartu) | Empty state | 45 mnt |

**Kriteria selesai:**
- [ ] Kartu diurutkan berdasarkan prioritas yang benar
- [ ] Animasi flip berjalan mulus (60 FPS)
- [ ] Tombol penilaian hanya muncul setelah kartu dibalik
- [ ] Keyboard: Space balik, 1 lupa, 2 ingat, Escape keluar
- [ ] `prefers-reduced-motion` mengganti flip dengan pergantian langsung
- [ ] Tinggi kartu tidak berubah saat dibalik
- [ ] Kartu "Lupa" muncul kembali di putaran ulang
- [ ] Ringkasan menampilkan jumlah benar dan salah
- [ ] Tahap 2 selesai hanya jika semua kartu minimal sekali "Ingat"
- [ ] Tahap 3 terbuka setelah tahap 2 selesai
- [ ] Konfirmasi muncul saat keluar di tengah sesi
- [ ] Progres kartu tersimpan setelah sesi selesai

**Total estimasi: ± 28 jam**

---

### M6 — Quiz

**Tujuan:** Tahap 3 berfungsi penuh dengan analisis topik.

| # | Tugas | Output | Estimasi |
|---|-------|--------|----------|
| 6.1 | Query soal + opsi per modul | Data soal | 1 jam |
| 6.2 | Pengacakan dan pemilihan 10 soal | Soal terpilih | 1 jam |
| 6.3 | `useSesiQuiz` (state machine) | Logika quiz | 2,5 jam |
| 6.4 | Uji `useSesiQuiz` | Test lulus | 1,5 jam |
| 6.5 | `SoalPilihanGanda` | Soal PG | 2 jam |
| 6.6 | `SoalTracing` dengan blok kode bernomor | Soal trace | 2 jam |
| 6.7 | `UmpanBalik` (benar/salah + penjelasan) | Umpan balik | 2,5 jam |
| 6.8 | `aria-live` untuk pengumuman hasil | Aksesibilitas | 45 mnt |
| 6.9 | `HasilQuiz` dengan skor besar | Halaman hasil | 2 jam |
| 6.10 | `hitungAkurasiTopik` | Analisis topik | 1,5 jam |
| 6.11 | Uji `hitungAkurasiTopik` | Test lulus | 1 jam |
| 6.12 | `AnalisisTopik` dengan bar per topik | Visualisasi | 2 jam |
| 6.13 | `RincianJawaban` (daftar semua soal) | Rincian | 1,5 jam |
| 6.14 | Simpan hasil ke progres | Riwayat tersimpan | 1 jam |
| 6.15 | Dialog konfirmasi keluar | Cegah kehilangan | 45 mnt |
| 6.16 | Pesan saat tidak lulus (nada mendukung) | Nada pesan | 45 mnt |

**Kriteria selesai:**
- [ ] 10 soal diacak dari bank soal setiap sesi
- [ ] Umpan balik muncul segera setelah menjawab
- [ ] Jawaban salah menampilkan jawaban benar + penjelasan
- [ ] Penjelasan menjelaskan mengapa pengecoh salah
- [ ] Warna benar/salah selalu disertai ikon dan teks
- [ ] Skor dihitung dengan benar
- [ ] Analisis topik diurutkan dari terlemah
- [ ] Ambang lulus 70 diterapkan
- [ ] Tahap 3 dianggap selesai meskipun tidak lulus
- [ ] Pesan saat gagal tidak menghakimi
- [ ] `aria-live` mengumumkan hasil
- [ ] Riwayat quiz tersimpan di progres
- [ ] Keyboard: 1-4 pilih opsi, Enter lanjut

**Total estimasi: ± 24 jam**

---

### M7 — Dashboard

**Tujuan:** halaman yang menjawab "apa yang harus saya kerjakan sekarang".

| # | Tugas | Output | Estimasi |
|---|-------|--------|----------|
| 7.1 | `hitungRekomendasi` (logika prioritas) | Logika rekomendasi | 2 jam |
| 7.2 | Uji `hitungRekomendasi` semua kasus | Test lulus | 2 jam |
| 7.3 | `KartuRekomendasi` | Kartu utama | 2 jam |
| 7.4 | Kasus "semua modul selesai" | State selesai | 1 jam |
| 7.5 | `StatCard` (4 kartu) | Statistik | 2 jam |
| 7.6 | Perhitungan statistik | Angka akurat | 1,5 jam |
| 7.7 | `ProgresPerTopik` (bar per topik) | Visualisasi | 1,5 jam |
| 7.8 | Daftar modul dengan pengurutan pintar | Urutan sesuai konteks | 1,5 jam |
| 7.9 | Filter topik | Filter | 45 mnt |
| 7.10 | `Pengaturan` (tema, ekspor, reset) | Pengaturan | 2 jam |
| 7.11 | `DialogResetProgres` konfirmasi ganda | Dialog aman | 1,5 jam |
| 7.12 | Tawaran ekspor sebelum reset | Cegah kehilangan | 45 mnt |

**Kriteria selesai:**
- [ ] Rekomendasi selalu menampilkan alasan, bukan hanya aksi
- [ ] Rekomendasi mengikuti urutan prioritas yang benar
- [ ] Statistik dihitung dari data nyata, bukan angka tetap
- [ ] Kartu statistik menampilkan 0 dengan ajakan bertindak saat kosong
- [ ] Modul yang sedang dikerjakan muncul di atas
- [ ] Reset memerlukan dua konfirmasi
- [ ] Dialog reset menawarkan ekspor lebih dulu
- [ ] Ekspor menghasilkan berkas JSON yang valid

**Total estimasi: ± 19 jam**

---

### M8 — Home

**Tujuan:** pengunjung baru paham produk dalam 10 detik.

| # | Tugas | Output | Estimasi |
|---|-------|--------|----------|
| 8.1 | `Hero` + logika tombol Mulai | Hero | 2,5 jam |
| 8.2 | Section "Kenapa langsung ngoding tidak cukup" | Masalah | 1,5 jam |
| 8.3 | `DiagramTigaTahap` (interaktif) | Cara kerja | 3 jam |
| 8.4 | `KartuTopik` dengan angka dari data nyata | Topik | 2 jam |
| 8.5 | `AlasanHafalan` (3 alasan konkret) | Argumen | 1,5 jam |
| 8.6 | CTA akhir | Penutup | 45 mnt |
| 8.7 | Footer | Footer | 45 mnt |
| 8.8 | Meta tag + Open Graph | SEO | 1 jam |

**Kriteria selesai:**
- [ ] Tombol "Mulai Belajar" mengarahkan sesuai kondisi progres
- [ ] Diagram tiga tahap bisa diklik dan mengarah ke halaman terkait
- [ ] Angka jumlah modul dan kartu dihitung dari data
- [ ] Tidak ada testimoni atau klaim palsu
- [ ] Animasi masuk menghormati `prefers-reduced-motion`
- [ ] Meta tag dan Open Graph ada
- [ ] Tidak ada scroll horizontal di 375px

**Total estimasi: ± 13 jam**

---

### M9 — Konten

**Tujuan:** 9 modul sisanya terisi lengkap.

| # | Modul | Bagian | Kartu | Soal | Estimasi |
|---|-------|--------|-------|------|----------|
| 9.1 | `array-multidimensi` | 4 | 16 | 15 | 6 jam |
| 9.2 | `array-dinamis` | 5 | 20 | 18 | 7 jam |
| 9.3 | `struct-dasar` | 4 | 18 | 16 | 6 jam |
| 9.4 | `struct-nested` | 5 | 20 | 18 | 7 jam |
| 9.5 | `struct-memori` | 5 | 22 | 20 | 8 jam |
| 9.6 | `pointer-dasar` | 6 | 24 | 20 | 9 jam |
| 9.7 | `pointer-array` | 5 | 22 | 20 | 8 jam |
| 9.8 | `pointer-struct` | 4 | 18 | 16 | 6 jam |
| 9.9 | `pointer-dinamis` | 6 | 26 | 22 | 10 jam |

**Kriteria selesai per modul:**
- [ ] Semua bagian terisi, bukan placeholder
- [ ] Setiap konsep punya contoh C++ dan Python
- [ ] Minimal 4 tipe kartu berbeda
- [ ] Distribusi tipe kartu sesuai `02-KURIKULUM.md` §4.3
- [ ] Setiap soal punya 4 opsi dan tepat 1 jawaban benar
- [ ] Setiap soal punya penjelasan yang menyebut mengapa pengecoh salah
- [ ] **Semua contoh kode sudah dikompilasi dan dijalankan** untuk verifikasi output
- [ ] Jebakan yang disebut di `02-KURIKULUM.md` sudah dibahas
- [ ] Pemeriksa konten mengembalikan 0 baris untuk modul ini

**Total estimasi: ± 67 jam**

**Peringatan:** jangan menulis contoh kode dari ingatan. Setiap potongan kode di modul, kartu, dan soal **wajib dijalankan** untuk memverifikasi outputnya. Pada topik pointer, satu kesalahan kecil mengajarkan konsep yang salah.

---

### M10 — Rilis

**Tujuan:** aplikasi layak dipakai publik.

| # | Tugas | Output | Estimasi |
|---|-------|--------|----------|
| 10.1 | Audit aksesibilitas lengkap | Lulus checklist | 4 jam |
| 10.2 | Audit performa (Lighthouse) | Skor terpenuhi | 3 jam |
| 10.3 | Perbaikan performa | Optimasi | 4 jam |
| 10.4 | Uji responsif 375/768/1024/1440 | Lulus semua | 2 jam |
| 10.5 | Uji kedua tema lengkap | Lulus semua | 2 jam |
| 10.6 | Uji keyboard penuh | Lulus semua | 2 jam |
| 10.7 | Uji `prefers-reduced-motion` | Lulus | 1 jam |
| 10.8 | Uji alur lengkap dari nol | Berfungsi | 2 jam |
| 10.9 | Uji data korup dan error jaringan | Tidak crash | 2 jam |
| 10.10 | Hapus halaman `/demo` | Bersih | 15 mnt |
| 10.11 | Deploy ke Vercel/Netlify | Online | 1 jam |
| 10.12 | Konfigurasi SPA rewrite | Refresh tidak 404 | 30 mnt |
| 10.13 | Uji di production | Berfungsi | 1 jam |
| 10.14 | Tulis README proyek | Dokumentasi | 2 jam |

**Kriteria selesai:**
- [ ] Lighthouse Performance ≥ 90
- [ ] Lighthouse Accessibility ≥ 95
- [ ] Semua item di `08-CHECKLIST-QA.md` tercentang
- [ ] Aplikasi dapat diakses lewat URL publik
- [ ] Refresh di rute dalam tidak menghasilkan 404
- [ ] Alur lengkap dari modul baru sampai quiz tuntas berfungsi di production
- [ ] Tidak ada error di console

**Total estimasi: ± 27 jam**

---

## 4. Ringkasan Estimasi

| Milestone | Estimasi | Kumulatif |
|-----------|----------|-----------|
| M0 Persiapan | 4 jam | 4 jam |
| M1 Fondasi Visual | 18 jam | 22 jam |
| M2 Data | 12,5 jam | 34,5 jam |
| M3 Progres | 18 jam | 52,5 jam |
| M4 Materi | 34 jam | 86,5 jam |
| M5 Flashcard | 28 jam | 114,5 jam |
| M6 Quiz | 24 jam | 138,5 jam |
| M7 Dashboard | 19 jam | 157,5 jam |
| M8 Home | 13 jam | 170,5 jam |
| M9 Konten | 67 jam | 237,5 jam |
| M10 Rilis | 27 jam | **264,5 jam** |

**Total: ± 265 jam kerja fokus.**

Dalam hitungan realistis:

| Kecepatan | Durasi |
|-----------|--------|
| 10 jam/minggu (samping kuliah) | ± 27 minggu (6–7 bulan) |
| 20 jam/minggu (serius) | ± 13 minggu (3 bulan) |
| 40 jam/minggu (penuh waktu) | ± 6,5 minggu |

**Catatan jujur:** estimasi ini mengasumsikan tidak ada hambatan tak terduga. Dalam praktiknya, tambahkan 30–50% untuk debugging, perubahan desain, dan hal-hal yang tidak terduga. **Rencanakan 8–9 bulan pada 10 jam/minggu.**

---

## 5. Jalur Cepat (Jika Butuh Demo Cepat)

Jika butuh sesuatu yang bisa didemonstrasikan lebih cepat, potong cakupan dengan urutan prioritas berikut:

### Versi Demo — 1 Modul

Target: **± 60 jam** (6 minggu pada 10 jam/minggu)

| Yang dikerjakan | Yang ditunda |
|-----------------|--------------|
| M0, M1, M2 (1 modul), M3, M4 (tanpa video), M5, M6 | Dashboard, Home, 9 modul sisanya |
| Navigasi sederhana tanpa BottomNav | Animasi lanjutan |
| Tema terang saja | Tema gelap |
| Uji minimal pada `aturan.ts` | Uji lengkap |

Hasil: satu modul yang bisa diselesaikan dari awal sampai akhir, dengan penguncian tiga tahap bekerja.

**Cukup untuk:** demonstrasi konsep, presentasi proposal, validasi ide ke dosen atau teman.

### Versi Minimum Layak — 3 Modul

Target: **± 120 jam**

Tambahkan:
- Dashboard sederhana (tanpa statistik lanjutan)
- Home sederhana (tanpa diagram interaktif)
- 3 modul (satu per topik: `array-dasar`, `struct-dasar`, `pointer-dasar`)
- Tema terang dan gelap
- Uji lengkap pada logika inti

**Cukup untuk:** rilis terbatas ke sekelompok mahasiswa, pengumpulan tugas akhir.

### Kembali ke Jalur Penuh

Setelah versi minimum stabil, tambahkan modul satu per satu. Setiap modul baru tidak mengubah kode, hanya data — inilah keuntungan memisahkan konten dari kode.

---

## 6. Urutan Jika Waktu Terbatas

Jika waktu sangat terbatas dan harus memilih, kerjakan dalam urutan ini:

| Prioritas | Pekerjaan | Alasan |
|-----------|-----------|--------|
| 1 | `aturan.ts` + uji | Jika ini salah, seluruh metode rusak |
| 2 | Skema Zod progres | Jika ini salah, pengguna kehilangan progres |
| 3 | Halaman Materi (1 modul) | Tahap 1 adalah fondasi |
| 4 | Sesi Flashcard | Inti produk — ini yang membedakan |
| 5 | Sesi Quiz | Penutup alur tiga tahap |
| 6 | Halaman Soal (pemilih) | Menghubungkan flashcard dan quiz |
| 7 | Dashboard | Berguna, tapi tidak wajib untuk belajar |
| 8 | Home | Hanya untuk pengunjung baru |
| 9 | Video | Opsional menurut PRD |
| 10 | 9 modul sisanya | Menambah nilai, tidak mengubah kode |

**Prinsip:** kerjakan yang membuat alur tiga tahap bekerja untuk satu modul lebih dulu. Setelah itu, menambah modul hanyalah menambah data.

---

## 7. Risiko Jadwal

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Penyusunan konten lebih lambat dari perkiraan | M9 molor jauh | Mulai M9 lebih awal, paralel dengan M7–M8 |
| Perubahan desain di tengah jalan | Rework besar | Kunci design system di M1, jangan ubah setelah M4 |
| Kesalahan pada `aturan.ts` ditemukan terlambat | Perbaikan mahal | Uji lengkap di M3, sebelum dipakai di M4+ |
| Supabase free tier di-pause | Situs gagal memuat | Kunjungi rutin; jadwalkan ping jika perlu |
| Contoh kode di konten salah | Kredibilitas rusak | Wajib kompilasi dan jalankan setiap contoh |
| Scope creep (menambah topik/fitur) | Tidak pernah selesai | Tegakkan Non-Goals di `01-PRD.md` §9 |

**Risiko terbesar adalah penyusunan konten (M9).** 67 jam menulis materi teknis yang akurat lebih berat dari yang terlihat. Pertimbangkan untuk menyusun 3 modul pertama lebih awal, sebagai uji coba sebelum mengikat diri pada 10 modul.

---

## 8. Yang Harus Diperiksa di Setiap Milestone

Sebelum menandai milestone selesai, periksa:

- [ ] Kriteria selesai milestone terpenuhi semua
- [ ] `npm run typecheck` bersih
- [ ] `npm run lint` bersih
- [ ] `npm run test` lulus
- [ ] `npm run build` berhasil
- [ ] Tidak ada error atau peringatan di console browser
- [ ] Diuji di 375px dan 1440px
- [ ] Diuji di kedua tema
- [ ] Diuji dengan keyboard saja
- [ ] Tidak ada emoji di kode atau konten baru
- [ ] Dokumentasi diperbarui jika ada keputusan yang berubah

---

## 9. Referensi Silang

| Topik | Dokumen |
|-------|---------|
| Cakupan fitur dan prioritas | `01-PRD.md` §4 |
| Jumlah konten per modul | `02-KURIKULUM.md` §2 |
| Komponen yang harus dibuat | `03-DESIGN-SYSTEM.md` §6 |
| Struktur folder dan alur data | `04-ARSITEKTUR-TEKNIS.md` |
| Skema dan seed | `05-SKEMA-DATABASE.md` |
| Spesifikasi halaman | `06-SPESIFIKASI-HALAMAN.md` |
| Checklist rilis | `08-CHECKLIST-QA.md` |
| Cara setup dan deploy | `09-PANDUAN-SETUP.md` |
