# FlashStruct

> Platform pembelajaran **Struktur Data** (Array, Struct, Pointer) berbasis flashcard.
> Pahami, hafalkan, buktikan.

---

## Premis

Dunia TI berat di praktik. Ada anggapan bahwa "kalau sudah bisa ngoding, tidak perlu hafal teori."

FlashStruct menolak premis itu. Praktik tanpa hafalan yang kuat akan rapuh — mahasiswa bisa menyalin kode, tetapi tidak bisa menjelaskan mengapa `arr[i]` setara dengan `*(arr + i)`.

Karena itu FlashStruct memaksa hafalan tetap hidup, dengan tiga tahap berurutan:

```
  1. PAHAMI        ->     2. HAFALKAN      ->     3. BUKTIKAN
  Modul + Video           Flashcard               Quiz
```

Tahap berikutnya **terkunci** sampai tahap sebelumnya selesai.

---

## Stack

| Lapisan | Teknologi |
|---------|-----------|
| Bahasa | TypeScript 6 |
| UI | React 19 |
| Build | Vite 8 |
| Routing | React Router 7 |
| Styling | Tailwind CSS 4 |
| Data | TanStack Query 5 |
| Backend | **Neon** (PostgreSQL + Data API) |
| Animasi | Motion |
| Ikon | Lucide React |
| Validasi | Zod 4 |
| Uji | Vitest 5 |
| Lint | oxlint |
| Hosting | Vercel |

**Biaya: Rp0 per bulan.**

---

## Menjalankan Proyek

### Prasyarat

- Node.js 20 atau lebih baru
- npm 10 atau lebih baru

### Langkah

```bash
# 1. Pasang dependensi
npm install

# 2. Siapkan environment variable
cp .env.example .env.local
# lalu isi VITE_SUPABASE_URL dan VITE_SUPABASE_PUBLISHABLE_KEY

# 3. Jalankan dev server
npm run dev
```

Buka `http://localhost:5173`.

**Catatan:** pada M0, aplikasi belum memakai database, jadi `.env.local` belum wajib. Baru diperlukan mulai M2 — lihat `docs/13-PANDUAN-SETUP-NEON.md` untuk menyiapkan Neon.

---

## Perintah

| Perintah | Kegunaan |
|----------|----------|
| `npm run dev` | Dev server dengan hot reload |
| `npm run build` | Build produksi ke `dist/` |
| `npm run preview` | Pratinjau hasil build |
| `npm run lint` | Periksa kode |
| `npm run lint:fix` | Perbaiki otomatis |
| `npm run typecheck` | Periksa tipe |
| `npm run test` | Jalankan uji sekali |
| `npm run test:watch` | Uji mode pantau |
| `npm run format` | Format kode dengan Prettier |

Sebelum commit, jalankan:

```bash
npm run typecheck && npm run lint && npm run test && npm run build
```

---

## Struktur Folder

```
flashstruct/
├── docs/                    # Dokumentasi lengkap proyek
├── public/                  # Aset statis
├── src/
│   ├── app/                 # Router, provider, tema
│   ├── components/
│   │   ├── ui/              # Primitif tanpa logika bisnis
│   │   ├── layout/          # Header, BottomNav, RootLayout
│   │   ├── code/            # Blok kode (M4)
│   │   └── markdown/        # Renderer markdown (M4)
│   ├── features/            # Kode per fitur
│   │   ├── materi/
│   │   ├── video/
│   │   ├── flashcard/
│   │   ├── quiz/
│   │   ├── progres/
│   │   └── dashboard/
│   ├── lib/                 # Utilitas lintas fitur
│   ├── pages/               # Satu berkas per halaman
│   ├── styles/              # Token & style global
│   ├── test/                # Setup pengujian
│   └── types/               # Tipe TypeScript
└── supabase/
    └── migrations/          # SQL migrasi (M2)
```

**Aturan struktur:**

- `components/ui/` tidak boleh punya logika bisnis
- `features/*/api.ts` adalah satu-satunya tempat query ke Neon
- `pages/` hanya menyusun, tidak berisi logika
- Tidak ada impor lintas fitur kecuali lewat `components/`

Rincian: `docs/04-ARSITEKTUR-TEKNIS.md` §2.

---

## Rute

| Rute | Halaman | Milestone |
|------|---------|-----------|
| `/` | Home | M8 |
| `/dashboard` | Dashboard | M7 |
| `/materi` | Daftar materi | M4 |
| `/materi/:slug` | Baca modul | M4 |
| `/video` | Galeri video | M4 |
| `/soal` | Pemilih mode | M5 |
| `/soal/flashcard/:slug` | Sesi flashcard | M5 |
| `/soal/quiz/:slug` | Sesi quiz | M6 |

---

## Responsif

**Mobile dan desktop sama-sama prioritas penuh** — bukan mobile sebagai versi yang dipaksakan.

| Aspek | Mobile | Desktop |
|-------|--------|---------|
| Navigasi | Bottom nav 5 ikon | Header horizontal |
| Daftar isi modul | Drawer | Sidebar sticky |
| Grid materi | 1 kolom | 3–4 kolom |
| Target sentuh | 44×44px | 40×40px cukup |

Breakpoint: 640 / 768 / 1024 / 1280px. Pendekatan mobile-first.

**Aturan:** jangan sembunyikan fitur di mobile. Jika tidak nyaman di layar kecil, rancang ulang.

Rincian: `docs/03-DESIGN-SYSTEM.md` §4.

---

## Palet Warna

| Nama | Heksadesimal | Peran |
|------|--------------|-------|
| Cream | `#FDF4D2` | Latar utama mode terang |
| Biru | `#B0CDE6` | Topik **Array** |
| Ungu | `#A290B7` | Topik **Struct**, aksi utama |
| Coklat | `#946D6D` | Topik **Pointer**, aksen |

Ketiga warna non-cream dipetakan ke tiga topik. Semua varian teks sudah diverifikasi lolos WCAG AA/AAA.

**Catatan:** palet ini pastel, jadi **tidak boleh dipakai langsung sebagai teks**. Varian turunannya didefinisikan di `src/styles/tokens.css`.

Rincian perhitungan: `docs/03-DESIGN-SYSTEM.md` §2.10.

---

## Dokumentasi

Baca dalam urutan ini. Setiap dokumen adalah sumber kebenaran untuk topiknya.

| No | Dokumen | Isi |
|----|---------|-----|
| 01 | `01-PRD.md` | Visi, persona, aturan 3 tahap, daftar fitur |
| 02 | `02-KURIKULUM.md` | Peta 10 modul, taksonomi kartu, aturan soal |
| 03 | `03-DESIGN-SYSTEM.md` | Token warna, tipografi, komponen, animasi |
| 04 | `04-ARSITEKTUR-TEKNIS.md` | Stack, struktur folder, alur data |
| 05 | `05-SKEMA-DATABASE.md` | DDL, RLS, query, seed |
| 06 | `06-SPESIFIKASI-HALAMAN.md` | Spec rinci 5 halaman |
| 07 | `07-ROADMAP.md` | 11 milestone, estimasi |
| 08 | `08-CHECKLIST-QA.md` | Definition of Done |
| 09 | `09-PANDUAN-SETUP.md` | Setup sampai deploy |
| 10 | `10-KEPUTUSAN-DEPLOY.md` | Stack final, batasan Vercel Hobby |
| 11 | `11-ANALISIS-FIREBASE.md` | Kenapa bukan Firebase |

Dokumen riset pendukung ada di `docs/riset/` — hanya dibuka saat butuh justifikasi teknis.

---

## Status Proyek

Proyek dikerjakan bertahap sesuai `docs/07-ROADMAP.md`.

| Milestone | Isi | Status |
|-----------|-----|--------|
| M0 | Persiapan proyek | Selesai |
| M1 | Fondasi visual | Belum |
| M2 | Database & data | Belum |
| M3 | Progres & penguncian | Belum |
| M4 | Materi & video | Belum |
| M5 | Flashcard | Belum |
| M6 | Quiz | Belum |
| M7 | Dashboard | Belum |
| M8 | Home | Belum |
| M9 | Isi konten | Belum |
| M10 | QA & rilis | Belum |

---

## Catatan Penting

### Tidak memakai Docker

Pengembangan cukup dengan Supabase hosted. Untuk menguji skema secara lokal, gunakan PostgreSQL lokal langsung — caranya ada di `docs/09-PANDUAN-SETUP.md` §4.

### RLS wajib diverifikasi

Key `publishable` Supabase selalu bisa diambil dari bundle JavaScript. Tanpa RLS yang benar, siapa pun dapat menghapus seluruh konten. Menjalankan SQL RLS saja tidak cukup — harus **dibuktikan** dengan uji tulis dan hapus yang gagal.

### Tanpa autentikasi di v1

Progres belajar disimpan di `localStorage`. Konsekuensinya: progres hilang jika data browser dibersihkan, dan tidak pindah perangkat. Ini keputusan sadar — lihat `docs/01-PRD.md` §9.

### Vercel Hobby hanya untuk non-komersial

Proyek ini non-komersial (tanpa iklan, tanpa monetisasi), sehingga memenuhi ketentuan Vercel Hobby. Jika nanti ada pekerja berbayar atau monetisasi, harus pindah ke Cloudflare Pages atau upgrade ke Vercel Pro.

Rincian: `docs/10-KEPUTUSAN-DEPLOY.md` §5.

### Dilarang memakai emoji

Baik di kode maupun konten. Gunakan ikon SVG Lucide atau teks biasa. Alasan dan cara menegakkannya: `docs/03-DESIGN-SYSTEM.md` §5.2.
