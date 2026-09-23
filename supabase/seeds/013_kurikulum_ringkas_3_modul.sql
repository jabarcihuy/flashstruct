-- =========================================================
-- FlashStruct — Kurikulum Ringkas: 3 Modul Inti
--
-- Array · Struct · Pointer — satu modul per topik, tanpa submateri.
-- Setiap modul berisi:
--   - 1 bagian materi lengkap (konten_md)
--   - 10 kartu flashcard
--   - 10 soal pilihan ganda + 4 opsi masing-masing
--
-- Semua contoh kode C++ telah diverifikasi terhadap perilaku
-- sebenarnya (GCC, x86-64, sizeof(int) = 4).
--
-- CATATAN: skrip ini MENGGANTI seluruh konten lama (10 modul).
-- Backup konten lama: /tmp/opencode/backup-konten/konten-10-modul.json
-- =========================================================

begin;

-- =========================================================
-- 1) Bersihkan seluruh konten lama
--    (opsi_soal dan bagian ikut terhapus lewat ON DELETE CASCADE)
-- =========================================================

delete from public.video;
delete from public.flashcard;
delete from public.soal;
delete from public.bagian_modul;
delete from public.modul;

-- =========================================================
-- 2) Buat 3 modul
-- =========================================================

insert into public.modul (slug, judul, topik, deskripsi, estimasi_menit, urutan) values
('array-dasar',   'Array',   'array',   'Kumpulan elemen bertipe sama yang tersimpan berurutan di memori dan diakses lewat indeks.', 20, 1),
('struct-dasar',  'Struct',  'struct',  'Koleksi variabel dengan tipe data berbeda yang dikelompokkan dalam satu nama.',             18, 2),
('pointer-dasar', 'Pointer', 'pointer', 'Variabel yang menyimpan alamat memori, membuka akses ke alokasi dinamis dan manipulasi langsung.', 22, 3);

-- =========================================================
-- 3) Materi — satu bagian per modul
-- =========================================================

-- ---------------------------------------------------------
-- ARRAY
-- ---------------------------------------------------------
insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
select m.id, 'materi-array', 'Materi Array', E'Apa Itu Array
---
Array adalah kumpulan elemen dengan **tipe yang sama**, disimpan berurutan di memori, dan diakses lewat indeks.

Analoginya seperti loker berderet: setiap loker punya nomor, dan nomor itu dimulai dari nol.

## Tiga Ciri Array

1. **Homogen** — semua elemen harus bertipe data yang sama
2. **Kontigu** — elemen disimpan berurutan tanpa celah di memori
3. **Akses lewat indeks** — elemen pertama adalah indeks 0

> [!INFO]
> Indeks dimulai dari **0**, bukan 1. Ini berlaku di C++ dan Python.

## Deklarasi Array

### C++

```cpp
int A[5];                    // 5 elemen, nilai belum diisi
int B[5] = {10, 20, 30, 40, 50};   // 5 elemen terisi
int C[5] = {1, 2};           // sisanya otomatis 0
```

### Python

```python
A = [0] * 5                  # 5 elemen bernilai 0
B = [10, 20, 30, 40, 50]     # 5 elemen terisi
```

> [!PERHATIAN]
> Python memakai **list**, bukan array seperti C++. Ukurannya bisa berubah, dan tipenya boleh berbeda.

## Mengakses Elemen

Indeks ditulis di dalam kurung siku, dimulai dari 0.

```cpp
int B[5] = {10, 20, 30, 40, 50};

cout << B[0];   // 10  (elemen pertama)
cout << B[1];   // 20  (elemen kedua)
cout << B[4];   // 50  (elemen terakhir)
```

Perhatikan: array berukuran 5 punya indeks **0 sampai 4**, bukan 1 sampai 5.

## Mengapa Akses Array Sangat Cepat

Alamat setiap elemen bisa **dihitung langsung**, tanpa menelusuri elemen sebelumnya:

```
alamat(i) = alamat(0) + i x sizeof(Tipe)
```

Karena rumusnya sederhana, komputer bisa melompat ke elemen mana pun dalam waktu yang sama. Inilah yang disebut **random access** atau pengaksesan acak langsung.

Mengakses elemen ke-1 sama cepatnya dengan mengakses elemen ke-1000.

> [!INFO]
> Dalam notasi kompleksitas, akses array adalah **O(1)** — waktu konstan, tidak bergantung pada posisi elemen.

## Menelusuri Array

Perulangan dipakai untuk mengunjungi setiap elemen berurutan.

### C++

```cpp
int B[5] = {10, 20, 30, 40, 50};

for (int i = 0; i < 5; i++) {
    cout << B[i] << " ";
}
// Output: 10 20 30 40 50
```

### Python

```python
B = [10, 20, 30, 40, 50]

for nilai in B:
    print(nilai, end=" ")
# Output: 10 20 30 40 50
```

Perhatikan kondisi `i < 5`, bukan `i <= 5`. Kalau memakai `<=`, program akan mengakses indeks 5 yang **di luar batas**.

## Jebakan: Keluar Batas Array

C++ tidak memeriksa batas array saat program berjalan. Menulis di luar batas tidak memunculkan pesan error — tetapi merusak memori di sekitarnya.

```cpp
int B[5] = {10, 20, 30, 40, 50};

B[5] = 100;   // BAHAYA: indeks 5 di luar batas!
```

Ini disebut **undefined behavior**: program mungkin tampak berjalan normal, tetapi nilainya tidak bisa diprediksi.

> [!BAHAYA]
> Di Python, kasus yang sama melempar `IndexError` dan program berhenti dengan pesan jelas. Perbedaan ini penting: C++ mempercayai programmer, Python melindungi programmer.

## Menyalin Array

Di C++, menulis `B = A` pada array **tidak menyalin isinya** — dan sebenarnya tidak bisa dikompilasi. Isi harus disalin elemen per elemen.

```cpp
int A[3] = {1, 2, 3};
int B[3];

for (int i = 0; i < 3; i++) {
    B[i] = A[i];
}
// B sekarang berisi 1, 2, 3
```

Di Python, `B = A` juga **tidak menyalin** — B menjadi nama lain untuk list yang sama. Untuk menyalin isinya:

```python
A = [1, 2, 3]
B = A.copy()      # salinan terpisah

B[0] = 99
print(A[0])       # tetap 1 — A tidak terpengaruh
```

> [!JEBAKAN]
> Di Python, `B = A` membuat B menunjuk objek yang **sama**. Mengubah B[0] ikut mengubah A[0]. Ini penyebab bug yang sangat sering terjadi.

## Ringkasan

| Aspek | Keterangan |
|-------|------------|
| Tipe elemen | Homogen — harus sama semua |
| Letak di memori | Kontigu — berurutan tanpa celah |
| Indeks awal | 0 |
| Ukuran | Tetap, ditentukan saat dibuat |
| Kecepatan akses | O(1) — langsung dihitung alamatnya |
| Pemeriksaan batas | C++ tidak memeriksa; Python melempar IndexError |', 1
from public.modul m where m.slug = 'array-dasar';

-- ---------------------------------------------------------
-- STRUCT
-- ---------------------------------------------------------
insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
select m.id, 'materi-struct', 'Materi Struct', E'Apa Itu Struct
---
Struct adalah koleksi variabel dengan **tipe data berbeda** yang dikelompokkan dalam satu nama.

Kalau array menampung banyak nilai dengan tipe **sama**, struct menampung beberapa nilai dengan tipe yang boleh **berbeda** — semuanya dalam satu kesatuan.

## Array vs Struct

| Aspek | Array | Struct |
|-------|-------|--------|
| Tipe elemen | Homogen — harus sama | Heterogen — boleh berbeda |
| Cara akses | Lewat indeks angka | Lewat nama anggota |
| Jumlah anggota | Banyak, sejenis | Sedikit, bermacam tipe |
| Contoh | Daftar nilai ujian | Data mahasiswa (NIM, nama, IPK) |

Analoginya seperti **kartu identitas**: satu kartu memuat nama (teks), tanggal lahir (tanggal), dan tinggi badan (angka) — berbeda tipe, tetapi menyatu sebagai satu identitas.

## Mendefinisikan Struct

### C++

```cpp
struct Mahasiswa {
    string nim;      // teks
    string nama;     // teks
    float  ipk;      // bilangan desimal
    int    angkatan; // bilangan bulat
};
```

Definisi di atas baru **membuat cetakannya**, belum membuat variabelnya.

### Python

```python
from dataclasses import dataclass

@dataclass
class Mahasiswa:
    nim: str
    nama: str
    ipk: float
    angkatan: int
```

## Membuat Variabel Struct

Setelah struct didefinisikan, variabel bisa dibuat seperti tipe data biasa.

```cpp
Mahasiswa mhs1;                       // satu variabel
Mahasiswa mhs2, mhs3;                 // beberapa sekaligus, dipisah koma

// Mengisi nilainya
mhs1.nim = "231001";
mhs1.nama = "Rina";
mhs1.ipk = 3.75;
mhs1.angkatan = 2023;
```

Perhatikan tanda **koma** saat membuat beberapa variabel sekaligus — bukan titik koma.

## Mengakses Anggota

Anggota struct diakses memakai operator **titik** (`.`).

```cpp
cout << mhs1.nama;    // Rina
cout << mhs1.ipk;     // 3.75

mhs1.ipk = 3.90;      // mengubah nilai anggota
cout << mhs1.ipk;     // 3.90
```

### Python

```python
mhs1 = Mahasiswa(nim="231001", nama="Rina", ipk=3.75, angkatan=2023)

print(mhs1.nama)      # Rina
mhs1.ipk = 3.90       # mengubah nilai anggota
print(mhs1.ipk)       # 3.90
```

> [!INFO]
> Di Python, `mhs1.nama` juga memakai titik. Konsepnya sama: nama variabel, lalu titik, lalu nama anggota.

## Struct di Dalam Struct

Anggota struct boleh berupa struct lain. Ini disebut **nested struct**.

```cpp
struct Tanggal {
    int hari;
    int bulan;
    int tahun;
};

struct Mahasiswa {
    string  nama;
    Tanggal lahir;    // struct di dalam struct
};

Mahasiswa mhs;
mhs.nama = "Rina";
mhs.lahir.hari = 17;
mhs.lahir.bulan = 8;
mhs.lahir.tahun = 2005;

cout << mhs.lahir.tahun;   // 2005
```

Perhatikan `mhs.lahir.tahun` — dua titik, karena melewati dua lapisan.

## Array of Struct

Ini kombinasi yang sangat sering dipakai: banyak data dengan struktur sama.

```cpp
Mahasiswa daftar[3];

daftar[0].nama = "Rina";
daftar[1].nama = "Budi";
daftar[2].nama = "Sari";

for (int i = 0; i < 3; i++) {
    cout << daftar[i].nama << endl;
}
```

Perhatikan `daftar[i].nama` — kurung siku untuk memilih elemen, titik untuk memilih anggota.

## Menyalin Struct

Berbeda dari array, struct **bisa** disalin langsung dengan tanda sama dengan.

```cpp
Mahasiswa a;
a.nama = "Rina";
a.ipk = 3.75;

Mahasiswa b = a;      // seluruh isi ikut tersalin
cout << b.nama;       // Rina
```

> [!INFO]
> Di C++, penyalinan struct menyalin seluruh anggotanya. Ini berbeda dari array, yang tidak bisa disalin dengan `=`.

## Mengapa Struct Berguna

1. **Mengelompokkan data yang saling terkait** — nama, NIM, dan IPK memang satu kesatuan
2. **Menghindari banyak variabel terpisah** — `mhs1Nama`, `mhs1Nim`, `mhs1Ipk` menjadi `mhs1.nama`, `mhs1.nim`, `mhs1.ipk`
3. **Memudahkan pengiriman ke fungsi** — kirim satu struct, bukan lima parameter
4. **Dasar untuk struktur data lanjutan** — linked list dan tree dibangun dari struct

## Ringkasan

| Aspek | Keterangan |
|-------|------------|
| Isi | Beberapa variabel dengan tipe boleh berbeda |
| Cara akses | Operator titik (`.`) |
| Pemisah antar variabel | Tanda koma (`,`) |
| Bisa berisi struct lain | Ya — nested struct |
| Bisa disalin dengan `=` | Ya — berbeda dari array |', 1
from public.modul m where m.slug = 'struct-dasar';

-- ---------------------------------------------------------
-- POINTER
-- ---------------------------------------------------------
insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
select m.id, 'materi-pointer', 'Materi Pointer', E'Apa Itu Pointer
---
Pointer adalah variabel yang **menyimpan alamat memori**, bukan nilainya langsung.

Setiap variabel di program menempati lokasi tertentu di memori, dan setiap lokasi punya alamat. Pointer menyimpan alamat itu.

Analoginya seperti **catatan alamat rumah**: kertasnya bukan rumahnya, tetapi menunjukkan di mana rumah itu berada.

## Alamat Memori

Untuk melihat alamat sebuah variabel, pakai operator `&` (address-of).

```cpp
int nilai = 42;

cout << nilai;    // 42   — nilainya
cout << &nilai;   // 0x7ffd... — alamat memorinya
```

Alamat biasanya ditulis dalam bilangan heksadesimal.

## Mendeklarasikan Pointer

Pointer dideklarasikan dengan tanda **asterisk** (`*`) sebelum nama variabel.

```cpp
int nilai = 42;
int *p = &nilai;    // p menyimpan ALAMAT nilai
```

Perhatikan: `p` berisi alamat, bukan angka 42. Yang membuat `p` bertipe pointer adalah tanda `*` pada deklarasinya.

## Dua Operator Penting

| Operator | Nama | Fungsi |
|----------|------|--------|
| `&` | Address-of | Mengambil alamat sebuah variabel |
| `*` | Dereference | Mengakses nilai di alamat yang ditunjuk |

Contoh lengkapnya:

```cpp
int nilai = 42;
int *p = &nilai;     // p menunjuk ke nilai

cout << p;           // alamat (mis. 0x7ffd5e3a)
cout << *p;          // 42 — nilai di alamat itu
```

> [!INFO]
> Tanda `*` punya dua arti berbeda. Saat **deklarasi** (`int *p`), ia menandai bahwa p adalah pointer. Saat **dipakai** (`*p`), ia mengambil nilai di alamat yang ditunjuk.

## Mengubah Nilai Lewat Pointer

Inilah kekuatan pointer: mengubah nilai variabel lain tanpa menyentuh namanya.

```cpp
int nilai = 42;
int *p = &nilai;

*p = 100;            // mengubah nilai lewat pointer

cout << nilai;       // 100 — variabel aslinya ikut berubah
cout << *p;          // 100
```

Kedua baris terakhir mencetak angka yang sama, karena keduanya merujuk ke lokasi memori yang sama.

### Python

Python tidak memakai pointer eksplisit seperti C++. Yang paling dekat adalah referensi objek:

```python
nilai = 42
p = nilai          # p menunjuk nilai yang sama

print(p)           # 42
```

> [!PERHATIAN]
> Python tidak punya operator `&` dan `*`. Semua variabel di Python sebenarnya sudah berupa referensi, tetapi tidak bisa dimanipulasi alamatnya seperti di C++.

## Pointer dan Array

Nama array sebenarnya adalah **alamat elemen pertamanya**. Karena itu array dan pointer bisa dipakai bertukar.

```cpp
int B[5] = {10, 20, 30, 40, 50};

cout << B[2];      // 30
cout << *(B + 2);  // 30 — cara yang sama, ditulis lain
```

`B[2]` dan `*(B + 2)` menghasilkan nilai yang identik. Inilah alasan indeks array dimulai dari 0: elemen pertama adalah `*(B + 0)`, yaitu B itu sendiri.

### Aritmetika Pointer

Menambahkan angka ke pointer tidak menambah satu byte, tetapi menambah **satu elemen**:

```cpp
int B[5] = {10, 20, 30, 40, 50};
int *p = B;         // menunjuk elemen ke-0

cout << *p;         // 10
p++;                // maju satu elemen
cout << *p;         // 20
```

Kalau `int` berukuran 4 byte, `p++` menambah alamatnya sebanyak 4 byte — bukan 1 byte.

## Alokasi Memori Dinamis

Array biasa ukurannya tetap sejak dibuat. Kalau ukuran baru diketahui saat program berjalan, dipakai **alokasi dinamis**.

Fungsi utamanya di C adalah `malloc()`, yang meminta sejumlah byte dari sistem.

### C

```c
#include <stdlib.h>

int n = 5;
int *arr = malloc(n * sizeof(int));   // minta memori untuk 5 int

if (arr == NULL) {
    // alokasi gagal — memori tidak tersedia
    return 1;
}

for (int i = 0; i < n; i++) {
    arr[i] = (i + 1) * 10;
}

printf("%d", arr[2]);   // 30

free(arr);              // WAJIB: kembalikan memori
arr = NULL;
```

### C++

```cpp
int n = 5;
int *arr = new int[n];     // alokasi

for (int i = 0; i < n; i++) {
    arr[i] = (i + 1) * 10;
}

cout << arr[2];            // 30

delete[] arr;              // WAJIB: kembalikan memori
arr = nullptr;
```

> [!BAHAYA]
> Memori hasil `malloc()` atau `new` **harus** dikembalikan dengan `free()` atau `delete[]`. Kalau tidak, terjadi **memory leak** — memori terus terpakai sampai program ditutup.

> [!PERHATIAN]
> Setelah `free(arr)`, pointer masih menyimpan alamat lama. Mengaksesnya adalah undefined behavior. Biasakan langsung mengisi dengan `NULL` atau `nullptr`.

## Keunggulan Pointer

1. **Alokasi dinamis** — ukuran ditentukan saat program berjalan, bukan saat menulis kode
2. **Efisien** — mengirim alamat jauh lebih murah daripada menyalin data besar
3. **Mengubah nilai asli** — fungsi bisa mengubah variabel pemanggilnya
4. **Dasar struktur data lanjutan** — linked list, tree, dan graph dibangun dari pointer

## Pointer ke Struct

Anggota struct bisa diakses dari pointer memakai tanda **panah** (`->`).

```cpp
struct Mahasiswa {
    string nama;
    float ipk;
};

Mahasiswa mhs;
mhs.nama = "Rina";
mhs.ipk = 3.75;

Mahasiswa *p = &mhs;

cout << p->nama;    // Rina — sama dengan (*p).nama
cout << p->ipk;     // 3.75
```

`p->nama` adalah singkatan dari `(*p).nama`. Keduanya sama, tetapi tanda panah lebih mudah dibaca.

## Ringkasan

| Aspek | Keterangan |
|-------|------------|
| Isi pointer | Alamat memori, bukan nilai langsung |
| Tanda deklarasi | Asterisk (`*`) |
| Ambil alamat | Operator `&` |
| Akses nilai | Operator `*` (dereference) |
| Alokasi dinamis | `malloc()` di C, `new` di C++ |
| Wajib dikembalikan | `free()` atau `delete[]` |
| Akses anggota struct | Tanda panah (`->`) |', 1
from public.modul m where m.slug = 'pointer-dasar';

-- =========================================================
-- 4) Video pendukung (opsional, tidak memblokir progres)
--
--    Sumber: Seri Belajar C++ oleh Kelas Terbuka (Faqihza Mukhlish).
--    Video tetap ditautkan walau materi kini hanya satu bagian,
--    karena halaman Video menampilkannya terpisah dari modul.
-- =========================================================

insert into public.video (modul_id, youtube_id, judul, deskripsi, durasi_detik, urutan)
select m.id, v.youtube_id, v.judul, v.deskripsi, v.durasi_detik, v.urutan
from public.modul m
join (values
  ('array-dasar',
   '8WhUADLI4RQ',
   E'Belajar C++ [Dasar] - 42 - Pendahuluan Array',
   E'Konsep dasar array, deklarasi, pengindeksan elemen, serta representasi elemen array yang tersimpan berurutan di memori.',
   1033,
   1),
  ('struct-dasar',
   'ELCI_U4OF5w',
   E'Belajar C++ [Dasar] - 56 - Struct',
   E'Membuat tipe data bentukan baru dengan struct, mengelompokkan variabel bertipe heterogen, serta mengakses member dengan operator titik.',
   595,
   1),
  ('pointer-dasar',
   'O1kWNj5Ikro',
   E'Belajar C++ [Dasar] - 38 - Pointer',
   E'Konsep pointer di C++, operator alamat (&), operator dereferensi (*), dan cara memanipulasi nilai variabel lewat alamat memori.',
   873,
   1)
) as v(slug, youtube_id, judul, deskripsi, durasi_detik, urutan)
on m.slug = v.slug;

commit;

-- =========================================================
-- VERIFIKASI
-- Harapan: 3 modul, 3 bagian, 3 video, 30 kartu, 30 soal, 120 opsi
-- =========================================================

-- select
--   (select count(*) from modul)       as modul,
--   (select count(*) from bagian_modul) as bagian,
--   (select count(*) from video)       as video,
--   (select count(*) from flashcard)   as kartu,
--   (select count(*) from soal)        as soal,
--   (select count(*) from opsi_soal)   as opsi;
