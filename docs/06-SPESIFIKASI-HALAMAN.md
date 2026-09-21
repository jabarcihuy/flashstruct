# 06 — Spesifikasi Halaman

> Spesifikasi rinci lima halaman utama FlashStruct: Dashboard, Home, Materi, Video, Soal.
> Status: `[FINAL]` · Aturan bisnis di `01-PRD.md` §3 · Token visual di `03-DESIGN-SYSTEM.md`

---

## 1. Ikhtisar Halaman

| Halaman | Rute | Tujuan | Data yang dipakai | Bergantung pada |
|---------|------|--------|-------------------|-----------------|
| **Home** | `/` | Menjelaskan produk, mengarahkan mulai | Statis | — |
| **Dashboard** | `/dashboard` | Menampilkan progres dan langkah berikutnya | Semua modul + progres lokal | Materi, Flashcard, Quiz |
| **Materi** | `/materi`, `/materi/:slug` | Membaca modul (Tahap 1) | `modul`, `bagian_modul` | — |
| **Video** | `/video` | Menonton video pendukung | `video`, `modul` | — |
| **Soal** | `/soal`, `/soal/flashcard/:slug`, `/soal/quiz/:slug` | Menghafal (Tahap 2) dan menguji (Tahap 3) | `flashcard`, `soal`, `opsi_soal` | Materi |

**Urutan implementasi:** Materi → Video → Soal (Flashcard) → Soal (Quiz) → Dashboard → Home.

Alasan: Materi tidak bergantung pada apa pun. Soal bergantung pada Materi (penguncian). Dashboard menampilkan data dari ketiganya. Home hanya menjelaskan produk.

---

## 2. Home — `/`

### 2.1 Tujuan

Menjawab tiga pertanyaan pengunjung baru dalam waktu kurang dari 10 detik:

1. Ini apa?
2. Kenapa ini beda dari belajar biasa?
3. Bagaimana cara mulai?

### 2.2 Struktur

```
┌────────────────────────────────────────────────────────────┐
│  HEADER: FlashStruct    Home  Dashboard  Materi  Video  Soal│
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [Hero]                                                    │
│                                                            │
│    Hafal dulu.                                             │
│    Baru praktik.                                           │
│                                                            │
│    Dunia TI berat di praktik, tapi praktik tanpa           │
│    hafalan yang kuat akan rapuh. FlashStruct               │
│    membuktikannya lewat satu mata kuliah paling            │
│    menantang: Struktur Data.                               │
│                                                            │
│    [ Mulai Belajar ]   [ Lihat Cara Kerjanya ]             │
│                                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [Masalah]  Kenapa "langsung ngoding" tidak cukup          │
│                                                            │
│    Mahasiswa bisa menyalin kode linked list,               │
│    tapi tidak bisa menjawab:                               │
│    "Apa yang terjadi di memori saat delete dipanggil?"     │
│                                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [Cara Kerja]  Tiga tahap, berurutan, terkunci              │
│                                                            │
│    ┌──────────┐    ┌──────────┐    ┌──────────┐            │
│    │    1     │    │    2     │    │    3     │            │
│    │ PAHAMI   │ -> │ HAFALKAN │ -> │ BUKTIKAN │            │
│    │          │    │          │    │          │            │
│    │ Modul +  │    │Flashcard │    │   Quiz   │            │
│    │  Video   │    │          │    │          │            │
│    └──────────┘    └──────────┘    └──────────┘            │
│                                                            │
│    Tahap berikutnya terbuka setelah tahap sebelumnya       │
│    selesai. Tidak bisa dilompati.                          │
│                                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [Topik]  Yang akan kamu kuasai                            │
│                                                            │
│    ┌────────────┐  ┌────────────┐  ┌────────────┐          │
│    │   ARRAY    │  │   STRUCT   │  │  POINTER   │          │
│    │            │  │            │  │            │          │
│    │ 3 modul    │  │ 3 modul    │  │ 4 modul    │          │
│    │ 56 kartu   │  │ 60 kartu   │  │ 90 kartu   │          │
│    └────────────┘  └────────────┘  └────────────┘          │
│                                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [Kenapa Hafalan]  Praktik tanpa hafalan itu rapuh         │
│                                                            │
│    Tiga alasan konkret, bukan slogan:                      │
│                                                            │
│    1. Di wawancara kerja, kamu tidak bisa membuka Google.  │
│    2. Di ujian tulis, tidak ada compiler yang membantu.    │
│    3. Saat debug, kamu butuh tahu apa yang SEHARUSNYA      │
│       terjadi di memori.                                   │
│                                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [CTA Akhir]                                               │
│    Siap mulai? 10 modul, sekitar 4,5 jam untuk tuntas.     │
│    [ Mulai Belajar ]                                       │
│                                                            │
├────────────────────────────────────────────────────────────┤
│  FOOTER: FlashStruct · Dokumentasi · Progres lokal        │
└────────────────────────────────────────────────────────────┘
```

### 2.3 Spesifikasi Hero

| Aspek | Nilai |
|-------|-------|
| Judul | `--text-4xl` (39px), weight 700, `--font-heading` |
| Subjudul | `--text-lg` (18px), `--fg-muted`, maks 3 baris |
| Lebar teks | Maks 60 karakter per baris |
| Padding vertikal | `--space-16` (64px) desktop, `--space-12` (48px) mobile |
| CTA utama | Varian `accent`, ukuran `lg` |
| CTA sekunder | Varian `secondary`, ukuran `lg` |

**Alasan CTA memakai `accent` dan bukan `primary`:** di Home, tujuannya adalah menarik pengunjung baru. `accent` (`#543D3D`, coklat gelap) memberi kesan hangat dan membumi yang cocok untuk halaman penyambutan. Di dalam aplikasi, CTA memakai `primary` (`#6A5582`, ungu) agar konsisten dengan aksi utama di seluruh aplikasi.

**Perilaku tombol "Mulai Belajar":**

```typescript
function tombolMulai() {
  const progres = bacaProgres();
  const adaProgres = Object.keys(progres.modul).length > 0;

  if (!adaProgres) {
    // Pengguna baru: langsung ke modul pertama
    navigate('/materi/array-dasar');
  } else {
    // Sudah pernah belajar: ke dashboard untuk melihat rekomendasi
    navigate('/dashboard');
  }
}
```

Alasan: pengguna baru yang diarahkan ke Dashboard akan melihat semua angka nol dan tidak tahu harus apa. Pengguna yang sudah punya progres justru butuh Dashboard.

### 2.4 Perilaku Section "Cara Kerja"

Diagram tiga tahap **bukan gambar statis**. Setiap kartu tahap dapat diklik dan mengarah ke penjelasan:

| Kartu | Klik mengarah ke |
|-------|------------------|
| 1. Pahami | `/materi` |
| 2. Hafalkan | `/soal` |
| 3. Buktikan | `/soal` |

**Animasi:** masuk dengan stagger 100ms antar kartu saat masuk viewport. Jika `prefers-reduced-motion`, semua tampil langsung tanpa animasi.

**Alasan ada panah antar tahap:** panah menyampaikan urutan. Tanpa panah, tiga kartu berdampingan terlihat seperti pilihan bebas, bukan urutan wajib.

### 2.5 Perilaku Section "Topik"

Angka jumlah modul dan kartu **dihitung dari data nyata**, bukan ditulis manual:

```typescript
const { data: modul } = useDaftarModul();

const statistikTopik = useMemo(() => {
  const hasil = { array: { modul: 0, kartu: 0 }, struct: { modul: 0, kartu: 0 }, pointer: { modul: 0, kartu: 0 } };
  for (const m of modul ?? []) {
    hasil[m.topik].modul += 1;
    hasil[m.topik].kartu += m.flashcard.length;
  }
  return hasil;
}, [modul]);
```

Alasan: menulis angka manual berarti angka itu akan salah begitu konten bertambah.

### 2.6 Yang Tidak Ada di Home

| Tidak ada | Alasan |
|-----------|--------|
| Testimoni | Belum ada pengguna nyata. Testimoni palsu merusak kepercayaan |
| Logo kampus | Belum ada afiliasi resmi |
| Angka pengguna | Aplikasi baru, angkanya akan memalukan |
| Formulir pendaftaran | Tidak ada akun (lihat `01-PRD.md` §9) |
| Carousel | Mengalihkan perhatian; kontennya bisa muat dalam satu halaman |

**Prinsip:** lebih baik halaman yang jujur dan kosong daripada halaman yang penuh klaim palsu.

---

## 3. Dashboard — `/dashboard`

### 3.1 Tujuan

Menjawab satu pertanyaan: **"Apa yang harus saya kerjakan sekarang?"**

Dashboard **bukan** halaman statistik. Statistik hanya pendukung. Fokus utamanya adalah rekomendasi langkah berikutnya.

### 3.2 Struktur

```
┌────────────────────────────────────────────────────────────┐
│  Dashboard                                                 │
│  Ringkasan progres belajarmu                               │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [KARTU REKOMENDASI]  <- PALING ATAS, paling menonjol      │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  LANJUTKAN                                           │  │
│  │                                                      │  │
│  │  Pointer & Array: Aritmetika Pointer                 │  │
│  │  Tahap 2 dari 3 - Flashcard                          │  │
│  │                                                      │  │
│  │  Kamu sudah membaca modulnya. Sekarang hafalkan      │  │
│  │  konsepnya dengan 22 kartu.                          │  │
│  │                                                      │  │
│  │  [ Mulai Flashcard ]                                 │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [STATISTIK]  empat kartu                                  │
│                                                            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │    3     │ │   48     │ │   76%    │ │   12     │       │
│  │ modul    │ │ kartu    │ │ akurasi  │ │ hari     │       │
│  │ selesai  │ │ dikuasai │ │ quiz     │ │ streak   │       │
│  │ dari 10  │ │ dari 206 │ │          │ │          │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
│                                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [PROGRES PER TOPIK]                                       │
│                                                            │
│  ARRAY      ████████████░░░░░░░░  3 dari 3 modul           │
│  STRUCT     ████████░░░░░░░░░░░░  2 dari 3 modul           │
│  POINTER    ████░░░░░░░░░░░░░░░░  1 dari 4 modul           │
│                                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [DAFTAR MODUL]                                            │
│  Filter: [ Semua ] [ Array ] [ Struct ] [ Pointer ]        │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ (garis) Array                           [3 tahap]    │  │
│  │ Dasar Array & Indeks                                 │  │
│  │ 5 bagian · 20 kartu · 12 mnt                         │  │
│  │ [v] Pahami   [v] Hafal   [v] Buktikan                │  │
│  │ [ Ulangi ]                                           │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ (garis) Pointer                         [3 tahap]    │  │
│  │ Dasar Pointer & Alamat Memori                        │  │
│  │ 6 bagian · 24 kartu · 16 mnt                         │  │
│  │ [v] Pahami   [ ] Hafal   [ ] Buktikan                │  │
│  │ [ Lanjutkan Flashcard ]                              │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
├────────────────────────────────────────────────────────────┤
│  [Pengaturan]                                              │
│  Tema: [ Terang ] [ Gelap ] [ Ikuti Sistem ]               │
│  [ Ekspor Progres ]  [ Reset Progres ]                     │
└────────────────────────────────────────────────────────────┘
```

### 3.3 Kartu Rekomendasi

Ini komponen terpenting di Dashboard. Logika penentuannya:

```typescript
// features/dashboard/useRekomendasi.ts

type Rekomendasi = {
  modulSlug: string;
  modulJudul: string;
  tahap: 1 | 2 | 3;
  aksi: string;
  alasan: string;
  ctaLabel: string;
  ctaRute: string;
};

function hitungRekomendasi(
  semuaModul: Modul[],
  progres: ProgresGlobal
): Rekomendasi | null {
  // Prioritas 1: modul yang sedang dikerjakan (tahap 1 selesai, tahap 2 belum)
  // Ini yang paling mungkin dilanjutkan pengguna.
  for (const m of semuaModul) {
    const p = progres.modul[m.id];
    if (p?.tahap1Selesai && !p?.tahap2Selesai) {
      return {
        modulSlug: m.slug,
        modulJudul: m.judul,
        tahap: 2,
        aksi: 'Flashcard',
        alasan: `Kamu sudah membaca modulnya. Sekarang hafalkan konsepnya dengan ${m.flashcard.length} kartu.`,
        ctaLabel: 'Mulai Flashcard',
        ctaRute: `/soal/flashcard/${m.slug}`,
      };
    }
  }

  // Prioritas 2: modul dengan tahap 2 selesai, tahap 3 belum
  for (const m of semuaModul) {
    const p = progres.modul[m.id];
    if (p?.tahap2Selesai && !p?.tahap3Selesai) {
      return {
        modulSlug: m.slug,
        modulJudul: m.judul,
        tahap: 3,
        aksi: 'Quiz',
        alasan: 'Semua kartu sudah kamu kuasai. Buktikan dengan 10 soal.',
        ctaLabel: 'Mulai Quiz',
        ctaRute: `/soal/quiz/${m.slug}`,
      };
    }
  }

  // Prioritas 3: modul berikutnya yang belum dimulai
  for (const m of semuaModul) {
    if (!progres.modul[m.id]) {
      return {
        modulSlug: m.slug,
        modulJudul: m.judul,
        tahap: 1,
        aksi: 'Baca Modul',
        alasan: 'Belum kamu mulai. Baca modulnya dulu, sekitar ' + m.estimasi_menit + ' menit.',
        ctaLabel: 'Baca Modul',
        ctaRute: `/materi/${m.slug}`,
      };
    }
  }

  // Semua selesai
  return null;
}
```

**Jika semua modul selesai:** tampilkan kartu berbeda:

```
┌──────────────────────────────────────────────────────┐
│  SELESAI                                             │
│                                                      │
│  Kamu sudah menuntaskan seluruh 10 modul.            │
│                                                      │
│  Cara memperkuat:                                    │
│  - Ulangi quiz modul dengan akurasi terendah         │
│  - Ulangi deck flashcard yang sudah lama tidak dibuka│
│                                                      │
│  [ Ulangi Quiz Terlemah ]                            │
└──────────────────────────────────────────────────────┘
```

**Aturan penting:** rekomendasi **selalu menyebut alasan**. "Lanjutkan" tanpa alasan tidak membantu pengguna memahami di mana posisinya.

### 3.4 Kartu Statistik

| Kartu | Nilai | Perhitungan | Catatan |
|-------|-------|-------------|---------|
| **Modul selesai** | `3 dari 10` | Modul dengan `tahap3Selesai` | Bukan hanya tahap 1 |
| **Kartu dikuasai** | `48 dari 206` | Kartu dengan `jumlahIngat > 0` dan `jumlahLupa = 0` | Total dari data nyata |
| **Akurasi quiz** | `76%` | Rata-rata akurasi semua quiz | Bukan rata-rata nilai |
| **Streak** | `12 hari` | Hari berturut-turut ada aktivitas | Lihat catatan di bawah |

**Catatan "modul selesai":** modul baru dihitung selesai jika **ketiga** tahap tuntas. Menghitung hanya dari tahap 1 akan memberi gambaran progres yang terlalu optimis.

**Catatan "kartu dikuasai":** kartu dianggap dikuasai jika pernah ditandai "Ingat" dan tidak pernah "Lupa" setelahnya. Kartu yang masih sering lupa tidak dihitung, walaupun pernah ditandai ingat.

**Catatan streak:** streak dihitung dari tanggal aktivitas di `localStorage`. Karena bergantung pada jam perangkat, pengguna yang mengubah jam bisa merusaknya. Ini **dapat diterima** — bukan fitur keamanan, hanya motivasi. Nilai streak maksimal 999 untuk mencegah tampilan aneh.

**Perilaku saat data kosong:** kartu statistik tetap tampil dengan angka `0`, disertai teks pendamping yang menjelaskan cara mengisinya:

```
┌──────────┐
│    0     │
│ modul    │
│ selesai  │
│ dari 10  │
│          │
│ Mulai    │
│ modul    │
│ pertama  │
└──────────┘
```

Alasan: kartu kosong tanpa penjelasan membuat pengguna bingung. Kartu nol dengan ajakan bertindak memberi arah.

### 3.5 Daftar Modul

Sama dengan komponen `KartuModul` di `03-DESIGN-SYSTEM.md` §6.2.

**Filter topik:** memakai tombol, bukan dropdown. Alasannya hanya tiga pilihan dan semuanya muat dalam satu baris.

**Pengurutan default:** modul yang sedang dikerjakan di atas, lalu yang belum dimulai, lalu yang sudah selesai.

```typescript
function urutkanModul(modul: Modul[], progres: ProgresGlobal) {
  const bobot = (m: Modul) => {
    const p = progres.modul[m.id];
    if (!p) return 1;                                    // belum dimulai
    if (p.tahap3Selesai) return 2;                       // selesai
    return 0;                                            // sedang dikerjakan
  };
  return modul.slice().sort((a, b) => {
    const selisih = bobot(a) - bobot(b);
    return selisih !== 0 ? selisih : a.urutan - b.urutan;
  });
}
```

Alasan: pengguna yang membuka Dashboard ingin melanjutkan, bukan mencari-cari.

### 3.6 Pengaturan

| Kontrol | Perilaku |
|---------|----------|
| **Tema** | Tiga pilihan: Terang, Gelap, Ikuti Sistem. Tersimpan di `localStorage` |
| **Ekspor Progres** | Unduh `flashstruct-progres-<tanggal>.json` |
| **Reset Progres** | Dialog konfirmasi ganda (lihat di bawah) |

**Dialog reset progres — konfirmasi ganda:**

```
Langkah 1:
┌────────────────────────────────────────────────────┐
│  Reset semua progres?                              │
│                                                    │
│  Kamu akan kehilangan:                             │
│  - 3 modul yang sudah selesai                      │
│  - 48 kartu yang sudah dikuasai                    │
│  - 12 riwayat quiz                                 │
│                                                    │
│  Tindakan ini tidak bisa dibatalkan.               │
│                                                    │
│  [ Batal ]              [ Lanjutkan ]              │
└────────────────────────────────────────────────────┘

Langkah 2:
┌────────────────────────────────────────────────────┐
│  Konfirmasi terakhir                               │
│                                                    │
│  Ketik HAPUS untuk mengonfirmasi:                  │
│                                                    │
│  ┌──────────────────────────────────────────────┐  │
│  │                                              │  │
│  └──────────────────────────────────────────────┘  │
│                                                    │
│  [ Batal ]              [ Hapus Permanen ]         │
└────────────────────────────────────────────────────┘
```

**Mengapa dua langkah:** menghapus progres berarti menghapus jam belajar. Satu klik salah akan sangat merugikan. Konfirmasi mengetik kata memaksa pengguna berhenti dan berpikir.

**Tawaran ekspor sebelum reset:** jika ada progres, dialog langkah 1 menambahkan baris:

```
Sebelum menghapus, kamu bisa menyimpannya dulu:
[ Ekspor Progres ]
```

---

## 4. Materi — `/materi` dan `/materi/:slug`

### 4.1 Halaman Daftar Materi — `/materi`

```
┌────────────────────────────────────────────────────────────┐
│  Materi                                                    │
│  Pelajari konsepnya sebelum menghafal                      │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [ Semua ]  [ Array ]  [ Struct ]  [ Pointer ]             │
│                                                            │
│  ARRAY - 3 modul                                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ (garis) Dasar Array & Indeks                         │  │
│  │ Memori berurutan, indeks, dan batas array.           │  │
│  │ 5 bagian · 20 kartu · 12 mnt                         │  │
│  │ [v] Pahami   [v] Hafal   [ ] Buktikan                │  │
│  │ [ Lanjutkan Flashcard ]                              │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ (garis) Array Multidimensi                           │  │
│  │ ...                                                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
│  STRUCT - 3 modul                                          │
│  ...                                                       │
│                                                            │
│  POINTER - 4 modul                                         │
│  ...                                                       │
└────────────────────────────────────────────────────────────┘
```

**Perbedaan dengan Dashboard:** halaman ini menampilkan modul **terkelompok per topik** dan **tidak diurutkan berdasarkan progres**. Tujuannya adalah eksplorasi, bukan melanjutkan.

**Pencarian:** kotak pencarian memfilter berdasarkan judul dan deskripsi modul. Pencarian di sisi client karena jumlah modul hanya 10.

### 4.2 Halaman Baca Modul — `/materi/:slug`

Ini halaman terpenting untuk Tahap 1. Tampilannya berbeda di desktop dan mobile karena kebutuhan navigasi yang berbeda.

**Desktop (≥ 1024px):**

```
┌────────────────────────────────────────────────────────────┐
│  HEADER                                                    │
├──────────────────┬─────────────────────────────────────────┤
│                  │                                         │
│  DAFTAR ISI      │  (garis) ARRAY                          │
│  (sticky)        │                                         │
│                  │  Dasar Array & Indeks                   │
│  [v] 1. Apa Itu  │  12 menit baca · 20 kartu               │
│      Array       │                                         │
│                  │  ─────────────────────────────────      │
│  [ ] 2. Memori   │                                         │
│      Berurutan   │  ## Apa Itu Array                       │
│                  │                                         │
│  [ ] 3. Indeks   │  Array adalah kumpulan elemen dengan    │
│                  │  tipe yang sama, disimpan berurutan     │
│                  │  di memori, dan diakses lewat indeks.   │
│                  │                                         │
│  [ ] 4. Batas    │  Analoginya seperti loker berderet:     │
│      Array       │  setiap loker punya nomor, dan nomor    │
│                  │  itu dimulai dari 0.                    │
│  [ ] 5. C++ vs   │                                         │
│      Python      │  ```cpp                                 │
│                  │  int arr[5] = {10, 20, 30, 40, 50};     │
│                  │  cout << arr[0];  // 10                 │
│                  │  cout << arr[4];  // 50                 │
│                  │  ```                                    │
│                  │                                         │
│                  │  [Tab: C++] [Tab: Python]               │
│                  │                                         │
│                  │  ┌─ PERHATIAN ──────────────────────┐   │
│                  │  │ arr[5] pada array berukuran 5    │   │
│                  │  │ adalah di luar batas. C++ tidak  │   │
│                  │  │ memeriksa ini.                   │   │
│                  │  └──────────────────────────────────┘   │
│                  │                                         │
│                  │  ─────────────────────────────────      │
│                  │  [ < Sebelumnya ]  [ Tandai Selesai ]   │
│                  │                    [ Berikutnya > ]     │
│                  │                                         │
│  [Progres baca:  │                                         │
│   ████░░ 40% ]   │                                         │
├──────────────────┴─────────────────────────────────────────┤
│  Setelah selesai: [ Lanjut ke Flashcard ]  (terkunci/dibuka)│
└────────────────────────────────────────────────────────────┘
```

**Mobile (< 1024px):**

```
┌────────────────────────────────────┐
│  [<]  Dasar Array & Indeks    [i]  │  <- [i] buka daftar isi
├────────────────────────────────────┤
│                                    │
│  (garis) ARRAY                     │
│                                    │
│  ## Apa Itu Array                  │
│                                    │
│  Array adalah kumpulan elemen...   │
│                                    │
│  [blok kode]                       │
│                                    │
│  ┌─ PERHATIAN ──────────────────┐  │
│  │ arr[5] pada array berukuran  │  │
│  │ 5 adalah di luar batas...    │  │
│  └──────────────────────────────┘  │
│                                    │
│  ──────────────────────────────    │
│  [ Tandai Selesai ]                │
│                                    │
├────────────────────────────────────┤
│  Progres baca: ████░░ 40%          │  <- sticky di bawah
└────────────────────────────────────┘
```

### 4.3 Pelacakan Progres Baca

PRD mensyaratkan 80% bagian dibuka sebelum modul bisa ditandai selesai. Cara melacaknya:

```typescript
// features/materi/useProgresBaca.ts

export function useProgresBaca(modulId: string, semuaBagian: Bagian[]) {
  const { progres, tandaiBagianDibaca } = useProgres();
  const bagianDibaca = progres.modul[modulId]?.bagianDibaca ?? [];

  // IntersectionObserver menandai bagian saat terlihat
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            const slug = entry.target.getAttribute('data-bagian-slug');
            if (slug) tandaiBagianDibaca(modulId, slug);
          }
        }
      },
      {
        // Bagian dianggap dibaca setelah 60% terlihat
        threshold: 0.6,
        // Beri margin bawah agar tidak menandai terlalu dini
        rootMargin: '0px 0px -10% 0px',
      }
    );

    document
      .querySelectorAll('[data-bagian-slug]')
      .forEach((el) => observer.observe(el));

    return () => observer.disconnect();
  }, [modulId, semuaBagian, tandaiBagianDibaca]);

  const persen = (bagianDibaca.length / semuaBagian.length) * 100;
  const cukupUntukSelesai = persen >= PERSEN_MINIMAL_BACA;

  return { bagianDibaca, persen, cukupUntukSelesai };
}
```

**Mengapa `threshold: 0.6`:** menandai bagian sebagai dibaca hanya karena 1 pikselnya terlihat akan membuat pelacakan tidak berarti. 60% memastikan pengguna benar-benar melihat isinya.

**Mengapa ada `rootMargin: '0px 0px -10% 0px'`:** tanpa ini, bagian terakhir langsung terlihat saat halaman dimuat dan langsung ditandai. Margin bawah memaksa pengguna benar-benar scroll ke sana.

### 4.4 Tombol "Tandai Selesai"

| Kondisi | Tampilan | Aksi |
|---------|----------|------|
| Belum 80% | `disabled`, teks: "Baca dulu minimal 80% (sekarang 40%)" | Tidak ada |
| Sudah 80% | `primary`, aktif | Tandai `tahap1Selesai = true` |
| Sudah selesai | `ghost`, teks: "Modul selesai" + ikon centang | Bisa dibatalkan |

**Aturan penting:** teks tombol yang terkunci **menyebutkan persentase saat ini**. "Baca dulu minimal 80%" saja tidak membantu; pengguna perlu tahu posisinya.

### 4.5 Setelah Modul Selesai

Setelah ditandai selesai, muncul panel di bawah modul:

```
┌──────────────────────────────────────────────────────────┐
│  [v] Modul selesai                                       │
│                                                          │
│  Tahap 1 dari 3 tuntas.                                  │
│                                                          │
│  Berikutnya: Hafalkan 20 kartu dari modul ini.           │
│                                                          │
│  [ Lanjut ke Flashcard ]                                 │
└──────────────────────────────────────────────────────────┘
```

**Jika belum selesai:**

```
┌──────────────────────────────────────────────────────────┐
│  [kunci] Tahap berikutnya terkunci                       │
│                                                          │
│  Selesaikan modul ini dulu sebelum mulai menghafal.      │
│                                                          │
│  [ Lanjut ke Flashcard ]  (tidak aktif)                  │
└──────────────────────────────────────────────────────────┘
```

**Mengapa tombol terkunci tetap ditampilkan:** menyembunyikannya membuat pengguna tidak tahu ada tahap berikutnya. Menampilkannya dengan alasan mengajarkan alur tiga tahap.

### 4.6 Render Markdown

Konten modul disimpan sebagai Markdown. Komponen yang perlu di-override:

| Elemen Markdown | Komponen | Catatan |
|-----------------|----------|---------|
| `#`, `##`, `###` | Heading dengan `id` otomatis | Untuk anchor daftar isi |
| `` ```cpp `` | `CodeBlock` dengan Shiki | Bahasa dari info string |
| `> kutipan` | Blockquote | Gaya berbeda dari callout |
| `- daftar` | List | Spasi `--space-2` antar item |
| `**tebal**` | `<strong>` | Weight 600 |
| `[teks](url)` | Tautan | `target="_blank"` untuk tautan luar |
| Tabel | Tabel responsif | Scroll horizontal di mobile |

**Sintaks khusus untuk callout** — menggunakan blockquote dengan penanda:

```markdown
> [!PERHATIAN]
> arr[5] pada array berukuran 5 adalah di luar batas.

> [!INFO]
> Indeks dimulai dari 0 di C++ dan Python.

> [!BAHAYA]
> Menulis di luar batas array adalah undefined behavior.

> [!TIPS]
> Ingat: alamat(i) = alamat(0) + i x sizeof(Tipe)
```

Alasan memakai sintaks ini: tetap valid sebagai Markdown biasa (akan tampil sebagai kutipan jika penanganan gagal), dan tidak mengunci konten pada renderer tertentu.

### 4.7 Performa Shiki

Shiki berukuran besar (± 300 KB). Cara memuatnya:

```typescript
// components/code/shiki.ts

let highlighterPromise: Promise<Highlighter> | null = null;

export function getHighlighter() {
  // Singleton: hanya dibuat sekali
  if (!highlighterPromise) {
    highlighterPromise = import('shiki').then(({ createHighlighter }) =>
      createHighlighter({
        // HANYA bahasa yang dipakai
        themes: ['github-light', 'github-dark'],
        langs: ['cpp', 'python'],
      })
    );
  }
  return highlighterPromise;
}
```

**Poin penting:**

1. **Impor dinamis** — Shiki tidak masuk bundle awal
2. **Singleton** — highlighter dibuat sekali, tidak per komponen
3. **Hanya 2 bahasa** — memuat semua bahasa akan memperbesar bundle berkali-kali lipat
4. **Hanya 2 tema** — tema terang dan gelap, tidak lebih

**Fallback saat Shiki belum dimuat:** tampilkan blok kode tanpa pewarnaan, dengan latar `--code-bg`. Kode tetap terbaca, hanya belum berwarna. Ini lebih baik daripada menampilkan spinner.

---

## 5. Video — `/video`

### 5.1 Tujuan

Menyediakan penjelasan visual untuk konsep yang sulit dibayangkan dari teks. **Video bersifat opsional** dan tidak memblokir progres (PRD §3 Tahap 1).

### 5.2 Struktur

```
┌────────────────────────────────────────────────────────────┐
│  Video                                                     │
│  Penjelasan visual untuk konsep yang sulit dibayangkan     │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [ Semua ]  [ Array ]  [ Struct ]  [ Pointer ]             │
│                                                            │
│  ARRAY                                                     │
│  ┌───────────────────┐  ┌───────────────────┐              │
│  │ [thumbnail]       │  │ [thumbnail]       │              │
│  │                   │  │                   │              │
│  │ ▶ 8:00            │  │ ▶ 6:30            │              │
│  ├───────────────────┤  ├───────────────────┤              │
│  │ Visualisasi       │  │ Array             │              │
│  │ Memori Array      │  │ Multidimensi      │              │
│  │                   │  │                   │              │
│  │ Melihat bagaimana │  │ Urutan baris dan  │              │
│  │ elemen array...   │  │ kolom di memori   │              │
│  │                   │  │                   │              │
│  │ dari: Dasar Array │  │ dari: Array       │              │
│  │       & Indeks    │  │       Multidimensi│              │
│  └───────────────────┘  └───────────────────┘              │
│                                                            │
│  POINTER                                                   │
│  ┌───────────────────┐                                     │
│  │ [thumbnail]       │                                     │
│  │ ▶ 12:15           │                                     │
│  ├───────────────────┤                                     │
│  │ Alamat Memori     │                                     │
│  │ ...               │                                     │
│  └───────────────────┘                                     │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### 5.3 Kartu Video

| Elemen | Detail |
|--------|--------|
| Thumbnail | `https://img.youtube.com/vi/<ID>/hqdefault.jpg` |
| Rasio | 16:9, lebar penuh kartu |
| Durasi | Badge di kanan bawah thumbnail |
| Judul | Maks 2 baris, ellipsis jika lebih |
| Deskripsi | Maks 2 baris, `--fg-muted` |
| Asal modul | Teks kecil, warna topik modul |

**Pemuatan gambar:** thumbnail memakai `loading="lazy"` dan `width`/`height` eksplisit. Tanpa dimensi eksplisit, gambar yang dimuat akan menggeser layout (CLS).

```html
<img
  src={`https://img.youtube.com/vi/${video.youtube_id}/hqdefault.jpg`}
  alt={`Thumbnail video: ${video.judul}`}
  width="480"
  height="270"
  loading="lazy"
  decoding="async"
  class="aspect-video w-full rounded-t-lg object-cover"
/>
```

### 5.4 Pemutar Video

Video **tidak** disemat langsung di kartu (itu akan memuat 18 iframe YouTube sekaligus). Klik kartu membuka modal:

```
┌────────────────────────────────────────────────────────────┐
│  [X]                                                       │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                                                      │  │
│  │            [IFRAME YOUTUBE]                          │  │
│  │                                                      │  │
│  │                                                      │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
│  Visualisasi Memori Array                                  │
│  dari: Dasar Array & Indeks                                │
│                                                            │
│  Melihat bagaimana elemen array tersimpan berurutan.       │
│                                                            │
│  [ Buka di YouTube ]                                       │
└────────────────────────────────────────────────────────────┘
```

**Implementasi modal:**

```typescript
function VideoPlayer({ video, onClose }: Props) {
  // Kunci scroll body saat modal terbuka
  useEffect(() => {
    const sebelumnya = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => { document.body.style.overflow = sebelumnya; };
  }, []);

  // Escape menutup modal
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === 'Escape') onClose();
    }
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onClose]);

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-3xl">
        <iframe
          src={`https://www.youtube-nocookie.com/embed/${video.youtube_id}?autoplay=1`}
          title={video.judul}
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
          className="aspect-video w-full rounded-lg"
        />
        <h2>{video.judul}</h2>
        <p>{video.deskripsi}</p>
        <a href={`https://youtube.com/watch?v=${video.youtube_id}`}
           target="_blank" rel="noopener noreferrer">
          Buka di YouTube
        </a>
      </DialogContent>
    </Dialog>
  );
}
```

**Poin penting:**

| Keputusan | Alasan |
|-----------|--------|
| Domain `youtube-nocookie.com` | Mengurangi pelacakan. Sesuai N-09 di PRD |
| `autoplay=1` | Pengguna sudah menyatakan niat dengan mengklik |
| `title` pada iframe | Wajib untuk aksesibilitas |
| Tautan "Buka di YouTube" | Beberapa video tidak bisa diputar tersemat (pemilik menonaktifkannya) |
| Kunci scroll body | Mencegah halaman di belakang modal ikut bergulir |
| Escape menutup | Standar yang diharapkan pengguna keyboard |

### 5.5 Halaman Video Saat Kosong

Karena video opsional dan mungkin belum tersedia:

```
┌────────────────────────────────────────────────────────────┐
│  Video                                                     │
├────────────────────────────────────────────────────────────┤
│                                                            │
│                    [Ikon play-circle]                      │
│                                                            │
│              Video sedang disiapkan                        │
│                                                            │
│  Untuk saat ini, semua konsep sudah dijelaskan lengkap     │
│  di halaman Materi. Video hanya pendukung, dan tidak       │
│  wajib untuk menyelesaikan tahap belajar.                  │
│                                                            │
│              [ Buka Halaman Materi ]                       │
└────────────────────────────────────────────────────────────┘
```

**Prinsip penting:** halaman kosong harus **jujur dan mengarahkan**, bukan sekadar "Belum ada data". Pengguna yang membuka halaman kosong harus tahu apa yang harus dilakukan berikutnya.

---

## 6. Soal — `/soal`

Halaman ini menampung **dua tahap terakhir**: flashcard (Tahap 2) dan quiz (Tahap 3).

### 6.1 Halaman Pemilih Mode — `/soal`

```
┌────────────────────────────────────────────────────────────┐
│  Soal                                                      │
│  Hafalkan, lalu buktikan                                   │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  Pilih modul, lalu pilih tahapnya.                         │
│                                                            │
│  [ Semua ]  [ Array ]  [ Struct ]  [ Pointer ]             │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ (garis) Array                                        │  │
│  │ Dasar Array & Indeks                                 │  │
│  │                                                      │  │
│  │ ┌────────────────────┐  ┌────────────────────┐       │  │
│  │ │  HAFALKAN          │  │  BUKTIKAN          │       │  │
│  │ │                    │  │                    │       │  │
│  │ │  20 kartu          │  │  18 soal           │       │  │
│  │ │  16 dikuasai       │  │  akurasi 82%       │       │  │
│  │ │                    │  │                    │       │  │
│  │ │  [ Mulai ]         │  │  [ Mulai ]         │       │  │
│  │ └────────────────────┘  └────────────────────┘       │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ (garis) Pointer                                      │  │
│  │ Dasar Pointer & Alamat Memori                        │  │
│  │                                                      │  │
│  │ ┌────────────────────┐  ┌────────────────────┐       │  │
│  │ │  HAFALKAN          │  │  BUKTIKAN          │       │  │
│  │ │  24 kartu          │  │  [kunci] Terkunci  │       │  │
│  │ │  belum mulai       │  │                    │       │  │
│  │ │                    │  │  Selesaikan semua  │       │  │
│  │ │  [ Mulai ]         │  │  kartu dulu        │       │  │
│  │ └────────────────────┘  └────────────────────┘       │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

**Kartu "Hafalkan" menampilkan:**
- Jumlah kartu total
- Jumlah kartu yang sudah dikuasai (jika ada)
- Ring progres (jika sebagian sudah dikuasai)

**Kartu "Buktikan" menampilkan:**
- Jumlah soal di bank soal
- Akurasi quiz terakhir (jika ada)
- Status terkunci dengan alasan (jika tahap 2 belum selesai)

### 6.2 Sesi Flashcard — `/soal/flashcard/:slug`

**Tata letak desktop:**

```
┌────────────────────────────────────────────────────────────┐
│  [X]  Dasar Array & Indeks                    3 / 20       │
│  ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
├────────────────────────────────────────────────────────────┤
│                                                            │
│                                                            │
│              ┌──────────────────────────────┐              │
│              │                              │              │
│              │          ARRAY               │              │
│              │                              │              │
│              │   Apa itu array-to-pointer   │              │
│              │   decay?                     │              │
│              │                              │              │
│              │                              │              │
│              │   [ Ketuk untuk lihat ]      │              │
│              │                              │              │
│              └──────────────────────────────┘              │
│                                                            │
│                                                            │
│                                                            │
│  Spasi: balik kartu                                         │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

**Setelah dibalik:**

```
┌────────────────────────────────────────────────────────────┐
│  [X]  Dasar Array & Indeks                    3 / 20       │
│  ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
├────────────────────────────────────────────────────────────┤
│                                                            │
│              ┌──────────────────────────────┐              │
│              │          ARRAY               │              │
│              │                              │              │
│              │   Perubahan otomatis nama    │              │
│              │   array menjadi pointer ke   │              │
│              │   elemen pertamanya saat     │              │
│              │   dipakai dalam ekspresi     │              │
│              │   tertentu, misalnya saat    │              │
│              │   dikirim ke fungsi.         │              │
│              │                              │              │
│              └──────────────────────────────┘              │
│                                                            │
│                                                            │
│         [   Lupa (1)   ]    [   Ingat (2)   ]              │
│                                                            │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

**Spesifikasi kartu:**

| Aspek | Nilai |
|-------|-------|
| Lebar maks | 560px |
| Tinggi min | 320px |
| Tinggi maks | 480px, isi lebih dari itu di-scroll di dalam kartu |
| Padding | `--space-8` (32px) |
| Sudut | `--radius-xl` (20px) |
| Bayangan | `--shadow-md` |
| Teks pertanyaan | `--text-2xl` (25px), weight 600 |
| Teks jawaban | `--text-lg` (18px) |
| Label topik | `--text-xs`, warna topik, uppercase |

**Aturan tinggi kartu tetap:** jika tinggi kartu berubah saat dibalik, mata kehilangan posisi dan pengalaman terasa gelisah. Tinggi ditetapkan pada wadah, bukan pada isi.

### 6.3 Interaksi Flashcard

| Aksi | Mouse/Touch | Keyboard | Catatan |
|------|-------------|----------|---------|
| Balik kartu | Klik di mana saja pada kartu | `Space` atau `Enter` | Hanya jika belum dibalik |
| Tandai lupa | Tombol "Lupa" | `1` atau `ArrowLeft` | Hanya jika sudah dibalik |
| Tandai ingat | Tombol "Ingat" | `2` atau `ArrowRight` | Hanya jika sudah dibalik |
| Keluar sesi | Tombol `X` | `Escape` | Muncul konfirmasi jika belum selesai |

**Penting:** tombol "Lupa" dan "Ingat" **tidak muncul** sebelum kartu dibalik. Ini memaksa pengguna membaca jawaban dulu.

**Konfirmasi keluar:**

```
┌────────────────────────────────────────────────────┐
│  Keluar dari sesi?                                 │
│                                                    │
│  Kamu sudah menyelesaikan 3 dari 20 kartu.         │
│  Progres sesi ini akan hilang.                     │
│                                                    │
│  [ Lanjut Belajar ]        [ Keluar ]              │
└────────────────────────────────────────────────────┘
```

**Mengapa peringatan ini penting:** sesi flashcard disimpan di memori, bukan `localStorage` (lihat `04-ARSITEKTUR-TEKNIS.md` §3.3). Keluar berarti kehilangan progres sesi.

### 6.4 Ulangan Kartu "Lupa"

Setelah semua kartu dalam sesi selesai, jika ada kartu yang ditandai "Lupa":

```
┌────────────────────────────────────────────────────────────┐
│  PUTARAN ULANG                                             │
│                                                            │
│  Dari 20 kartu, 5 ditandai lupa.                           │
│                                                            │
│  Mari ulangi 5 kartu itu.                                  │
│                                                            │
│  [ Ulangi Sekarang ]        [ Lewati ]                     │
└────────────────────────────────────────────────────────────┘
```

**Aturan:** ulangan hanya **satu putaran**. Jika di putaran ulang masih ada yang lupa, sesi tetap selesai dan kartu itu tercatat lupa.

**Alasan hanya satu putaran:** putaran tak terbatas bisa membuat sesi tidak pernah selesai. Pengguna yang benar-benar kesulitan akan mengulanginya di sesi berikutnya — dan karena kartu lupa diprioritaskan, kartu itu akan muncul lagi.

### 6.5 Ringkasan Sesi

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                     [Ikon layers]                          │
│                                                            │
│                   Sesi selesai                             │
│                                                            │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │     20     │  │     15     │  │     5      │            │
│  │  kartu     │  │  diingat   │  │  perlu     │            │
│  │  dikerjakan│  │            │  │  diulang   │            │
│  └────────────┘  └────────────┘  └────────────┘            │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  STATUS DECK                                         │  │
│  │                                                      │  │
│  │  ████████████████████░░░░  15 dari 20 kartu dikuasai │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  [v] Tahap 2 dari 3 selesai                          │  │
│  │                                                      │  │
│  │  Semua kartu sudah kamu tandai ingat minimal sekali. │  │
│  │  Tahap berikutnya terbuka: Buktikan dengan quiz.     │  │
│  │                                                      │  │
│  │  [ Mulai Quiz ]                                      │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
│  [ Ulangi Sesi ]              [ Kembali ke Soal ]          │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

**Jika masih ada kartu lupa:**

```
┌──────────────────────────────────────────────────────┐
│  Tahap 2 belum selesai                               │
│                                                      │
│  Masih ada 5 kartu yang perlu diulang.               │
│  Selesaikan semuanya dulu untuk membuka quiz.        │
│                                                      │
│  [ Ulangi Sesi ]                                     │
└──────────────────────────────────────────────────────┘
```

**Aturan kelulusan Tahap 2:** semua kartu minimal sekali ditandai "Ingat". Ini sesuai `01-PRD.md` §3 Tahap 2.

### 6.6 Sesi Quiz — `/soal/quiz/:slug`

**Tata letak:**

```
┌────────────────────────────────────────────────────────────┐
│  [X]  Dasar Array & Indeks               Soal 3 dari 10    │
│  ███████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌─ PG ────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  Berapa nilai sizeof(arr) jika dideklarasikan       │   │
│  │  sebagai int arr[5] dengan int berukuran 4 byte?    │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  A   4                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  B   5                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  C   20                                             │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  D   40                                             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

**Setelah menjawab (umpan balik langsung):**

```
┌────────────────────────────────────────────────────────────┐
│  [X]  Dasar Array & Indeks               Soal 3 dari 10    │
│  ███████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌─ PG ────────────────────────────────────────────────┐   │
│  │  Berapa nilai sizeof(arr) jika dideklarasikan       │   │
│  │  sebagai int arr[5] dengan int berukuran 4 byte?    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  A   4                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  B   5                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─ BENAR ─────────────────────────────────────────────┐   │
│  │  C   20                                     [v]     │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  D   40                                             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                            │
│  ┌─ PENJELASAN ────────────────────────────────────────┐   │
│  │  [v] Jawaban benar: C                               │   │
│  │                                                     │   │
│  │  5 elemen x 4 byte = 20 byte.                       │   │
│  │                                                     │   │
│  │  Opsi A salah karena 4 adalah ukuran satu int.      │   │
│  │  Opsi B salah karena 5 adalah jumlah elemen.        │   │
│  │  Opsi D salah karena keliru mengira int 8 byte.     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                            │
│                              [ Soal Berikutnya ]           │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

**Setelah menjawab salah:**

```
│  ┌─────────────────────────────────────────────────────┐   │
│  │  A   4                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─ SALAH (pilihanmu) ─────────────────────────────────┐   │
│  │  B   5                                      [x]     │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─ JAWABAN BENAR ─────────────────────────────────────┐   │
│  │  C   20                                     [v]     │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  D   40                                             │   │
│  └─────────────────────────────────────────────────────┘   │
```

**Aturan visual umpan balik:**

| Kondisi | Border | Latar | Ikon |
|---------|--------|-------|------|
| Pilihan benar | 2px `--success` | `--success` 8% opasitas | `check-circle-2` |
| Pilihan salah | 2px `--danger` | `--danger` 8% opasitas | `x-circle` |
| Jawaban benar (saat salah) | 2px `--success` | `--success` 8% opasitas | `check-circle-2` |
| Lainnya | 1px `--border` | transparan | — |

**Penting:** warna **selalu** disertai ikon dan teks ("BENAR", "SALAH", "JAWABAN BENAR"). Warna saja tidak cukup untuk pengguna dengan gangguan penglihatan warna.

### 6.7 Soal Tipe TRACE

Soal tracing menampilkan blok kode:

```
│  ┌─ TRACE ─────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  Apa output dari kode berikut?                      │   │
│  │                                                     │   │
│  │  ┌───────────────────────────────────────────────┐  │   │
│  │  │ 1  int arr[5] = {10, 20, 30, 40, 50};        │  │   │
│  │  │ 2  int* p = arr;                             │  │   │
│  │  │ 3  cout << *(p + 3);                         │  │   │
│  │  └───────────────────────────────────────────────┘  │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
```

**Perbedaan dengan soal PG:** ada blok kode dengan nomor baris. Nomor baris penting karena soal tracing sering merujuk "baris ke-3".

**Aturan nomor baris:** hanya ditampilkan jika kode lebih dari 3 baris. Untuk kode 1–3 baris, nomor baris hanya menambah kebisingan visual.

### 6.8 Hasil Quiz

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                     [Ikon clipboard]                       │
│                                                            │
│                    Quiz selesai                            │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                                                      │  │
│  │                      80                              │  │
│  │                    ──────                            │  │
│  │                     dari 100                         │  │
│  │                                                      │  │
│  │                   [v] LULUS                          │  │
│  │                                                      │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
│  8 benar · 2 salah · ambang lulus 70                      │
│                                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ANALISIS PER TOPIK                                        │
│                                                            │
│  MEMORI      ████████████████████░░░░   83%   (5/6)        │
│  TRACING     ████████████████░░░░░░░░   75%   (3/4)        │
│  JEBAKAN     ░░░░░░░░░░░░░░░░░░░░░░░░    0%   (0/1)        │
│                                                            │
│  ┌─ PERLU DIULANG ─────────────────────────────────────┐   │
│  │  Topik "JEBAKAN" masih lemah (0%).                  │   │
│  │  Baca ulang modul bagian batas array, lalu ulangi   │   │
│  │  kartu dengan tipe ini.                             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  RINCIAN JAWABAN                                           │
│                                                            │
│  [v] 1. Berapa nilai sizeof(arr)...            Benar       │
│  [v] 2. Apa output dari kode berikut...        Benar       │
│  [x] 3. Kode berikut bocor memori...           Salah       │
│      Jawabanmu: B    Jawaban benar: C                      │
│      [ Lihat penjelasan ]                                  │
│  ...                                                       │
│                                                            │
├────────────────────────────────────────────────────────────┤
│  [v] Tahap 3 dari 3 selesai                                │
│                                                            │
│  Modul ini tuntas. Lanjut ke modul berikutnya?             │
│                                                            │
│  [ Modul Berikutnya ]        [ Kembali ke Dashboard ]      │
└────────────────────────────────────────────────────────────┘
```

**Jika tidak lulus (< 70):**

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│                      50                              │
│                    ──────                            │
│                     dari 100                         │
│                                                      │
│                   [x] BELUM LULUS                    │
│                                                      │
└──────────────────────────────────────────────────────┘

5 benar · 5 salah · ambang lulus 70

┌─ SARAN ──────────────────────────────────────────────┐
│  Nilai belum mencapai 70. Ini bukan masalah -        │
│  artinya ada bagian yang perlu diperkuat.            │
│                                                      │
│  Topik terlemah: JEBAKAN (0%)                        │
│                                                      │
│  [ Ulangi Quiz ]    [ Baca Ulang Modul ]             │
└──────────────────────────────────────────────────────┘
```

**Nada pesan saat gagal:** tidak menghakimi. "Ini bukan masalah" penting — pengguna yang gagal sudah tahu ia gagal, dan pesan yang menyalahkan akan membuatnya berhenti.

**Aturan penting:** Tahap 3 **tidak wajib lulus** untuk dianggap selesai. Pengguna yang menyelesaikan quiz (apapun nilainya) menuntaskan tahap 3. Alasannya: memaksa nilai tinggi akan membuat pengguna terjebak mengulang tanpa akhir.

### 6.9 Perhitungan Analisis Topik

```typescript
// features/quiz/analisis.ts

export interface AkurasiTopik {
  cardType: TipeKartu;
  benar: number;
  total: number;
  persen: number;
  kategori: 'lemah' | 'cukup' | 'kuat';
}

export function hitungAkurasiTopik(
  soal: Soal[],
  jawaban: Record<string, string>   // soalId -> label yang dipilih
): AkurasiTopik[] {
  const perTopik = new Map<TipeKartu, { benar: number; total: number }>();

  for (const s of soal) {
    const stat = perTopik.get(s.card_type) ?? { benar: 0, total: 0 };
    stat.total += 1;

    const opsiBenar = s.opsi_soal.find((o) => o.benar);
    if (jawaban[s.id] && opsiBenar && jawaban[s.id] === opsiBenar.label) {
      stat.benar += 1;
    }

    perTopik.set(s.card_type, stat);
  }

  return Array.from(perTopik.entries()).map(([cardType, stat]) => {
    const persen = stat.total > 0 ? (stat.benar / stat.total) * 100 : 0;
    return {
      cardType,
      benar: stat.benar,
      total: stat.total,
      persen: Math.round(persen),
      kategori:
        persen < AMBANG_TOPIK_LEMAH ? 'lemah'
        : persen < AMBANG_TOPIK_CUKUP ? 'cukup'
        : 'kuat',
    };
  }).sort((a, b) => a.persen - b.persen);   // terlemah di atas
}
```

**Mengapa diurutkan dari terlemah:** yang perlu ditindaklanjuti adalah yang lemah. Menampilkan yang kuat di atas hanya menyenangkan hati tapi tidak membantu.

**Ambang batas:** dari `lib/constants.ts` — `AMBANG_TOPIK_LEMAH = 50`, `AMBANG_TOPIK_CUKUP = 80`. Nilai yang sama dipakai di `02-KURIKULUM.md` §5.4.

### 6.10 Pencegahan Keluar Saat Quiz

Selama quiz berlangsung, jika pengguna menekan tombol `X`:

```
┌────────────────────────────────────────────────────┐
│  Keluar dari quiz?                                 │
│                                                    │
│  Kamu sudah menjawab 3 dari 10 soal.               │
│  Jawaban akan hilang.                              │
│                                                    │
│  [ Lanjut Mengerjakan ]      [ Keluar ]            │
└────────────────────────────────────────────────────┘
```

**Tidak ada `beforeunload`:** mencegah dialog bawaan browser saat menutup tab. Alasannya, `beforeunload` sering disalahgunakan dan pengguna sudah terbiasa mengabaikannya. Konfirmasi di dalam aplikasi lebih jujur dan tidak mengganggu.

---

## 7. Perilaku Bersama Semua Halaman

### 7.1 Saat Memuat

Setiap halaman yang memuat data menampilkan skeleton dengan tinggi yang **sama** dengan konten akhir:

```typescript
function HalamanMateriSkeleton() {
  return (
    <div className="container-base py-8">
      <Skeleton className="h-8 w-1/3" />
      <Skeleton className="mt-2 h-4 w-2/3" />
      <div className="mt-8 space-y-4">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="rounded-lg border p-6" style={{ minHeight: 220 }}>
            <Skeleton className="h-6 w-3/4" />
            <Skeleton className="mt-3 h-4 w-full" />
            <Skeleton className="mt-2 h-4 w-1/2" />
          </div>
        ))}
      </div>
    </div>
  );
}
```

**Aturan:** tinggi skeleton sama dengan konten akhir. Skeleton yang lebih pendek menyebabkan lompatan layout saat konten masuk.

### 7.2 Saat Data Kosong

Setiap daftar harus punya `EmptyState` dengan tiga bagian:

1. **Ikon** — menggambarkan situasinya
2. **Penjelasan** — mengapa kosong
3. **Aksi** — apa yang harus dilakukan

```typescript
function EmptyState({ ikon: Ikon, judul, pesan, aksi }: Props) {
  return (
    <div className="flex flex-col items-center gap-4 py-16 text-center">
      <Ikon className="size-12 text-[var(--fg-muted)]" aria-hidden="true" />
      <div>
        <h2 className="text-xl font-semibold">{judul}</h2>
        <p className="mt-2 max-w-md text-[var(--fg-muted)]">{pesan}</p>
      </div>
      {aksi}
    </div>
  );
}
```

Contoh pemakaian:

```typescript
<EmptyState
  ikon={BookOpen}
  judul="Belum ada modul"
  pesan="Konten sedang disiapkan. Coba muat ulang halaman sebentar lagi."
  aksi={<Button onClick={muatUlang}>Muat Ulang</Button>}
/>
```

### 7.3 Saat Error

```typescript
<ErrorState
  judul="Gagal memuat materi"
  pesan="Tidak bisa terhubung ke server. Periksa koneksi internet, lalu coba lagi."
  onCobaLagi={refetch}
/>
```

**Aturan pesan error:** sebutkan apa yang gagal, kemungkinan penyebabnya, dan apa yang bisa dilakukan. Jangan menampilkan kode error mentah.

### 7.4 Judul Halaman

Setiap halaman menyetel `document.title`:

```typescript
function useJudulHalaman(judul: string) {
  useEffect(() => {
    document.title = `${judul} | FlashStruct`;
  }, [judul]);
}
```

| Halaman | Judul |
|---------|-------|
| Home | `FlashStruct — Belajar Struktur Data dengan Flashcard` |
| Dashboard | `Dashboard` |
| Materi | `Materi` |
| Modul | `Dasar Array & Indeks` |
| Video | `Video` |
| Soal | `Soal` |
| Flashcard | `Flashcard: Dasar Array & Indeks` |
| Quiz | `Quiz: Dasar Array & Indeks` |

Alasan penting: pengguna yang membuka banyak tab harus bisa membedakannya dari judul.

### 7.5 Fokus Saat Navigasi

```typescript
function useFokusHalaman() {
  useEffect(() => {
    const h1 = document.querySelector('h1');
    if (h1) {
      h1.setAttribute('tabindex', '-1');
      h1.focus();
    }
  }, []);
}
```

Alasan: pada SPA, berpindah halaman tidak memindahkan fokus. Tanpa ini, pengguna keyboard tetap di posisi lama dan harus menekan Tab berkali-kali untuk mencapai konten baru.

### 7.6 Perilaku Offline

Jika koneksi terputus:

| Kondisi | Perilaku |
|---------|----------|
| Konten sudah di cache | Tetap tampil normal |
| Konten belum di cache | `ErrorState` dengan pesan koneksi |
| Sedang mengerjakan quiz | Tetap berjalan (soal sudah dimuat) |
| Sedang flashcard | Tetap berjalan (kartu sudah dimuat) |
| Menyimpan progres | Tetap berhasil (`localStorage` lokal) |

**Poin penting:** karena semua konten dimuat di awal sesi dan progres disimpan lokal, pengguna yang sudah membuka halaman dapat menyelesaikan sesi belajar tanpa internet. Ini keuntungan tak terduga dari arsitektur tanpa autentikasi.

---

## 8. Ringkasan Komponen Baru per Halaman

Komponen yang perlu dibuat, di luar primitif di `components/ui/`.

| Halaman | Komponen | Berkas |
|---------|----------|--------|
| Home | `Hero` | `features/home/Hero.tsx` |
| Home | `DiagramTigaTahap` | `features/home/DiagramTigaTahap.tsx` |
| Home | `KartuTopik` | `features/home/KartuTopik.tsx` |
| Home | `AlasanHafalan` | `features/home/AlasanHafalan.tsx` |
| Dashboard | `KartuRekomendasi` | `features/dashboard/KartuRekomendasi.tsx` |
| Dashboard | `StatCard` | `features/dashboard/StatCard.tsx` |
| Dashboard | `ProgresPerTopik` | `features/dashboard/ProgresPerTopik.tsx` |
| Dashboard | `Pengaturan` | `features/dashboard/Pengaturan.tsx` |
| Dashboard | `DialogResetProgres` | `features/dashboard/DialogResetProgres.tsx` |
| Materi | `ModulCard` | `features/materi/ModulCard.tsx` |
| Materi | `ModulReader` | `features/materi/ModulReader.tsx` |
| Materi | `DaftarIsi` | `features/materi/DaftarIsi.tsx` |
| Materi | `TombolSelesai` | `features/materi/TombolSelesai.tsx` |
| Materi | `PanelLanjut` | `features/materi/PanelLanjut.tsx` |
| Video | `VideoCard` | `features/video/VideoCard.tsx` |
| Video | `VideoPlayer` | `features/video/VideoPlayer.tsx` |
| Soal | `PemilihMode` | `features/soal/PemilihMode.tsx` |
| Flashcard | `FlashcardDeck` | `features/flashcard/FlashcardDeck.tsx` |
| Flashcard | `Flashcard` | `features/flashcard/Flashcard.tsx` |
| Flashcard | `PenilaianDiri` | `features/flashcard/PenilaianDiri.tsx` |
| Flashcard | `PutaranUlang` | `features/flashcard/PutaranUlang.tsx` |
| Flashcard | `RingkasanSesi` | `features/flashcard/RingkasanSesi.tsx` |
| Quiz | `QuizRunner` | `features/quiz/QuizRunner.tsx` |
| Quiz | `SoalPilihanGanda` | `features/quiz/SoalPilihanGanda.tsx` |
| Quiz | `SoalTracing` | `features/quiz/SoalTracing.tsx` |
| Quiz | `UmpanBalik` | `features/quiz/UmpanBalik.tsx` |
| Quiz | `HasilQuiz` | `features/quiz/HasilQuiz.tsx` |
| Quiz | `AnalisisTopik` | `features/quiz/AnalisisTopik.tsx` |
| Quiz | `RincianJawaban` | `features/quiz/RincianJawaban.tsx` |

---

## 9. Referensi Silang

| Topik | Dokumen |
|-------|---------|
| Aturan bisnis tiga tahap | `01-PRD.md` §3 |
| Konten dan taksonomi kartu | `02-KURIKULUM.md` §4 |
| Token visual dan spesifikasi komponen dasar | `03-DESIGN-SYSTEM.md` §2, §6 |
| Struktur folder dan alur data | `04-ARSITEKTUR-TEKNIS.md` §2, §3 |
| Bentuk data dan query | `05-SKEMA-DATABASE.md` §3, §5 |
| Urutan pengerjaan | `07-ROADMAP.md` |
| Checklist sebelum selesai | `08-CHECKLIST-QA.md` |
