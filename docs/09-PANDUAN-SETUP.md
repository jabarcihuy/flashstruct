# 09 — Panduan Setup & Deploy

> Langkah demi langkah menyiapkan lingkungan pengembangan FlashStruct sampai online.
> Status: `[FINAL]` · Tautan sumber resmi ada di `riset/01-RISET-TEKNIS.md`

---

## 1. Yang Perlu Disiapkan

### 1.1 Perangkat Lunak

| Perangkat | Versi minimum | Cara cek | Kenapa perlu |
|-----------|---------------|----------|--------------|
| **Node.js** | 20 LTS atau lebih baru | `node --version` | Menjalankan Vite dan tooling |
| **npm** | 10 atau lebih baru | `npm --version` | Memasang dependensi |
| **Git** | 2.30+ | `git --version` | Kontrol versi |
| **Editor kode** | — | — | VS Code direkomendasikan |
| **Browser modern** | Chrome/Firefox/Edge/Safari | — | DevTools untuk debugging |
| **PostgreSQL** (opsional) | 15+ | `postgres --version` | Hanya jika ingin mencoba skema secara lokal |

**Catatan versi Node:** Vite 8 membutuhkan Node 20 atau lebih baru. Node 18 sudah tidak didukung.

**Catatan tentang Docker:** proyek ini **tidak memakai Docker**. Pengembangan cukup dengan Supabase hosted (yang sudah menyediakan database siap pakai), sehingga tidak perlu menjalankan container apa pun di mesin sendiri. PostgreSQL lokal hanya diperlukan jika kamu ingin bereksperimen dengan skema tanpa menyentuh data online — dan itu pun opsional.

### 1.2 Ekstensi Editor yang Disarankan

| Ekstensi | Kegunaan |
|----------|----------|
| ESLint | Menampilkan error lint langsung |
| Prettier | Format otomatis saat simpan |
| Tailwind CSS IntelliSense | Autocomplete kelas Tailwind |
| Error Lens | Menampilkan error di baris kode |

### 1.3 Akun yang Dibutuhkan

| Akun | Untuk | Gratis? |
|------|-------|---------|
| **Supabase** | Database konten | Ya, Free Plan cukup |
| **GitHub** | Menyimpan kode | Ya |
| **Vercel** atau **Netlify** | Hosting | Ya, Free Plan cukup |

**Rekomendasi:** pakai Vercel. Alasannya SPA rewrite-nya paling sederhana (satu berkas `vercel.json`) dan mendeteksi Vite otomatis tanpa konfigurasi.

### 1.4 Pengetahuan Prasyarat

Panduan ini mengasumsikan kamu sudah bisa:

- Menjalankan perintah di terminal
- Menggunakan Git dasar (`add`, `commit`, `push`)
- Menulis JavaScript/TypeScript dasar
- Membaca pesan error

Jika belum familiar dengan React, selesaikan tutorial resmi di [react.dev/learn](https://react.dev/learn) lebih dulu. Panduan ini tidak mengajarkan React dari nol.

---

## 2. Setup Proyek

### 2.1 Membuat Proyek

```bash
# Buat proyek Vite dengan template React + TypeScript
npm create vite@latest flashstruct -- --template react-ts

cd flashstruct
npm install
```

### 2.2 Memasang Dependensi

**Dependensi produksi:**

```bash
npm install \
  react-router-dom \
  @tanstack/react-query \
  @supabase/supabase-js \
  motion \
  lucide-react \
  zod \
  react-markdown \
  shiki \
  clsx \
  tailwind-merge
```

**Dependensi pengembangan:**

```bash
npm install -D \
  tailwindcss \
  @tailwindcss/vite \
  vitest \
  @vitest/ui \
  jsdom \
  @testing-library/react \
  @testing-library/user-event \
  @testing-library/jest-dom \
  eslint \
  prettier \
  eslint-config-prettier \
  @types/node
```

**Penjelasan setiap paket:**

| Paket | Kenapa |
|-------|--------|
| `react-router-dom` | Routing SPA |
| `@tanstack/react-query` | Cache dan sinkronisasi data server |
| `@supabase/supabase-js` | Client database |
| `motion` | Animasi |
| `lucide-react` | Ikon SVG |
| `zod` | Validasi data runtime |
| `react-markdown` | Render konten modul |
| `shiki` | Pewarnaan sintaks kode |
| `clsx` + `tailwind-merge` | Gabung kelas Tailwind dengan aman |
| `tailwindcss` + `@tailwindcss/vite` | Styling |
| `vitest` + `jsdom` + Testing Library | Pengujian |

### 2.3 Konfigurasi Vite

```typescript
// vite.config.ts

import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import { fileURLToPath, URL } from 'node:url';

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './src/test/setup.ts',
    css: true,
  },
});
```

### 2.4 Konfigurasi TypeScript

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "skipLibCheck": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"]
}
```

**Catatan `noUncheckedIndexedAccess`:** opsi ini membuat akses array mengembalikan `T | undefined`. Terasa merepotkan di awal, tetapi mencegah bug yang sangat umum pada aplikasi yang banyak mengakses array (seperti flashcard dan quiz).

### 2.5 Tailwind CSS v4

Tailwind v4 memakai konfigurasi berbasis CSS, bukan berkas JS.

```css
/* src/styles/global.css */

@import 'tailwindcss';
@import './tokens.css';

@theme {
  /* Petakan token ke nama Tailwind */
  --color-bg: var(--bg);
  --color-surface: var(--surface);
  --color-fg: var(--fg);
  --color-fg-muted: var(--fg-muted);
  --color-primary: var(--primary);
  --color-on-primary: var(--on-primary);
  --color-accent: var(--accent);
  --color-success: var(--success);
  --color-danger: var(--danger);
  --color-border: var(--border);
  --color-ring: var(--ring);

  --color-topik-array: var(--topik-array);
  --color-topik-struct: var(--topik-struct);
  --color-topik-pointer: var(--topik-pointer);

  --font-ui: var(--font-ui);
  --font-heading: var(--font-heading);
  --font-mono: var(--font-mono);
}
```

**Token `tokens.css`** disalin dari `03-DESIGN-SYSTEM.md` §2.6. Jangan menulis ulang nilainya — salin persis.

### 2.6 Script `package.json`

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:ui": "vitest --ui",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "format": "prettier --write \"src/**/*.{ts,tsx,css}\"",
    "typecheck": "tsc --noEmit"
  }
}
```

### 2.7 Struktur Folder

Buat folder sesuai `04-ARSITEKTUR-TEKNIS.md` §2.2:

```bash
mkdir -p src/{app,lib,types,styles,components/{ui,layout,code,markdown}} \
         src/features/{materi,video,flashcard,quiz,progres,dashboard,soal} \
         src/pages \
         src/test/fixtures \
         supabase/{migrations} \
         public
```

### 2.8 Memastikan Setup Berhasil

```bash
npm run dev
```

Buka `http://localhost:5173`. Halaman default Vite harus tampil.

```bash
npm run typecheck && npm run lint && npm run test
```

Semua harus selesai tanpa error.

---

## 3. Setup Supabase

### 3.1 Membuat Project

1. Buka [supabase.com](https://supabase.com) dan masuk
2. Klik **New project**
3. Isi:
   - **Name:** `flashstruct`
   - **Database Password:** buat yang kuat, **simpan di tempat aman**
   - **Region:** pilih yang terdekat (untuk Indonesia: `Southeast Asia (Singapore)`)
4. Klik **Create new project**, tunggu 2–3 menit

**Catatan region:** memilih region yang jauh menambah latensi. Singapore adalah pilihan terdekat untuk Indonesia.

### 3.2 Mengambil Kredensial

1. Buka project, pilih **Settings** di sidebar
2. Pilih **API Keys**
3. Catat dua nilai:

| Nama | Bentuk | Dipakai di mana |
|------|--------|-----------------|
| **Project URL** | `https://xxxxx.supabase.co` | `VITE_SUPABASE_URL` |
| **Publishable key** | `sb_publishable_xxxxx` | `VITE_SUPABASE_PUBLISHABLE_KEY` |

**Catatan penting tentang API key:** Supabase sedang mengganti sistem key lama. Key `anon` lama akan digantikan oleh **publishable key** (`sb_publishable_...`). Untuk project baru, langsung pakai publishable key. Jika di dashboard hanya terlihat `anon` key, itu juga bisa dipakai untuk sementara — keduanya aman diekspos selama RLS aktif.

**JANGAN pernah** memakai `service_role` atau `sb_secret_` key di frontend. Key itu melewati RLS dan memberi akses penuh ke database.

### 3.3 Menjalankan Skema Database

1. Di dashboard Supabase, pilih **SQL Editor**
2. Klik **New query**
3. Salin seluruh isi blok DDL dari `05-SKEMA-DATABASE.md` §3
4. Klik **Run**
5. Pastikan hasilnya sukses tanpa error

### 3.4 Menjalankan RLS

**Langkah ini tidak boleh dilewati.**

1. Buat query baru di SQL Editor
2. Salin seluruh isi blok RLS dari `05-SKEMA-DATABASE.md` §4.3
3. Klik **Run**

### 3.5 VERIFIKASI KEAMANAN

Ini langkah paling penting. Jangan lewati.

Ganti `<PROJECT>` dan `<PUBLISHABLE_KEY>` dengan nilai sebenarnya, lalu jalankan:

**Uji 1 — baca harus berhasil:**

```bash
curl "https://<PROJECT>.supabase.co/rest/v1/modul?select=*" \
  -H "apikey: <PUBLISHABLE_KEY>" \
  -H "Authorization: Bearer <PUBLISHABLE_KEY>"
```

Harapan: `[]` (array kosong, karena belum ada data). Ini berarti koneksi berhasil.

**Uji 2 — tulis harus GAGAL:**

```bash
curl -X POST "https://<PROJECT>.supabase.co/rest/v1/modul" \
  -H "apikey: <PUBLISHABLE_KEY>" \
  -H "Authorization: Bearer <PUBLISHABLE_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"slug":"uji-keamanan","judul":"Uji","topik":"array","deskripsi":"tes"}'
```

Harapan: **gagal** dengan status 401 atau 403, dan pesan menyebut `row-level security` atau `permission denied`.

**Jika Uji 2 berhasil (data masuk), JANGAN LANJUT.** Berarti RLS belum benar. Periksa ulang blok `revoke` di `05-SKEMA-DATABASE.md` §4.3.

### 3.6 Mengisi Data Contoh

1. Buat query baru di SQL Editor
2. Salin isi `supabase/seed.sql` dari `05-SKEMA-DATABASE.md` §6
3. Klik **Run**

Verifikasi:

```sql
select
  (select count(*) from modul) as modul,
  (select count(*) from bagian_modul) as bagian,
  (select count(*) from flashcard) as kartu,
  (select count(*) from soal) as soal,
  (select count(*) from opsi_soal) as opsi;
```

Harapan: `1, 5, 8, 3, 12`.

### 3.7 Konfigurasi Environment Variable

```bash
# .env.local

VITE_SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxxxxxxxxxxx
```

```bash
# .env.example — di-commit ke repo, berisi placeholder

VITE_SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxxxxxxxxxxx
```

**Pastikan `.env.local` ada di `.gitignore`:**

```bash
echo ".env.local" >> .gitignore
echo ".env*.local" >> .gitignore
```

**Verifikasi `.env.local` tidak terlacak Git:**

```bash
git status --porcelain | grep env
# Harapan: tidak ada .env.local
```

---

## 4. Mencoba Skema Secara Lokal (Opsional)

Bagian ini opsional. Untuk mengembangkan FlashStruct, kamu **tidak perlu** database lokal sama sekali — cukup pakai Supabase hosted dari §3.

Bagian ini berguna jika kamu ingin:

- Menguji skema dan RLS tanpa takut merusak data online
- Memverifikasi bahwa migrasi berjalan bersih dari database kosong
- Bereksperimen dengan query sebelum menerapkannya di aplikasi

**Pendekatan yang dipakai: PostgreSQL lokal langsung.** Tidak memakai Docker, tidak memakai Supabase CLI. Hanya PostgreSQL yang dipasang di sistem.

### 4.1 Memasang PostgreSQL

**Arch / CachyOS / Manjaro:**

```bash
sudo pacman -S postgresql
```

**Ubuntu / Debian:**

```bash
sudo apt install postgresql postgresql-contrib
```

**Fedora:**

```bash
sudo dnf install postgresql-server postgresql-contrib
sudo postgresql-setup --initdb
```

**macOS (Homebrew):**

```bash
brew install postgresql@16
brew services start postgresql@16
```

Verifikasi:

```bash
postgres --version
# Harapan: postgres (PostgreSQL) 15 atau lebih baru
```

### 4.2 Menyiapkan Database Uji

Pilih salah satu cara berikut.

**Cara A — Pakai cluster bawaan sistem (paling mudah):**

```bash
# Jalankan service
sudo systemctl start postgresql
sudo systemctl enable postgresql   # agar otomatis jalan saat boot

# Masuk sebagai user postgres
sudo -u postgres psql
```

Di dalam prompt `psql`:

```sql
create database flashstruct_uji;
create user fs_dev with password 'dev-saja';
grant all privileges on database flashstruct_uji to fs_dev;
\q
```

**Cara B — Cluster terpisah tanpa sudo (lebih bersih):**

Cara ini membuat cluster PostgreSQL sendiri di folder home, tidak menyentuh instalasi sistem, dan tidak butuh sudo setelah `initdb`.

```bash
# Buat folder data
mkdir -p ~/pg-flashstruct
initdb -D ~/pg-flashstruct/data

# Jalankan di port berbeda agar tidak bentrok dengan PostgreSQL sistem
pg_ctl -D ~/pg-flashstruct/data -o "-p 5433" -l ~/pg-flashstruct/log.txt start

# Buat database
createdb -p 5433 flashstruct_uji
```

Untuk menghentikan:

```bash
pg_ctl -D ~/pg-flashstruct/data stop
```

### 4.3 Menerapkan Skema

```bash
# Cara A (cluster sistem)
psql -U fs_dev -d flashstruct_uji -f supabase/migrations/001_initial_schema.sql

# Cara B (cluster terpisah, port 5433)
psql -p 5433 -d flashstruct_uji -f supabase/migrations/001_initial_schema.sql
```

### 4.4 Uji RLS Secara Lokal

RLS di Supabase memakai role `anon` dan `authenticated` yang **tidak ada** di PostgreSQL biasa. Untuk menguji, buat role tersebut lebih dulu.

```sql
-- Buat role tiruan (hanya untuk pengujian lokal)
create role anon nologin;
create role authenticated nologin;
```

Lalu jalankan berkas RLS:

```bash
psql -U fs_dev -d flashstruct_uji -f supabase/migrations/002_rls_policies.sql
```

Verifikasi bahwa RLS benar-benar melindungi:

```bash
psql -U fs_dev -d flashstruct_uji -c "set role anon; select count(*) from modul;"
# Harapan: berhasil, menampilkan angka

psql -U fs_dev -d flashstruct_uji -c "set role anon; insert into modul(slug,judul,topik,deskripsi) values ('hack','X','array','y');"
# Harapan: ERROR: permission denied for table modul

psql -U fs_dev -d flashstruct_uji -c "set role anon; delete from modul;"
# Harapan: ERROR: permission denied for table modul
```

Jika kedua perintah terakhir **berhasil**, berarti RLS belum benar. Periksa ulang blok `revoke` di `05-SKEMA-DATABASE.md` §4.3.

### 4.5 Mengisi Data Contoh

```bash
psql -U fs_dev -d flashstruct_uji -f supabase/seed.sql
```

Verifikasi:

```sql
select
  (select count(*) from modul) as modul,
  (select count(*) from bagian_modul) as bagian,
  (select count(*) from flashcard) as kartu,
  (select count(*) from soal) as soal,
  (select count(*) from opsi_soal) as opsi;
```

Harapan: `1, 5, 8, 3, 12`.

### 4.6 Menjalankan Pemeriksa Konten

Jalankan semua query dari `05-SKEMA-DATABASE.md` §7. Semua harus mengembalikan 0 baris.

```bash
psql -U fs_dev -d flashstruct_uji -f supabase/checks.sql
```

### 4.7 Mengulang dari Awal

Untuk menguji migrasi dari database kosong:

```bash
dropdb -U fs_dev flashstruct_uji
createdb -U fs_dev flashstruct_uji
psql -U fs_dev -d flashstruct_uji -f supabase/migrations/001_initial_schema.sql
psql -U fs_dev -d flashstruct_uji -f supabase/migrations/002_rls_policies.sql
psql -U fs_dev -d flashstruct_uji -f supabase/seed.sql
```

**Penting:** database lokal ini **hanya untuk menguji skema**. Aplikasi React tetap terhubung ke Supabase hosted, karena PostgreSQL biasa tidak menyediakan REST API (PostgREST) yang dipakai `@supabase/supabase-js`.

### 4.8 Perbandingan

| Aspek | PostgreSQL lokal | Supabase hosted |
|-------|------------------|-----------------|
| Uji skema dan RLS | Bisa | Bisa (hati-hati, ini data nyata) |
| Dipakai aplikasi React | **Tidak bisa** (tanpa REST API) | Ya |
| Butuh Docker | Tidak | Tidak |
| Berat | Ringan (± 40 MB RAM) | Tidak ada beban lokal |
| Bisa offline | Ya | Tidak |
| Data hilang saat reset | Ya, dan itu tujuannya | **Tidak boleh** |

**Rekomendasi:** gunakan PostgreSQL lokal hanya untuk memverifikasi migrasi sebelum menerapkannya ke Supabase. Untuk pengembangan sehari-hari, langsung pakai Supabase hosted — lebih sederhana dan persis sama dengan lingkungan production.

### 4.9 Catatan: Mengapa Tidak Memakai Supabase CLI

Supabase CLI (`npx supabase start`) menjalankan seluruh stack Supabase di lokal, tetapi **membutuhkan container runtime seperti Docker**. Karena proyek ini menghindari Docker, pendekatan PostgreSQL langsung di atas sudah cukup untuk kebutuhan pengujian skema.

Supabase CLI juga membutuhkan unduhan image berukuran beberapa GB dan memakan RAM 2–4 GB — jauh lebih berat daripada PostgreSQL biasa yang hanya ± 40 MB.

---

## 5. Menjalankan Aplikasi

### 5.1 Mode Pengembangan

```bash
npm run dev
```

Buka `http://localhost:5173`.

### 5.2 Perintah Harian

| Perintah | Kegunaan | Kapan |
|----------|----------|-------|
| `npm run dev` | Dev server dengan HMR | Saat mengembangkan |
| `npm run build` | Build produksi | Sebelum commit atau deploy |
| `npm run preview` | Pratinjau hasil build | Setelah build, untuk cek hasil nyata |
| `npm run test` | Jalankan semua uji sekali | Sebelum commit |
| `npm run test:watch` | Uji mode pantau | Saat mengembangkan fitur |
| `npm run typecheck` | Periksa tipe | Sebelum commit |
| `npm run lint` | Periksa kode | Sebelum commit |
| `npm run format` | Format kode | Sesudah menulis banyak kode |

### 5.3 Alur Kerja Harian

```bash
# 1. Pastikan kode terbaru
git pull

# 2. Buat branch untuk fitur
git checkout -b fitur/halaman-flashcard

# 3. Kembangkan
npm run dev
# ... tulis kode ...

# 4. Sebelum commit
npm run typecheck && npm run lint && npm run test && npm run build

# 5. Commit
git add .
git commit -m "feat: tambah sesi flashcard dengan animasi flip"

# 6. Push
git push origin fitur/halaman-flashcard
```

### 5.4 Menambah Modul Baru

Setelah UI stabil, menambah modul hanya perlu menambah data:

1. Buka Supabase SQL Editor
2. Tulis `insert` untuk modul baru (ikuti pola di `05-SKEMA-DATABASE.md` §6)
3. Jalankan pemeriksa konten dari `05-SKEMA-DATABASE.md` §7
4. Muat ulang aplikasi — modul baru langsung muncul

**Tidak ada perubahan kode yang diperlukan.** Inilah keuntungan memisahkan konten dari kode.

---

## 6. Deploy

### 6.1 Deploy ke Vercel (Direkomendasikan)

**Alasan memilih Vercel:**

- Mendeteksi Vite otomatis, tanpa konfigurasi build
- SPA rewrite paling sederhana
- Deploy otomatis setiap push ke `main`
- Free Plan cukup untuk proyek ini

**Langkah:**

1. Push kode ke GitHub:

```bash
git remote add origin https://github.com/<USERNAME>/flashstruct.git
git push -u origin main
```

2. Buka [vercel.com](https://vercel.com), masuk dengan akun GitHub

3. Klik **Add New** > **Project**

4. Pilih repository `flashstruct`

5. Vercel mendeteksi Vite otomatis. Pastikan:

| Setting | Nilai |
|---------|-------|
| Framework Preset | Vite |
| Build Command | `npm run build` |
| Output Directory | `dist` |
| Install Command | `npm install` |

6. Buka **Environment Variables**, tambahkan:

| Name | Value |
|------|-------|
| `VITE_SUPABASE_URL` | URL project Supabase |
| `VITE_SUPABASE_PUBLISHABLE_KEY` | Publishable key |

7. Klik **Deploy**, tunggu 1–2 menit

**Konfigurasi SPA rewrite:**

Buat berkas `vercel.json` di root proyek:

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

**Mengapa ini penting:** tanpa rewrite, membuka `https://situs.com/materi/array-dasar` langsung atau me-refresh di halaman itu akan menghasilkan **404**, karena Vercel mencari berkas fisik di path tersebut yang tidak ada.

**Setelah deploy:**

- [ ] Situs bisa dibuka
- [ ] Refresh di `/materi/array-dasar` tidak 404
- [ ] Konten dari Supabase termuat
- [ ] Tidak ada error di console

**Environment variable berubah?** Di Vercel, perubahan environment variable **hanya berlaku untuk deployment baru**. Setelah mengubah, lakukan redeploy.

### 6.2 Deploy ke Netlify

**Langkah:**

1. Push kode ke GitHub
2. Buka [netlify.com](https://netlify.com), masuk dengan GitHub
3. Klik **Add new site** > **Import an existing project**
4. Pilih repository
5. Pastikan setting:

| Setting | Nilai |
|---------|-------|
| Build command | `npm run build` |
| Publish directory | `dist` |

6. Buka **Site configuration** > **Environment variables**, tambahkan dua variabel Supabase
7. Klik **Deploy**

**Konfigurasi SPA rewrite — pilih salah satu:**

**Opsi A** — buat `public/_redirects`:

```text
/*  /index.html  200
```

**Opsi B** — buat `netlify.toml` di root:

```toml
[build]
  command = "npm run build"
  publish = "dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

**Penjelasan status `200`:** ini **rewrite**, bukan redirect. URL di address bar tetap sama, tetapi yang disajikan adalah `index.html`. Dengan `301` atau `302`, URL akan berubah dan routing React Router rusak.

### 6.3 Deploy ke GitHub Pages

**Peringatan:** GitHub Pages **tidak mendukung SPA rewrite**. Membuka rute dalam secara langsung atau me-refresh akan menghasilkan 404.

Ada dua pilihan:

**Pilihan A — Terima 404 pada rute dalam.** Pengguna yang membuka `https://user.github.io/flashstruct/materi/array-dasar` langsung akan melihat 404 dan harus kembali ke beranda. Navigasi di dalam aplikasi tetap berfungsi normal.

**Pilihan B — Ganti ke `HashRouter`.** URL menjadi `https://user.github.io/flashstruct/#/materi/array-dasar`. Refresh berfungsi, tetapi URL kurang bersih.

```typescript
// app/router.tsx
import { createHashRouter } from 'react-router-dom';

export const router = createHashRouter([ /* ...rute... */ ]);
```

**Rekomendasi: pakai Vercel atau Netlify.** Keduanya gratis dan mendukung URL bersih. GitHub Pages hanya tepat jika kamu punya alasan khusus untuk memakainya.

**Jika tetap memilih GitHub Pages:**

1. Set `base` di `vite.config.ts`:

```typescript
export default defineConfig({
  // Jika di https://<USERNAME>.github.io/<REPO>/
  base: '/flashstruct/',
  // Jika di https://<USERNAME>.github.io/ atau domain sendiri
  // base: '/',
  plugins: [react(), tailwindcss()],
});
```

2. Buat `.github/workflows/deploy.yml`:

```yaml
name: Deploy ke GitHub Pages

on:
  push:
    branches: ['main']
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: 'pages'
  cancel-in-progress: true

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 'lts/*'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build
        env:
          VITE_SUPABASE_URL: ${{ secrets.VITE_SUPABASE_URL }}
          VITE_SUPABASE_PUBLISHABLE_KEY: ${{ secrets.VITE_SUPABASE_PUBLISHABLE_KEY }}

      - name: Setup Pages
        uses: actions/configure-pages@v5

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: './dist'

      - name: Deploy
        id: deployment
        uses: actions/deploy-pages@v4
```

3. Tambahkan secrets di GitHub: **Settings** > **Secrets and variables** > **Actions** > **New repository secret**

4. Aktifkan Pages: **Settings** > **Pages** > **Source: GitHub Actions**

**Limit GitHub Pages:** 1 GB ukuran situs, bandwidth lunak 100 GB/bulan, deployment timeout 10 menit.

### 6.4 Ringkasan Perbandingan Platform

| Aspek | Vercel | Netlify | GitHub Pages |
|-------|--------|---------|--------------|
| Setup | Paling mudah | Mudah | Sedang |
| Deteksi Vite otomatis | Ya | Ya | Tidak |
| SPA rewrite | `vercel.json` | `_redirects` | Tidak didukung |
| URL bersih | Ya | Ya | Hanya dengan HashRouter |
| Deploy otomatis | Ya | Ya | Ya (via Actions) |
| Cocok untuk proyek ini | **Paling cocok** | Cocok | Kurang cocok |

---

## 7. Pemecahan Masalah

### 7.1 Masalah Setup

**`npm create vite` gagal**

Periksa versi Node: `node --version` harus 20 atau lebih. Jika lebih lama, perbarui Node lewat [nodejs.org](https://nodejs.org) atau `nvm`.

**Port 5173 sudah dipakai**

```bash
npm run dev -- --port 5174
```

**`Cannot find module '@/...'`**

Periksa dua tempat:
1. `tsconfig.json` punya `paths: { "@/*": ["./src/*"] }`
2. `vite.config.ts` punya `resolve.alias` dengan `@`

Keduanya harus ada. TypeScript memakai `paths`, Vite memakai `alias`.

### 7.2 Masalah Supabase

**`Invalid API key`**

- Periksa `.env.local` sudah berisi nilai yang benar
- Pastikan tidak ada spasi tambahan
- **Restart dev server** setelah mengubah `.env.local` — Vite hanya membaca env saat start

**Data tidak muncul, tapi tidak ada error**

Kemungkinan penyebab:
1. RLS aktif tapi tidak ada policy SELECT → tambahkan policy
2. Tabel tidak diekspos ke Data API → periksa **Integrations** > **Data API** di dashboard

**`permission denied for table`**

Ini justru tanda RLS bekerja jika kamu mencoba menulis. Jika muncul saat **membaca**, berarti grant `select` belum diberikan. Periksa langkah `grant select` di blok RLS.

**`new row violates row-level security policy`**

Muncul saat mencoba menulis dari client. Ini **benar** — client memang tidak boleh menulis. Jika perlu menambah konten, gunakan SQL Editor di dashboard, bukan dari aplikasi.

**Project di-pause**

Free Plan Supabase men-pause project setelah **7 hari tanpa aktivitas**. Jika situs menampilkan error koneksi:

1. Buka dashboard Supabase
2. Klik **Restore project**
3. Tunggu beberapa menit

**Pencegahan:** project dengan pengunjung rutin tidak akan di-pause. Jika situs masih dalam pengembangan, buka dashboard sekali seminggu.

### 7.3 Masalah Deploy

**404 saat refresh di rute dalam**

SPA rewrite belum dikonfigurasi. Lihat §6.1 (Vercel) atau §6.2 (Netlify).

**Halaman kosong setelah deploy**

Kemungkinan penyebab:
1. Environment variable belum diatur di platform
2. Environment variable diatur setelah deployment terakhir → lakukan redeploy
3. `base` di `vite.config.ts` salah (khusus GitHub Pages)

Cek console browser untuk error spesifik.

**Aset tidak termuat (gambar, font)**

Jika deploy ke GitHub Pages di subpath, `base` di `vite.config.ts` harus diset ke `/<REPO>/`.

**`VITE_SUPABASE_URL is not defined`**

Environment variable tidak terbaca. Ingat:
- Vite hanya mengekspos variabel berawalan `VITE_`
- Perubahan env butuh restart dev server (lokal) atau redeploy (production)

### 7.4 Masalah Data

**Progres hilang**

Penyebab umum:
1. Data browser dibersihkan
2. Mode privat (data dihapus saat tab ditutup)
3. Buka di browser atau perangkat berbeda
4. Domain berubah (misalnya dari `localhost` ke domain production)

Ini **perilaku yang diharapkan** karena v1 tidak punya autentikasi. Gunakan fitur ekspor/impor untuk memindahkan progres.

**Progres tidak tersimpan**

- Periksa `localStorage` tidak penuh
- Periksa mode privat browser
- Buka DevTools > Application > Local Storage, cari kunci `flashstruct:progres:v1`

**Kartu tidak muncul di sesi flashcard**

- Periksa modul punya kartu di database
- Periksa Tahap 1 sudah selesai (Tahap 2 terkunci jika belum)
- Buka console, cari error

### 7.5 Masalah Tampilan

**Tema gelap tidak bekerja**

- Periksa atribut `data-theme="dark"` ada di `<html>`
- Periksa `tokens.css` punya blok `[data-theme="dark"]`

**Kode tidak berwarna**

Shiki gagal dimuat. Periksa:
- Koneksi internet (Shiki dimuat dinamis)
- Tidak ada error di console
- Blok kode punya penanda bahasa yang valid (`cpp` atau `python`)

**Layout berantakan di mobile**

- Periksa `<meta name="viewport" content="width=device-width, initial-scale=1">` ada di `index.html`
- Uji di 375px dengan DevTools

### 7.6 Masalah Performa

**Aplikasi terasa lambat**

1. Jalankan `npm run build` dan periksa ukuran bundle
2. Pastikan Shiki dan react-markdown dimuat lazy
3. Buka DevTools > Network, cari berkas besar

**Animasi tersendat**

- Periksa hanya `transform` dan `opacity` yang dianimasikan
- Rekam dengan DevTools > Performance untuk menemukan penyebab

---

## 8. Checklist Setup

### 8.1 Setup Lokal

- [ ] Node.js 20+ terpasang
- [ ] Proyek Vite dibuat
- [ ] Semua dependensi terpasang
- [ ] `vite.config.ts` punya alias `@`
- [ ] `tsconfig.json` punya `paths`
- [ ] Tailwind v4 terkonfigurasi
- [ ] `tokens.css` disalin dari design system
- [ ] Struktur folder dibuat
- [ ] `npm run dev` berjalan
- [ ] `npm run typecheck` bersih
- [ ] `npm run lint` bersih
- [ ] `npm run test` berjalan
- [ ] `npm run build` berhasil

### 8.2 Setup Supabase

- [ ] Project Supabase dibuat
- [ ] Region dipilih yang terdekat
- [ ] Kredensial dicatat
- [ ] Skema database dijalankan
- [ ] RLS dijalankan
- [ ] **Uji tulis GAGAL** (bukti RLS aktif)
- [ ] **Uji hapus GAGAL**
- [ ] Seed dijalankan
- [ ] Data seed terverifikasi
- [ ] `.env.local` dibuat
- [ ] `.env.example` dibuat
- [ ] `.env.local` ada di `.gitignore`
- [ ] Aplikasi bisa membaca data dari Supabase

### 8.3 Setup Deploy

- [ ] Kode di-push ke GitHub
- [ ] Project dibuat di Vercel/Netlify
- [ ] Build command: `npm run build`
- [ ] Output directory: `dist`
- [ ] Environment variable diatur
- [ ] SPA rewrite dikonfigurasi
- [ ] Deploy berhasil
- [ ] Situs bisa dibuka
- [ ] Refresh di rute dalam tidak 404
- [ ] Konten termuat
- [ ] Tidak ada error di console

---

## 9. Perintah Referensi Cepat

```bash
# Pengembangan
npm run dev                    # Dev server
npm run build                  # Build produksi
npm run preview                # Pratinjau build

# Kualitas kode
npm run typecheck              # Periksa tipe
npm run lint                   # Periksa kode
npm run lint:fix               # Perbaiki otomatis
npm run format                 # Format kode

# Pengujian
npm run test                   # Uji sekali
npm run test:watch             # Uji mode pantau
npm run test:ui                # Uji dengan antarmuka

# Git
git checkout -b fitur/nama     # Branch baru
git add . && git commit -m "..." # Commit
git push origin fitur/nama     # Push

# PostgreSQL lokal untuk uji skema (opsional)
sudo systemctl start postgresql   # Jalankan service
sudo -u postgres psql             # Masuk
pg_ctl -D ~/pg-flashstruct/data -o "-p 5433" -l ~/pg-flashstruct/log.txt start
psql -U fs_dev -d flashstruct_uji -f supabase/migrations/001_initial_schema.sql
psql -U fs_dev -d flashstruct_uji -f supabase/migrations/002_rls_policies.sql
dropdb -U fs_dev flashstruct_uji && createdb -U fs_dev flashstruct_uji  # Reset

# Verifikasi RLS
curl "https://<PROJECT>.supabase.co/rest/v1/modul?select=*" \
  -H "apikey: <KEY>" -H "Authorization: Bearer <KEY>"
```

---

## 10. Referensi Silang

| Topik | Dokumen |
|-------|---------|
| Stack dan alasan pemilihan | `04-ARSITEKTUR-TEKNIS.md` §1 |
| Struktur folder lengkap | `04-ARSITEKTUR-TEKNIS.md` §2.2 |
| Skema database | `05-SKEMA-DATABASE.md` §3 |
| RLS dan verifikasinya | `05-SKEMA-DATABASE.md` §4 |
| Seed data | `05-SKEMA-DATABASE.md` §6 |
| Token yang harus disalin | `03-DESIGN-SYSTEM.md` §2.6 |
| Checklist sebelum rilis | `08-CHECKLIST-QA.md` |
| Tautan sumber resmi | `riset/01-RISET-TEKNIS.md` |
