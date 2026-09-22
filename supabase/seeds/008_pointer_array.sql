-- =========================================================
-- Seed: Modul 8 — pointer-array
-- Pointer & Array: Aritmetika Pointer
-- Semua contoh kode DIKOMPILASI dan DIJALANKAN (GCC 16.2.1)
-- Klaim UB diverifikasi di docs/riset/04-RISET-UB-POINTER.md
-- =========================================================

insert into public.modul (slug, judul, topik, deskripsi, estimasi_menit, urutan)
values ('pointer-array', 'Pointer & Array: Aritmetika Pointer', 'pointer',
  'Mengapa arr[i] sama dengan *(arr+i), apa itu decay, dan mengapa sizeof array hilang di fungsi.', 15, 8);

insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
select m.id, v.slug, v.judul, v.konten_md, v.urutan
from public.modul m, (values

('nama-array-sebagai-pointer', 'Nama Array sebagai Pointer', $md$Nama array, dalam banyak situasi, **berubah otomatis menjadi pointer** ke elemen pertamanya. Ini disebut **array-to-pointer decay**.

```cpp
int arr[5] = {10, 20, 30, 40, 50};

int* p = arr;      // arr berubah jadi pointer ke arr[0]
```

**Bukti:**

```cpp
cout << (arr == &arr[0]);   // 1 (true)
```

`arr` dan `&arr[0]` menghasilkan alamat yang **sama**.

## Kapan Decay Terjadi

| Situasi | Decay? |
|---------|--------|
| Dikirim ke fungsi | **Ya** |
| Di-assign ke pointer | **Ya** |
| Aritmetika (`arr + 1`) | **Ya** |
| `sizeof(arr)` | **Tidak** |
| `&arr` | **Tidak** |

## Kapan Decay TIDAK Terjadi

Ini penting — ada dua situasi di mana array tetap array:

```cpp
int arr[5];

sizeof(arr);   // 20 - ukuran ARRAY, bukan pointer
&arr;          // pointer ke ARRAY (int(*)[5]), bukan int*
```

## Perbedaan &arr dan arr

Keduanya menghasilkan alamat yang sama, tetapi **tipenya berbeda**:

| Ekspresi | Tipe | `+ 1` melompat |
|----------|------|----------------|
| `arr` | `int*` | 4 byte (satu elemen) |
| `&arr` | `int(*)[5]` | **20 byte** (seluruh array) |

**Bukti terukur:**

```cpp
cout << (char*)(arr + 1) - (char*)arr;      // 4
cout << (char*)(&arr + 1) - (char*)&arr;    // 20
```

Perhatikan: `&arr + 1` melompat **seluruh array** (20 byte), bukan satu elemen.

> [!INFO]
> `arr` dan `&arr` menghasilkan alamat yang sama, tetapi tipe dan perilaku aritmetikanya berbeda. Ini detail yang sering ditanyakan di wawancara kerja.

## Konsekuensi Decay

Karena array berubah jadi pointer saat dikirim ke fungsi, **informasi ukurannya hilang**. Ini dibahas di bagian berikutnya.$md$, 1),

('aritmetika-pointer', 'Aritmetika Pointer', $md$Aritmetika pointer berbeda dari aritmetika angka biasa.

## Aturan: Skala Mengikuti Tipe

`p + 1` **tidak** menambah 1 byte. Ia menambah **`sizeof(*p)` byte**.

```cpp
int arr[5];
int* p = arr;

cout << (char*)(p + 1) - (char*)p;   // 4 (sizeof(int))
```

| Tipe pointer | `p + 1` menambah |
|--------------|-------------------|
| `char*` | 1 byte |
| `int*` | 4 byte |
| `double*` | 8 byte |
| `Titik*` (struct) | `sizeof(Titik)` byte |

**Bukti terukur:**

```cpp
char c[4];   char* pc = c;
double d[3]; double* pd = d;

(char*)(pc + 1) - (char*)pc;   // 1
(char*)(pd + 1) - (char*)pd;   // 8
```

## Mengapa Skala Mengikuti Tipe

Karena tujuan `p + 1` adalah menunjuk **elemen berikutnya**, bukan byte berikutnya. Kalau `int*` menambah 1 byte, ia akan menunjuk ke tengah-tengah int — tidak berguna.

## Operasi yang Diizinkan

| Operasi | Contoh | Keterangan |
|---------|--------|------------|
| Tambah bilangan | `p + 3` | Lompat 3 elemen |
| Kurang bilangan | `p - 2` | Mundur 2 elemen |
| Selisih dua pointer | `p2 - p1` | Jumlah elemen antara keduanya |
| Increment | `p++` | Maju satu elemen |
| Perbandingan | `p1 < p2` | Bandingkan posisi (array sama) |

## Selisih Pointer

```cpp
int arr[5] = {10, 20, 30, 40, 50};
int* awal = &arr[0];
int* akhir = &arr[4];

cout << (akhir - awal);   // 4 (elemen, BUKAN byte)
```

Hasilnya **4 elemen**, bukan 16 byte. Operator `-` pada pointer menghasilkan jumlah elemen.

## Batas yang Aman

Untuk array berukuran `n`:

```
arr + i    LEGAL    jika  0 <= i <= n
*(arr + i) LEGAL    jika  0 <= i < n
```

Perhatikan batas atasnya **berbeda**:

- Membentuk pointer: boleh sampai `n` (one-past-the-end)
- Mendereferensi: hanya sampai `n-1`

> [!BAHAYA]
> Aritmetika pointer di luar batas ini adalah **undefined behavior**.
>
> ```cpp
> int arr[5];
> int* p = arr + 6;   // UB!
> int* q = arr - 1;   // UB!
> ```
>
> Yang mengejutkan: **melangkah lebih jauh dari one-past-the-end juga UB**, walaupun kamu tidak mendereferensinya.$md$, 2),

('kesetaraan-notasi', 'Kesetaraan Notasi', $md$Karena `arr` berubah jadi pointer dan `p + i` menunjuk elemen ke-i, maka:

```cpp
arr[i]  ==  *(arr + i)
```

Ini bukan kebetulan — `arr[i]` **didefinisikan** sebagai `*(arr + i)`.

## Semua Bentuk yang Setara

```cpp
int arr[5] = {10, 20, 30, 40, 50};

arr[3]        // 40
*(arr + 3)    // 40
*(3 + arr)    // 40  <- penjumlahan komutatif
3[arr]        // 40  <- valid, tapi JANGAN dipakai
```

**Bukti terukur:** keempatnya menghasilkan 40.

## Mengapa i[arr] Valid

Karena `arr[i]` diterjemahkan menjadi `*(arr + i)`, dan penjumlahan bersifat komutatif (`arr + i == i + arr`), maka `i[arr]` juga valid.

**Tetapi jangan dipakai.** Kode seperti `3[arr]` membingungkan pembaca dan tidak ada gunanya. Ini hanya menarik sebagai fakta bahasa.

## Notasi Pointer vs Indeks

| Notasi | Kapan dipakai |
|--------|---------------|
| `arr[i]` | **Paling jelas** — pakai ini |
| `*(arr + i)` | Saat menjelaskan cara kerja array |
| `*(p + i)` | Saat bekerja dengan pointer |
| `i[arr]` | Jangan dipakai — hanya fakta bahasa |

> [!TIPS]
> Pakai `arr[i]` untuk keterbacaan. Pahami `*(arr + i)` untuk mengerti **mengapa** array bisa diakses sangat cepat: alamat elemen dihitung langsung, tanpa mencari.

## Konsekuensi Penting

Karena `arr[i]` setara `*(arr + i)`, **array tidak menyimpan informasi batas**. Tidak ada cara bagi `arr` untuk tahu berapa panjangnya.

Inilah mengapa C++ tidak bisa mendeteksi akses di luar batas — informasinya memang tidak ada di array itu sendiri.

Bandingkan dengan Python: list Python **tahu** panjangnya, sehingga bisa melempar `IndexError`.$md$, 3),

('array-sebagai-parameter', 'Array sebagai Parameter', $md$Ini bagian paling penting di modul ini, karena menjelaskan bug yang sangat sering terjadi.

## Masalah: Ukuran Hilang

```cpp
void cetak(int arr[]) {
    cout << sizeof(arr);   // 8 (ukuran POINTER!)
}

int main() {
    int arr[5] = {1,2,3,4,5};
    cout << sizeof(arr);   // 20 (ukuran array)
    cetak(arr);
}
```

Di dalam fungsi, `sizeof(arr)` menghasilkan **8 byte** — ukuran pointer, bukan 20 byte ukuran array.

**Informasi ukurannya hilang.**

## Mengapa Terjadi

Parameter `int arr[]` sebenarnya adalah `int* arr`. Compiler menerjemahkannya:

```cpp
void cetak(int arr[]);     // sebenarnya:
void cetak(int* arr);      // sama saja
```

Karena array dikirim sebagai pointer, ukurannya tidak ikut.

## Tiga Cara Mengatasinya

**Cara 1: Kirim ukuran sebagai parameter**

```cpp
void cetak(int arr[], int n) {
    for (int i = 0; i < n; i++) {
        cout << arr[i] << " ";
    }
}

cetak(arr, 5);
```

Ini cara gaya C. Bekerja, tetapi berisiko: kalau `n` salah, terjadi akses di luar batas.

**Cara 2: Pakai referensi ke array**

```cpp
void cetak(int (&arr)[5]) {
    cout << sizeof(arr);   // 20 - ukuran array TETAP ADA
    for (int x : arr) cout << x << " ";
}
```

Dengan referensi, decay **tidak terjadi**. Ukuran tetap diketahui.

Kekurangannya: ukurannya harus diketahui saat kompilasi dan tertulis di tipe fungsi.

**Cara 3: Pakai std::span (C++20)**

```cpp
#include <span>

void cetak(std::span<int> arr) {
    for (int x : arr) cout << x << " ";
    cout << arr.size();   // ukuran tersimpan
}
```

`std::span` menyimpan **pointer DAN ukuran**. Ini solusi paling modern dan fleksibel.

## Perbandingan

| Cara | Ukuran tersimpan | Fleksibel |
|------|------------------|-----------|
| `int arr[]` | **Tidak** | Ya |
| `int (&arr)[5]` | **Ya** | Tidak (ukuran tetap) |
| `std::span<int>` | **Ya** | Ya |

> [!TIPS]
> Untuk kode C++ modern, pakai `std::span`. Untuk kode gaya C, selalu kirim ukuran sebagai parameter terpisah. Jangan pernah mengandalkan `sizeof` di dalam fungsi untuk array parameter — hasilnya selalu ukuran pointer.

## Pointer sebagai Parameter Bisa Mengubah Array

Ini keuntungannya — berbeda dari kirim nilai:

```cpp
void gandakan(int* a, int n) {
    for (int i = 0; i < n; i++) a[i] *= 2;
}

int arr[5] = {10, 20, 30, 40, 50};
gandakan(arr, 5);
// arr sekarang: 20 40 60 80 100
```

Karena yang dikirim adalah **alamat**, fungsi mengubah array **asli**.$md$, 4),

('python-list', 'List Python: Perbandingan', $md$Python tidak punya decay karena tidak punya pointer. Tetapi ada perbedaan perilaku yang perlu dipahami.

## List Python Tahu Panjangnya

```python
arr = [10, 20, 30, 40, 50]

print(len(arr))   # 5 - selalu bisa
```

Di C++, `len()` tidak ada untuk array yang dikirim ke fungsi. Di Python, list selalu tahu panjangnya.

## Indeks Negatif

```python
arr = [10, 20, 30, 40, 50]

print(arr[-1])   # 50  - elemen terakhir
print(arr[-2])   # 40  - kedua dari belakang
```

Fitur ini **tidak ada** di C++.

## Slicing MENYALIN

```python
arr = [10, 20, 30, 40, 50]
s = arr[1:4]

s[0] = 999

print(arr)   # [10, 20, 30, 40, 50] - TIDAK berubah
print(s)     # [999, 30, 40]
```

Di C++, mengakses lewat pointer **tidak** menyalin — mengubahnya akan mengubah data asli.

```cpp
// C++
int arr[5] = {10,20,30,40,50};
int* p = &arr[1];

p[0] = 999;
// arr sekarang: 10 999 30 40 50 - BERUBAH
```

**Perbedaan penting:**

| Operasi | C++ pointer | Python slice |
|---------|-------------|--------------|
| Mengakses sebagian | Tidak menyalin | **Menyalin** |
| Mengubah hasil | Mengubah asli | **Tidak mengubah asli** |

## Iterasi

```python
# Cara Pythonic
for nilai in arr:
    print(nilai)

# Dengan indeks
for i in range(len(arr)):
    print(arr[i])

# Dengan enumerate
for i, nilai in enumerate(arr):
    print(i, nilai)
```

## Perbandingan Lengkap

| Aspek | C++ `int arr[5]` | Python `list` |
|-------|------------------|---------------|
| Tahu panjangnya | Hanya di scope asal | **Selalu** |
| Decay | **Ya** | Tidak ada konsep ini |
| Indeks negatif | Tidak | **Ya** |
| Slice menyalin | Tidak | **Ya** |
| Ukuran | Tetap | Dinamis |
| Aritmetika pointer | Ya | Tidak bisa |

> [!INFO]
> Python menghilangkan decay dengan menyimpan panjang di dalam objek list. Ini salah satu alasan list Python lebih aman, tetapi juga sedikit lebih berat daripada array C++.$md$, 5)

) as v(slug, judul, konten_md, urutan)
where m.slug = 'pointer-array';

-- ============ FLASHCARD (22 kartu) ============
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values

('Apa itu array-to-pointer decay?',
 E'Perubahan otomatis nama array menjadi pointer ke elemen\npertamanya dalam ekspresi tertentu.\n\nint arr[5];\nint* p = arr;   // arr decay jadi &arr[0]\n\nAkibatnya informasi ukuran bisa hilang.',
 'ISTILAH', null, null, 1),

('Kapan array-to-pointer decay terjadi?',
 E'TERJADI saat:\n- dikirim ke fungsi\n- di-assign ke pointer\n- aritmetika (arr + 1)\n\nTIDAK terjadi saat:\n- sizeof(arr)\n- &arr',
 'MEMORI', null, null, 2),

(E'int arr[5];\ncout << (arr == &arr[0]);',
 E'Output: 1 (true)\n\nNama array dan alamat elemen pertamanya\nmenghasilkan alamat yang SAMA.\n\nIni bukti decay: arr berubah jadi pointer ke arr[0].',
 'TRACING', 'int arr[5];\ncout << (arr == &arr[0]);  // 1', 'cpp', 3),

('Apa perbedaan arr dan &arr?',
 E'Keduanya alamat SAMA, tapi TIPE berbeda:\n\narr  : int*        -> +1 melompat 4 byte (satu elemen)\n&arr : int(*)[5]   -> +1 melompat 20 byte (SELURUH array)\n\nBukti terukur:\n(char*)(arr+1)-(char*)arr    = 4\n(char*)(&arr+1)-(char*)&arr  = 20',
 'BANDING', null, null, 4),

('Apa yang terjadi pada sizeof(arr) di dalam fungsi?',
 E'Menghasilkan ukuran POINTER (8 byte), bukan ukuran array.\n\nvoid f(int arr[]) {\n    sizeof(arr);   // 8, bukan 20!\n}\n\nPenyebab: parameter int arr[] sebenarnya adalah int* arr.\nInformasi ukuran HILANG.',
 'JEBAKAN', 'void f(int arr[]) {\n    sizeof(arr);  // 8, bukan ukuran array\n}', 'cpp', 5),

('Bagaimana cara mengirim array ke fungsi agar ukurannya tidak hilang?',
 E'Tiga cara:\n\n1. Kirim ukuran sebagai parameter:\n   void f(int arr[], int n)\n\n2. Referensi ke array:\n   void f(int (&arr)[5])\n\n3. std::span (C++20):\n   void f(std::span<int> arr)',
 'SINTAKS', 'void f(int arr[], int n);\nvoid g(int (&arr)[5]);\nvoid h(std::span<int> arr);', 'cpp', 6),

('Bagaimana cara mengubah array dari dalam fungsi?',
 E'Kirim sebagai POINTER:\n\nvoid gandakan(int* a, int n) {\n    for (int i = 0; i < n; i++) a[i] *= 2;\n}\n\nint arr[5] = {10,20,30,40,50};\ngandakan(arr, 5);\n// arr jadi: 20 40 60 80 100\n\nKarena yang dikirim ALAMAT, array ASLI berubah.',
 'SINTAKS', 'void gandakan(int* a, int n) {\n    for (int i = 0; i < n; i++) a[i] *= 2;\n}', 'cpp', 7),

('Berapa byte yang ditambah p + 1 jika p adalah int*?',
 E'4 byte (= sizeof(int)).\n\nAritmetika pointer mengikuti SKALA TIPE,\nbukan 1 byte.\n\nchar*   -> +1 byte\ndouble* -> +8 byte\nint*    -> +4 byte',
 'MEMORI', null, null, 8),

('Mengapa aritmetika pointer mengikuti skala tipe, bukan 1 byte?',
 E'Karena tujuan p + 1 adalah menunjuk ELEMEN BERIKUTNYA,\nbukan byte berikutnya.\n\nKalau int* menambah 1 byte, ia akan menunjuk ke\ntengah-tengah int - tidak berguna.\n\nDengan skala tipe, p + 1 selalu tepat di elemen berikutnya.',
 'MEMORI', null, null, 9),

(E'int arr[5] = {10, 20, 30, 40, 50};\nint* awal = &arr[0];\nint* akhir = &arr[4];\ncout << (akhir - awal);',
 E'Output: 4\n\nSelisih dua pointer menghasilkan JUMLAH ELEMEN,\nbukan byte.\n\n(akhir - awal) = 4 elemen, bukan 16 byte.',
 'TRACING', 'int arr[5] = {10, 20, 30, 40, 50};\ncout << (&arr[4] - &arr[0]);  // 4', 'cpp', 10),

('Apa aturan batas aman aritmetika pointer pada array berukuran n?',
 E'MEMBENTUK pointer:\n  arr + i LEGAL jika 0 <= i <= n\n  arr + i UB    jika i < 0 atau i > n\n\nDEREFERENSI:\n  *(arr + i) LEGAL jika 0 <= i < n\n  *(arr + i) UB    jika i == n\n\nPerhatikan batas atasnya BERBEDA.',
 'MEMORI', null, null, 11),

('Apakah arr[i] sama dengan *(arr + i)?',
 E'YA, keduanya IDENTIK.\n\narr[i] DIDEfinisikan sebagai *(arr + i).\n\nint arr[5] = {10,20,30,40,50};\narr[3]     = 40\n*(arr + 3) = 40\n\nIni bukan kebetulan - ini definisi bahasanya.',
 'MEMORI', null, null, 12),

('Mengapa i[arr] juga valid?',
 E'Karena arr[i] diterjemahkan jadi *(arr + i),\ndan penjumlahan bersifat KOMUTATIF:\n\n*(arr + i) == *(i + arr)\n\nJadi 3[arr] juga valid dan bernilai sama dengan arr[3].\n\nTETAPI jangan dipakai - membingungkan pembaca.',
 'JEBAKAN', 'int arr[5] = {10,20,30,40,50};\ncout << 3[arr];  // 40 - valid tapi jangan dipakai', 'cpp', 13),

('Mengapa C++ tidak bisa mendeteksi akses array di luar batas?',
 E'Karena array TIDAK MENYIMPAN informasi batas.\n\narr[i] hanya diterjemahkan jadi *(arr + i) -\nkomputer menghitung alamat dan mengaksesnya.\nTidak ada yang memeriksa apakah i masih dalam rentang.\n\nBandingkan Python: list tahu panjangnya,\nsehingga bisa melempar IndexError.',
 'MEMORI', null, null, 14),

('Apa keuntungan std::span dibanding int arr[] sebagai parameter?',
 E'std::span menyimpan POINTER dan UKURAN sekaligus.\n\nvoid f(std::span<int> arr) {\n    cout << arr.size();   // ukuran tersimpan!\n    for (int x : arr) cout << x;\n}\n\nMasalah decay teratasi: ukuran tidak hilang,\ndan tetap fleksibel untuk array berbagai ukuran.',
 'KAPAN', 'void f(std::span<int> arr) {\n    cout << arr.size();\n}', 'cpp', 15),

('Bagaimana cara mengirim array ke fungsi agar tidak bisa diubah?',
 E'Pakai const:\n\nvoid cetak(const int arr[], int n);\n\natau dengan span:\nvoid cetak(std::span<const int> arr);\n\nconst mencegah fungsi mengubah data.\nIni praktik baik untuk fungsi yang hanya membaca.',
 'SINTAKS', 'void cetak(const int arr[], int n);', 'cpp', 16),

('Apa itu std::span?',
 E'Pandangan (view) ke deretan elemen yang sudah ada.\nMenyimpan POINTER dan UKURAN.\n\n#include <span>\n\nvoid f(std::span<int> arr);\n\nTIDAK memiliki data - hanya melihat.\nSolusi modern untuk masalah decay (C++20).',
 'ISTILAH', null, null, 17),

('Apakah list Python tahu panjangnya?',
 E'YA, selalu.\n\narr = [10, 20, 30]\nprint(len(arr))   # 3\n\nBerbeda dari array C++ yang kehilangan\ninformasi ukuran saat dikirim ke fungsi.\n\nIni salah satu alasan list Python lebih aman.',
 'BANDING', null, null, 18),

(E'arr = [10, 20, 30, 40, 50]\ns = arr[1:4]\ns[0] = 999\nprint(arr[1])',
 E'Output: 20\n\nSlicing Python MENYALIN elemen.\nMengubah s[0] TIDAK mengubah arr[1].\n\nBandingkan C++:\nint* p = &arr[1];\np[0] = 999;   // arr[1] IKUT berubah\n\nPerbedaan penting: slice menyalin, pointer tidak.',
 'TRACING', 'arr = [10, 20, 30, 40, 50]\ns = arr[1:4]\ns[0] = 999\nprint(arr[1])', 'python', 19),

('Apa perbedaan slice Python dan pointer C++?',
 E'Slice Python MENYALIN:\n  s = arr[1:4]   -> salinan baru\n  s[0] = 999     -> arr TIDAK berubah\n\nPointer C++ TIDAK menyalin:\n  int* p = &arr[1];\n  p[0] = 999;    -> arr[1] IKUT berubah\n\nIni perbedaan mendasar: nilai vs referensi.',
 'BANDING', null, null, 20),

('Apakah Python punya indeks negatif?',
 E'YA.\n\narr = [10, 20, 30, 40, 50]\nprint(arr[-1])   # 50 (terakhir)\nprint(arr[-2])   # 40 (kedua dari belakang)\n\nFitur ini TIDAK ada di C++.\nDi C++ arr[-1] adalah UB (di luar batas).',
 'BANDING', 'arr = [10, 20, 30, 40, 50]\nprint(arr[-1])  # 50', 'python', 21),

('Apa saja cara mengiterasi list Python?',
 E'1. Langsung (paling Pythonic):\n   for nilai in arr: print(nilai)\n\n2. Dengan indeks:\n   for i in range(len(arr)): print(arr[i])\n\n3. Dengan enumerate:\n   for i, nilai in enumerate(arr): print(i, nilai)',
 'SINTAKS', 'for nilai in arr:\n    print(nilai)\n\nfor i, nilai in enumerate(arr):\n    print(i, nilai)', 'python', 22)

) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'pointer-array';

-- ============ SOAL QUIZ (20 soal) ============
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values

('Apa itu array-to-pointer decay?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Perubahan otomatis nama array menjadi pointer ke elemen pertamanya.\n\nint arr[5];\nint* p = arr;   // arr decay jadi &arr[0]\n\nTerjadi saat dikirim ke fungsi, di-assign ke pointer, atau dalam aritmetika.\nTIDAK terjadi pada sizeof(arr) dan &arr.',
 1),

(E'int arr[5];\ncout << (arr == &arr[0]);',
 'int arr[5];\ncout << (arr == &arr[0]);',
 'cpp', 'TRACE', 'TRACING',
 E'Output: 1\n\nNama array dan alamat elemen pertamanya menghasilkan alamat yang SAMA.\nIni bukti decay: arr berubah jadi pointer ke arr[0].\n\nPengecoh 0 salah - keduanya memang alamat yang sama.',
 2),

('Apa perbedaan arr dan &arr?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Tipenya berbeda, sehingga aritmetikanya berbeda.\n\narr  : int*       -> +1 melompat 4 byte (satu elemen)\n&arr : int(*)[5]  -> +1 melompat 20 byte (SELURUH array)\n\nKeduanya menghasilkan ALAMAT yang sama, tetapi tipe dan perilaku +1 berbeda.\n\nIni detail yang sering ditanyakan di wawancara kerja.',
 3),

('Berapa nilai sizeof(arr) di dalam fungsi void f(int arr[])?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: 8 byte - ukuran pointer, bukan ukuran array.\n\nParameter int arr[] sebenarnya adalah int* arr. Compiler menerjemahkannya, sehingga informasi ukuran array HILANG.\n\nPengecoh "20 byte" salah - itu ukuran array di main, bukan di fungsi.',
 4),

('Bagaimana cara mengirim array ke fungsi agar ukurannya tidak hilang?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Kirim ukuran sebagai parameter, pakai referensi ke array, atau pakai std::span.\n\n1. void f(int arr[], int n)\n2. void f(int (&arr)[5])\n3. void f(std::span<int> arr)\n\nstd::span adalah solusi modern (C++20) karena menyimpan pointer DAN ukuran.',
 5),

('Mengapa aritmetika pointer mengikuti skala tipe, bukan 1 byte?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena tujuan p + 1 adalah menunjuk elemen berikutnya, bukan byte berikutnya.\n\nKalau int* menambah 1 byte, ia akan menunjuk ke tengah-tengah int - tidak berguna. Dengan skala tipe, p + 1 selalu tepat di elemen berikutnya.\n\nchar* +1 = 1 byte, int* +1 = 4 byte, double* +1 = 8 byte.',
 6),

(E'int arr[5] = {10, 20, 30, 40, 50};\ncout << (&arr[4] - &arr[0]);',
 'int arr[5] = {10, 20, 30, 40, 50};\ncout << (&arr[4] - &arr[0]);',
 'cpp', 'TRACE', 'TRACING',
 E'Output: 4\n\nSelisih dua pointer menghasilkan JUMLAH ELEMEN, bukan byte.\n\n(&arr[4] - &arr[0]) = 4 elemen, bukan 16 byte.\n\nPengecoh 16 = menghitung byte (4 elemen x 4 byte).',
 7),

('Apakah arr[i] sama dengan *(arr + i)?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Ya, keduanya identik.\n\narr[i] DIDEFINISIKAN sebagai *(arr + i). Ini bukan kebetulan atau optimasi compiler - ini definisi bahasanya.\n\nKonsekuensinya: array tidak menyimpan informasi batas, sehingga C++ tidak bisa mendeteksi akses di luar batas.',
 8),

('Mengapa i[arr] juga valid?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena arr[i] diterjemahkan jadi *(arr + i), dan penjumlahan bersifat komutatif.\n\n*(arr + i) == *(i + arr)\n\nJadi 3[arr] valid dan bernilai sama dengan arr[3].\n\nTETAPI jangan dipakai - membingungkan pembaca dan tidak ada gunanya. Ini hanya fakta bahasa yang menarik.',
 9),

('Mengapa C++ tidak bisa mendeteksi akses array di luar batas?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena array tidak menyimpan informasi batas.\n\narr[i] hanya diterjemahkan jadi *(arr + i) - komputer menghitung alamat dan mengaksesnya. Tidak ada yang memeriksa apakah i masih dalam rentang.\n\nBandingkan Python: list tahu panjangnya, sehingga bisa melempar IndexError.',
 10),

('Apa aturan batas aman aritmetika pointer pada array berukuran n?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: arr + i legal untuk 0 <= i <= n; *(arr + i) legal untuk 0 <= i < n.\n\nMEMBENTUK pointer : 0 <= i <= n\nDEREFERENSI       : 0 <= i < n\n\nPerhatikan batas atasnya BERBEDA. Membentuk pointer boleh sampai n (one-past-the-end), tetapi mendereferensinya tidak.',
 11),

(E'int arr[5] = {10, 20, 30, 40, 50};\nint* p = arr;\ncout << *(p + 3);',
 'int arr[5] = {10, 20, 30, 40, 50};\nint* p = arr;\ncout << *(p + 3);',
 'cpp', 'TRACE', 'TRACING',
 E'Output: 40\n\np menunjuk ke arr[0]. p + 3 menunjuk ke arr[3]. *(p + 3) = arr[3] = 40.\n\np + 3 menambah 3 x sizeof(int) = 12 byte dari alamat awal.\n\nPengecoh 30 = arr[2]. Pengecoh 50 = arr[4].',
 12),

('Apa keuntungan utama std::span dibanding int arr[] sebagai parameter?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: std::span menyimpan pointer DAN ukuran sekaligus.\n\nvoid f(std::span<int> arr) {\n    cout << arr.size();   // ukuran tersimpan\n}\n\nMasalah decay teratasi: ukuran tidak hilang, dan tetap fleksibel untuk array berbagai ukuran.\n\nint (&arr)[5] juga menyimpan ukuran, tetapi ukurannya harus diketahui saat kompilasi.',
 13),

('Bagaimana cara mengirim array ke fungsi agar tidak bisa diubah?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Pakai const.\n\nvoid cetak(const int arr[], int n);\n\natau dengan span:\nvoid cetak(std::span<const int> arr);\n\nconst mencegah fungsi mengubah data. Ini praktik baik untuk fungsi yang hanya membaca - mencegah bug yang tidak disengaja.',
 14),

('Apa perbedaan slice Python dan pointer C++?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Slice Python MENYALIN; pointer C++ TIDAK menyalin.\n\nPython: s = arr[1:4] -> salinan baru. s[0] = 999 tidak mengubah arr.\n\nC++: int* p = &arr[1]; p[0] = 999 -> arr[1] IKUT berubah.\n\nIni perbedaan mendasar antara bahasa dengan nilai dan bahasa dengan referensi.',
 15),

(E'arr = [10, 20, 30, 40, 50]\ns = arr[1:4]\ns[0] = 999\nprint(arr[1])',
 'arr = [10, 20, 30, 40, 50]\ns = arr[1:4]\ns[0] = 999\nprint(arr[1])',
 'python', 'TRACE', 'BANDING',
 E'Output: 20\n\nSlicing Python MENYALIN elemen. Mengubah s[0] tidak mengubah arr[1].\n\nBandingkan C++:\nint* p = &arr[1];\np[0] = 999;   // arr[1] IKUT berubah\n\nPengecoh 999 salah - itu mengira slice menunjuk ke elemen asli.',
 16),

('Apakah Python punya indeks negatif?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Ya. arr[-1] adalah elemen terakhir, arr[-2] kedua dari belakang.\n\nFitur ini TIDAK ada di C++. Di C++, arr[-1] adalah undefined behavior karena di luar batas.\n\nIni salah satu kenyamanan Python yang hilang di C++.',
 17),

('Bagaimana cara mengubah array dari dalam fungsi?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Kirim sebagai pointer, lalu ubah elemennya.\n\nvoid gandakan(int* a, int n) {\n    for (int i = 0; i < n; i++) a[i] *= 2;\n}\n\nint arr[5] = {10,20,30,40,50};\ngandakan(arr, 5);\n// arr jadi: 20 40 60 80 100\n\nKarena yang dikirim ALAMAT, array ASLI berubah.',
 18),

('Apa yang terjadi jika mengakses arr[-1] pada array C++?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Undefined behavior - indeks negatif berada di luar batas array.\n\nint arr[5];\narr[-1];   // UB!\n\nBerbeda dari Python yang mendukung indeks negatif (arr[-1] = elemen terakhir).\n\nDi C++, indeks valid hanya 0 sampai n-1.',
 19),

('Mengapa list Python lebih aman daripada array C++?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Karena list Python menyimpan panjangnya, sehingga bisa mendeteksi akses di luar batas.\n\narr = [1, 2, 3]\narr[10]   # IndexError\n\nC++ tidak menyimpan batas, sehingga arr[10] adalah undefined behavior - bisa tampak berjalan normal.\n\nKonsekuensinya: Python lebih aman tetapi sedikit lebih berat.',
 20)

) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'pointer-array';

insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', 'Perubahan otomatis nama array menjadi pointer ke elemen pertamanya', true, 1),
  (1, 'B', 'Penghapusan array yang tidak terpakai', false, 2),
  (1, 'C', 'Konversi array menjadi list', false, 3),
  (1, 'D', 'Pembesaran array otomatis', false, 4),
  (2, 'A', '1', true, 1),
  (2, 'B', '0', false, 2),
  (2, 'C', 'Error', false, 3),
  (2, 'D', 'Bergantung compiler', false, 4),
  (3, 'A', 'arr bertipe int* (+1 = 4 byte); &arr bertipe int(*)[5] (+1 = 20 byte)', true, 1),
  (3, 'B', 'Keduanya bertipe sama dan berperilaku sama', false, 2),
  (3, 'C', 'arr adalah nilai, &arr adalah alamat', false, 3),
  (3, 'D', '&arr tidak valid untuk array', false, 4),
  (4, 'A', '8 byte - ukuran pointer, karena parameter sebenarnya adalah int*', true, 1),
  (4, 'B', '20 byte - sama seperti di main', false, 2),
  (4, 'C', '4 byte - ukuran satu int', false, 3),
  (4, 'D', 'Error kompilasi', false, 4),
  (5, 'A', 'Kirim ukuran sebagai parameter, pakai referensi ke array, atau pakai std::span', true, 1),
  (5, 'B', 'Pakai sizeof di dalam fungsi', false, 2),
  (5, 'C', 'Deklarasikan array sebagai global', false, 3),
  (5, 'D', 'Tidak bisa dilakukan di C++', false, 4),
  (6, 'A', 'Karena tujuan p + 1 adalah menunjuk elemen berikutnya, bukan byte berikutnya', true, 1),
  (6, 'B', 'Karena compiler mengoptimalkan aritmetika', false, 2),
  (6, 'C', 'Karena pointer menyimpan tipe data', false, 3),
  (6, 'D', 'Karena memori komputer berbasis blok', false, 4),
  (7, 'A', '4', true, 1),
  (7, 'B', '16', false, 2),
  (7, 'C', '1', false, 3),
  (7, 'D', 'Error', false, 4),
  (8, 'A', 'Ya, arr[i] didefinisikan sebagai *(arr + i)', true, 1),
  (8, 'B', 'Tidak, keduanya berbeda', false, 2),
  (8, 'C', 'Ya, tetapi hanya untuk array char', false, 3),
  (8, 'D', 'Ya, tetapi hanya di C++20 ke atas', false, 4),
  (9, 'A', 'Karena arr[i] menjadi *(arr + i) dan penjumlahan bersifat komutatif', true, 1),
  (9, 'B', 'Karena compiler memperbaiki urutan otomatis', false, 2),
  (9, 'C', 'Karena i[arr] adalah sintaks khusus', false, 3),
  (9, 'D', 'i[arr] sebenarnya tidak valid', false, 4),
  (10, 'A', 'Karena array tidak menyimpan informasi batas', true, 1),
  (10, 'B', 'Karena compiler terlalu lambat untuk memeriksa', false, 2),
  (10, 'C', 'Karena batas hanya diketahui saat runtime', false, 3),
  (10, 'D', 'Karena pemeriksaan batas dimatikan secara default', false, 4),
  (11, 'A', 'arr + i legal untuk 0 <= i <= n; *(arr + i) legal untuk 0 <= i < n', true, 1),
  (11, 'B', 'Keduanya legal untuk 0 <= i <= n', false, 2),
  (11, 'C', 'Keduanya legal untuk 0 <= i < n', false, 3),
  (11, 'D', 'Tidak ada batas selama alamatnya valid', false, 4),
  (12, 'A', '40', true, 1),
  (12, 'B', '30', false, 2),
  (12, 'C', '50', false, 3),
  (12, 'D', '10', false, 4),
  (13, 'A', 'std::span menyimpan pointer DAN ukuran sekaligus', true, 1),
  (13, 'B', 'std::span lebih cepat diakses', false, 2),
  (13, 'C', 'std::span menyalin array', false, 3),
  (13, 'D', 'std::span hanya untuk array char', false, 4),
  (14, 'A', 'Pakai const: void cetak(const int arr[], int n);', true, 1),
  (14, 'B', 'Deklarasikan array sebagai static', false, 2),
  (14, 'C', 'Kirim array dengan cara disalin', false, 3),
  (14, 'D', 'Tidak bisa dicegah di C++', false, 4),
  (15, 'A', 'Slice Python MENYALIN; pointer C++ TIDAK menyalin', true, 1),
  (15, 'B', 'Keduanya menyalin', false, 2),
  (15, 'C', 'Keduanya tidak menyalin', false, 3),
  (15, 'D', 'Slice tidak menyalin; pointer menyalin', false, 4),
  (16, 'A', '20', true, 1),
  (16, 'B', '999', false, 2),
  (16, 'C', '30', false, 3),
  (16, 'D', 'Error', false, 4),
  (17, 'A', 'Ya - arr[-1] adalah elemen terakhir', true, 1),
  (17, 'B', 'Tidak, Python tidak mendukung indeks negatif', false, 2),
  (17, 'C', 'Ya, tetapi hanya untuk list angka', false, 3),
  (17, 'D', 'Ya, tetapi arr[-1] adalah elemen pertama', false, 4),
  (18, 'A', 'Kirim sebagai pointer, lalu ubah elemennya di dalam fungsi', true, 1),
  (18, 'B', 'Kirim sebagai nilai biasa', false, 2),
  (18, 'C', 'Deklarasikan array sebagai const', false, 3),
  (18, 'D', 'Array tidak bisa diubah dari fungsi', false, 4),
  (19, 'A', 'Undefined behavior - indeks negatif di luar batas array', true, 1),
  (19, 'B', 'Mengembalikan elemen terakhir', false, 2),
  (19, 'C', 'Mengembalikan elemen pertama', false, 3),
  (19, 'D', 'Error kompilasi', false, 4),
  (20, 'A', 'Karena list Python menyimpan panjangnya sehingga bisa mendeteksi akses di luar batas', true, 1),
  (20, 'B', 'Karena Python lebih cepat dari C++', false, 2),
  (20, 'C', 'Karena Python tidak punya array', false, 3),
  (20, 'D', 'Karena Python memakai memori lebih sedikit', false, 4)
) as v(urutan_soal, label, teks, benar, urutan)
  on v.urutan_soal = s.urutan
where m.slug = 'pointer-array';
