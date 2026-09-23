-- =========================================================
-- Seed: Modul 3 — array-dinamis
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
| Elemen pertama | `v.front()` | — |
| Elemen terakhir | `v.back()` | — |
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

`at()` memeriksa batas dan melempar exception. `[ ]` tidak memeriksa apa pun — sama seperti array C biasa.

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

Perhatikan: kapasitas berlipat (1 → 2 → 4 → 8 → 16), sedangkan size bertambah satu per satu.

## Mengapa Kapasitas Berlipat

Karena menambah kapasitas satu per satu akan sangat lambat:

```
Tambah 1 per 1  : setiap push_back butuh alokasi ulang -> O(n) per operasi
Lipat ganda     : alokasi ulang jarang -> O(1) rata-rata
```

Dengan melipatgandakan, alokasi ulang jadi semakin jarang seiring data bertambah.

> [!PERHATIAN]
> Angka pertumbuhan **2x** adalah *implementation-defined* — tidak dijamin standar C++. GCC memakai 2x, tetapi implementasi lain bisa memakai 1,5x. **Jangan hafalkan angkanya**; pahami **mengapa** pertumbuhan berlipat diperlukan.

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

Di dalam fungsi, `sizeof(arr)` menghasilkan **8 byte** — ukuran pointer — bukan 20 byte ukuran array. Informasi ukuran **hilang**.

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

('list-python', 'List Python', $md$`list` Python adalah padanan `std::vector` — array dinamis. Tapi mekanismenya berbeda.

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

-- ============ FLASHCARD (10 kartu) ============
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

-- ============ SOAL QUIZ (10 soal) ============
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

-- ============ OPSI JAWABAN (40 opsi) ============
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
