# 17 — Mengontrol Database dari Laptop Lokal

> Jawaban atas pertanyaan: "apakah bisa kontrol database melalui laptop lokal saya?"
> Status: `[PANDUAN]` · Semua sudah diverifikasi di laptop Anda

---

## 1. Jawaban Singkat

**Bisa.** Ada **empat cara**, dari yang paling mudah sampai paling powerful.

| Cara | Perlu install? | Bisa apa |
|------|----------------|----------|
| **1. Supabase Dashboard** | Tidak | Lihat data, jalankan SQL, kelola project |
| **2. REST API + curl** | Tidak | Baca data, uji koneksi |
| **3. `psql` (terminal)** | **Sudah ada** di laptop Anda | SQL penuh, lihat struktur, backup |
| **4. Supabase CLI** | Perlu install | Migrasi, diff skema, kelola lokal |

**Di laptop Anda sudah tersedia:** `psql` dan `pg_dump` versi 18.6. Port 5432 dan 6543 ke Supabase Anda juga sudah terbuka.

---

## 2. Hasil Verifikasi di Laptop Anda

Saya sudah menguji koneksinya:

| Yang diuji | Hasil |
|------------|-------|
| `psql --version` | PostgreSQL 18.6 — tersedia |
| `pg_dump --version` | 18.6 — tersedia |
| Port 5432 (direct) | **Terbuka** |
| Port 6543 (pooler) | **Terbuka** |
| REST API | Berfungsi (401 tanpa key, 404 = tabel belum ada) |
| Supabase CLI | Belum terpasang |

**Artinya:** laptop Anda sudah siap. Yang kurang hanya password database, yang bisa Anda ambil dari dashboard Supabase.

---

## 3. Cara 1 — Supabase Dashboard (Paling Mudah)

**Tidak perlu install apa pun.** Cukup browser.

### Kapan dipakai

| Situasi | Cocok? |
|---------|--------|
| Menjalankan SQL sesekali | Ya |
| Melihat isi tabel | Ya |
| Mengubah data manual | Ya |
| Backup | Tidak — pakai `pg_dump` |
| Otomasi | Tidak |

### Cara akses

1. Buka [supabase.com/dashboard](https://supabase.com/dashboard)
2. Pilih project `flashstruct`
3. **SQL Editor** — untuk menjalankan SQL
4. **Table Editor** — untuk melihat/mengubah data seperti spreadsheet

### Kelebihan

- Tidak perlu setup
- Ada autocomplete SQL
- Bisa lihat hasil query dalam tabel
- Aman — tidak ada risiko salah koneksi

### Kekurangan

- Harus buka browser
- Tidak bisa dipakai di skrip atau otomasi
- Tidak bisa `pg_dump`

---

## 4. Cara 2 — REST API + curl (Untuk Uji Cepat)

Ini yang sudah dipakai untuk verifikasi keamanan.

### Contoh perintah

```bash
# Simpan ke variabel agar tidak menulis ulang
export SB_URL="https://lxvoedfjecmmwfrfhbah.supabase.co"
export SB_KEY="sb_publishable_2AhzgjfPLsquiUHNw-yr2Q_1XjHn6nd"

# Baca semua modul
curl "$SB_URL/rest/v1/modul?select=*" \
  -H "apikey: $SB_KEY" \
  -H "Authorization: Bearer $SB_KEY"

# Baca modul tertentu dengan relasinya
curl "$SB_URL/rest/v1/modul?select=id,judul,bagian_modul(judul)&slug=eq.array-dasar" \
  -H "apikey: $SB_KEY" \
  -H "Authorization: Bearer $SB_KEY"
```

### Kapan dipakai

| Situasi | Cocok? |
|---------|--------|
| Uji cepat apakah API jalan | Ya |
| Uji keamanan (tulis harus gagal) | **Ya — ini caranya** |
| Lihat data | Ya |
| Mengubah data | Tidak — RLS akan menolak |

### Kelebihan

- Tidak perlu install
- Persis seperti yang dipakai aplikasi
- Bagus untuk menguji RLS

### Kekurangan

- Hanya bisa **baca** (RLS menolak tulis)
- Query kompleks jadi panjang di URL

---

## 5. Cara 3 — `psql` di Terminal (Paling Powerful)

**Ini yang paling berguna untuk Anda.** `psql` sudah terpasang.

### 5.1 Ambil Connection String

1. Buka Supabase Dashboard, pilih project
2. Klik tombol **Connect** (kanan atas)
3. Pilih tab **Session pooler** atau **Direct connection**
4. Salin connection string

Bentuknya:

```
postgresql://postgres.lxvoedfjecmmwfrfhbah:[YOUR-PASSWORD]@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres
```

Ganti `[YOUR-PASSWORD]` dengan database password yang Anda simpan saat membuat project.

### 5.2 Pilih Pooler atau Direct?

| Mode | Port | Dipakai untuk |
|------|------|---------------|
| **Session pooler** | 5432 | **Default** — aman untuk hampir semua hal |
| **Transaction pooler** | 6543 | Aplikasi serverless, koneksi sebentar |
| **Direct connection** | 5432 | `pg_dump`, migrasi, operasi admin |

**Rekomendasi: pakai Session pooler** untuk pekerjaan sehari-hari. IPv4 sudah didukung, tidak perlu konfigurasi tambahan.

### 5.3 Simpan Agar Tidak Menulis Ulang

**JANGAN simpan di `.env.local`** — itu dibaca Vite dan bisa masuk bundle browser.

Buat file terpisah yang tidak dipakai aplikasi:

```bash
# Simpan di home directory, bukan di folder proyek
echo 'export SB_DB="postgresql://postgres.lxvoedfjecmmwfrfhbah:PASSWORD@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres"' >> ~/.bashrc
source ~/.bashrc
```

Atau pakai file `.pgpass` (lebih aman, tidak terlihat di `history`):

```bash
# Format: hostname:port:database:username:password
echo "aws-0-ap-southeast-1.pooler.supabase.com:5432:postgres:postgres.lxvoedfjecmmwfrfhbah:PASSWORD" >> ~/.pgpass
chmod 600 ~/.pgpass
```

Setelah itu, `psql` tidak akan menanyakan password lagi.

### 5.4 Perintah Berguna

**Masuk ke database:**

```bash
psql "$SB_DB"
```

**Lihat semua tabel:**

```bash
psql "$SB_DB" -c "\dt public.*"
```

**Lihat struktur tabel:**

```bash
psql "$SB_DB" -c "\d public.modul"
```

**Jalankan query:**

```bash
psql "$SB_DB" -c "select slug, judul, topik from modul order by urutan;"
```

**Lihat isi tabel seperti spreadsheet:**

```bash
psql "$SB_DB" -c "select * from flashcard limit 10;" -P pager=off
```

**Cek RLS aktif di semua tabel:**

```bash
psql "$SB_DB" -c "select tablename, rowsecurity from pg_tables where schemaname='public' order by tablename;"
```

**Cek policy yang terpasang:**

```bash
psql "$SB_DB" -c "select tablename, policyname, cmd from pg_policies where schemaname='public' order by tablename;"
```

**Jalankan file SQL:**

```bash
psql "$SB_DB" -f supabase/migrations/001_initial_schema.sql
```

**Uji sebagai role anon (uji keamanan):**

```bash
psql "$SB_DB" -c "set role anon; select count(*) from modul;"
psql "$SB_DB" -c "set role anon; insert into modul(slug,judul,topik,deskripsi) values ('x','X','array','y');"
# Harapan: permission denied
```

**Backup seluruh database:**

```bash
pg_dump "$SB_DB" > backup-$(date +%Y%m%d).sql
```

**Backup hanya data (tanpa struktur):**

```bash
pg_dump "$SB_DB" --data-only > data-$(date +%Y%m%d).sql
```

**Backup hanya satu tabel:**

```bash
pg_dump "$SB_DB" -t public.modul > modul-$(date +%Y%m%d).sql
```

**Restore dari backup:**

```bash
psql "$SB_DB" < backup-20260922.sql
```

### 5.5 Perintah `psql` yang Sering Dipakai

Setelah masuk ke `psql` (prompt berubah jadi `postgres=>`):

| Perintah | Fungsi |
|----------|--------|
| `\dt` | Lihat semua tabel |
| `\d modul` | Lihat struktur tabel `modul` |
| `\d+ modul` | Struktur lebih detail |
| `\dn` | Lihat semua schema |
| `\df` | Lihat semua function |
| `\l` | Lihat semua database |
| `\x` | Toggle tampilan vertikal (bagus untuk tabel lebar) |
| `\e` | Buka editor untuk menulis query panjang |
| `\i file.sql` | Jalankan file SQL |
| `\o hasil.txt` | Simpan output ke file |
| `\q` | Keluar |

### 5.6 Catatan Penting: `psql` Melewati RLS

**Ini krusial untuk dipahami.**

Saat connect dengan `psql` memakai user `postgres`, Anda masuk sebagai **owner database**. Owner **melewati RLS sepenuhnya**.

Artinya:

| Yang Anda lakukan | Lewat RLS? |
|-------------------|------------|
| Aplikasi (key publishable) | **Tidak** — RLS berlaku |
| `psql` sebagai postgres | **Ya** — RLS dilewati |

**Konsekuensinya:**

- `psql` **bisa** menulis, mengubah, menghapus data — karena Anda owner
- Ini **bukan** berarti RLS rusak
- Untuk menguji RLS, harus pakai `set role anon` dulu

**Jangan pernah** memasukkan connection string `psql` ke aplikasi. Kalau bocor, RLS tidak melindungi apa pun.

---

## 6. Cara 4 — Supabase CLI (Untuk Migrasi)

Belum terpasang di laptop Anda. Install kalau butuh mengelola migrasi.

### 6.1 Install

```bash
npm install supabase --save-dev
npx supabase --version
```

### 6.2 Kapan Perlu CLI

| Situasi | Perlu CLI? |
|---------|------------|
| Menjalankan SQL sesekali | Tidak — pakai Dashboard |
| Lihat data | Tidak — pakai `psql` |
| Backup | Tidak — pakai `pg_dump` |
| **Kelola migrasi versi** | **Ya** |
| **Diff skema lokal vs remote** | **Ya** |
| **Jalankan Supabase lokal** | Ya — tapi butuh Docker |

### 6.3 Perintah Berguna

```bash
# Login
npx supabase login

# Hubungkan ke project
npx supabase link --project-ref lxvoedfjecmmwfrfhbah

# Lihat daftar migrasi
npx supabase migration list

# Terapkan migrasi ke remote
npx supabase db push

# Tarik skema dari remote
npx supabase db pull

# Cek kesehatan database (saran perbaikan)
npx supabase db advisors
```

### 6.4 Catatan

**CLI untuk Supabase lokal butuh Docker.** Kita sudah memutuskan tidak memakai Docker, jadi fitur `supabase start` tidak akan dipakai. Tapi perintah migrasi (`db push`, `db pull`, `migration list`) **tidak butuh Docker** — hanya koneksi ke project remote.

---

## 7. Perbandingan: Mana yang Dipakai Kapan

| Tugas | Cara terbaik |
|-------|--------------|
| Jalankan DDL pertama kali | **Dashboard SQL Editor** |
| Cek data sudah masuk | **Dashboard Table Editor** atau `psql` |
| Uji keamanan RLS | **curl** atau `psql` dengan `set role anon` |
| Lihat struktur tabel | **`psql`** dengan `\d modul` |
| Backup rutin | **`pg_dump`** |
| Tambah data konten | **Dashboard SQL Editor** |
| Debug query lambat | **Dashboard** (Query Performance) |
| Kelola migrasi | **Supabase CLI** |
| Kerja cepat dari terminal | **`psql`** |

---

## 8. Rekomendasi untuk Anda

### Setup Sekali

1. **Ambil connection string** dari Dashboard > Connect
2. **Simpan di `~/.pgpass`** agar tidak perlu ketik password
3. **Uji koneksi** dengan `psql "$SB_DB" -c "select 1"`

### Alur Kerja Sehari-hari

```bash
# Lihat tabel
psql "$SB_DB" -c "\dt public.*"

# Cek data
psql "$SB_DB" -c "select slug, judul from modul order by urutan;"

# Backup sebelum perubahan besar
pg_dump "$SB_DB" > backup-$(date +%Y%m%d).sql

# Jalankan SQL
psql "$SB_DB" -f supabase/migrations/003_tambah_kolom.sql
```

### Yang Perlu Diingat

| Aturan | Alasan |
|--------|--------|
| **Jangan simpan connection string di `.env.local`** | Vite akan memasukkannya ke bundle browser |
| **Connection string = RAHASIA** | Melewati RLS, akses penuh |
| **Uji RLS pakai `set role anon`** | Karena owner melewati RLS |
| **Backup sebelum perubahan besar** | `pg_dump` gratis dan cepat |

---

## 9. Status Saat Ini

| Item | Status |
|------|--------|
| `psql` terpasang | Ya (18.6) |
| `pg_dump` terpasang | Ya (18.6) |
| Port 5432 terbuka | Ya |
| Port 6543 terbuka | Ya |
| REST API berfungsi | Ya |
| Tabel sudah dibuat | **Belum** — DDL belum dijalankan |
| Connection string tersimpan | **Belum** — perlu Anda ambil |

### Langkah Berikutnya

1. **Jalankan DDL** dari `supabase/migrations/001_initial_schema.sql` di Dashboard SQL Editor
2. **Jalankan RLS** dari `supabase/migrations/002_rls_policies.sql`
3. **Uji keamanan** dengan curl (uji tulis harus gagal)
4. **Ambil connection string** dari Dashboard > Connect, simpan di `~/.pgpass`
5. **Uji `psql`** untuk memastikan bisa akses dari laptop

Setelah itu, Anda punya kendali penuh atas database dari laptop.

---

## 10. Referensi

| Topik | Dokumen |
|-------|---------|
| Skema SQL siap pakai | `supabase/migrations/001_initial_schema.sql` |
| RLS siap pakai | `supabase/migrations/002_rls_policies.sql` |
| Kenapa RLS wajib | `16-KENAPA-RLS-WAJIB.md` |
| Setup Supabase | `15-SETUP-SUPABASE-UNTUK-ANDA.md` |
