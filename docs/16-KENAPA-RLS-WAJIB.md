# 16 — Kenapa RLS Wajib Diaktifkan

> Jawaban atas pertanyaan: "perlukah mengaktifkan RLS?"
> Status: `[PENTING]` · Berisi hasil demonstrasi nyata, bukan sekadar teori

---

## 1. Jawaban Singkat

**Ya, wajib. Tanpa RLS, seluruh konten Anda bisa dihapus siapa pun dalam hitungan detik.**

Ini bukan teori. Saya sudah membuktikannya dengan menjalankan serangan nyata di PostgreSQL lokal. Hasilnya ada di §3.

---

## 2. Mengapa Ini Terjadi

### 2.1 Key Publishable Selalu Bisa Diambil

Key `publishable` yang dipakai aplikasi **akan selalu terlihat** di browser. Itu memang desainnya — bukan kebocoran, bukan kesalahan.

Siapa pun bisa:
1. Buka situs Anda
2. Tekan F12 (DevTools)
3. Cari key di tab Network atau Sources
4. Pakai key itu untuk memanggil API Anda langsung

**Anda tidak bisa mencegah ini.** Key itu harus ada di browser agar aplikasi bisa berfungsi.

### 2.2 Karena Itu, yang Melindungi Harus RLS

Karena key tidak bisa dirahasiakan, **satu-satunya pertahanan adalah RLS**.

RLS (Row Level Security) memberi tahu database: "role ini hanya boleh membaca, tidak boleh menulis."

Tanpa RLS, key publishable menjadi **kunci master** — siapa pun yang memilikinya bisa melakukan apa saja.

### 2.3 Apa Kata Dokumentasi Resmi

Ini kutipan persis dari dokumentasi Supabase:

> "**A table in an exposed schema without RLS is readable and writable by any role with a grant on it.** Enable RLS on every table in an exposed schema. On projects that still grant `anon` and `authenticated` by default, revoke those grants. **Adding policies doesn't remove them.**"
> — [Supabase: Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)

Perhatikan kalimat terakhir: **"Adding policies doesn't remove them."** Ini yang sering disalahpahami — lihat §4.

---

## 3. Bukti: Demonstrasi Serangan Nyata

Saya menjalankan simulasi lengkap di PostgreSQL lokal dengan role `anon` seperti di Supabase.

### 3.1 Skenario A — TANPA RLS

Kondisi: tabel `modul` berisi 2 modul, role `anon` punya grant standar Supabase.

| Serangan | Hasil |
|----------|-------|
| anon baca data | **Berhasil** |
| anon ubah judul modul | **Berhasil** — `UPDATE 1` |
| anon hapus semua modul | **Berhasil** — `DELETE 2` |
| anon tambah data spam | **Berhasil** — `INSERT 0 1` |

**Isi tabel setelah serangan:**

```
spam | Situs Judi Online
```

**Dua modul pembelajaran terhapus, diganti spam judi online.** Hanya dengan 4 perintah, tanpa login, tanpa akses khusus.

### 3.2 Skenario B — DENGAN RLS (setup yang benar)

Kondisi: RLS aktif + grant tulis dicabut + hanya policy SELECT.

| Serangan | Hasil |
|----------|-------|
| anon baca data | **Berhasil** |
| anon ubah judul | **DITOLAK** — `permission denied for table modul` |
| anon hapus modul | **DITOLAK** — `permission denied for table modul` |
| anon tambah data | **DITOLAK** — `permission denied for table modul` |
| anon hapus tabel | **DITOLAK** — `must be owner of table modul` |

**Isi tabel setelah semua serangan:**

```
array-dasar | Dasar Array & Indeks
pointer-dasar | Dasar Pointer
```

**Data utuh, tidak berubah sedikit pun.**

### 3.3 Ringkasan Perbandingan

| Skenario | anon bisa baca? | anon bisa tulis? |
|----------|-----------------|------------------|
| **A.** Tanpa RLS | Ya | **Ya — bahaya** |
| **B.** RLS + revoke + policy SELECT | Ya | Tidak |
| **C.** RLS + policy SELECT, grant tulis masih ada | Ya | **Sebagian** |
| **D.** RLS + policy `FOR ALL` | Ya | **Ya — bahaya** |

---

## 4. Jebakan yang Sering Terjadi

Ada **tiga** kesalahan umum. Dua di antaranya sangat berbahaya karena sistem **tampak aman** padahal tidak.

### 4.1 Jebakan 1: Mengira Policy SELECT Sudah Cukup

Ini kesalahan paling umum.

**Kondisi:** RLS aktif, ada policy SELECT, tapi **grant tulis masih ada** (bawaan Supabase).

Hasil demonstrasi saya:

```sql
-- anon mencoba menghapus
delete from modul;
-- Hasil: DELETE 0   <- bukan error!
```

**Kenapa `DELETE 0` dan bukan error?** Karena policy SELECT memfilter baris yang terlihat, sehingga `DELETE` tidak menemukan baris untuk dihapus.

**Masalahnya:** sistem **tidak memberi peringatan**. Kalau nanti Anda menambah policy lain, atau kondisi berubah, grant tulis itu akan aktif kembali.

**Solusi:** cabut grant tulis secara eksplisit:

```sql
revoke all on table public.modul from anon, authenticated;
grant select on table public.modul to anon, authenticated;
```

### 4.2 Jebakan 2: Memakai Policy `FOR ALL`

Saya menguji ini dan hasilnya jelas:

```sql
create policy "semua orang boleh apa saja"
  on kartu for all to anon using (true) with check (true);
```

| Serangan | Hasil |
|----------|-------|
| anon hapus kartu | **Berhasil** — `DELETE 1` |
| anon tambah kartu | **Berhasil** — `INSERT 0 1` |

**Policy `for all using (true)` MEMANG mengizinkan tulis.** Ini bukan bug — memang begitu cara kerjanya.

**Solusi:** tulis policy **per operasi**, jangan `for all`:

```sql
-- BENAR: hanya SELECT
create policy "modul dapat dibaca publik"
  on public.modul for select to anon using (true);

-- JANGAN: for all
-- create policy "..." on public.modul for all to anon using (true);
```

### 4.3 Jebakan 3: Mengira "RLS Aktif" Sama Dengan "Aman"

RLS aktif **belum cukup**. Yang membuat aman adalah **kombinasi tiga hal**:

| # | Lapis | Fungsi |
|---|-------|--------|
| 1 | **RLS aktif** | Mengaktifkan sistem pemeriksaan |
| 2 | **Grant dicabut** | Menentukan operasi apa yang diizinkan |
| 3 | **Policy SELECT saja** | Menentukan baris mana yang boleh diakses |

**Ketiganya harus ada.** Kalau salah satu hilang, ada celah.

---

## 5. Perintah SQL yang Benar

Ini yang harus dijalankan untuk setiap tabel. Sudah ada di `05-SKEMA-DATABASE.md` §4.3.

```sql
-- LANGKAH 1: Aktifkan RLS
alter table public.modul enable row level security;

-- LANGKAH 2: Cabut SEMUA grant dari role publik
--    Ini langkah yang sering dilewatkan!
revoke all on table public.modul from anon, authenticated;

-- LANGKAH 3: Beri HANYA hak baca
grant select on table public.modul to anon, authenticated;

-- LANGKAH 4: Policy SELECT saja (bukan FOR ALL)
create policy "modul dapat dibaca publik"
  on public.modul for select to anon, authenticated using (true);
```

**Tidak ada policy INSERT, UPDATE, atau DELETE.** Ini disengaja.

---

## 6. Cara Membuktikan RLS Anda Benar

**Jangan percaya bahwa SQL sudah dijalankan. Buktikan.**

Setelah menjalankan RLS, uji dengan tiga perintah ini:

### Uji 1 — Baca harus BERHASIL

```bash
curl -i "https://<PROJECT>.supabase.co/rest/v1/modul?select=*" \
  -H "apikey: <KEY>" \
  -H "Authorization: Bearer <KEY>"
```

**Harapan:** `HTTP/2 200` dengan data.

### Uji 2 — Tulis harus GAGAL

```bash
curl -i -X POST "https://<PROJECT>.supabase.co/rest/v1/modul" \
  -H "apikey: <KEY>" \
  -H "Authorization: Bearer <KEY>" \
  -H "Content-Type: application/json" \
  -d '{"slug":"uji","judul":"Uji","topik":"array","deskripsi":"tes"}'
```

**Harapan:** `401` atau `403` dengan pesan `permission denied`.

### Uji 3 — Hapus harus GAGAL

```bash
curl -i -X DELETE "https://<PROJECT>.supabase.co/rest/v1/modul?slug=eq.array-dasar" \
  -H "apikey: <KEY>" \
  -H "Authorization: Bearer <KEY>"
```

**Harapan:** GAGAL, dan data modul tetap ada.

### Jika Uji 2 atau 3 Berhasil

**JANGAN LANJUT.** Database Anda terbuka. Yang harus dilakukan:

1. Jalankan ulang blok `revoke all`
2. Pastikan tidak ada error
3. Uji lagi

---

## 7. Pertanyaan yang Sering Muncul

### Apakah RLS memperlambat aplikasi?

Tidak signifikan. RLS dievaluasi di dalam database, bukan di aplikasi. Untuk konten read-only seperti FlashStruct, dampaknya tidak terasa.

### Apakah saya perlu RLS kalau kontennya bukan rahasia?

**Ya, tetap perlu.** Alasannya bukan kerahasiaan, tapi **integritas**:

| Yang dilindungi | Contoh |
|-----------------|--------|
| Konten tidak bisa dihapus | Orang iseng menghapus semua modul |
| Konten tidak bisa diubah | Judul modul diganti spam |
| Database tidak diisi sampah | Insert 10.000 baris spam |

Konten FlashStruct memang untuk dibaca publik — tapi **bukan untuk diubah publik**.

### Apa yang terjadi kalau lupa mengaktifkan RLS?

Berdasarkan demonstrasi §3.1: seluruh konten bisa terhapus dan diganti spam dalam hitungan detik.

Supabase punya peringatan di dashboard untuk tabel tanpa RLS, tapi **peringatan bisa diabaikan**. Jangan andalkan itu.

### Apakah RLS bisa dimatikan setelah diaktifkan?

Bisa, tapi **jangan**. Kalau perlu mengubah akses, ubah policy-nya, bukan mematikan RLS.

---

## 8. Yang Perlu Anda Lakukan

Saat setup Supabase nanti:

| Langkah | Status |
|---------|--------|
| Jalankan DDL | Wajib |
| **Jalankan RLS** | **Wajib — jangan dilewati** |
| **Uji tulis harus GAGAL** | **Wajib — ini buktinya** |
| Jalankan seed | Setelah RLS terverifikasi |

**Kalau ada satu langkah yang boleh dilewatkan, itu bukan RLS.** Langkah lain bisa diulang nanti; RLS yang terlupakan bisa berakibat konten hilang.

---

## 9. Ringkasan

| Pertanyaan | Jawaban |
|------------|---------|
| Perlukah mengaktifkan RLS? | **Ya, wajib** |
| Kenapa? | Tanpa RLS, siapa pun bisa hapus/ubah konten |
| Apakah policy SELECT saja cukup? | **Tidak** — grant tulis harus dicabut |
| Apakah policy `FOR ALL` aman? | **Tidak** — itu mengizinkan tulis |
| Bagaimana membuktikan sudah benar? | Uji tulis harus **gagal** |
| Apakah memperlambat? | Tidak signifikan |
| Boleh dilewatkan? | **Tidak** |

---

## 10. Referensi

| Topik | Dokumen |
|-------|---------|
| SQL RLS lengkap | `05-SKEMA-DATABASE.md` §4.3 |
| Cara verifikasi | `05-SKEMA-DATABASE.md` §4.4 |
| Langkah setup untuk Anda | `15-SETUP-SUPABASE-UNTUK-ANDA.md` |
| Kutipan sumber resmi | `riset/01-RISET-TEKNIS.md` §3 |
