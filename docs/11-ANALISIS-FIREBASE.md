# 11 — Analisis: Firebase sebagai Pengganti Supabase

> Jawaban atas pertanyaan: **apakah bisa jika Supabase diganti dengan Firebase?**
> Status: `[ANALISIS]` · Data kuota dari `riset/02-RISET-DEPLOY-GRATIS.md`

---

## 1. Jawaban Singkat

**Bisa.** Firebase gratis (Spark Plan) mampu menampung proyek ini, dan bahkan unggul di beberapa angka.

**Tapi tidak direkomendasikan**, karena satu alasan utama: **data FlashStruct itu relasional, dan Firestore itu NoSQL.**

| Aspek | Supabase | Firebase |
|-------|----------|----------|
| Biaya | Rp0 | Rp0 |
| Kapasitas | Cukup | **Lebih longgar** |
| Kemudahan query | **Satu request** | 1 request (dengan trik) |
| Cocok untuk data relasional | **Ya, natural** | Perlu denormalisasi manual |
| Perlu kartu kredit | Tidak | Tidak |
| Pause saat idle | **Ya, risiko** | Tidak |

**Kesimpulan:** bukan soal "tidak bisa", tapi soal **biaya perawatan jangka panjang**. Firebase memaksa Anda menulis data dengan cara yang tidak alami, dan itu terasa saat konten bertambah.

---

## 2. Analisis Kapasitas: Firebase Ternyata Lebih Longgar

Ini temuan yang mengejutkan saat dihitung. Dengan penataan yang tepat, Firebase **lebih longgar** dari Supabase di beberapa aspek.

### 2.1 Konten FlashStruct Sangat Kecil

Hitungan nyata ukuran konten per modul:

| Bagian | Estimasi |
|--------|----------|
| 5 bagian modul (± 2 KB markdown per bagian) | 10 KB |
| 20 flashcard (± 500 byte per kartu) | 10 KB |
| 18 soal + opsi + penjelasan (± 800 byte per soal) | 14,4 KB |
| **Total per modul** | **± 34 KB** |
| **Total 10 modul** | **± 340 KB** |

Dibandingkan batas Firestore **1 MiB per dokumen**, satu modul hanya memakai **3,3%**. Bahkan **seluruh 10 modul sekaligus** hanya 340 KB — masih di bawah 1 MiB.

### 2.2 Ini Membuka Trik Denormalisasi

Karena kontennya kecil, **satu modul bisa disimpan sebagai SATU dokumen** Firestore, bukan dipecah ke banyak koleksi:

```
modul/{modulId}
  ├─ slug: "array-dasar"
  ├─ judul: "Dasar Array & Indeks"
  ├─ topik: "array"
  ├─ bagian: [ {judul, konten_md, urutan}, ... ]     <- array di dalam dokumen
  ├─ flashcard: [ {depan, belakang, card_type}, ... ] <- array di dalam dokumen
  └─ soal: [ {pertanyaan, opsi: [...], penjelasan}, ... ]
```

**Kenapa ini penting:** dokumentasi resmi Firestore menyatakan *"Each document read is counted as 1 read, regardless of document size."* Artinya membaca dokumen 34 KB **sama biayanya** dengan membaca dokumen 1 KB — yaitu 1 read.

### 2.3 Perbandingan Read

| Cara | Buka 1 modul | Buka 10 modul | Batas tercapai pada |
|------|--------------|---------------|---------------------|
| **Tanpa denormalisasi** (dokumen terpisah) | 44 read | 440 read | **113 perangkat baru/hari** |
| **Dengan denormalisasi** (1 modul = 1 dokumen) | 1 read | 10 read | **5.000 perangkat baru/hari** |

**Denormalisasi membuat Firestore 44x lebih efisien.** Ini membalik kesimpulan awal — dengan penataan yang tepat, kuota 50.000 read/hari sangat lega:

| Skenario | Read/hari | Pemakaian kuota |
|----------|-----------|-----------------|
| 100 mahasiswa baru × 10 modul | 1.000 | 2% |
| 500 mahasiswa baru × 10 modul | 5.000 | 10% |
| 1.000 mahasiswa baru × 10 modul | 10.000 | 20% |
| 2.000 mahasiswa baru × 10 modul | 20.000 | 40% |

Ditambah caching di `localStorage`, kunjungan ulang tidak memakan read sama sekali.

### 2.4 Perbandingan Kuota Lengkap

| Sumber daya | Supabase Free | Firestore Spark | Pemenang |
|-------------|---------------|-----------------|----------|
| Ukuran database | 500 MB | **1 GiB** | Firebase |
| Egress/bulan | 5 GB | **10 GiB** | Firebase |
| Batas request | **Tanpa batas** | 50.000 read/hari | Supabase |
| Risiko idle | **Pause 7 hari** | Tidak ada | Firebase |
| Kartu kredit | Tidak | Tidak | Seri |
| Database gratis | 2 per akun | 1 per project | Supabase |

**Catatan penting:** Firestore Spark membatasi **tepat satu database gratis per project**, dan kuota di-reset tengah malam waktu Pasifik.

---

## 3. Masalah Sebenarnya: Bukan Kuota, Tapi Model Data

Kalau kapasitas Firebase lebih longgar, kenapa tetap tidak direkomendasikan? Karena masalahnya di tempat lain.

### 3.1 Dokumentasi Firebase Sendiri Mengakuinya

Ini kutipan resmi dari dokumentasi Firestore:

> "Getting data that is naturally hierarchical might become increasingly complex as your database grows."
> — [Firestore: Structure Your Data](https://firebase.google.com/docs/firestore/manage-data/structure-data)

Struktur FlashStruct **persis** seperti itu:

```
modul → bagian_modul
modul → flashcard
modul → soal → opsi_soal
```

### 3.2 Tiga Jebakan yang Terdokumentasi

| Jebakan | Kutipan resmi | Dampak |
|---------|---------------|--------|
| **Tidak ada JOIN** | Join hanya di Enterprise edition (bukan Spark) | Harus denormalisasi manual |
| **Hapus tidak berantai** | *"Deleting a document does not delete its subcollections!"* | Menghapus modul meninggalkan data yatim |
| **Nested list tidak scalable** | *"This isn't as scalable as other options... With larger or growing lists, the document also grows, which can lead to slower document retrieval times."* | Daftar kartu tidak boleh ditanam |

### 3.3 Kontradiksi yang Harus Disadari

Ada ketegangan nyata di sini:

- **Untuk hemat kuota**, konten harus **ditanam** dalam satu dokumen (denormalisasi).
- **Untuk skalabilitas**, dokumentasi Firebase justru **memperingatkan** agar tidak menanam daftar besar dalam dokumen.

Untuk FlashStruct saat ini, kontennya cukup kecil (34 KB per modul) sehingga menanam aman. Tetapi **jika nanti menambah 10 modul lagi atau menambah fitur** (misalnya melacak jawaban per soal, riwayat per kartu), struktur ini akan mulai terasa sesak.

### 3.4 Tanpa Constraint Database

Ini yang paling sering diremehkan. Di PostgreSQL, aturan konten ditegakkan **oleh database**:

```sql
-- Supabase: database MENOLAK data yang salah
create unique index opsi_soal_satu_benar_idx
  on public.opsi_soal (soal_id)
  where benar = true;
-- Hasil uji: menolak soal dengan dua jawaban benar
```

Di Firestore, tidak ada yang setara. Security rules **tidak bisa** memvalidasi relasi antar dokumen. Artinya:

| Pemeriksaan | Supabase | Firestore |
|-------------|----------|-----------|
| Soal harus punya tepat 1 jawaban benar | Ditegakkan database | Harus dicek manual |
| Label opsi hanya A–D | `check constraint` | Tidak ada |
| Slug format valid | `check constraint` | Tidak ada |
| Format YouTube ID | `check constraint` | Tidak ada |
| Panjang maksimal kartu | `check constraint` | Tidak ada |
| Hapus modul membersihkan turunannya | `on delete cascade` | Manual |

Saat ini Anda punya **9 pemeriksa konten SQL** di `05-SKEMA-DATABASE.md` §7 yang berjalan di database. Di Firestore, semua itu harus ditulis ulang sebagai kode JavaScript, dan hanya berjalan kalau Anda ingat menjalankannya.

---

## 4. Perbandingan Kode

Kalau tetap pindah ke Firebase, ini yang berubah.

### 4.1 Contoh Query yang Sama

**Supabase — satu request, ambil semua:**

```typescript
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

**Firestore — dengan denormalisasi:**

```typescript
const doc = await getDoc(doc(db, 'modul', 'array-dasar'));
const data = doc.data();
// data.bagian, data.flashcard, data.soal sudah ada di dalamnya
```

Terlihat sama sederhananya — **selama** struktur sudah didesain untuk denormalisasi. Tapi konsekuensinya:

- Untuk menambah satu kartu, Anda harus menulis **seluruh dokumen modul** (bukan satu baris). Ini memakan 1 write, tapi berisiko menimpa perubahan bersamaan.
- Untuk mencari "kartu mana yang berisi kata X", Anda harus membaca **semua** modul lalu memfilternya di client.
- Untuk menghapus modul, Anda harus ingat menghapus dokumen-dokumen terkait.

### 4.2 Berkas yang Berubah

| Berkas | Status | Keterangan |
|--------|--------|------------|
| `lib/supabase.ts` → `lib/firebase.ts` | Tulis ulang | Init client beda total |
| `features/materi/api.ts` | Tulis ulang | PostgREST → Firestore SDK |
| `features/video/api.ts` | Tulis ulang | Sama |
| `features/flashcard/api.ts` | Tulis ulang | Sama |
| `features/quiz/api.ts` | Tulis ulang | Sama |
| `types/database.ts` | Tulis ulang | Tipe generated → tipe manual |
| `supabase/migrations/*` → `firestore.rules` | Ganti | SQL → security rules |
| `features/progres/*` | **Tetap** | `localStorage` tidak berubah |
| `features/flashcard/useSesi*` | **Tetap** | Logika murni, tidak tahu backend |
| `features/quiz/useSesi*` | **Tetap** | Sama |
| `components/*` | **Tetap** | UI tidak berubah |

**Kabar baik:** sekitar **40% kode tidak berubah** — semua logika sesi, progres, dan UI. Yang berubah hanya lapisan akses data.

### 4.3 Berkas Dokumentasi yang Berubah

| Dokumen | Dampak |
|---------|--------|
| `01-PRD.md` | Kecil — sebut "Supabase" → "Firebase" |
| `02-KURIKULUM.md` | Tidak ada — kurikulum tidak terkait backend |
| `03-DESIGN-SYSTEM.md` | Tidak ada — warna tidak terkait backend |
| `04-ARSITEKTUR-TEKNIS.md` | Besar — stack, alur data, contoh kode |
| `05-SKEMA-DATABASE.md` | **Total** — DDL/RLS/query → struktur dokumen/rules |
| `06-SPESIFIKASI-HALAMAN.md` | Kecil — beberapa contoh query |
| `07-ROADMAP.md` | Sedang — task M2 berubah |
| `08-CHECKLIST-QA.md` | Sedang — uji RLS → uji security rules |
| `09-PANDUAN-SETUP.md` | Besar — setup Supabase → Firebase |
| `10-KEPUTUSAN-DEPLOY.md` | Besar — keputusan stack berubah |

**Yang penting:** `05-SKEMA-DATABASE.md` adalah dokumen **paling rinci dan paling teruji** di seluruh proyek. Isinya sudah dijalankan di PostgreSQL 18.6 dan terbukti menolak semua operasi tulis dari role `anon`. Mengganti ke Firestore berarti membuang dokumen itu dan menulis ulang dari nol.

---

## 5. Kapan Firebase Justru Pilihan Lebih Baik

Supaya analisis ini adil, Firebase **lebih tepat** jika:

| Kondisi | Kenapa Firebase lebih baik |
|---------|---------------------------|
| Butuh autentikasi siap pakai | Firebase Auth sangat matang, banyak provider |
| Butuh realtime sync antar pengguna | Firestore punya listener realtime bawaan |
| Data tidak relasional | Misalnya hanya daftar artikel datar |
| Sudah familiar ekosistem Google | Kurva belajar lebih pendek |
| Tidak ingin risiko pause | Firestore tidak pernah pause karena idle |
| Butuh egress lebih besar | 10 GiB vs Supabase 5 GB |

**Untuk FlashStruct v1:** tidak ada satu pun kondisi itu yang berlaku. Semua data relasional, tidak ada login, tidak butuh realtime.

**Untuk FlashStruct v2** (jika nanti menambah akun pengguna): Firebase Auth bisa jadi pertimbangan. Tapi bahkan saat itu, Supabase Auth juga tersedia dan skema database saat ini **sudah siap** untuk penambahan autentikasi tanpa migrasi besar (lihat `05-SKEMA-DATABASE.md` §9.3).

---

## 6. Opsi Ketiga: Neon

Jika yang tidak disukai dari Supabase adalah **risiko pause setelah 7 hari idle**, ada alternatif yang tetap PostgreSQL:

| Aspek | Supabase | Neon |
|-------|----------|------|
| Jenis | PostgreSQL | PostgreSQL |
| Pause saat idle | Ya, 7 hari, manual unpause | **Scale to zero 5 menit, otomatis bangun** |
| Ukuran database | 500 MB | 0.5 GB |
| Egress | 5 GB/bulan | 5 GB/bulan |
| Perilaku saat limit | — | Suspend compute, **data tidak hilang** |
| Kartu kredit | Tidak | Tidak |

**Kelebihan Neon:** tidak perlu unpause manual. Database "tidur" saat tidak dipakai dan bangun otomatis saat ada request. Untuk aplikasi dengan trafik tidak teratur seperti ini, itu lebih nyaman.

**Kekurangan Neon:** tidak menyediakan REST API otomatis seperti PostgREST di Supabase. Anda perlu memanggilnya lewat serverless function atau driver khusus, yang menambah satu lapisan.

**Verdict:** tetap Supabase lebih praktis untuk proyek ini, karena PostgREST menghilangkan kebutuhan menulis backend sendiri.

---

## 7. Rekomendasi

### 7.1 Tetap Pakai Supabase

**Alasan utama:**

1. **Data relasional cocok dengan PostgreSQL.** Foreign key, JOIN, dan constraint memetakan langsung ke struktur FlashStruct.
2. **Dokumentasi skema sudah teruji.** `05-SKEMA-DATABASE.md` sudah dijalankan dan terbukti aman. Menggantinya berarti membuang kerja itu.
3. **PostgREST menghilangkan backend sendiri.** Query bertingkat satu request, tanpa serverless function.
4. **Constraint menjaga kualitas konten.** 9 pemeriksa konten berjalan di database, bukan bergantung pada disiplin manual.
5. **Kuota lebih dari cukup.** Untuk 1.000 pengunjung/bulan, Supabase Free hanya terpakai ± 4% dari kapasitas.

### 7.2 Mitigasi Risiko Pause

Risiko nyata Supabase adalah **pause setelah 7 hari idle**. Mitigasinya sederhana:

| Cara | Usaha |
|------|-------|
| Kunjungi situs seminggu sekali | Nol usaha |
| Pasang uptime monitor gratis (UptimeRobot) yang ping tiap 3 hari | 10 menit setup, sekali saja |
| Upgrade ke Pro ($25/bulan) | Hanya jika sudah serius |

**Yang perlu ditegaskan:** pause **tidak menghilangkan data**. Cukup klik "Restore project" di dashboard, dan situs kembali normal dalam beberapa menit.

### 7.3 Jika Tetap Ingin Firebase

Bisa. Tapi lakukan dengan mata terbuka:

**Yang harus Anda terima:**

- Tidak ada constraint database — validasi konten jadi tanggung jawab manual
- Tidak ada `on delete cascade` — menghapus modul perlu kode khusus
- Denormalisasi wajib — struktur dokumen harus didesain hati-hati sejak awal
- `05-SKEMA-DATABASE.md` harus ditulis ulang total
- Mencari konten lintas modul jadi mahal (harus baca semua modul)

**Yang harus diubah:**

- Tulis ulang 6 berkas lapisan data
- Tulis ulang `05-SKEMA-DATABASE.md` menjadi struktur dokumen + security rules
- Perbarui 5 dokumen lain (04, 07, 08, 09, 10)
- Perbarui task M2 di roadmap

**Estimasi tambahan:** ± 8–12 jam kerja untuk migrasi desain dan penulisan ulang dokumentasi, **sebelum** menulis kode aplikasi.

---

## 8. Ringkasan Perbandingan

| Kriteria | Supabase | Firebase | Pemenang |
|----------|----------|----------|----------|
| Biaya | Rp0 | Rp0 | Seri |
| Ukuran database | 500 MB | 1 GiB | Firebase |
| Egress | 5 GB/bln | 10 GiB/bln | Firebase |
| Batas request | Tanpa batas | 50.000 read/hari | Supabase |
| Risiko idle | Pause 7 hari | Tidak ada | Firebase |
| Query relasional | **Native** | Perlu denormalisasi | **Supabase** |
| Constraint database | **Ya, 8 jenis** | Tidak ada | **Supabase** |
| Hapus berantai | **Otomatis** | Manual | **Supabase** |
| Setup backend | **PostgREST otomatis** | Perlu SDK | **Supabase** |
| Dokumentasi siap | **Sudah teruji** | Harus ditulis ulang | **Supabase** |
| Realtime | Terbatas | **Bawaan** | Firebase |
| Auth | Ada | **Lebih matang** | Firebase |

**Untuk kebutuhan FlashStruct v1, Supabase menang di 6 dari 8 kriteria yang relevan.**

---

## 9. Yang Tidak Terverifikasi

| Klaim | Status |
|-------|--------|
| Perilaku tepat saat kuota Firestore Spark habis | Dokumentasi tidak menjelaskan apakah request gagal total atau dibatasi sebagian |
| Apakah Firestore auto-unpause saat ada request | Tidak relevan (Firestore tidak pause) |
| Batasan komersial Firebase | Tidak ditemukan batasan pada ToS yang ditinjau |
| Detail integrasi Firebase–Vercel | Tidak diriset |
| Estimasi 8–12 jam migrasi | Perkiraan, bukan hasil pengukuran |

---

## 10. Referensi Silang

| Topik | Dokumen |
|-------|---------|
| Data kuota lengkap dan kutipan sumber | `riset/02-RISET-DEPLOY-GRATIS.md` §3 |
| Keputusan stack yang berlaku | `10-KEPUTUSAN-DEPLOY.md` |
| Skema database yang sudah teruji | `05-SKEMA-DATABASE.md` |
| Arsitektur dan alur data | `04-ARSITEKTUR-TEKNIS.md` |
| Setup database | `09-PANDUAN-SETUP.md` §3 |
