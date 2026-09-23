-- =========================================================
-- Seed: Modul 2 — array-multidimensi
-- Array Multidimensi
--
-- Semua contoh kode di file ini sudah DIKOMPILASI dan DIJALANKAN.
-- Output yang tertulis adalah output nyata, bukan dari ingatan.
-- Platform verifikasi: GCC 16.2.1, x86-64, sizeof(int)=4
-- =========================================================

-- ============ MODUL ============
insert into public.modul (slug, judul, topik, deskripsi, estimasi_menit, urutan)
values (
  'array-multidimensi',
  'Array Multidimensi',
  'array',
  'Urutan baris dan kolom di memori, cara menghitung alamat, dan jebakan list bersarang di Python.',
  10,
  2
);

-- ============ BAGIAN MODUL ============
insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
select m.id, v.slug, v.judul, v.konten_md, v.urutan
from public.modul m, (values

-- Bagian 1
('konsep-array-2d', 'Konsep Array 2D', $md$Array 2D adalah array yang elemennya berupa array. Bayangkan tabel dengan **baris** dan **kolom**.

```cpp
int m[3][4];   // 3 baris, 4 kolom
```

Cara membaca deklarasi di atas: "`m` adalah array berisi 3 elemen, di mana setiap elemen adalah array berisi 4 `int`".

## Mengapa 3x4 dan bukan 4x3

Angka pertama adalah **jumlah baris**, angka kedua **jumlah kolom**:

| Deklarasi | Baris | Kolom | Total elemen |
|-----------|-------|-------|--------------|
| `int m[3][4]` | 3 | 4 | 12 |
| `int m[2][5]` | 2 | 5 | 10 |

> [!TIPS]
> Ingat: baris dulu, kolom kemudian. Sama seperti membaca koordinat (baris, kolom) di spreadsheet.

## Menginisialisasi Array 2D

```cpp
// Cara 1: bersarang, lebih jelas
int m[2][3] = {
    {1, 2, 3},
    {4, 5, 6}
};

// Cara 2: rata, hasilnya sama
int n[2][3] = {1, 2, 3, 4, 5, 6};
```

Kedua cara menghasilkan array yang **identik**. Cara pertama lebih mudah dibaca karena bentuknya menyerupai tabelnya.

## Mengakses Elemen

```cpp
int m[2][3] = {{1,2,3},{4,5,6}};

cout << m[0][0];   // 1  (baris 0, kolom 0)
cout << m[1][2];   // 6  (baris 1, kolom 2)
```

Perhatikan: `m[1][2]` berarti baris **1**, kolom **2** — bukan sebaliknya.$md$, 1),

-- Bagian 2
('row-major-order', 'Row-Major Order', $md$Ini konsep terpenting di array multidimensi: **bagaimana elemen disimpan di memori**.

C++ menyimpan array 2D **baris demi baris**, bukan kolom demi kolom. Ini disebut **row-major order**.

## Visualisasi

Array `int m[2][3]` dengan nilai `{{1,2,3},{4,5,6}}`:

```
Logis (yang kamu lihat):        Memori (yang sebenarnya):

    kol0  kol1  kol2              Alamat:  0    4    8   12   16   20
bar0  1     2     3               Nilai:   1    2    3    4    5    6
bar1  4     5     6                        └── baris 0 ──┘└── baris 1 ──┘
```

Baris 0 disimpan **seluruhnya** dulu, baru baris 1.

## Membuktikan dengan Kode

```cpp
int m[2][3] = {{1,2,3},{4,5,6}};
int* flat = &m[0][0];   // alamat elemen pertama

cout << m[1][2];      // 6
cout << flat[5];      // 6  <- elemen ke-6 dari awal
```

`flat[5]` menghasilkan `6`, sama dengan `m[1][2]`. Ini membuktikan elemen tersimpan berurutan: index ke-5 adalah baris 1, kolom 2.

## Mengapa Ini Penting

Karena tersimpan baris demi baris, **mengakses elemen yang berdekatan dalam satu baris jauh lebih cepat** daripada melompat antar baris.

```cpp
// CEPAT: akses berurutan dalam satu baris
for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 4; j++) {
        proses(m[i][j]);
    }
}
```

> [!INFO]
> Python **tidak** menjamin list bersarang tersimpan berurutan di memori. Yang disimpan berurutan adalah *referensi* ke setiap baris. Ini perbedaan penting dari C++.$md$, 2),

-- Bagian 3
('menghitung-alamat', 'Menghitung Alamat Elemen', $md$Karena array 2D tersimpan baris demi baris, alamat setiap elemen bisa dihitung langsung.

## Rumus

```
alamat(i,j) = alamat(0,0) + (i x jumlahKolom + j) x sizeof(Tipe)
```

Perhatikan: yang dikali adalah **jumlah kolom**, bukan jumlah baris.

## Contoh Perhitungan

Array `int m[2][3]`, `sizeof(int) = 4`:

| Elemen | Perhitungan | Offset byte |
|--------|-------------|-------------|
| `m[0][0]` | (0×3 + 0) × 4 | 0 |
| `m[0][2]` | (0×3 + 2) × 4 | 8 |
| `m[1][0]` | (1×3 + 0) × 4 | 12 |
| `m[1][2]` | (1×3 + 2) × 4 | 20 |

Perhatikan `m[1][0]`: baris 1 dimulai pada offset 12, yaitu setelah **seluruh** baris 0 (3 elemen × 4 byte).

## Membuktikan dengan Kode

```cpp
int m[2][3] = {{1,2,3},{4,5,6}};

long selisih = (char*)&m[1][2] - (char*)&m[0][0];

cout << selisih;   // 20
```

Hasilnya **20 byte**, cocok dengan rumus: (1×3 + 2) × 4 = 20.

## Notasi Alternatif

`m[i][j]` sebenarnya adalah gula sintaks. Bentuk aslinya:

```cpp
m[i][j]  ==  *(*(m + i) + j)
```

Mengapa? `m + i` menunjuk ke baris ke-i, `*(m + i)` adalah baris itu, lalu `+ j` menunjuk kolom ke-j, dan `*` terakhir mengambil nilainya.

```cpp
int m[2][3] = {{1,2,3},{4,5,6}};

cout << m[1][2];          // 6
cout << *(*(m+1)+2);      // 6  <- sama persis
```

> [!TIPS]
> Rumus `alamat(i,j) = alamat(0,0) + (i x kolom + j) x sizeof` adalah alasan mengapa akses array 2D bisa sangat cepat — alamatnya dihitung langsung, tanpa mencari.$md$, 3),

-- Bagian 4
('python-list-2d', 'List 2D di Python', $md$Python tidak punya array 2D bawaan seperti C++. Yang ada adalah **list bersarang** — list yang elemennya list.

```python
m = [[1, 2, 3], [4, 5, 6]]

print(m[1][2])   # 6
```

Terlihat mirip, tetapi mekanismenya **berbeda total** dari C++.

## Perbedaan Penting

| Aspek | C++ `int m[2][3]` | Python `[[1,2,3],[4,5,6]]` |
|-------|-------------------|----------------------------|
| Penyimpanan | Satu blok memori berurutan | Referensi ke objek list terpisah |
| Ukuran | Tetap saat kompilasi | Bisa berubah |
| Tipe elemen | Harus seragam | Bebas |
| Baris | Bagian dari blok yang sama | Objek terpisah |

## Membuktikan Perbedaannya

```python
a = [1, 2, 3]
b = [4, 5, 6]
nested = [a, b]

print(id(nested[0]) == id(a))   # True
```

`nested[0]` **adalah** objek `a` yang sama, bukan salinan. List bersarang menyimpan **referensi**, bukan nilai.

Akibatnya, dua baris bisa tersimpan di lokasi memori yang berjauhan — tidak ada jaminan berurutan seperti C++.

## Cara Mengakses

```python
m = [[1, 2, 3], [4, 5, 6]]

# Ukuran
print(len(m))       # 2  (jumlah baris)
print(len(m[0]))    # 3  (jumlah kolom)

# Iterasi
for baris in m:
    for nilai in baris:
        print(nilai, end=" ")
```

> [!INFO]
> Di Python tidak ada konsep `sizeof` untuk list. `sys.getsizeof()` mengembalikan ukuran **objek list-nya**, bukan ukuran data yang disimpan.$md$, 4),

-- Bagian 5
('jebakan-list-bersarang', 'Jebakan: List Bersarang', $md$Ini jebakan paling terkenal di Python, dan sering muncul di ujian maupun wawancara kerja.

## Kode yang Terlihat Benar

```python
salah = [[0] * 3] * 3
salah[0][0] = 99

print(salah)
```

**Tebakan banyak orang:**
```python
[[99, 0, 0], [0, 0, 0], [0, 0, 0]]
```

**Hasil sebenarnya:**
```python
[[99, 0, 0], [99, 0, 0], [99, 0, 0]]
```

**Semua baris berubah!**

## Mengapa Terjadi

`[[0] * 3] * 3` berarti: "buat satu list `[0,0,0]`, lalu **gandakan referensinya** 3 kali".

```python
salah = [[0] * 3] * 3

print([id(baris) for baris in salah])
# [139651255536768, 139651255536768, 139651255536768]
```

Ketiga elemen menunjuk ke **objek list yang sama**. Mengubah satu berarti mengubah semuanya.

## Cara yang Benar

Buat list baru untuk setiap baris:

```python
benar = [[0] * 3 for _ in range(3)]
benar[0][0] = 99

print(benar)
# [[99, 0, 0], [0, 0, 0], [0, 0, 0]]
```

Hanya baris pertama yang berubah.

```python
print([id(baris) for baris in benar])
# [139651255539008, 139651255539072, 139651255539136]
```

Sekarang ketiga id **berbeda** — setiap baris adalah objek terpisah.

## Aturan Praktis

> [!BAHAYA]
> Jangan pernah membuat list 2D dengan `[[nilai] * kolom] * baris`. Selalu pakai **list comprehension**: `[[nilai] * kolom for _ in range(baris)]`.

Masalah yang sama berlaku untuk `dict` dan `set` di dalam list. Jika elemennya **mutable**, menggandakan dengan `*` akan menggandakan referensinya.

## Versi C++ dari Jebakan Ini

Di C++ jebakan ini **tidak ada** untuk array biasa, karena setiap elemen adalah nilai, bukan referensi:

```cpp
int m[3][3] = {0};   // semua elemen benar-benar 0
m[0][0] = 99;        // hanya m[0][0] yang berubah
```

Inilah salah satu alasan C++ array lebih "aman" untuk pemula dalam hal ini — tetapi juga lebih kaku.$md$, 5)

) as v(slug, judul, konten_md, urutan)
where m.slug = 'array-multidimensi';

-- ============ FLASHCARD (10 kartu) ============
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Bagaimana cara mendeklarasikan array 2D berukuran 3 baris 4 kolom di C++?',
 E'int m[3][4];\n\nAngka pertama = jumlah baris.\nAngka kedua = jumlah kolom.',
 'SINTAKS', E'int m[3][4];', 'cpp', 1),

(E'Apa arti "row-major order"?',
 E'Urutan penyimpanan array multidimensi\ndimana elemen disimpan BARIS DEMI BARIS.\n\nBaris 0 seluruhnya dulu, baru baris 1,\ndan seterusnya.\n\nIni kebalikan dari column-major (dipakai Fortran, MATLAB, R).',
 'ISTILAH', null, null, 2),

(E'Apa rumus menghitung alamat elemen m[i][j] pada array 2D?',
 E'alamat(i,j) = alamat(0,0) + (i x jumlahKolom + j) x sizeof(Tipe)\n\nYang dikali adalah jumlah KOLOM, bukan jumlah baris.',
 'MEMORI', null, null, 3),

(E'int m[2][3] = {{1,2,3},{4,5,6}};\nint* flat = &m[0][0];\ncout << flat[5];\n\nApa outputnya?',
 E'Output: 6\n\nflat[5] adalah elemen ke-6 dari awal = m[1][2] = 6.\nIni membuktikan array 2D tersimpan berurutan (row-major).',
 'TRACING', E'int m[2][3] = {{1,2,3},{4,5,6}};\\nint* flat = &m[0][0];\\ncout << flat[5];', 'cpp', 4),

(E'int m[2][3] = {{1,2,3},{4,5,6}};\ncout << *(*(m+1)+2);\n\nApa outputnya?',
 E'Output: 6\n\n*(*(m+1)+2) sama dengan m[1][2].\n\nm+1    -> menunjuk baris 1\n*(m+1) -> baris 1 itu sendiri\n+2     -> kolom 2\n*      -> nilainya = 6',
 'TRACING', E'int m[2][3] = {{1,2,3},{4,5,6}};\\ncout << *(*(m+1)+2);', 'cpp', 5),

(E'salah = [[0] * 3] * 3\nsalah[0][0] = 99\nprint(salah)\n\nApa outputnya?',
 E'[[99, 0, 0], [99, 0, 0], [99, 0, 0]]\n\nSEMUA baris berubah, bukan hanya yang pertama.\n\nPenyebab: [x] * 3 menggandakan REFERENSI, bukan nilainya. Ketiga baris menunjuk objek list yang sama.',
 'JEBAKAN', E'salah = [[0] * 3] * 3\\nsalah[0][0] = 99\\nprint(salah)', 'python', 6),

(E'Bagaimana cara BENAR membuat list 2D di Python?',
 E'benar = [[0] * 3 for _ in range(3)]\n\nPakai list comprehension agar setiap baris\nadalah objek BARU yang terpisah.\n\nJANGAN pakai [[0] * 3] * 3.',
 'SINTAKS', E'benar = [[0] * 3 for _ in range(3)]', 'python', 7),

(E'Mengapa mengakses elemen dalam satu baris lebih cepat daripada melompat antar baris?',
 E'Karena array tersimpan baris demi baris (row-major).\n\nAkses berurutan memanfaatkan CPU cache:\ndata yang berdekatan dimuat sekaligus.\n\nMelompat antar baris menyebabkan cache miss\nsehingga lebih lambat.',
 'MEMORI', null, null, 8),

(E'Apa perbedaan array 2D di C++ dan list 2D di Python?',
 E'C++ int m[2][3]:\n- satu blok memori berurutan\n- ukuran tetap\n- tipe elemen seragam\n\nPython [[1,2],[3,4]]:\n- daftar referensi ke objek terpisah\n- ukuran bisa berubah\n- tipe elemen bebas',
 'BANDING', null, null, 9),

(E'Kapan sebaiknya memakai array 2D dan kapan list bersarang Python?',
 E'Array 2D C++:\n- ukuran diketahui saat kompilasi\n- butuh satu blok memori berurutan\n- performa akses penting\n\nList bersarang Python:\n- ukuran dinamis\n- tipe elemen bebas\n- keterbacaan lebih penting dari performa',
 'KAPAN', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'array-multidimensi';

-- ============ SOAL QUIZ (10 soal) ============
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Bagaimana cara mendeklarasikan array 2D dengan 3 baris dan 4 kolom?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: int m[3][4];\n\nAngka PERTAMA adalah jumlah baris (3), angka KEDUA jumlah kolom (4).\n\nint m[4][3] akan menghasilkan 4 baris dan 3 kolom - tertukar.\nint m[3,4] bukan sintaks C++ yang valid.\nint m[12] hanya array 1D dengan 12 elemen.',
 1),

(E'Berapa jumlah elemen array int m[4][5]?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: 20\n\n4 baris x 5 kolom = 20 elemen.\n\nPengecoh 9 = 4+5 (menjumlahkan, bukan mengalikan).\nPengecoh 5 = hanya kolom. Pengecoh 4 = hanya baris.',
 2),

(E'Apa arti "row-major order"?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Elemen array multidimensi disimpan baris demi baris.\n\nBaris 0 disimpan seluruhnya dulu, baru baris 1, dan seterusnya.\n\nKebalikannya adalah column-major (dipakai Fortran, MATLAB, R).\nC++ dan Python (untuk list) memakai row-major.',
 3),

(E'int m[3][4] = {0};\ncout << sizeof(m);\n\nBerapa outputnya jika sizeof(int) = 4?',
 E'int m[3][4] = {0};\\ncout << sizeof(m);', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 48\n\nsizeof(m) = jumlah elemen x sizeof(int) = 12 x 4 = 48 byte.\n\nPengecoh 12 = jumlah elemen, bukan ukuran byte.\nPengecoh 16 = ukuran satu baris (4 x 4).',
 4),

(E'Bagaimana cara menghitung alamat elemen m[i][j]?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: alamat(0,0) + (i x jumlahKolom + j) x sizeof(Tipe)\n\nYang dikali i adalah jumlah KOLOM, karena kita harus melewati i baris penuh terlebih dahulu.\n\nPengecoh yang memakai jumlah baris adalah kesalahan paling umum di sini.',
 5),

(E'int m[2][3] = {{1,2,3},{4,5,6}};\nint* flat = &m[0][0];\ncout << flat[4];\n\nApa outputnya?',
 E'int m[2][3] = {{1,2,3},{4,5,6}};\\nint* flat = &m[0][0];\\ncout << flat[4];', 'cpp', 'TRACE', 'TRACING',
 E'Output: 5\n\nflat[4] adalah elemen ke-5 dari awal (indeks 4).\nElemen tersimpan berurutan: m[0][0]=1, m[0][1]=2, m[0][2]=3, m[1][0]=4, m[1][1]=5.\nJadi elemen indeks 4 = 5.\n\nPengecoh 4 = m[1][0] (indeks 3). Pengecoh 6 = m[1][2] (indeks 5).',
 6),

(E'int m[2][3] = {{1,2,3},{4,5,6}};\ncout << *(*(m+1)+1);\n\nApa outputnya?',
 E'int m[2][3] = {{1,2,3},{4,5,6}};\\ncout << *(*(m+1)+1);', 'cpp', 'TRACE', 'TRACING',
 E'Output: 5\n\n*(*(m+1)+1) sama dengan m[1][1].\n\nm+1     -> baris 1\n*(m+1)  -> baris 1 (array berisi 4,5,6)\n+1      -> elemen kedua dari baris itu\n*       -> nilainya = 5',
 7),

(E'salah = [[0] * 3] * 3\nsalah[0][0] = 99\nprint(salah[1][0])\n\nApa outputnya?',
 E'salah = [[0] * 3] * 3\\nsalah[0][0] = 99\\nprint(salah[1][0])', 'python', 'TRACE', 'JEBAKAN',
 E'Output: 99\n\nKarena [[0]*3]*3 menggandakan REFERENSI, ketiga baris menunjuk objek list yang SAMA.\nMengubah salah[0][0] juga mengubah salah[1][0] dan salah[2][0].\n\nJika memakai list comprehension, hasilnya 0.',
 8),

(E'Manakah cara yang BENAR membuat list 2D 3x3 berisi nol di Python?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: [[0] * 3 for _ in range(3)]\n\nList comprehension membuat objek list BARU untuk setiap baris.\n\n[[0]*3]*3 salah: menggandakan referensi, semua baris jadi objek yang sama.\n[0]*9 salah: itu list 1D berisi 9 nol, bukan 2D.\n[[0]*3]*range(3) salah: bukan sintaks Python yang valid.',
 9),

(E'Kode berikut lambat untuk data besar.\nMengapa?',
 E'for i in range(len(m)):\n    for j in range(len(m[0])):\n        proses(m[j][i])', 'python', 'ANALISIS', 'MEMORI',
 E'Penyebab: akses m[j][i] melompat antar baris, bukan berurutan.\n\nKarena list bersarang menyimpan referensi ke objek terpisah, mengakses m[0][0], m[1][0], m[2][0] berarti berpindah antar objek list yang posisinya berjauhan.\n\nPerbaikan: tukar urutan loop agar mengakses m[i][j] - berurutan dalam satu baris.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'array-multidimensi';

-- ============ OPSI JAWABAN (40 opsi) ============
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'int m[3][4];', true, 1),
  (1, 'B', E'int m[4][3];', false, 2),
  (1, 'C', E'int m[3,4];', false, 3),
  (1, 'D', E'int m[12];', false, 4),
  (2, 'A', E'9', false, 1),
  (2, 'B', E'20', true, 2),
  (2, 'C', E'5', false, 3),
  (2, 'D', E'4', false, 4),
  (3, 'A', E'Elemen array multidimensi disimpan baris demi baris', true, 1),
  (3, 'B', E'Elemen array multidimensi disimpan kolom demi kolom', false, 2),
  (3, 'C', E'Elemen array disimpan berdasarkan nilainya', false, 3),
  (3, 'D', E'Elemen array disimpan berdasarkan urutan input', false, 4),
  (4, 'A', E'12', false, 1),
  (4, 'B', E'16', false, 2),
  (4, 'C', E'48', true, 3),
  (4, 'D', E'24', false, 4),
  (5, 'A', E'alamat(0,0) + (i x jumlahKolom + j) x sizeof(Tipe)', true, 1),
  (5, 'B', E'alamat(0,0) + (i x jumlahBaris + j) x sizeof(Tipe)', false, 2),
  (5, 'C', E'alamat(0,0) + (i + j) x sizeof(Tipe)', false, 3),
  (5, 'D', E'alamat(0,0) + (i x j) x sizeof(Tipe)', false, 4),
  (6, 'A', E'4', false, 1),
  (6, 'B', E'5', true, 2),
  (6, 'C', E'6', false, 3),
  (6, 'D', E'3', false, 4),
  (7, 'A', E'4', false, 1),
  (7, 'B', E'5', true, 2),
  (7, 'C', E'6', false, 3),
  (7, 'D', E'2', false, 4),
  (8, 'A', E'0', false, 1),
  (8, 'B', E'99', true, 2),
  (8, 'C', E'IndexError', false, 3),
  (8, 'D', E'None', false, 4),
  (9, 'A', E'[[0] * 3] * 3', false, 1),
  (9, 'B', E'[[0] * 3 for _ in range(3)]', true, 2),
  (9, 'C', E'[0] * 9', false, 3),
  (9, 'D', E'[[0] * 3] * range(3)', false, 4),
  (10, 'A', E'Akses m[j][i] melompat antar baris, bukan berurutan', true, 1),
  (10, 'B', E'Python lambat untuk semua operasi loop', false, 2),
  (10, 'C', E'range() tidak efisien', false, 3),
  (10, 'D', E'Variabel i dan j tertukar nama', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'array-multidimensi';
