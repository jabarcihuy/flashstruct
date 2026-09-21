# FlashStruct — Dokumentasi Proyek

> Platform pembelajaran berbasis web untuk mata kuliah **Struktur Data** (Array, Struct, Pointer) dengan metode **flashcard** sebagai penguat hafalan.

---

## Premis Produk

Dunia TI sangat berat di praktik. Ada anggapan bahwa "kalau sudah bisa ngoding, tidak perlu hafal teori."

FlashStruct menolak premis itu. **Praktik tanpa hafalan yang kuat akan rapuh** — mahasiswa bisa menyalin kode tetapi tidak bisa menjelaskan mengapa `arr[i]` setara dengan `*(arr + i)`, atau mengapa `sizeof(struct)` tidak sama dengan jumlah `sizeof` anggota-anggotanya.

Karena itu FlashStruct memaksa hafalan tetap hidup, tetapi dengan cara yang tidak membosankan: **hafal dulu lewat modul, tempel lewat flashcard, buktikan lewat quiz.**

---

## Tiga Tahap Pembelajaran

Setiap modul dalam FlashStruct harus dilalui dalam tiga tahap berurutan. Ini bukan tiga fitur terpisah — ini satu alur yang saling mengunci.

| Tahap | Nama | Tujuan | Output |
|-------|------|--------|--------|
| **1** | Pahami | Pemaparan materi lewat modul tulis + video | Mahasiswa tahu konsepnya |
| **2** | Hafalkan | Flashcard aktif (spaced repetition sederhana) | Mahasiswa ingat detailnya |
| **3** | Buktikan | Quiz pilihan ganda + tracing kode | Mahasiswa bisa membuktikan pemahamannya |

Aturan penting: **tahap 3 terkunci sampai tahap 2 selesai**, dan tahap 2 terkunci sampai tahap 1 dibuka. Ini mencegah mahasiswa langsung menebak-nebak quiz tanpa belajar.

---

## Struktur Dokumentasi

Baca dokumen dalam urutan ini. Setiap dokumen adalah sumber kebenaran untuk topiknya — kalau ada konflik antar dokumen, dokumen dengan nomor lebih kecil yang menang.

| No | Dokumen | Isi | Untuk siapa |
|----|---------|-----|-------------|
| — | [`README.md`](./README.md) | Indeks, premis, konvensi | Semua |
| 01 | [`01-PRD.md`](./01-PRD.md) | Visi, persona, KPI, daftar fitur, non-goals | Semua |
| 02 | [`02-KURIKULUM.md`](./02-KURIKULUM.md) | Peta materi array/struct/pointer, taksonomi kartu | Penyusun konten |
| 03 | [`03-DESIGN-SYSTEM.md`](./03-DESIGN-SYSTEM.md) | Token warna, tipografi, spacing, komponen | Frontend |
| 04 | [`04-ARSITEKTUR-TEKNIS.md`](./04-ARSITEKTUR-TEKNIS.md) | Stack, struktur folder, alur data, state | Frontend/Backend |
| 05 | [`05-SKEMA-DATABASE.md`](./05-SKEMA-DATABASE.md) | DDL, RLS, query embedding, seed | Backend |
| 06 | [`06-SPESIFIKASI-HALAMAN.md`](./06-SPESIFIKASI-HALAMAN.md) | Spec 5 halaman: Dashboard, Home, Materi, Video, Soal | Frontend |
| 07 | [`07-ROADMAP.md`](./07-ROADMAP.md) | Milestone, task breakdown, estimasi | Manajemen |
| 08 | [`08-CHECKLIST-QA.md`](./08-CHECKLIST-QA.md) | Definition of Done, checklist rilis | QA |
| 09 | [`09-PANDUAN-SETUP.md`](./09-PANDUAN-SETUP.md) | Setup environment, Supabase, deploy | Semua |
| 10 | [`10-KEPUTUSAN-DEPLOY.md`](./10-KEPUTUSAN-DEPLOY.md) | Stack final, hosting gratis, batasan Vercel Hobby | Semua |
| 11 | [`11-ANALISIS-FIREBASE.md`](./11-ANALISIS-FIREBASE.md) | Analisis: bisakah Firebase menggantikan Supabase? | Semua |
| 12 | [`12-ANALISIS-NEON.md`](./12-ANALISIS-NEON.md) | Analisis: bisakah Neon menggantikan Supabase? | Semua |

Dokumen riset pendukung ada di [`riset/`](./riset/) dan **tidak perlu dibaca rutin** — hanya dirujuk saat butuh justifikasi teknis:

| Dokumen | Isi |
|---------|-----|
| `riset/01-RISET-TEKNIS.md` | Fakta Supabase, RLS, embedding, deployment, dari sumber resmi |
| `riset/02-RISET-DEPLOY-GRATIS.md` | Perbandingan hosting & database gratis, batasan komersial |
| `riset/03-RISET-NEON.md` | Fakta Neon Data API, akses browser, RLS, connection pooling |

---

## Ringkasan Keputusan yang Sudah Dikunci

Keputusan berikut sudah final untuk versi 1. Mengubahnya berarti merevisi beberapa dokumen sekaligus.

| Aspek | Keputusan | Alasan |
|-------|-----------|--------|
| **Nama** | FlashStruct | Menggabungkan "flashcard" + "structure", langsung menjelaskan produk |
| **Target** | Mahasiswa TI semester awal | Sesuai kedalaman materi dan istilah akademik |
| **Frontend** | React 19 + Vite + TypeScript | Cepat, ekosistem besar, sesuai permintaan |
| **Styling** | Tailwind CSS v4 + token CSS variable | Utility-first, konsisten dengan design system |
| **Palet warna** | Cream `#FDF4D2` · Biru `#B0CDE6` · Ungu `#A290B7` · Coklat `#946D6D` | Tiga warna non-cream dipetakan ke tiga topik; semua varian teks sudah lolos WCAG AA |
| **Routing** | React Router v7 | Standar de facto untuk SPA |
| **Data fetching** | TanStack Query v5 | Cache, retry, loading state otomatis |
| **Animasi** | Motion (Framer Motion) | Deklaratif, mendukung `prefers-reduced-motion` |
| **Backend** | Supabase (PostgreSQL + REST) | Relasional, API otomatis, tanpa server sendiri |
| **Hosting** | Vercel Hobby | Gratis, deteksi Vite otomatis, SPA rewrite didukung |
| **Database gratis** | Supabase Free | 500 MB database, 5 GB egress, API tanpa batas |
| **Autentikasi** | **Tidak ada** di v1 | Progres disimpan di `localStorage` |
| **Bahasa contoh kode** | C++ dan Python | C++ untuk kedalaman memori, Python untuk keterbacaan |
| **Kunci jawaban** | Disimpan di database, dinilai di client | Dapat diterima karena konten bersifat edukatif terbuka |
| **Docker** | **Tidak dipakai** | Supabase hosted sudah cukup; PostgreSQL lokal untuk uji skema |

**Biaya total: Rp0 per bulan.** Rincian lengkap dan peringatan batasan Vercel Hobby ada di `10-KEPUTUSAN-DEPLOY.md`.

### Catatan Konsekuensi: Tanpa Autentikasi

Karena v1 tidak punya login:

- Progres belajar **hilang jika user membersihkan data browser**, atau **tidak pindah perangkat**.
- Tidak ada fitur sosial, peringkat, atau perbandingan antar mahasiswa.
- Kunci jawaban quiz **terekspos** ke client karena tabel dibaca publik. Ini disadari dan diterima — untuk aplikasi edukatif, menahan kunci jawaban dari mahasiswa yang ingin belajar tidak memberi nilai tambah. Ini akan ditinjau ulang jika v2 menambahkan autentikasi.

---

## Konvensi Penulisan Dokumen

Agar dokumen tetap berguna saat proyek berkembang:

1. **Bahasa Indonesia** untuk narasi, **bahasa Inggris** untuk istilah teknis, nama variabel, dan nama file. Contoh: "Query ini menggunakan *foreign key embedding*."
2. **Dilarang memakai emoji** — di dokumen, UI, maupun konten. Gunakan ikon SVG Lucide (lihat `03-DESIGN-SYSTEM.md` §5) atau teks biasa.
3. **Setiap keputusan harus punya alasan.** Menulis "gunakan Tailwind" saja tidak cukup — sebutkan mengapa.
4. **Angka harus konkret.** Tulis "maks 500ms" bukan "cepat".
5. **Tandai status.** Gunakan `[FINAL]`, `[DRAFT]`, atau `[PERLU KEPUTUSAN]` di awal bagian yang relevan.
6. **Jangan duplikasi.** Kalau sebuah nilai didefinisikan di design system, dokumen lain merujuk ke sana, tidak menyalin nilainya.

---

## Alur Kerja Pengembangan

```
Riset
  |
  v
Dokumentasi
  |
  v
Setup Proyek
  |
  v
Database (skema + seed)
  |
  v
Design System (kode: token, komponen dasar)
  |
  v
Halaman Materi & Video
  |
  v
Halaman Soal (Flashcard + Quiz)
  |
  v
Halaman Dashboard
  |
  v
Halaman Home
  |
  v
QA
  |
  v
Final Polish
```

Urutan implementasi halaman mengikuti ketergantungan data: materi dibutuhkan flashcard, flashcard dibutuhkan quiz, dan dashboard butuh data dari ketiganya. Home dikerjakan terakhir karena hanya menampilkan ringkasan dari yang sudah ada.

---

## Standar Kualitas

Target minimum yang harus dicapai sebelum rilis:

| Metrik | Target | Cara ukur |
|--------|--------|-----------|
| Lighthouse Performance | ≥ 90 | Chrome DevTools |
| Lighthouse Accessibility | ≥ 95 | Chrome DevTools |
| Kontras teks | ≥ 4.5:1 | Sudah diverifikasi, lihat `03-DESIGN-SYSTEM.md` §2 |
| First Contentful Paint | < 1.8s | Lighthouse, jaringan 4G |
| Cumulative Layout Shift | < 0.1 | Lighthouse |
| Ukuran bundle awal | < 200 KB (gzip) | `vite build` |
| Animasi | 60 FPS | Chrome Performance panel |
| Keyboard navigasi | 100% fitur | Uji manual Tab/Enter/Escape |
| `prefers-reduced-motion` | Dihormati | Uji manual di OS |

---

## Catatan Teknis Penting

Tiga hal yang perlu diketahui sebelum mulai bekerja:

### 1. Proyek ini tidak memakai Docker

Pengembangan cukup dengan **Supabase hosted**, yang sudah menyediakan database siap pakai. Tidak ada container yang perlu dijalankan. Jika ingin menguji skema secara lokal, gunakan **PostgreSQL lokal langsung** — caranya ada di `09-PANDUAN-SETUP.md` §4.

### 2. RLS wajib diverifikasi, bukan hanya dijalankan

Key `publishable` Supabase selalu bisa diambil dari bundle JavaScript. Tanpa RLS yang benar, siapa pun dapat **menghapus seluruh konten**. Menjalankan SQL RLS saja tidak cukup — harus **dibuktikan dengan uji tulis dan hapus yang gagal**. Caranya ada di `05-SKEMA-DATABASE.md` §4.4.

Skema database di dokumen ini sudah diuji pada PostgreSQL 18.6 dan terbukti menolak semua operasi tulis dari role `anon`. Detail hasil pengujian ada di `05-SKEMA-DATABASE.md` §0.

### 3. Tanpa autentikasi, progres hanya tersimpan di browser

Progres belajar disimpan di `localStorage`. Konsekuensinya:

- Progres **hilang** jika data browser dibersihkan
- Progres **tidak pindah** perangkat
- Data browser berbeda di setiap browser dan domain

Ini keputusan sadar untuk v1 (lihat `01-PRD.md` §9). Mitigasinya adalah fitur ekspor/impor JSON. Skema database sudah dirancang agar penambahan autentikasi di v2 tidak memerlukan migrasi besar — lihat `05-SKEMA-DATABASE.md` §9.3.

---

## Status Dokumen

| Dokumen | Status | Catatan |
|---------|--------|---------|
| `README.md` | `[FINAL]` | — |
| `01-PRD.md` | `[FINAL]` | — |
| `02-KURIKULUM.md` | `[FINAL]` | Struktur dan angka sudah divalidasi dengan compiler nyata |
| `03-DESIGN-SYSTEM.md` | `[FINAL]` | Palet cream/biru/ungu/coklat; semua kontras sudah dihitung dan diverifikasi |
| `04-ARSITEKTUR-TEKNIS.md` | `[FINAL]` | — |
| `05-SKEMA-DATABASE.md` | `[FINAL]` | **SQL sudah diuji di PostgreSQL 18.6** — lihat §0 |
| `06-SPESIFIKASI-HALAMAN.md` | `[FINAL]` | — |
| `07-ROADMAP.md` | `[DRAFT]` | Estimasi perlu disesuaikan setelah 2 minggu kerja nyata |
| `08-CHECKLIST-QA.md` | `[FINAL]` | — |
| `09-PANDUAN-SETUP.md` | `[FINAL]` | — |
| `10-KEPUTUSAN-DEPLOY.md` | `[FINAL]` | Keputusan stack dan hosting gratis |
| `11-ANALISIS-FIREBASE.md` | `[ANALISIS]` | Jawaban "bisakah pakai Firebase?" — bisa, tapi tidak direkomendasikan |
| `12-ANALISIS-NEON.md` | `[ANALISIS]` | Jawaban "bagaimana jika pakai Neon?" — bisa, dan lebih cocok untuk idle |
| `riset/01-RISET-TEKNIS.md` | `[REFERENSI]` | Fakta dari sumber resmi; tidak perlu dibaca rutin |
| `riset/02-RISET-DEPLOY-GRATIS.md` | `[REFERENSI]` | Perbandingan hosting gratis |
| `riset/03-RISET-NEON.md` | `[REFERENSI]` | Fakta Neon Data API dari dokumentasi resmi |

`[DRAFT]` berarti dokumen sudah bisa dipakai untuk mulai bekerja, tetapi isinya masih mungkin berubah tanpa merevisi dokumen lain.

`[REFERENSI]` berarti dokumen ini adalah catatan riset pendukung — hanya dibuka saat butuh justifikasi teknis.

`[ANALISIS]` berarti dokumen ini menjawab satu pertanyaan spesifik dan tidak mengubah keputusan yang sudah dikunci.
