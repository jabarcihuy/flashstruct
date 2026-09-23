# 01 — Product Requirements Document (PRD)

> **FlashStruct** — Platform pembelajaran Struktur Data berbasis flashcard
> Status: `[FINAL]` · Versi: 1.0 · Dokumen ini adalah sumber kebenaran untuk visi dan cakupan produk.

---

## 1. Ringkasan Eksekutif

### 1.1 Masalah

Mahasiswa Teknologi Informasi menghadapi dua masalah yang saling bertolak belakang:

1. **Struktur Data adalah mata kuliah dengan tingkat kegagalan tinggi.** Materi seperti pointer dan manajemen memori tidak bisa dipahami hanya dengan membaca sekali. Butuh pengulangan.

2. **Budaya "langsung ngoding" membuat hafalan dianggap tidak perlu.** Mahasiswa mengandalkan AI dan mesin pencari untuk mengingat sintaks, lalu gagal saat ujian tulis atau saat diminta menjelaskan kodenya sendiri di wawancara kerja.

Akibatnya muncul pola yang mudah dikenali: mahasiswa bisa menyalin kode linked list dari internet, tetapi tidak bisa menjawab "apa yang terjadi pada memori saat `delete current` dipanggil?"

### 1.2 Solusi

FlashStruct adalah aplikasi web yang **memaksa tiga tahap pembelajaran berurutan** untuk setiap modul:

```
    ┌─────────────┐      ┌──────────────┐      ┌─────────────┐
    │  1. PAHAMI  │ ───► │ 2. HAFALKAN  │ ───► │ 3. BUKTIKAN │
    │             │      │              │      │             │
    │ Modul tulis │      │  Flashcard   │      │    Quiz     │
    │  + Video    │      │  (flip+SR)   │      │  (PG+trace) │
    └─────────────┘      └──────────────┘      └─────────────┘
         Baca              Ingat                Uji
```

Tahap berikutnya **terkunci** sampai tahap sebelumnya selesai. Ini bukan sekadar fitur — ini inti dari metode pembelajarannya.

### 1.3 Yang Membuat FlashStruct Berbeda

| Aspek | Platform belajar biasa | FlashStruct |
|-------|------------------------|-------------|
| Urutan | Bebas, user pilih sendiri | **Terkunci berurutan** — pahami → hafalkan → buktikan |
| Fokus | Video saja | **Modul tulis + video + flashcard + quiz** |
| Pengulangan | Tidak ada | **Spaced repetition sederhana** berbasis tingkat kesulitan kartu |
| Cakupan | Semua topik, dangkal | **Satu mata kuliah, sangat dalam** (array, struct, pointer) |
| Contoh kode | Satu bahasa | **C++ dan Python berdampingan** |
| Kunci jawaban | Sering disembunyikan | **Terbuka** — tujuannya belajar, bukan menyeleksi |

### 1.4 Visi

> Menjadi alasan mahasiswa TI percaya bahwa **hafalan dan praktik bukan dua hal yang bertentangan** — dan membuktikannya lewat satu mata kuliah yang paling menantang: Struktur Data.

---

## 2. Target Pengguna

### 2.1 Persona Utama — "Mahasiswa yang Sedang Ambil Struktur Data"

| Atribut | Deskripsi |
|---------|-----------|
| **Nama fiktif** | Rani |
| **Usia** | 18–21 tahun |
| **Status** | Mahasiswa TI semester 2–3 |
| **Konteks** | Sedang mengambil mata kuliah Struktur Data. UTS/UAS sebentar lagi |
| **Perangkat** | Laptop untuk belajar serius, HP untuk mengulang saat senggang |
| **Kemampuan teknis** | Bisa menulis program sederhana. Sudah pernah dengar pointer, tapi belum paham benar |
| **Masalah** | "Aku bisa baca kodenya, tapi kalau disuruh tulis dari nol, aku blank." |
| **Tujuan** | Lulus mata kuliah dengan nilai baik, dan benar-benar paham supaya tidak kesulitan di mata kuliah lanjutan |

**Perilaku yang harus didukung:**

- Belajar dalam sesi pendek 15–30 menit, sering, di sela jadwal kuliah.
- Mengulang materi lama sebelum ujian.
- Belajar di HP saat menunggu kelas, di laptop saat serius.
- Ingin tahu **seberapa jauh** progresnya tanpa harus mengingat-ingat sendiri.

**Yang membuat frustrasi:**

- Harus login dan verifikasi email hanya untuk mulai belajar.
- Situs yang berat dan lambat di HP.
- Materi yang terlalu banyak teks tanpa inti yang jelas.
- Tidak tahu bagian mana yang masih lemah.

### 2.2 Persona Sekunder — "Dosen / Asisten Dosen"

| Atribut | Deskripsi |
|---------|-----------|
| **Kebutuhan** | Materi flashcard yang bisa dipakai sebagai tugas mandiri mahasiswa |
| **Cara pakai** | Memberikan tautan FlashStruct, mahasiswa belajar mandiri |
| **Batasan v1** | **Tidak ada panel admin.** Konten diisi langsung ke database oleh pengembang |

### 2.3 Bukan Target Pengguna (v1)

Menyatakan siapa yang **bukan** target sama pentingnya dengan menyatakan siapa yang target, agar cakupan tidak melebar:

- **Siswa SMA / pemula total.** Materi mengasumsikan pembaca sudah pernah menulis program.
- **Praktisi profesional.** Ini bukan buku referensi.
- **Pembelajar visual murni / anak-anak.** Desainnya teknis dan padat, bukan bergambar.
- **Pengguna yang butuh sertifikat.** v1 tidak menerbitkan sertifikat apa pun.

---

## 3. Tiga Tahap Pembelajaran (Fitur Inti)

Ini adalah jantung produk. Detail teknis ada di `06-SPESIFIKASI-HALAMAN.md`, tetapi aturan bisnisnya ditetapkan di sini.

### Tahap 1 — Pahami (Materi)

**Yang dilihat pengguna:** Modul tulis dengan penjelasan, diagram, tabel perbandingan, dan blok kode C++/Python. Video pendukung tersedia di halaman terpisah.

**Aturan:**

| Aturan | Detail |
|--------|--------|
| Kelengkapan | Modul dianggap selesai jika pengguna menekan "Tandai Selesai" **dan** sudah membuka minimal 80% bagian modul |
| Video | **Opsional.** Tidak memblokir progres |
| Contoh kode | Setiap konsep penting menyediakan tab C++ dan Python |
| Estimasi waktu | Ditampilkan di kartu modul, misalnya "± 12 menit baca" |

**Mengapa 80% dan bukan 100%:** memaksa scroll sampai dasar membuat pengguna yang sudah paham menjadi frustrasi. 80% cukup untuk memastikan materi benar-benar dibaca, bukan sekadar dibuka.

### Tahap 2 — Hafalkan (Flashcard)

**Yang dilihat pengguna:** Kartu yang bisa dibalik. Sisi depan berisi pertanyaan atau istilah, sisi belakang berisi jawaban.

**Aturan:**

| Aturan | Detail |
|--------|--------|
| Dek | Kartu dikelompokkan per modul |
| Sesi | Satu sesi = maksimal 20 kartu, dipilih dari kartu yang paling perlu diulang |
| Penilaian diri | Setelah membalik kartu, pengguna memilih **"Lupa"** atau **"Ingat"** |
| Pengulangan | Kartu "Lupa" **muncul kembali di akhir sesi yang sama** (satu putaran ulang) |
| Kelulusan | Deck selesai jika **semua kartu** minimal sekali ditandai "Ingat" |
| Progres | Disimpan di `localStorage` |

**Algoritma pengurutan (versi sederhana, sengaja tidak rumit):**

```
Urutan prioritas kartu dalam satu sesi:
  1. Kartu dengan status "Lupa" paling sering     (paling tinggi)
  2. Kartu yang belum pernah dilihat
  3. Kartu dengan status "Ingat" paling lama tidak dilihat
  4. Kartu yang sudah sering "Ingat"              (paling rendah)
```

Ini bukan SM-2 penuh seperti Anki. Kesederhanaan ini disengaja: algoritma yang tidak dipahami pengguna akan terasa seperti keacakan. Dengan aturan di atas, mahasiswa selalu bisa menjawab "kenapa kartu ini muncul lagi?" — karena dia sebelumnya menandainya "Lupa".

**Mengapa penilaian diri, bukan pilihan ganda:** flashcard yang memaksa mengingat tanpa bantuan pilihan akan menghasilkan memori yang jauh lebih kuat. Ini didukung temuan riset *testing effect* — tapi lebih penting, ini sesuai dengan premis produk: hafalan yang jujur.

### Tahap 3 — Buktikan (Quiz)

**Yang dilihat pengguna:** Serangkaian soal dengan progres jelas dan hasil di akhir.

**Aturan:**

| Aturan | Detail |
|--------|--------|
| Jumlah soal | 10 soal per quiz, diambil acak dari bank soal modul |
| Tipe soal | Pilihan ganda (4 opsi) + tracing kode (menentukan output) |
| Umpan balik | **Segera setelah menjawab** — benar/salah plus penjelasan |
| Batas waktu | **Tidak ada.** Ini alat belajar, bukan ujian |
| Kelulusan | Nilai ≥ 70 |
| Percobaan ulang | Tidak terbatas. Soal diacak ulang setiap percobaan |
| Hasil | Menampilkan nilai, rincian per soal, dan **daftar topik yang masih lemah** |

**Mengapa umpan balik langsung dan bukan di akhir:** menunggu sampai akhir untuk tahu jawaban benar membuat momen belajar hilang. Mengetahui kesalahan tepat setelah terjadi adalah saat paling efektif untuk memperbaiki pemahaman.

**Mengapa tanpa batas waktu:** batas waktu mengubah latihan menjadi ujian, memicu kecemasan, dan mendorong menebak. Tujuannya adalah pemahaman, bukan kecepatan.

**Mengapa nilai ≥ 70 dan bukan 100:** ambang yang terlalu tinggi memaksa pengulangan tanpa akhir untuk kesalahan kecil. 70 berarti "sebagian besar sudah paham, sisanya perlu diulang".

---

## 4. Daftar Fitur

Prioritas menggunakan skala MoSCoW: **M** = Must have, **S** = Should have, **C** = Could have, **W** = Won't have (v1).

### 4.1 Fitur Fungsional

| ID | Fitur | Prioritas | Deskripsi |
|----|-------|-----------|-----------|
| F-01 | Halaman Home | M | Landing page: penjelasan produk, cara kerja 3 tahap, tombol mulai |
| F-02 | Halaman Dashboard | M | Ringkasan progres: modul selesai, akurasi quiz, kartu dikuasai, rekomendasi lanjut |
| F-03 | Halaman Materi | M | Daftar modul + halaman baca modul dengan navigasi antar-bagian |
| F-04 | Halaman Video | M | Galeri video pendukung, tersemat dari YouTube, terkelompok per topik |
| F-05 | Halaman Soal (Flashcard) | M | Sesi flashcard dengan animasi flip, penilaian diri, dan ulangan kartu "Lupa" |
| F-06 | Halaman Soal (Quiz) | M | Quiz 10 soal dengan umpan balik langsung dan hasil akhir |
| F-07 | Penguncian Tahap | M | Tahap 2 terkunci sampai Tahap 1 selesai; Tahap 3 terkunci sampai Tahap 2 selesai |
| F-08 | Pelacakan Progres | M | Simpan status modul, kartu dikuasai, riwayat quiz di `localStorage` |
| F-09 | Rekomendasi Belajar | S | Dashboard menyarankan langkah berikutnya berdasarkan progres |
| F-10 | Pencarian Materi | S | Cari modul dan kartu berdasarkan kata kunci |
| F-11 | Mode Gelap / Terang | S | Ikut preferensi sistem, dapat diubah manual |
| F-12 | Reset Progres | S | Hapus semua progres dengan konfirmasi ganda |
| F-13 | Ekspor / Impor Progres | C | Unduh progres sebagai JSON untuk pindah perangkat |
| F-14 | Panel Admin | W | Pengelolaan konten lewat UI |
| F-15 | Akun Pengguna | W | Registrasi, login, sinkronisasi lintas perangkat |
| F-16 | Peringkat / Sosial | W | Leaderboard, berbagi pencapaian |

### 4.2 Fitur Non-Fungsional

| ID | Aspek | Target | Alasan |
|----|-------|--------|--------|
| N-01 | Performa | FCP < 1.8s pada 4G | Mahasiswa sering membuka di jaringan kampus yang lambat |
| N-02 | Performa | Bundle awal < 200 KB gzip | Muat cepat di HP kelas menengah |
| N-03 | Aksesibilitas | Kontras ≥ 4.5:1 | Sudah diverifikasi di `03-DESIGN-SYSTEM.md` |
| N-04 | Aksesibilitas | Navigasi keyboard penuh | Flashcard harus bisa dibalik dengan Enter/Space |
| N-05 | Aksesibilitas | `prefers-reduced-motion` dihormati | Animasi flip bisa memicu motion sickness |
| N-06 | Responsif | 375px – 1440px tanpa scroll horizontal | Dari HP kecil sampai monitor lebar |
| N-07 | Offline | Halaman terakhir tetap terbaca | Service worker cache untuk konten yang sudah dibuka |
| N-08 | Ketahanan | Data `localStorage` tidak korup | Validasi skema dengan Zod saat membaca |
| N-09 | Privasi | Tanpa pelacakan pihak ketiga | Sesuai target pengguna mahasiswa |
| N-10 | SEO | Meta tag per halaman, sitemap | Supaya bisa ditemukan lewat pencarian |

---

## 5. Arsitektur Informasi

### 5.1 Peta Navigasi

```
┌──────────────────────────────────────────────────────────────┐
│  FLASHSTRUCT                                   [Tema]        │
├──────────────────────────────────────────────────────────────┤
│  Home  ·  Dashboard  ·  Materi  ·  Video  ·  Soal            │
└──────────────────────────────────────────────────────────────┘

HOME  (/)
  └─► Penjelasan premis, diagram 3 tahap, CTA "Mulai Belajar"

DASHBOARD  (/dashboard)
  ├─► Kartu ringkasan: Modul selesai · Kartu dikuasai · Akurasi quiz
  ├─► Rekomendasi: "Lanjutkan: Pointer — Tahap 2 (Flashcard)"
  └─► Daftar semua modul dengan status 3 tahap

MATERI  (/materi)
  ├─► Daftar modul (filter: Array / Struct / Pointer)
  └─► /materi/:slug
        ├─► Isi modul (bagian-bagian)
        ├─► Tandai Selesai
        └─► Tombol "Lanjut ke Flashcard" (aktif jika selesai)

VIDEO  (/video)
  └─► Galeri video terkelompok per topik
        └─► Modal pemutar tersemat

SOAL  (/soal)
  ├─► Pemilih mode: Flashcard | Quiz
  ├─► /soal/flashcard/:modulSlug
  │     └─► Sesi kartu → Ringkasan sesi
  └─► /soal/quiz/:modulSlug
        └─► Soal 1..10 → Hasil + analisis topik lemah
```

### 5.2 Hirarki Konten

```
Mata Kuliah: Struktur Data
│
├── Topik: Array
│   ├── Modul: Dasar Array & Indeks
│   ├── Modul: Array Multidimensi
│   └── Modul: Array Dinamis (vector / list)
│
├── Topik: Struct
│   ├── Modul: Mendefinisikan Struct
│   ├── Modul: Nested Struct & Array of Struct
│   └── Modul: Padding, Alignment & sizeof
│
└── Topik: Pointer
    ├── Modul: Dasar Pointer & Alamat Memori
    ├── Modul: Pointer & Array (aritmetika pointer)
    ├── Modul: Pointer ke Struct (arrow operator)
    └── Modul: Alokasi Memori Dinamis
```

Setiap modul memiliki: 1 modul tulis, 0–3 video, tepat 10 flashcard, dan tepat 10 soal quiz.

Total konten v1: **10 modul · 100 flashcard · 100 soal** (rincian di `02-KURIKULUM.md` §2).

---

## 6. Kriteria Keberhasilan

### 6.1 Kriteria Rilis (Definition of Done)

Proyek dinyatakan selesai jika **semua** poin berikut terpenuhi:

- [ ] Kelima halaman (Dashboard, Home, Materi, Video, Soal) berfungsi penuh
- [ ] Ketiga tahap terkunci dengan benar dan tidak bisa dilewati
- [ ] Progres bertahan setelah browser ditutup dan dibuka kembali
- [ ] Semua 10 modul terisi konten lengkap
- [ ] Tidak ada error di console pada semua alur utama
- [ ] Lulus seluruh checklist di `08-CHECKLIST-QA.md`
- [ ] Dapat diakses publik lewat URL

### 6.2 Metrik Pembelajaran (di luar v1)

Ini dicatat untuk konteks, **tidak diukur di v1** karena membutuhkan autentikasi:

| Metrik | Target | Kenapa penting |
|--------|--------|----------------|
| Rasio penyelesaian modul | > 60% | Mengukur apakah konten menarik |
| Rata-rata nilai quiz percobaan ke-2 | Naik ≥ 15 poin dari ke-1 | Mengukur apakah umpan balik efektif |
| Retensi 7 hari | > 30% kembali dalam seminggu | Mengukur apakah kebiasaan terbentuk |

---

## 7. Batasan dan Asumsi

### 7.1 Batasan Teknis

| Batasan | Dampak | Mitigasi |
|---------|--------|----------|
| Tanpa autentikasi | Progres terikat satu browser | Ekspor/impor JSON (F-13); dokumentasikan dengan jelas |
| `localStorage` maks ±5 MB | Cukup untuk progres teks, tidak untuk video | Progres hanya menyimpan ID dan angka, bukan konten |
| Supabase free tier di-pause setelah 7 hari idle | Situs gagal memuat konten jika di-pause | Pengunjung rutin mencegah pause; jadwalkan ping jika perlu |
| Kunci jawaban terekspos di client | Pengguna teknis bisa melihat jawaban | Disadari dan diterima untuk aplikasi edukatif |
| Video disemat dari YouTube | Bergantung pada ketersediaan pihak ketiga | Video bersifat opsional, tidak memblokir progres |

### 7.2 Asumsi

- Pengguna memiliki koneksi internet untuk memuat konten pertama kali.
- Pengguna menggunakan browser modern (Chrome/Edge/Firefox/Safari versi 2 tahun terakhir).
- Konten disusun oleh pengembang, bukan diunggah pengguna.
- Mata kuliah Struktur Data di kampus target mencakup array, struct, dan pointer dengan bahasa C++ dan/atau Python.

---

## 8. Risiko

| Risiko | Kemungkinan | Dampak | Mitigasi |
|--------|-------------|--------|----------|
| Konten tidak lengkap saat tenggat | Sedang | Tinggi | Selesaikan 3 modul inti dulu (satu per topik), sisanya menyusul |
| Pengguna merasa terkunci itu menyebalkan | Sedang | Sedang | Tombol lanjut selalu terlihat meski terkunci, dengan penjelasan alasan |
| `localStorage` terhapus, progres hilang | Sedang | Sedang | Peringatan jelas + fitur ekspor JSON |
| Supabase free tier di-pause | Rendah | Tinggi | Pengunjung rutin; rencanakan ping terjadwal |
| Animasi flip membuat pusing | Rendah | Sedang | Wajib hormati `prefers-reduced-motion` |
| Cakupan melebar ke topik lain | Tinggi | Sedang | Tegakkan Non-Goals di bawah |

---

## 9. Non-Goals (v1)

Secara eksplisit **tidak** akan dikerjakan di v1. Ini bukan "belum sempat", tapi keputusan sadar untuk menjaga fokus:

| Tidak dikerjakan | Alasan |
|------------------|--------|
| Topik di luar array, struct, pointer | Fokus adalah kedalaman, bukan cakupan. Menambah topik berarti mengurangi kualitas |
| Sistem akun & sinkronisasi | Menambah kompleksitas besar (autentikasi, keamanan, migrasi) untuk manfaat yang belum terbukti |
| Panel admin | Konten diisi langsung ke database; UI admin hanya berguna jika ada banyak penyusun konten |
| Fitur sosial, komentar, forum | Membutuhkan moderasi dan autentikasi |
| Aplikasi mobile native | Web responsif sudah cukup untuk kebutuhan |
| Gamifikasi (poin, lencana, level) | Berisiko mengalihkan fokus dari belajar ke mengumpulkan poin |
| Sertifikat | Di luar cakupan alat belajar mandiri |
| Dukungan bahasa Inggris | Target pengguna adalah mahasiswa Indonesia |
| Editor kode interaktif | Kompleks dan berat; tracing kode secara statis sudah cukup untuk v1 |
| AI tutor / chatbot | Menambah biaya dan kompleksitas; belum ada bukti dibutuhkan |

---

## 10. Perencanaan Versi Berikutnya (di luar v1)

Dicatat sebagai arah, bukan komitmen:

| Versi | Fokus | Prasyarat |
|-------|-------|-----------|
| v1.1 | Topik tambahan: Linked List, Stack, Queue | Struktur konten v1 terbukti berjalan |
| v1.2 | Editor kode dengan eksekusi terisolasi | Riset keamanan sandbox |
| v2.0 | Akun pengguna + sinkronisasi lintas perangkat | Keputusan untuk menambah autentikasi |
| v2.1 | Panel admin untuk dosen | Setelah ada lebih dari satu penyusun konten |
| v3.0 | Analitik pembelajaran adaptif | Data penggunaan terkumpul |

---

## 11. Pertanyaan yang Belum Terjawab

Dicatat jujur agar tidak terlupakan:

| Pertanyaan | Dampak jika salah | Kapan harus dijawab |
|------------|-------------------|---------------------|
| Apakah 10 modul cukup untuk satu mata kuliah penuh? | Mungkin perlu menambah menjadi 14–16 modul | Setelah 3 modul pertama selesai, evaluasi waktu penyusunan |
| Apakah ambang 80% untuk "modul selesai" tepat? | Terlalu tinggi = frustrasi, terlalu rendah = tidak efektif | Uji ke 3–5 mahasiswa setelah Tahap 1 jadi |
| Apakah 20 kartu per sesi tidak terlalu banyak? | Sesi terasa panjang, pengguna berhenti di tengah | Uji setelah Tahap 2 jadi |
| Apakah sumber video tersedia dengan kualitas cukup? | Perlu membuat video sendiri (beban besar) | Sebelum menyusun konten video |
| Perlukah halaman terpisah untuk tiap topik? | Navigasi mungkin perlu penyesuaian | Setelah 3 modul terisi |

---

## 12. Referensi

| Dokumen | Isi yang relevan |
|---------|------------------|
| `02-KURIKULUM.md` | Rincian materi per modul dan taksonomi kartu |
| `03-DESIGN-SYSTEM.md` | Token visual dan komponen |
| `04-ARSITEKTUR-TEKNIS.md` | Stack dan struktur kode |
| `05-SKEMA-DATABASE.md` | Bentuk data yang mendukung aturan bisnis di dokumen ini |
| `06-SPESIFIKASI-HALAMAN.md` | Detail implementasi tiap halaman |
| `07-ROADMAP.md` | Urutan pengerjaan |
| `riset/01-RISET-TEKNIS.md` | Justifikasi teknis pilihan Supabase dan deployment |
