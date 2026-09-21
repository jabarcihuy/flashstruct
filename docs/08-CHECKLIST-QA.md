# 08 — Checklist QA & Definition of Done

> Checklist yang harus dilewati sebelum FlashStruct dinyatakan selesai.
> Status: `[FINAL]` · Setiap item harus bisa dibuktikan, bukan hanya "sepertinya sudah".

---

## 1. Cara Memakai Dokumen Ini

Checklist ini dipakai dalam dua cara:

| Kapan | Cara pakai |
|-------|-----------|
| **Setiap milestone** | Periksa hanya bagian yang relevan (lihat tabel di §2) |
| **Sebelum rilis** | Periksa **semua** bagian, tanpa kecuali |

**Aturan:** jangan menandai item tercentang jika belum benar-benar diuji. Checklist yang dicentang asal-asalan lebih berbahaya daripada tidak ada checklist, karena memberi rasa aman yang palsu.

---

## 2. Peta Checklist per Milestone

| Bagian | M0 | M1 | M2 | M3 | M4 | M5 | M6 | M7 | M8 | M9 | M10 |
|--------|----|----|----|----|----|----|----|----|----|----|-----|
| §3 Build & Kode | v | v | v | v | v | v | v | v | v | v | v |
| §4 Logika Inti | | | v | v | v | v | v | v | | | v |
| §5 Database & Keamanan | | | v | | | | | | | v | v |
| §6 Halaman | | | | | v | v | v | v | v | | v |
| §7 Aksesibilitas | | v | | | v | v | v | v | v | | v |
| §8 Responsif | | v | | | v | v | v | v | v | | v |
| §9 Tema | | v | | | v | v | v | v | v | | v |
| §10 Konten | | | v | | v | v | v | | | v | v |
| §11 Performa | | | | | | | | | | | v |
| §12 Deploy | | | | | | | | | | | v |

---

## 3. Build & Kode

Periksa di setiap milestone.

- [ ] `npm run typecheck` selesai tanpa error
- [ ] `npm run lint` selesai tanpa error
- [ ] `npm run test` semua lulus
- [ ] `npm run build` berhasil menghasilkan `dist/`
- [ ] `npm run preview` menampilkan aplikasi dengan benar
- [ ] Tidak ada `console.log` yang tertinggal di kode produksi
- [ ] Tidak ada `any` di kode TypeScript
- [ ] Tidak ada `@ts-ignore` atau `eslint-disable` tanpa komentar alasan
- [ ] Tidak ada kode mati atau komponen yang tidak dipakai
- [ ] Tidak ada nilai heksadesimal mentah di komponen (semua lewat token)
- [ ] Tidak ada emoji di kode maupun konten
- [ ] Ukuran bundle awal < 200 KB gzip
- [ ] Tidak ada dependensi yang tidak dipakai di `package.json`

**Cara memeriksa bundle:**

```bash
npm run build
# Periksa output: bagian "dist/assets/*.js" menunjukkan ukuran gzip
```

**Cara memeriksa emoji:**

```bash
grep -rP '[\x{1F300}-\x{1FAFF}]|[\x{2600}-\x{27BF}]|[\x{FE0F}]' src/ supabase/
# Harapan: tidak ada hasil
```

---

## 4. Logika Inti

Bagian paling kritis. Jika ada yang salah di sini, seluruh metode tiga tahap rusak.

### 4.1 Aturan Penguncian Tahap

- [ ] Modul baru: Tahap 1 `tersedia`, Tahap 2 `terkunci`, Tahap 3 `terkunci`
- [ ] Tahap 1 selesai: Tahap 2 `tersedia`, Tahap 3 tetap `terkunci`
- [ ] Tahap 1 selesai tapi Tahap 2 belum: Tahap 3 tetap `terkunci`
- [ ] Tahap 1 dan 2 selesai: Tahap 3 `tersedia`
- [ ] Tahap yang sudah selesai berstatus `selesai`, bukan `tersedia`
- [ ] Tahap terkunci tidak bisa dibuka lewat URL langsung

**Uji terakhir sangat penting.** Coba buka `/soal/quiz/pointer-dasar` secara langsung padahal Tahap 2 belum selesai. Harapan: diarahkan kembali atau menampilkan pesan terkunci, **bukan** membuka quiz.

### 4.2 Pelacakan Progres

- [ ] Progres modul tersimpan setelah menandai selesai
- [ ] Progres bertahan setelah browser ditutup dan dibuka kembali
- [ ] Progres bertahan setelah refresh halaman
- [ ] Progres bertahan setelah tab ditutup
- [ ] Status kartu tersimpan setelah sesi flashcard selesai
- [ ] Riwayat quiz tersimpan setelah quiz selesai
- [ ] Reset progres menghapus semua data
- [ ] Ekspor menghasilkan JSON yang valid
- [ ] Impor JSON memulihkan progres dengan benar
- [ ] Impor JSON yang rusak ditolak dengan pesan jelas

### 4.3 Ketahanan Data

- [ ] `localStorage` kosong: aplikasi berjalan normal
- [ ] `localStorage` berisi JSON tidak valid: aplikasi tidak crash
- [ ] `localStorage` berisi JSON valid tapi skema salah: aplikasi tidak crash
- [ ] `localStorage` berisi versi lama: ditangani dengan aman
- [ ] Data korup disimpan sebagai salinan untuk diagnosis
- [ ] `localStorage` penuh (kuota habis): ditangani tanpa crash

**Cara menguji data korup:**

```javascript
// Di console browser
localStorage.setItem('flashstruct:progres:v1', 'ini bukan json');
// Muat ulang halaman -> harus berjalan normal dengan progres kosong

localStorage.setItem('flashstruct:progres:v1', '{"versi":1,"modul":"bukan objek"}');
// Muat ulang halaman -> harus berjalan normal
```

### 4.4 Sesi Flashcard

- [ ] Maksimal 20 kartu per sesi
- [ ] Kartu dengan status "Lupa" diprioritaskan muncul lebih dulu
- [ ] Kartu yang belum pernah dilihat diprioritaskan di atas yang sudah dikuasai
- [ ] Tombol "Lupa" dan "Ingat" hanya muncul setelah kartu dibalik
- [ ] Kartu "Lupa" muncul kembali di putaran ulang
- [ ] Putaran ulang hanya satu kali
- [ ] Tahap 2 selesai hanya jika semua kartu minimal sekali "Ingat"
- [ ] Tinggi kartu tidak berubah saat dibalik
- [ ] Konten panjang bisa di-scroll di dalam kartu

### 4.5 Sesi Quiz

- [ ] 10 soal diambil acak dari bank soal
- [ ] Urutan soal berbeda di setiap percobaan
- [ ] Urutan opsi jawaban diacak
- [ ] Umpan balik muncul segera setelah menjawab
- [ ] Jawaban salah menampilkan jawaban benar
- [ ] Penjelasan selalu ada dan menyebut mengapa pengecoh salah
- [ ] Skor dihitung benar (`jumlah benar / 10 x 100`)
- [ ] Ambang lulus 70 diterapkan
- [ ] Tahap 3 selesai meskipun tidak lulus
- [ ] Analisis topik diurutkan dari terlemah
- [ ] Akurasi per topik dihitung benar

### 4.6 Perhitungan Statistik

- [ ] "Modul selesai" hanya menghitung modul dengan ketiga tahap tuntas
- [ ] "Kartu dikuasai" menghitung kartu dengan `jumlahIngat > 0` dan `jumlahLupa = 0`
- [ ] "Akurasi quiz" adalah rata-rata akurasi, bukan rata-rata nilai
- [ ] Streak dihitung dari hari berturut-turut ada aktivitas
- [ ] Streak dibatasi maksimal 999
- [ ] Statistik menampilkan 0 dengan benar saat belum ada data

---

## 5. Database & Keamanan

Periksa setelah migrasi dijalankan, dan sekali lagi sebelum rilis.

### 5.1 Skema

- [ ] Semua tabel dibuat tanpa error
- [ ] Semua enum dibuat
- [ ] Semua index dibuat
- [ ] Semua `check` constraint aktif
- [ ] Foreign key dengan `on delete cascade` bekerja

**Uji cascade:**

```sql
begin;
delete from modul where slug = 'array-dasar';
select count(*) from flashcard;   -- harus 0
select count(*) from soal;        -- harus 0
select count(*) from opsi_soal;   -- harus 0
rollback;
```

### 5.2 RLS — WAJIB

Ini bagian keamanan paling penting. Jangan dilewati.

- [ ] RLS aktif di **semua** tabel konten
- [ ] Grant tulis sudah dicabut dari `anon` dan `authenticated`
- [ ] Hanya grant `select` yang diberikan
- [ ] Policy SELECT ada untuk setiap tabel
- [ ] **Uji baca berhasil**
- [ ] **Uji tulis gagal**
- [ ] **Uji hapus gagal**

**Uji 1 — baca harus berhasil:**

```bash
curl "https://<PROJECT>.supabase.co/rest/v1/modul?select=*" \
  -H "apikey: <PUBLISHABLE_KEY>" \
  -H "Authorization: Bearer <PUBLISHABLE_KEY>"
```

Harapan: array JSON berisi data.

**Uji 2 — tulis harus gagal:**

```bash
curl -X POST "https://<PROJECT>.supabase.co/rest/v1/modul" \
  -H "apikey: <PUBLISHABLE_KEY>" \
  -H "Authorization: Bearer <PUBLISHABLE_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"slug":"uji","judul":"Uji","topik":"array","deskripsi":"tes"}'
```

Harapan: status 401 atau 403, pesan menyebut `row-level security` atau `permission denied`.

**Uji 3 — hapus harus gagal:**

```bash
curl -X DELETE "https://<PROJECT>.supabase.co/rest/v1/modul?slug=eq.array-dasar" \
  -H "apikey: <PUBLISHABLE_KEY>" \
  -H "Authorization: Bearer <PUBLISHABLE_KEY>"
```

Harapan: gagal, dan data modul tetap ada.

**Jika Uji 2 atau 3 berhasil, JANGAN rilis.** Periksa ulang langkah `revoke` di `05-SKEMA-DATABASE.md` §4.3.

### 5.3 Kebersihan Kredensial

- [ ] `.env.local` ada di `.gitignore`
- [ ] `.env.local` **tidak** pernah di-commit
- [ ] `.env.example` ada dan berisi placeholder, bukan nilai nyata
- [ ] Tidak ada `service_role` atau `sb_secret_` di kode frontend
- [ ] Tidak ada key yang di-hardcode di kode
- [ ] Riwayat git tidak mengandung kredensial

**Cara memeriksa riwayat git:**

```bash
git log --all -p | grep -iE "supabase.co|sb_publishable|sb_secret|service_role" | head
# Harapan: hanya nama variabel, bukan nilai sebenarnya
```

---

## 6. Halaman

Periksa setiap halaman terhadap `06-SPESIFIKASI-HALAMAN.md`.

### 6.1 Home

- [ ] Hero menampilkan premis produk dengan jelas
- [ ] Tombol "Mulai Belajar" mengarahkan ke modul pertama (pengguna baru)
- [ ] Tombol "Mulai Belajar" mengarahkan ke Dashboard (pengguna dengan progres)
- [ ] Diagram tiga tahap bisa diklik
- [ ] Angka modul dan kartu dihitung dari data nyata
- [ ] Tidak ada testimoni atau klaim palsu
- [ ] Section "Kenapa Hafalan" berisi alasan konkret, bukan slogan

### 6.2 Dashboard

- [ ] Kartu rekomendasi ada di paling atas
- [ ] Rekomendasi menyebut alasan, bukan hanya aksi
- [ ] Rekomendasi mengikuti prioritas yang benar
- [ ] Empat kartu statistik menampilkan angka yang benar
- [ ] Kartu statistik menampilkan 0 dengan ajakan bertindak saat kosong
- [ ] Progres per topik menampilkan tiga bar
- [ ] Modul yang sedang dikerjakan muncul di atas
- [ ] Filter topik berfungsi
- [ ] Pengalih tema berfungsi
- [ ] Ekspor progres menghasilkan berkas
- [ ] Reset memerlukan dua konfirmasi
- [ ] Dialog reset menawarkan ekspor lebih dulu

### 6.3 Materi

- [ ] Daftar materi terkelompok per topik
- [ ] Filter topik berfungsi
- [ ] Pencarian memfilter berdasarkan judul dan deskripsi
- [ ] Modul bisa dibaca sampai habis
- [ ] Daftar isi muncul sebagai sidebar di desktop
- [ ] Daftar isi muncul sebagai drawer di mobile
- [ ] Klik item daftar isi menggulir ke bagian tersebut
- [ ] Progres baca bertambah saat scroll
- [ ] Tombol "Tandai Selesai" terkunci sampai 80%
- [ ] Teks tombol terkunci menyebut persentase saat ini
- [ ] Setelah selesai, panel menampilkan arah ke flashcard
- [ ] Panel terkunci menampilkan alasan
- [ ] Tombol "Lanjut ke Flashcard" tetap terlihat meski terkunci

### 6.4 Video

- [ ] Video terkelompok per topik
- [ ] Thumbnail dimuat dengan dimensi eksplisit
- [ ] Klik kartu membuka modal
- [ ] Video bisa diputar di modal
- [ ] Escape menutup modal
- [ ] Klik di luar modal menutup modal
- [ ] Scroll body terkunci saat modal terbuka
- [ ] Tautan "Buka di YouTube" ada
- [ ] Halaman kosong menampilkan pesan yang mengarahkan

### 6.5 Soal

- [ ] Halaman pemilih mode menampilkan kartu Hafalkan dan Buktikan
- [ ] Kartu Hafalkan menampilkan jumlah kartu dan yang dikuasai
- [ ] Kartu Buktikan menampilkan jumlah soal dan akurasi terakhir
- [ ] Kartu Buktikan terkunci dengan alasan jika Tahap 2 belum selesai

### 6.6 Flashcard

- [ ] Kartu bisa dibalik dengan klik
- [ ] Kartu bisa dibalik dengan Space dan Enter
- [ ] Tombol penilaian muncul hanya setelah dibalik
- [ ] Keyboard: `1` untuk lupa, `2` untuk ingat
- [ ] Indikator posisi (`3 / 20`) terlihat
- [ ] Progres bar bertambah
- [ ] Putaran ulang muncul jika ada kartu lupa
- [ ] Ringkasan menampilkan jumlah benar dan salah
- [ ] Dialog konfirmasi muncul saat keluar di tengah sesi
- [ ] Tahap 3 terbuka setelah Tahap 2 selesai

### 6.7 Quiz

- [ ] Soal menampilkan label tipe (PG / TRACE / ANALISIS)
- [ ] Soal TRACE menampilkan blok kode dengan nomor baris
- [ ] Umpan balik muncul segera setelah menjawab
- [ ] Warna benar/salah disertai ikon dan teks
- [ ] Jawaban salah menampilkan jawaban benar
- [ ] Penjelasan menjelaskan mengapa pengecoh salah
- [ ] Halaman hasil menampilkan skor besar
- [ ] Analisis topik menampilkan bar per tipe kartu
- [ ] Topik terlemah di atas
- [ ] Rincian jawaban menampilkan semua soal
- [ ] Pesan saat gagal tidak menghakimi
- [ ] Dialog konfirmasi muncul saat keluar di tengah quiz

---

## 7. Aksesibilitas

Target: Lighthouse Accessibility ≥ 95, dan semua item berikut tercentang.

### 7.1 Kontras

- [ ] Semua teks ≥ 4.5:1 (sudah dijamin oleh token)
- [ ] Teks besar ≥ 3:1
- [ ] Batas kontrol input terlihat jelas
- [ ] Cincin fokus ≥ 3:1
- [ ] Warna bukan satu-satunya penanda (benar/salah pakai ikon + teks)
- [ ] Teks di kedua tema terverifikasi

### 7.2 Keyboard

- [ ] Semua elemen interaktif dapat dijangkau dengan Tab
- [ ] Urutan Tab masuk akal (kiri ke kanan, atas ke bawah)
- [ ] Cincin fokus terlihat di semua elemen
- [ ] `Enter` dan `Space` mengaktifkan tombol
- [ ] `Escape` menutup modal dan dialog
- [ ] Fokus terkunci di dalam modal
- [ ] Fokus kembali ke pemicu setelah modal tutup
- [ ] Skip link berfungsi dan terlihat saat difokus
- [ ] Flashcard dapat diselesaikan tanpa mouse
- [ ] Quiz dapat diselesaikan tanpa mouse
- [ ] Tidak ada jebakan fokus (fokus yang tidak bisa keluar)

### 7.3 Pembaca Layar

- [ ] Setiap halaman punya tepat satu `<h1>`
- [ ] Heading berurutan tanpa melompat
- [ ] Semua gambar punya `alt` deskriptif
- [ ] Ikon dekoratif punya `aria-hidden="true"`
- [ ] Tombol ikon punya `aria-label`
- [ ] Progress bar punya `aria-valuenow`, `aria-valuemin`, `aria-valuemax`
- [ ] Hasil quiz diumumkan lewat `aria-live`
- [ ] Blok kode punya label yang bisa dibaca
- [ ] Formulir punya `<label>` yang terhubung
- [ ] Error dikaitkan dengan field lewat `aria-describedby`
- [ ] Landmark (`header`, `nav`, `main`, `footer`) ada
- [ ] Flashcard punya `aria-label` yang menjelaskan posisi dan aksi

### 7.4 Gerak

- [ ] `prefers-reduced-motion` dihormati
- [ ] Animasi flip diganti pergantian langsung
- [ ] Stagger daftar dinonaktifkan
- [ ] Tidak ada animasi yang berjalan terus-menerus
- [ ] Tidak ada animasi otomatis yang tidak bisa dihentikan

**Cara menguji:** aktifkan "Reduce motion" di pengaturan OS, lalu muat ulang aplikasi.

### 7.5 Uji dengan Alat

- [ ] Lighthouse Accessibility ≥ 95
- [ ] axe DevTools: 0 pelanggaran serius
- [ ] Tidak ada error di console saat navigasi keyboard

---

## 8. Responsif

Uji di empat lebar. Gunakan DevTools dengan mode perangkat.

### 8.1 375px (Mobile Kecil)

- [ ] Tidak ada scroll horizontal
- [ ] Semua teks terbaca tanpa perlu zoom
- [ ] Tombol ≥ 44x44px
- [ ] Navigasi berfungsi (bottom nav atau menu)
- [ ] Flashcard muat penuh tanpa terpotong
- [ ] Blok kode bisa di-scroll horizontal
- [ ] Modal video muat penuh
- [ ] Tabel bisa di-scroll horizontal
- [ ] Daftar isi muncul sebagai drawer

### 8.2 768px (Tablet)

- [ ] Grid menyesuaikan (2-3 kolom)
- [ ] Tidak ada elemen yang terlalu melebar
- [ ] Navigasi horizontal berfungsi
- [ ] Tidak ada scroll horizontal

### 8.3 1024px (Laptop Kecil)

- [ ] Sidebar daftar isi muncul di halaman modul
- [ ] Grid 3 kolom
- [ ] Tidak ada scroll horizontal

### 8.4 1440px (Desktop)

- [ ] Konten tidak terlalu melebar (maks lebar kontainer dipatuhi)
- [ ] Teks tidak terlalu panjang (maks 72 karakter per baris)
- [ ] Grid 4 kolom untuk kartu
- [ ] Tidak ada ruang kosong berlebihan

### 8.5 Uji Tambahan

- [ ] Zoom 200% tidak merusak layout
- [ ] Rotasi layar (portrait ke landscape) tidak merusak
- [ ] Keyboard virtual tidak menutupi input

---

## 9. Tema

- [ ] Tema terang berfungsi di semua halaman
- [ ] Tema gelap berfungsi di semua halaman
- [ ] "Ikuti Sistem" mengikuti preferensi OS
- [ ] Perubahan tema OS langsung diterapkan (jika mode "Ikuti Sistem")
- [ ] Pilihan tema tersimpan setelah refresh
- [ ] Tidak ada kedipan tema saat halaman dimuat
- [ ] Blok kode berwarna benar di kedua tema
- [ ] Kontras terverifikasi di kedua tema
- [ ] Gambar dan ilustrasi terlihat di kedua tema
- [ ] Tidak ada elemen yang "hilang" di salah satu tema

**Cara menguji kedipan tema:** set mode gelap, muat ulang halaman dengan throttle jaringan lambat. Tema gelap harus langsung terlihat, bukan berkedip putih dulu.

---

## 10. Konten

### 10.1 Struktur Konten

- [ ] Semua 10 modul ada
- [ ] Setiap modul punya minimal 4 bagian
- [ ] Setiap modul punya minimal 15 kartu
- [ ] Setiap modul punya minimal 15 soal
- [ ] Setiap modul punya minimal 4 tipe kartu berbeda
- [ ] Tidak ada placeholder ("TODO", "lorem ipsum", "...")

### 10.2 Kualitas Kartu

- [ ] Setiap kartu menguji satu fakta
- [ ] Sisi belakang maksimal 2 kalimat (kecuali BANDING dan JEBAKAN)
- [ ] Kode maksimal 8 baris
- [ ] Tidak ada "dan" di sisi depan
- [ ] Selalu ada konteks bahasa
- [ ] Tidak ada kartu yang menyalin kalimat modul persis
- [ ] Sisi depan selalu bisa dijawab

### 10.3 Kualitas Soal

- [ ] Setiap soal punya tepat 4 opsi
- [ ] Setiap soal punya tepat 1 jawaban benar
- [ ] Setiap soal punya penjelasan
- [ ] Penjelasan menyebut mengapa pengecoh salah
- [ ] Pengecoh masuk akal (dari kesalahan umum)
- [ ] Tidak ada opsi "semua benar" atau "semua salah"
- [ ] Tidak ada kata "selalu" atau "tidak pernah" tanpa alasan
- [ ] Panjang opsi seimbang
- [ ] Kode maksimal 10 baris

### 10.4 Akurasi Teknis

- [ ] **Semua contoh kode C++ sudah dikompilasi dan dijalankan**
- [ ] **Semua contoh kode Python sudah dijalankan**
- [ ] Output di soal tracing sudah diverifikasi
- [ ] Klaim bergantung platform ditandai jelas
- [ ] Tidak ada klaim yang salah

**Cara memverifikasi contoh kode:**

```bash
# C++
g++ -std=c++17 -Wall -o /tmp/test contoh.cpp && /tmp/test

# Python
python3 contoh.py
```

**Ini item paling penting di seluruh checklist.** Satu contoh kode yang salah output akan mengajarkan konsep yang salah kepada ratusan mahasiswa.

### 10.5 Pemeriksa Konten

Jalankan semua query dari `05-SKEMA-DATABASE.md` §7. Semua harus mengembalikan **0 baris**.

- [ ] Soal tanpa jawaban benar: 0
- [ ] Soal dengan jumlah opsi bukan 4: 0
- [ ] Modul tanpa kartu: 0
- [ ] Modul dengan kartu < 15: 0
- [ ] Modul dengan soal < 15: 0
- [ ] Modul tanpa bagian: 0
- [ ] Modul dengan < 4 tipe kartu: 0
- [ ] Penjelasan terlalu pendek: 0
- [ ] Sisi depan kartu terlalu panjang: 0

### 10.6 Video

- [ ] Semua ID video valid dan bisa diputar
- [ ] Video bisa diputar tersemat (tidak dibatasi pemiliknya)
- [ ] Durasi video akurat
- [ ] Thumbnail memuat dengan benar
- [ ] Minimal 3 video ada (satu per topik) untuk rilis v1

---

## 11. Performa

### 11.1 Lighthouse

Uji di mode Incognito, dengan throttling 4G.

| Metrik | Target | Hasil |
|--------|--------|-------|
| Performance | ≥ 90 | ___ |
| Accessibility | ≥ 95 | ___ |
| Best Practices | ≥ 90 | ___ |
| SEO | ≥ 90 | ___ |

- [ ] First Contentful Paint < 1.8s
- [ ] Largest Contentful Paint < 2.5s
- [ ] Cumulative Layout Shift < 0.1
- [ ] Total Blocking Time < 200ms

### 11.2 Bundle

- [ ] Bundle awal < 200 KB gzip
- [ ] Shiki dimuat lazy (tidak di bundle awal)
- [ ] `react-markdown` dimuat lazy
- [ ] Semua halaman dimuat lazy
- [ ] Tidak ada dependensi besar yang tidak sengaja masuk bundle awal

### 11.3 Animasi

- [ ] Animasi flip kartu 60 FPS
- [ ] Tidak ada jank saat scroll
- [ ] Animasi hanya memakai `transform` dan `opacity`
- [ ] Tidak ada animasi `width`, `height`, `top`, `left`

**Cara menguji FPS:** buka Chrome DevTools > Performance, rekam saat membalik kartu. Cari frame di bawah 60 FPS.

### 11.4 Layout Shift

- [ ] Skeleton punya tinggi yang sama dengan konten akhir
- [ ] Thumbnail video punya dimensi eksplisit
- [ ] Font dimuat dengan `display=swap`
- [ ] Tidak ada konten yang bergeser setelah dimuat
- [ ] Tidak ada iklan atau elemen dinamis yang menggeser konten

### 11.5 Jaringan

- [ ] Aplikasi berfungsi di koneksi 3G lambat
- [ ] Loading state terlihat saat data lambat
- [ ] Error state muncul saat koneksi gagal
- [ ] Konten yang sudah dimuat tetap terbaca saat offline
- [ ] Sesi flashcard/quiz berjalan offline setelah dimuat

---

## 12. Deploy

### 12.1 Sebelum Deploy

- [ ] Semua checklist di atas tercentang
- [ ] Halaman `/demo` sudah dihapus atau dilindungi
- [ ] `console.log` sudah dihapus
- [ ] Environment variable sudah disiapkan di platform
- [ ] Build produksi berhasil di lokal

### 12.2 Konfigurasi Platform

- [ ] Build command: `npm run build`
- [ ] Output directory: `dist`
- [ ] `VITE_SUPABASE_URL` diatur
- [ ] `VITE_SUPABASE_PUBLISHABLE_KEY` diatur
- [ ] SPA rewrite dikonfigurasi

**SPA rewrite — Vercel (`vercel.json`):**

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

**SPA rewrite — Netlify (`public/_redirects`):**

```text
/*  /index.html  200
```

### 12.3 Setelah Deploy

- [ ] Situs bisa dibuka lewat URL publik
- [ ] **Refresh di rute dalam tidak 404** (uji `/materi/array-dasar`)
- [ ] **Buka rute dalam langsung dari URL baru tidak 404**
- [ ] Konten dari Supabase termuat
- [ ] Tidak ada error CORS di console
- [ ] Tidak ada error lain di console
- [ ] HTTPS aktif
- [ ] Favicon muncul
- [ ] Meta tag dan Open Graph benar

### 12.4 Uji Alur Lengkap di Production

Lakukan dari nol, di browser yang belum pernah membuka situs:

- [ ] Buka Home, paham apa produknya
- [ ] Klik "Mulai Belajar", masuk ke modul pertama
- [ ] Baca modul sampai 80%
- [ ] Tandai modul selesai
- [ ] Lanjut ke flashcard
- [ ] Selesaikan sesi flashcard
- [ ] Tahap 3 terbuka
- [ ] Kerjakan quiz
- [ ] Lihat hasil dan analisis topik
- [ ] Buka Dashboard, lihat progres tercatat
- [ ] Refresh halaman, progres masih ada
- [ ] Tutup browser, buka lagi, progres masih ada

**Jika salah satu langkah gagal, jangan rilis.**

### 12.5 Setelah Rilis

- [ ] Uji di Chrome, Firefox, Safari, Edge
- [ ] Uji di Android dan iOS
- [ ] Pantau error selama 24 jam pertama
- [ ] Siapkan rencana rollback

---

## 13. Uji Lintas Browser

| Browser | Versi | Status |
|---------|-------|--------|
| Chrome | 2 tahun terakhir | ___ |
| Firefox | 2 tahun terakhir | ___ |
| Safari | 2 tahun terakhir | ___ |
| Edge | 2 tahun terakhir | ___ |
| Chrome Android | Terbaru | ___ |
| Safari iOS | Terbaru | ___ |

**Yang perlu diperiksa khusus:**

- [ ] `backdrop-filter` (jika dipakai) didukung
- [ ] `dvh` didukung (Safari 15.4+)
- [ ] `IntersectionObserver` didukung
- [ ] `:has()` didukung (jika dipakai)
- [ ] Ligatur font kode tampil
- [ ] Animasi 3D flip berfungsi di Safari
- [ ] `localStorage` berfungsi di mode privat Safari

**Catatan Safari mode privat:** `localStorage` bisa gagal di mode privat. Pastikan aplikasi tidak crash dan memberi tahu pengguna bahwa progres tidak akan tersimpan.

---

## 14. Definition of Done

Proyek dinyatakan **selesai** jika semua ini benar:

### Fungsi

- [ ] Kelima halaman berfungsi penuh
- [ ] Tiga tahap terkunci dengan benar dan tidak bisa dilewati
- [ ] Progres tersimpan dan bertahan
- [ ] Semua 10 modul terisi konten lengkap
- [ ] Semua contoh kode terverifikasi berjalan
- [ ] Pemeriksa konten mengembalikan 0 baris

### Kualitas

- [ ] Lulus seluruh checklist di dokumen ini
- [ ] Lighthouse Performance ≥ 90, Accessibility ≥ 95
- [ ] Tidak ada error di console
- [ ] Tidak ada scroll horizontal di lebar mana pun
- [ ] Berfungsi di kedua tema
- [ ] Dapat dioperasikan keyboard penuh
- [ ] `prefers-reduced-motion` dihormati

### Keamanan

- [ ] RLS aktif dan terverifikasi (uji tulis dan hapus gagal)
- [ ] Tidak ada kredensial di repository
- [ ] Tidak ada `service_role` key di frontend

### Rilis

- [ ] Dapat diakses lewat URL publik
- [ ] Refresh di rute dalam tidak 404
- [ ] Alur lengkap berfungsi di production
- [ ] Diuji di minimal 3 browser

---

## 15. Yang TIDAK Perlu Diperiksa (v1)

Agar checklist ini tidak membengkak tanpa manfaat, hal-hal berikut **tidak** perlu diperiksa karena tidak ada di v1:

| Tidak perlu | Alasan |
|-------------|--------|
| Alur login/registrasi | Tidak ada autentikasi |
| Sinkronisasi lintas perangkat | Progres hanya lokal |
| Panel admin | Konten diisi lewat database |
| Notifikasi push | Tidak ada |
| Berbagi sosial | Tidak ada |
| Pembayaran | Gratis |
| Analitik pengguna | Tidak ada pelacakan (N-09) |
| Dukungan multi-bahasa | Satu bahasa |
| Mode offline penuh (PWA installable) | Hanya cache dasar |
| Aksesibilitas untuk buta total | Di luar cakupan v1, meski struktur dasar sudah mendukung |

**Catatan jujur:** baris terakhir penting. Aplikasi ini mengajarkan kode dan pointer — konsep yang secara inheren visual. Membuat pengalaman yang sepenuhnya setara untuk pengguna tunanetra membutuhkan deskripsi audio untuk setiap diagram dan blok kode, yang merupakan pekerjaan besar tersendiri. Struktur dasar (heading, label, `aria`) sudah benar, tetapi pengalaman penuhnya belum setara. Ini dicatat sebagai keterbatasan yang disadari, bukan diabaikan.

---

## 16. Referensi Silang

| Topik | Dokumen |
|-------|---------|
| Kriteria rilis produk | `01-PRD.md` §6 |
| Aturan konten | `02-KURIKULUM.md` §4–5, §7 |
| Checklist komponen UI | `03-DESIGN-SYSTEM.md` §9 |
| Alur data dan logika | `04-ARSITEKTUR-TEKNIS.md` §3 |
| Uji RLS | `05-SKEMA-DATABASE.md` §4.4 |
| Spesifikasi halaman | `06-SPESIFIKASI-HALAMAN.md` |
| Urutan milestone | `07-ROADMAP.md` |
| Cara setup dan deploy | `09-PANDUAN-SETUP.md` |
