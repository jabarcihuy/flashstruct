# 04 — Arsitektur Teknis

> Stack, struktur folder, alur data, dan keputusan teknis FlashStruct.
> Status: `[FINAL]` · Justifikasi pilihan Supabase dan deployment ada di `riset/01-RISET-TEKNIS.md`.

---

## 1. Stack Teknologi

### 1.1 Daftar Lengkap

Versi berikut adalah versi terbaru yang tersedia saat dokumen ini ditulis. **Gunakan `^` pada `package.json`** agar patch dan minor update otomatis masuk, tetapi kunci major version.

| Lapisan | Teknologi | Versi | Peran |
|---------|-----------|-------|-------|
| **Bahasa** | TypeScript | ^7.0 | Bahasa utama, type safety |
| **UI** | React | ^19.3 | Perpustakaan antarmuka |
| **Build** | Vite | ^8.3 | Dev server dan bundler |
| **Routing** | React Router | ^7.18 | Navigasi SPA |
| **Styling** | Tailwind CSS | ^4.3 | Utility-first CSS |
| **Data** | TanStack Query | ^5.103 | Cache dan sinkronisasi data server |
| **Backend** | Supabase JS | ^2.116 | Client ke PostgreSQL via REST |
| **Animasi** | Motion | ^13.4 | Animasi deklaratif |
| **Ikon** | Lucide React | ^1.47 | Ikon SVG |
| **Validasi** | Zod | ^4.6 | Validasi skema runtime |
| **Markdown** | react-markdown | ^10.1 | Render konten modul |
| **Highlight** | Shiki | ^4.4 | Pewarnaan sintaks kode |
| **Uji** | Vitest | ^5.0 | Unit dan integration test |
| **Uji UI** | Testing Library | terbaru | Uji perilaku komponen |
| **Lint** | ESLint + Prettier | terbaru | Konsistensi kode |

### 1.2 Alasan Setiap Pilihan

**React + Vite, bukan Next.js**

| Faktor | React + Vite | Next.js |
|--------|--------------|---------|
| Kompleksitas | Rendah — hanya SPA | Tinggi — SSR, RSC, routing file-based |
| Kebutuhan SSR | Tidak ada | Tidak perlu; konten di balik progres, bukan untuk SEO |
| Kecepatan dev | Sangat cepat (HMR instan) | Lebih lambat |
| Deploy | Static hosting, gratis di mana saja | Butuh runtime Node atau platform khusus |

Alasan utama: **FlashStruct tidak butuh SSR.** Konten utamanya di balik penguncian tahap, dan tidak ada kebutuhan SEO untuk halaman modul individual. Menambahkan Next.js berarti menambah kompleksitas tanpa manfaat yang jelas. Jika nanti SEO menjadi penting (misalnya ingin halaman modul terindeks), migrasi ke Next.js tetap mungkin karena komponen React dapat dipindahkan.

**Tailwind CSS v4, bukan CSS Modules atau styled-components**

- Kecepatan penulisan tinggi untuk UI yang banyak variasi kecil.
- Token design system dipetakan langsung ke tema Tailwind (lihat `03-DESIGN-SYSTEM.md`).
- Hasil build hanya memuat kelas yang dipakai — bundle CSS kecil.
- v4 memakai konfigurasi berbasis CSS (`@theme`), bukan file JS terpisah.

Alasan menolak `styled-components`: menambah *runtime overhead*, dan token tetap harus dikelola manual.

**TanStack Query, bukan `useEffect` + `fetch`**

Alasan konkret: tanpa TanStack Query, setiap komponen harus mengelola `isLoading`, `isError`, `data`, retry, dan cache sendiri. Itu sekitar 40 baris kode berulang per komponen. TanStack Query menangani semuanya, termasuk:
- Cache otomatis (materi tidak di-fetch ulang setiap navigasi)
- Retry otomatis saat jaringan gagal
- Deduplikasi request bersamaan
- Status `stale` dan revalidation

**Motion, bukan CSS animation murni**

Untuk animasi sederhana, CSS sudah cukup. Motion dipakai karena:
- Flip kartu dengan state kompleks lebih mudah dikelola deklaratif
- Kontrol durasi dan easing terpusat
- Deteksi `prefers-reduced-motion` otomatis lewat `useReducedMotion()`

**Shiki, bukan Prism atau Highlight.js**

Alasan: Shiki memakai mesin TextMate yang sama dengan VS Code, menghasilkan pewarnaan yang **persis** seperti editor. Untuk aplikasi yang mengajarkan kode, akurasi pewarnaan bukan kemewahan — ini bagian dari materi.

Konsekuensi: Shiki lebih berat. Karena itu **hanya dimuat di halaman Materi dan Soal**, bukan di halaman Home atau Dashboard, dan dimuat secara *lazy*.

**Zod**

Dipakai di dua tempat:
1. Validasi data dari `localStorage` — mencegah crash jika data korup atau dari versi lama
2. Validasi bentuk respons Supabase sebelum dipakai

**Tidak memakai state management global (Redux, Zustand)**

Alasan: aplikasi ini punya dua jenis state saja:
- **State server** (materi, kartu, soal) — ditangani TanStack Query
- **State lokal pengguna** (progres, tema) — cukup React Context + hook

Menambahkan Redux berarti menambah lapisan yang tidak menyelesaikan masalah nyata.

### 1.3 Yang Sengaja TIDAK Dipakai

| Teknologi | Alasan ditolak |
|-----------|----------------|
| Next.js | Tidak butuh SSR; menambah kompleksitas |
| Redux / Zustand | Tidak ada state global kompleks |
| styled-components / Emotion | Runtime overhead; Tailwind lebih ringan |
| Prism.js / Highlight.js | Shiki lebih akurat untuk tujuan edukasi |
| Supabase Auth | v1 tanpa autentikasi (keputusan PRD) |
| GraphQL | REST Supabase sudah cukup; GraphQL menambah lapisan tanpa manfaat |
| Service worker penuh (PWA installable) | Kompleks; cukup cache konten dasar |
| i18n library | Satu bahasa saja (Indonesia) |

---

## 2. Struktur Folder

### 2.1 Prinsip

Struktur mengikuti **feature-based**, bukan type-based. Artinya berkas dikelompokkan berdasarkan fitur (`materi/`, `flashcard/`), bukan berdasarkan jenis (`components/`, `hooks/`).

Alasan: saat mengerjakan fitur flashcard, semua berkas yang relevan ada dalam satu folder. Mencari `Flashcard.tsx` di antara 60 komponen di folder `components/` jauh lebih lambat.

### 2.2 Struktur Lengkap

```
flashstruct/
├── docs/                              # Dokumentasi (folder ini)
├── public/
│   ├── favicon.svg
│   └── og-image.png                   # Gambar untuk berbagi sosial
│
├── src/
│   ├── main.tsx                       # Entry point
│   ├── App.tsx                        # Root: provider + router
│   │
│   ├── app/                           # Konfigurasi aplikasi
│   │   ├── router.tsx                 # Definisi semua rute
│   │   ├── providers.tsx              # QueryClient, Theme, Toast
│   │   └── query-client.ts            # Konfigurasi TanStack Query
│   │
│   ├── lib/                           # Utilitas lintas fitur
│   │   ├── supabase.ts                # Client Supabase (satu instance)
│   │   ├── storage.ts                 # Wrapper localStorage + Zod
│   │   ├── format.ts                  # Format tanggal, angka, persen
│   │   ├── cn.ts                      # Gabung className (clsx + tailwind-merge)
│   │   └── constants.ts               # Nilai tetap (ambang, batas)
│   │
│   ├── types/                         # Tipe TypeScript
│   │   ├── database.ts                # Tipe hasil query Supabase
│   │   ├── progres.ts                 # Tipe progres pengguna
│   │   └── quiz.ts                    # Tipe soal dan hasil
│   │
│   ├── styles/
│   │   ├── tokens.css                 # Token design system (03-DESIGN-SYSTEM.md §2.6)
│   │   ├── global.css                 # Reset, base, font
│   │   └── code.css                   # Gaya blok kode + tema Shiki
│   │
│   ├── components/                    # Komponen UI yang dipakai ulang
│   │   ├── ui/                        # Primitif (tanpa logika bisnis)
│   │   │   ├── Button.tsx
│   │   │   ├── Card.tsx
│   │   │   ├── Badge.tsx
│   │   │   ├── Progress.tsx
│   │   │   ├── Dialog.tsx
│   │   │   ├── Toast.tsx
│   │   │   ├── Skeleton.tsx
│   │   │   ├── Tabs.tsx
│   │   │   ├── EmptyState.tsx
│   │   │   └── ErrorState.tsx
│   │   │
│   │   ├── layout/
│   │   │   ├── Header.tsx
│   │   │   ├── BottomNav.tsx          # Navigasi mobile
│   │   │   ├── Container.tsx
│   │   │   └── ThemeToggle.tsx
│   │   │
│   │   ├── code/
│   │   │   ├── CodeBlock.tsx          # Blok kode + tombol salin
│   │   │   ├── CodeTabs.tsx           # Tab C++ / Python
│   │   │   └── shiki.ts               # Inisialisasi highlighter (lazy)
│   │   │
│   │   └── markdown/
│   │       ├── MarkdownRenderer.tsx   # react-markdown + komponen kustom
│   │       └── Callout.tsx            # info / warning / danger / tip
│   │
│   ├── features/                      # Kode per fitur
│   │   ├── materi/
│   │   │   ├── api.ts                 # Query Supabase
│   │   │   ├── hooks.ts               # useModul, useModulList
│   │   │   ├── ModulCard.tsx
│   │   │   ├── ModulList.tsx
│   │   │   ├── ModulReader.tsx        # Halaman baca modul
│   │   │   └── DaftarIsi.tsx          # Sidebar navigasi bagian
│   │   │
│   │   ├── video/
│   │   │   ├── api.ts
│   │   │   ├── hooks.ts
│   │   │   ├── VideoCard.tsx
│   │   │   ├── VideoGrid.tsx
│   │   │   └── VideoPlayer.tsx        # Modal pemutar tersemat
│   │   │
│   │   ├── flashcard/
│   │   │   ├── api.ts
│   │   │   ├── hooks.ts
│   │   │   ├── useSesiFlashcard.ts    # Logika sesi (state machine)
│   │   │   ├── FlashcardDeck.tsx      # Wadah sesi
│   │   │   ├── Flashcard.tsx          # Kartu tunggal + animasi flip
│   │   │   ├── FlashcardFront.tsx
│   │   │   ├── FlashcardBack.tsx
│   │   │   ├── PenilaianDiri.tsx      # Tombol Lupa / Ingat
│   │   │   └── RingkasanSesi.tsx
│   │   │
│   │   ├── quiz/
│   │   │   ├── api.ts
│   │   │   ├── hooks.ts
│   │   │   ├── useSesiQuiz.ts         # Logika sesi quiz
│   │   │   ├── QuizRunner.tsx         # Wadah pengerjaan
│   │   │   ├── SoalPilihanGanda.tsx
│   │   │   ├── SoalTracing.tsx        # Soal dengan blok kode
│   │   │   ├── UmpanBalik.tsx         # Benar/salah + penjelasan
│   │   │   ├── HasilQuiz.tsx
│   │   │   └── AnalisisTopik.tsx      # Akurasi per tipe kartu
│   │   │
│   │   ├── progres/
│   │   │   ├── schema.ts              # Skema Zod progres
│   │   │   ├── store.ts               # Baca/tulis localStorage
│   │   │   ├── ProgresProvider.tsx    # Context
│   │   │   ├── useProgres.ts          # Hook konsumsi
│   │   │   └── aturan.ts              # Logika penguncian tahap
│   │   │
│   │   └── dashboard/
│   │       ├── StatCard.tsx
│   │       ├── Rekomendasi.tsx
│   │       └── RingkasanModul.tsx
│   │
│   ├── pages/                         # Satu berkas per halaman
│   │   ├── HomePage.tsx
│   │   ├── DashboardPage.tsx
│   │   ├── MateriPage.tsx
│   │   ├── ModulDetailPage.tsx
│   │   ├── VideoPage.tsx
│   │   ├── SoalPage.tsx               # Pemilih mode
│   │   ├── FlashcardPage.tsx
│   │   ├── QuizPage.tsx
│   │   └── NotFoundPage.tsx
│   │
│   └── test/
│       ├── setup.ts
│       └── fixtures/                  # Data contoh untuk uji
│
├── supabase/
│   ├── migrations/
│   │   └── 001_initial_schema.sql
│   └── seed.sql                       # Data awal
│
├── .env.local                         # Rahasia (TIDAK di-commit)
├── .env.example                       # Template (di-commit)
├── index.html
├── package.json
├── tsconfig.json
├── vite.config.ts
├── tailwind.config.ts                 # Minimal, karena v4 pakai CSS
├── eslint.config.js
└── README.md
```

### 2.3 Aturan Struktur

| Aturan | Alasan |
|--------|--------|
| `components/ui/` tidak boleh punya logika bisnis | Harus bisa dipakai ulang di mana saja |
| `features/*/api.ts` adalah satu-satunya tempat query Supabase | Memudahkan penggantian backend di masa depan |
| `pages/` hanya menyusun, tidak berisi logika | Halaman tipis, logika di `features/` |
| Setiap folder fitur punya `hooks.ts` | Satu tempat untuk semua hook fitur itu |
| Tidak ada impor lintas fitur kecuali lewat `components/` | Mencegah ketergantungan silang yang kusut |
| `lib/` tidak boleh mengimpor dari `features/` | `lib/` adalah lapisan paling bawah |

---

## 3. Alur Data

### 3.1 Dua Sumber Data

```
┌──────────────────────────────────────────────────────────────┐
│                     SUMBER DATA                              │
├──────────────────────────┬───────────────────────────────────┤
│   SUPABASE (jauh)        │   LOCALSTORAGE (lokal)            │
│                          │                                   │
│   - modul                │   - modul selesai                 │
│   - bagian_modul         │   - status kartu (ingat/lupa)     │
│   - video                │   - riwayat quiz                  │
│   - flashcard            │   - tema terang/gelap             │
│   - soal                 │                                   │
│                          │                                   │
│   Sifat: baca saja       │   Sifat: baca + tulis             │
│   Berubah: jarang        │   Berubah: terus                   │
│   Cache: TanStack Query  │   Cache: React Context            │
└──────────────────────────┴───────────────────────────────────┘
```

**Aturan pembagian yang jelas:** konten yang sama untuk semua orang ada di Supabase; data yang khas per pengguna ada di `localStorage`. Tidak ada data yang disimpan di dua tempat.

### 3.2 Alur Membaca Materi

```
User buka /materi/pointer-dasar
        |
        v
ModulDetailPage
        |
        v
useModul('pointer-dasar')              <- features/materi/hooks.ts
        |
        v
TanStack Query cek cache
        |
   ┌────┴────┐
   |         |
 Ada       Tidak ada
   |         |
   |         v
   |   materi/api.ts
   |         |
   |         v
   |   supabase.from('modul')
   |     .select(`*, bagian_modul(*), video(*)`)
   |     .eq('slug', 'pointer-dasar')
   |     .single()
   |         |
   |         v
   |   Zod validasi bentuk respons
   |         |
   |         v
   |   Simpan ke cache (staleTime: 5 menit)
   |         |
   └────┬────┘
        v
Render ModulReader + DaftarIsi
        |
        v
Baca progres dari useProgres()          <- features/progres/useProgres.ts
        |
        v
Tampilkan status 3 tahap + tombol lanjut
```

### 3.3 Alur Sesi Flashcard

Ini alur paling kompleks karena melibatkan state machine.

```
1. MASUK
   useSesiFlashcard(modulSlug)
        |
        v
   Ambil semua kartu modul dari Supabase (cache)
   Ambil status kartu dari localStorage
        |
        v
   Urutkan berdasarkan prioritas (lihat 01-PRD.md §3 Tahap 2)
   Ambil maks 20 kartu
        |
        v
2. KERJAKAN (untuk setiap kartu)
   ┌─────────────────────────────────────────┐
   │  Tampilkan sisi depan                   │
   │         |                               │
   │         v                               │
   │  User tekan Space/Enter                 │
   │         |                               │
   │         v                               │
   │  Flip ke sisi belakang (320ms)          │
   │         |                               │
   │         v                               │
   │  User tekan 1 (Lupa) atau 2 (Ingat)     │
   │         |                               │
   │         v                               │
   │  Catat hasil di state sesi              │
   │         |                               │
   │         v                               │
   │  Kartu keluar (160ms)                   │
   └─────────────────────────────────────────┘
        |
        v
3. ULANGAN
   Jika ada kartu "Lupa" dan belum diulang:
     -> Susun sesi ulang berisi HANYA kartu yang lupa
     -> Kembali ke langkah 2
   Jika tidak ada:
     -> Lanjut ke langkah 4
        |
        v
4. SELESAI
   Simpan status semua kartu ke localStorage
   Hitung ringkasan: total, ingat, lupa, akurasi
   Tampilkan RingkasanSesi
   Tandai tahap 2 selesai JIKA semua kartu minimal sekali "Ingat"
        |
        v
5. BUKA KUNCI
   Tahap 3 (Quiz) sekarang terbuka
```

**Detail penting:** sesi disimpan di memori (`useState`/`useReducer`), **bukan** di `localStorage` per kartu. Alasannya: menulis ke `localStorage` 20 kali dalam satu sesi itu lambat dan tidak perlu. Yang disimpan hanya hasil akhir sesi. Konsekuensinya: jika user menutup tab di tengah sesi, sesi hilang. Ini diterima — memaksa menyimpan state sesi yang kompleks akan menambah banyak kode untuk manfaat kecil.

### 3.4 Alur Sesi Quiz

```
1. MASUK
   useSesiQuiz(modulSlug)
        |
        v
   Ambil bank soal modul dari Supabase
   Acak, ambil 10 soal
        |
        v
2. KERJAKAN (soal 1..10)
   ┌─────────────────────────────────────────┐
   │  Tampilkan soal + 4 opsi                │
   │         |                               │
   │         v                               │
   │  User pilih opsi                        │
   │         |                               │
   │         v                               │
   │  Kunci jawaban ada di data soal         │
   │  -> Nilai langsung di client            │
   │         |                               │
   │         v                               │
   │  Tampilkan UmpanBalik (benar/salah)     │
   │  + penjelasan                           │
   │         |                               │
   │         v                               │
   │  User tekan "Soal berikutnya"           │
   │         |                               │
   │         v                               │
   │  Catat jawaban di state sesi            │
   └─────────────────────────────────────────┘
        |
        v
3. SELESAI
   Hitung: skor, jumlah benar, akurasi per topik (card_type)
   Simpan riwayat ke localStorage
   Tampilkan HasilQuiz + AnalisisTopik
        |
        v
4. PENILAIAN
   Jika skor >= 70: tandai tahap 3 selesai
   Jika < 70: sarankan ulangi, tetap boleh lanjut
```

**Catatan keamanan:** kunci jawaban (`jawaban_benar`) ada di data yang dikirim ke client. Ini **disadari dan diterima** (lihat `README.md` §Ringkasan Keputusan). Untuk aplikasi edukatif, menyembunyikan jawaban dari mahasiswa yang ingin belajar tidak memberi manfaat.

### 3.5 Alur Penguncian Tahap

Ini logika inti produk. Harus diimplementasikan di **satu tempat** agar tidak ada perbedaan perilaku antar halaman.

```typescript
// features/progres/aturan.ts

export type StatusTahap = 'terkunci' | 'tersedia' | 'selesai';

export interface ProgresModul {
  modulId: string;
  tahap1Selesai: boolean;
  tahap2Selesai: boolean;
  tahap3Selesai: boolean;
  kartu: Record<string, StatusKartu>;
  riwayatQuiz: HasilQuiz[];
}

/**
 * Aturan:
 *   Tahap 1 selalu tersedia
 *   Tahap 2 tersedia jika tahap 1 selesai
 *   Tahap 3 tersedia jika tahap 2 selesai
 */
export function statusTahap(
  progres: ProgresModul | undefined,
  tahap: 1 | 2 | 3
): StatusTahap {
  if (!progres) {
    return tahap === 1 ? 'tersedia' : 'terkunci';
  }

  const selesai = [
    progres.tahap1Selesai,
    progres.tahap2Selesai,
    progres.tahap3Selesai,
  ];

  if (selesai[tahap - 1]) return 'selesai';

  // Tahap n tersedia jika tahap n-1 selesai
  const prasyaratTerpenuhi = tahap === 1 || selesai[tahap - 2];
  return prasyaratTerpenuhi ? 'tersedia' : 'terkunci';
}

/**
 * Pesan yang ditampilkan saat tahap terkunci.
 * Harus menjelaskan ALASAN, bukan sekadar "terkunci".
 */
export function alasanTerkunci(tahap: 2 | 3): string {
  if (tahap === 2) {
    return 'Selesaikan modul ini dulu sebelum mulai menghafal.';
  }
  return 'Selesaikan semua kartu dulu sebelum mengerjakan quiz.';
}
```

**Aturan UI:** saat tahap terkunci, tombolnya **tetap terlihat** tetapi tidak aktif, disertai ikon kunci dan alasan. Alasannya: menyembunyikan tombol membuat pengguna tidak tahu ada tahap berikutnya. Menampilkannya dengan alasan jelas mengajarkan alur.

### 3.6 Penyimpanan Progres

```typescript
// features/progres/store.ts

import { z } from 'zod';

const KUNCI_STORAGE = 'flashstruct:progres:v1';

const StatusKartuSchema = z.object({
  kartuId: z.string(),
  jumlahIngat: z.number().int().min(0),
  jumlahLupa: z.number().int().min(0),
  terakhirDilihat: z.number(),      // epoch ms
});

const ProgresModulSchema = z.object({
  modulId: z.string(),
  tahap1Selesai: z.boolean(),
  tahap2Selesai: z.boolean(),
  tahap3Selesai: z.boolean(),
  bagianDibaca: z.array(z.string()),
  kartu: z.record(z.string(), StatusKartuSchema),
  riwayatQuiz: z.array(HasilQuizSchema),
});

const ProgresGlobalSchema = z.object({
  versi: z.literal(1),
  modul: z.record(z.string(), ProgresModulSchema),
  tema: z.enum(['terang', 'gelap', 'sistem']),
  terakhirDiperbarui: z.number(),
});

export function bacaProgres(): ProgresGlobal {
  try {
    const mentah = localStorage.getItem(KUNCI_STORAGE);
    if (!mentah) return progresKosong();

    const hasil = ProgresGlobalSchema.safeParse(JSON.parse(mentah));

    if (!hasil.success) {
      // Data korup atau dari versi lama.
      // Simpan salinan untuk diagnosis, lalu mulai bersih.
      console.warn('Progres tidak valid, memulai ulang:', hasil.error);
      localStorage.setItem(
        `${KUNCI_STORAGE}:rusak-${Date.now()}`,
        mentah
      );
      return progresKosong();
    }

    return hasil.data;
  } catch {
    return progresKosong();
  }
}
```

**Poin penting:**

1. **Kunci versi (`:v1`).** Jika bentuk data berubah di masa depan, kunci baru dipakai dan data lama diabaikan dengan aman.
2. **Validasi Zod saat baca.** Jangan pernah mempercayai `localStorage` — isinya bisa diubah manual, rusak, atau dari versi aplikasi yang berbeda.
3. **Simpan data rusak untuk diagnosis**, jangan langsung buang. Berguna saat ada laporan bug.
4. **Selalu punya nilai kembali yang aman.** Fungsi ini tidak pernah melempar error.

---

## 4. Konfigurasi Supabase

### 4.1 Client

```typescript
// lib/supabase.ts

import { createClient } from '@supabase/supabase-js';
import type { Database } from '@/types/database';

const url = import.meta.env.VITE_SUPABASE_URL;
const key = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY;

if (!url || !key) {
  throw new Error(
    'VITE_SUPABASE_URL dan VITE_SUPABASE_PUBLISHABLE_KEY harus diisi di .env.local'
  );
}

export const supabase = createClient<Database>(url, key, {
  auth: {
    // v1 tidak memakai autentikasi. Matikan agar tidak ada
    // request sesi yang tidak perlu.
    persistSession: false,
    autoRefreshToken: false,
    detectSessionInUrl: false,
  },
});
```

### 4.2 Environment Variable

```bash
# .env.example — di-commit ke repo
VITE_SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxxxxxxxxxxx
```

**Aturan:**

| Aturan | Alasan |
|--------|--------|
| `.env.local` **tidak di-commit** | Berisi kredensial project spesifik |
| Hanya variabel berawalan `VITE_` yang tersedia di client | Vite hanya mengekspos variabel dengan prefix ini |
| **Tidak pernah** memakai `service_role` / `sb_secret_` di frontend | Key itu melewati RLS dan memberi akses penuh ke database |
| Key `publishable` aman diekspos | Aman **hanya jika RLS aktif**. Lihat `05-SKEMA-DATABASE.md` |

**Peringatan:** ada perubahan pada sistem API key Supabase — key `anon` lama sedang digantikan key `publishable` (`sb_publishable_...`). Project baru sebaiknya langsung memakai key `publishable`. Detail dan tautan sumber ada di `riset/01-RISET-TEKNIS.md` §2.

### 4.3 Konfigurasi TanStack Query

```typescript
// app/query-client.ts

import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // Konten edukasi hampir tidak pernah berubah.
      // 5 menit mencegah fetch ulang saat navigasi bolak-balik.
      staleTime: 5 * 60 * 1000,

      // Simpan di cache selama 30 menit.
      gcTime: 30 * 60 * 1000,

      // Coba 2 kali dengan backoff. Jaringan kampus sering tidak stabil.
      retry: 2,
      retryDelay: (attempt) => Math.min(1000 * 2 ** attempt, 10_000),

      // Jangan fetch ulang hanya karena window kembali fokus.
      // Mengganggu saat pengguna sedang membaca modul panjang.
      refetchOnWindowFocus: false,

      // Fetch ulang saat koneksi kembali.
      refetchOnReconnect: true,
    },
  },
});
```

**Alasan `staleTime` 5 menit:** konten modul berubah mungkin sekali sebulan. Mengambil ulang setiap navigasi hanya membuang kuota egress Supabase dan memperlambat UI tanpa manfaat.

---

## 5. Routing

```typescript
// app/router.tsx

import { createBrowserRouter } from 'react-router-dom';
import { lazy, Suspense } from 'react';

// Halaman berat dimuat lazy agar bundle awal kecil
const HomePage = lazy(() => import('@/pages/HomePage'));
const DashboardPage = lazy(() => import('@/pages/DashboardPage'));
const MateriPage = lazy(() => import('@/pages/MateriPage'));
const ModulDetailPage = lazy(() => import('@/pages/ModulDetailPage'));
const VideoPage = lazy(() => import('@/pages/VideoPage'));
const SoalPage = lazy(() => import('@/pages/SoalPage'));
const FlashcardPage = lazy(() => import('@/pages/FlashcardPage'));
const QuizPage = lazy(() => import('@/pages/QuizPage'));

export const router = createBrowserRouter([
  {
    path: '/',
    element: <RootLayout />,
    errorElement: <ErrorPage />,
    children: [
      { index: true, element: <HomePage /> },
      { path: 'dashboard', element: <DashboardPage /> },
      { path: 'materi', element: <MateriPage /> },
      { path: 'materi/:slug', element: <ModulDetailPage /> },
      { path: 'video', element: <VideoPage /> },
      { path: 'soal', element: <SoalPage /> },
      { path: 'soal/flashcard/:slug', element: <FlashcardPage /> },
      { path: 'soal/quiz/:slug', element: <QuizPage /> },
      { path: '*', element: <NotFoundPage /> },
    ],
  },
]);
```

### 5.1 Aturan Routing

| Aturan | Alasan |
|--------|--------|
| `createBrowserRouter` (bukan `HashRouter`) | URL bersih. Vercel/Netlify mendukung SPA rewrite |
| Semua halaman `lazy` | Bundle awal kecil |
| `Suspense` di `RootLayout` | Satu tempat untuk fallback loading |
| `errorElement` di root | Menangkap error tanpa layar putih |
| URL mengandung `:slug`, bukan ID numerik | URL bisa dibaca manusia dan stabil |

**Catatan GitHub Pages:** jika deploy ke GitHub Pages, `createBrowserRouter` akan 404 saat refresh karena GitHub Pages tidak punya rewrite server-side. Solusinya: pindah ke Vercel/Netlify (direkomendasikan), atau ganti ke `createHashRouter`. Lihat `09-PANDUAN-SETUP.md` §Deploy.

### 5.2 Kode Halaman dengan Lazy Loading

```typescript
// components/layout/RootLayout.tsx

import { Suspense } from 'react';
import { Outlet, ScrollRestoration } from 'react-router-dom';
import { Header } from './Header';
import { BottomNav } from './BottomNav';
import { PageSkeleton } from '@/components/ui/Skeleton';

export function RootLayout() {
  return (
    <div className="min-h-dvh bg-[var(--bg)] text-[var(--fg)]">
      <Header />

      <main id="konten-utama" className="pb-20 md:pb-0">
        <Suspense fallback={<PageSkeleton />}>
          <Outlet />
        </Suspense>
      </main>

      <BottomNav />
      <ScrollRestoration />
    </div>
  );
}
```

**Catatan:** `min-h-dvh` dipakai, bukan `min-h-screen`. Satuan `dvh` menyesuaikan tinggi viewport dinamis di browser mobile, menghindari masalah address bar yang muncul/hilang.

---

## 6. Manajemen State

### 6.1 Peta State

| Jenis state | Contoh | Dikelola oleh | Alasan |
|-------------|--------|---------------|--------|
| **Server** | Modul, kartu, soal, video | TanStack Query | Cache, retry, revalidation otomatis |
| **Progres pengguna** | Modul selesai, status kartu, riwayat quiz | React Context + localStorage | Persisten, diakses banyak komponen |
| **Tema** | Terang/gelap/sistem | React Context + localStorage | Global, jarang berubah |
| **Sesi** | Kartu ke-3 dari 20, jawaban sementara | `useReducer` lokal | Sementara, tidak perlu global |
| **UI** | Modal terbuka, tab aktif | `useState` lokal | Sangat lokal |

### 6.2 Mengapa `useReducer` untuk Sesi

Sesi flashcard dan quiz punya transisi state yang jelas. `useReducer` lebih tepat daripada beberapa `useState` terpisah karena:

```typescript
type AksiSesi =
  | { tipe: 'FLIP' }
  | { tipe: 'NILAI'; kartuId: string; ingat: boolean }
  | { tipe: 'LANJUT' }
  | { tipe: 'ULANG_KARTU_LUPA' }
  | { tipe: 'SELESAI' };

interface StateSesi {
  kartu: Kartu[];
  indeks: number;
  terbuka: boolean;
  hasil: Record<string, boolean>;
  putaran: number;
  selesai: boolean;
}
```

Alasan:
- Semua transisi terlihat di satu tempat (fungsi reducer)
- Tidak mungkin masuk ke state tidak valid (misalnya `selesai: true` tapi masih ada kartu)
- Mudah diuji tanpa merender komponen

### 6.3 Hook Sesi Flashcard

```typescript
// features/flashcard/useSesiFlashcard.ts

export function useSesiFlashcard(modulSlug: string) {
  const { data: kartu, isLoading } = useKartuModul(modulSlug);
  const { progres, simpanHasilSesi } = useProgres();

  const [state, dispatch] = useReducer(reducerSesi, undefined, () =>
    stateAwal(kartu ?? [], progres, modulSlug)
  );

  // Keyboard: Space/Enter = flip, 1 = lupa, 2 = ingat
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === ' ' || e.key === 'Enter') {
        e.preventDefault();
        dispatch({ tipe: 'FLIP' });
      }
      if (e.key === '1' && state.terbuka) {
        dispatch({ tipe: 'NILAI', kartuId: kartuSekarang.id, ingat: false });
      }
      if (e.key === '2' && state.terbuka) {
        dispatch({ tipe: 'NILAI', kartuId: kartuSekarang.id, ingat: true });
      }
    }
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [state.terbuka, kartuSekarang]);

  // Simpan HANYA saat sesi selesai, bukan per kartu
  useEffect(() => {
    if (state.selesai && kartu) {
      simpanHasilSesi(modulSlug, state.hasil);
    }
  }, [state.selesai]);

  return { state, dispatch, isLoading };
}
```

---

## 7. Penanganan Error

### 7.1 Lapisan Error

| Lapisan | Penanganan | Contoh |
|---------|-----------|--------|
| **Jaringan** | TanStack Query retry + `ErrorState` | "Gagal memuat materi. Periksa koneksi." |
| **Data tidak ditemukan** | `EmptyState` | "Modul tidak ditemukan." |
| **Data korup** | Zod gagal, reset dengan aman | Progres direset, salinan disimpan |
| **Error render** | `errorElement` router | Halaman error dengan tombol kembali |
| **Error tidak terduga** | Error boundary | Pesan generik + tombol muat ulang |

### 7.2 Komponen ErrorState

```typescript
interface ErrorStateProps {
  judul: string;
  pesan: string;
  onCobaLagi?: () => void;
}

export function ErrorState({ judul, pesan, onCobaLagi }: ErrorStateProps) {
  return (
    <div role="alert" className="flex flex-col items-center gap-4 py-12 text-center">
      <AlertTriangle className="size-10 text-[var(--danger)]" aria-hidden="true" />
      <div>
        <h2 className="text-lg font-semibold">{judul}</h2>
        <p className="mt-1 text-[var(--fg-muted)]">{pesan}</p>
      </div>
      {onCobaLagi && (
        <Button onClick={onCobaLagi} variant="secondary">
          Coba lagi
        </Button>
      )}
    </div>
  );
}
```

**Aturan pesan error:**

| Salah | Benar | Alasan |
|-------|-------|--------|
| "Error 500" | "Gagal memuat materi. Coba lagi sebentar lagi." | Pengguna tidak tahu apa itu 500 |
| "Fetch failed" | "Tidak bisa terhubung. Periksa koneksi internet." | Bahasa manusia, bukan bahasa mesin |
| "Terjadi kesalahan" | "Materi tidak ditemukan. Mungkin tautannya salah." | Spesifik dan memberi arah |

### 7.3 Tampilan Error Tidak Boleh Menghilangkan Progres

Aturan penting: jika pemuatan konten gagal, **jangan** reset atau ubah progres pengguna. Progres adalah data pengguna, bukan data server. Error server tidak boleh menghukum pengguna.

---

## 8. Performa

### 8.1 Strategi

| Teknik | Penerapan | Target |
|--------|-----------|--------|
| **Code splitting** | Semua halaman `lazy` | Bundle awal < 200 KB gzip |
| **Lazy Shiki** | Dimuat hanya di halaman Materi/Soal | Hemat ± 300 KB dari bundle awal |
| **Cache query** | `staleTime` 5 menit | Navigasi instan |
| **Virtualisasi** | Tidak perlu (maks 26 kartu per deck) | — |
| **Gambar** | WebP/AVIF, `loading="lazy"`, ukuran eksplisit | Cegah CLS |
| **Font** | `display=swap`, preconnect | Teks langsung terbaca |
| **Animasi** | Hanya `transform` + `opacity` | 60 FPS |
| **Video** | Sematan YouTube, tidak diunduh | Tidak membebani server sendiri |

### 8.2 Anggaran Bundle

| Bagian | Target (gzip) |
|--------|---------------|
| React + ReactDOM | ± 45 KB |
| React Router | ± 12 KB |
| TanStack Query | ± 13 KB |
| Supabase JS | ± 25 KB |
| Motion | ± 18 KB |
| Kode aplikasi | ± 40 KB |
| **Total awal** | **± 155 KB** |
| Shiki (lazy) | ± 300 KB (hanya saat dibutuhkan) |
| react-markdown (lazy) | ± 40 KB |

**Cara memverifikasi:** jalankan `npm run build` dan periksa laporan ukuran. Jika melebihi anggaran, periksa apakah ada dependensi yang tidak sengaja terimpor ke bundle awal.

### 8.3 Mencegah Layout Shift

Setiap elemen yang memuat data harus punya ruang yang dipesan:

```typescript
// Skeleton dengan tinggi yang SAMA dengan konten akhir
export function KartuModulSkeleton() {
  return (
    <div className="rounded-lg border p-6" style={{ minHeight: 220 }}>
      <Skeleton className="h-6 w-3/4" />
      <Skeleton className="mt-3 h-4 w-full" />
      <Skeleton className="mt-2 h-4 w-2/3" />
    </div>
  );
}
```

**Aturan:** tinggi skeleton harus sama dengan tinggi konten akhir. Skeleton yang lebih pendek menyebabkan lompatan saat konten masuk.

---

## 9. Aksesibilitas Teknis

| Kebutuhan | Implementasi |
|-----------|--------------|
| Skip link | Tautan "Lewati ke konten" di awal `body` |
| Landmark | `<header>`, `<nav>`, `<main id="konten-utama">`, `<footer>` |
| Fokus saat navigasi | Pindahkan fokus ke `<h1>` halaman baru |
| Fokus terkunci di modal | `focus-trap` saat dialog terbuka |
| Kembalikan fokus | Kembali ke pemicu saat modal tutup |
| Pengumuman status | `aria-live="polite"` untuk hasil quiz |
| Kode terbaca | `<pre role="region" aria-label="...">` |

### 9.1 Skip Link

```html
<a href="#konten-utama" class="skip-link">
  Lewati ke konten utama
</a>
```

```css
.skip-link {
  position: absolute;
  left: -9999px;
}
.skip-link:focus {
  position: fixed;
  top: 8px;
  left: 8px;
  z-index: 9999;
  padding: 12px 16px;
  background: var(--primary);
  color: var(--on-primary);
  border-radius: var(--radius-md);
}
```

### 9.2 Fokus Saat Navigasi Halaman

```typescript
// Di setiap halaman
useEffect(() => {
  const h1 = document.querySelector('h1');
  h1?.setAttribute('tabindex', '-1');
  h1?.focus();
}, []);
```

Alasan: pada SPA, berpindah halaman tidak memindahkan fokus secara otomatis. Tanpa ini, pengguna keyboard tetap berada di posisi lama dan harus menekan Tab berkali-kali.

---

## 10. Pengujian

### 10.1 Apa yang Diuji

| Jenis | Cakupan | Alat |
|-------|---------|------|
| **Unit — logika murni** | `statusTahap`, `alasanTerkunci`, pengurutan kartu, penilaian quiz, skema Zod | Vitest |
| **Unit — hook** | `useSesiFlashcard`, `useSesiQuiz` | Vitest + `renderHook` |
| **Komponen** | Flip kartu, umpan balik quiz, kartu modul | Testing Library |
| **Integrasi** | Alur lengkap: buka modul, selesaikan, kerjakan kartu, kerjakan quiz | Testing Library |
| **Manual** | Aksesibilitas, responsif, kedua mode tema | Checklist `08-CHECKLIST-QA.md` |

### 10.2 Prioritas Pengujian

Urutan berdasarkan risiko. **Uji ini dulu**, sisanya menyusul:

1. `statusTahap` — jika salah, penguncian rusak dan seluruh metode belajar gagal
2. Skema Zod progres — jika salah, pengguna kehilangan progres
3. Pengurutan kartu — jika salah, kartu penting tidak muncul
4. Penilaian quiz — jika salah, nilai salah
5. Alur sesi flashcard — termasuk ulangan kartu lupa

### 10.3 Contoh Uji

```typescript
// features/progres/aturan.test.ts

import { describe, it, expect } from 'vitest';
import { statusTahap } from './aturan';

describe('statusTahap', () => {
  it('menandai tahap 1 tersedia untuk modul baru', () => {
    expect(statusTahap(undefined, 1)).toBe('tersedia');
  });

  it('mengunci tahap 2 dan 3 untuk modul baru', () => {
    expect(statusTahap(undefined, 2)).toBe('terkunci');
    expect(statusTahap(undefined, 3)).toBe('terkunci');
  });

  it('membuka tahap 2 setelah tahap 1 selesai', () => {
    const progres = buatProgres({ tahap1Selesai: true });
    expect(statusTahap(progres, 2)).toBe('tersedia');
    expect(statusTahap(progres, 3)).toBe('terkunci');
  });

  it('membuka tahap 3 setelah tahap 2 selesai', () => {
    const progres = buatProgres({ tahap1Selesai: true, tahap2Selesai: true });
    expect(statusTahap(progres, 3)).toBe('tersedia');
  });

  it('menandai tahap selesai dengan status selesai, bukan tersedia', () => {
    const progres = buatProgres({ tahap1Selesai: true });
    expect(statusTahap(progres, 1)).toBe('selesai');
  });

  it('tidak membuka tahap 3 jika tahap 1 selesai tapi tahap 2 belum', () => {
    const progres = buatProgres({ tahap1Selesai: true, tahap2Selesai: false });
    expect(statusTahap(progres, 3)).toBe('terkunci');
  });
});
```

---

## 11. Konvensi Kode

### 11.1 Penamaan

| Jenis | Konvensi | Contoh |
|-------|----------|--------|
| Komponen | PascalCase | `FlashcardDeck.tsx` |
| Hook | camelCase, awalan `use` | `useSesiFlashcard.ts` |
| Fungsi utilitas | camelCase | `hitungAkurasi()` |
| Konstanta | SCREAMING_SNAKE | `MAKS_KARTU_PER_SESI` |
| Tipe / Interface | PascalCase | `ProgresModul` |
| Berkas non-komponen | camelCase | `aturan.ts` |
| Folder | kebab-case | `features/flashcard/` |

**Catatan bahasa:** kode ditulis dengan **penamaan Indonesia** untuk domain (`hitungAkurasi`, `statusTahap`) dan **Inggris** untuk hal teknis umum (`useState`, `onClick`, `handleSubmit`). Konsistensi lebih penting daripada pilihan bahasa itu sendiri.

### 11.2 Urutan Impor

```typescript
// 1. React dan library eksternal
import { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';

// 2. Alias internal (@/)
import { Button } from '@/components/ui/Button';
import { useProgres } from '@/features/progres/useProgres';

// 3. Impor relatif
import { aturanSesi } from './aturan';

// 4. Tipe
import type { Kartu } from '@/types/database';

// 5. Style
import './styles.css';
```

### 11.3 Aturan Penulisan

| Aturan | Alasan |
|--------|--------|
| **Komponen maksimal 150 baris** | Lebih dari itu, pecah |
| **Fungsi maksimal 50 baris** | Lebih dari itu, sulit diuji dan dipahami |
| **Maksimal 3 level nesting** | Lebih dalam dari itu, ekstrak jadi fungsi |
| **Nama variabel menjelaskan isi** | `sisaKartu` bukan `x` |
| **Komentar menjelaskan MENGAPA, bukan APA** | `// ini menambah 1` tidak berguna |
| **Tidak ada `any`** | Gunakan `unknown` lalu validasi dengan Zod |
| **Nilai tetap di `constants.ts`** | Satu tempat untuk mengubah ambang |

### 11.4 Konstanta Penting

```typescript
// lib/constants.ts

/** Maksimal kartu per sesi flashcard */
export const MAKS_KARTU_PER_SESI = 20;

/** Jumlah soal per quiz */
export const JUMLAH_SOAL_QUIZ = 10;

/** Nilai minimum untuk lulus quiz */
export const AMBANG_LULUS_QUIZ = 70;

/** Persentase modul yang harus dibaca sebelum bisa ditandai selesai */
export const PERSEN_MINIMAL_BACA = 80;

/** Ambang akurasi topik untuk kategorisasi */
export const AMBANG_TOPIK_LEMAH = 50;
export const AMBANG_TOPIK_CUKUP = 80;

/** Kunci localStorage */
export const KUNCI_PROGRES = 'flashstruct:progres:v1';
export const KUNCI_TEMA = 'flashstruct:tema';
```

**Catatan konsistensi:** nilai-nilai ini harus sama dengan yang tertulis di `01-PRD.md` §3. Jika salah satu berubah, ubah keduanya.

---

## 12. Alur Pengembangan

### 12.1 Perintah

```bash
npm install          # Pasang dependensi
npm run dev          # Dev server (localhost:5173)
npm run build        # Build produksi
npm run preview      # Pratinjau hasil build
npm run test         # Uji sekali
npm run test:watch   # Uji mode pantau
npm run lint         # Periksa kode
npm run typecheck    # Periksa tipe
```

### 12.2 Sebelum Commit

Jalankan berurutan:

```bash
npm run typecheck && npm run lint && npm run test && npm run build
```

Alasan: lebih baik menemukan masalah di lokal daripada menunggu pipeline gagal.

### 12.3 Urutan Implementasi

Mengikuti ketergantungan data:

```
1. Setup proyek (Vite, TS, Tailwind, ESLint)
2. Token design system (tokens.css)
3. Komponen UI dasar (Button, Card, Progress, Skeleton)
4. Skema database + seed 1 modul
5. Client Supabase + TanStack Query
6. Progres: skema Zod + store + aturan penguncian
7. Halaman Materi (pakai 1 modul seed)
8. Halaman Flashcard
9. Halaman Quiz
10. Halaman Video
11. Halaman Dashboard
12. Halaman Home
13. Isi semua 10 modul
14. QA + polish
```

Alasan urutan ini: setiap langkah hanya bergantung pada langkah sebelumnya. Tidak ada langkah yang menunggu pekerjaan yang belum ada.

---

## 13. Referensi Silang

| Topik | Dokumen |
|-------|---------|
| Aturan bisnis 3 tahap | `01-PRD.md` §3 |
| Konten dan taksonomi kartu | `02-KURIKULUM.md` §4 |
| Token warna dan komponen | `03-DESIGN-SYSTEM.md` |
| Skema database lengkap | `05-SKEMA-DATABASE.md` |
| Spesifikasi tiap halaman | `06-SPESIFIKASI-HALAMAN.md` |
| Urutan pengerjaan | `07-ROADMAP.md` |
| Setup dan deploy | `09-PANDUAN-SETUP.md` |
| Justifikasi Supabase | `riset/01-RISET-TEKNIS.md` |
