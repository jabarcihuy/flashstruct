# 15 — Setup Supabase: Yang Perlu Anda Lakukan

> Panduan langkah demi langkah untuk Anda. Setelah selesai, saya lanjutkan M2.
> Status: `[PANDUAN]` · Detail teknis di `05-SKEMA-DATABASE.md`, `09-PANDUAN-SETUP.md` §3

---

## Ringkasan Alur

```
1. Buat akun Supabase          (3 menit)
2. Buat project                (3 menit, tunggu 2-3 menit proses)
3. Catat kredensial            (2 menit)
4. Jalankan skema database     (10 menit)
5. Jalankan RLS                (5 menit)
6. UJI KEAMANAN                (5 menit)  <- paling penting
7. Isi data contoh             (5 menit)
8. Laporkan ke saya            (2 menit)
```

**Total: ± 35 menit.**

---

## Langkah 1 — Buat Akun Supabase

1. Buka **https://supabase.com**
2. Klik **Start your project** (kanan atas)
3. Pilih **Continue with GitHub** — lebih cepat, tidak perlu verifikasi email

   Bisa juga pakai email + password kalau lebih nyaman.

**Tidak perlu kartu kredit.** Free Plan Supabase benar-benar gratis tanpa kartu.

---

## Langkah 2 — Buat Project

Setelah masuk, Anda akan diminta membuat project. Isi seperti ini:

| Field | Nilai | Alasan |
|-------|-------|--------|
| **Organization** | Biarkan default (nama akun Anda) | — |
| **Project name** | `flashstruct` | Nama bebas |
| **Database Password** | **Buat yang kuat, SIMPAN di password manager** | Tidak bisa dilihat lagi setelah dibuat |
| **Region** | **Southeast Asia (Singapore)** | Terdekat dari Indonesia |
| **Pricing Plan** | Free | — |

### PENTING soal Database Password

Password ini **hanya ditampilkan sekali** saat pembuatan. Kalau lupa, harus reset.

**Simpan di tempat aman.** Anda tidak akan memerlukannya untuk aplikasi (aplikasi pakai API key), tapi berguna kalau nanti perlu akses database langsung.

**Tips:** gunakan generator password di password manager Anda, jangan ketik manual.

### Soal Region

**Pilih Singapore.** Kalau memilih US atau Europe, setiap request akan menempuh perjalanan jauh dan terasa lambat.

Klik **Create new project**, lalu tunggu **2–3 menit** sambil Supabase menyiapkan database.

---

## Langkah 3 — Catat Kredensial

Setelah project siap:

1. Di sidebar kiri, klik **Settings** (ikon gerigi, di bawah)
2. Pilih **API Keys**
3. Catat **dua nilai** ini:

| Nama di Dashboard | Bentuk | Contoh |
|-------------------|--------|--------|
| **Project URL** | `https://xxxxx.supabase.co` | `https://abcdefghijk.supabase.co` |
| **Publishable key** | `sb_publishable_xxxxx` | `sb_publishable_AbCdEf123...` |

### Kalau tidak menemukan "Publishable key"

Supabase sedang mengganti sistem key. Kemungkinan yang Anda lihat:

| Yang terlihat | Tindakan |
|---------------|----------|
| `sb_publishable_...` | **Pakai ini** — format terbaru |
| `anon` `public` (JWT panjang) | **Boleh dipakai** — format lama, masih didukung |
| Keduanya ada | Pakai `sb_publishable_...` |

**Keduanya aman dibagikan** selama RLS aktif.

### JANGAN ambil yang ini

| Nama | Kenapa berbahaya |
|------|------------------|
| `service_role` | Melewati RLS — akses penuh ke database |
| `sb_secret_...` | Sama, ini pengganti `service_role` |

Kalau key ini bocor, siapa pun bisa menghapus seluruh konten Anda.

---

## Langkah 4 — Jalankan Skema Database

1. Di sidebar kiri Supabase, klik **SQL Editor**
2. Klik **New query**
3. Buka file `docs/05-SKEMA-DATABASE.md`, cari bagian **§3. DDL Lengkap**
4. Salin **seluruh blok SQL** di dalamnya
5. Tempel ke SQL Editor
6. Klik **Run** (atau Ctrl+Enter)

**Harapan:** muncul pesan sukses, tanpa error.

### Verifikasi Tabel Dibuat

Buat query baru, jalankan ini:

```sql
select table_name
from information_schema.tables
where table_schema = 'public'
order by table_name;
```

**Harapan:** muncul **6 tabel**:
`bagian_modul`, `flashcard`, `modul`, `opsi_soal`, `soal`, `video`

Kalau kurang atau ada error, **berhenti dan laporkan ke saya**.

---

## Langkah 5 — Jalankan RLS

**Ini langkah keamanan paling penting.**

1. Buat **query baru** di SQL Editor
2. Buka `docs/05-SKEMA-DATABASE.md` §4.3
3. Salin seluruh blok RLS
4. Tempel dan **Run**

**Harapan:** sukses tanpa error.

**Catatan:** Supabase sudah punya role `anon` dan `authenticated` bawaan, jadi tidak perlu membuat role baru seperti di Neon.

---

## Langkah 6 — UJI KEAMANAN (Jangan Dilewati)

Ini membuktikan database Anda benar-benar terlindungi. Jalankan di **terminal** komputer Anda.

Ganti `<PROJECT>` dan `<KEY>` dengan nilai dari Langkah 3.

### Uji 1 — Baca harus BERHASIL

```bash
curl -i "https://<PROJECT>.supabase.co/rest/v1/modul?select=*" \
  -H "apikey: <KEY>" \
  -H "Authorization: Bearer <KEY>"
```

**Harapan:** `HTTP/2 200` dan body berisi `[]` (array kosong, karena belum ada data).

Kalau muncul `401` atau `403`, periksa kembali key-nya.

### Uji 2 — Tulis harus GAGAL

```bash
curl -i -X POST "https://<PROJECT>.supabase.co/rest/v1/modul" \
  -H "apikey: <KEY>" \
  -H "Authorization: Bearer <KEY>" \
  -H "Content-Type: application/json" \
  -d '{"slug":"uji-keamanan","judul":"Uji","topik":"array","deskripsi":"tes"}'
```

**Harapan: GAGAL.** Status 401 atau 403, dan pesan menyebut `row-level security` atau `permission denied`.

### Uji 3 — Hapus harus GAGAL

```bash
curl -i -X DELETE "https://<PROJECT>.supabase.co/rest/v1/modul?slug=eq.array-dasar" \
  -H "apikey: <KEY>" \
  -H "Authorization: Bearer <KEY>"
```

**Harapan: GAGAL.**

### Jika Uji 2 atau 3 BERHASIL

**JANGAN LANJUT.** Artinya database Anda terbuka dan siapa pun bisa menghapus konten.

Yang harus dilakukan:
1. Jalankan ulang blok `revoke all` di Langkah 5
2. Pastikan tidak ada error
3. Uji lagi

Kalau masih berhasil, **laporkan ke saya segera**.

---

## Langkah 7 — Isi Data Contoh

1. Buat query baru di SQL Editor
2. Buka `docs/05-SKEMA-DATABASE.md` §6
3. Salin blok seed SQL
4. Tempel dan **Run**

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

### Uji Query Bertingkat

Ini yang akan dipakai aplikasi — satu request mengambil modul beserta semua turunannya:

```bash
curl "https://<PROJECT>.supabase.co/rest/v1/modul?select=id,slug,judul,bagian_modul(id,judul),flashcard(id,depan)&slug=eq.array-dasar" \
  -H "apikey: <KEY>" \
  -H "Authorization: Bearer <KEY>"
```

**Harapan:** satu modul dengan array `bagian_modul` dan `flashcard` di dalamnya.

**Kalau query ini berhasil, arsitektur FlashStruct sudah terbukti bekerja.**

---

## Langkah 8 — Laporkan ke Saya

Kirim informasi ini:

```
1. Project URL            : https://xxxxx.supabase.co
2. Publishable key        : sb_publishable_xxxxx  (atau anon key)
3. Uji baca (harus 200)   : [hasil]
4. Uji tulis (harus GAGAL): [hasil]
5. Uji hapus (harus GAGAL): [hasil]
6. Verifikasi seed        : [1, 5, 8, 3, 12, 1 / lainnya]
7. Query bertingkat       : [berhasil / gagal]
8. Ada error?             : [jelaskan]
```

**Project URL dan publishable key boleh dibagikan** — keduanya memang untuk publik, seperti alamat situs. Yang melindungi data adalah RLS, bukan kerahasiaan key.

**JANGAN kirim:**
- Database password
- `service_role` key
- `sb_secret_` key

---

## Setelah Laporan Anda

Saya akan:

1. Buat file `.env.local` dengan kredensial Anda (tidak akan di-commit)
2. Buat `lib/supabase.ts` — client Supabase
3. Buat `features/materi/api.ts` — query materi
4. Buat tipe TypeScript dari skema
5. Verifikasi data tampil di browser
6. Commit M2

**Estimasi M2: ± 12,5 jam kerja** (termasuk melengkapi modul `array-dasar` menjadi 20 kartu + 18 soal).

---

## Pemecahan Masalah

### Project tidak selesai dibuat

Tunggu 2–3 menit. Kalau lebih dari 5 menit, refresh halaman. Kalau masih stuck, hapus project dan buat ulang.

### Tidak menemukan menu SQL Editor

Pastikan Anda sudah di dalam project (bukan halaman daftar project). Sidebar kiri punya ikon-ikon; SQL Editor biasanya ikon `>_`.

### Error saat menjalankan DDL

| Error | Penyebab | Solusi |
|-------|----------|--------|
| `type "topik_modul" already exists` | Sudah pernah dijalankan | Aman diabaikan, atau hapus tabel dulu |
| `permission denied for schema public` | Bukan owner project | Pastikan login sebagai pemilik |
| `relation "modul" already exists` | Sudah ada | Hapus dulu atau lewati |

Kalau ragu, **laporkan error lengkapnya ke saya** sebelum mencoba memperbaiki sendiri.

### curl tidak tersedia

Windows: pakai PowerShell dengan `Invoke-RestMethod`. Atau laporkan ke saya, saya bantu caranya.

### curl mengembalikan HTML, bukan JSON

URL salah. Pastikan:
- Diakhiri `/rest/v1/...`
- Tidak ada spasi yang ikut tersalin
- Tidak ada tanda kutip yang salah

### Lupa database password

Tidak masalah untuk aplikasi ini. Reset lewat **Settings > Database > Reset database password** kalau nanti perlu.

---

## Yang Perlu Anda Ingat

| Aturan | Alasan |
|--------|--------|
| **Publishable key aman dibagikan** | Memang untuk publik; RLS yang melindungi |
| **service_role key = RAHASIA** | Melewati RLS sepenuhnya |
| **Uji tulis HARUS gagal** | Bukti database aman |
| **Region Singapore** | Terdekat, latensi paling rendah |
| **Simpan database password** | Tidak bisa dilihat lagi |

---

## Referensi

| Topik | Dokumen |
|-------|---------|
| Keputusan arsitektur & alasan | `14-KEPUTUSAN-ARSITEKTUR-DATA.md` |
| DDL, RLS, seed lengkap | `05-SKEMA-DATABASE.md` |
| Panduan setup umum | `09-PANDUAN-SETUP.md` §3 |
| Checklist rilis | `08-CHECKLIST-QA.md` |
