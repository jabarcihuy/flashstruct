# 12 — Analisis: Neon sebagai Pengganti Supabase

> Jawaban atas pertanyaan: **bagaimana jika saya buat Neon?**
> Status: `[ANALISIS]` · Fakta dan kutipan sumber di `riset/03-RISET-NEON.md`

---

## 1. Jawaban Singkat

**Bisa, dan untuk kasus FlashStruct, Neon secara teknis justru lebih cocok.**

| Aspek | Supabase | Neon | Pemenang |
|-------|----------|------|----------|
| Jenis database | PostgreSQL | PostgreSQL | Seri |
| REST API otomatis | PostgREST | **Neon Data API** (PostgREST-compatible) | Seri |
| Query bertingkat satu request | Ya | **Ya** | Seri |
| Perilaku saat idle | **Pause 7 hari, manual resume** | **Scale to zero 5 menit, auto-bangun** | **Neon** |
| Data hilang saat idle | Tidak | Tidak | Seri |
| Ukuran database | 500 MB | 0.5 GB | Seri |
| Egress | 5 GB/bulan | 5 GB/bulan | Seri |
| Kartu kredit | Tidak perlu | Tidak perlu | Seri |
| Status API | Stabil | **GA (18 Sep 2026)** | Seri |
| Status SDK klien | Stabil | **Beta** | **Supabase** |
| Kematangan ekosistem | Lebih lama, lebih banyak contoh | Lebih baru | **Supabase** |

**Rekomendasi saya: pindah ke Neon.** Alasannya satu, tapi menentukan — lihat §2.

---

## 2. Alasan Utama: Perilaku Saat Idle

Ini pembeda yang sesungguhnya, dan untuk FlashStruct dampaknya besar.

### 2.1 Masalah dengan Supabase

Supabase Free **men-pause project setelah 7 hari tanpa aktivitas**, dan **resume harus manual dari dashboard**.

Bayangkan skenario nyata:

```
Mahasiswa belajar keras selama UAS (minggu 1-2)
        |
        v
Libur semester, tidak buka FlashStruct (minggu 3-4)
        |
        v
Semester baru, dia mau mengulang materi
        |
        v
Buka situs -> "Database unavailable"
        |
        v
Dia harus: buka dashboard Supabase -> login -> klik Restore -> tunggu
        |
        v
Dia tidak bisa melakukan ini. Dia tidak punya akun Supabase.
        |
        v
DIA PERGI DAN TIDAK KEMBALI
```

**Masalahnya bukan teknis, tapi manusiawi.** Pengguna FlashStruct tidak punya akses ke dashboard Supabase — itu milik Anda. Jadi ketika database pause, **tidak ada yang bisa memperbaikinya kecuali Anda**, dan Anda mungkin tidak tahu sampai ada yang mengeluh.

### 2.2 Cara Neon Menanganinya

Neon **scale to zero setelah 5 menit idle**, tapi **bangun otomatis saat ada request** dalam beberapa ratus milidetik.

```
Tidak ada aktivitas 5 menit -> compute tidur (hemat kuota)
        |
        v
Ada request masuk -> compute bangun otomatis
        |
        v
Response normal (dengan tambahan latensi singkat di request pertama)
        |
        v
Pengguna tidak sadar apa pun terjadi
```

**Data tidak hilang saat scale to zero.** Ini karena arsitekturnya memisahkan compute (ephemeral) dari storage (durable). Compute boleh mati berkali-kali; data tetap ada.

### 2.3 Perbandingan Langsung

| Skenario | Supabase Free | Neon Free |
|----------|---------------|-----------|
| Tidak diakses 1 minggu | Pause, perlu resume manual | Tidur, bangun otomatis |
| Tidak diakses 1 bulan | Pause, perlu resume manual | Tidur, bangun otomatis |
| Yang bisa memperbaiki | Hanya Anda (pemilik akun) | Tidak perlu diperbaiki |
| Pengguna sadar ada masalah? | Ya, situs mati | Tidak, hanya agak lambat sedetik |
| Perlu jadwal ping? | **Ya** (UptimeRobot dll.) | Tidak perlu |

**Konsekuensi praktis:** dengan Neon, Anda **tidak perlu** memasang uptime monitor atau mengingat untuk membuka situs seminggu sekali. Satu hal lebih sedikit yang bisa dilupakan.

---

## 3. Yang Perlu Diperhatikan

### 3.1 SDK Klien Masih Beta

Ini satu-satunya keunggulan nyata Supabase:

| Komponen | Status |
|----------|--------|
| Neon Data API (endpoint) | **GA** — 18 September 2026 |
| `@neondatabase/neon-js` | **Beta** (`0.7.0-beta`) |
| `@neondatabase/postgrest-js` | **Beta** (`0.2.0-beta`) |
| `@supabase/supabase-js` | Stabil (`2.116.0`) |

**Tapi risikonya bisa dihilangkan.** Karena Neon Data API adalah **HTTP biasa + PostgREST**, Anda tidak wajib memakai SDK-nya:

```typescript
// Tanpa SDK sama sekali — cukup fetch
const respons = await fetch(
  `${import.meta.env.VITE_NEON_API_URL}/modul?select=id,judul,bagian_modul(id,judul)`,
  { headers: { Accept: 'application/json' } }
);
```

**Rekomendasi: pakai `fetch` langsung, jangan pakai SDK beta.** Alasannya:

1. Menghilangkan ketergantungan pada paket yang API-nya masih bisa berubah
2. Lebih sedikit kode yang masuk bundle (hemat ± 25 KB)
3. PostgREST sudah terdokumentasi sangat baik, dan sintaksnya stabil
4. Jika nanti SDK sudah stabil, migrasi ke SDK mudah karena keduanya bicara protokol yang sama

### 3.2 Ketegangan Dokumentasi yang Perlu Diuji

Ada satu hal yang **belum terverifikasi** dan perlu Anda uji sendiri sebelum saya menulis banyak kode:

> Satu halaman dokumentasi Neon menyatakan akses anonim "tetap memakai JWT", halaman lain menyatakan role `anonymous` dipakai untuk "request tanpa header Authorization".

**Ini krusial** karena seluruh arsitektur tanpa-login bergantung padanya. Cara mengujinya sederhana, satu perintah `curl` (lihat §6.3).

**Rencana mitigasi:** kalau ternyata butuh header, ada dua jalan keluar:
1. Aktifkan opsi `allowAnonymous: true` di konfigurasi Data API
2. Pakai role `anonymous` dengan policy yang mengizinkan

Keduanya masih tanpa login pengguna — hanya berbeda cara konfigurasinya.

### 3.3 Rate Limit Tidak Terdokumentasi

Neon **tidak mempublikasikan angka rate limit** untuk Data API. Untuk 1.000 pengunjung/bulan ini hampir pasti tidak masalah, tapi dicatat sebagai ketidakpastian.

### 3.4 Lebih Sedikit Contoh di Internet

Supabase punya lebih banyak tutorial dan contoh. Kalau Anda mencari bantuan, jawabannya lebih mudah ditemukan.

**Mitigasi:** karena Neon Data API kompatibel PostgREST, **semua tutorial PostgREST berlaku**. Anda tinggal mengganti URL dan nama role.

---

## 4. Yang Tetap Sama

Kabar baiknya: **sebagian besar pekerjaan yang sudah dilakukan tetap berlaku.**

### 4.1 Yang Tidak Berubah Sama Sekali

| Aset | Alasan |
|------|--------|
| **DDL skema** (`05-SKEMA-DATABASE.md` §3) | Sama-sama PostgreSQL — 100% berlaku |
| **Constraint** (check, unique, foreign key) | Sama |
| **`on delete cascade`** | Sama |
| **Pemeriksa konten** (§7) | Sama |
| **Semua kode React** | Tidak tahu backend apa yang dipakai |
| **Semua test** (67 lulus) | Tidak terpengaruh |
| **Design system & token** | Tidak terpengaruh |
| **Kurikulum** | Tidak terpengaruh |

### 4.2 Yang Berubah

| Aset | Perubahan | Besar |
|------|-----------|-------|
| **RLS policy** | Role `anon` → `anonymous` | Kecil |
| **Client** | `@supabase/supabase-js` → `fetch` | Kecil |
| **Environment variable** | `VITE_SUPABASE_URL` → `VITE_NEON_API_URL` | Kecil |
| **Query API** | `.from().select()` → `fetch` + URL | Sedang |
| **Tipe database** | Tetap sama (ditulis manual) | Tidak ada |

**Contoh perubahan query:**

```typescript
// Sebelum (Supabase)
const { data, error } = await supabase
  .from('modul')
  .select(`id, slug, judul, bagian_modul ( id, judul, konten_md )`)
  .eq('slug', 'array-dasar')
  .single();

// Sesudah (Neon, pakai fetch)
const respons = await fetch(
  `${API}/modul?select=id,slug,judul,bagian_modul(id,judul,konten_md)&slug=eq.array-dasar`,
  { headers: { Accept: 'application/vnd.pgrst.object+json' } }
);
const data = await respons.json();
```

**Perhatikan:** sintaks `bagian_modul(...)` untuk embedding **sama persis**, karena keduanya PostgREST. Hanya cara memanggilnya yang berbeda.

### 4.3 Estimasi Tambahan

| Pekerjaan | Estimasi |
|-----------|----------|
| Sesuaikan RLS untuk role `anonymous` | 30 menit |
| Buat wrapper `fetch` untuk query | 1,5 jam |
| Sesuaikan dokumentasi (05, 09, 10) | 1 jam |
| Uji apakah akses anonim butuh header | 15 menit |
| **Total** | **± 3 jam** |

Ini **jauh lebih murah** dibanding migrasi ke Firebase (8–12 jam) karena Neon tetap PostgreSQL — skema, constraint, dan cascade tidak perlu diubah sama sekali.

---

## 5. Perbandingan Tiga Opsi

| Kriteria | Supabase | Neon | Firebase |
|----------|----------|------|----------|
| Jenis | PostgreSQL | PostgreSQL | NoSQL |
| REST API otomatis | PostgREST | Neon Data API | Tidak ada |
| Query bertingkat | Satu request | Satu request | 3-4 request |
| Constraint database | Ya | Ya | Tidak |
| Hapus berantai | Otomatis | Otomatis | Manual |
| Idle | **Pause 7 hari, manual** | **Tidur 5 menit, auto** | Tidak ada |
| SDK | Stabil | **Beta** | Stabil |
| Skema bisa dipakai ulang | — | **100%** | 0% |
| Dokumentasi siap | Ya | **Ya, 90% berlaku** | Harus tulis ulang |
| Biaya | Rp0 | Rp0 | Rp0 |
| **Untuk FlashStruct** | Baik | **Paling cocok** | Kurang cocok |

**Urutan rekomendasi:**

1. **Neon** — perilaku idle paling cocok untuk aplikasi belajar sporadis
2. **Supabase** — paling matang, tapi risiko pause manual mengganggu pengguna
3. **Firebase** — tidak cocok karena NoSQL

---

## 6. Langkah Jika Memilih Neon

### 6.1 Membuat Project

1. Buka [neon.tech](https://neon.tech), daftar (bisa pakai GitHub)
2. Buat project baru
3. **Pilih region:** Singapore (terdekat dari Indonesia)
4. Catat dua hal:
   - **Connection string** (untuk menjalankan SQL migrasi — ini RAHASIA)
   - **Data API URL** (untuk browser — ini aman diekspos)

### 6.2 Mengaktifkan Data API

1. Di Neon Console, buka project
2. Pilih **Data API**
3. Aktifkan untuk database Anda
4. Salin **Data API URL** — bentuknya seperti:
   ```
   https://ep-xxx.apirest.ap-southeast-1.aws.neon.tech/neondb/rest/v1
   ```

### 6.3 UJI KRUSIAL — Lakukan Sebelum Lanjut

**Ini langkah paling penting.** Uji apakah akses anonim benar-benar bekerja tanpa header:

```bash
# Uji 1: akses TANPA header Authorization
curl -i "https://<DATA_API_URL>/modul?select=*"

# Harapan: HTTP 200 dengan data (array kosong jika belum ada data)
# Jika 401/403: butuh konfigurasi tambahan (lihat di bawah)
```

Jika Uji 1 gagal, aktifkan akses anonim:

```sql
-- Buat role anonymous (jika belum ada)
-- lalu beri izin baca
grant usage on schema public to anonymous;
grant select on all tables in schema public to anonymous;
```

Lalu uji lagi. Jika masih gagal, aktifkan `allowAnonymous` di konfigurasi Data API Neon.

### 6.4 Menjalankan Skema

Jalankan SQL dari `05-SKEMA-DATABASE.md` §3 lewat Neon SQL Editor, dengan satu perubahan di bagian RLS:

```sql
-- GANTI: from anon, authenticated
-- MENJADI: from anonymous

revoke all on table
  public.modul, public.bagian_modul, public.video,
  public.flashcard, public.soal, public.opsi_soal
from anonymous;

grant select on table
  public.modul, public.bagian_modul, public.video,
  public.flashcard, public.soal, public.opsi_soal
to anonymous;

create policy "modul dapat dibaca publik"
  on public.modul for select to anonymous using (true);
-- ... dan seterusnya untuk tabel lain
```

### 6.5 Uji Keamanan (Wajib)

Sama seperti Supabase, **buktikan tulis ditolak**:

```bash
# Uji tulis — HARUS GAGAL
curl -X POST "https://<DATA_API_URL>/modul" \
  -H "Content-Type: application/json" \
  -d '{"slug":"uji","judul":"Uji","topik":"array","deskripsi":"tes"}'

# Harapan: 401 / 403 / permission denied
```

**Jika berhasil (data masuk), JANGAN LANJUT.** Periksa ulang `revoke`.

### 6.6 Environment Variable

```bash
# .env.local

# Data API URL — aman diekspos ke browser
VITE_NEON_API_URL=https://ep-xxx.apirest.ap-southeast-1.aws.neon.tech/neondb/rest/v1

# JANGAN taruh connection string di sini!
# DATABASE_URL=postgresql://... <- ini RAHASIA, hanya untuk migrasi
```

**Peringatan penting:** connection string Neon memberi **akses penuh dan melewati RLS**. Jangan pernah memasukkannya ke `.env.local` yang dipakai Vite, karena semua variabel berawalan `VITE_` akan ikut ke bundle browser.

---

## 7. Perbandingan Keamanan

| Aspek | Supabase | Neon |
|-------|----------|------|
| Yang diekspos ke browser | `anon` key (JWT) | Data API URL |
| Apakah itu rahasia? | Tidak | Tidak |
| Apa yang melindungi | RLS | RLS |
| Role publik | `anon` | `anonymous` |
| Ada key yang **tidak boleh** diekspos? | `service_role` | **Connection string** |
| Risiko jika salah ekspos | Seluruh database bisa diubah | **Seluruh database bisa diubah** |

**Sama-sama bergantung pada RLS.** Baik Supabase maupun Neon, jika RLS tidak aktif dan grant tulis tidak dicabut, siapa pun bisa menghapus konten.

**Perbedaan penting:** di Supabase, key `anon` **memang dirancang** untuk diekspos. Di Neon, yang diekspos adalah URL tanpa kredensial — secara konsep lebih bersih, tapi **connection string** justru jauh lebih berbahaya jika bocor (karena melewati RLS sepenuhnya).

**Aturan untuk Neon:** connection string hanya dipakai di terminal untuk menjalankan migrasi. **Jangan pernah** memasukkannya ke file yang dibaca Vite.

---

## 8. Rekomendasi

### 8.1 Pindah ke Neon

**Alasan utama:** perilaku idle. Supabase pause 7 hari dengan resume manual menciptakan titik gagal yang tidak bisa diperbaiki pengguna. Neon bangun otomatis.

**Alasan pendukung:**
- Skema, constraint, dan cascade bisa dipakai **100% tanpa perubahan**
- Biaya tetap Rp0
- Data API sudah GA dan PostgREST-compatible
- Tidak perlu uptime monitor

**Yang harus diterima:**
- SDK klien masih beta → **mitigasi: pakai `fetch`, jangan SDK**
- Lebih sedikit tutorial → **mitigasi: tutorial PostgREST berlaku**
- Perlu 3 jam kerja penyesuaian

### 8.2 Jika Tetap Pilih Supabase

Bisa, tapi lakukan ini:

1. **Pasang uptime monitor** (UptimeRobot gratis) yang ping tiap 3 hari
2. Dokumentasikan di README bahwa database bisa pause
3. Terima bahwa ada kemungkinan pengguna menemukan situs mati

### 8.3 Yang Tidak Berubah dari Keputusan Sebelumnya

| Keputusan | Tetap berlaku? |
|-----------|----------------|
| PostgreSQL, bukan NoSQL | Ya |
| Hosting Vercel Hobby | Ya |
| Tanpa login | Ya |
| Progres di localStorage | Ya |
| Tidak memakai Docker | Ya |
| Skema database yang sudah teruji | **Ya, 100%** |

---

## 9. Yang Tidak Terverifikasi

| Klaim | Status |
|-------|--------|
| Apakah akses anonim Neon benar-benar bekerja tanpa header | **Perlu diuji dengan `curl`** |
| Rate limit Data API Neon | Tidak dipublikasikan |
| Latensi Data API saat compute bangun dari tidur | Tidak dipublikasikan |
| Apakah "100% PostgREST compatible" mencakup semua fitur lanjutan | Tidak diverifikasi independen |
| Kapan SDK Neon keluar dari beta | Tidak ada roadmap publik |
| Apakah Data API otomatis aktif di preview deployment Vercel | Tidak terverifikasi |

---

## 10. Keputusan yang Perlu Anda Ambil

| Pilihan | Konsekuensi |
|---------|-------------|
| **A. Pindah ke Neon** | Perlu buat akun Neon + 3 jam penyesuaian. Tidak perlu uptime monitor. Idle aman. |
| **B. Tetap Supabase** | Tidak perlu kerja tambahan, tapi harus pasang uptime monitor dan terima risiko pause |
| **C. Selesaikan M2-M3 dulu dengan PostgreSQL lokal** | Tunda keputusan database sampai kode lebih matang |

**Saran saya: pilih A.** Alasannya bukan karena Neon lebih unggul secara umum, tapi karena **perilaku idle-nya menghilangkan satu titik gagal yang tidak bisa diperbaiki pengguna.** Untuk aplikasi belajar yang dipakai sporadis, itu penting.

Kalau Anda setuju, langkah pertama adalah: buat project Neon, lalu **jalankan uji `curl` di §6.3** dan laporkan hasilnya ke saya. Setelah itu saya bisa langsung menyesuaikan dokumentasi dan melanjutkan M2.

---

## 11. Referensi Silang

| Topik | Dokumen |
|-------|---------|
| Fakta lengkap dan kutipan sumber | `riset/03-RISET-NEON.md` |
| Skema database yang bisa dipakai ulang | `05-SKEMA-DATABASE.md` |
| Keputusan stack sebelumnya | `10-KEPUTUSAN-DEPLOY.md` |
| Analisis Firebase | `11-ANALISIS-FIREBASE.md` |
| Setup dan deploy | `09-PANDUAN-SETUP.md` |
