# 10 — Keputusan Stack & Deploy Gratis

> Jawaban atas pertanyaan: **stack apa yang dipakai agar FlashStruct bisa online gratis di vercel.app?**
> Status: `[FINAL]` · Fakta dan kutipan sumber ada di `riset/02-RISET-DEPLOY-GRATIS.md`

---

## 1. Jawaban Singkat

**Pakai React + Vite + TypeScript (bukan Firebase), host di Vercel, database di Supabase.**

| Lapisan | Pilihan | Biaya |
|---------|---------|-------|
| Frontend | React 19 + Vite + TypeScript | Gratis (open source) |
| Hosting | **Vercel Hobby** | **Rp0** |
| Database | **Supabase Free** | **Rp0** |
| Domain | `flashstruct.vercel.app` | **Rp0** |

**Total: Rp0 per bulan.**

**Jangan pakai Firebase** untuk proyek ini. Alasannya bukan soal gratis atau tidak — Firebase Spark juga gratis — tetapi karena **Firestore (NoSQL) tidak cocok untuk struktur data FlashStruct** yang relasional. Detail di §4.

---

## 2. Mengapa Bukan Firebase

Ini pertanyaan yang bagus, dan jawabannya perlu dijelaskan karena Firebase sering dianggap pilihan default untuk proyek gratis.

### 2.1 Masalah Utama: Firestore Itu NoSQL

Struktur data FlashStruct **secara alami relasional**:

```
modul (1) ──< bagian_modul (banyak)
modul (1) ──< flashcard    (banyak)
modul (1) ──< soal         (banyak)
soal  (1) ──< opsi_soal    (banyak)
```

Di PostgreSQL, ini langsung dipetakan ke foreign key dan satu query bisa mengambil semuanya sekaligus:

```typescript
// Supabase — SATU request, ambil modul + semua turunannya
const { data } = await supabase
  .from('modul')
  .select(`
    id, slug, judul,
    bagian_modul ( id, judul, konten_md ),
    flashcard ( id, depan, belakang ),
    soal ( id, pertanyaan, opsi_soal ( id, label, teks, benar ) )
  `)
  .eq('slug', 'array-dasar')
  .single();
```

Di Firestore, tidak ada JOIN di Standard edition (yang dipakai Spark plan). Query yang sama harus dipecah dan disusun manual di client.

### 2.2 Jebakan Firestore yang Terdokumentasi Resmi

Ini bukan opini — dokumentasi resmi Firebase sendiri yang menyatakannya:

| Jebakan | Kutipan resmi | Dampak untuk FlashStruct |
|---------|---------------|--------------------------|
| **Tidak ada JOIN** | Join hanya ada di Enterprise edition (Pipeline operations) | Harus denormalisasi atau query berlapis |
| **Hapus dokumen tidak menghapus subcollection** | *"Deleting a document does not delete its subcollections!"* | Menghapus modul meninggalkan kartu dan soal yatim |
| **Nested list tidak scalable** | *"This isn't as scalable as other options... With larger or growing lists, the document also grows, which can lead to slower document retrieval times."* | Daftar kartu tidak boleh ditanam dalam satu dokumen |
| **Dokumen maks 1 MiB** | *"Maximum size for a document: 1 MiB"* | Modul dengan banyak konten bisa mentok |
| **Hierarki jadi rumit** | *"Getting data that is naturally hierarchical might become increasingly complex as your database grows."* | Persis masalah yang dihadapi FlashStruct |
| **Query lebih banyak** | Setiap modul butuh 3–4 query terpisah | Lebih banyak pembacaan, kuota lebih cepat habis |

**Kutipan terakhir sangat relevan:** dokumentasi Firebase sendiri mengakui bahwa data yang "naturally hierarchical" menjadi semakin rumit di Firestore. FlashStruct **adalah** data hierarkis.

### 2.3 Batasan Firebase Hosting

Selain masalah database, Firebase Hosting punya transfer **360 MB per hari**. Vercel Hobby memberi **100 GB per bulan** (± 3,3 GB/hari) — sekitar 9 kali lebih longgar.

### 2.4 Kapan Firebase Justru Lebih Tepat

Supaya penilaian ini adil, Firebase lebih baik jika:

- Data tidak relasional (misalnya hanya daftar artikel datar)
- Butuh autentikasi siap pakai (Firebase Auth sangat matang)
- Butuh realtime sync antar pengguna
- Sudah familiar dengan ekosistem Google

**Tidak ada satu pun dari kondisi itu yang berlaku untuk FlashStruct v1.**

---

## 3. Mengapa Vercel + Supabase

### 3.1 Kecocokan Teknis

| Kebutuhan FlashStruct | Vercel | Supabase |
|----------------------|--------|----------|
| Host SPA React | Ya, deteksi Vite otomatis | — |
| URL bersih tanpa `#` | Ya, `vercel.json` rewrite | — |
| Database relasional | — | Ya, PostgreSQL penuh |
| API tanpa backend sendiri | — | Ya, REST API otomatis (PostgREST) |
| Query bertingkat satu request | — | Ya, foreign key embedding |
| Constraint data | — | Ya, `check`, `unique`, foreign key |
| Baca publik, tulis tertutup | — | Ya, RLS |

### 3.2 Kuota Lebih dari Cukup

| Sumber daya | Batas gratis | Kebutuhan FlashStruct | Sisa |
|-------------|--------------|----------------------|------|
| Transfer Vercel | 100 GB/bulan | ± 1 GB/bulan | 99% |
| Database Supabase | 500 MB | ± 5 MB (teks saja) | 99% |
| Egress Supabase | 5 GB/bulan | ± 200 MB/bulan | 96% |
| API request Supabase | Tanpa batas | — | — |
| Deploy Vercel | 100/hari | 2–5/hari saat aktif | 95% |

Perhitungan untuk 1.000 pengunjung/bulan: setiap pengunjung memuat ± 1 MB (bundle + konten), jadi ± 1 GB/bulan. Batasnya 100 GB.

### 3.3 Alur Deploy

```
GitHub  ──push──>  Vercel  ──fetch konten──>  Supabase
   │                  │                          │
 kode kamu        hosting gratis            database gratis
                  (React SPA)               (PostgreSQL)
```

Sekali setup, setiap `git push` otomatis ter-deploy. Tidak ada server yang perlu diurus.

---

## 4. Perbandingan Stack (Data dari Riset)

| Aspek | **A: Vercel + Supabase** | B: Vercel + Firebase | C: Firebase penuh | D: Cloudflare + Supabase |
|-------|--------------------------|----------------------|-------------------|--------------------------|
| Biaya | Rp0 | Rp0 | Rp0 | Rp0 |
| Database | PostgreSQL relasional | Firestore NoSQL | Firestore NoSQL | PostgreSQL relasional |
| Query bertingkat | **1 request** | 3–4 request | 3–4 request | **1 request** |
| Constraint database | Ya | Tidak | Tidak | Ya |
| Hapus berantai | Otomatis | Manual | Manual | Otomatis |
| Transfer hosting | 100 GB/bulan | 100 GB/bulan | 360 MB/hari | **Tanpa batas** |
| Batasan komersial | Non-komersial (lihat §5) | Non-komersial | Tidak ada | Belum terverifikasi |
| Kemudahan setup | Paling mudah | Sedang | Mudah | Mudah |
| **Untuk FlashStruct** | **Paling cocok** | Kurang cocok | Kurang cocok | Alternatif aman |

**Kesimpulan:** Stack A menang karena **kecocokan data**, bukan karena kuota. Kuota semua pilihan gratis sudah lebih dari cukup.

---

## 5. Peringatan Penting: Batasan Vercel Hobby

Ini harus kamu tahu sebelum memakai Vercel.

### 5.1 Vercel Hobby Hanya untuk Non-Komersial

Kutipan resmi dari Vercel:

> "Hobby teams are restricted to non-commercial personal use only. All commercial usage of the platform requires either a Pro or Enterprise plan."
> — [Vercel Fair Use Guidelines](https://vercel.com/docs/limits/fair-use-guidelines)

Dan dari Terms of Service:

> "You shall only use the Services under a Hobby plan for your personal or non-commercial use. ... We reserve the right to disable or remove any Project or website deployment on the Hobby plan with or without notice at our sole discretion."
> — [Vercel Terms of Service §4](https://vercel.com/legal/terms)

### 5.2 Apakah FlashStruct Melanggar?

**Tidak**, selama memenuhi semua kondisi ini:

| Kondisi | Status FlashStruct |
|---------|-------------------|
| Tidak ada iklan (AdSense dll.) | Aman — tidak ada iklan |
| Tidak menjual produk/jasa | Aman — sepenuhnya gratis |
| Tidak ada pembayaran dari pengunjung | Aman |
| Tidak ada affiliate link | Aman |
| **Tidak ada pihak yang dibayar** untuk membuat/mengelola/menghosting | **Perlu kamu pastikan** |
| Donasi | **Diperbolehkan** — "Asking for Donations does not fall under commercial usage" |

### 5.3 Yang Perlu Kamu Waspadai

**Definisi "commercial" Vercel sangat luas:**

> "any Deployment that is used for the purpose of financial gain of **anyone** involved in **any part of the production** of the project, including a paid employee or consultant writing the code."

Artinya: jika **kamu sendiri** dibayar seseorang untuk membuat FlashStruct, statusnya berubah menjadi komersial dan **melanggar** ketentuan Hobby. Jika kamu membuatnya sendiri tanpa bayaran (misalnya untuk tugas kuliah atau skripsi), aman.

**Jika situasinya berubah** (misalnya proyek ini nanti jadi produk berbayar, atau kamu dibayar untuk mengerjakannya), ada dua pilihan:
1. Upgrade ke Vercel Pro ($20/bulan)
2. Pindah hosting ke Cloudflare Pages (gratis, tidak ada batasan bandwidth)

### 5.4 Vercel Boleh Menghapus Situsmu Tanpa Pemberitahuan

Kutipan ToS di atas menyatakan Vercel berhak menonaktifkan deployment Hobby "with or without notice at our sole discretion."

**Mitigasi:** simpan kode di GitHub. Jika Vercel menghapus situsmu, kamu bisa deploy ulang ke Cloudflare Pages atau Netlify dalam hitungan menit karena kodenya tidak hilang.

### 5.5 Satu Catatan Lagi: Konten Boleh Dipakai untuk Training AI

ToS Vercel menyatakan konten pada plan Hobby dapat dipakai untuk melatih model AI. Untuk proyek edukasi terbuka ini, itu dapat diterima. Jika kamu tidak nyaman, gunakan Cloudflare Pages.

---

## 6. Alternatif Gratis (Jika Vercel Tidak Cocok)

### 6.1 Cloudflare Pages + Supabase

**Kapan pilih ini:** jika ada keraguan soal aturan komersial Vercel, atau ingin bandwidth benar-benar tanpa batas.

| Kelebihan | Kekurangan |
|-----------|------------|
| Aset statis "free and unlimited" | ToS-nya belum terverifikasi menyeluruh |
| SPA didukung otomatis | Ekosistem tooling kurang familiar |
| Tidak ada batasan bandwidth | — |

Konfigurasi SPA-nya bahkan lebih sederhana dari Vercel — tidak perlu berkas konfigurasi sama sekali, Cloudflare menangani SPA secara otomatis.

### 6.2 Netlify + Supabase

**Kapan pilih ini:** jika sudah familiar dengan Netlify.

| Kelebihan | Kekurangan |
|-----------|------------|
| SPA rewrite satu baris (`_redirects`) | Model kredit 300/bulan dengan **hard limit** |
| UI sederhana | Kredit bisa habis tanpa disadari |
| — | ToS-nya berupa PDF, klausul komersial belum terverifikasi |

Untuk 1.000 pengunjung/bulan, 300 kredit sebenarnya masih cukup (15 GB bandwidth). Tetapi model kredit lebih mudah membingungkan daripada kuota biasa.

### 6.3 Yang Tidak Direkomendasikan

| Layanan | Alasan |
|---------|--------|
| **PlanetScale** | Tidak punya free tier lagi di 2026 |
| **Fly.io** | Hanya trial 7 hari |
| **Railway** | Free plan hanya $1 kredit/bulan, tanpa custom domain |
| **Render** | PostgreSQL free expired setelah 30 hari |
| **GitHub Pages** | Tidak ada SPA rewrite resmi; perlu `HashRouter` (URL jadi ada `#`) |

### 6.4 Ringkasan Pilihan Hosting

| Platform | Bandwidth Gratis | SPA Rewrite | Batasan Komersial | Rekomendasi |
|----------|------------------|-------------|-------------------|-------------|
| **Vercel** | 100 GB/bulan | Ya | Non-komersial | **Pilihan utama** |
| Cloudflare Pages | Tanpa batas | Otomatis | Belum terverifikasi | Alternatif aman |
| Netlify | 300 kredit/bulan | Ya | Belum terverifikasi | Alternatif |
| Firebase Hosting | 360 MB/hari | Ya | Tidak ada | Kurang longgar |
| GitHub Pages | 100 GB (soft) | Tidak | Tidak ada | Perlu `HashRouter` |

---

## 7. Keputusan Final

### 7.1 Stack yang Dipakai

```
Frontend   : React 19 + Vite + TypeScript
Styling    : Tailwind CSS v4
Routing    : React Router v7
Data       : TanStack Query + Supabase JS
Animasi    : Motion
Backend    : Supabase (PostgreSQL + REST API)
Hosting    : Vercel Hobby
Domain     : <nama>.vercel.app
```

**Total biaya: Rp0/bulan.**

### 7.2 Konsekuensi yang Diterima

| Konsekuensi | Mitigasi |
|-------------|----------|
| Supabase pause setelah 7 hari idle | Kunjungi situs minimal seminggu sekali, atau unpause manual dari dashboard (data aman) |
| Vercel bisa hapus situs tanpa notice | Kode di GitHub; bisa redeploy ke Cloudflare dalam menit |
| Hanya boleh non-komersial | Tidak ada iklan, tidak ada monetisasi |
| Tidak boleh ada pekerja berbayar | Kerjakan sendiri |
| Konten boleh dipakai training AI Vercel | Diterima untuk proyek edukasi terbuka |

### 7.3 Jika Salah Satu Asumsi Berubah

| Jika ini terjadi | Lakukan ini |
|------------------|-------------|
| Situs jadi komersial | Pindah ke Cloudflare Pages, atau upgrade Vercel Pro |
| Butuh bandwidth lebih besar | Pindah ke Cloudflare Pages |
| Supabase sering pause | Upgrade Supabase Pro ($25/bulan), atau pindah ke Neon |
| Butuh login pengguna | Tambah Supabase Auth (skema sudah siap, lihat `05-SKEMA-DATABASE.md` §9.3) |

---

## 8. Langkah Setup

Panduan lengkap ada di `09-PANDUAN-SETUP.md`. Ringkasnya:

**Tahap 1 — Database (30 menit):**
1. Buat project Supabase, pilih region Singapore
2. Jalankan DDL dari `05-SKEMA-DATABASE.md` §3
3. Jalankan RLS dari `05-SKEMA-DATABASE.md` §4.3
4. **Verifikasi RLS** dengan uji tulis (harus gagal)
5. Catat URL dan publishable key

**Tahap 2 — Lokal (2 jam):**
1. `npm create vite@latest flashstruct -- --template react-ts`
2. Pasang dependensi
3. Buat `.env.local` berisi kredensial Supabase
4. `npm run dev` dan pastikan data terbaca

**Tahap 3 — Deploy (30 menit):**
1. Push ke GitHub
2. Import repo di Vercel
3. Tambahkan environment variable
4. Buat `vercel.json` untuk SPA rewrite
5. Deploy

**Tahap 4 — Verifikasi:**
1. Buka `<nama>.vercel.app`
2. **Refresh di halaman dalam** (misalnya `/materi/array-dasar`) — harus tidak 404
3. Cek konten dari Supabase termuat

---

## 9. Berkas Konfigurasi Deploy

### 9.1 `vercel.json`

Wajib ada. Tanpa ini, refresh di halaman dalam akan 404.

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

### 9.2 Environment Variable di Vercel

Tambahkan di **Project Settings** > **Environment Variables**:

| Nama | Nilai | Environment |
|------|-------|-------------|
| `VITE_SUPABASE_URL` | `https://xxxxx.supabase.co` | Production, Preview |
| `VITE_SUPABASE_PUBLISHABLE_KEY` | `sb_publishable_xxxxx` | Production, Preview |

**Penting:** perubahan environment variable **hanya berlaku untuk deployment baru**. Setelah menambah atau mengubah, lakukan redeploy.

### 9.3 `.gitignore`

```gitignore
.env
.env.local
.env*.local
node_modules
dist
.vercel
```

---

## 10. Yang Tidak Terverifikasi

Dicatat jujur agar tidak dianggap fakta:

| Klaim | Status |
|-------|--------|
| Kuota build minutes Vercel Hobby (angka pasti) | Halaman pricing menyebut "Included" tanpa angka |
| Durasi maks function Vercel untuk proyek baru (Fluid compute) | Tabel limits hanya memuat proyek lama |
| Apakah Supabase auto-unpause saat ada request | Tidak ditemukan pernyataan eksplisit |
| Batasan komersial Cloudflare Pages | ToS tidak ditinjau menyeluruh |
| Batasan komersial Netlify | ToS berbentuk PDF, tidak terbaca |
| Perilaku tepat saat kuota Firestore Spark habis | Tidak dijelaskan eksplisit |

**Catatan:** semua angka kuota di dokumen ini berasal dari halaman pricing resmi yang diakses September 2026. Harga dan ketentuan dapat berubah — verifikasi ulang sebelum keputusan final.

---

## 11. Referensi Silang

| Topik | Dokumen |
|-------|---------|
| Fakta lengkap dan kutipan sumber | `riset/02-RISET-DEPLOY-GRATIS.md` |
| Langkah setup dan deploy | `09-PANDUAN-SETUP.md` |
| Skema database dan RLS | `05-SKEMA-DATABASE.md` |
| Stack dan struktur kode | `04-ARSITEKTUR-TEKNIS.md` |
| Checklist sebelum rilis | `08-CHECKLIST-QA.md` |
