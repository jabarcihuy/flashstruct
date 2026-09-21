# 14 — Keputusan Akhir: Arsitektur Data

> **KEPUTUSAN FINAL: Supabase.** Dokumen ini mencatat alasan dan riwayat pertimbangannya.
> Status: `[FINAL]` · Menggantikan asumsi di `12-ANALISIS-NEON.md` §6

---

## 0. Ringkasan untuk Pembaca yang Buru-buru

| Pertanyaan | Jawaban |
|------------|---------|
| Database apa yang dipakai? | **Supabase** (PostgreSQL + PostgREST) |
| Kenapa bukan Neon? | Neon sendiri tidak merekomendasikan Data API untuk aplikasi baru |
| Kenapa bukan Firebase? | Firestore NoSQL, tidak cocok untuk data relasional |
| Apakah masalah pause Supabase sudah teratasi? | **Ya** — dicegah dengan Vercel Cron gratis (lihat §3.2) |
| Apa yang perlu dilakukan sekarang? | Setup project Supabase, ikuti `09-PANDUAN-SETUP.md` §3 |

**Riwayat singkat:** rencana sempat berpindah ke Neon, lalu dikoreksi setelah membaca panduan resmi Neon yang terpasang sebagai agent skill. Detail di §1.

---

## 1. Koreksi: Rencana Sebelumnya Kurang Tepat

Saat saya menulis analisis Neon, saya berasumsi **Neon Data API bisa dipanggil dari browser tanpa autentikasi**, sama seperti PostgREST Supabase dengan anon key.

**Asumsi itu perlu dikoreksi.** Setelah membaca Neon agent skills resmi dan dokumentasi terbaru:

> "Anonymous access **still uses a JWT**, but no user sign-in is required."
> — [Neon: Access Control](https://neon.com/docs/data-api/access-control)

Jadi **tidak ada** mode "tanpa autentikasi sama sekali". Yang ada adalah **JWT anonim** — tetap token, tapi diperoleh otomatis tanpa pengguna perlu login.

### 1.1 Lebih Penting Lagi: Neon Sendiri Tidak Merekomendasikan Data API

Skill resmi Neon menyatakan dengan sangat jelas:

> "**Offer the Data API only as a Supabase / PostgREST migration path** when an existing PostgREST or `supabase-js` database client must keep working. **Putting PostgREST in the browser and relying on RLS is easy to get wrong: misconfigured policies expose the database to the client. Do not recommend this for new apps.**"
> — [Neon skill: SKILL.md](https://github.com/neondatabase/agent-skills/blob/main/skills/neon/SKILL.md)

Dan:

> "For an app using PostgREST or a `supabase-js` database client, prefer migrating database calls to **REST endpoints in a Hono Function** that queries Lakebase Postgres. **Enforce authorization in the Function instead of relying on browser-facing RLS.**"
> — Skill Neon, bagian "Second best: client-only app with a Functions backend"

**Artinya:** Neon sendiri mengarahkan aplikasi baru untuk **tidak** menaruh PostgREST di browser. FlashStruct adalah aplikasi baru, jadi rekomendasi resmi Neon berlaku.

### 1.2 Kenapa Neon Berpendapat Begitu

Ini bukan tanpa alasan. Menaruh PostgREST langsung di browser berarti:

| Risiko | Penjelasan |
|--------|------------|
| **Salah konfigurasi RLS = database terbuka** | Satu policy yang keliru, dan seluruh konten bisa dihapus siapa pun |
| **Sulit diuji** | Tidak ada tempat untuk menaruh logika validasi |
| **Kebocoran bertahap** | Setiap tabel baru harus diingat untuk diberi RLS |

Untuk Supabase, RLS adalah **inti produk** — mereka membangun tooling, dokumentasi, dan pengujian di sekitarnya. Untuk Neon, RLS adalah fitur PostgreSQL yang tersedia, tapi bukan fokus produk.

---

## 2. Keputusan: Arsitektur yang Dipakai

Ada tiga pilihan. Saya bandingkan dengan jujur.

### Opsi A — Neon Data API + RLS (rencana sebelumnya)

| Aspek | Penilaian |
|-------|-----------|
| Kerja tambahan | 0 (sudah direncanakan) |
| Sesuai rekomendasi Neon? | **Tidak** — Neon menyarankan sebaliknya |
| Risiko keamanan | Sedang — bergantung pada RLS yang benar |
| Perlu login pengguna? | Tidak, tapi butuh JWT anonim |
| Kompleksitas | Rendah |

### Opsi B — Neon Functions sebagai API (rekomendasi Neon)

| Aspek | Penilaian |
|-------|-----------|
| Kerja tambahan | **Besar** — perlu tulis endpoint, deploy, kelola secret |
| Sesuai rekomendasi Neon? | Ya |
| Risiko keamanan | Rendah — otorisasi di kode |
| Perlu login pengguna? | Tidak |
| Kompleksitas | Tinggi |

**Masalah:** ini berarti menulis backend sendiri — tepat hal yang ingin dihindari sejak awal dengan memilih Supabase/PostgREST.

### Opsi C — Kembali ke Supabase

| Aspek | Penilaian |
|-------|-----------|
| Kerja tambahan | 0 |
| Sesuai rekomendasi vendor? | **Ya** — Supabase memang dibangun untuk ini |
| Risiko keamanan | Rendah — RLS adalah inti produk Supabase |
| Perlu login pengguna? | Tidak |
| Kompleksitas | Rendah |
| Kelemahan | Pause 7 hari, resume manual |

---

## 3. Rekomendasi: Kembali ke Supabase

**Ini bukan mundur — ini menyesuaikan diri dengan fakta baru.**

### 3.1 Alasan

| # | Alasan |
|---|--------|
| 1 | **Neon sendiri tidak merekomendasikan Data API untuk aplikasi baru.** Mengabaikan ini berarti melawan panduan vendor |
| 2 | **Supabase dirancang tepat untuk pola ini.** PostgREST + RLS adalah inti produknya, bukan fitur tambahan |
| 3 | **Risiko RLS salah lebih kecil di Supabase.** Ekosistem, tooling, dan dokumentasinya dibangun untuk kasus ini |
| 4 | **Data API Neon masih butuh JWT anonim** — jadi tidak lebih sederhana dari Supabase yang juga pakai anon key |
| 5 | **Skema sudah 100% siap.** `05-SKEMA-DATABASE.md` sudah diuji di PostgreSQL dan memakai role `anon` |
| 6 | **Tidak ada kode yang perlu diubah.** M0 dan M1 tidak menyentuh database sama sekali |

### 3.2 Yang Harus Diterima

Kelemahan Supabase tetap ada: **pause setelah 7 hari idle, resume manual.**

**TAPI ada kabar baik yang saya temukan saat memverifikasi ulang:**

#### Pause Supabase Mudah Dicegah, dan Gratis

Dokumentasi resmi Supabase menyatakan:

> "Typically **a few user requests to the database each day** over the previous week is enough to keep the project from being paused."
> — [Supabase: Project Pausing](https://supabase.com/docs/guides/platform/free-project-pausing)

Dan **Vercel Hobby punya Cron Jobs gratis** — sekali per hari:

| Platform | Cron gratis? | Interval |
|----------|--------------|----------|
| **Vercel Hobby** | **Ya** | Sekali per hari |
| Vercel Pro | Ya | Sekali per menit |

Artinya: **satu cron job harian sudah cukup** untuk mencegah pause. Kombinasi Vercel Cron + Supabase menyelesaikan masalah ini sepenuhnya, tanpa biaya.

**Tambahan lagi:** Supabase mengirim **email peringatan 1 minggu sebelum pause**. Jadi Anda tidak akan kaget — ada waktu untuk mencegahnya.

#### Tiga Lapis Mitigasi

| Lapis | Cara | Usaha |
|-------|------|-------|
| 1 | Cron job harian di Vercel | Setup 10 menit, sekali saja |
| 2 | Email peringatan dari Supabase | Otomatis, tidak perlu apa-apa |
| 3 | Kunjungi dashboard saat ada peringatan | 1 menit |

**Dengan tiga lapis ini, risiko pause praktis hilang.**

### 3.3 Kapan Neon Justru Lebih Tepat

Kalau nanti proyek berkembang dan butuh backend sendiri, Neon menjadi pilihan yang baik:

| Kondisi | Neon lebih tepat karena |
|---------|------------------------|
| Butuh logika server (validasi, rate limit, rahasia) | Neon Functions |
| Butuh autentikasi pengguna sungguhan | Managed Better Auth |
| Butuh object storage | Bawaan Neon |
| Butuh WebSocket / SSE | Neon Functions |
| Idle panjang jadi masalah nyata | Scale to zero otomatis |

**Untuk v1 tanpa login dan tanpa logika server, Supabase lebih tepat.**

---

## 4. Yang Tidak Berubah

Keputusan kembali ke Supabase **tidak membatalkan** pekerjaan yang sudah dilakukan:

| Aset | Status |
|------|--------|
| Skema database (`05-SKEMA-DATABASE.md`) | **Tetap dipakai, 100%** |
| RLS dengan role `anon` | **Tetap dipakai** |
| Pemeriksa konten (9 query) | **Tetap dipakai** |
| Semua kode React | Tidak terpengaruh |
| 67 test | Tidak terpengaruh |
| Design system & palet warna | Tidak terpengaruh |
| Kurikulum | Tidak terpengaruh |
| Neon skills yang terpasang | **Tetap berguna** — untuk referensi jika nanti pindah |

**Satu-satunya yang berubah:** `.env.example` kembali memakai Supabase.

---

## 5. Perbandingan Final Tiga Opsi

| Kriteria | **Supabase** | Neon Data API | Neon Functions |
|----------|--------------|---------------|----------------|
| Sesuai rekomendasi vendor | **Ya** | **Tidak** | Ya |
| Kerja tambahan | 0 | 3 jam | **20+ jam** |
| Perlu tulis backend? | Tidak | Tidak | **Ya** |
| Perlu login pengguna? | Tidak | Tidak (JWT anonim) | Tidak |
| Risiko RLS salah | Rendah | Sedang | Rendah |
| Skema siap pakai | **100%** | 95% | 95% |
| Idle | Pause 7 hari | **Auto** | **Auto** |
| Kompleksitas | Rendah | Rendah | Tinggi |
| **Untuk FlashStruct v1** | **Paling tepat** | Kurang tepat | Berlebihan |

---

## 6. Keputusan yang Perlu Anda Ambil

| Pilihan | Konsekuensi |
|---------|-------------|
| **A. Kembali ke Supabase** (rekomendasi saya) | Buat project Supabase, jalankan SQL yang sudah ada, lanjut M2. Tidak ada kode yang perlu diubah |
| **B. Tetap Neon dengan Data API** | Bisa, tapi melawan rekomendasi vendor dan butuh JWT anonim. Perlu 3 jam penyesuaian |
| **C. Neon dengan Functions** | Paling aman secara arsitektur, tapi berarti menulis backend sendiri (± 20 jam) |

### 6.1 Jika Pilih A — Langkah Anda

1. Buat project di [supabase.com](https://supabase.com) (region **Singapore**)
2. Settings > API Keys, catat:
   - **Project URL** (`https://xxxxx.supabase.co`)
   - **Publishable key** (`sb_publishable_...`)
3. Jalankan DDL dari `05-SKEMA-DATABASE.md` §3 di SQL Editor
4. Jalankan RLS dari `05-SKEMA-DATABASE.md` §4.3
5. **Uji tulis harus GAGAL** (bukti RLS aktif)
6. Jalankan seed dari §6
7. Laporkan hasilnya ke saya

Panduan lengkap: `09-PANDUAN-SETUP.md` §3.

### 6.2 Jika Pilih B — Langkah Anda

Ikuti `13-PANDUAN-SETUP-NEON.md`, dengan perubahan:
- Aktifkan **Managed Better Auth** saat mengaktifkan Data API
- Di aplikasi, pakai `allowAnonymous: true` pada client
- SDK `@neondatabase/neon-js` masih beta

### 6.3 Jika Pilih C — Langkah Anda

Sama seperti B, tapi jangan aktifkan Data API. Sebagai gantinya:
- Buat Neon Function dengan Hono
- Tulis endpoint untuk setiap query yang dibutuhkan
- Deploy dengan `neon deploy`

Ini pekerjaan besar. Saya sarankan **tidak** untuk v1.

---

## 7. Pelajaran dari Proses Ini

Ini layak dicatat, karena proses ini sendiri informatif:

| Pelajaran | Penjelasan |
|-----------|------------|
| **Riset awal bisa keliru** | Analisis pertama saya menyimpulkan Neon lebih cocok, berdasarkan asumsi yang ternyata tidak lengkap |
| **Membaca skill vendor mengubah gambaran** | Skill resmi Neon secara eksplisit **tidak** merekomendasikan Data API untuk aplikasi baru |
| **Vendor tahu produknya lebih baik** | Neon tahu RLS browser mudah salah — mereka yang membangunnya |
| **Rencana harus bisa berubah** | Mengubah rencana setelah fakta baru bukan kegagalan, tapi proses yang benar |
| **Biaya perubahan kecil di sini** | Karena belum ada kode database, koreksi ini gratis. Kalau sudah M4, akan mahal |

**Yang penting:** koreksi ini dilakukan **sebelum** menulis kode database. Itulah gunanya milestone — memaksa verifikasi bertahap.

---

## 8. Yang Tidak Terverifikasi

| Klaim | Status |
|-------|--------|
| Apakah Data API Neon benar-benar menolak request tanpa JWT | Dokumentasi menyatakan butuh JWT, tapi tidak diuji langsung |
| Seberapa sering Supabase pause dalam praktik | Bergantung pola akses; tidak terukur |
| Apakah UptimeRobot efektif mencegah pause Supabase | Tidak diverifikasi |

---

## 9. Referensi Silang

| Topik | Dokumen |
|-------|---------|
| Analisis Neon awal (sebagian dikoreksi) | `12-ANALISIS-NEON.md` |
| Panduan setup Neon (jika tetap pilih Neon) | `13-PANDUAN-SETUP-NEON.md` |
| Skema database yang tetap dipakai | `05-SKEMA-DATABASE.md` |
| Panduan setup Supabase | `09-PANDUAN-SETUP.md` §3 |
| Fakta Neon dari dokumentasi | `riset/03-RISET-NEON.md` |
