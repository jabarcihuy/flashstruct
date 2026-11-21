-- Restore kurikulum penuh 10 modul sesuai docs/02-KURIKULUM.md.
-- ID tiga modul existing dipertahankan; seed 011/012 mengganti kartu, quiz, dan video.
begin;
update public.modul set judul='Dasar Array & Indeks',deskripsi='Konsep dasar array, indeks, dan akses elemen di C++ dan Python.',estimasi_menit=12 where slug='array-dasar';
update public.modul set judul='Mendefinisikan Struct',deskripsi='Mendefinisikan dan mengakses struct, serta padanannya dengan dataclass Python.',estimasi_menit=11 where slug='struct-dasar';
update public.modul set judul='Dasar Pointer & Alamat Memori',deskripsi='Memahami alamat memori, pointer, dan dereferensi di C++.',estimasi_menit=16 where slug='pointer-dasar';
delete from public.bagian_modul where modul_id in(select id from public.modul where slug in('struct-dasar','pointer-dasar'));
-- ==== 002_array_multidimensi.sql ====
-- =========================================================
-- Seed: Modul 2 â€” array-multidimensi
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

Perhatikan: `m[1][2]` berarti baris **1**, kolom **2** â€” bukan sebaliknya.$md$, 1),

-- Bagian 2
('row-major-order', 'Row-Major Order', $md$Ini konsep terpenting di array multidimensi: **bagaimana elemen disimpan di memori**.

C++ menyimpan array 2D **baris demi baris**, bukan kolom demi kolom. Ini disebut **row-major order**.

## Visualisasi

Array `int m[2][3]` dengan nilai `{{1,2,3},{4,5,6}}`:

```
Logis (yang kamu lihat):        Memori (yang sebenarnya):

    kol0  kol1  kol2              Alamat:  0    4    8   12   16   20
bar0  1     2     3               Nilai:   1    2    3    4    5    6
bar1  4     5     6                        â””â”€â”€ baris 0 â”€â”€â”˜â””â”€â”€ baris 1 â”€â”€â”˜
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
| `m[0][0]` | (0Ã—3 + 0) Ã— 4 | 0 |
| `m[0][2]` | (0Ã—3 + 2) Ã— 4 | 8 |
| `m[1][0]` | (1Ã—3 + 0) Ã— 4 | 12 |
| `m[1][2]` | (1Ã—3 + 2) Ã— 4 | 20 |

Perhatikan `m[1][0]`: baris 1 dimulai pada offset 12, yaitu setelah **seluruh** baris 0 (3 elemen Ã— 4 byte).

## Membuktikan dengan Kode

```cpp
int m[2][3] = {{1,2,3},{4,5,6}};

long selisih = (char*)&m[1][2] - (char*)&m[0][0];

cout << selisih;   // 20
```

Hasilnya **20 byte**, cocok dengan rumus: (1Ã—3 + 2) Ã— 4 = 20.

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
> Rumus `alamat(i,j) = alamat(0,0) + (i x kolom + j) x sizeof` adalah alasan mengapa akses array 2D bisa sangat cepat â€” alamatnya dihitung langsung, tanpa mencari.$md$, 3),

-- Bagian 4
('python-list-2d', 'List 2D di Python', $md$Python tidak punya array 2D bawaan seperti C++. Yang ada adalah **list bersarang** â€” list yang elemennya list.

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

Akibatnya, dua baris bisa tersimpan di lokasi memori yang berjauhan â€” tidak ada jaminan berurutan seperti C++.

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

Sekarang ketiga id **berbeda** â€” setiap baris adalah objek terpisah.

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

Inilah salah satu alasan C++ array lebih "aman" untuk pemula dalam hal ini â€” tetapi juga lebih kaku.$md$, 5)

) as v(slug, judul, konten_md, urutan)
where m.slug = 'array-multidimensi';



-- ==== 003_array_dinamis.sql ====
-- =========================================================
-- Seed: Modul 3 â€” array-dinamis
-- Array Dinamis: vector & list
--
-- Semua contoh kode DIKOMPILASI dan DIJALANKAN.
-- Platform: GCC 16.2.1, x86-64, sizeof(int)=4
-- =========================================================

insert into public.modul (slug, judul, topik, deskripsi, estimasi_menit, urutan)
values (
  'array-dinamis',
  'Array Dinamis: vector & list',
  'array',
  'Cara array tumbuh saat berjalan, beda size dan capacity, serta mengapa pointer bisa jadi dangling.',
  14,
  3
);

insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
select m.id, v.slug, v.judul, v.konten_md, v.urutan
from public.modul m, (values

('masalah-array-statis', 'Masalah Array Statis', $md$Array biasa punya satu keterbatasan besar: **ukurannya harus diketahui saat kompilasi**.

```cpp
int arr[5];   // ukuran ditentukan di kode
```

Masalahnya, sering kita tidak tahu berapa banyak data yang akan diproses saat menulis kode:

- Berapa baris data yang akan diimpor dari berkas?
- Berapa kata yang diketik pengguna?
- Berapa banyak node yang dibutuhkan graf?

## Solusi Sementara yang Buruk

```cpp
int arr[10000];   // "biar aman, kasih besar saja"
```

Ini punya dua masalah:

| Masalah | Akibat |
|---------|--------|
| Boros memori | 10.000 int = 40 KB, padahal butuh 5 |
| Tetap bisa kurang | Bagaimana kalau butuh 20.000? |

## Solusi yang Benar

Gunakan wadah yang bisa **tumbuh saat program berjalan**:

| Bahasa | Wadah | Karakteristik |
|--------|-------|---------------|
| C++ | `std::vector` | Dinamis, data di heap |
| C++ | `std::array` | Tetap, tapi lebih aman dari array C |
| Python | `list` | Dinamis, menyimpan referensi |

> [!INFO]
> `std::vector` adalah wadah yang paling sering dipakai di C++ modern. Memahaminya adalah keterampilan dasar yang wajib.

## Yang Akan Dipelajari

1. Cara `vector` tumbuh
2. Beda `size` dan `capacity`
3. Bahaya pointer ke elemen saat `vector` tumbuh
4. Padanan `vector` di Python: `list`$md$, 1),

('vector-dasar', 'std::vector: Dasar', $md$`std::vector` adalah array dinamis dari pustaka standar C++.

```cpp
#include <vector>
using namespace std;

vector<int> v;              // kosong
vector<int> a = {1, 2, 3};  // dengan nilai awal
vector<int> b(5);           // 5 elemen, semua 0
vector<int> c(5, 7);        // 5 elemen, semua 7
```

## Operasi Dasar

| Operasi | Kode | Keterangan |
|---------|------|------------|
| Tambah di akhir | `v.push_back(4)` | Paling cepat, O(1) rata-rata |
| Hapus di akhir | `v.pop_back()` | O(1) |
| Ukuran | `v.size()` | Jumlah elemen |
| Kapasitas | `v.capacity()` | Ruang yang sudah dialokasikan |
| Akses | `v[i]` atau `v.at(i)` | `at()` memeriksa batas |
| Elemen pertama | `v.front()` | â€” |
| Elemen terakhir | `v.back()` | â€” |
| Kosongkan | `v.clear()` | Size jadi 0, kapasitas tetap |

## Contoh Penggunaan

```cpp
vector<int> v = {10, 20, 30};

v.push_back(40);
v.push_back(50);

cout << v.size();      // 5
cout << v[0];          // 10
cout << v.back();      // 50

for (size_t i = 0; i < v.size(); i++) {
    cout << v[i] << " ";
}
```

## Perbedaan `v[i]` dan `v.at(i)`

Ini penting untuk keselamatan kode:

```cpp
vector<int> v = {10, 20, 30};

cout << v.at(1);    // 20 - aman
cout << v[99];      // undefined behavior - TIDAK diperiksa
cout << v.at(99);   // melempar std::out_of_range
```

`at()` memeriksa batas dan melempar exception. `[ ]` tidak memeriksa apa pun â€” sama seperti array C biasa.

> [!TIPS]
> Pakai `.at()` saat indeks berasal dari input pengguna atau perhitungan yang bisa salah. Pakai `[ ]` saat kamu yakin indeksnya valid, karena lebih cepat.$md$, 2),

('size-vs-capacity', 'Size vs Capacity', $md$Ini konsep yang paling sering membingungkan pemula, dan sering muncul di wawancara kerja.

## Perbedaannya

| Istilah | Arti |
|---------|------|
| **size** | Jumlah elemen yang **benar-benar ada** |
| **capacity** | Jumlah elemen yang **bisa ditampung** sebelum perlu alokasi ulang |

Analoginya seperti lemari:

```
size = 3      -> 3 baju tergantung
capacity = 8  -> lemari muat 8 baju
```

Lemari bisa menampung 8, tapi baru berisi 3.

## Melihat Pertumbuhannya

```cpp
vector<int> v;

cout << v.size() << " " << v.capacity() << "\n";   // 0 0

for (int i = 1; i <= 10; i++) {
    v.push_back(i);
    cout << v.size() << " " << v.capacity() << "\n";
}
```

**Output nyata (GCC 16.2.1):**

```
size  capacity
  1      1
  2      2
  3      4      <- kapasitas berlipat
  4      4
  5      8      <- berlipat lagi
  6      8
  7      8
  8      8
  9     16      <- berlipat lagi
 10     16
```

Perhatikan: kapasitas berlipat (1 â†’ 2 â†’ 4 â†’ 8 â†’ 16), sedangkan size bertambah satu per satu.

## Mengapa Kapasitas Berlipat

Karena menambah kapasitas satu per satu akan sangat lambat:

```
Tambah 1 per 1  : setiap push_back butuh alokasi ulang -> O(n) per operasi
Lipat ganda     : alokasi ulang jarang -> O(1) rata-rata
```

Dengan melipatgandakan, alokasi ulang jadi semakin jarang seiring data bertambah.

> [!PERHATIAN]
> Angka pertumbuhan **2x** adalah *implementation-defined* â€” tidak dijamin standar C++. GCC memakai 2x, tetapi implementasi lain bisa memakai 1,5x. **Jangan hafalkan angkanya**; pahami **mengapa** pertumbuhan berlipat diperlukan.

## reserve: Mencegah Alokasi Ulang

Kalau jumlah elemen sudah diketahui, gunakan `reserve()`:

```cpp
vector<int> v;
v.reserve(10);      // alokasikan ruang untuk 10 elemen

cout << v.size();       // 0
cout << v.capacity();   // 10
```

Sekarang `push_back` tidak perlu alokasi ulang sampai elemen ke-11.

> [!TIPS]
> Kalau tahu akan menampung 1000 elemen, panggil `v.reserve(1000)` sebelum loop. Ini mencegah puluhan alokasi ulang dan mempercepat program secara signifikan.$md$, 3),

('cara-vector-tumbuh', 'Bagaimana vector Tumbuh', $md$Ini bagian yang paling penting dipahami, karena menjelaskan banyak bug yang sulit dilacak.

## Proses Alokasi Ulang

Ketika `push_back` dipanggil dan **size sudah sama dengan capacity**:

1. Alokasikan blok memori **baru** yang lebih besar
2. **Salin** semua elemen lama ke blok baru
3. **Bebaskan** blok lama
4. Tambahkan elemen baru

```
Sebelum push_back ke-5 (capacity=4, sudah penuh):

Blok lama: [1][2][3][4]        <- penuh

Setelah push_back ke-5:

1. Alokasi blok baru (kapasitas 8)
2. Salin 1,2,3,4 ke blok baru
3. Bebaskan blok lama
4. Tambah 5

Blok baru: [1][2][3][4][5][ ][ ][ ]
Blok lama: (dibebaskan)
```

## Konsekuensinya: Alamat Berubah

Karena data dipindah ke blok baru, **alamat elemen berubah**.

```cpp
vector<int> v;
v.push_back(1);

int* p = v.data();              // simpan alamat elemen pertama
cout << p << "\n";              // 0x55605b89e030

for (int i = 0; i < 10; i++) v.push_back(i);

cout << v.data() << "\n";       // 0x55605b89e420 - BERUBAH!
```

**Output nyata:** alamat berubah dari `...e030` menjadi `...e420`.

## BAHAYA: Dangling Pointer

Ini bug yang sangat berbahaya karena **sering tidak langsung terlihat**.

```cpp
vector<int> v = {1, 2, 3};
int* p = &v[0];        // pointer ke elemen pertama

v.push_back(4);        // jika terjadi alokasi ulang...
v.push_back(5);
// ... pointer p sekarang DANGLING (menunjuk memori yang sudah dibebaskan)

cout << *p;            // UNDEFINED BEHAVIOR
```

Masalahnya: kode ini **mungkin tampak berjalan normal**. Nilai lama masih ada di memori yang sudah dibebaskan, jadi `*p` bisa mencetak nilai yang benar. Tapi begitu memori itu dipakai untuk hal lain, nilainya berubah.

> [!BAHAYA]
> JANGAN menyimpan pointer atau referensi ke elemen `vector` lalu memanggil `push_back`. Jika alokasi ulang terjadi, pointer itu menjadi dangling dan mengaksesnya adalah undefined behavior.

## Cara yang Aman

**Cara 1: Pakai indeks, bukan pointer**

```cpp
vector<int> v = {1, 2, 3};
size_t idx = 0;

v.push_back(4);        // aman - indeks selalu valid
cout << v[idx];        // 1
```

**Cara 2: reserve dulu**

```cpp
vector<int> v;
v.reserve(100);        // tidak akan realokasi sampai 100 elemen
int* p = &v[0];
for (int i = 0; i < 100; i++) v.push_back(i);
// p tetap valid
```

**Cara 3: ulangi ambil pointer setelah perubahan**

```cpp
v.push_back(4);
p = &v[0];             // ambil ulang setelah push_back
```$md$, 4),

('vector-vs-array', 'vector vs array', $md$Tiga wadah yang sering dibingungkan: array C biasa, `std::array`, dan `std::vector`.

## Perbandingan

| Aspek | `int arr[5]` | `std::array<int,5>` | `std::vector<int>` |
|-------|--------------|---------------------|---------------------|
| Ukuran | Tetap (kompilasi) | Tetap (kompilasi) | **Dinamis** |
| Lokasi data | Stack | Stack | **Heap** |
| `.size()` | Tidak ada | **Ada** | **Ada** |
| Decay ke pointer | **Ya** | Tidak | Tidak |
| Bisa disalin dengan `=` | Tidak | **Ya** | **Ya** |
| Periksa batas | Tidak | Tidak | Ada (`.at()`) |
| Bisa tumbuh | Tidak | Tidak | **Ya** |

## Decay: Masalah Array C Biasa

```cpp
void cetak(int arr[]) {
    cout << sizeof(arr);   // 8 (ukuran POINTER, bukan array!)
}

int main() {
    int arr[5] = {1,2,3,4,5};
    cout << sizeof(arr);   // 20 (ukuran array asli)
    cetak(arr);
}
```

Di dalam fungsi, `sizeof(arr)` menghasilkan **8 byte** â€” ukuran pointer â€” bukan 20 byte ukuran array. Informasi ukuran **hilang**.

`std::array` tidak punya masalah ini:

```cpp
void cetak(const array<int,5>& a) {
    cout << a.size();   // 5 - informasi ukuran TIDAK hilang
}
```

## Kapan Pakai yang Mana

| Situasi | Pilihan |
|---------|---------|
| Ukuran tetap, butuh performa maksimal, interoperasi C | `int arr[5]` |
| Ukuran tetap, ingin aman dan punya `.size()` | `std::array<int,5>` |
| Ukuran tidak diketahui saat kompilasi | `std::vector<int>` |
| Butuh bisa tumbuh/berkurang | `std::vector<int>` |

> [!TIPS]
> Aturan praktis C++ modern: **default ke `std::vector`**. Pakai `std::array` kalau ukurannya tetap dan kamu ingin keamanan ekstra. Pakai array C biasa hanya kalau berinteraksi dengan API gaya C atau butuh performa maksimal.$md$, 5),

('list-python', 'List Python', $md$`list` Python adalah padanan `std::vector` â€” array dinamis. Tapi mekanismenya berbeda.

## Dasar

```python
lst = [1, 2, 3]

lst.append(4)        # tambah di akhir
lst.insert(0, 0)     # sisipkan di depan
lst.remove(1)        # hapus nilai 1
lst.pop()            # hapus elemen terakhir
print(len(lst))      # panjang
```

## Ukuran Tumbuh Otomatis

```python
lst = [1, 2, 3]
print(len(lst))      # 3

lst.append(4)
print(len(lst))      # 4
```

Tidak ada konsep `capacity` yang bisa diakses langsung seperti di C++, tetapi Python juga melakukan *over-allocation* di balik layar.

```python
import sys

l = []
for i in range(1, 11):
    l.append(i)
    print(len(l), sys.getsizeof(l))
```

**Output nyata:**

```
len  byte
  1    88
  2    88
  3    88
  4    88      <- masih dalam alokasi yang sama
  5   120      <- naik
  ...
  9   184      <- naik lagi
```

Perhatikan: ukuran memori **tidak bertambah setiap append**. Python mengalokasikan lebih banyak dari yang dibutuhkan, sama seperti `vector`.

> [!INFO]
> `sys.getsizeof()` mengembalikan ukuran **objek list itu sendiri**, bukan ukuran data yang disimpan. Karena list menyimpan referensi (pointer), angka ini tidak sama dengan "ukuran data".

## insert(0) Itu Mahal

Ini operasi yang sering disalahpahami sebagai murah.

```python
lst = list(range(1000))
lst.insert(0, 99)
```

`insert(0, ...)` harus **menggeser semua elemen** satu posisi ke kanan. Kompleksitasnya **O(n)**, bukan O(1).

**Bukti pengukuran (5.000 iterasi):**

| Operasi | Waktu |
|---------|-------|
| `append` ke belakang | 0.8 ms |
| `insert` ke depan | 155.1 ms |

**198x lebih lambat.**

> [!PERHATIAN]
> Jangan pakai `insert(0, ...)` di dalam loop untuk data besar. Kalau butuh menambah di depan berulang kali, pakai `collections.deque` yang punya `appendleft()` dengan kompleksitas O(1).

## Slicing MENYALIN

Berbeda dari C++ yang memakai pointer, slicing Python menghasilkan **salinan**:

```python
arr = [10, 20, 30, 40, 50]
s = arr[1:4]

s[0] = 999

print(arr)   # [10, 20, 30, 40, 50] - TIDAK berubah
print(s)     # [999, 30, 40]
```

Ini penting untuk dipahami: mengubah hasil slice **tidak** mengubah list asli.

## List Menyimpan Referensi

```python
a = [1, 2, 3]
b = a           # bukan salinan!

b.append(4)
print(a)        # [1, 2, 3, 4] - IKUT berubah
print(id(a) == id(b))   # True
```

Untuk membuat salinan sebenarnya:

```python
c = a.copy()    # atau a[:] atau list(a)

c.append(5)
print(a)        # [1, 2, 3, 4] - tidak berubah
print(c)        # [1, 2, 3, 4, 5]
```

> [!BAHAYA]
> `b = a` pada list TIDAK membuat salinan. Keduanya menunjuk objek yang sama. Untuk menyalin, gunakan `a.copy()`, `a[:]`, atau `list(a)`.$md$, 6)

) as v(slug, judul, konten_md, urutan)
where m.slug = 'array-dinamis';



-- ==== 004_struct_dasar.sql ====
-- =========================================================
-- Seed: Modul 4 â€” struct-dasar
-- Mendefinisikan Struct
--
-- Semua contoh kode DIKOMPILASI dan DIJALANKAN.
-- Platform: GCC 16.2.1, x86-64
-- =========================================================

insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
select m.id, v.slug, v.judul, v.konten_md, v.urutan
from public.modul m, (values

('mengapa-butuh-struct', 'Mengapa Butuh Struct', $md$Bayangkan menyimpan data satu mahasiswa. Dengan variabel terpisah:

```cpp
string nama1 = "Rani";
int umur1 = 20;
double ipk1 = 3.75;

string nama2 = "Budi";
int umur2 = 21;
double ipk2 = 3.50;
```

Masalahnya langsung terlihat:

- Harus mengingat variabel mana milik siapa
- Sulit dikirim ke fungsi (harus kirim 3 parameter)
- Tidak bisa disimpan dalam satu array
- Menambah field baru berarti mengubah semua tempat

## Solusi: Struct

`struct` mengelompokkan data yang **saling terkait** menjadi satu kesatuan:

```cpp
struct Mahasiswa {
    string nama;
    int umur;
    double ipk;
};

Mahasiswa m1 = {"Rani", 20, 3.75};
Mahasiswa m2 = {"Budi", 21, 3.50};
```

Sekarang `m1` adalah **satu nilai** yang berisi tiga data.

## Kapan Memakai Struct

Pakai struct kalau data-data ini **selalu muncul bersama**:

| Situasi | Struct |
|---------|--------|
| Titik di bidang 2D | `struct Titik { int x; int y; }` |
| Data mahasiswa | `struct Mahasiswa { string nama; int umur; }` |
| Barang di toko | `struct Barang { string nama; double harga; }` |
| Tanggal | `struct Tanggal { int hari; int bulan; int tahun; }` |

> [!INFO]
> Struct adalah langkah pertama dari "variabel lepas" menuju **model data**. Ini dasar dari hampir semua sistem nyata.

## Struct vs Class

Di C++, `struct` dan `class` hampir identik. Perbedaan utamanya:

| Aspek | `struct` | `class` |
|-------|----------|---------|
| Akses default | **public** | **private** |
| Konvensi | Wadah data | Objek dengan perilaku |

> [!TIPS]
> Konvensi umum: pakai `struct` untuk **wadah data sederhana** tanpa logika, dan `class` untuk objek yang punya perilaku dan menyembunyikan detail internal.$md$, 1),

('mendefinisikan-struct', 'Mendefinisikan Struct', $md$## Sintaks Dasar

```cpp
struct NamaStruct {
    tipe anggota1;
    tipe anggota2;
};   // <- JANGAN lupa titik koma!
```

Perhatikan **titik koma setelah kurung kurawal penutup**. Ini kesalahan paling umum bagi pemula.

## Contoh Lengkap

```cpp
struct Titik {
    int x;
    int y;
};

int main() {
    Titik t = {3, 7};

    cout << t.x;   // 3
    cout << t.y;   // 7
}
```

## Tiga Cara Menginisialisasi

```cpp
// Cara 1: daftar nilai berurutan
Titik a = {3, 7};

// Cara 2: dengan nama anggota (C++20, lebih jelas)
Titik b = {.x = 3, .y = 7};

// Cara 3: satu per satu
Titik c;
c.x = 3;
c.y = 7;
```

## Mengakses Anggota

Gunakan **operator titik** (`.`):

```cpp
Titik t = {3, 7};

t.x = 10;              // ubah nilai
cout << t.x;           // 10

int jumlah = t.x + t.y;   // 17
```

## Inisialisasi Sebagian

```cpp
Titik t = {5};   // hanya x yang diisi

cout << t.x;   // 5
cout << t.y;   // 0  <- sisanya OTOMATIS nol
```

Sama seperti array, anggota yang tidak diinisialisasi **otomatis diisi nol**.

## Struct Bisa Berisi Apa Saja

```cpp
struct Mahasiswa {
    string nama;        // string
    int umur;           // bilangan bulat
    double ipk;         // bilangan desimal
    bool aktif;         // boolean
    char kelas;         // karakter
};
```

Tipe anggotanya **boleh berbeda-beda** â€” inilah yang membedakan struct dari array yang harus bertipe seragam.

> [!PERHATIAN]
> Lupa titik koma setelah `}` pada definisi struct adalah kesalahan yang sangat sering terjadi. Pesan error-nya bisa membingungkan karena menunjuk ke baris berikutnya, bukan ke tempat kesalahannya.$md$, 2),

('struct-sebagai-parameter', 'Struct sebagai Parameter', $md$Struct bisa dikirim ke fungsi seperti tipe biasa.

## Dikirim sebagai Nilai (Disalin)

```cpp
struct Titik { int x; int y; };

void geser(Titik t) {
    t.x = t.x + 10;   // mengubah SALINAN
}

int main() {
    Titik a = {3, 7};
    geser(a);

    cout << a.x;   // 3 - TIDAK berubah!
}
```

Struct dikirim sebagai **salinan**. Mengubahnya di dalam fungsi tidak mempengaruhi aslinya.

## Dikirim sebagai Referensi (Tidak Disalin)

```cpp
void geser(Titik& t) {
    t.x = t.x + 10;   // mengubah ASLINYA
}

int main() {
    Titik a = {3, 7};
    geser(a);

    cout << a.x;   // 13 - berubah!
}
```

Tanda `&` membuat fungsi menerima **referensi**, bukan salinan.

## Referensi Konstan (Aman dan Cepat)

```cpp
void cetak(const Titik& t) {
    cout << t.x << ", " << t.y;
    // t.x = 10;   // ERROR: tidak bisa diubah
}
```

`const` mencegah fungsi mengubah data, sementara `&` mencegah penyalinan. Ini pola yang paling sering dipakai.

## Kapan Pakai yang Mana

| Cara | Kapan |
|------|-------|
| `void f(Titik t)` | Struct kecil DAN perlu diubah tanpa mempengaruhi aslinya |
| `void f(Titik& t)` | Perlu mengubah data aslinya |
| `void f(const Titik& t)` | **Paling umum** â€” hanya membaca, tidak menyalin |

## Struct Bisa Disalin dengan `=`

```cpp
Titik a = {3, 7};
Titik b = a;      // SALINAN

b.x = 99;

cout << a.x;   // 3  - tidak berubah
cout << b.x;   // 99
```

> [!TIPS]
> Untuk struct besar, selalu pakai `const Titik&` saat hanya membaca. Menyalin struct besar untuk setiap pemanggilan fungsi itu pemborosan yang tidak perlu.$md$, 3),

('struct-di-python', 'Struct di Python', $md$Python tidak punya `struct` seperti C++, tetapi punya padanan yang lebih fleksibel: **`dataclass`**.

## Dataclass

```python
from dataclasses import dataclass

@dataclass
class Titik:
    x: int
    y: int

t = Titik(3, 7)

print(t.x)   # 3
print(t.y)   # 7
```

## Yang Otomatis Didapat

Dekorator `@dataclass` membuat beberapa method secara otomatis:

```python
t = Titik(3, 7)

print(t)              # Titik(x=3, y=7)  <- repr otomatis
print(t == Titik(3,7))  # True            <- __eq__ otomatis
```

Tanpa `@dataclass`, kamu harus menulis `__init__`, `__repr__`, dan `__eq__` sendiri.

## JANGAN Lupa Dekorator

```python
# SALAH - lupa @dataclass
class Titik:
    x: int
    y: int

t = Titik(3, 7)   # TypeError: takes no arguments
```

Tanpa `@dataclass`, kelas ini hanya anotasi tipe â€” tidak ada `__init__` yang menerima argumen.

## Dataclass dengan Nilai Default

```python
@dataclass
class Mahasiswa:
    nama: str
    umur: int = 18          # nilai default
    aktif: bool = True

m = Mahasiswa("Rani")       # umur dan aktif pakai default
print(m)                    # Mahasiswa(nama='Rani', umur=18, aktif=True)
```

> [!PERHATIAN]
> Field dengan nilai default harus diletakkan SETELAH field tanpa default. Kalau tidak, Python melempar `TypeError: non-default argument follows default argument`.

## Dataclass Bisa Diubah

```python
@dataclass
class Titik:
    x: int
    y: int

t = Titik(3, 7)
t.x = 10        # BOLEH - dataclass mutable secara default
print(t)        # Titik(x=10, y=7)
```

Kalau ingin tidak bisa diubah, pakai `frozen=True`:

```python
@dataclass(frozen=True)
class Titik:
    x: int
    y: int

t = Titik(3, 7)
t.x = 10        # ERROR: cannot assign to field 'x'
```

## Perbandingan C++ dan Python

| Aspek | C++ `struct` | Python `@dataclass` |
|-------|--------------|---------------------|
| Deklarasi | `struct Titik { int x; }` | `@dataclass class Titik:` |
| Tipe anggota | Wajib, dicek saat kompilasi | Anotasi, tidak dipaksa runtime |
| Inisialisasi | `Titik t = {3, 7};` | `Titik(3, 7)` |
| Cetak | Perlu tulis sendiri | `repr` otomatis |
| Bandingkan | Perlu tulis sendiri | `__eq__` otomatis |
| Ukuran memori | Bisa dihitung dengan `sizeof` | Tidak ada konsep `sizeof` |

> [!INFO]
> Di Python, tipe pada anotasi (`x: int`) **tidak dipaksa saat runtime**. Kamu tetap bisa menulis `Titik("halo", 3.14)` tanpa error. Anotasi berguna untuk dokumentasi dan alat seperti mypy, bukan untuk penegakan tipe.$md$, 4)

) as v(slug, judul, konten_md, urutan)
where m.slug = 'struct-dasar';



-- ==== 005_struct_nested.sql ====
-- =========================================================
-- Seed: Modul 5 â€” struct-nested
-- Nested Struct & Array of Struct
-- Semua contoh kode DIKOMPILASI dan DIJALANKAN (GCC 16.2.1)
-- =========================================================

insert into public.modul (slug, judul, topik, deskripsi, estimasi_menit, urutan)
values ('struct-nested', 'Nested Struct & Array of Struct', 'struct',
  'Menyusun struct di dalam struct, array of struct, dan cara mengurutkannya.', 13, 5);

insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
select m.id, v.slug, v.judul, v.konten_md, v.urutan
from public.modul m, (values

('struct-sebagai-anggota', 'Struct sebagai Anggota', $md$Data nyata hampir selalu bertingkat. Mahasiswa punya alamat, alamat punya kota dan kode pos.

Dengan struct, kita bisa menyusun struct di dalam struct:

```cpp
struct Alamat {
    string kota;
    string kodePos;
};

struct Mahasiswa {
    string nama;
    int umur;
    Alamat alamat;      // struct sebagai anggota
};
```

## Inisialisasi Bertingkat

```cpp
Mahasiswa m = {"Rani", 20, {"Bandung", "40123"}};
```

Perhatikan kurung kurawal bersarang: `{"Bandung", "40123"}` adalah nilai untuk `alamat`.

## Mengakses Anggota Bertingkat

Gunakan **dua titik** â€” satu untuk setiap level:

```cpp
cout << m.nama;              // Rani
cout << m.alamat.kota;       // Bandung
cout << m.alamat.kodePos;    // 40123
```

Cara membacanya: "`m` punya `alamat`, dan `alamat` punya `kota`".

## Mengubah Anggota Bertingkat

```cpp
m.alamat.kota = "Jakarta";
cout << m.alamat.kota;   // Jakarta
```

## Urutan Akses Itu Penting

```cpp
m.alamat.kota     // BENAR
m.kota.alamat     // SALAH - kota bukan anggota m
```

> [!PERHATIAN]
> Kesalahan paling umum adalah **tertukar urutan**. Ingat: akses mengikuti struktur dari luar ke dalam. `m` (luar) -> `alamat` (tengah) -> `kota` (dalam).

## Bisa Lebih dari Dua Level

```cpp
struct Negara { string nama; };
struct Alamat { string kota; Negara negara; };
struct Mahasiswa { string nama; Alamat alamat; };

Mahasiswa m = {"Rani", {"Bandung", {"Indonesia"}}};

cout << m.alamat.negara.nama;   // Indonesia
```

Tidak ada batas praktis kedalamannya, tetapi lebih dari 3 level biasanya tanda strukturnya perlu disederhanakan.$md$, 1),

('array-of-struct', 'Array of Struct', $md$Ini pola yang sangat sering dipakai: **array yang setiap elemennya struct**.

## Mendeklarasikan

```cpp
struct Barang {
    string nama;
    double harga;
};

Barang daftar[3] = {
    {"Buku", 25000},
    {"Pulpen", 3000},
    {"Tas", 150000}
};
```

## Mengiterasi

```cpp
double total = 0;

for (int i = 0; i < 3; i++) {
    cout << daftar[i].nama << " = Rp" << daftar[i].harga << "\n";
    total += daftar[i].harga;
}

cout << "total = Rp" << total;
```

**Output nyata:**

```
Buku = Rp25000
Pulpen = Rp3000
Tas = Rp150000
total = Rp178000
```

## Menghitung Jumlah Elemen

```cpp
int jumlah = sizeof(daftar) / sizeof(daftar[0]);   // 3
```

Ini bekerja **hanya** kalau array-nya masih di scope yang sama. Kalau dikirim ke fungsi, informasi ukurannya hilang (decay).

## Mengurutkan Array of Struct

Array of struct bisa diurutkan dengan `std::sort` dan lambda pembanding:

```cpp
#include <algorithm>

struct Kelas { string nama; double ipk; };

Kelas kelas[3] = {{"Rani", 3.75}, {"Budi", 3.20}, {"Citra", 3.90}};

sort(kelas, kelas + 3, [](const Kelas& a, const Kelas& b) {
    return a.ipk > b.ipk;   // menurun
});
```

**Output nyata (ipk menurun):**

```
Citra = 3.9
Rani  = 3.75
Budi  = 3.2
```

Ubah `>` menjadi `<` untuk urutan menaik.

## Array of Struct vs Struct of Array

Dua cara menyimpan data yang sama:

**Array of Struct (AoS):**
```cpp
struct Mahasiswa { string nama; double ipk; };
Mahasiswa daftar[100];
```

**Struct of Array (SoA):**
```cpp
struct DaftarMahasiswa {
    string nama[100];
    double ipk[100];
};
```

| Aspek | Array of Struct | Struct of Array |
|-------|-----------------|-----------------|
| Keterbacaan | **Lebih jelas** | Kurang jelas |
| Akses satu objek | **Baik** (data berdekatan) | Kurang baik |
| Akses satu field semua objek | Kurang baik | **Baik** |

**Rekomendasi:** pakai **array of struct** kecuali ada alasan performa khusus. Keterbacaan lebih penting.

> [!TIPS]
> Array of struct adalah cara paling alami memodelkan "daftar benda". Kalau kamu butuh menyimpan 100 mahasiswa, `Mahasiswa daftar[100]` jauh lebih mudah dikelola daripada 200 variabel terpisah.$md$, 2),

('padanan-python', 'Padanan di Python', $md$Python tidak punya array of struct, tetapi punya padanan yang lebih fleksibel: **list of dataclass**.

## Dataclass Bersarang

```python
from dataclasses import dataclass

@dataclass
class Alamat:
    kota: str
    kode_pos: str

@dataclass
class Mahasiswa:
    nama: str
    umur: int
    alamat: Alamat

m = Mahasiswa("Rani", 20, Alamat("Bandung", "40123"))

print(m.nama)             # Rani
print(m.alamat.kota)      # Bandung
```

Akses bertingkat memakai titik, sama seperti C++.

## List of Dataclass

```python
daftar = [
    Mahasiswa("Rani", 20, Alamat("Bandung", "40123")),
    Mahasiswa("Budi", 21, Alamat("Jakarta", "10110")),
]

for m in daftar:
    print(f"{m.nama} dari {m.alamat.kota}")
```

## Mengurutkan

Python punya `sorted()` dengan parameter `key`:

```python
@dataclass
class Kelas:
    nama: str
    ipk: float

kelas = [
    Kelas("Rani", 3.75),
    Kelas("Budi", 3.20),
    Kelas("Citra", 3.90),
]

# Urut menurun berdasarkan ipk
terurut = sorted(kelas, key=lambda k: k.ipk, reverse=True)

for k in terurut:
    print(f"{k.nama} = {k.ipk}")
```

**Output:**
```
Citra = 3.9
Rani = 3.75
Budi = 3.2
```

## Perbandingan dengan C++

| Aspek | C++ | Python |
|-------|-----|--------|
| Struct bersarang | `struct` di dalam `struct` | `dataclass` di dalam `dataclass` |
| Akses bertingkat | `m.alamat.kota` | `m.alamat.kota` |
| Array of struct | `Barang daftar[3]` | `daftar = [...]` |
| Ukuran | Tetap | Dinamis |
| Mengurutkan | `std::sort` + lambda | `sorted()` + `key` |
| Jumlah elemen | `sizeof/sizeof` | `len()` |

> [!INFO]
> Di Python, list bisa menampung dataclass dengan tipe berbeda tanpa error. Ini fleksibel tetapi juga berisiko: kesalahan tipe baru terdeteksi saat program berjalan, bukan saat menulis kode.$md$, 3),

('jebakan-nested', 'Jebakan Struct Bersarang', $md$Beberapa kesalahan yang sering terjadi saat memakai struct bersarang.

## Jebakan 1: Tertukar Urutan Akses

```cpp
struct Alamat { string kota; };
struct Mahasiswa { string nama; Alamat alamat; };

Mahasiswa m = {"Rani", {"Bandung"}};

cout << m.alamat.kota;   // BENAR
cout << m.kota.alamat;   // SALAH - m tidak punya anggota 'kota'
```

Compiler akan memberi error "no member named 'kota' in 'Mahasiswa'". Pesan ini cukup jelas, jadi kesalahannya mudah ditemukan.

## Jebakan 2: Lupa Kurung Kurawal Bersarang

```cpp
// SALAH - compiler bingung
Mahasiswa m = {"Rani", "Bandung"};

// BENAR - alamat dibungkus kurung sendiri
Mahasiswa m = {"Rani", {"Bandung"}};
```

## Jebakan 3: Salah Mengira Struct Bersarang Disalin Sebagian

Struct bersarang disalin **seluruhnya**, termasuk struct di dalamnya:

```cpp
Mahasiswa a = {"Rani", 20, {"Bandung", "40123"}};
Mahasiswa b = a;              // SALINAN lengkap

b.alamat.kota = "Jakarta";

cout << a.alamat.kota;        // Bandung - TIDAK berubah
cout << b.alamat.kota;        // Jakarta
```

Ini **berbeda** dari Python, di mana objek bersarang bisa saja dibagi referensinya.

## Jebakan 4: Memakai `->` padahal Bukan Pointer

```cpp
Mahasiswa m = {"Rani", {"Bandung"}};

cout << m->nama;      // SALAH - m bukan pointer
cout << m.nama;       // BENAR

Mahasiswa* p = &m;
cout << p->nama;      // BENAR - p pointer
cout << p.nama;       // SALAH
```

Aturan: **`.` untuk nilai/referensi, `->` untuk pointer.**

## Jebakan 5: Inisialisasi Bertingkat yang Salah Urutan

```cpp
// SALAH - urutan tertukar
Mahasiswa m = {"Rani", {"40123", "Bandung"}};
// kota berisi "40123", kodePos berisi "Bandung"
```

Compiler tidak akan error karena keduanya bertipe `string`. Kesalahan ini hanya terlihat saat program berjalan.

> [!BAHAYA]
> Kesalahan urutan inisialisasi seperti di atas **tidak terdeteksi compiler** kalau tipenya sama. Ini alasan penting untuk memakai inisialisasi dengan nama (C++20) saat struct punya banyak anggota bertipe sama:
>
> ```cpp
> Mahasiswa m = {.nama = "Rani", .alamat = {.kota = "Bandung"}};
> ```$md$, 4)

) as v(slug, judul, konten_md, urutan)
where m.slug = 'struct-nested';



-- ==== 006_struct_memori.sql ====
-- =========================================================
-- Seed: Modul 6 â€” struct-memori
-- Padding, Alignment & sizeof
--
-- PENTING: Semua angka di modul ini adalah HASIL PENGUKURAN NYATA
-- pada platform tertentu (GCC 16.2.1, x86-64, sizeof(int)=4,
-- sizeof(long)=8, sizeof(short)=2). Alignment bersifat
-- implementation-defined - angka bisa berbeda di platform lain.
-- =========================================================

insert into public.modul (slug, judul, topik, deskripsi, estimasi_menit, urutan)
values ('struct-memori', 'Padding, Alignment & sizeof', 'struct',
  'Mengapa sizeof(struct) lebih besar dari jumlah anggotanya, dan kapan pengurutan anggota membantu.', 16, 6);

insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
select m.id, v.slug, v.judul, v.konten_md, v.urutan
from public.modul m, (values

('kejutan-pertama', 'Kejutan Pertama', $md$Ini kejutan yang dialami hampir semua orang yang pertama kali memeriksa `sizeof` struct.

```cpp
struct Campur {
    char a;    // 1 byte
    int b;     // 4 byte
};

cout << sizeof(Campur);
```

**Tebakan banyak orang:** 5 byte (1 + 4)

**Hasil sebenarnya:** **8 byte**

Kemana 3 byte sisanya?

## Jawabannya: Padding

```
struct Campur { char a; int b; };

Offset:  0    1    2    3    4    5    6    7
Isi:    [a]  [pad][pad][pad] [   b   ]
        1B    3 byte padding   4 byte
```

Ada **3 byte kosong** antara `a` dan `b`. Byte itu disebut **padding**.

## Membuktikan dengan offsetof

```cpp
#include <cstddef>

cout << offsetof(Campur, a);   // 0
cout << offsetof(Campur, b);   // 4  <- bukan 1!
```

`b` dimulai pada offset **4**, bukan 1. Tiga byte pertama setelah `a` dilewati.

## Mengapa Padding Ada

Karena CPU tidak membaca memori satu byte demi satu byte. CPU membaca dalam **blok** (biasanya 4 atau 8 byte).

Kalau `int b` diletakkan pada offset 1, CPU perlu membaca dua blok dan menggabungkan hasilnya â€” jauh lebih lambat.

Dengan meletakkan `b` pada offset 4 (kelipatan 4), CPU bisa membacanya dalam **satu** operasi.

> [!INFO]
> Padding adalah **pertukaran**: kita "membuang" beberapa byte memori demi kecepatan akses. Untuk sebagian besar program, ini pertukaran yang menguntungkan.

## Konsekuensi yang Perlu Diingat

| Konsekuensi | Penjelasan |
|-------------|------------|
| `sizeof` lebih besar dari perkiraan | Harus dihitung, bukan dijumlahkan |
| Byte padding berisi nilai tak tentu | Jangan bandingkan struct dengan `memcmp` |
| Layout bisa beda antar platform | Jangan kirim struct mentah antar sistem |
| Array of struct punya "jarak" lebih besar | Setiap elemen punya padding sendiri |

## Struct Tanpa Padding

Kalau semua anggota berukuran sama, tidak ada padding:

```cpp
struct Titik { int x; int y; };      // 8 byte (4+4)
struct Titik3D { int x; int y; int z; };  // 12 byte (4+4+4)
```

Padding hanya muncul saat ukuran anggota **berbeda-beda**.

> [!TIPS]
> Aturan cepat: padding muncul karena **alignment**. Setiap anggota harus dimulai pada alamat yang merupakan kelipatan ukurannya (atau alignment-nya).$md$, 1),

('aturan-alignment', 'Aturan Alignment', $md$Untuk bisa menghitung padding sendiri, kamu perlu tahu aturannya.

## Aturan Alignment

**Setiap anggota harus dimulai pada alamat yang merupakan kelipatan alignment-nya.**

Alignment biasanya sama dengan ukuran tipe, dengan pengecualian:

| Tipe | Ukuran | Alignment (x86-64) |
|------|--------|---------------------|
| `char` | 1 | 1 |
| `short` | 2 | 2 |
| `int` | 4 | 4 |
| `long` | 8 | 8 |
| `double` | 8 | 8 |
| pointer | 8 | 8 |

## Dua Langkah Menghitung Padding

**Langkah 1:** Setiap anggota mulai pada offset yang merupakan kelipatan alignment-nya.

**Langkah 2:** Total ukuran struct dibulatkan ke kelipatan alignment **terbesar** di antara anggotanya.

### Contoh 1: char, int

```cpp
struct A { char a; int b; };
```

| Anggota | Alignment | Offset | Keterangan |
|---------|-----------|--------|------------|
| `a` | 1 | 0 | mulai di 0, ok |
| `b` | 4 | **4** | harus kelipatan 4; setelah `a` di 1, dibulatkan ke 4 |

Padding: offset 1-3 (3 byte). Total: 4 + 4 = **8 byte**.

### Contoh 2: char, long, char

```cpp
struct B { char a; long b; char c; };
```

| Anggota | Alignment | Offset | Keterangan |
|---------|-----------|--------|------------|
| `a` | 1 | 0 | ok |
| `b` | 8 | **8** | harus kelipatan 8; setelah 1, dibulatkan ke 8 |
| `c` | 1 | 16 | ok |

Setelah `c` di offset 16, totalnya 17. Alignment terbesar = 8, jadi dibulatkan ke **24**.

**Hasil terukur: 24 byte.** (1 + 7 padding + 8 + 1 + 7 padding akhir)

### Contoh 3: long, char, char

```cpp
struct C { long b; char a; char c; };
```

| Anggota | Alignment | Offset |
|---------|-----------|--------|
| `b` | 8 | 0 |
| `a` | 1 | 8 |
| `c` | 1 | 9 |

Total 10, dibulatkan ke kelipatan 8 menjadi **16**.

**Hasil terukur: 16 byte.** Hemat 8 byte dibanding contoh 2.

> [!PERHATIAN]
> Alignment **bersifat implementation-defined**. Angka di atas berlaku untuk x86-64 dengan GCC/Clang. Di platform lain (ARM, embedded) bisa berbeda. **Selalu verifikasi dengan `sizeof` dan `offsetof` di platformmu.**$md$, 2),

('mengurangi-padding', 'Mengurangi Padding', $md$Karena padding membuang memori, muncul pertanyaan: bisakah dikurangi?

### Cara 1: Mengurutkan Anggota

Ini saran yang sering diberikan: **urutkan anggota dari besar ke kecil**.

**Tapi hati-hati â€” saran ini TIDAK selalu benar.**

## Bukti Pengukuran

Mari bandingkan pada GCC 16.2.1, x86-64:

| Struct | sizeof | Hemat? |
|--------|--------|--------|
| `{char a; int b;}` | **8** | â€” |
| `{int b; char a;}` | **8** | **TIDAK hemat!** |
| `{char a; long b; char c;}` | **24** | â€” |
| `{long b; char a; char c;}` | **16** | Hemat 8 byte |
| `{char a; int b; short c;}` | **12** | â€” |
| `{int b; short c; char a;}` | **8** | Hemat 4 byte |

**Perhatikan baris pertama dan kedua:** `{char, int}` dan `{int, char}` **sama-sama 8 byte**. Pengurutan tidak mengubah apa pun!

## Mengapa Demikian

Pada struct dengan **dua anggota**, tidak ada anggota kecil yang bisa dikemas bersama. Padding akhir tetap diperlukan agar ukuran total kelipatan alignment terbesar.

**Pengurutan baru membantu kalau ada beberapa anggota kecil yang bisa dikemas berdampingan.**

## Aturan yang Lebih Akurat

> Padding berkurang ketika anggota-anggota kecil dikelompokkan berdampingan sehingga mereka muat dalam satu blok alignment. Ini **biasanya** tercapai dengan mengurutkan dari besar ke kecil, tetapi **bukan jaminan**.

### Cara 2: #pragma pack

`#pragma pack` memaksa compiler mengurangi atau menghilangkan padding:

```cpp
#pragma pack(push, 1)
struct Padat {
    char a;
    int b;
};
#pragma pack(pop)
```

Dengan `pack(1)`, `sizeof(Padat)` menjadi **5 byte**.

> [!BAHAYA]
> `#pragma pack(1)` punya konsekuensi serius:
>
> 1. **Lebih lambat** â€” CPU harus membaca beberapa blok dan menggabungkan
> 2. **Tidak portabel** â€” perilaku berbeda antar compiler
> 3. **Bahaya pada ARM** â€” akses tidak selaras bisa menyebabkan crash
>
> Gunakan hanya kalau benar-benar perlu (mis. protokol jaringan atau format berkas biner yang sudah ditentukan).

### Cara 3: Verifikasi Sendiri

Cara terbaik bukan menghafal aturan, tapi **mengukur**:

```cpp
#include <cstddef>
#include <iostream>
using namespace std;

struct A2 { char a; int b; };
struct B2 { int b; char a; };

int main() {
    cout << sizeof(A2) << " " << sizeof(B2) << "\n";
    cout << offsetof(A2, a) << " " << offsetof(A2, b) << "\n";
}
```

> [!TIPS]
> Jangan hafalkan "urutkan dari besar ke kecil". Ukur sendiri dengan `sizeof` dan `offsetof`, lalu temukan kapan pengurutan membantu dan kapan tidak. Ini jauh lebih berharga daripada aturan hafalan yang ternyata tidak selalu berlaku.$md$, 3),

('offsetof-dan-memcmp', 'offsetof dan Bahaya memcmp', $md$Dua alat penting saat bekerja dengan struct di level memori.

## offsetof: Melihat Posisi Anggota

```cpp
#include <cstddef>

struct Campur { char a; int b; };

cout << offsetof(Campur, a);   // 0
cout << offsetof(Campur, b);   // 4
```

`offsetof` mengembalikan **jarak dalam byte** dari awal struct ke anggota tersebut.

Ini alat yang sangat berguna untuk:
- Membuktikan padding ada
- Memverifikasi layout sesuai harapan
- Debugging masalah serialisasi

## Padding Berisi Nilai Tak Tentu

Ini poin yang sangat penting dan sering diabaikan:

```cpp
struct Campur { char a; int b; };

Campur x = {'A', 100};
Campur y = {'A', 100};

// Apakah x == y?
```

Secara logis, `x` dan `y` berisi data yang sama. Tapi **byte padding-nya belum tentu sama**.

Padding diisi dengan apa saja â€” sisa data lama di memori, nilai nol, atau apa pun. Standar C++ **tidak menentukan** isinya.

## Bahaya memcmp

Karena padding berisi nilai tak tentu, membandingkan struct dengan `memcmp` bisa memberi hasil yang **salah**:

```cpp
#include <cstring>

struct Campur { char a; int b; };

Campur x = {'A', 100};
Campur y;
y.a = 'A';
y.b = 100;

if (memcmp(&x, &y, sizeof(Campur)) == 0) {
    cout << "sama";
} else {
    cout << "beda";   // <- bisa tercetak walau datanya sama!
}
```

`memcmp` membandingkan **seluruh byte**, termasuk padding yang isinya tak tentu.

> [!BAHAYA]
> JANGAN membandingkan struct dengan `memcmp`. Padding berisi nilai tak tentu, sehingga dua struct dengan data identik bisa dianggap berbeda.
>
> Bandingkan anggota satu per satu, atau tulis operator `==` sendiri.

## Cara Membandingkan yang Benar

```cpp
struct Titik { int x; int y; };

bool sama(const Titik& a, const Titik& b) {
    return a.x == b.x && a.y == b.y;
}
```

Atau di C++20, gunakan `operator==` default:

```cpp
struct Titik {
    int x;
    int y;

    bool operator==(const Titik&) const = default;
};
```

## Bahaya Menulis Struct ke Berkas

Masalah yang sama berlaku saat menulis struct langsung ke berkas:

```cpp
Campur x = {'A', 100};
berkas.write((char*)&x, sizeof(Campur));
```

Yang tertulis termasuk byte padding yang isinya tak tentu. Kalau berkas dibaca di platform lain dengan aturan alignment berbeda, hasilnya bisa kacau.

> [!INFO]
> Untuk serialisasi, gunakan format yang tidak bergantung layout memori â€” misalnya JSON, Protocol Buffers, atau tulis setiap anggota satu per satu dengan urutan yang disepakati.$md$, 4),

('padanan-python', 'Struct Memori di Python', $md$Python tidak punya konsep padding seperti C++, tetapi ada modul `struct` untuk berinteraksi dengan data biner.

## Mengapa Python Tidak Punya Padding

Karena objek Python disimpan sebagai referensi, bukan nilai berurutan:

```python
@dataclass
class Campur:
    a: str
    b: int

c = Campur("A", 100)
```

Objek `c` menyimpan **referensi** ke string dan integer, bukan nilai langsung. Ukuran objeknya tidak ditentukan oleh padding alignment.

## Modul struct: Untuk Data Biner

Kalau butuh berinteraksi dengan format biner (mis. membaca berkas dari program C), Python menyediakan modul `struct`:

```python
import struct

# Pack: ubah nilai jadi byte
data = struct.pack('bi', 65, 100)
print(len(data))    # 5 (1 byte char + 4 byte int)
```

Perhatikan: hasilnya **5 byte**, bukan 8. Karena modul `struct` Python secara default **tidak menambahkan padding**.

## Format String yang Sering Dipakai

| Kode | Tipe C | Ukuran |
|------|--------|--------|
| `b` | signed char | 1 |
| `B` | unsigned char | 1 |
| `h` | short | 2 |
| `i` | int | 4 |
| `l` | long | 4 atau 8 |
| `q` | long long | 8 |
| `f` | float | 4 |
| `d` | double | 8 |

## Padding Eksplisit

Kalau butuh meniru layout C yang punya padding, gunakan `@` atau `=`:

```python
# Tanpa padding (default untuk jaringan)
struct.pack('bi', 65, 100)      # 5 byte

# Dengan alignment native
struct.pack('@bi', 65, 100)     # 8 byte (ada padding)
```

## Perbandingan

| Aspek | C++ | Python |
|-------|-----|--------|
| Padding otomatis | **Ya** | Tidak (kecuali diminta) |
| `sizeof` | Ada | Tidak ada untuk objek |
| Alignment | Otomatis | Manual via modul struct |
| Akses biner | Langsung | Modul `struct` |

> [!INFO]
> Untuk aplikasi Python biasa, padding tidak perlu dipikirkan. Yang penting dipahami: **kalau membaca data biner dari program C, layout-nya bisa berbeda** dan harus disesuaikan dengan format string yang tepat.$md$, 5)

) as v(slug, judul, konten_md, urutan)
where m.slug = 'struct-memori';



-- ==== 007_pointer_dasar.sql ====
-- =========================================================
-- Seed: Modul 7 â€” pointer-dasar
-- Dasar Pointer & Alamat Memori
--
-- Klaim UB di modul ini SUDAH DIVERIFIKASI terhadap standar C++
-- (docs/riset/04-RISET-UB-POINTER.md)
-- =========================================================

insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
select m.id, v.slug, v.judul, v.konten_md, v.urutan
from public.modul m, (values

('alamat-memori', 'Alamat Memori', $md$Setiap variabel di program menempati ruang di memori, dan ruang itu punya **alamat**.

```cpp
int nilai = 42;

cout << nilai;    // 42    <- NILAI
cout << &nilai;   // 0x7ffd...  <- ALAMAT
```

Operator `&` (address-of) mengambil alamat sebuah variabel.

## Analogi: Rumah dan Alamat

| Konsep | Analogi |
|--------|---------|
| Variabel | Rumah |
| Nilai | Isi rumah |
| Alamat | Alamat rumah |
| Pointer | Kertas berisi alamat rumah |

Pointer tidak menyimpan isi rumah â€” ia menyimpan **alamat** rumah.

## Alamat Itu Angka

Alamat memori sebenarnya hanyalah angka â€” nomor posisi di memori. Di sistem 64-bit, alamat ditulis dalam heksadesimal:

```
0x7ffdd6755440
```

Alamat ini berubah setiap kali program dijalankan (karena *address space layout randomization*). Yang penting bukan angkanya, tetapi bahwa alamat itu **menunjuk ke lokasi yang konsisten** selama program berjalan.

## Melihat Ukuran Alamat

```cpp
cout << sizeof(&nilai);   // 8 pada sistem 64-bit
```

Alamat selalu berukuran sama (8 byte di 64-bit), tidak peduli tipe datanya. Alamat `int` dan alamat `double` sama-sama 8 byte.

> [!INFO]
> Alamat memori bukanlah nilai yang perlu dihafal. Yang perlu dipahami: **setiap variabel punya alamat unik**, dan pointer menyimpan alamat itu.

## Mengapa Ini Penting

Dengan alamat, kamu bisa:

1. **Mengubah nilai variabel lain** dari dalam fungsi
2. **Menghindari penyalinan** data besar
3. **Membuat struktur data dinamis** yang ukurannya berubah
4. **Mengakses memori secara langsung** untuk kontrol tingkat rendah

Ini semua adalah dasar dari linked list, tree, graph, dan hampir semua struktur data lanjutan.$md$, 1),

('mendeklarasikan-pointer', 'Mendeklarasikan Pointer', $md$Pointer dideklarasikan dengan tanda bintang `*` setelah tipe.

```cpp
int* p;      // pointer ke int
double* q;   // pointer ke double
char* r;     // pointer ke char
```

## Cara Membaca Deklarasi

Baca dari **kanan ke kiri**:

```cpp
int* p;   // "p adalah pointer ke int"
```

Ini membantu saat tipe menjadi rumit:

```cpp
int** pp;         // "pp adalah pointer ke pointer ke int"
int* arr[5];      // "arr adalah array berisi 5 pointer ke int"
int (*p)[5];      // "p adalah pointer ke array berisi 5 int"
```

## JEBAKAN: int* a, b

Ini kesalahan yang sangat sering terjadi:

```cpp
int* a, b;    // HANYA a yang pointer!
```

Tanda `*` hanya berlaku untuk variabel **pertama**. `b` adalah `int` biasa.

**Bukti terukur:**

```cpp
int* a, b;
cout << sizeof(a);   // 8  (pointer)
cout << sizeof(b);   // 4  (int, BUKAN pointer!)
```

**Cara yang benar:**

```cpp
int* a;
int* b;      // tulis terpisah, atau
int *a, *b;  // ulangi tanda bintang
```

> [!PERHATIAN]
> `int* a, b` adalah jebakan klasik. Selalu tulis deklarasi pointer di baris terpisah, atau ulangi tanda bintang untuk setiap variabel.

## Inisialisasi

```cpp
int nilai = 42;

int* p = &nilai;      // BENAR: p menunjuk ke nilai
int* kosong = nullptr; // BENAR: pointer kosong
int* bahaya;           // BAHAYA: pointer liar (wild pointer)
```

`int* bahaya;` berisi alamat acak. Mendereferensinya adalah **undefined behavior** yang bisa crash.

> [!BAHAYA]
> Selalu inisialisasi pointer. Kalau belum tahu mau menunjuk ke mana, isi dengan `nullptr`. Pointer yang tidak diinisialisasi berisi alamat acak dan sangat berbahaya.$md$, 2),

('dereferensi', 'Dereferensi', $md$Dereferensi berarti **mengambil nilai di alamat yang disimpan pointer**. Dilakukan dengan operator `*`.

```cpp
int nilai = 42;
int* p = &nilai;

cout << p;    // 0x7ffd...  <- alamat
cout << *p;   // 42         <- nilai di alamat itu
```

## Membaca dan Menulis

```cpp
int nilai = 42;
int* p = &nilai;

cout << *p;    // 42  - membaca

*p = 100;      // menulis lewat pointer
cout << nilai; // 100 - nilai ASLI berubah!
```

Inilah kekuatan pointer: **mengubah variabel lain** tanpa menyentuh namanya langsung.

## Dua Arti Tanda Bintang

Ini yang sering membingungkan pemula:

| Konteks | Arti |
|---------|------|
| Di deklarasi | Bagian dari TIPE |
| Di ekspresi | Operator dereferensi |

```cpp
int* p = &nilai;   // * di sini bagian dari tipe
*p = 100;          // * di sini operator dereferensi
```

## Bahaya: Dereferensi nullptr

```cpp
int* p = nullptr;
cout << *p;    // UNDEFINED BEHAVIOR - crash!
```

Mendereferensi `nullptr` adalah **undefined behavior**. Program biasanya crash, tetapi standar tidak menjamin itu â€” bisa saja tampak berjalan normal.

**Selalu periksa sebelum dereferensi:**

```cpp
if (p != nullptr) {
    cout << *p;   // aman
}
```

> [!TIPS]
> Kebiasaan baik: sebelum mendereferensi pointer, tanyakan "apakah pointer ini pasti menunjuk ke objek yang valid?" Kalau ragu, periksa dengan `if (p)`.

## Pointer dan const

`const` pada pointer bisa berarti dua hal berbeda:

```cpp
// 1. Tidak bisa mengubah NILAI yang ditunjuk
const int* p1 = &nilai;
// *p1 = 10;   // ERROR
p1 = &lain;    // BOLEH

// 2. Tidak bisa mengubah ALAMAT yang disimpan
int* const p2 = &nilai;
*p2 = 10;      // BOLEH
// p2 = &lain; // ERROR

// 3. Keduanya tidak bisa diubah
const int* const p3 = &nilai;
```

Cara membaca: baca dari kanan ke kiri.

| Deklarasi | Arti |
|-----------|------|
| `const int* p` | pointer ke int yang konstan |
| `int* const p` | pointer konstan ke int |
| `const int* const p` | pointer konstan ke int yang konstan |$md$, 3),

('pointer-python', 'Pointer di Python', $md$Python **tidak punya pointer** seperti C++. Tetapi Python punya sesuatu yang mirip: **referensi**.

## Semua Nama di Python Adalah Referensi

```python
x = [1, 2, 3]
y = x          # y menunjuk objek yang SAMA

y.append(4)
print(x)       # [1, 2, 3, 4] - x ikut berubah!
```

`y = x` tidak menyalin list. Kedua nama menunjuk **objek yang sama**.

## Melihat Identitas Objek

```python
x = [1, 2, 3]
y = x

print(id(x))            # 140323743028864
print(id(y))            # 140323743028864  <- SAMA
print(id(x) == id(y))   # True
```

`id()` mengembalikan identitas objek â€” mirip alamat memori.

## Ini MIRIP Pointer, Tapi BEDA

| Aspek | C++ pointer | Python nama |
|-------|-------------|-------------|
| Menyimpan | Alamat | Referensi ke objek |
| Aritmetika | Bisa (`p + 1`) | Tidak bisa |
| Bisa di-cast | Bisa | Tidak bisa |
| Alamat terlihat | Ya (`cout << p`) | Tidak langsung (`id()`) |
| Manajemen memori | Manual | Otomatis |

**Perbedaan paling penting:** di C++ kamu bisa melakukan **aritmetika pointer** (`p + 1`), di Python tidak. Kamu tidak bisa "menambah 1" pada nama Python.

## Membuat Salinan Sebenarnya

```python
x = [1, 2, 3]
y = x.copy()      # salinan baru

y.append(4)
print(x)          # [1, 2, 3] - TIDAK berubah
print(y)          # [1, 2, 3, 4]
print(id(x) == id(y))   # False
```

## Untuk Objek Bersarang: deepcopy

```python
import copy

x = [[1, 2], [3, 4]]
y = x.copy()          # salinan DANGKAL

y[0].append(99)
print(x)              # [[1, 2, 99], [3, 4]] - IKUT berubah!
```

`copy()` hanya menyalin list luar. List di dalamnya masih **dibagi**.

```python
z = copy.deepcopy(x)  # salinan MENDALAM

z[0].append(77)
print(x)              # tidak berubah
```

> [!BAHAYA]
> `copy()` hanya menyalin satu level. Untuk objek bersarang, gunakan `copy.deepcopy()`. Ini sumber bug yang sangat umum di Python.

## Mengapa Python Tidak Butuh Pointer

Python mengelola memori otomatis:

1. **Tidak ada alamat eksplisit** â€” kamu tidak perlu tahu di mana objek disimpan
2. **Tidak ada `delete`** â€” *garbage collector* membersihkan objek yang tidak dipakai
3. **Tidak ada dangling pointer** â€” objek tetap hidup selama masih ada referensi

> [!INFO]
> Memahami pointer C++ membuatmu memahami **mengapa** Python dirancang tanpa pointer. Python mengorbankan kontrol tingkat rendah demi keamanan. Untuk sebagian besar aplikasi, ini pertukaran yang menguntungkan.$md$, 4),

('one-past-the-end', 'Koreksi: One-Past-The-End Itu LEGAL', $md$Bagian ini mengoreksi kesalahpahaman yang **sangat umum** â€” termasuk yang sering diajarkan secara keliru.

## Kesalahpahaman Umum

Banyak yang mengatakan:

> "Melakukan `arr + 5` pada array berukuran 5 adalah undefined behavior."

**Ini SALAH.**

## Yang Benar

Standar C++ **mengizinkan** membentuk pointer satu langkah melewati elemen terakhir. Pointer itu disebut **one-past-the-end**.

```cpp
int arr[5] = {10, 20, 30, 40, 50};

int* akhir = arr + 5;    // LEGAL! Ini pointer one-past-the-end
```

Ini bukan UB. Standar bahkan menamai kategori nilai ini sebagai nilai yang sah.

## Bukti: Idiom Loop yang Sah

Perhatikan loop berikut â€” ini **sah** justru karena `arr + 5` legal:

```cpp
for (int* p = arr; p != arr + 5; ++p) {
    cout << *p << " ";
}
// Output: 10 20 30 40 50
```

Kalau `arr + 5` UB, maka idiom loop standar ini juga UB â€” padahal ini cara yang lazim dan benar untuk mengiterasi array.

## Tiga Hal yang Berbeda

Ini yang harus dibedakan dengan jelas:

| Operasi | Status |
|---------|--------|
| **Membentuk** `arr + 5` (one-past-end) | **LEGAL** |
| **Mendereferensi** `*(arr + 5)` | **UNDEFINED BEHAVIOR** |
| **Melangkah lebih jauh** `arr + 6` atau `arr - 1` | **UNDEFINED BEHAVIOR** |

```cpp
int arr[5];

int* a = arr + 5;    // LEGAL
// int x = *a;       // UB - tidak dijalankan
// int* b = arr + 6; // UB - tidak dijalankan
// int* c = arr - 1; // UB - tidak dijalankan
```

## Mengapa Aturan Ini Ada

Aturan ini masuk akal kalau dipikirkan: untuk menulis loop `p != akhir`, kamu **butuh** bisa membentuk pointer `akhir` yang menunjuk satu langkah melewati array. Kalau tidak boleh, kamu harus memakai indeks dan perbandingan `<`, yang kurang umum di C++.

## Ringkasan Aturan Aritmetika Pointer

Untuk array dengan `n` elemen:

```
arr + i  LEGAL    jika  0 <= i <= n
arr + i  UB       jika  i < 0 atau i > n

*(arr + i)  LEGAL jika  0 <= i < n
*(arr + i)  UB    jika  i == n atau di luar rentang
```

Perhatikan batasnya: **`<= n`** untuk membentuk pointer, **`< n`** untuk mendereferensi.

> [!INFO]
> Ini contoh penting bahwa "aturan yang sering diulang" belum tentu benar. Selalu verifikasi ke standar atau dokumentasi resmi, bukan ke sumber sekunder.$md$, 5)

) as v(slug, judul, konten_md, urutan)
where m.slug = 'pointer-dasar';



-- ==== 008_pointer_array.sql ====
-- =========================================================
-- Seed: Modul 8 â€” pointer-array
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

Ini penting â€” ada dua situasi di mana array tetap array:

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

Karena tujuan `p + 1` adalah menunjuk **elemen berikutnya**, bukan byte berikutnya. Kalau `int*` menambah 1 byte, ia akan menunjuk ke tengah-tengah int â€” tidak berguna.

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

Ini bukan kebetulan â€” `arr[i]` **didefinisikan** sebagai `*(arr + i)`.

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
| `arr[i]` | **Paling jelas** â€” pakai ini |
| `*(arr + i)` | Saat menjelaskan cara kerja array |
| `*(p + i)` | Saat bekerja dengan pointer |
| `i[arr]` | Jangan dipakai â€” hanya fakta bahasa |

> [!TIPS]
> Pakai `arr[i]` untuk keterbacaan. Pahami `*(arr + i)` untuk mengerti **mengapa** array bisa diakses sangat cepat: alamat elemen dihitung langsung, tanpa mencari.

## Konsekuensi Penting

Karena `arr[i]` setara `*(arr + i)`, **array tidak menyimpan informasi batas**. Tidak ada cara bagi `arr` untuk tahu berapa panjangnya.

Inilah mengapa C++ tidak bisa mendeteksi akses di luar batas â€” informasinya memang tidak ada di array itu sendiri.

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

Di dalam fungsi, `sizeof(arr)` menghasilkan **8 byte** â€” ukuran pointer, bukan 20 byte ukuran array.

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
> Untuk kode C++ modern, pakai `std::span`. Untuk kode gaya C, selalu kirim ukuran sebagai parameter terpisah. Jangan pernah mengandalkan `sizeof` di dalam fungsi untuk array parameter â€” hasilnya selalu ukuran pointer.

## Pointer sebagai Parameter Bisa Mengubah Array

Ini keuntungannya â€” berbeda dari kirim nilai:

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

Di C++, mengakses lewat pointer **tidak** menyalin â€” mengubahnya akan mengubah data asli.

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



-- ==== 009_pointer_struct.sql ====
-- =========================================================
-- Seed: Modul 9 â€” pointer-struct
-- Pointer ke Struct & Arrow Operator
-- Semua contoh kode DIKOMPILASI dan DIJALANKAN (GCC 16.2.1)
-- =========================================================

insert into public.modul (slug, judul, topik, deskripsi, estimasi_menit, urutan)
values ('pointer-struct', 'Pointer ke Struct & Arrow Operator', 'pointer',
  'Operator -> dan (*)., plus mengapa pointer lebih efisien untuk struct besar.', 12, 9);

insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
select m.id, v.slug, v.judul, v.konten_md, v.urutan
from public.modul m, (values

('pointer-ke-struct', 'Pointer ke Struct', $md$Pointer bisa menunjuk ke struct, sama seperti ke tipe lain.

```cpp
struct Titik { int x; int y; };

Titik t = {3, 7};
Titik* pt = &t;      // pointer ke struct
```

## Cara Mengakses Anggota

Ada **dua cara**, dan keduanya setara:

```cpp
(*pt).x      // BENAR - dereferensi dulu, lalu akses anggota
pt->x        // BENAR - cara singkat
```

**Bukti terukur:** ketiganya menghasilkan nilai yang sama.

```cpp
cout << t.x;        // 3
cout << pt->x;      // 3
cout << (*pt).x;    // 3
```

## Mengapa Ada Operator ->

`(*pt).x` benar tetapi **merepotkan ditulis** dan mudah salah. Tanda kurung wajib ada karena operator `.` lebih tinggi prioritasnya daripada `*`.

Tanpa tanda kurung:

```cpp
*pt.x        // SALAH - dibaca sebagai *(pt.x)
```

Ini akan error karena `pt.x` tidak valid (pt adalah pointer, bukan struct).

Karena itu C++ menyediakan `->` sebagai singkatan:

```cpp
pt->x   ==   (*pt).x
```

> [!TIPS]
> Pakai `->` untuk pointer. Pakai `.` untuk nilai atau referensi. Aturan sederhana ini mencegah kebingungan.

## Mengubah Anggota Lewat Pointer

```cpp
Titik t = {3, 7};
Titik* pt = &t;

pt->x = 99;

cout << t.x;   // 99 - struct ASLI berubah
```

Karena pointer menunjuk ke `t` yang asli, mengubah lewat pointer mengubah `t`.

## Tabel Ringkasan

| Ekspresi | Valid? | Keterangan |
|----------|--------|------------|
| `t.x` | Ya | `t` adalah struct |
| `pt->x` | Ya | `pt` adalah pointer |
| `(*pt).x` | Ya | Dereferensi lalu akses |
| `pt.x` | **Tidak** | `pt` pointer, bukan struct |
| `*pt.x` | **Tidak** | Prioritas salah |
| `t->x` | **Tidak** | `t` bukan pointer |$md$, 1),

('struct-besar-dan-pointer', 'Struct Besar & Pointer', $md$Mengapa pointer penting untuk struct? Karena **menghindari penyalinan**.

## Masalah: Struct Besar Disalin

```cpp
struct Besar {
    int data[1000];
};

cout << sizeof(Besar);   // 4000 byte
```

Kalau struct ini dikirim **sebagai nilai** ke fungsi:

```cpp
void proses(Besar b) {    // menyalin 4000 byte!
    // ...
}
```

Setiap pemanggilan menyalin **4000 byte**. Kalau dipanggil 1000 kali, itu 4 juta byte penyalinan yang tidak perlu.

**Bukti terukur:** `sizeof(Besar)` = 4000 byte, sedangkan `sizeof(Besar*)` hanya 8 byte.

## Solusi: Kirim Pointer

```cpp
void proses(Besar* b) {   // menyalin 8 byte saja
    // ...
}

proses(&data);
```

Hanya **8 byte** yang disalin (ukuran pointer), bukan 4000 byte.

## Tiga Cara Mengirim Struct

| Cara | Disalin? | Bisa diubah? | Kapan dipakai |
|------|----------|--------------|---------------|
| `void f(Titik t)` | **Ya** (seluruh struct) | Tidak | Struct kecil + perlu salinan |
| `void f(Titik* t)` | Hanya 8 byte | **Ya** | Perlu mengubah data asli |
| `void f(const Titik* t)` | Hanya 8 byte | Tidak | **Paling umum** - hanya membaca |

## Bukti: Nilai vs Pointer

**Kirim sebagai nilai â€” TIDAK berubah:**

```cpp
void ubahNilai(Mahasiswa m) {
    m.ipk = 4.0;
}

Mahasiswa m = {"Rani", 20, 3.5};
ubahNilai(m);
// m.ipk tetap 3.5
```

**Kirim sebagai pointer â€” BERUBAH:**

```cpp
void ubahPointer(Mahasiswa* m) {
    m->ipk = 4.0;
}

ubahPointer(&m);
// m.ipk jadi 4.0
```

**Output terukur:**

```
Sebelum:               Rani ipk=3.5
Setelah ubahNilai:     Rani ipk=3.5   <- TIDAK berubah
Setelah ubahPointer:   Rani ipk=4     <- BERUBAH
```

## Pola Paling Umum: const Pointer

```cpp
void cetak(const Mahasiswa* m) {
    cout << m->nama << " ipk=" << m->ipk;
    // m->ipk = 4.0;   // ERROR - tidak bisa diubah
}
```

`const` mencegah fungsi mengubah data, sementara pointer mencegah penyalinan. Ini pola yang paling sering dipakai di kode C++ profesional.

> [!TIPS]
> Aturan praktis: kirim struct sebagai `const T*` kalau hanya membaca, dan `T*` kalau perlu mengubah. Kirim sebagai nilai (`T`) hanya untuk struct kecil (di bawah ~16 byte) yang memang perlu disalin.$md$, 2),

('array-of-struct-pointer', 'Array of Struct Lewat Pointer', $md$Pointer juga berguna untuk mengakses array of struct.

## Akses dengan Aritmetika Pointer

```cpp
Mahasiswa daftar[3] = {
    {"Rani", 20, 3.75},
    {"Budi", 21, 3.20},
    {"Citra", 22, 3.90}
};

Mahasiswa* p = daftar;   // decay ke &daftar[0]

for (int i = 0; i < 3; i++) {
    cout << (p + i)->nama;
}
```

**Output terukur:**

```
(p+0)->nama = Rani
(p+1)->nama = Budi
(p+2)->nama = Citra
```

## Bentuk yang Setara

Keempat bentuk ini menghasilkan hasil yang sama:

```cpp
daftar[i].nama        // cara indeks biasa
p[i].nama             // pointer + indeks
(p + i)->nama         // aritmetika pointer + arrow
(*(p + i)).nama       // eksplisit
```

**Bukti:** `p[1].nama` = `Budi`, sama dengan `(p+1)->nama`.

## Kapan Pakai yang Mana

| Bentuk | Kapan dipakai |
|--------|---------------|
| `daftar[i].nama` | **Paling jelas** - pakai ini untuk kode baru |
| `p[i].nama` | Saat `p` sudah pointer |
| `(p + i)->nama` | Saat menjelaskan aritmetika pointer |

> [!TIPS]
> Walaupun `(p + i)->nama` valid, `p[i].nama` lebih mudah dibaca. Pakai bentuk yang paling jelas kecuali ada alasan khusus.

## Mengubah Elemen Lewat Pointer

```cpp
Mahasiswa* p = daftar;

p[1].ipk = 4.0;      // atau (p + 1)->ipk = 4.0

cout << daftar[1].ipk;   // 4.0 - array ASLI berubah
```

## Iterasi dengan Pointer

```cpp
// Gaya pointer
for (Mahasiswa* p = daftar; p != daftar + 3; ++p) {
    cout << p->nama << "\n";
}
```

Perhatikan `daftar + 3` â€” ini **one-past-the-end**, dan seperti dijelaskan di modul 7, ini **LEGAL** (bukan UB). Yang UB hanya mendereferensinya.

## Jebakan: nullptr

```cpp
Mahasiswa* kosong = nullptr;

if (kosong) {
    // tidak dijalankan
}

// kosong->nama;   // UB - tidak dijalankan
```

Selalu periksa pointer sebelum mengakses anggotanya, terutama kalau pointer berasal dari parameter fungsi.$md$, 3),

('padanan-python', 'Padanan di Python', $md$Python tidak punya pointer, tetapi ada perbedaan penting yang perlu dipahami.

## Python Tidak Butuh Arrow Operator

```python
@dataclass
class Titik:
    x: int
    y: int

t = Titik(3, 7)
print(t.x)     # 3 - selalu pakai titik
```

Tidak ada `t->x` karena tidak ada pointer. Semua akses memakai titik.

## Perbedaan Penting: Objek Disalin atau Dibagi?

Ini sumber kebingungan terbesar saat pindah dari C++ ke Python.

**Di C++, struct disalin:**

```cpp
Titik a = {3, 7};
Titik b = a;      // SALINAN

b.x = 99;
cout << a.x;      // 3 - TIDAK berubah
```

**Di Python, objek dibagi:**

```python
a = Titik(3, 7)
b = a             # REFERENSI yang sama

b.x = 99
print(a.x)        # 99 - IKUT berubah!
```

## Mengapa Berbeda

| Aspek | C++ struct | Python objek |
|-------|-----------|--------------|
| `b = a` | Menyalin **nilai** | Menyalin **referensi** |
| Mengubah `b` | Tidak mempengaruhi `a` | **Mempengaruhi `a`** |
| Butuh pointer? | Ya, untuk berbagi | Tidak, sudah otomatis |

Di C++, untuk membuat dua variabel menunjuk objek yang sama, kamu **butuh pointer**. Di Python, itu terjadi **secara otomatis**.

## Cara Membuat Salinan di Python

```python
import copy

a = Titik(3, 7)
b = copy.copy(a)      # salinan dangkal

b.x = 99
print(a.x)            # 3 - TIDAK berubah
```

Untuk objek bersarang, gunakan `copy.deepcopy()`.

## Ringkasan Perbandingan

| Operasi | C++ | Python |
|---------|-----|--------|
| Akses anggota | `t.x` (nilai) atau `pt->x` (pointer) | `t.x` selalu |
| `b = a` | Menyalin nilai | Menyalin referensi |
| Berbagi objek | Butuh pointer | Otomatis |
| Salinan | Otomatis saat `=` | Perlu `copy()` |
| Null check | Perlu (`if (p)`) | Tidak ada null pointer |

> [!INFO]
> Python menghilangkan pointer dengan membuat semua nama menjadi referensi. Ini menghilangkan banyak bug (dangling pointer, null dereference), tetapi juga menghilangkan kontrol tingkat rendah yang kadang dibutuhkan.$md$, 4)

) as v(slug, judul, konten_md, urutan)
where m.slug = 'pointer-struct';



-- ==== 010_pointer_dinamis.sql ====
-- =========================================================
-- Seed: Modul 10 â€” pointer-dinamis
-- Alokasi Memori Dinamis
-- Semua contoh kode DIKOMPILASI dan DIJALANKAN (GCC 16.2.1)
-- Klaim UB diverifikasi di docs/riset/04-RISET-UB-POINTER.md
-- =========================================================

insert into public.modul (slug, judul, topik, deskripsi, estimasi_menit, urutan)
values ('pointer-dinamis', 'Alokasi Memori Dinamis', 'pointer',
  'Stack vs heap, new/delete, tiga bug klasik memori, dan mengapa C++ modern memakai smart pointer.', 18, 10);

insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
select m.id, v.slug, v.judul, v.konten_md, v.urutan
from public.modul m, (values

('stack-vs-heap', 'Stack vs Heap', $md$Program C++ punya dua area memori utama: **stack** dan **heap**. Memahami perbedaannya adalah kunci memahami alokasi dinamis.

## Perbandingan

| Aspek | Stack | Heap |
|-------|-------|------|
| Kecepatan | **Sangat cepat** | Lebih lambat |
| Ukuran | Kecil (biasanya 1-8 MB) | Besar (sebatas memori tersedia) |
| Masa hidup | Otomatis (saat keluar scope) | **Manual** (sampai di-`delete`) |
| Pengelolaan | Otomatis oleh compiler | **Manual oleh programmer** |
| Fragmentasi | Tidak ada | Bisa terjadi |

## Variabel Biasa Ada di Stack

```cpp
void fungsi() {
    int x = 42;         // di stack
    Titik t = {3, 7};   // di stack

}   // <- x dan t OTOMATIS hilang di sini
```

Ketika fungsi selesai, semua variabel lokal **otomatis dibebaskan**. Tidak perlu melakukan apa pun.

## Alokasi Dinamis Ada di Heap

```cpp
void fungsi() {
    int* p = new int(42);   // di HEAP

    // ... pakai p ...

    delete p;   // <- WAJIB dibebaskan manual
}
```

Kalau lupa `delete`, memori tetap terpakai **sampai program berakhir**.

## Mengapa Ada Dua

**Stack** cocok untuk data yang:
- Ukurannya diketahui saat kompilasi
- Masa hidupnya terbatas pada satu scope

**Heap** diperlukan untuk data yang:
- Ukurannya baru diketahui saat program berjalan
- Masa hidupnya harus melebihi scope pembuatnya
- Ukurannya terlalu besar untuk stack

## Contoh: Ukuran Baru Diketahui Saat Runtime

```cpp
int n;
cout << "Berapa data? ";
cin >> n;

int* arr = new int[n];   // ukuran dari input pengguna

// ... pakai arr ...

delete[] arr;
```

Ini **tidak bisa** dilakukan dengan array biasa karena ukurannya harus konstanta saat kompilasi.

## Bahaya: Stack Overflow

Stack kecil. Alokasi besar di stack bisa menyebabkan **stack overflow**:

```cpp
void bahaya() {
    int besar[1000000];   // 4 MB di stack - bisa overflow!
}
```

Solusinya: alokasikan di heap.

```cpp
void aman() {
    int* besar = new int[1000000];   // di heap
    // ...
    delete[] besar;
}
```

> [!INFO]
> Aturan praktis: data kecil dan berumur pendek -> stack. Data besar atau berumur panjang -> heap. Tapi di C++ modern, **hindari `new`/`delete` manual** â€” pakai `std::vector` atau *smart pointer*.$md$, 1),

('new-dan-delete', 'new dan delete', $md$`new` mengalokasikan memori di heap. `delete` membebaskannya.

## Alokasi Satu Nilai

```cpp
int* p = new int(42);   // alokasi + inisialisasi

cout << *p;             // 42

delete p;               // bebaskan
```

## Alokasi Array

```cpp
int* arr = new int[5];   // 5 elemen

for (int i = 0; i < 5; i++) arr[i] = i * 10;
cout << arr[4];          // 40

delete[] arr;            // PERHATIKAN: delete[]
```

## ATURAN: new[] HARUS Dipasangkan delete[]

Ini aturan yang **tidak boleh dilanggar**:

| Alokasi | Pembebasan yang BENAR | Yang SALAH |
|---------|----------------------|------------|
| `new int` | `delete p` | `delete[] p` |
| `new int[5]` | `delete[] arr` | `delete arr` |

Mencampur keduanya adalah **undefined behavior**.

```cpp
int* arr = new int[5];
delete arr;      // UB! seharusnya delete[]
```

> [!BAHAYA]
> `new[]` harus dipasangkan `delete[]`, dan `new` harus dipasangkan `delete`. Mencampurnya adalah undefined behavior yang bisa menyebabkan crash atau kerusakan memori.

## delete TIDAK Mengubah Pointer

Ini fakta yang mengejutkan banyak orang:

```cpp
int* p = new int(42);
cout << p;      // 0x557d611d7030

delete p;
cout << p;      // 0x557d611d7030  <- MASIH ALAMAT LAMA!
```

**`delete` membebaskan memori, tetapi TIDAK mengubah nilai pointer.**

Setelah `delete`, `p` masih menyimpan alamat lama. Alamat itu sekarang tidak valid â€” memakainya adalah **undefined behavior**.

**Praktik baik:**

```cpp
delete p;
p = nullptr;    // set sendiri, tidak otomatis
```

## Ukuran Pointer vs Data

```cpp
cout << sizeof(int*);   // 8 (pointer)
cout << sizeof(int);    // 4 (data)
```

Pointer selalu 8 byte di sistem 64-bit, tidak peduli ukuran data yang ditunjuk.

> [!TIPS]
> Setelah `delete`, selalu set pointer ke `nullptr`. Ini mencegah *dangling pointer* dan membuat pemeriksaan `if (p)` menjadi bermakna.$md$, 2),

('tiga-bug-klasik', 'Tiga Bug Klasik Memori', $md$Manajemen memori manual adalah sumber bug paling mahal di C/C++. Ada tiga yang paling sering terjadi.

### Bug 1: Memory Leak

**Penyebab:** lupa `delete`.

```cpp
void bocor() {
    for (int i = 0; i < 10; i++) {
        int* p = new int(i);
        if (*p > 5) {
            return;      // <- LEAK: return tanpa delete
        }
        delete p;
    }
}
```

**Mengapa bocor:** `new` mengalokasikan di heap. Saat `return`, pointer `p` hilang dari scope, **tetapi memori di heap tidak otomatis dibebaskan**.

**Akibat:** memori terpakai sampai program berakhir. Dalam program panjang, memori habis dan program crash.

**Penting:** lupa `delete` **bukan** undefined behavior â€” hanya kebocoran memori. Bedanya penting:

| Masalah | UB? | Akibat |
|---------|-----|--------|
| Lupa `delete` | **Tidak** | Memori terpakai terus, akhirnya habis |
| Pakai setelah `delete` | **Ya** | Bisa apa saja, termasuk crash |

**Perbaikan:**

```cpp
int* p = new int(i);
if (*p > 5) {
    int hasil = *p;
    delete p;        // bebaskan SEBELUM return
    return hasil;
}
delete p;
```

### Bug 2: Dangling Pointer

**Penyebab:** memakai pointer setelah memorinya dibebaskan.

```cpp
int* p = new int(42);
delete p;

cout << *p;    // UNDEFINED BEHAVIOR!
```

**Bahayanya:** kode ini **mungkin tampak berjalan normal**. Memori yang sudah dibebaskan masih berisi nilai lama, jadi `*p` bisa mencetak 42.

Tetapi begitu memori itu dipakai untuk hal lain, nilainya berubah. Inilah yang membuat bug ini sangat sulit dilacak.

**Perbaikan:**

```cpp
delete p;
p = nullptr;

if (p) {
    cout << *p;    // tidak dijalankan
}
```

### Bug 3: Double Free

**Penyebab:** memanggil `delete` dua kali pada pointer yang sama.

```cpp
int* p = new int(42);

delete p;
delete p;      // UNDEFINED BEHAVIOR!
```

**Akibat:** bisa crash, bisa merusak heap, bisa apa saja.

**Perbaikan:**

```cpp
delete p;
p = nullptr;

delete p;      // AMAN - delete pada nullptr tidak melakukan apa-apa
```

Inilah salah satu alasan **selalu set pointer ke `nullptr` setelah `delete`** â€” ia membuat `delete` kedua menjadi aman.

## Ringkasan

| Bug | Penyebab | UB? | Pencegahan |
|-----|----------|-----|------------|
| Memory leak | Lupa `delete` | Tidak | Selalu bebaskan, atau pakai smart pointer |
| Dangling | Pakai setelah `delete` | **Ya** | Set `nullptr` setelah `delete` |
| Double free | `delete` dua kali | **Ya** | Set `nullptr` setelah `delete` |

> [!BAHAYA]
> Ketiga bug ini adalah alasan mengapa C++ modern menganjurkan **smart pointer**. Dengan `unique_ptr`, ketiganya **tidak mungkin terjadi** â€” memori dibebaskan otomatis saat pointer keluar scope.$md$, 3),

('smart-pointer', 'Smart Pointer', $md$C++ modern menyediakan **smart pointer** yang membebaskan memori otomatis. Ini menghilangkan tiga bug klasik sekaligus.

## unique_ptr: Kepemilikan Tunggal

```cpp
#include <memory>

{
    auto p = make_unique<int>(99);

    cout << *p;    // 99

}   // <- memori OTOMATIS dibebaskan di sini
```

Tidak ada `delete`. Tidak mungkin lupa. Tidak mungkin double free.

## unique_ptr Tidak Bisa Disalin

Karena kepemilikannya tunggal:

```cpp
auto p1 = make_unique<int>(7);

// auto p2 = p1;         // ERROR: tidak bisa disalin
auto p2 = move(p1);      // BOLEH: dipindahkan

cout << *p2;             // 7
cout << (p1 == nullptr); // 1 (true) - p1 sekarang kosong
```

**Setelah dipindahkan, `p1` menjadi kosong.** Ini mencegah dua `unique_ptr` memiliki objek yang sama.

## unique_ptr untuk Array

```cpp
auto arr = make_unique<int[]>(3);

arr[0] = 1;
arr[1] = 2;
arr[2] = 3;

// otomatis dibebaskan, tidak perlu delete[]
```

## shared_ptr: Kepemilikan Bersama

Kalau beberapa bagian kode perlu memiliki objek yang sama:

```cpp
#include <memory>

auto s1 = make_shared<int>(55);

cout << s1.use_count();    // 1

{
    auto s2 = s1;          // salinan DIPERBOLEHKAN
    cout << s1.use_count(); // 2
}

cout << s1.use_count();    // 1 - s2 sudah hilang
```

**Output terukur:** `1 â†’ 2 â†’ 1`

Memori dibebaskan ketika **penghitung mencapai nol** â€” artinya tidak ada lagi yang memiliki objek itu.

## Perbandingan

| Aspek | Pointer mentah | unique_ptr | shared_ptr |
|-------|----------------|------------|------------|
| Perlu `delete` manual | **Ya** | Tidak | Tidak |
| Bisa disalin | Ya | **Tidak** | Ya |
| Bisa dipindahkan | Ya | **Ya** | Ya |
| Risiko leak | **Tinggi** | Tidak ada | Tidak ada |
| Biaya | Gratis | Sangat kecil | Sedikit lebih besar |

## Kapan Pakai yang Mana

| Situasi | Pilihan |
|---------|---------|
| Kepemilikan tunggal (paling umum) | **`unique_ptr`** |
| Kepemilikan bersama | `shared_ptr` |
| Hanya melihat, tidak memiliki | Pointer mentah atau referensi |
| Berinteraksi dengan API C | Pointer mentah |

> [!TIPS]
> **Aturan C++ modern:** hindari `new`/`delete` manual. Pakai `make_unique` sebagai default. Gunakan `shared_ptr` hanya kalau benar-benar perlu kepemilikan bersama â€” ia sedikit lebih mahal karena menghitung referensi.

## Mengapa Ini Penting

Dengan smart pointer, tiga bug klasik **tidak mungkin terjadi**:

| Bug | Dengan unique_ptr |
|-----|-------------------|
| Memory leak | Tidak mungkin â€” dibebaskan otomatis |
| Dangling | Tidak mungkin â€” pointer menjadi kosong |
| Double free | Tidak mungkin â€” hanya dibebaskan sekali |

Ini bukan sekadar kenyamanan. Ini menghilangkan seluruh kategori bug.$md$, 4),

('python-memori', 'Manajemen Memori di Python', $md$Python mengelola memori **otomatis**. Tidak ada `new`, tidak ada `delete`, tidak ada pointer.

## Tidak Ada delete di Python

```python
data = [1, 2, 3, 4, 5]

# ... pakai data ...

# Tidak ada yang perlu dilakukan.
# Python membersihkan otomatis saat data tidak dipakai lagi.
```

## Reference Counting

Python menghitung berapa banyak nama yang menunjuk ke sebuah objek:

```python
import sys

a = [1, 2, 3]

print(sys.getrefcount(a))   # 2 (a + argumen getrefcount)

b = a
print(sys.getrefcount(a))   # 3 (a, b, + argumen)

del b
print(sys.getrefcount(a))   # 2 kembali
```

Ketika penghitung mencapai **nol**, objek dibebaskan otomatis.

**Ini mirip `shared_ptr` di C++**, tetapi terjadi pada semua objek tanpa perlu kamu tulis.

## Garbage Collection untuk Reference Cycle

Reference counting punya satu kelemahan: **siklus referensi**.

```python
class Node:
    def __init__(self):
        self.teman = None

a = Node()
b = Node()

a.teman = b      # a menunjuk b
b.teman = a      # b menunjuk a - SIKLUS!
```

Setelah `a` dan `b` tidak dipakai lagi, penghitung referensinya **tidak mencapai nol** karena keduanya saling menunjuk.

**Solusinya:** Python punya *garbage collector* terpisah yang mendeteksi siklus seperti ini dan membersihkannya.

Jadi Python punya **dua mekanisme**:

| Mekanisme | Menangani |
|-----------|-----------|
| Reference counting | Kasus umum, langsung |
| Garbage collector | Siklus referensi, berkala |

## Mengapa Python Tidak Punya Pointer

| Alasan | Penjelasan |
|--------|------------|
| Semua nama adalah referensi | Tidak perlu pointer terpisah |
| Memori dikelola otomatis | Tidak perlu `new`/`delete` |
| Tidak ada aritmetika | Tidak bisa mengakses memori mentah |
| Aman | Tidak ada dangling, double free, atau leak |

## Perbandingan

| Aspek | C++ pointer mentah | C++ unique_ptr | Python |
|-------|-------------------|----------------|--------|
| Alokasi | `new` | `make_unique` | Otomatis |
| Pembebasan | `delete` manual | Otomatis | Otomatis |
| Risiko leak | **Tinggi** | Tidak ada | Tidak ada |
| Siklus referensi | Bisa | Bisa (dengan shared_ptr) | Ditangani GC |
| Kontrol memori | **Penuh** | Terbatas | Tidak ada |

> [!INFO]
> Python mengorbankan **kontrol** demi **keamanan**. Untuk sebagian besar aplikasi, ini pertukaran yang menguntungkan. Tetapi untuk sistem yang butuh kontrol memori presisi (game engine, sistem embedded, database), C++ tetap diperlukan.

## Yang Perlu Diingat

Walaupun Python mengelola memori otomatis, **kebocoran tetap mungkin**:

1. **Siklus referensi** yang tidak ditangani GC
2. **Cache yang tidak dibatasi** â€” objek disimpan terus dan tidak pernah dilepas
3. **Referensi global** yang menahan objek besar

Jadi "otomatis" bukan berarti "bebas dari masalah memori".$md$, 5),

('kapan-dinamis', 'Kapan Alokasi Dinamis Diperlukan', $md$Tidak semua data perlu dialokasikan secara dinamis. Berikut kapan ia benar-benar diperlukan.

## Empat Situasi yang Memerlukan Heap

### 1. Ukuran Baru Diketahui Saat Runtime

```cpp
int n;
cin >> n;

int* data = new int[n];
```

Array biasa butuh ukuran konstanta saat kompilasi. Kalau ukurannya dari input pengguna, harus pakai heap.

**Di C++ modern:** pakai `std::vector` yang mengurus ini otomatis.

### 2. Masa Hidup Melebihi Scope

```cpp
int* buat() {
    int* p = new int(42);
    return p;    // masih valid setelah fungsi selesai
}
```

Variabel stack hilang saat fungsi selesai. Data di heap tetap hidup sampai di-`delete`.

### 3. Struktur Data Rekursif

Ini yang paling penting untuk Struktur Data:

```cpp
struct Node {
    int data;
    Node* next;      // menunjuk node lain di heap
};
```

**Linked list, tree, dan graph** tidak mungkin dibuat tanpa alokasi dinamis, karena:
- Ukurannya berubah saat program berjalan
- Node saling menunjuk, dan jumlahnya tidak diketahui di awal

### 4. Objek Besar

```cpp
// Stack kecil - ini bisa overflow
int besar[1000000];    // 4 MB

// Heap besar - aman
int* besar = new int[1000000];
```

## Kapan TIDAK Perlu Dinamis

| Situasi | Pilihan lebih baik |
|---------|-------------------|
| Ukuran diketahui saat kompilasi | `std::array` atau array biasa |
| Ukuran dinamis tapi sederhana | `std::vector` |
| Struct kecil | Kirim sebagai nilai |
| Hanya membaca data besar | `const` pointer atau referensi |

## Di C++ Modern: Hindari new/delete Manual

```cpp
// GAYA LAMA - hindari
int* data = new int[n];
// ...
delete[] data;

// GAYA MODERN - pakai ini
vector<int> data(n);
// otomatis dibebaskan
```

`std::vector` melakukan hal yang sama tetapi **tidak mungkin bocor**.

## Untuk Struktur Data: Smart Pointer

```cpp
struct Node {
    int data;
    unique_ptr<Node> next;   // kepemilikan jelas
};
```

Dengan `unique_ptr`, seluruh linked list dibebaskan otomatis saat head keluar scope. Tidak perlu menelusuri dan menghapus satu per satu.

> [!TIPS]
> Untuk modul Struktur Data, kamu akan sering memakai `new`/`delete` karena itu bagian dari materi. Tetapi di kode produksi, pakai `std::vector` dan smart pointer. Memahami keduanya penting: yang satu untuk ujian, yang satu untuk kerja.$md$, 6)

) as v(slug, judul, konten_md, urutan)
where m.slug = 'pointer-dinamis';



-- ==== 011_sesuaikan_10_kartu_10_soal.sql ====
-- =========================================================
-- FlashStruct â€” Penyesuaian 10 Flashcard & 10 Soal per Materi
--
-- Total: 10 Modul x 10 Flashcard = 100 Flashcard (urutan 1..10)
-- Total: 10 Modul x 10 Soal      = 100 Soal      (urutan 1..10)
-- Total: 100 Soal x 4 Opsi       = 400 Opsi Soal (label A..D)
--
-- Semua konten telah divalidasi terhadap batasan skema dan kurikulum:
-- - char_length(depan) <= 400, char_length(belakang) <= 800
-- - char_length(pertanyaan) <= 800, char_length(penjelasan) <= 1200
-- - trace_wajib_kode & soal_kode_butuh_bahasa dipatuhi
-- - tepat 1 jawaban benar per soal
-- =========================================================

-- 1. Hapus kartu dan soal lama (cascade ke opsi_soal)
delete from public.flashcard
where modul_id in (select id from public.modul where slug in ('array-dasar', 'array-multidimensi', 'array-dinamis', 'struct-dasar', 'struct-nested', 'struct-memori', 'pointer-dasar', 'pointer-array', 'pointer-struct', 'pointer-dinamis'));

delete from public.soal
where modul_id in (select id from public.modul where slug in ('array-dasar', 'array-multidimensi', 'array-dinamis', 'struct-dasar', 'struct-nested', 'struct-memori', 'pointer-dasar', 'pointer-array', 'pointer-struct', 'pointer-dinamis'));

-- =========================================================
-- Modul 1: array-dasar (Dasar Array & Indeks)
-- =========================================================
-- FLASHCARD (array-dasar)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa itu array?',
 E'Kumpulan elemen bertipe sama yang disimpan berurutan di memori dan diakses lewat indeks.',
 'ISTILAH', null, null, 1),

(E'Dari indeks berapa array dimulai di C++ dan Python?',
 E'Dari 0. Elemen pertama adalah arr[0], bukan arr[1].',
 'ISTILAH', null, null, 2),

(E'Bagaimana cara mendeklarasikan array 5 bilangan bulat di C++?',
 E'int arr[5];\n\n// Dengan nilai awal:\nint arr[5] = {10, 20, 30, 40, 50};',
 'SINTAKS', E'int arr[5] = {10, 20, 30, 40, 50};', 'cpp', 3),

(E'Bagaimana cara membuat array 5 elemen di Python?',
 E'arr = [0] * 5\n\nDengan nilai langsung:\narr = [10, 20, 30, 40, 50]\n\nPython memakai LIST, bukan array seperti C++.',
 'SINTAKS', E'arr = [0] * 5', 'python', 4),

(E'Apa rumus alamat elemen ke-i pada array?',
 E'alamat(i) = alamat(0) + i x sizeof(Tipe)\\n\\nKarena itu pengaksesan array sangat cepat: alamatnya bisa dihitung langsung.',
 'MEMORI', null, null, 5),

(E'Mengapa pengaksesan array sangat cepat?',
 E'Karena alamat elemen bisa DIHITUNG LANGSUNG:\nalamat(i) = alamat(0) + i x sizeof(Tipe)\n\nTidak perlu mencari atau menelusuri.\nKompleksitasnya O(1) - waktu konstan,\ntidak bergantung pada posisi elemen.',
 'MEMORI', null, null, 6),

(E'int arr[5] = {10,20,30,40,50};\\ncout << arr[2];\\n\\nApa outputnya?',
 E'30\\n\\narr[2] adalah elemen ketiga karena indeks dimulai dari 0:\\narr[0]=10, arr[1]=20, arr[2]=30',
 'TRACING', E'int arr[5] = {10,20,30,40,50};\\ncout << arr[2];', 'cpp', 7),

(E'Berapa nilai arr[0] jika dideklarasikan int arr[5] = {1, 2};?',
 E'1\n\nElemen pertama diisi 1, elemen kedua 2.\nSisanya (arr[2], arr[3], arr[4]) otomatis diisi NOL\ndi C++.\n\nIni berbeda dari variabel lokal biasa yang tidak diinisialisasi\n(mengandung nilai sampah).',
 'TRACING', E'int arr[5] = {1, 2};\\ncout << arr[0];', 'cpp', 8),

(E'Apa yang salah dari kode ini?\\nint arr[5];\\narr[5] = 100;',
 E'Indeks 5 berada DI LUAR batas.\n\nArray berukuran 5 punya indeks 0 sampai 4.\nMenulis arr[5] adalah undefined behavior: mungkin tampak berhasil, tetapi merusak memori di sekitarnya.',
 'JEBAKAN', E'int arr[5];\\narr[5] = 100;  // di luar batas!', 'cpp', 9),

(E'Apa perbedaan array C++ dan list Python?',
 E'Array C++ (int arr[5]):\n- ukuran tetap saat kompilasi\n- tipe elemen seragam\n- satu blok memori berurutan\n\nList Python ([0]*5):\n- ukuran bisa berubah\n- tipe elemen bebas\n- menyimpan referensi ke objek',
 'BANDING', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'array-dasar';

-- SOAL (array-dasar)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Dari indeks berapa array dimulai di C++ dan Python?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: 0\n\nBaik C++ maupun Python memulai indeks dari 0.\nElemen pertama adalah arr[0], bukan arr[1].\n\nPengecoh 1 adalah kesalahan paling umum bagi pemula.',
 1),

(E'Bagaimana cara mendeklarasikan array 3 bilangan bulat dengan nilai awal di C++?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: int arr[3] = {1, 2, 3};\n\nint arr(3) salah: itu sintaks untuk memanggil fungsi, bukan array.\narr = [1,2,3] adalah sintaks Python, bukan C++.\narray arr[3] bukan sintaks C++ yang valid.',
 2),

(E'int arr[5] = {10, 20, 30, 40, 50};\ncout << arr[4];\n\nApa outputnya?',
 E'int arr[5] = {10, 20, 30, 40, 50};\\ncout << arr[4];', 'cpp', 'TRACE', 'TRACING',
 E'Output: 50\n\narr[4] adalah elemen KELIMA (indeks terakhir) karena indeks mulai dari 0.\n\nPengecoh 40 = arr[3]. Pengecoh 10 = arr[0].',
 3),

(E'arr = [10, 20, 30, 40, 50]\nprint(arr[-1])\n\nApa outputnya?',
 E'arr = [10, 20, 30, 40, 50]\\nprint(arr[-1])', 'python', 'TRACE', 'TRACING',
 E'Output: 50\n\nPython mendukung indeks NEGATIF:\narr[-1] = elemen terakhir\narr[-2] = kedua dari belakang\n\nFitur ini TIDAK ada di C++.',
 4),

(E'Berapa nilai sizeof(arr) jika dideklarasikan sebagai int arr[5] dengan int berukuran 4 byte?',
 null, null, 'PG', 'MEMORI',
 E'5 elemen x 4 byte = 20 byte.\n\nOpsi 4 salah karena itu ukuran satu int. Opsi 5 salah karena itu jumlah elemen. Opsi 40 salah karena keliru mengira int berukuran 8 byte.',
 5),

(E'Apa rumus menghitung alamat elemen ke-i pada array?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: alamat(0) + i x sizeof(Tipe)\n\nKarena elemen array tersimpan berurutan dengan jarak tetap (sebesar ukuran tipe), alamat elemen ke-i bisa dihitung langsung.\n\nInilah alasan pengaksesan array O(1) - waktu konstan.',
 6),

(E'int arr[5] = {1, 2};\ncout << arr[4];\n\nApa outputnya?',
 E'int arr[5] = {1, 2};\\ncout << arr[4];', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 0\n\nKetika array diinisialisasi dengan nilai lebih sedikit dari ukurannya, sisanya otomatis diisi NOL.\n\narr[0]=1, arr[1]=2, arr[2]=0, arr[3]=0, arr[4]=0.\n\nIni BERBEDA dari variabel lokal tanpa inisialisasi yang berisi nilai sampah.',
 7),

(E'Apa yang terjadi jika menulis arr[3] = 100 pada array berukuran 3 di C++?',
 E'int arr[3];\narr[3] = 100;', 'cpp', 'ANALISIS', 'JEBAKAN',
 E'Undefined behavior.\n\nArray berukuran 3 punya indeks valid 0, 1, 2.\narr[3] berada DI LUAR BATAS.\n\nC++ TIDAK memeriksa batas indeks - program bisa tampak berjalan normal, mencetak nilai sampah, crash, atau merusak data lain tanpa terlihat.\n\nIni bukan error yang bisa ditangkap, melainkan perilaku yang tidak didefinisikan standar.',
 8),

(E'Apa yang terjadi jika mengakses indeks di luar batas di Python?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Python melempar IndexError dan program berhenti dengan pesan jelas.\n\nIni perbedaan penting dari C++ yang menghasilkan undefined behavior (bisa tampak berhasil).\n\nPengecoh "mengembalikan 0" salah - Python tidak mengisi nilai default.',
 9),

(E'Mengapa pengaksesan elemen array berkompleksitas O(1)?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena alamat elemen bisa dihitung langsung tanpa mencari.\n\nRumus alamat(i) = alamat(0) + i x sizeof(Tipe) memungkinkan komputer melompat langsung ke elemen mana pun.\n\nTidak seperti linked list yang harus menelusuri satu per satu (O(n)).',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'array-dasar';

-- OPSI SOAL (array-dasar)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'0', true, 1),
  (1, 'B', E'1', false, 2),
  (1, 'C', E'Tergantung bahasa', false, 3),
  (1, 'D', E'Tergantung tipe data', false, 4),
  (2, 'A', E'int arr[3] = {1, 2, 3};', true, 1),
  (2, 'B', E'int arr(3);', false, 2),
  (2, 'C', E'arr = [1, 2, 3];', false, 3),
  (2, 'D', E'array arr[3];', false, 4),
  (3, 'A', E'40', false, 1),
  (3, 'B', E'50', true, 2),
  (3, 'C', E'10', false, 3),
  (3, 'D', E'Error', false, 4),
  (4, 'A', E'10', false, 1),
  (4, 'B', E'50', true, 2),
  (4, 'C', E'IndexError', false, 3),
  (4, 'D', E'40', false, 4),
  (5, 'A', E'4', false, 1),
  (5, 'B', E'5', false, 2),
  (5, 'C', E'20', true, 3),
  (5, 'D', E'40', false, 4),
  (6, 'A', E'alamat(0) + i x sizeof(Tipe)', true, 1),
  (6, 'B', E'alamat(0) + i', false, 2),
  (6, 'C', E'alamat(0) + sizeof(Tipe)', false, 3),
  (6, 'D', E'alamat(i) = i x alamat(0)', false, 4),
  (7, 'A', E'0', true, 1),
  (7, 'B', E'Nilai sampah', false, 2),
  (7, 'C', E'Error kompilasi', false, 3),
  (7, 'D', E'2', false, 4),
  (8, 'A', E'Compiler menolak kode dan gagal build', false, 1),
  (8, 'B', E'Program otomatis berhenti dengan pesan error', false, 2),
  (8, 'C', E'Undefined behavior: bisa cetak nilai sampah, crash, atau tampak normal', true, 3),
  (8, 'D', E'Array otomatis diperbesar agar muat', false, 4),
  (9, 'A', E'Mengembalikan 0', false, 1),
  (9, 'B', E'Melempar IndexError dan program berhenti', true, 2),
  (9, 'C', E'Mengembalikan None', false, 3),
  (9, 'D', E'Memperbesar list otomatis', false, 4),
  (10, 'A', E'Karena alamat elemen bisa dihitung langsung tanpa mencari', true, 1),
  (10, 'B', E'Karena array selalu kecil', false, 2),
  (10, 'C', E'Karena compiler mengoptimalkan semua array', false, 3),
  (10, 'D', E'Karena array disimpan di cache CPU', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'array-dasar';

-- =========================================================
-- Modul 2: array-multidimensi (Array Multidimensi)
-- =========================================================
-- FLASHCARD (array-multidimensi)
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

-- SOAL (array-multidimensi)
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

-- OPSI SOAL (array-multidimensi)
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

-- =========================================================
-- Modul 3: array-dinamis (Array Dinamis: vector & list)
-- =========================================================
-- FLASHCARD (array-dinamis)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa itu std::vector?',
 E'Array dinamis dari pustaka standar C++.\n\nUkurannya bisa bertambah saat program berjalan,\nberbeda dari array biasa yang ukurannya tetap.',
 'ISTILAH', null, null, 1),

(E'Bagaimana cara membuat vector kosong dan vector dengan 5 elemen bernilai 7?',
 E'vector<int> kosong;         // kosong\nvector<int> v(5, 7);      // 5 elemen, semua 7\nvector<int> w = {1,2,3};  // dengan nilai awal',
 'SINTAKS', E'vector<int> kosong;\\nvector<int> v(5, 7);', 'cpp', 2),

(E'Apa perbedaan size dan capacity pada vector?',
 E'size     = jumlah elemen yang BENAR-BENAR ada\ncapacity = jumlah elemen yang BISA ditampung\n           sebelum perlu alokasi ulang\n\nAnaloginya lemari:\nsize = 3 baju tergantung\ncapacity = lemari muat 8 baju',
 'ISTILAH', null, null, 3),

(E'Apa perbedaan v[i] dan v.at(i)?',
 E'v[i]    : TIDAK memeriksa batas (undefined behavior)\nv.at(i) : MEMERIKSA batas, melempar std::out_of_range\n\nPakai .at() kalau indeks berasal dari input pengguna.\nPakai [ ] kalau yakin indeksnya valid (lebih cepat).',
 'BANDING', null, null, 4),

(E'Apa yang terjadi saat vector perlu tumbuh (push_back ketika penuh)?',
 E'1. Alokasikan blok memori BARU yang lebih besar\n2. SALIN semua elemen lama ke blok baru\n3. BEBASKAN blok lama\n4. Tambahkan elemen baru\n\nAkibat penting: ALAMAT elemen berubah!',
 'MEMORI', null, null, 5),

(E'vector<int> v;\nfor (int i = 1; i <= 10; i++) {\n    v.push_back(i);\n    cout << v.size() << " " << v.capacity() << "\\n";\n}\n\nBagaimana pola outputnya (GCC)?',
 E'size bertambah 1 setiap kali:\n1, 2, 3, 4, 5, 6, 7, 8, 9, 10\n\ncapacity BERLIPAT: 1, 2, 4, 8, 16\n\ncapacity naik hanya saat size mencapai batasnya.',
 'TRACING', E'vector<int> v;\\nfor (int i = 1; i <= 10; i++) {\\n    v.push_back(i);\\n    cout << v.size() << " " << v.capacity() << "\\\\n";\\n}', 'cpp', 6),

(E'Mengapa kapasitas vector berlipat (2x) dan bukan bertambah 1?',
 E'Karena menambah 1 per 1 akan sangat lambat:\nsetiap push_back butuh alokasi ulang -> O(n) per operasi\n\nDengan berlipat, alokasi ulang semakin jarang\nseiring data bertambah -> O(1) rata-rata.\n\nCATATAN: angka 2x adalah implementation-defined.\nGCC memakai 2x, implementasi lain bisa 1,5x.',
 'MEMORI', null, null, 7),

(E'Mengapa lst.insert(0, x) itu mahal?',
 E'Karena harus MENGGESER semua elemen satu posisi ke kanan.\nKompleksitasnya O(n), bukan O(1).\n\nPengukuran nyata (5.000 iterasi):\nappend ke belakang : 0.8 ms\ninsert ke depan    : 155.1 ms\n\n198x lebih lambat!\n\nAlternatif: pakai collections.deque dengan appendleft().',
 'MEMORI', null, null, 8),

(E'a = [1, 2, 3]\nb = a\nb.append(4)\nprint(a)\n\nApa outputnya?',
 E'[1, 2, 3, 4]\n\nb = a TIDAK membuat salinan!\nKeduanya menunjuk objek list yang SAMA.\n\nUntuk menyalin: pakai a.copy(), a[:], atau list(a).',
 'JEBAKAN', E'a = [1, 2, 3]\\nb = a\\nb.append(4)\\nprint(a)', 'python', 9),

(E'Kapan sebaiknya pakai vector dan kapan pakai array?',
 E'Pakai VECTOR bila:\n- ukuran tidak diketahui saat kompilasi\n- butuh menambah/mengurangi elemen\n- butuh .size() dan keamanan\n\nPakai ARRAY (C atau std::array) bila:\n- ukuran tetap dan diketahui\n- butuh performa maksimal\n- berinteraksi dengan API gaya C\n\nDefault C++ modern: std::vector.',
 'KAPAN', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'array-dinamis';

-- SOAL (array-dinamis)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Apa perbedaan size dan capacity pada vector?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: size = jumlah elemen yang ada; capacity = jumlah yang bisa ditampung sebelum alokasi ulang.\n\nAnaloginya lemari: size adalah jumlah baju tergantung, capacity adalah berapa baju yang muat.\n\nPengecoh "size lebih besar dari capacity" salah - capacity selalu >= size.',
 1),

(E'vector<int> v = {1,2,3,4};\nv.push_back(5);\ncout << v.size();\n\nApa outputnya?',
 E'vector<int> v = {1,2,3,4};\\nv.push_back(5);\\ncout << v.size();', 'cpp', 'TRACE', 'TRACING',
 E'Output: 5\n\nVector awalnya berisi 4 elemen.\nSetelah push_back(5), jumlah elemen menjadi 5.\n\nPengecoh 4 = size sebelum push_back.',
 2),

(E'Apa yang terjadi saat vector perlu tumbuh?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Alokasi blok baru, salin elemen lama, bebaskan blok lama, tambah elemen baru.\n\nProses ini menyebabkan ALAMAT elemen berubah - itulah mengapa pointer ke elemen bisa menjadi dangling setelah push_back.\n\nPengecoh "memori lama otomatis diperbesar" salah - memori yang sudah dialokasikan tidak bisa diperbesar di tempat.',
 3),

(E'Apa kegunaan v.reserve(n)?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Mengalokasikan ruang untuk n elemen sehingga tidak perlu alokasi ulang sampai elemen ke-n+1.\n\nSetelah reserve(10), size tetap 0 tapi capacity menjadi 10.\n\nPengecoh "mengisi vector dengan n elemen" salah - itu yang dilakukan vector<int> v(n).',
 4),

(E'vector<int> v;\nv.reserve(10);\ncout << v.size() << " " << v.capacity();\n\nApa outputnya?',
 E'vector<int> v;\\nv.reserve(10);\\ncout << v.size() << " " << v.capacity();', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 0 10\n\nreserve() menyiapkan RUANG, bukan mengisi elemen.\nsize tetap 0 karena belum ada elemen.\ncapacity menjadi 10 karena ruang sudah dialokasikan.\n\nIni membedakan reserve() dari vector<int> v(10) yang langsung mengisi 10 elemen.',
 5),

(E'Apa perbedaan v[i] dan v.at(i)?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: v[i] tidak memeriksa batas (undefined behavior); v.at(i) memeriksa dan melempar std::out_of_range.\n\nKeduanya mengakses elemen yang sama jika indeks valid. Perbedaannya hanya pada pemeriksaan batas.\n\nv.at() sedikit lebih lambat karena ada pemeriksaan, tapi lebih aman.',
 6),

(E'Mengapa kapasitas vector berlipat (2x) dan bukan bertambah 1 setiap kali?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Agar alokasi ulang semakin jarang, sehingga push_back tetap O(1) rata-rata.\n\nJika kapasitas bertambah 1 setiap kali, setiap push_back akan memicu alokasi ulang + penyalinan seluruh elemen, sehingga O(n) per operasi. Untuk n elemen, totalnya O(n kuadrat) - sangat lambat.\n\nDengan berlipat, total waktu menjadi O(n).',
 7),

(E'Mengapa lst.insert(0, x) jauh lebih lambat dari lst.append(x)?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: insert(0, x) harus menggeser SEMUA elemen satu posisi, kompleksitasnya O(n). append hanya menambah di akhir, O(1).\n\nPengukuran nyata 5.000 iterasi: append 0.8 ms, insert 155.1 ms - 198x lebih lambat.\n\nAlternatif: collections.deque dengan appendleft() yang O(1).',
 8),

(E'a = [1, 2, 3]\nb = a\nb.append(4)\nprint(len(a))\n\nApa outputnya?',
 E'a = [1, 2, 3]\\nb = a\\nb.append(4)\\nprint(len(a))', 'python', 'TRACE', 'JEBAKAN',
 E'Output: 4\n\nb = a TIDAK membuat salinan - keduanya menunjuk objek list yang SAMA.\n\nSetelah b.append(4), list yang ditunjuk a dan b sama-sama berisi [1,2,3,4].\n\nUntuk menyalin dengan benar: a.copy(), a[:], atau list(a).',
 9),

(E'Kapan sebaiknya memakai std::vector daripada array?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: Saat ukuran tidak diketahui saat kompilasi atau butuh menambah/mengurangi elemen.\n\nvector unggul untuk:\n- data yang jumlahnya baru diketahui saat program berjalan\n- data yang perlu tumbuh/berkurang\n- kasus yang butuh .size() dan keamanan\n\nArray lebih tepat saat ukuran tetap dan butuh performa maksimal.\n\nDefault C++ modern: std::vector.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'array-dinamis';

-- OPSI SOAL (array-dinamis)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'size = jumlah elemen yang ada; capacity = jumlah yang bisa ditampung sebelum alokasi ulang', true, 1),
  (1, 'B', E'size selalu lebih besar dari capacity', false, 2),
  (1, 'C', E'size dan capacity selalu sama', false, 3),
  (1, 'D', E'capacity = jumlah elemen; size = ruang tersedia', false, 4),
  (2, 'A', E'4', false, 1),
  (2, 'B', E'5', true, 2),
  (2, 'C', E'8', false, 3),
  (2, 'D', E'1', false, 4),
  (3, 'A', E'Alokasi blok baru, salin elemen lama, bebaskan blok lama', true, 1),
  (3, 'B', E'Memori lama otomatis diperbesar di tempat', false, 2),
  (3, 'C', E'Elemen baru disimpan di lokasi terpisah', false, 3),
  (3, 'D', E'Vector membuat vector baru dan menghapus yang lama', false, 4),
  (4, 'A', E'Mengalokasikan ruang untuk n elemen sehingga tidak perlu alokasi ulang', true, 1),
  (4, 'B', E'Mengisi vector dengan n elemen bernilai nol', false, 2),
  (4, 'C', E'Membatasi vector agar maksimal n elemen', false, 3),
  (4, 'D', E'Menghapus semua elemen lalu menambah n elemen baru', false, 4),
  (5, 'A', E'0 10', true, 1),
  (5, 'B', E'10 10', false, 2),
  (5, 'C', E'0 0', false, 3),
  (5, 'D', E'10 0', false, 4),
  (6, 'A', E'v[i] tidak memeriksa batas; v.at(i) memeriksa dan melempar exception', true, 1),
  (6, 'B', E'v[i] untuk baca, v.at(i) untuk tulis', false, 2),
  (6, 'C', E'v.at(i) lebih cepat karena dioptimalkan compiler', false, 3),
  (6, 'D', E'Tidak ada perbedaan sama sekali', false, 4),
  (7, 'A', E'Agar alokasi ulang semakin jarang sehingga push_back tetap O(1) rata-rata', true, 1),
  (7, 'B', E'Karena memori komputer selalu berlipat dua', false, 2),
  (7, 'C', E'Karena standar C++ mewajibkan kapasitas 2x', false, 3),
  (7, 'D', E'Agar vector tidak bisa diakses dari luar', false, 4),
  (8, 'A', E'insert(0, x) harus menggeser semua elemen (O(n)); append hanya menambah di akhir (O(1))', true, 1),
  (8, 'B', E'insert menggunakan lebih banyak memori', false, 2),
  (8, 'C', E'append dioptimalkan oleh compiler Python', false, 3),
  (8, 'D', E'insert memerlukan konversi tipe data', false, 4),
  (9, 'A', E'3', false, 1),
  (9, 'B', E'4', true, 2),
  (9, 'C', E'1', false, 3),
  (9, 'D', E'Error', false, 4),
  (10, 'A', E'Saat ukuran tidak diketahui saat kompilasi atau butuh menambah/mengurangi elemen', true, 1),
  (10, 'B', E'Saat butuh performa maksimal dan ukuran tetap', false, 2),
  (10, 'C', E'Saat berinteraksi dengan API gaya C', false, 3),
  (10, 'D', E'Saat butuh array dengan indeks mulai dari 1', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'array-dinamis';

-- =========================================================
-- Modul 4: struct-dasar (Mendefinisikan Struct)
-- =========================================================
-- FLASHCARD (struct-dasar)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa itu struct?',
 E'Cara mengelompokkan beberapa data yang saling terkait\nmenjadi SATU kesatuan, walaupun tipenya berbeda.\n\nstruct Mahasiswa {\n    string nama;\n    int umur;\n};',
 'ISTILAH', null, null, 1),

(E'Bagaimana sintaks mendefinisikan struct di C++?',
 E'struct NamaStruct {\n    tipe anggota1;\n    tipe anggota2;\n};   <- JANGAN lupa titik koma!\n\nTitik koma setelah } adalah kesalahan paling umum.',
 'SINTAKS', E'struct Titik {\\n    int x;\\n    int y;\\n};', 'cpp', 2),

(E'Bagaimana cara menginisialisasi struct dengan nilai?',
 E'Tiga cara:\n\nTitik a = {3, 7};              // daftar berurutan\nTitik b = {.x = 3, .y = 7};    // dengan nama (C++20)\n\nTitik c;\nc.x = 3; c.y = 7;              // satu per satu',
 'SINTAKS', E'Titik t = {3, 7};', 'cpp', 3),

(E'Bagaimana cara mengakses anggota struct?',
 E'Pakai OPERATOR TITIK ( . ):\n\nTitik t = {3, 7};\ncout << t.x;   // 3\nt.x = 10;      // ubah nilai\n\nint jumlah = t.x + t.y;   // 17',
 'SINTAKS', E'Titik t = {3, 7};\\ncout << t.x;', 'cpp', 4),

(E'Apa yang salah dari kode ini?\\nstruct Titik { int x; int y; }\\nint main() { ... }',
 E'KURANG TITIK KOMA setelah kurung kurawal penutup.\n\nBenar:\nstruct Titik { int x; int y; };   <- titik koma\n\nPesan error-nya sering menunjuk ke baris berikutnya,\nbukan ke tempat kesalahannya.',
 'JEBAKAN', E'struct Titik { int x; int y; }  // kurang titik koma!\\nint main() { }', 'cpp', 5),

(E'struct Titik { int x; int y; };\nvoid geser(Titik t) { t.x = t.x + 10; }\n\nint main() {\n    Titik a = {3, 7};\n    geser(a);\n    cout << a.x;\n}\n\nApa outputnya?',
 E'Output: 3\n\nStruct dikirim sebagai SALINAN.\nMengubah t di dalam fungsi TIDAK mempengaruhi a.\n\nAgar bisa mengubah aslinya, parameter harus referensi:\nvoid geser(Titik& t)',
 'TRACING', E'void geser(Titik t) { t.x = t.x + 10; }\\nTitik a = {3, 7};\\ngeser(a);\\ncout << a.x;  // 3', 'cpp', 6),

(E'Apa perbedaan struct dan class di C++?',
 E'Perbedaan UTAMA: akses default.\n\nstruct : anggota default PUBLIC\nclass  : anggota default PRIVATE\n\nKonvensi:\n- struct untuk wadah data sederhana\n- class untuk objek dengan perilaku',
 'BANDING', null, null, 7),

(E'Apa padanan struct di Python?',
 E'DATACLASS:\n\nfrom dataclasses import dataclass\n\n@dataclass\nclass Titik:\n    x: int\n    y: int\n\nt = Titik(3, 7)',
 'SINTAKS', E'from dataclasses import dataclass\\n\\n@dataclass\\nclass Titik:\\n    x: int\\n    y: int', 'python', 8),

(E'Bagaimana cara membuat dataclass yang tidak bisa diubah?',
 E'Pakai frozen=True:\n\n@dataclass(frozen=True)\nclass Titik:\n    x: int\n    y: int\n\nt = Titik(3, 7)\nt.x = 10   # ERROR: cannot assign to field\n\nTanpa frozen, dataclass mutable secara default.',
 'SINTAKS', E'@dataclass(frozen=True)\\nclass Titik:\\n    x: int\\n    y: int', 'python', 9),

(E'Kapan sebaiknya memakai struct?',
 E'Pakai struct kalau data-data ini SELALU muncul bersama:\n\n- Titik 2D        -> struct Titik { int x; int y; }\n- Data mahasiswa  -> nama, umur, ipk\n- Barang di toko  -> nama, harga\n- Tanggal         -> hari, bulan, tahun\n\nStruct adalah langkah dari "variabel lepas" menuju MODEL DATA.',
 'KAPAN', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'struct-dasar';

-- SOAL (struct-dasar)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Bagaimana sintaks yang BENAR untuk mendefinisikan struct di C++?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: struct Titik { int x; int y; };\n\nTitik koma setelah } WAJIB ada.\n\nstruct Titik { int x; int y; } tanpa titik koma adalah kesalahan paling umum - pesan error-nya menunjuk ke baris berikutnya sehingga membingungkan.',
 1),

(E'struct Titik { int x; int y; };\nTitik t = {5};\ncout << t.x << " " << t.y;\n\nApa outputnya?',
 E'struct Titik { int x; int y; };\\nTitik t = {5};\\ncout << t.x << " " << t.y;', 'cpp', 'TRACE', 'TRACING',
 E'Output: 5 0\n\nInisialisasi sebagian: hanya x yang diisi 5.\nAnggota yang tidak diinisialisasi OTOMATIS diisi NOL.\n\nSama seperti array: int arr[5] = {1} -> sisanya 0.\n\nPengecoh "5 5" salah - nilai tidak diulang.',
 2),

(E'struct Titik { int x; int y; };\nvoid geser(Titik t) { t.x = t.x + 10; }\n\nTitik a = {3, 7};\ngeser(a);\ncout << a.x;\n\nApa outputnya?',
 E'struct Titik { int x; int y; };\\nvoid geser(Titik t) { t.x = t.x + 10; }\\n\\nTitik a = {3, 7};\\ngeser(a);\\ncout << a.x;', 'cpp', 'TRACE', 'TRACING',
 E'Output: 3\n\nStruct dikirim sebagai SALINAN.\nMengubah t di dalam fungsi tidak mempengaruhi a.\n\nAgar bisa mengubah aslinya, parameter harus referensi: void geser(Titik& t)\n\nIni konsep penting: nilai vs referensi.',
 3),

(E'Apa perbedaan utama struct dan class di C++?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: struct default-nya public, class default-nya private.\n\nSelain itu keduanya hampir identik - bisa punya method, konstruktor, dan inheritance.\n\nKonvensi umum: struct untuk wadah data sederhana, class untuk objek dengan perilaku dan enkapsulasi.',
 4),

(E'Apa padanan struct di Python?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: dataclass dengan dekorator @dataclass\n\nfrom dataclasses import dataclass\n\n@dataclass\nclass Titik:\n    x: int\n    y: int\n\nPengecoh namedtuple juga bisa menyimpan data, tapi tidak bisa diubah (immutable) dan kurang fleksibel untuk kasus umum.',
 5),

(E'Apa yang OTOMATIS dibuat oleh dekorator @dataclass?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: __init__, __repr__, dan __eq__\n\n@dataclass\nclass Titik:\n    x: int\n    y: int\n\nt = Titik(3, 7)           # __init__\nprint(t)                  # __repr__: Titik(x=3, y=7)\nt == Titik(3, 7)          # __eq__: True\n\nTanpa @dataclass, ketiganya harus ditulis manual.',
 6),

(E'Bagaimana cara membuat dataclass yang tidak bisa diubah setelah dibuat?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: @dataclass(frozen=True)\n\n@dataclass(frozen=True)\nclass Titik:\n    x: int\n    y: int\n\nt = Titik(3, 7)\nt.x = 10   # ERROR: cannot assign to field\n\nTanpa frozen, dataclass mutable secara default - field bisa diubah kapan saja.',
 7),

(E'Apa yang terjadi jika field berdefault diletakkan sebelum field tanpa default di dataclass?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Python melempar TypeError: non-default argument follows default argument\n\nSALAH:\n@dataclass\nclass M:\n    umur: int = 18\n    nama: str        # ERROR\n\nBENAR: field tanpa default harus lebih dulu.\n\nIni aturan Python untuk semua fungsi, bukan hanya dataclass.',
 8),

(E'Kapan sebaiknya struct dikirim ke fungsi dengan const reference?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: Saat fungsi hanya membaca dan struct-nya besar.\n\nvoid cetak(const Titik& t)\n\nconst mencegah fungsi mengubah data, & mencegah penyalinan.\n\nIni pola paling umum dan direkomendasikan untuk struct besar.\n\nKirim sebagai nilai hanya kalau struct kecil DAN perlu diubah tanpa mempengaruhi aslinya.',
 9),

(E'struct Titik { int x; int y; };\nTitik a = {3, 7};\nTitik b = a;\nb.x = 99;\ncout << a.x;\n\nApa outputnya?',
 E'struct Titik { int x; int y; };\\nTitik a = {3, 7};\\nTitik b = a;\\nb.x = 99;\\ncout << a.x;', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 3\n\nb = a membuat SALINAN, bukan referensi.\nMengubah b.x tidak mempengaruhi a.x.\n\nIni berbeda dari Python list: b = a pada list Python membuat REFERENSI, sehingga mengubah b ikut mengubah a.\n\nStruct C++ menyalin nilai; list Python menyalin referensi.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'struct-dasar';

-- OPSI SOAL (struct-dasar)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'struct Titik { int x; int y; };', true, 1),
  (1, 'B', E'struct Titik { int x; int y; }', false, 2),
  (1, 'C', E'struct Titik ( int x; int y; );', false, 3),
  (1, 'D', E'def struct Titik { int x; int y; };', false, 4),
  (2, 'A', E'5 0', true, 1),
  (2, 'B', E'5 5', false, 2),
  (2, 'C', E'0 5', false, 3),
  (2, 'D', E'Error', false, 4),
  (3, 'A', E'3', true, 1),
  (3, 'B', E'13', false, 2),
  (3, 'C', E'10', false, 3),
  (3, 'D', E'Error', false, 4),
  (4, 'A', E'struct default-nya public, class default-nya private', true, 1),
  (4, 'B', E'struct tidak bisa punya method', false, 2),
  (4, 'C', E'class tidak bisa punya konstruktor', false, 3),
  (4, 'D', E'struct hanya bisa menyimpan tipe primitif', false, 4),
  (5, 'A', E'dataclass dengan dekorator @dataclass', true, 1),
  (5, 'B', E'list bersarang', false, 2),
  (5, 'C', E'dictionary', false, 3),
  (5, 'D', E'tuple', false, 4),
  (6, 'A', E'__init__, __repr__, dan __eq__', true, 1),
  (6, 'B', E'Hanya __init__', false, 2),
  (6, 'C', E'__str__ dan __len__', false, 3),
  (6, 'D', E'Tidak ada yang otomatis', false, 4),
  (7, 'A', E'@dataclass(frozen=True)', true, 1),
  (7, 'B', E'@dataclass(immutable=True)', false, 2),
  (7, 'C', E'@dataclass(const=True)', false, 3),
  (7, 'D', E'Tidak bisa dibuat tidak bisa diubah', false, 4),
  (8, 'A', E'TypeError: non-default argument follows default argument', true, 1),
  (8, 'B', E'Field berdefault akan ditimpa', false, 2),
  (8, 'C', E'Python akan mengurutkan otomatis', false, 3),
  (8, 'D', E'Tidak terjadi apa-apa', false, 4),
  (9, 'A', E'Saat fungsi hanya membaca dan struct-nya besar', true, 1),
  (9, 'B', E'Saat fungsi perlu mengubah data aslinya', false, 2),
  (9, 'C', E'Saat struct hanya punya satu anggota', false, 3),
  (9, 'D', E'Saat struct berisi array', false, 4),
  (10, 'A', E'3', true, 1),
  (10, 'B', E'99', false, 2),
  (10, 'C', E'7', false, 3),
  (10, 'D', E'Error', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'struct-dasar';

-- =========================================================
-- Modul 5: struct-nested (Nested Struct & Array of Struct)
-- =========================================================
-- FLASHCARD (struct-nested)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa itu nested struct?',
 E'Struct yang salah satu anggotanya bertipe struct lain.\n\nstruct Alamat { string kota; };\nstruct Mahasiswa {\n    string nama;\n    Alamat alamat;   <- struct sebagai anggota\n};',
 'ISTILAH', null, null, 1),

(E'Bagaimana cara menginisialisasi nested struct?',
 E'Mahasiswa m = {"Rani", 20, {"Bandung", "40123"}};\n\nPerhatikan kurung kurawal BERSARANG:\n{"Bandung", "40123"} adalah nilai untuk alamat.',
 'SINTAKS', E'Mahasiswa m = {"Rani", 20, {"Bandung", "40123"}};', 'cpp', 2),

(E'Bagaimana cara mengakses anggota nested struct?',
 E'Pakai DUA TITIK - satu untuk setiap level:\n\nm.alamat.kota\n\nCara membaca: m punya alamat, dan alamat punya kota.\n\nURUTAN PENTING: dari luar ke dalam.',
 'SINTAKS', E'cout << m.alamat.kota;', 'cpp', 3),

(E'Bagaimana cara mendeklarasikan array of struct?',
 E'Barang daftar[3] = {\n    {"Buku", 25000},\n    {"Pulpen", 3000},\n    {"Tas", 150000}\n};\n\nSetiap elemen adalah struct lengkap.',
 'SINTAKS', E'Barang daftar[3] = {{"Buku", 25000}, {"Pulpen", 3000}};', 'cpp', 4),

(E'Bagaimana cara mengiterasi array of struct?',
 E'for (int i = 0; i < 3; i++) {\n    cout << daftar[i].nama;\n    cout << daftar[i].harga;\n}\n\nAkses anggota tiap elemen dengan operator titik.',
 'SINTAKS', E'for (int i = 0; i < 3; i++) {\\n    cout << daftar[i].nama;\\n}', 'cpp', 5),

(E'Bagaimana cara mengurutkan array of struct berdasarkan satu field?',
 E'Pakai std::sort dengan lambda pembanding:\n\nsort(kelas, kelas + 3, [](const Kelas& a, const Kelas& b) {\n    return a.ipk > b.ipk;   // menurun\n});\n\nUbah > jadi < untuk menaik.',
 'SINTAKS', E'sort(kelas, kelas + 3, [](const Kelas& a, const Kelas& b) {\\n    return a.ipk > b.ipk;\\n});', 'cpp', 6),

(E'Apa perbedaan array of struct dan struct of array?',
 E'Array of Struct (AoS):\nstruct Mhs { string nama; double ipk; };\nMhs daftar[100];\n-> satu objek utuh, data berdekatan\n\nStruct of Array (SoA):\nstruct Daftar { string nama[100]; double ipk[100]; };\n-> satu field untuk semua objek\n\nAoS lebih mudah dibaca - direkomendasikan.',
 'BANDING', null, null, 7),

(E'Bagaimana cara mengurutkan list of dataclass di Python?',
 E'Pakai sorted() dengan key:\n\nterurut = sorted(kelas, key=lambda k: k.ipk, reverse=True)\n\nreverse=True untuk urutan menurun.\nTanpa reverse, urutan menaik (default).',
 'SINTAKS', E'terurut = sorted(kelas, key=lambda k: k.ipk, reverse=True)', 'python', 8),

(E'Apa yang salah dari inisialisasi ini?\\nMahasiswa m = {"Rani", "Bandung"};',
 E'Kurung kurawal BERSARANG tidak dipakai untuk alamat.\n\nSALAH: {"Rani", "Bandung"}\nBENAR: {"Rani", {"Bandung"}}\n\nKarena alamat adalah struct, nilainya harus dibungkus kurung kurawal sendiri.',
 'JEBAKAN', E'Mahasiswa m = {"Rani", "Bandung"};  // SALAH', 'cpp', 9),

(E'Kapan sebaiknya memakai struct bersarang?',
 E'Kalau ada data yang SELALU muncul bersama sebagai satu kesatuan.\n\nContoh:\n- Mahasiswa punya Alamat\n- Barang punya Dimensi\n- Pesanan punya Pengiriman\n\nKalau data itu bisa berdiri sendiri, jadikan struct terpisah\ndan simpan sebagai dua field, bukan bersarang.',
 'KAPAN', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'struct-nested';

-- SOAL (struct-nested)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Bagaimana cara mengakses kota dari struct Mahasiswa yang punya anggota Alamat?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: m.alamat.kota\n\nAkses mengikuti struktur dari LUAR ke DALAM:\nm (struct Mahasiswa) -> .alamat (struct Alamat) -> .kota (string).\n\nm.kota.alamat salah karena m tidak punya anggota kota langsung.',
 1),

(E'struct Alamat { string kota; };\nstruct Mahasiswa { string nama; Alamat alamat; };\n\nMahasiswa m = {"Rani", {"Bandung"}};\ncout << m.alamat.kota;',
 E'Mahasiswa m = {"Rani", {"Bandung"}};\\ncout << m.alamat.kota;', 'cpp', 'TRACE', 'TRACING',
 E'Output: Bandung\n\nm.alamat.kota mengakses string kota di dalam struct Alamat, yang merupakan anggota dari Mahasiswa.\n\n"Rani" adalah nama, "Bandung" adalah kota.',
 2),

(E'Bagaimana cara mendeklarasikan array 3 barang dengan nilai awal?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Barang daftar[3] = {{"Buku",25000},{"Pulpen",3000},{"Tas",150000}};\n\nSetiap elemen dibungkus kurung kurawal sendiri.\n\nBarang daftar[3] = {"Buku", 25000, "Pulpen", 3000} salah - compiler tidak tahu mana batas tiap elemen.',
 3),

(E'Bagaimana cara mengurutkan array of struct berdasarkan field ipk menurun?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: sort(kelas, kelas + 3, [](const Kelas& a, const Kelas& b) { return a.ipk > b.ipk; });\n\nLambda pembanding menerima dua elemen dan mengembalikan true jika a harus datang sebelum b.\n\nTanda > untuk menurun, < untuk menaik.\n\nPerlu #include <algorithm>.',
 4),

(E'Apa perbedaan array of struct dan struct of array?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Array of struct menyimpan satu objek utuh per elemen; struct of array menyimpan satu field untuk semua objek.\n\nAoS: struct Mhs { string nama; double ipk; }; Mhs daftar[100];\n-> daftar[0] berisi nama DAN ipk mahasiswa pertama\n\nSoA: struct Daftar { string nama[100]; double ipk[100]; };\n-> semua nama dalam satu array, semua ipk dalam array lain\n\nAoS lebih mudah dibaca dan direkomendasikan untuk kebanyakan kasus.',
 5),

(E'struct Barang { string nama; double harga; };\nBarang daftar[3] = {{"Buku",25000},{"Pulpen",3000},{"Tas",150000}};\n\nint n = sizeof(daftar) / sizeof(daftar[0]);\ncout << n;',
 E'int n = sizeof(daftar) / sizeof(daftar[0]);\\ncout << n;', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 3\n\nsizeof(daftar) adalah ukuran SELURUH array.\nsizeof(daftar[0]) adalah ukuran SATU elemen.\nPembagiannya menghasilkan jumlah elemen = 3.\n\nPENTING: ini hanya bekerja kalau array masih di scope yang sama. Kalau dikirim ke fungsi, array decay jadi pointer dan informasi ukuran hilang.',
 6),

(E'Apa yang salah dari Mahasiswa m = {"Rani", "Bandung"};?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Nilai untuk alamat harus dibungkus kurung kurawal sendiri.\n\nSALAH: {"Rani", "Bandung"}\nBENAR: {"Rani", {"Bandung"}}\n\nKarena alamat adalah struct, nilainya harus berupa daftar tersendiri.\n\nCompiler akan memberi error karena tidak bisa mengonversi "Bandung" menjadi struct Alamat.',
 7),

(E'Bagaimana cara mengiterasi array of struct dan menjumlahkan field harganya?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: double total = 0; for (int i = 0; i < 3; i++) { total += daftar[i].harga; }\n\nSetiap elemen diakses dengan indeks, lalu field-nya dengan titik.\n\ndaftar.harga salah karena daftar adalah array, bukan struct tunggal.\n\nHasil untuk data contoh: 25000 + 3000 + 150000 = 178000.',
 8),

(E'Bagaimana cara mengurutkan list of dataclass berdasarkan field ipk menurun?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: sorted(kelas, key=lambda k: k.ipk, reverse=True)\n\nkey menentukan field yang dipakai untuk mengurutkan.\nreverse=True membuat urutan menurun.\n\nkelas.sort(key=...) juga bisa tapi mengubah list asli (in-place).\n\nC++ memakai std::sort dengan lambda pembanding - konsepnya mirip.',
 9),

(E'Apa perbedaan cara menyalin struct bersarang C++ dan objek Python?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: C++ menyalin seluruh nilai; Python hanya menyalin referensi.\n\nC++: Mahasiswa b = a; -> salinan lengkap, termasuk struct di dalamnya. Mengubah b tidak mempengaruhi a.\n\nPython: b = a; -> hanya referensi ke objek yang sama. Mengubah b IKUT mengubah a. Untuk salinan sebenarnya perlu copy.deepcopy(a).\n\nIni perbedaan mendasar antara bahasa dengan nilai dan bahasa dengan referensi.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'struct-nested';

-- OPSI SOAL (struct-nested)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'm.alamat.kota', true, 1),
  (1, 'B', E'm.kota.alamat', false, 2),
  (1, 'C', E'm.kota', false, 3),
  (1, 'D', E'm->alamat->kota', false, 4),
  (2, 'A', E'Bandung', true, 1),
  (2, 'B', E'Rani', false, 2),
  (2, 'C', E'Error', false, 3),
  (2, 'D', E'm.alamat.kota', false, 4),
  (3, 'A', E'Barang daftar[3] = {{"Buku",25000},{"Pulpen",3000},{"Tas",150000}};', true, 1),
  (3, 'B', E'Barang daftar[3] = {"Buku",25000,"Pulpen",3000,"Tas",150000};', false, 2),
  (3, 'C', E'Barang daftar[] = {"Buku"};', false, 3),
  (3, 'D', E'Barang daftar(3) = {{"Buku",25000}};', false, 4),
  (4, 'A', E'sort(kelas, kelas+3, [](const Kelas& a, const Kelas& b) { return a.ipk > b.ipk; });', true, 1),
  (4, 'B', E'sort(kelas.ipk);', false, 2),
  (4, 'C', E'sort(kelas, kelas+3);', false, 3),
  (4, 'D', E'kelas.sort(ipk);', false, 4),
  (5, 'A', E'AoS menyimpan satu objek utuh per elemen; SoA menyimpan satu field untuk semua objek', true, 1),
  (5, 'B', E'AoS lebih hemat memori dari SoA', false, 2),
  (5, 'C', E'SoA tidak bisa diurutkan', false, 3),
  (5, 'D', E'AoS hanya bisa menyimpan tipe primitif', false, 4),
  (6, 'A', E'3', true, 1),
  (6, 'B', E'Ukuran satu elemen dalam byte', false, 2),
  (6, 'C', E'1', false, 3),
  (6, 'D', E'Error kompilasi', false, 4),
  (7, 'A', E'Nilai untuk alamat harus dibungkus kurung kurawal sendiri: {"Rani", {"Bandung"}}', true, 1),
  (7, 'B', E'Struct tidak boleh punya anggota bertipe struct', false, 2),
  (7, 'C', E'Perlu menambahkan titik koma di akhir', false, 3),
  (7, 'D', E'Nama mahasiswa harus diletakkan setelah alamat', false, 4),
  (8, 'A', E'double total = 0; for (int i = 0; i < 3; i++) { total += daftar[i].harga; }', true, 1),
  (8, 'B', E'double total = daftar.harga;', false, 2),
  (8, 'C', E'double total = sum(daftar);', false, 3),
  (8, 'D', E'double total = daftar[0].harga + daftar.harga;', false, 4),
  (9, 'A', E'sorted(kelas, key=lambda k: k.ipk, reverse=True)', true, 1),
  (9, 'B', E'sort(kelas, ipk, menurun)', false, 2),
  (9, 'C', E'kelas.urutkan("ipk")', false, 3),
  (9, 'D', E'sorted(kelas, ipk, True)', false, 4),
  (10, 'A', E'C++ menyalin seluruh nilai; Python hanya menyalin referensi', true, 1),
  (10, 'B', E'C++ dan Python sama-sama menyalin referensi', false, 2),
  (10, 'C', E'Python menyalin nilai; C++ menyalin referensi', false, 3),
  (10, 'D', E'Keduanya tidak bisa menyalin struct bersarang', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'struct-nested';

-- =========================================================
-- Modul 6: struct-memori (Padding, Alignment & sizeof)
-- =========================================================
-- FLASHCARD (struct-memori)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Berapa sizeof(struct { char a; int b; }) jika sizeof(int)=4?',
 E'8 byte, bukan 5.\n\n1 (char) + 3 (padding) + 4 (int) = 8\n\nPadding 3 byte muncul agar int b dimulai\npada offset yang merupakan kelipatan 4.',
 'MEMORI', E'struct Campur { char a; int b; };\\ncout << sizeof(Campur);  // 8', 'cpp', 1),

(E'Apa itu padding pada struct?',
 E'Byte KOSONG yang disisipkan compiler di antara anggota struct\nagar setiap anggota dimulai pada alamat yang sesuai alignment-nya.\n\nPadding TIDAK berisi data apa pun - isinya nilai tak tentu.',
 'ISTILAH', null, null, 2),

(E'Bagaimana cara memeriksa offset anggota struct?',
 E'Pakai offsetof dari <cstddef>:\n\n#include <cstddef>\n\nstruct Campur { char a; int b; };\n\ncout << offsetof(Campur, a);   // 0\ncout << offsetof(Campur, b);   // 4',
 'SINTAKS', E'#include <cstddef>\\ncout << offsetof(Campur, b);  // 4', 'cpp', 3),

(E'Apa aturan alignment untuk anggota struct?',
 E'Setiap anggota harus dimulai pada alamat yang merupakan\nKELIPATAN alignment-nya.\n\nAlignment biasanya sama dengan ukuran tipe:\nchar=1, short=2, int=4, long=8, pointer=8\n\nSelain itu, total ukuran struct dibulatkan ke kelipatan\nalignment TERBESAR di antara anggotanya.',
 'MEMORI', null, null, 4),

(E'Berapa sizeof(struct { char a; long b; char c; })?',
 E'24 byte.\n\nOffset: a=0, b=8 (butuh kelipatan 8), c=16\nTotal sebelum pembulatan: 17\nAlignment terbesar: 8\nDibulatkan ke kelipatan 8 -> 24\n\nRincian: 1 + 7 pad + 8 + 1 + 7 pad akhir = 24',
 'MEMORI', E'struct B { char a; long b; char c; };\\ncout << sizeof(B);  // 24', 'cpp', 5),

(E'Apakah mengurutkan anggota struct SELALU mengurangi padding?',
 E'TIDAK.\n\n{char a; int b;} = 8 byte\n{int b; char a;} = 8 byte\n\nSAMA! Pengurutan tidak membantu pada struct 2 anggota.\n\nPengurutan baru membantu kalau ada BEBERAPA anggota kecil\nyang bisa dikemas berdampingan.',
 'JEBAKAN', null, null, 6),

(E'Apa risiko memakai #pragma pack(1)?',
 E'1. LEBIH LAMBAT - CPU harus membaca beberapa blok dan menggabungkan\n2. TIDAK PORTABEL - perilaku berbeda antar compiler\n3. BAHAYA DI ARM - akses tidak selaras bisa menyebabkan crash\n\nGunakan hanya kalau benar-benar perlu,\nmisalnya untuk protokol jaringan atau format biner tertentu.',
 'JEBAKAN', null, null, 7),

(E'Mengapa struct TIDAK boleh dibandingkan dengan memcmp?',
 E'Karena padding berisi nilai TAK TENTU.\n\nmemcmp membandingkan SELURUH byte termasuk padding.\nDua struct dengan data identik bisa dianggap BERBEDA\nkalau padding-nya berbeda.\n\nBandingkan anggota satu per satu, atau pakai\noperator== default (C++20).',
 'JEBAKAN', null, null, 8),

(E'Bagaimana cara membandingkan dua struct dengan benar?',
 E'Bandingkan anggota satu per satu:\n\nbool sama(const Titik& a, const Titik& b) {\n    return a.x == b.x && a.y == b.y;\n}\n\nAtau di C++20, pakai operator== default:\n\nstruct Titik {\n    int x, y;\n    bool operator==(const Titik&) const = default;\n};',
 'SINTAKS', E'struct Titik {\\n    int x, y;\\n    bool operator==(const Titik&) const = default;\\n};', 'cpp', 9),

(E'Apakah alignment struct sama di semua platform?',
 E'TIDAK - alignment bersifat IMPLEMENTATION-DEFINED.\n\nAngka seperti sizeof(int)=4, sizeof(long)=8 berlaku untuk\nx86-64. Di platform lain (ARM, embedded) bisa BERBEDA.\n\nSelalu verifikasi dengan sizeof dan offsetof\ndi platform yang kamu pakai.',
 'MEMORI', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'struct-memori';

-- SOAL (struct-memori)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Berapa sizeof(struct { char a; int b; }) jika sizeof(int) = 4?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: 8 byte\n\n1 (char) + 3 (padding) + 4 (int) = 8.\n\nPengecoh 5 = menjumlahkan tanpa memperhitungkan padding.\nPengecoh 4 = hanya ukuran int. Pengecoh 12 = salah hitung alignment.',
 1),

(E'Mengapa padding diperlukan dalam struct?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Agar setiap anggota dimulai pada alamat yang selaras, sehingga CPU bisa membacanya dalam satu operasi.\n\nCPU membaca memori dalam blok (4 atau 8 byte), bukan byte demi byte. Kalau int diletakkan pada offset tidak selaras, CPU perlu dua operasi baca dan menggabungkannya - jauh lebih lambat.\n\nPengecoh "untuk menghemat memori" salah - padding justru MEMBUANG memori demi kecepatan.',
 2),

(E'struct Campur { char a; int b; };\ncout << offsetof(Campur, b);\n\nBerapa outputnya jika sizeof(int)=4?',
 E'struct Campur { char a; int b; };\\ncout << offsetof(Campur, b);', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 4\n\nb harus dimulai pada offset yang merupakan kelipatan 4 (alignment int).\nSetelah char a di offset 0, offset berikutnya adalah 1.\nDibulatkan ke kelipatan 4 -> 4.\n\nTiga byte di offset 1-3 adalah padding.',
 3),

(E'Berapa sizeof(struct { char a; long b; char c; })?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: 24 byte\n\nOffset: a=0, b=8 (butuh kelipatan 8), c=16.\nTotal sebelum pembulatan: 17.\nAlignment terbesar = 8, dibulatkan ke 24.\n\nRincian: 1 + 7 padding + 8 + 1 + 7 padding akhir = 24.\n\nPengecoh 10 = 1+8+1 tanpa padding. Pengecoh 16 = lupa padding setelah c.',
 4),

(E'struct A { char a; long b; char c; };\nstruct B { long b; char a; char c; };\n\ncout << sizeof(A) << " " << sizeof(B);\n\nApa outputnya?',
 E'struct A { char a; long b; char c; };\\nstruct B { long b; char a; char c; };\\ncout << sizeof(A) << " " << sizeof(B);', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 24 16\n\nA: a=0, b=8, c=16 -> total 17 dibulatkan ke 24\nB: b=0, a=8, c=9  -> total 10 dibulatkan ke 16\n\nB menghemat 8 byte karena anggota kecil (a dan c) dikelompokkan berdampingan.\n\nIni contoh pengurutan yang BERHASIL menghemat.',
 5),

(E'Apa aturan yang lebih akurat tentang mengurangi padding?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Padding berkurang ketika anggota kecil dikelompokkan berdampingan sehingga muat dalam satu blok alignment.\n\nIni BIASANYA tercapai dengan mengurutkan dari besar ke kecil, tetapi BUKAN JAMINAN.\n\nPada struct dengan hanya 2 anggota, pengurutan sering tidak mengubah apa pun karena tidak ada anggota kecil yang bisa dikemas bersama.',
 6),

(E'Apa yang dilakukan #pragma pack(1)?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Memaksa compiler mengurangi atau menghilangkan padding.\n\n#pragma pack(push, 1)\nstruct Padat { char a; int b; };\n#pragma pack(pop)\n\nDengan pack(1), sizeof(Padat) menjadi 5 byte (bukan 8).\n\nTapi ada konsekuensi serius: lebih lambat, tidak portabel, dan bisa crash di ARM.',
 7),

(E'Apa risiko memakai #pragma pack(1)?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Lebih lambat, tidak portabel, dan bisa crash di ARM.\n\n1. LEBIH LAMBAT - CPU harus membaca beberapa blok dan menggabungkan\n2. TIDAK PORTABEL - perilaku berbeda antar compiler\n3. BAHAYA DI ARM - akses tidak selaras bisa menyebabkan crash\n\nGunakan hanya kalau benar-benar perlu (protokol jaringan, format biner tertentu).',
 8),

(E'Mengapa struct TIDAK boleh dibandingkan dengan memcmp?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena padding berisi nilai tak tentu, sehingga dua struct dengan data identik bisa dianggap berbeda.\n\nmemcmp membandingkan SELURUH byte termasuk padding. Standar C++ tidak menentukan isi padding - bisa nilai nol, sisa data lama, atau apa pun.\n\nBandingkan anggota satu per satu, atau pakai operator== default (C++20).',
 9),

(E'Apa bahaya menulis struct langsung ke berkas?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Byte padding yang isinya tak tentu ikut tertulis, sehingga data bisa kacau saat dibaca di platform lain.\n\nberkas.write((char*)&x, sizeof(Campur));\n\nYang tertulis termasuk padding. Kalau dibaca di platform dengan aturan alignment berbeda, layout-nya tidak cocok.\n\nSolusi: gunakan JSON, Protocol Buffers, atau tulis setiap anggota satu per satu.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'struct-memori';

-- OPSI SOAL (struct-memori)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'5', false, 1),
  (1, 'B', E'8', true, 2),
  (1, 'C', E'4', false, 3),
  (1, 'D', E'12', false, 4),
  (2, 'A', E'Agar setiap anggota dimulai pada alamat selaras sehingga CPU bisa membacanya dalam satu operasi', true, 1),
  (2, 'B', E'Untuk menghemat penggunaan memori', false, 2),
  (2, 'C', E'Untuk memudahkan compiler membaca kode', false, 3),
  (2, 'D', E'Untuk mencegah akses tidak sah', false, 4),
  (3, 'A', E'1', false, 1),
  (3, 'B', E'4', true, 2),
  (3, 'C', E'5', false, 3),
  (3, 'D', E'8', false, 4),
  (4, 'A', E'10', false, 1),
  (4, 'B', E'16', false, 2),
  (4, 'C', E'24', true, 3),
  (4, 'D', E'32', false, 4),
  (5, 'A', E'24 16', true, 1),
  (5, 'B', E'16 24', false, 2),
  (5, 'C', E'24 24', false, 3),
  (5, 'D', E'10 10', false, 4),
  (6, 'A', E'Padding berkurang ketika anggota kecil dikelompokkan berdampingan, biasanya tercapai dengan mengurutkan', true, 1),
  (6, 'B', E'Padding selalu berkurang dengan mengurutkan dari besar ke kecil', false, 2),
  (6, 'C', E'Padding tidak bisa dikurangi dengan cara apa pun', false, 3),
  (6, 'D', E'Padding berkurang dengan menambah anggota', false, 4),
  (7, 'A', E'Memaksa compiler mengurangi atau menghilangkan padding', true, 1),
  (7, 'B', E'Mengurutkan anggota secara otomatis', false, 2),
  (7, 'C', E'Menambah padding agar alignment lebih baik', false, 3),
  (7, 'D', E'Mengubah tipe anggota agar seragam', false, 4),
  (8, 'A', E'Lebih lambat, tidak portabel, dan bisa crash di ARM', true, 1),
  (8, 'B', E'Struct tidak bisa dikompilasi', false, 2),
  (8, 'C', E'Anggota struct tidak bisa diakses', false, 3),
  (8, 'D', E'Struct tidak bisa disalin', false, 4),
  (9, 'A', E'Padding berisi nilai tak tentu, sehingga struct dengan data sama bisa dianggap berbeda', true, 1),
  (9, 'B', E'memcmp tidak mendukung struct', false, 2),
  (9, 'C', E'memcmp terlalu lambat untuk struct besar', false, 3),
  (9, 'D', E'memcmp hanya bisa membandingkan tipe primitif', false, 4),
  (10, 'A', E'Byte padding yang isinya tak tentu ikut tertulis, data bisa kacau di platform lain', true, 1),
  (10, 'B', E'Struct tidak bisa ditulis ke berkas', false, 2),
  (10, 'C', E'Berkas menjadi terlalu besar', false, 3),
  (10, 'D', E'Program akan crash saat menulis', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'struct-memori';

-- =========================================================
-- Modul 7: pointer-dasar (Dasar Pointer & Alamat Memori)
-- =========================================================
-- FLASHCARD (pointer-dasar)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa itu pointer?',
 E'Variabel yang menyimpan ALAMAT memori,\nbukan nilai langsung.\n\nint nilai = 42;\nint* p = &nilai;   // p menyimpan alamat nilai',
 'ISTILAH', null, null, 1),

(E'Bagaimana cara mendeklarasikan pointer ke int?',
 E'int* p;\n\nCara membaca: "p adalah pointer ke int".\nBaca dari KANAN ke KIRI.',
 'SINTAKS', E'int* p;', 'cpp', 2),

(E'Bagaimana cara mengambil alamat sebuah variabel?',
 E'Pakai operator & (address-of):\n\nint nilai = 42;\ncout << &nilai;   // 0x7ffd...\n\n& adalah kebalikan dari * (dereferensi).',
 'SINTAKS', E'int nilai = 42;\\nint* p = &nilai;', 'cpp', 3),

(E'Apa yang salah dari int* a, b;?',
 E'HANYA a yang pointer. b adalah int BIASA.\n\nBukti:\nsizeof(a) = 8 (pointer)\nsizeof(b) = 4 (int)\n\nTanda * hanya berlaku untuk variabel PERTAMA.\n\nBenar: int* a; int* b;',
 'JEBAKAN', E'int* a, b;   // HANYA a yang pointer!', 'cpp', 4),

(E'Apa dua arti tanda bintang pada pointer?',
 E'1. Di DEKLARASI = bagian dari TIPE\n   int* p;\n\n2. Di EKSPRESI = operator DEREFERENSI\n   *p = 100;\n\nIni yang sering membingungkan pemula.',
 'ISTILAH', null, null, 5),

(E'Apa yang terjadi jika mendereferensi nullptr?',
 E'UNDEFINED BEHAVIOR - biasanya crash,\ntetapi standar tidak menjamin itu.\n\nint* p = nullptr;\ncout << *p;   // UB!\n\nSelalu periksa: if (p) { cout << *p; }',
 'JEBAKAN', null, null, 6),

(E'Mengapa pointer harus selalu diinisialisasi?',
 E'Pointer yang tidak diinisialisasi berisi ALAMAT ACAK\n(wild pointer).\n\nint* p;        // BAHAYA - alamat acak\ncout << *p;    // UB!\n\nKalau belum tahu mau menunjuk ke mana:\nint* p = nullptr;',
 'JEBAKAN', null, null, 7),

(E'Apa perbedaan const int* p dan int* const p?',
 E'const int* p  : nilai tidak bisa diubah, alamat BOLEH\nint* const p  : alamat tidak bisa diubah, nilai BOLEH\nconst int* const p : keduanya tidak bisa diubah\n\nCara ingat: baca dari kanan ke kiri.\nconst yang paling dekat dengan p mengunci p.',
 'BANDING', null, null, 8),

(E'Apa yang terjadi jika mengakses nilai variabel lokal yang sudah keluar scope lewat pointer?',
 E'UNDEFINED BEHAVIOR.\n\nint* f() {\n    int lokal = 42;\n    return &lokal;   // BAHAYA!\n}\n\nSetelah f() selesai, lokal sudah tidak ada.\nPointer yang dikembalikan adalah DANGLING POINTER.\n\nMemakainya = UB.',
 'JEBAKAN', E'int* f() {\\n    int lokal = 42;\\n    return &lokal;  // UB!\\n}', 'cpp', 9),

(E'int nilai = 42;\nint* p = &nilai;\n*p = 100;\ncout << nilai;',
 E'Output: 100\n\n*p = 100 mengubah nilai di alamat yang ditunjuk p.\nKarena p menunjuk ke nilai, maka nilai ikut berubah.\n\nIni kekuatan pointer: mengubah variabel lain\ntanpa menyentuh namanya.',
 'TRACING', E'int nilai = 42;\\nint* p = &nilai;\\n*p = 100;\\ncout << nilai;', 'cpp', 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'pointer-dasar';

-- SOAL (pointer-dasar)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Apa yang disimpan oleh pointer?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Alamat memori, bukan nilai langsung.\n\nint nilai = 42;\nint* p = &nilai;   // p menyimpan ALAMAT nilai\n\nPengecoh "nilai variabel" salah - itu isi, bukan alamat.\nPengecoh "salinan variabel" salah - pointer tidak menyalin.',
 1),

(E'Apa yang salah dari deklarasi int* a, b;?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Hanya a yang pointer; b adalah int biasa.\n\nBukti: sizeof(a) = 8 (pointer), sizeof(b) = 4 (int).\n\nTanda * hanya berlaku untuk variabel PERTAMA dalam deklarasi.\n\nCara benar: int* a; int* b; atau int *a, *b;',
 2),

(E'int nilai = 42;\nint* p = &nilai;\n*p = 100;\ncout << nilai;',
 E'int nilai = 42;\\nint* p = &nilai;\\n*p = 100;\\ncout << nilai;', 'cpp', 'TRACE', 'TRACING',
 E'Output: 100\n\n*p = 100 mengubah nilai di ALAMAT yang ditunjuk p.\nKarena p menunjuk ke nilai, maka nilai ikut berubah.\n\nIni kekuatan pointer: mengubah variabel lain tanpa menyentuh namanya.\n\nPengecoh 42 = nilai sebelum diubah.',
 3),

(E'Apa dua arti tanda bintang pada pointer?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Di deklarasi ia bagian dari TIPE; di ekspresi ia operator DEREFERENSI.\n\nint* p = &nilai;   // * bagian dari tipe\n*p = 100;          // * operator dereferensi\n\nIni yang sering membingungkan pemula karena simbolnya sama tetapi maknanya berbeda.',
 4),

(E'Apa yang terjadi jika mendereferensi nullptr?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Undefined behavior - biasanya crash, tetapi standar tidak menjamin itu.\n\nint* p = nullptr;\ncout << *p;   // UB!\n\nPengecoh "selalu crash" kurang tepat - standar hanya bilang UB, jadi bisa saja tampak berjalan.\nPengecoh "mengembalikan 0" salah - tidak ada nilai yang dikembalikan.',
 5),

(E'Mengapa pointer yang tidak diinisialisasi berbahaya?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena berisi alamat acak (wild pointer), dan mendereferensinya adalah undefined behavior.\n\nint* p;        // berisi alamat acak\ncout << *p;    // UB!\n\nSelalu inisialisasi: int* p = nullptr;',
 6),

(E'Apa perbedaan const int* p dan int* const p?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: const int* p mengunci NILAI; int* const p mengunci ALAMAT.\n\nconst int* p  : nilai tidak bisa diubah, alamat boleh\nint* const p  : alamat tidak bisa diubah, nilai boleh\n\nCara ingat: baca dari kanan ke kiri. const yang paling dekat dengan p mengunci p.',
 7),

(E'Mengapa mengembalikan pointer ke variabel lokal berbahaya?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena variabel lokal sudah tidak ada setelah fungsi selesai, sehingga pointer menjadi dangling dan memakainya adalah UB.\n\nint* f() {\n    int lokal = 42;\n    return &lokal;   // BAHAYA!\n}\n\nSetelah f() selesai, memori lokal sudah dibebaskan.',
 8),

(E'Bagaimana pointer bisa mengubah variabel dari dalam fungsi?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Dengan mengirim alamat variabel, lalu fungsi mendereferensinya.\n\nvoid ubah(int* q) { *q = 777; }\nint y = 1;\nubah(&y);   // y jadi 777\n\nKalau dikirim nilai biasa, perubahan tidak mempengaruhi aslinya:\nvoid ubahSalah(int q) { q = 888; }   // y tidak berubah',
 9),

(E'Apa perbedaan utama pointer C++ dan referensi Python?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: C++ bisa aritmetika pointer dan manajemen memori manual; Python tidak bisa aritmetika dan memori dikelola otomatis.\n\nC++: p + 1 (aritmetika), delete (manual), alamat terlihat\nPython: tidak bisa aritmetika, garbage collector otomatis, id() untuk identitas\n\nKeduanya sama-sama menunjuk objek, tetapi tingkat kontrolnya berbeda jauh.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'pointer-dasar';

-- OPSI SOAL (pointer-dasar)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'Alamat memori, bukan nilai langsung', true, 1),
  (1, 'B', E'Nilai variabel', false, 2),
  (1, 'C', E'Salinan variabel', false, 3),
  (1, 'D', E'Nama variabel', false, 4),
  (2, 'A', E'Hanya a yang pointer; b adalah int biasa', true, 1),
  (2, 'B', E'a dan b keduanya pointer', false, 2),
  (2, 'C', E'Keduanya bukan pointer', false, 3),
  (2, 'D', E'Deklarasi tidak valid dan gagal kompilasi', false, 4),
  (3, 'A', E'100', true, 1),
  (3, 'B', E'42', false, 2),
  (3, 'C', E'0', false, 3),
  (3, 'D', E'Error', false, 4),
  (4, 'A', E'Di deklarasi bagian dari tipe; di ekspresi operator dereferensi', true, 1),
  (4, 'B', E'Selalu berarti perkalian', false, 2),
  (4, 'C', E'Selalu berarti dereferensi', false, 3),
  (4, 'D', E'Tidak ada arti khusus', false, 4),
  (5, 'A', E'Undefined behavior - biasanya crash, tetapi standar tidak menjamin itu', true, 1),
  (5, 'B', E'Selalu crash', false, 2),
  (5, 'C', E'Mengembalikan nilai 0', false, 3),
  (5, 'D', E'Melempar exception', false, 4),
  (6, 'A', E'Karena berisi alamat acak (wild pointer), dan mendereferensinya adalah UB', true, 1),
  (6, 'B', E'Karena pointer tidak bisa dibandingkan', false, 2),
  (6, 'C', E'Karena pointer memakan lebih banyak memori', false, 3),
  (6, 'D', E'Karena compiler menolak pointer tanpa nilai', false, 4),
  (7, 'A', E'const int* p mengunci NILAI; int* const p mengunci ALAMAT', true, 1),
  (7, 'B', E'Keduanya sama saja', false, 2),
  (7, 'C', E'const int* p mengunci alamat; int* const p mengunci nilai', false, 3),
  (7, 'D', E'Keduanya mengunci nilai dan alamat', false, 4),
  (8, 'A', E'Variabel lokal sudah tidak ada setelah fungsi selesai, pointer menjadi dangling, dan memakainya UB', true, 1),
  (8, 'B', E'Compiler menolak mengembalikan pointer', false, 2),
  (8, 'C', E'Pointer otomatis menjadi nullptr', false, 3),
  (8, 'D', E'Nilai variabel lokal ikut dikembalikan', false, 4),
  (9, 'A', E'Dengan mengirim alamat variabel, lalu fungsi mendereferensinya', true, 1),
  (9, 'B', E'Dengan mengirim variabel sebagai nilai', false, 2),
  (9, 'C', E'Dengan mendeklarasikan variabel sebagai global', false, 3),
  (9, 'D', E'Dengan mengembalikan nilai dari fungsi', false, 4),
  (10, 'A', E'C++ bisa aritmetika pointer dan manajemen memori manual; Python tidak bisa aritmetika dan memori otomatis', true, 1),
  (10, 'B', E'C++ dan Python sama-sama punya aritmetika pointer', false, 2),
  (10, 'C', E'Python punya aritmetika pointer, C++ tidak', false, 3),
  (10, 'D', E'Keduanya tidak bisa menunjuk objek', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'pointer-dasar';

-- =========================================================
-- Modul 8: pointer-array (Pointer & Array: Aritmetika Pointer)
-- =========================================================
-- FLASHCARD (pointer-array)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa itu array-to-pointer decay?',
 E'Perubahan otomatis nama array menjadi pointer ke elemen\npertamanya dalam ekspresi tertentu.\n\nint arr[5];\nint* p = arr;   // arr decay jadi &arr[0]\n\nAkibatnya informasi ukuran bisa hilang.',
 'ISTILAH', null, null, 1),

(E'int arr[5];\ncout << (arr == &arr[0]);',
 E'Output: 1 (true)\n\nNama array dan alamat elemen pertamanya\nmenghasilkan alamat yang SAMA.\n\nIni bukti decay: arr berubah jadi pointer ke arr[0].',
 'TRACING', E'int arr[5];\\ncout << (arr == &arr[0]);  // 1', 'cpp', 2),

(E'Apa perbedaan arr dan &arr?',
 E'Keduanya alamat SAMA, tapi TIPE berbeda:\n\narr  : int*        -> +1 melompat 4 byte (satu elemen)\n&arr : int(*)[5]   -> +1 melompat 20 byte (SELURUH array)\n\nBukti terukur:\n(char*)(arr+1)-(char*)arr    = 4\n(char*)(&arr+1)-(char*)&arr  = 20',
 'BANDING', null, null, 3),

(E'Apa yang terjadi pada sizeof(arr) di dalam fungsi?',
 E'Menghasilkan ukuran POINTER (8 byte), bukan ukuran array.\n\nvoid f(int arr[]) {\n    sizeof(arr);   // 8, bukan 20!\n}\n\nPenyebab: parameter int arr[] sebenarnya adalah int* arr.\nInformasi ukuran HILANG.',
 'JEBAKAN', E'void f(int arr[]) {\\n    sizeof(arr);  // 8, bukan ukuran array\\n}', 'cpp', 4),

(E'Berapa byte yang ditambah p + 1 jika p adalah int*?',
 E'4 byte (= sizeof(int)).\n\nAritmetika pointer mengikuti SKALA TIPE,\nbukan 1 byte.\n\nchar*   -> +1 byte\ndouble* -> +8 byte\nint*    -> +4 byte',
 'MEMORI', null, null, 5),

(E'int arr[5] = {10, 20, 30, 40, 50};\nint* awal = &arr[0];\nint* akhir = &arr[4];\ncout << (akhir - awal);',
 E'Output: 4\n\nSelisih dua pointer menghasilkan JUMLAH ELEMEN,\nbukan byte.\n\n(akhir - awal) = 4 elemen, bukan 16 byte.',
 'TRACING', E'int arr[5] = {10, 20, 30, 40, 50};\\ncout << (&arr[4] - &arr[0]);  // 4', 'cpp', 6),

(E'Apakah arr[i] sama dengan *(arr + i)?',
 E'YA, keduanya IDENTIK.\n\narr[i] DIDEfinisikan sebagai *(arr + i).\n\nint arr[5] = {10,20,30,40,50};\narr[3]     = 40\n*(arr + 3) = 40\n\nIni bukan kebetulan - ini definisi bahasanya.',
 'MEMORI', null, null, 7),

(E'Mengapa i[arr] juga valid?',
 E'Karena arr[i] diterjemahkan jadi *(arr + i),\ndan penjumlahan bersifat KOMUTATIF:\n\n*(arr + i) == *(i + arr)\n\nJadi 3[arr] juga valid dan bernilai sama dengan arr[3].\n\nTETAPI jangan dipakai - membingungkan pembaca.',
 'JEBAKAN', E'int arr[5] = {10,20,30,40,50};\\ncout << 3[arr];  // 40 - valid tapi jangan dipakai', 'cpp', 8),

(E'Apa keuntungan std::span dibanding int arr[] sebagai parameter?',
 E'std::span menyimpan POINTER dan UKURAN sekaligus.\n\nvoid f(std::span<int> arr) {\n    cout << arr.size();   // ukuran tersimpan!\n    for (int x : arr) cout << x;\n}\n\nMasalah decay teratasi: ukuran tidak hilang,\ndan tetap fleksibel untuk array berbagai ukuran.',
 'KAPAN', E'void f(std::span<int> arr) {\\n    cout << arr.size();\\n}', 'cpp', 9),

(E'Apa perbedaan slice Python dan pointer C++?',
 E'Slice Python MENYALIN:\n  s = arr[1:4]   -> salinan baru\n  s[0] = 999     -> arr TIDAK berubah\n\nPointer C++ TIDAK menyalin:\n  int* p = &arr[1];\n  p[0] = 999;    -> arr[1] IKUT berubah\n\nIni perbedaan mendasar: nilai vs referensi.',
 'BANDING', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'pointer-array';

-- SOAL (pointer-array)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Apa itu array-to-pointer decay?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Perubahan otomatis nama array menjadi pointer ke elemen pertamanya.\n\nint arr[5];\nint* p = arr;   // arr decay jadi &arr[0]\n\nTerjadi saat dikirim ke fungsi, di-assign ke pointer, atau dalam aritmetika.\nTIDAK terjadi pada sizeof(arr) dan &arr.',
 1),

(E'int arr[5];\ncout << (arr == &arr[0]);',
 E'int arr[5];\\ncout << (arr == &arr[0]);', 'cpp', 'TRACE', 'TRACING',
 E'Output: 1\n\nNama array dan alamat elemen pertamanya menghasilkan alamat yang SAMA.\nIni bukti decay: arr berubah jadi pointer ke arr[0].\n\nPengecoh 0 salah - keduanya memang alamat yang sama.',
 2),

(E'Apa perbedaan arr dan &arr?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Tipenya berbeda, sehingga aritmetikanya berbeda.\n\narr  : int*       -> +1 melompat 4 byte (satu elemen)\n&arr : int(*)[5]  -> +1 melompat 20 byte (SELURUH array)\n\nKeduanya menghasilkan ALAMAT yang sama, tetapi tipe dan perilaku +1 berbeda.\n\nIni detail yang sering ditanyakan di wawancara kerja.',
 3),

(E'Berapa nilai sizeof(arr) di dalam fungsi void f(int arr[])?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: 8 byte - ukuran pointer, bukan ukuran array.\n\nParameter int arr[] sebenarnya adalah int* arr. Compiler menerjemahkannya, sehingga informasi ukuran array HILANG.\n\nPengecoh "20 byte" salah - itu ukuran array di main, bukan di fungsi.',
 4),

(E'Mengapa aritmetika pointer mengikuti skala tipe, bukan 1 byte?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena tujuan p + 1 adalah menunjuk elemen berikutnya, bukan byte berikutnya.\n\nKalau int* menambah 1 byte, ia akan menunjuk ke tengah-tengah int - tidak berguna. Dengan skala tipe, p + 1 selalu tepat di elemen berikutnya.\n\nchar* +1 = 1 byte, int* +1 = 4 byte, double* +1 = 8 byte.',
 5),

(E'int arr[5] = {10, 20, 30, 40, 50};\ncout << (&arr[4] - &arr[0]);',
 E'int arr[5] = {10, 20, 30, 40, 50};\\ncout << (&arr[4] - &arr[0]);', 'cpp', 'TRACE', 'TRACING',
 E'Output: 4\n\nSelisih dua pointer menghasilkan JUMLAH ELEMEN, bukan byte.\n\n(&arr[4] - &arr[0]) = 4 elemen, bukan 16 byte.\n\nPengecoh 16 = menghitung byte (4 elemen x 4 byte).',
 6),

(E'Apakah arr[i] sama dengan *(arr + i)?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Ya, keduanya identik.\n\narr[i] DIDEFINISIKAN sebagai *(arr + i). Ini bukan kebetulan atau optimasi compiler - ini definisi bahasanya.\n\nKonsekuensinya: array tidak menyimpan informasi batas, sehingga C++ tidak bisa mendeteksi akses di luar batas.',
 7),

(E'Mengapa i[arr] juga valid?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena arr[i] diterjemahkan jadi *(arr + i), dan penjumlahan bersifat komutatif.\n\n*(arr + i) == *(i + arr)\n\nJadi 3[arr] valid dan bernilai sama dengan arr[3].\n\nTETAPI jangan dipakai - membingungkan pembaca dan tidak ada gunanya. Ini hanya fakta bahasa yang menarik.',
 8),

(E'Apa keuntungan utama std::span dibanding int arr[] sebagai parameter?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: std::span menyimpan pointer DAN ukuran sekaligus.\n\nvoid f(std::span<int> arr) {\n    cout << arr.size();   // ukuran tersimpan\n}\n\nMasalah decay teratasi: ukuran tidak hilang, dan tetap fleksibel untuk array berbagai ukuran.\n\nint (&arr)[5] juga menyimpan ukuran, tetapi ukurannya harus diketahui saat kompilasi.',
 9),

(E'arr = [10, 20, 30, 40, 50]\ns = arr[1:4]\ns[0] = 999\nprint(arr[1])',
 E'arr = [10, 20, 30, 40, 50]\\ns = arr[1:4]\\ns[0] = 999\\nprint(arr[1])', 'python', 'TRACE', 'BANDING',
 E'Output: 20\n\nSlicing Python MENYALIN elemen. Mengubah s[0] tidak mengubah arr[1].\n\nBandingkan C++:\nint* p = &arr[1];\np[0] = 999;   // arr[1] IKUT berubah\n\nPengecoh 999 salah - itu mengira slice menunjuk ke elemen asli.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'pointer-array';

-- OPSI SOAL (pointer-array)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'Perubahan otomatis nama array menjadi pointer ke elemen pertamanya', true, 1),
  (1, 'B', E'Penghapusan array yang tidak terpakai', false, 2),
  (1, 'C', E'Konversi array menjadi list', false, 3),
  (1, 'D', E'Pembesaran array otomatis', false, 4),
  (2, 'A', E'1', true, 1),
  (2, 'B', E'0', false, 2),
  (2, 'C', E'Error', false, 3),
  (2, 'D', E'Bergantung compiler', false, 4),
  (3, 'A', E'arr bertipe int* (+1 = 4 byte); &arr bertipe int(*)[5] (+1 = 20 byte)', true, 1),
  (3, 'B', E'Keduanya bertipe sama dan berperilaku sama', false, 2),
  (3, 'C', E'arr adalah nilai, &arr adalah alamat', false, 3),
  (3, 'D', E'&arr tidak valid untuk array', false, 4),
  (4, 'A', E'8 byte - ukuran pointer, karena parameter sebenarnya adalah int*', true, 1),
  (4, 'B', E'20 byte - sama seperti di main', false, 2),
  (4, 'C', E'4 byte - ukuran satu int', false, 3),
  (4, 'D', E'Error kompilasi', false, 4),
  (5, 'A', E'Karena tujuan p + 1 adalah menunjuk elemen berikutnya, bukan byte berikutnya', true, 1),
  (5, 'B', E'Karena compiler mengoptimalkan aritmetika', false, 2),
  (5, 'C', E'Karena pointer menyimpan tipe data', false, 3),
  (5, 'D', E'Karena memori komputer berbasis blok', false, 4),
  (6, 'A', E'4', true, 1),
  (6, 'B', E'16', false, 2),
  (6, 'C', E'1', false, 3),
  (6, 'D', E'Error', false, 4),
  (7, 'A', E'Ya, arr[i] didefinisikan sebagai *(arr + i)', true, 1),
  (7, 'B', E'Tidak, keduanya berbeda', false, 2),
  (7, 'C', E'Ya, tetapi hanya untuk array char', false, 3),
  (7, 'D', E'Ya, tetapi hanya di C++20 ke atas', false, 4),
  (8, 'A', E'Karena arr[i] menjadi *(arr + i) dan penjumlahan bersifat komutatif', true, 1),
  (8, 'B', E'Karena compiler memperbaiki urutan otomatis', false, 2),
  (8, 'C', E'Karena i[arr] adalah sintaks khusus', false, 3),
  (8, 'D', E'i[arr] sebenarnya tidak valid', false, 4),
  (9, 'A', E'std::span menyimpan pointer DAN ukuran sekaligus', true, 1),
  (9, 'B', E'std::span lebih cepat diakses', false, 2),
  (9, 'C', E'std::span menyalin array', false, 3),
  (9, 'D', E'std::span hanya untuk array char', false, 4),
  (10, 'A', E'20', true, 1),
  (10, 'B', E'999', false, 2),
  (10, 'C', E'30', false, 3),
  (10, 'D', E'Error', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'pointer-array';

-- =========================================================
-- Modul 9: pointer-struct (Pointer ke Struct & Arrow Operator)
-- =========================================================
-- FLASHCARD (pointer-struct)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Bagaimana cara mendeklarasikan pointer ke struct?',
 E'struct Titik { int x; int y; };\n\nTitik t = {3, 7};\nTitik* pt = &t;   // pointer ke struct',
 'SINTAKS', E'Titik t = {3, 7};\\nTitik* pt = &t;', 'cpp', 1),

(E'Apa dua cara mengakses anggota struct lewat pointer?',
 E'1. (*pt).x   - dereferensi dulu, lalu akses anggota\n2. pt->x     - cara SINGKAT (arrow operator)\n\nKeduanya SETARA dan menghasilkan nilai yang sama.',
 'SINTAKS', E'(*pt).x    // cara panjang\\npt->x      // cara singkat', 'cpp', 2),

(E'Mengapa operator -> diperlukan?',
 E'Karena (*pt).x merepotkan ditulis dan mudah salah.\n\nTanda kurung WAJIB karena operator . lebih tinggi\nprioritasnya daripada *.\n\nTanpa kurung:\n*pt.x  SALAH - dibaca sebagai *(pt.x)\n\nKarena itu C++ menyediakan -> sebagai singkatan.',
 'ISTILAH', null, null, 3),

(E'Apa perbedaan aturan pakai . dan ->?',
 E'. (titik)   : untuk NILAI atau REFERENSI\n-> (arrow)  : untuk POINTER\n\nTitik t = {3,7};\nt.x        // BENAR\nt->x       // SALAH\n\nTitik* pt = &t;\npt->x      // BENAR\npt.x       // SALAH',
 'BANDING', null, null, 4),

(E'Mengapa pointer penting untuk struct besar?',
 E'Karena MENGHINDARI penyalinan.\n\nstruct Besar { int data[1000]; };\nsizeof(Besar) = 4000 byte\n\nKirim sebagai nilai  -> salin 4000 byte setiap panggilan\nKirim sebagai pointer -> salin 8 byte saja\n\nSelisihnya 500x lebih hemat!',
 'MEMORI', null, null, 5),

(E'struct Mahasiswa { double ipk; };\n\nvoid ubahPointer(Mahasiswa* m) { m->ipk = 4.0; }\n\nMahasiswa m = {3.5};\nubahPointer(&m);\ncout << m.ipk;',
 E'Output: 4\n\nKirim sebagai POINTER = alamat dikirim.\nMengubah m->ipk mengubah struct ASLI.\n\nBandingkan dengan kirim nilai: hasilnya tetap 3.5.',
 'TRACING', E'void ubahPointer(Mahasiswa* m) { m->ipk = 4.0; }\\nMahasiswa m = {3.5};\\nubahPointer(&m);\\ncout << m.ipk;  // jadi 4', 'cpp', 6),

(E'Bagaimana cara mengakses array of struct lewat pointer?',
 E'Mahasiswa daftar[3];\nMahasiswa* p = daftar;\n\nEmpat bentuk SETARA:\n  daftar[i].nama\n  p[i].nama\n  (p + i)->nama\n  (*(p + i)).nama\n\nPaling jelas: p[i].nama',
 'SINTAKS', E'Mahasiswa* p = daftar;\\ncout << (p + i)->nama;\\ncout << p[i].nama;   // setara', 'cpp', 7),

(E'Mengapa perlu memeriksa pointer sebelum mengakses anggotanya?',
 E'Karena mengakses anggota lewat nullptr adalah UB.\n\nMahasiswa* p = nullptr;\np->nama;   // UB!\n\nSelalu periksa:\nif (p) { cout << p->nama; }\n\nTerutama penting kalau pointer berasal dari parameter fungsi.',
 'JEBAKAN', E'Mahasiswa* p = nullptr;\\nif (p) { cout << p->nama; }', 'cpp', 8),

(E'Bagaimana cara mengirim struct agar tidak disalin dan tidak bisa diubah?',
 E'Pakai const pointer:\n\nvoid cetak(const Mahasiswa* m) {\n    cout << m->nama;\n    // m->ipk = 4.0;   // ERROR\n}\n\nconst mencegah perubahan, pointer mencegah penyalinan.\nIni pola PALING UMUM di kode C++ profesional.',
 'KAPAN', E'void cetak(const Mahasiswa* m) {\\n    cout << m->nama;\\n}', 'cpp', 9),

(E'Apa perbedaan perilaku b = a pada struct C++ dan objek Python?',
 E'C++ : b = a menyalin NILAI. Mengubah b TIDAK\n      mempengaruhi a.\n\nPython: b = a menyalin REFERENSI. Mengubah b IKUT\n        mempengaruhi a.\n\nIni perbedaan MENDASAR:\n- C++ struct = tipe nilai\n- Python objek = tipe referensi',
 'BANDING', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'pointer-struct';

-- SOAL (pointer-struct)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Apa dua cara mengakses anggota struct lewat pointer?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: (*pt).x dan pt->x\n\nKeduanya setara dan menghasilkan nilai yang sama.\n\npt->x adalah cara singkat untuk (*pt).x. Tanda kurung pada cara panjang WAJIB ada karena operator . lebih tinggi prioritasnya daripada *.\n\npt.x salah - pt adalah pointer, bukan struct.',
 1),

(E'Mengapa operator -> diperlukan?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Karena (*pt).x merepotkan ditulis dan mudah salah.\n\nTanda kurung wajib ada karena operator . lebih tinggi prioritasnya daripada *. Tanpa kurung, *pt.x dibaca sebagai *(pt.x) yang error.\n\nKarena itu C++ menyediakan -> sebagai singkatan yang lebih jelas.',
 2),

(E'Apa aturan pakai operator . dan ->?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: . untuk nilai/referensi; -> untuk pointer.\n\nTitik t = {3,7};\nt.x        // BENAR (t adalah nilai)\nt->x       // SALAH\n\nTitik* pt = &t;\npt->x      // BENAR (pt adalah pointer)\npt.x       // SALAH',
 3),

(E'struct Titik { int x; int y; };\nTitik t = {3, 7};\nTitik* pt = &t;\npt->x = 99;\ncout << t.x;',
 E'struct Titik { int x; int y; };\\nTitik t = {3, 7};\\nTitik* pt = &t;\\npt->x = 99;\\ncout << t.x;', 'cpp', 'TRACE', 'TRACING',
 E'Output: 99\n\npt menunjuk ke t yang ASLI.\nMengubah pt->x sama dengan mengubah t.x.\n\nPengecoh 3 = nilai awal sebelum diubah.',
 4),

(E'Mengapa pointer penting untuk struct besar?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena menghindari penyalinan seluruh struct.\n\nstruct Besar { int data[1000]; };\nsizeof(Besar) = 4000 byte\n\nKirim sebagai nilai  -> salin 4000 byte setiap panggilan\nKirim sebagai pointer -> salin 8 byte saja\n\nSelisihnya 500x lebih hemat. Untuk fungsi yang dipanggil sering, ini sangat signifikan.',
 5),

(E'struct Mahasiswa { double ipk; };\nvoid ubah(Mahasiswa m) { m.ipk = 4.0; }\n\nMahasiswa m = {3.5};\nubah(m);\ncout << m.ipk;',
 E'void ubah(Mahasiswa m) { m.ipk = 4.0; }\\nMahasiswa m = {3.5};\\nubah(m);\\ncout << m.ipk;', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 3.5\n\nKirim sebagai NILAI = SALINAN. Mengubah m.ipk di dalam fungsi tidak mempengaruhi struct asli.\n\nPengecoh 4 salah - itu hasil kalau dikirim sebagai pointer.\n\nUntuk mengubah aslinya: void ubah(Mahasiswa* m) { m->ipk = 4.0; }',
 6),

(E'Mahasiswa daftar[3] = {{"Rani"},{"Budi"},{"Citra"}};\nMahasiswa* p = daftar;\ncout << (p + 1)->nama;',
 E'Mahasiswa* p = daftar;\\ncout << (p + 1)->nama;', 'cpp', 'TRACE', 'TRACING',
 E'Output: Budi\n\np menunjuk ke daftar[0]. p + 1 menunjuk ke daftar[1]. (p + 1)->nama = daftar[1].nama = "Budi"\n\nSetara dengan p[1].nama.\n\nPengecoh Rani = daftar[0]. Citra = daftar[2].',
 7),

(E'Bagaimana cara mengirim struct agar tidak disalin dan tidak bisa diubah?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: Pakai const pointer.\n\nvoid cetak(const Mahasiswa* m) {\n    cout << m->nama;\n    // m->ipk = 4.0;   // ERROR\n}\n\nconst mencegah perubahan, pointer mencegah penyalinan. Ini pola paling umum di kode C++ profesional.\n\nMahasiswa m (nilai) juga tidak bisa diubah kalau const, tetapi tetap disalin.',
 8),

(E'Mengapa mengakses anggota lewat nullptr berbahaya?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena itu undefined behavior.\n\nMahasiswa* p = nullptr;\np->nama;   // UB!\n\nSelalu periksa: if (p) { cout << p->nama; }\n\nTerutama penting kalau pointer berasal dari parameter fungsi, karena pemanggil mungkin mengirim nullptr.',
 9),

(E'Apa perbedaan perilaku b = a pada struct C++ dan objek Python?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: C++ menyalin NILAI; Python menyalin REFERENSI.\n\nC++: Titik b = a; -> salinan. Mengubah b tidak mempengaruhi a.\n\nPython: b = a -> referensi yang sama. Mengubah b IKUT mempengaruhi a.\n\nIni perbedaan mendasar antara tipe nilai (C++ struct) dan tipe referensi (Python objek).',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'pointer-struct';

-- OPSI SOAL (pointer-struct)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'(*pt).x dan pt->x', true, 1),
  (1, 'B', E'pt.x dan pt->x', false, 2),
  (1, 'C', E'*pt.x dan pt->x', false, 3),
  (1, 'D', E'pt.x dan (*pt)->x', false, 4),
  (2, 'A', E'Karena (*pt).x merepotkan ditulis dan tanda kurungnya mudah terlupa', true, 1),
  (2, 'B', E'Karena (*pt).x tidak valid', false, 2),
  (2, 'C', E'Karena operator . tidak bisa dipakai pada struct', false, 3),
  (2, 'D', E'Karena -> lebih cepat dijalankan', false, 4),
  (3, 'A', E'. untuk nilai/referensi; -> untuk pointer', true, 1),
  (3, 'B', E'. untuk pointer; -> untuk nilai', false, 2),
  (3, 'C', E'Keduanya bisa dipakai bergantian', false, 3),
  (3, 'D', E'-> hanya untuk array', false, 4),
  (4, 'A', E'99', true, 1),
  (4, 'B', E'3', false, 2),
  (4, 'C', E'7', false, 3),
  (4, 'D', E'Error', false, 4),
  (5, 'A', E'Karena menghindari penyalinan seluruh struct', true, 1),
  (5, 'B', E'Karena pointer lebih mudah dibaca', false, 2),
  (5, 'C', E'Karena struct tidak bisa disalin', false, 3),
  (5, 'D', E'Karena pointer menghemat memori saat disimpan', false, 4),
  (6, 'A', E'3.5', true, 1),
  (6, 'B', E'4', false, 2),
  (6, 'C', E'0', false, 3),
  (6, 'D', E'Error', false, 4),
  (7, 'A', E'Budi', true, 1),
  (7, 'B', E'Rani', false, 2),
  (7, 'C', E'Citra', false, 3),
  (7, 'D', E'Error', false, 4),
  (8, 'A', E'Pakai const pointer: void cetak(const Mahasiswa* m)', true, 1),
  (8, 'B', E'Pakai nilai biasa: void cetak(Mahasiswa m)', false, 2),
  (8, 'C', E'Pakai referensi biasa: void cetak(Mahasiswa& m)', false, 3),
  (8, 'D', E'Tidak bisa dilakukan di C++', false, 4),
  (9, 'A', E'Karena itu undefined behavior', true, 1),
  (9, 'B', E'Karena compiler menolak', false, 2),
  (9, 'C', E'Karena nullptr tidak bisa diakses', false, 3),
  (9, 'D', E'Karena struct tidak punya anggota', false, 4),
  (10, 'A', E'C++ menyalin NILAI; Python menyalin REFERENSI', true, 1),
  (10, 'B', E'Keduanya menyalin nilai', false, 2),
  (10, 'C', E'Keduanya menyalin referensi', false, 3),
  (10, 'D', E'C++ menyalin referensi; Python menyalin nilai', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'pointer-struct';

-- =========================================================
-- Modul 10: pointer-dinamis (Alokasi Memori Dinamis)
-- =========================================================
-- FLASHCARD (pointer-dinamis)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa perbedaan stack dan heap?',
 E'STACK:\n- sangat cepat\n- kecil (1-8 MB)\n- masa hidup otomatis (keluar scope)\n- dikelola compiler\n\nHEAP:\n- lebih lambat\n- besar\n- masa hidup MANUAL (sampai delete)\n- dikelola programmer',
 'BANDING', null, null, 1),

(E'Bagaimana cara mengalokasikan satu nilai di heap?',
 E'int* p = new int(42);   // alokasi + inisialisasi\n\ncout << *p;             // 42\n\ndelete p;               // WAJIB dibebaskan',
 'SINTAKS', E'int* p = new int(42);\\ndelete p;', 'cpp', 2),

(E'Bagaimana cara mengalokasikan array di heap?',
 E'int* arr = new int[5];   // 5 elemen\n\nfor (int i = 0; i < 5; i++) arr[i] = i * 10;\n\ndelete[] arr;             // PERHATIKAN: delete[]',
 'SINTAKS', E'int* arr = new int[5];\\ndelete[] arr;   // pakai delete[]!', 'cpp', 3),

(E'Mengapa new[] harus dipasangkan delete[]?',
 E'Karena keduanya BERBEDA:\n\nnew int      -> delete p\nnew int[5]   -> delete[] arr\n\nMencampurnya adalah UNDEFINED BEHAVIOR:\n\nint* arr = new int[5];\ndelete arr;      // UB! seharusnya delete[]',
 'JEBAKAN', E'int* arr = new int[5];\\ndelete arr;   // UB! seharusnya delete[]', 'cpp', 4),

(E'Apa itu memory leak?',
 E'Memori heap yang TIDAK dibebaskan karena lupa delete.\n\nvoid bocor() {\n    int* p = new int(42);\n    // lupa delete -> LEAK\n}\n\nAkibat: memori terpakai sampai program berakhir.\nDalam program panjang, memori habis -> crash.',
 'ISTILAH', null, null, 5),

(E'Apa itu dangling pointer?',
 E'Pointer yang menunjuk ke memori yang SUDAH dibebaskan.\n\nint* p = new int(42);\ndelete p;\ncout << *p;   // UB! p adalah dangling pointer\n\nBAHAYANYA: mungkin tampak berjalan normal karena\nnilai lama masih ada. Tapi itu undefined behavior.\n\nPerbaikan: p = nullptr; setelah delete.',
 'JEBAKAN', E'int* p = new int(42);\\ndelete p;\\ncout << *p;  // UB! dangling pointer', 'cpp', 6),

(E'Apa itu double free?',
 E'Memanggil delete DUA KALI pada pointer yang sama.\n\nint* p = new int(42);\ndelete p;\ndelete p;      // UB!\n\nPerbaikan:\ndelete p;\np = nullptr;\ndelete p;      // AMAN - delete pada nullptr tidak apa-apa',
 'JEBAKAN', E'delete p;\\ndelete p;  // UB!\\n\\n// Perbaikan:\\ndelete p; p = nullptr;\\ndelete p;  // aman', 'cpp', 7),

(E'Mengapa selalu set pointer ke nullptr setelah delete?',
 E'Dua alasan:\n\n1. Mencegah DANGLING POINTER\n   Akses lewat nullptr akan jelas salah,\n   bukan UB yang tersembunyi\n\n2. Membuat DELETE KEDUA aman\n   delete pada nullptr tidak melakukan apa-apa\n\ndelete p;\np = nullptr;',
 'KAPAN', E'delete p;\\np = nullptr;   // selalu lakukan ini', 'cpp', 8),

(E'Apa itu unique_ptr?',
 E'Smart pointer dengan kepemilikan TUNGGAL.\n\n#include <memory>\n\nauto p = make_unique<int>(99);\ncout << *p;   // 99\n\n// keluar scope -> OTOMATIS dibebaskan\n\nTidak bisa DISALIN (kepemilikan tunggal),\ntapi bisa DIPINDAHKAN dengan move().',
 'ISTILAH', E'auto p = make_unique<int>(99);\\n// otomatis dibebaskan saat keluar scope', 'cpp', 9),

(E'Bagaimana Python mengelola memori?',
 E'OTOMATIS, dengan dua mekanisme:\n\n1. REFERENCE COUNTING (utama)\n   Menghitung berapa nama menunjuk ke objek.\n   Saat mencapai nol -> dibebaskan.\n\n2. GARBAGE COLLECTOR (untuk siklus)\n   Mendeteksi objek yang saling menunjuk\n   sehingga penghitungnya tidak pernah nol.\n\nTidak ada new, tidak ada delete.',
 'ISTILAH', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'pointer-dinamis';

-- SOAL (pointer-dinamis)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Apa perbedaan utama stack dan heap?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Stack dikelola otomatis dan cepat; heap dikelola manual dan lebih lambat.\n\nSTACK: sangat cepat, kecil (1-8 MB), masa hidup otomatis saat keluar scope.\nHEAP: lebih lambat, besar, masa hidup manual sampai delete.\n\nPengecoh "stack lebih besar" salah - justru heap yang besar.',
 1),

(E'Bagaimana cara mengalokasikan satu nilai di heap?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: int* p = new int(42);\n\nnew mengalokasikan di heap dan mengembalikan pointer. delete membebaskannya.\n\nint* p = &x; salah - itu menunjuk variabel stack, bukan alokasi heap.\nint p = new int; salah - p bukan pointer.\nmalloc saja tanpa free adalah gaya C, bukan C++.',
 2),

(E'Bagaimana cara mengalokasikan array di heap?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: int* arr = new int[5];\n\nPerhatikan tanda kurung siku [5] untuk array.\n\nint* arr = new int; salah - itu alokasi SATU int, bukan array.\nint arr[5] = new int[5]; salah - itu array stack, bukan heap.\nint* arr = new int(5); salah - itu satu int bernilai 5.',
 3),

(E'Apa yang terjadi jika memakai delete (bukan delete[]) untuk memori dari new[]?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Undefined behavior.\n\nint* arr = new int[5];\ndelete arr;      // UB! seharusnya delete[]\n\nnew[] HARUS dipasangkan delete[], dan new harus dipasangkan delete. Mencampurnya bisa menyebabkan crash atau kerusakan heap.\n\nAturan ini tidak boleh dilanggar.',
 4),

(E'Apa itu memory leak?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Memori heap yang tidak dibebaskan karena lupa delete.\n\nvoid bocor() {\n    int* p = new int(42);\n    // lupa delete\n}\n\nAkibat: memori terpakai sampai program berakhir. Dalam program panjang, memori habis dan program crash.\n\nPengecoh "crash seketika" salah - leak bekerja perlahan.',
 5),

(E'Apa itu dangling pointer?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Pointer yang menunjuk ke memori yang sudah dibebaskan.\n\nint* p = new int(42);\ndelete p;\ncout << *p;   // UB! p adalah dangling pointer\n\nBahayanya: mungkin tampak berjalan normal karena nilai lama masih ada di memori. Tapi itu undefined behavior.\n\nPerbaikan: set p = nullptr setelah delete.',
 6),

(E'Apa itu double free?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Memanggil delete dua kali pada pointer yang sama.\n\ndelete p;\ndelete p;      // UB!\n\nPerbaikannya:\ndelete p;\np = nullptr;\ndelete p;      // AMAN - delete pada nullptr tidak melakukan apa-apa\n\nIni salah satu alasan selalu set nullptr setelah delete.',
 7),

(E'Mengapa selalu set pointer ke nullptr setelah delete?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: Untuk mencegah dangling pointer dan membuat delete kedua aman.\n\n1. Akses lewat nullptr akan jelas salah (bukan UB tersembunyi)\n2. delete pada nullptr tidak melakukan apa-apa, sehingga double free terhindar\n\ndelete p;\np = nullptr;   // selalu lakukan',
 8),

(E'Apa itu unique_ptr?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Smart pointer dengan kepemilikan tunggal.\n\nauto p = make_unique<int>(99);\n// keluar scope -> otomatis dibebaskan\n\nTidak bisa DISALIN karena kepemilikannya tunggal, tetapi bisa DIPINDAHKAN dengan move().\n\nPengecoh "kepemilikan bersama" salah - itu shared_ptr.',
 9),

(E'Bagaimana Python mengelola memori?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Otomatis dengan reference counting, plus garbage collector untuk siklus referensi.\n\n1. REFERENCE COUNTING: menghitung berapa nama menunjuk objek. Saat mencapai nol, dibebaskan.\n2. GARBAGE COLLECTOR: mendeteksi objek yang saling menunjuk sehingga penghitungnya tidak pernah nol.\n\nTidak ada new, tidak ada delete.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'pointer-dinamis';

-- OPSI SOAL (pointer-dinamis)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'Stack dikelola otomatis dan cepat; heap dikelola manual dan lebih lambat', true, 1),
  (1, 'B', E'Stack lebih besar dari heap', false, 2),
  (1, 'C', E'Heap otomatis, stack manual', false, 3),
  (1, 'D', E'Keduanya dikelola otomatis', false, 4),
  (2, 'A', E'int* p = new int(42);', true, 1),
  (2, 'B', E'int* p = &x;', false, 2),
  (2, 'C', E'int p = new int;', false, 3),
  (2, 'D', E'int* p = malloc(4);', false, 4),
  (3, 'A', E'int* arr = new int[5];', true, 1),
  (3, 'B', E'int* arr = new int;', false, 2),
  (3, 'C', E'int arr[5] = new int[5];', false, 3),
  (3, 'D', E'int* arr = new int(5);', false, 4),
  (4, 'A', E'Undefined behavior', true, 1),
  (4, 'B', E'Hanya membebaskan elemen pertama', false, 2),
  (4, 'C', E'Compiler menolak dan gagal build', false, 3),
  (4, 'D', E'Aman, karena delete sama dengan delete[]', false, 4),
  (5, 'A', E'Memori heap yang tidak dibebaskan karena lupa delete', true, 1),
  (5, 'B', E'Program crash seketika', false, 2),
  (5, 'C', E'Memori yang dibebaskan dua kali', false, 3),
  (5, 'D', E'Pointer yang menunjuk memori tidak valid', false, 4),
  (6, 'A', E'Pointer yang menunjuk ke memori yang sudah dibebaskan', true, 1),
  (6, 'B', E'Pointer yang bernilai nullptr', false, 2),
  (6, 'C', E'Pointer yang tidak diinisialisasi', false, 3),
  (6, 'D', E'Pointer yang menunjuk array', false, 4),
  (7, 'A', E'Memanggil delete dua kali pada pointer yang sama', true, 1),
  (7, 'B', E'Menghapus dua elemen sekaligus', false, 2),
  (7, 'C', E'Menghapus array dengan delete biasa', false, 3),
  (7, 'D', E'Menghapus pointer yang belum dialokasikan', false, 4),
  (8, 'A', E'Mencegah dangling pointer dan membuat delete kedua aman', true, 1),
  (8, 'B', E'Agar memori lebih cepat dibebaskan', false, 2),
  (8, 'C', E'Agar compiler tidak memberi peringatan', false, 3),
  (8, 'D', E'Karena delete memerlukan nilai nullptr', false, 4),
  (9, 'A', E'Smart pointer dengan kepemilikan tunggal', true, 1),
  (9, 'B', E'Smart pointer dengan kepemilikan bersama', false, 2),
  (9, 'C', E'Pointer yang tidak bisa dipindahkan', false, 3),
  (9, 'D', E'Pointer untuk array saja', false, 4),
  (10, 'A', E'Otomatis dengan reference counting, plus garbage collector untuk siklus referensi', true, 1),
  (10, 'B', E'Manual dengan new dan delete', false, 2),
  (10, 'C', E'Hanya dengan garbage collector', false, 3),
  (10, 'D', E'Dengan smart pointer', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'pointer-dinamis';

-- =========================================================
-- VERIFIKASI AKHIR
-- =========================================================
do $$
declare
  v_kartu int;
  v_soal int;
  v_opsi int;
  v_anomali int;
begin
  select count(*) into v_kartu from public.flashcard;
  select count(*) into v_soal from public.soal;
  select count(*) into v_opsi from public.opsi_soal;

  if v_kartu != 100 then
    raise exception 'Jumlah flashcard tidak sesuai: diharapkan 100, ada %', v_kartu;
  end if;

  if v_soal != 100 then
    raise exception 'Jumlah soal tidak sesuai: diharapkan 100, ada %', v_soal;
  end if;

  if v_opsi != 400 then
    raise exception 'Jumlah opsi tidak sesuai: diharapkan 400, ada %', v_opsi;
  end if;

  -- Pastikan setiap soal punya tepat 1 jawaban benar
  select count(*) into v_anomali
  from (
    select soal_id, count(*) filter (where benar = true) as benar_cnt
    from public.opsi_soal
    group by soal_id
    having count(*) filter (where benar = true) != 1
  ) sub;

  if v_anomali > 0 then
    raise exception 'Ditemukan % soal yang tidak memiliki tepat 1 jawaban benar!', v_anomali;
  end if;

  raise notice 'VERIFIKASI BERHASIL: 100 kartu, 100 soal, 400 opsi.';
end $$;


-- ==== 012_video_pembelajaran.sql ====
-- 012_video_pembelajaran.sql
-- Mengisi video pembelajaran C++ (Bahasa Indonesia) untuk setiap modul (1 s.d. 10).
-- Sumber: Seri Belajar C++ Dasar & OOP oleh Kelas Terbuka (Faqihza Mukhlish).
-- =========================================================

delete from public.video;

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

  ('array-multidimensi',
   '-hsKUD4fVRE',
   E'Belajar C++ [Dasar] - 46 - Multidimensi Array | Built-in',
   E'Pemahaman array 2 dimensi (matriks), representasi baris dan kolom, serta pemetaan indeks baris-kolom di memori.',
   594,
   1),

  ('array-dinamis',
   'o1DegduG140',
   E'Belajar C++ [Dasar] - 43 - Array || Standard Library',
   E'Pengenalan std::array dan konsep container modern C++, fungsi utilitas ukuran (.size()), dan transisi menuju array dinamis.',
   535,
   1),

  ('struct-dasar',
   'ELCI_U4OF5w',
   E'Belajar C++ [Dasar] - 56 - Struct',
   E'Membuat tipe data bentukan baru dengan struct, mengelompokkan variabel bertipe heterogen, serta mengakses member dengan operator titik.',
   595,
   1),

  ('struct-nested',
   'b2N3_dA8VBU',
   E'Belajar C++ [Dasar] - 57 - Nesting Struct',
   E'Struktur bertingkat (nested struct), array of struct, dan pemodelan entitas yang saling berhubungan secara terstruktur.',
   640,
   1),

  ('struct-memori',
   '4wWobjVejnU',
   E'Belajar C++ [OOP] - 08 - Memory dan Address dari Object',
   E'Bedah struktur memori objek/struct di C++, analisis alamat memori tiap member, ukuran sizeof, serta konsep padding dan alignment.',
   1654,
   1),

  ('pointer-dasar',
   'O1kWNj5Ikro',
   E'Belajar C++ [Dasar] - 38 - Pointer',
   E'Konsep pointer di C++, operator alamat (&), operator dereferensi (*), dan cara memanipulasi nilai variabel lewat alamat memori.',
   873,
   1),

  ('pointer-array',
   'ah8RcGXoK5A',
   E'Belajar C++ [Dasar] - 40 - Fungsi dengan Pointer',
   E'Mengirim pointer dan array ke parameter fungsi, konsep decay array menjadi pointer, serta manipulasi data array lewat pointer.',
   560,
   1),

  ('pointer-struct',
   '9C03NT254rA',
   E'Belajar C++ [OOP] - 20 - This & Cascading Function Calls',
   E'Mengakses anggota struct/objek lewat pointer menggunakan arrow operator (->) dan peran pointer implisit this pada C++.',
   1130,
   1),

  ('pointer-dinamis',
   'LaFxsl8rhTs',
   E'Belajar C++ [OOP] - 07 - Berbagai cara membuat Object',
   E'Alokasi memori dinamis di heap menggunakan keyword new, menyimpan alamat ke pointer, dan membebaskan memori dengan delete.',
   896,
   1)
) as v(slug, youtube_id, judul, deskripsi, durasi_detik, urutan)
  on m.slug = v.slug;

do $$ begin
 if(select count(*) from public.modul)<>10 then raise exception 'Expected 10 modules'; end if;
 if exists(select 1 from public.modul m where(select count(*) from public.flashcard f where f.modul_id=m.id)<>10) then raise exception 'Expected exactly 10 flashcards per module'; end if;
 if exists(select 1 from public.modul m where(select count(*) from public.soal s where s.modul_id=m.id)<>10) then raise exception 'Expected exactly 10 questions per module'; end if;
 if exists(select 1 from public.soal s where(select count(*) from public.opsi_soal o where o.soal_id=s.id)<>4 or(select count(*) from public.opsi_soal o where o.soal_id=s.id and o.benar)<>1) then raise exception 'Invalid quiz options'; end if;
 if(select count(*) from public.video)<>10 then raise exception 'Expected 10 videos'; end if;
end $$;
commit;
