# 13 — Panduan Setup Neon (Langkah demi Langkah)

> Panduan untuk Anda — dari nol sampai database siap dipakai FlashStruct.
> Status: `[PANDUAN]` · Fakta teknis di `riset/03-RISET-NEON.md`

---

## Ringkasan Alur

```
1. Buat akun Neon              (5 menit)
2. Buat project                (3 menit)
3. Catat connection string     (2 menit)
4. Jalankan skema database     (10 menit)
5. Jalankan RLS                (5 menit)
6. Aktifkan Data API           (5 menit)
7. UJI KRUSIAL                 (5 menit)  <- paling penting
8. Uji keamanan                (5 menit)
9. Isi data contoh             (5 menit)
10. Laporkan ke saya           (2 menit)
```

**Total: ± 45 menit.**

Anda hanya perlu melakukan langkah 1–10. Setelah itu saya lanjutkan M2.

---

## Sebelum Mulai

Siapkan:

| Kebutuhan | Keterangan |
|-----------|------------|
| Browser | Chrome/Firefox/Edge |
| Akun GitHub | Untuk daftar Neon (lebih cepat dari email) |
| Terminal | Untuk menjalankan `curl` dan `psql` |
| Password manager | Untuk menyimpan connection string |

**Cek apakah `psql` tersedia di komputer Anda:**

```bash
psql --version
```

Jika belum ada, tidak masalah — ada alternatif memakai Neon SQL Editor (langkah 4B).

---

## Langkah 1 — Buat Akun Neon

1. Buka **https://neon.tech**
2. Klik **Sign Up** (kanan atas)
3. Pilih **Continue with GitHub** — lebih cepat, tidak perlu verifikasi email

   Kalau tidak mau pakai GitHub, bisa pakai email + password.

4. Setelah masuk, Anda akan langsung diarahkan untuk membuat project pertama.

**Tidak perlu kartu kredit.** Neon Free benar-benar gratis tanpa kartu.

---

## Langkah 2 — Buat Project

Anda akan melihat form **Create your first project**. Isi seperti ini:

| Field | Nilai | Alasan |
|-------|-------|--------|
| **Project name** | `flashstruct` | Nama bebas, tidak memengaruhi apa pun |
| **Postgres version** | Biarkan default (versi terbaru) | Versi baru punya semua fitur yang dibutuhkan |
| **Region** | **Asia Pacific (Singapore)** | Terdekat dari Indonesia, latensi paling rendah |
| **Database name** | `neondb` | Biarkan default |

**Region itu penting.** Kalau memilih US atau Europe, setiap request akan menempuh perjalanan jauh dan terasa lambat. Singapore adalah pilihan terdekat.

Klik **Create Project**. Tunggu ± 10 detik.

---

## Langkah 3 — Catat Connection String

Setelah project dibuat, Neon menampilkan **Connection string**. Bentuknya seperti ini:

```
postgresql://neondb_owner:npg_AbCdEf123456@ep-cool-name-123456.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
```

### PENTING: Ada DUA jenis connection string

Neon punya dua mode koneksi. Pilih yang benar:

| Jenis | Bentuk host | Dipakai untuk |
|-------|-------------|---------------|
| **Pooled** | `ep-xxx-pooler.ap-southeast-1...` | Aplikasi serverless |
| **Direct** | `ep-xxx.ap-southeast-1...` (tanpa `-pooler`) | **Migrasi skema** |

**Untuk menjalankan skema, pakai yang DIRECT** (tanpa `-pooler`).

Alasannya: pooled connection memakai PgBouncer yang tidak mendukung semua perintah DDL. Kalau Anda pakai pooled untuk `create table`, bisa gagal dengan error aneh.

**Cara memastikan Anda dapat yang direct:**
- Di halaman Connection Details, ada dropdown **Connection pooling**
- Matikan toggle-nya untuk mendapatkan direct connection

### Simpan dengan aman

Salin connection string dan simpan di password manager. **Ini rahasia** — siapa pun yang memilikinya bisa mengubah seluruh database Anda.

**JANGAN simpan di:**
- File di dalam folder proyek yang dibaca Vite
- Chat, screenshot, atau catatan publik
- Git

**Simpan sementara** di catatan lokal yang aman, karena Anda akan memakainya di langkah 4.

---

## Langkah 4 — Jalankan Skema Database

Ada dua cara. Pilih salah satu.

### Cara A — Lewat Terminal (lebih cepat)

```bash
# Masuk ke folder proyek
cd "/home/ael/DATA/project on linux/webapp/webhanipakim"

# Buat folder migrasi jika belum ada
mkdir -p supabase/migrations

# Simpan connection string ke variabel (ganti dengan milik Anda)
export NEON_URL="postgresql://neondb_owner:npg_XXXX@ep-xxx.ap-southeast-1.aws.neon.tech/neondb?sslmode=require"

# Uji koneksi dulu
psql "$NEON_URL" -c "select version();"
```

Kalau berhasil, Anda akan melihat versi PostgreSQL. Kalau gagal, periksa connection string.

Sekarang jalankan skema. **Tapi jangan langsung — baca dulu catatan di bawah.**

### Cara B — Lewat Neon SQL Editor (lebih mudah)

1. Di Neon Console, pilih project Anda
2. Klik **SQL Editor** di sidebar kiri
3. Anda akan melihat kotak kosong untuk menulis SQL

Cara ini lebih mudah karena tidak perlu install apa pun.

---

### 4.1 Salin DDL dari Dokumen

Buka file `docs/05-SKEMA-DATABASE.md`, cari bagian **§3. DDL Lengkap**.

Salin **seluruh blok SQL** di dalamnya (mulai dari `create extension` sampai `create unique index opsi_soal_satu_benar_idx`).

Tempel ke SQL Editor (atau simpan sebagai file lalu jalankan lewat `psql`), lalu **Run**.

**Harapan:** semua perintah sukses, membuat 6 tabel + 4 enum + 12 index.

### 4.2 Verifikasi Tabel Dibuat

Jalankan query ini untuk memastikan:

```sql
select table_name
from information_schema.tables
where table_schema = 'public'
order by table_name;
```

**Harapan:** muncul 6 tabel: `bagian_modul`, `flashcard`, `modul`, `opsi_soal`, `soal`, `video`.

Kalau kurang atau ada error, laporkan ke saya sebelum lanjut.

---

## Langkah 5 — Jalankan RLS

**Ini langkah keamanan paling penting. Jangan dilewati.**

Buka `docs/05-SKEMA-DATABASE.md` §4.3, salin blok RLS.

### PENTING: Ada yang harus diubah untuk Neon

Skema asli ditulis untuk Supabase yang punya role `anon` dan `authenticated`. **Neon memakai role `anonymous`.**

Ganti semua bagian ini:

```sql
-- GANTI BAGIAN INI
from anon, authenticated;
to anon, authenticated;
```

Menjadi:

```sql
-- MENJADI INI
from anonymous;
to anonymous;
```

### SQL RLS Lengkap untuk Neon

Salin blok ini **utuh** (sudah disesuaikan untuk Neon):

```sql
-- =========================================================
-- RLS untuk Neon: baca publik, tulis tertutup total
-- =========================================================

-- 1) Aktifkan RLS di SEMUA tabel konten
alter table public.modul        enable row level security;
alter table public.bagian_modul enable row level security;
alter table public.video        enable row level security;
alter table public.flashcard    enable row level security;
alter table public.soal         enable row level security;
alter table public.opsi_soal    enable row level security;

-- 2) Cabut SEMUA grant dari role publik
--    Langkah ini WAJIB. Tanpa ini, grant tulis bawaan
--    masih aktif walaupun policy SELECT sudah dibuat.
revoke all on table
  public.modul,
  public.bagian_modul,
  public.video,
  public.flashcard,
  public.soal,
  public.opsi_soal
from anonymous;

-- 3) Beri kembali HANYA hak baca
grant usage on schema public to anonymous;

grant select on table
  public.modul,
  public.bagian_modul,
  public.video,
  public.flashcard,
  public.soal,
  public.opsi_soal
to anonymous;

-- 4) Policy: siapa pun boleh membaca semua baris
create policy "modul dapat dibaca publik"
  on public.modul for select to anonymous using (true);

create policy "bagian modul dapat dibaca publik"
  on public.bagian_modul for select to anonymous using (true);

create policy "video dapat dibaca publik"
  on public.video for select to anonymous using (true);

create policy "flashcard dapat dibaca publik"
  on public.flashcard for select to anonymous using (true);

create policy "soal dapat dibaca publik"
  on public.soal for select to anonymous using (true);

create policy "opsi soal dapat dibaca publik"
  on public.opsi_soal for select to anonymous using (true);
```

**Jika muncul error `role "anonymous" does not exist`:**

Role itu belum ada. Buat dulu:

```sql
create role anonymous nologin;
```

Lalu jalankan blok RLS di atas lagi.

**Tidak ada policy INSERT, UPDATE, atau DELETE.** Ini disengaja — dengan grant tulis sudah dicabut dan tidak ada policy tulis, role `anonymous` tidak dapat mengubah apa pun.

---

## Langkah 6 — Aktifkan Data API

Ini yang membuat browser bisa query database tanpa backend.

1. Di Neon Console, pilih project Anda
2. Di sidebar kiri, cari **Data API**
3. Klik **Enable** atau **Activate**
4. Pilih database `neondb`
5. Tunggu proses selesai (± 30 detik)

Setelah aktif, Anda akan melihat **Data API URL**. Bentuknya:

```
https://ep-cool-name-123456.apirest.ap-southeast-1.aws.neon.tech/neondb/rest/v1
```

**Catat URL ini.** Ini yang nanti dipakai aplikasi.

### Soal akses anonim

Di pengaturan Data API, cari opsi tentang **anon access** atau **allow anonymous**. Aktifkan jika ada.

Ada kemungkinan konfigurasi ini bernama `allowAnonymous` atau berupa pilihan role. Aktifkan supaya request tanpa login bisa masuk.

---

## Langkah 7 — UJI KRUSIAL

**Ini langkah paling penting dari seluruh panduan.**

Ada satu hal yang belum jelas di dokumentasi Neon: apakah request **tanpa header Authorization** benar-benar diterima. Seluruh arsitektur tanpa-login bergantung pada ini.

### 7.1 Uji Baca Tanpa Header

Ganti `<DATA_API_URL>` dengan URL Anda, lalu jalankan:

```bash
curl -i "<DATA_API_URL>/modul?select=*"
```

**Harapan:** `HTTP/2 200` dan body berisi `[]` (array kosong, karena belum ada data).

### 7.2 Kemungkinan Hasil dan Artinya

| Hasil | Artinya | Tindakan |
|-------|---------|----------|
| `200` + `[]` | **BERHASIL.** Akses anonim bekerja | Lanjut ke langkah 8 |
| `401` / `403` | Butuh konfigurasi tambahan | Lihat 7.3 |
| `404` | URL salah atau tabel tidak ada | Periksa URL dan langkah 4 |
| `500` | Masalah di sisi Neon | Tunggu 1 menit, coba lagi |

### 7.3 Jika Muncul 401 atau 403

Coba langkah ini berurutan:

**Langkah 1 — Pastikan role sudah diberi izin:**

```sql
grant usage on schema public to anonymous;
grant select on all tables in schema public to anonymous;
```

Lalu uji `curl` lagi.

**Langkah 2 — Periksa pengaturan Data API:**

Kembali ke halaman Data API di Neon Console. Cari opsi tentang anonim/authenticated access. Pastikan akses anonim diizinkan.

**Langkah 3 — Laporkan ke saya:**

Jika masih gagal, kirim ke saya:
- Output `curl` lengkap (termasuk header respons)
- Screenshot pengaturan Data API

Saya akan bantu cari solusinya. Ada beberapa kemungkinan cara mengatasi, dan saya perlu tahu respons persisnya untuk memilih yang tepat.

---

## Langkah 8 — Uji Keamanan

**Jangan lewati.** Ini membuktikan database Anda benar-benar aman.

### 8.1 Uji Tulis — HARUS GAGAL

```bash
curl -i -X POST "<DATA_API_URL>/modul" \
  -H "Content-Type: application/json" \
  -d '{"slug":"uji-keamanan","judul":"Uji","topik":"array","deskripsi":"tes"}'
```

**Harapan: GAGAL** dengan status 401, 403, atau pesan `permission denied`.

### 8.2 Uji Hapus — HARUS GAGAL

```bash
curl -i -X DELETE "<DATA_API_URL>/modul?slug=eq.uji-keamanan"
```

**Harapan: GAGAL.**

### 8.3 Jika Uji Tulis BERHASIL

**Ini masalah serius. JANGAN LANJUT.**

Artinya RLS belum benar dan siapa pun bisa menghapus konten Anda. Yang harus dilakukan:

1. Jalankan ulang blok `revoke all` di langkah 5
2. Pastikan tidak ada error saat menjalankannya
3. Uji lagi

Jika masih berhasil, laporkan ke saya segera.

### 8.4 Bersihkan Data Uji

Jika uji tulis tadi berhasil (dan seharusnya tidak), hapus datanya:

```sql
delete from public.modul where slug = 'uji-keamanan';
```

---

## Langkah 9 — Isi Data Contoh

Buka `docs/05-SKEMA-DATABASE.md` §6, salin blok seed SQL.

Tempel ke SQL Editor Neon, lalu Run.

### Verifikasi

```sql
select
  (select count(*) from modul) as modul,
  (select count(*) from bagian_modul) as bagian,
  (select count(*) from flashcard) as kartu,
  (select count(*) from soal) as soal,
  (select count(*) from opsi_soal) as opsi,
  (select count(*) from video) as video;
```

**Harapan:** `1, 5, 8, 3, 12, 1`

### Uji Baca Data dari Data API

```bash
curl "<DATA_API_URL>/modul?select=slug,judul,topik"
```

**Harapan:** menampilkan 1 modul `array-dasar`.

Sekarang uji query bertingkat — ini yang akan dipakai aplikasi:

```bash
curl "<DATA_API_URL>/modul?select=id,slug,judul,bagian_modul(id,judul),flashcard(id,depan)&slug=eq.array-dasar"
```

**Harapan:** satu modul dengan array `bagian_modul` dan `flashcard` di dalamnya.

**Jika query bertingkat ini berhasil, arsitektur FlashStruct sudah terbukti bekerja.**

---

## Langkah 10 — Laporkan ke Saya

Kirim ke saya informasi ini:

```
1. Status uji baca anonim     : [200 OK / 401 / lainnya]
2. Status uji tulis           : [GAGAL (benar) / BERHASIL (masalah)]
3. Status uji hapus           : [GAGAL (benar) / BERHASIL (masalah)]
4. Hasil verifikasi seed      : [1, 5, 8, 3, 12, 1 / lainnya]
5. Hasil query bertingkat     : [berhasil / gagal]
6. Data API URL               : https://...
7. Ada error atau keanehan?   : [jelaskan]
```

**Data API URL boleh dibagikan** — itu memang untuk publik, seperti alamat situs.

**JANGAN kirim connection string.** Itu rahasia dan memberi akses penuh.

Setelah saya terima laporan, saya akan:
1. Perbarui dokumentasi (05, 09, 10) untuk Neon
2. Buat wrapper `fetch` untuk query
3. Lanjutkan M2 (Supabase client → Neon client)

---

## Pemecahan Masalah

### Error saat menjalankan DDL

**`extension "pgcrypto" is not available`**

Neon sudah punya `gen_random_uuid()` bawaan. Hapus baris `create extension if not exists pgcrypto;` dan jalankan ulang.

**`permission denied for schema public`**

Anda memakai role yang salah. Pastikan memakai connection string dengan user `neondb_owner`.

### Error saat menjalankan RLS

**`role "anonymous" does not exist`**

Buat dulu:

```sql
create role anonymous nologin;
```

**`policy "..." already exists`**

Policy sudah pernah dibuat. Hapus dulu lalu buat ulang:

```sql
drop policy if exists "modul dapat dibaca publik" on public.modul;
```

### Data API tidak muncul di sidebar

Pastikan project sudah selesai dibuat (bukan masih provisioning). Kalau perlu, refresh halaman.

### curl mengembalikan HTML, bukan JSON

URL salah. Pastikan diakhiri `/rest/v1` dan tidak ada spasi atau tanda kutip yang ikut tersalin.

### curl sangat lambat pada request pertama

Itu normal. Compute sedang bangun dari tidur (scale to zero). Request berikutnya cepat.

---

## Yang Perlu Anda Ingat

| Aturan | Alasan |
|--------|--------|
| **Connection string = rahasia** | Memberi akses penuh, melewati RLS |
| **Data API URL = publik** | Memang untuk dipakai browser |
| **Jangan taruh connection string di `.env.local`** | Vite akan memasukkannya ke bundle browser |
| **Uji tulis HARUS gagal** | Bukti database aman |
| **Pakai direct connection untuk migrasi** | Pooled tidak mendukung semua DDL |

---

## Referensi

| Topik | Dokumen |
|-------|---------|
| Analisis keputusan pindah ke Neon | `12-ANALISIS-NEON.md` |
| Fakta teknis dan tautan sumber | `riset/03-RISET-NEON.md` |
| DDL dan RLS asli | `05-SKEMA-DATABASE.md` §3, §4.3 |
| Seed data contoh | `05-SKEMA-DATABASE.md` §6 |
