-- =========================================================
-- Seed: Modul 7 — pointer-dasar
-- Dasar Pointer & Alamat Memori
--
-- Klaim UB di modul ini SUDAH DIVERIFIKASI terhadap standar C++
-- (docs/riset/04-RISET-UB-POINTER.md)
-- =========================================================

insert into public.modul (slug, judul, topik, deskripsi, estimasi_menit, urutan)
values ('pointer-dasar', 'Dasar Pointer & Alamat Memori', 'pointer',
  'Pointer menyimpan alamat, bukan nilai. Plus koreksi penting tentang one-past-the-end yang LEGAL.', 16, 7);

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

Pointer tidak menyimpan isi rumah — ia menyimpan **alamat** rumah.

## Alamat Itu Angka

Alamat memori sebenarnya hanyalah angka — nomor posisi di memori. Di sistem 64-bit, alamat ditulis dalam heksadesimal:

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

Mendereferensi `nullptr` adalah **undefined behavior**. Program biasanya crash, tetapi standar tidak menjamin itu — bisa saja tampak berjalan normal.

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

`id()` mengembalikan identitas objek — mirip alamat memori.

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

1. **Tidak ada alamat eksplisit** — kamu tidak perlu tahu di mana objek disimpan
2. **Tidak ada `delete`** — *garbage collector* membersihkan objek yang tidak dipakai
3. **Tidak ada dangling pointer** — objek tetap hidup selama masih ada referensi

> [!INFO]
> Memahami pointer C++ membuatmu memahami **mengapa** Python dirancang tanpa pointer. Python mengorbankan kontrol tingkat rendah demi keamanan. Untuk sebagian besar aplikasi, ini pertukaran yang menguntungkan.$md$, 4),

('one-past-the-end', 'Koreksi: One-Past-The-End Itu LEGAL', $md$Bagian ini mengoreksi kesalahpahaman yang **sangat umum** — termasuk yang sering diajarkan secara keliru.

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

Perhatikan loop berikut — ini **sah** justru karena `arr + 5` legal:

```cpp
for (int* p = arr; p != arr + 5; ++p) {
    cout << *p << " ";
}
// Output: 10 20 30 40 50
```

Kalau `arr + 5` UB, maka idiom loop standar ini juga UB — padahal ini cara yang lazim dan benar untuk mengiterasi array.

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

-- ============ FLASHCARD (24 kartu) ============
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values

('Apa itu pointer?',
 E'Variabel yang menyimpan ALAMAT memori,\nbukan nilai langsung.\n\nint nilai = 42;\nint* p = &nilai;   // p menyimpan alamat nilai',
 'ISTILAH', null, null, 1),

('Bagaimana cara mendeklarasikan pointer ke int?',
 E'int* p;\n\nCara membaca: "p adalah pointer ke int".\nBaca dari KANAN ke KIRI.',
 'SINTAKS', 'int* p;', 'cpp', 2),

('Bagaimana cara mengambil alamat sebuah variabel?',
 E'Pakai operator & (address-of):\n\nint nilai = 42;\ncout << &nilai;   // 0x7ffd...\n\n& adalah kebalikan dari * (dereferensi).',
 'SINTAKS', 'int nilai = 42;\nint* p = &nilai;', 'cpp', 3),

('Bagaimana cara membaca nilai lewat pointer?',
 E'Pakai operator * (dereferensi):\n\nint nilai = 42;\nint* p = &nilai;\n\ncout << *p;   // 42',
 'SINTAKS', 'int nilai = 42;\nint* p = &nilai;\ncout << *p;  // 42', 'cpp', 4),

('Apa yang salah dari int* a, b;?',
 E'HANYA a yang pointer. b adalah int BIASA.\n\nBukti:\nsizeof(a) = 8 (pointer)\nsizeof(b) = 4 (int)\n\nTanda * hanya berlaku untuk variabel PERTAMA.\n\nBenar: int* a; int* b;',
 'JEBAKAN', 'int* a, b;   // HANYA a yang pointer!', 'cpp', 5),

('Bagaimana cara mengubah nilai variabel lewat pointer?',
 E'int nilai = 42;\nint* p = &nilai;\n\n*p = 100;\ncout << nilai;   // 100 - nilai ASLI berubah\n\nInilah kekuatan pointer.',
 'SINTAKS', 'int nilai = 42;\nint* p = &nilai;\n*p = 100;  // nilai jadi 100', 'cpp', 6),

('Apa dua arti tanda bintang pada pointer?',
 E'1. Di DEKLARASI = bagian dari TIPE\n   int* p;\n\n2. Di EKSPRESI = operator DEREFERENSI\n   *p = 100;\n\nIni yang sering membingungkan pemula.',
 'ISTILAH', null, null, 7),

('Apa yang terjadi jika mendereferensi nullptr?',
 E'UNDEFINED BEHAVIOR - biasanya crash,\ntetapi standar tidak menjamin itu.\n\nint* p = nullptr;\ncout << *p;   // UB!\n\nSelalu periksa: if (p) { cout << *p; }',
 'JEBAKAN', null, null, 8),

('Mengapa pointer harus selalu diinisialisasi?',
 E'Pointer yang tidak diinisialisasi berisi ALAMAT ACAK\n(wild pointer).\n\nint* p;        // BAHAYA - alamat acak\ncout << *p;    // UB!\n\nKalau belum tahu mau menunjuk ke mana:\nint* p = nullptr;',
 'JEBAKAN', null, null, 9),

('Apa arti const pada const int* p?',
 E'Pointer ke int yang KONSTAN.\n\nconst int* p = &nilai;\n// *p = 10;   // ERROR - nilai tidak bisa diubah\np = &lain;    // BOLEH - alamat bisa diubah\n\nBaca dari kanan ke kiri:\n"p adalah pointer ke int yang const"',
 'SINTAKS', 'const int* p = &nilai;\n// *p = 10;  // ERROR', 'cpp', 10),

('Apa arti const pada int* const p?',
 E'Pointer KONSTAN ke int.\n\nint* const p = &nilai;\n*p = 10;      // BOLEH - nilai bisa diubah\n// p = &lain; // ERROR - alamat tidak bisa diubah\n\nBaca dari kanan ke kiri:\n"p adalah pointer const ke int"',
 'SINTAKS', 'int* const p = &nilai;\n*p = 10;  // BOLEH', 'cpp', 11),

('Apa perbedaan const int* p dan int* const p?',
 E'const int* p  : nilai tidak bisa diubah, alamat BOLEH\nint* const p  : alamat tidak bisa diubah, nilai BOLEH\nconst int* const p : keduanya tidak bisa diubah\n\nCara ingat: baca dari kanan ke kiri.\nconst yang paling dekat dengan p mengunci p.',
 'BANDING', null, null, 12),

('Apa yang terjadi jika mengakses nilai variabel lokal yang sudah keluar scope lewat pointer?',
 E'UNDEFINED BEHAVIOR.\n\nint* f() {\n    int lokal = 42;\n    return &lokal;   // BAHAYA!\n}\n\nSetelah f() selesai, lokal sudah tidak ada.\nPointer yang dikembalikan adalah DANGLING POINTER.\n\nMemakainya = UB.',
 'JEBAKAN', 'int* f() {\n    int lokal = 42;\n    return &lokal;  // UB!\n}', 'cpp', 13),

(E'int arr[5] = {10, 20, 30, 40, 50};\nint* p = arr;\ncout << *(p + 3);\n\nApa outputnya?',
 E'Output: 40\n\np menunjuk ke arr[0].\np + 3 menunjuk ke arr[3].\n*(p + 3) = arr[3] = 40',
 'TRACING', 'int arr[5] = {10, 20, 30, 40, 50};\nint* p = arr;\ncout << *(p + 3);', 'cpp', 14),

(E'int nilai = 42;\nint* p = &nilai;\n*p = 100;\ncout << nilai;',
 E'Output: 100\n\n*p = 100 mengubah nilai di alamat yang ditunjuk p.\nKarena p menunjuk ke nilai, maka nilai ikut berubah.\n\nIni kekuatan pointer: mengubah variabel lain\ntanpa menyentuh namanya.',
 'TRACING', 'int nilai = 42;\nint* p = &nilai;\n*p = 100;\ncout << nilai;', 'cpp', 15),

('Apa itu pointer ke pointer?',
 E'Pointer yang menyimpan alamat pointer lain.\n\nint x = 42;\nint* px = &x;\nint** ppx = &px;\n\ncout << **ppx;   // 42\n\nDua tanda bintang untuk dua level.',
 'ISTILAH', 'int x = 42;\nint* px = &x;\nint** ppx = &px;\ncout << **ppx;  // 42', 'cpp', 16),

('Bagaimana pointer bisa mengubah variabel dari dalam fungsi?',
 E'Dengan mengirim ALAMAT variabel:\n\nvoid ubah(int* q) { *q = 777; }\n\nint y = 1;\nubah(&y);\ncout << y;   // 777 - BERUBAH\n\nBandingkan dengan kirim nilai biasa:\nvoid ubahSalah(int q) { q = 888; }\nubahSalah(y);   // y TIDAK berubah',
 'SINTAKS', 'void ubah(int* q) { *q = 777; }\nint y = 1;\nubah(&y);  // y jadi 777', 'cpp', 17),

('Apakah membentuk pointer one-past-the-end itu undefined behavior?',
 E'TIDAK! Itu LEGAL.\n\nint arr[5];\nint* akhir = arr + 5;   // LEGAL\n\nStandar C++ mengizinkan membentuk pointer\nsatu langkah melewati elemen terakhir.\n\nYang UB adalah MENdereferensinya atau\nmelangkah LEBIH JAUH.',
 'JEBAKAN', 'int arr[5];\nint* akhir = arr + 5;   // LEGAL, bukan UB!', 'cpp', 18),

('Apa perbedaan membentuk dan mendereferensi pointer one-past-the-end?',
 E'MEMBENTUK arr + n  : LEGAL (0 <= i <= n)\nDEREFERENSI *(arr+n): UB untuk i == n\nMELANGKAH LEBIH     : UB\n\nint arr[5];\nint* p = arr + 5;   // LEGAL\n// *p;              // UB\n// arr + 6;         // UB',
 'MEMORI', null, null, 19),

('Mengapa idiom loop p != arr + n itu SAH?',
 E'Karena membentuk arr + n itu LEGAL.\n\nfor (int* p = arr; p != arr + 5; ++p) {\n    cout << *p << " ";\n}\n\nKalau arr + 5 UB, idiom loop standar ini juga UB -\npadahal ini cara lazim mengiterasi array di C++.',
 'MEMORI', 'for (int* p = arr; p != arr + 5; ++p) {\n    cout << *p << " ";\n}', 'cpp', 20),

('Apa aturan batas aritmetika pointer pada array berukuran n?',
 E'MEMBENTUK pointer:\n  arr + i LEGAL jika 0 <= i <= n\n  arr + i UB    jika i < 0 atau i > n\n\nDEREFERENSI:\n  *(arr + i) LEGAL jika 0 <= i < n\n  *(arr + i) UB    jika i == n\n\nPerhatikan: <= n untuk membentuk, < n untuk dereferensi.',
 'MEMORI', null, null, 21),

('Apakah Python punya pointer?',
 E'TIDAK. Python tidak punya pointer eksplisit.\n\nTetapi semua nama di Python adalah REFERENSI:\n\nx = [1, 2, 3]\ny = x          # objek SAMA\ny.append(4)\nprint(x)       # [1, 2, 3, 4] - ikut berubah\n\nMirip pointer, tapi TIDAK ada aritmetika pointer.',
 'BANDING', null, null, 22),

('Apa perbedaan pointer C++ dan referensi Python?',
 E'C++ pointer:\n- menyimpan alamat\n- bisa aritmetika (p + 1)\n- bisa di-cast\n- alamat terlihat (cout << p)\n- manajemen memori MANUAL\n\nPython nama:\n- referensi ke objek\n- TIDAK bisa aritmetika\n- tidak bisa di-cast\n- alamat tidak langsung terlihat (id())\n- manajemen memori OTOMATIS',
 'BANDING', null, null, 23),

('Bagaimana cara membuat salinan mendalam di Python?',
 E'Pakai copy.deepcopy():\n\nimport copy\n\nx = [[1, 2], [3, 4]]\ny = copy.deepcopy(x)\n\ny[0].append(99)\nprint(x)   # TIDAK berubah\n\nPERHATIAN: x.copy() hanya menyalin SATU level.\nUntuk objek bersarang, WAJIB deepcopy.',
 'SINTAKS', 'import copy\ny = copy.deepcopy(x)', 'python', 24)

) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'pointer-dasar';

-- ============ SOAL QUIZ (20 soal) ============
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values

('Apa yang disimpan oleh pointer?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Alamat memori, bukan nilai langsung.\n\nint nilai = 42;\nint* p = &nilai;   // p menyimpan ALAMAT nilai\n\nPengecoh "nilai variabel" salah - itu isi, bukan alamat.\nPengecoh "salinan variabel" salah - pointer tidak menyalin.',
 1),

('Apa yang salah dari deklarasi int* a, b;?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Hanya a yang pointer; b adalah int biasa.\n\nBukti: sizeof(a) = 8 (pointer), sizeof(b) = 4 (int).\n\nTanda * hanya berlaku untuk variabel PERTAMA dalam deklarasi.\n\nCara benar: int* a; int* b; atau int *a, *b;',
 2),

(E'int nilai = 42;\nint* p = &nilai;\n*p = 100;\ncout << nilai;',
 'int nilai = 42;\nint* p = &nilai;\n*p = 100;\ncout << nilai;',
 'cpp', 'TRACE', 'TRACING',
 E'Output: 100\n\n*p = 100 mengubah nilai di ALAMAT yang ditunjuk p.\nKarena p menunjuk ke nilai, maka nilai ikut berubah.\n\nIni kekuatan pointer: mengubah variabel lain tanpa menyentuh namanya.\n\nPengecoh 42 = nilai sebelum diubah.',
 3),

('Apa dua arti tanda bintang pada pointer?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Di deklarasi ia bagian dari TIPE; di ekspresi ia operator DEREFERENSI.\n\nint* p = &nilai;   // * bagian dari tipe\n*p = 100;          // * operator dereferensi\n\nIni yang sering membingungkan pemula karena simbolnya sama tetapi maknanya berbeda.',
 4),

('Apa yang terjadi jika mendereferensi nullptr?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Undefined behavior - biasanya crash, tetapi standar tidak menjamin itu.\n\nint* p = nullptr;\ncout << *p;   // UB!\n\nPengecoh "selalu crash" kurang tepat - standar hanya bilang UB, jadi bisa saja tampak berjalan.\nPengecoh "mengembalikan 0" salah - tidak ada nilai yang dikembalikan.',
 5),

('Mengapa pointer yang tidak diinisialisasi berbahaya?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena berisi alamat acak (wild pointer), dan mendereferensinya adalah undefined behavior.\n\nint* p;        // berisi alamat acak\ncout << *p;    // UB!\n\nSelalu inisialisasi: int* p = nullptr;',
 6),

('Apa arti const int* p?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Pointer ke int yang konstan - nilai tidak bisa diubah, alamat boleh diubah.\n\nconst int* p = &nilai;\n// *p = 10;   // ERROR\np = &lain;    // BOLEH\n\nCara baca: dari kanan ke kiri - "p adalah pointer ke int yang const".',
 7),

('Apa arti int* const p?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Pointer konstan ke int - alamat tidak bisa diubah, nilai boleh diubah.\n\nint* const p = &nilai;\n*p = 10;      // BOLEH\n// p = &lain; // ERROR\n\nCara baca: dari kanan ke kiri - "p adalah pointer const ke int".',
 8),

('Apa perbedaan const int* p dan int* const p?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: const int* p mengunci NILAI; int* const p mengunci ALAMAT.\n\nconst int* p  : nilai tidak bisa diubah, alamat boleh\nint* const p  : alamat tidak bisa diubah, nilai boleh\n\nCara ingat: baca dari kanan ke kiri. const yang paling dekat dengan p mengunci p.',
 9),

('Mengapa mengembalikan pointer ke variabel lokal berbahaya?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena variabel lokal sudah tidak ada setelah fungsi selesai, sehingga pointer menjadi dangling dan memakainya adalah UB.\n\nint* f() {\n    int lokal = 42;\n    return &lokal;   // BAHAYA!\n}\n\nSetelah f() selesai, memori lokal sudah dibebaskan.',
 10),

(E'int arr[5] = {10, 20, 30, 40, 50};\nint* p = arr;\ncout << *(p + 2);',
 'int arr[5] = {10, 20, 30, 40, 50};\nint* p = arr;\ncout << *(p + 2);',
 'cpp', 'TRACE', 'TRACING',
 E'Output: 30\n\np menunjuk ke arr[0].\np + 2 menunjuk ke arr[2].\n*(p + 2) = arr[2] = 30\n\nIndeks dimulai dari 0, jadi p+2 adalah elemen KETIGA.',
 11),

('Apakah membentuk pointer one-past-the-end (arr + n) itu undefined behavior?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: TIDAK - itu LEGAL menurut standar C++.\n\nint arr[5];\nint* akhir = arr + 5;   // LEGAL\n\nStandar mengizinkan membentuk pointer satu langkah melewati elemen terakhir.\n\nYang UB adalah MENdereferensinya atau melangkah LEBIH JAUH.\n\nIni kesalahpahaman yang sangat umum - banyak yang mengira ini UB padahal bukan.',
 12),

('Apa perbedaan membentuk dan mendereferensi pointer one-past-the-end?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Membentuk arr + n LEGAL; mendereferensi *(arr + n) UB.\n\nint arr[5];\nint* p = arr + 5;   // LEGAL\n// *p;              // UB\n// arr + 6;         // UB\n\nBatas: <= n untuk membentuk pointer, < n untuk mendereferensi.',
 13),

('Mengapa idiom loop p != arr + n itu sah?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena membentuk arr + n itu legal menurut standar.\n\nfor (int* p = arr; p != arr + 5; ++p) {\n    cout << *p << " ";\n}\n\nKalau arr + 5 UB, idiom loop standar ini juga UB - padahal ini cara lazim mengiterasi array di C++.\n\nAturan one-past-the-end ada JUSTRU agar idiom ini sah.',
 14),

('Apa aturan batas aritmetika pointer pada array berukuran n?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: arr + i legal untuk 0 <= i <= n; *(arr + i) legal untuk 0 <= i < n.\n\nMEMBENTUK pointer  : 0 <= i <= n\nDEREFERENSI        : 0 <= i < n\n\nPerhatikan batas atasnya BERBEDA: <= n untuk membentuk, < n untuk dereferensi.',
 15),

('Bagaimana pointer bisa mengubah variabel dari dalam fungsi?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Dengan mengirim alamat variabel, lalu fungsi mendereferensinya.\n\nvoid ubah(int* q) { *q = 777; }\nint y = 1;\nubah(&y);   // y jadi 777\n\nKalau dikirim nilai biasa, perubahan tidak mempengaruhi aslinya:\nvoid ubahSalah(int q) { q = 888; }   // y tidak berubah',
 16),

(E'int x = 42;\nint* px = &x;\nint** ppx = &px;\ncout << **ppx;',
 'int x = 42;\nint* px = &x;\nint** ppx = &px;\ncout << **ppx;',
 'cpp', 'TRACE', 'TRACING',
 E'Output: 42\n\nppx adalah pointer ke pointer.\n*ppx  = px (pointer ke x)\n**ppx = x = 42\n\nDua tanda bintang untuk dua level dereferensi.',
 17),

('Apakah Python punya pointer?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Tidak, Python tidak punya pointer eksplisit. Tetapi semua nama Python adalah referensi.\n\nx = [1, 2, 3]\ny = x          # objek SAMA\ny.append(4)\nprint(x)       # [1, 2, 3, 4]\n\nMirip pointer, tetapi TIDAK ada aritmetika pointer - kamu tidak bisa melakukan "x + 1".',
 18),

('Apa perbedaan utama pointer C++ dan referensi Python?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: C++ bisa aritmetika pointer dan manajemen memori manual; Python tidak bisa aritmetika dan memori dikelola otomatis.\n\nC++: p + 1 (aritmetika), delete (manual), alamat terlihat\nPython: tidak bisa aritmetika, garbage collector otomatis, id() untuk identitas\n\nKeduanya sama-sama menunjuk objek, tetapi tingkat kontrolnya berbeda jauh.',
 19),

('Bagaimana cara membuat salinan mendalam di Python?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: copy.deepcopy()\n\nimport copy\nx = [[1, 2], [3, 4]]\ny = copy.deepcopy(x)\n\nPENTING: x.copy() hanya menyalin SATU level. Untuk objek bersarang, list di dalamnya masih dibagi, sehingga mengubah y[0] ikut mengubah x[0].\n\nUntuk objek bersarang, WAJIB deepcopy.',
 20)

) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'pointer-dasar';

-- ============ OPSI JAWABAN ============
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', 'Alamat memori, bukan nilai langsung', true, 1),
  (1, 'B', 'Nilai variabel', false, 2),
  (1, 'C', 'Salinan variabel', false, 3),
  (1, 'D', 'Nama variabel', false, 4),
  (2, 'A', 'Hanya a yang pointer; b adalah int biasa', true, 1),
  (2, 'B', 'a dan b keduanya pointer', false, 2),
  (2, 'C', 'Keduanya bukan pointer', false, 3),
  (2, 'D', 'Deklarasi tidak valid dan gagal kompilasi', false, 4),
  (3, 'A', '100', true, 1),
  (3, 'B', '42', false, 2),
  (3, 'C', '0', false, 3),
  (3, 'D', 'Error', false, 4),
  (4, 'A', 'Di deklarasi bagian dari tipe; di ekspresi operator dereferensi', true, 1),
  (4, 'B', 'Selalu berarti perkalian', false, 2),
  (4, 'C', 'Selalu berarti dereferensi', false, 3),
  (4, 'D', 'Tidak ada arti khusus', false, 4),
  (5, 'A', 'Undefined behavior - biasanya crash, tetapi standar tidak menjamin itu', true, 1),
  (5, 'B', 'Selalu crash', false, 2),
  (5, 'C', 'Mengembalikan nilai 0', false, 3),
  (5, 'D', 'Melempar exception', false, 4),
  (6, 'A', 'Karena berisi alamat acak (wild pointer), dan mendereferensinya adalah UB', true, 1),
  (6, 'B', 'Karena pointer tidak bisa dibandingkan', false, 2),
  (6, 'C', 'Karena pointer memakan lebih banyak memori', false, 3),
  (6, 'D', 'Karena compiler menolak pointer tanpa nilai', false, 4),
  (7, 'A', 'Nilai tidak bisa diubah, alamat boleh diubah', true, 1),
  (7, 'B', 'Alamat tidak bisa diubah, nilai boleh diubah', false, 2),
  (7, 'C', 'Keduanya tidak bisa diubah', false, 3),
  (7, 'D', 'Keduanya bisa diubah', false, 4),
  (8, 'A', 'Alamat tidak bisa diubah, nilai boleh diubah', true, 1),
  (8, 'B', 'Nilai tidak bisa diubah, alamat boleh diubah', false, 2),
  (8, 'C', 'Keduanya tidak bisa diubah', false, 3),
  (8, 'D', 'Keduanya bisa diubah', false, 4),
  (9, 'A', 'const int* p mengunci NILAI; int* const p mengunci ALAMAT', true, 1),
  (9, 'B', 'Keduanya sama saja', false, 2),
  (9, 'C', 'const int* p mengunci alamat; int* const p mengunci nilai', false, 3),
  (9, 'D', 'Keduanya mengunci nilai dan alamat', false, 4),
  (10, 'A', 'Variabel lokal sudah tidak ada setelah fungsi selesai, pointer menjadi dangling, dan memakainya UB', true, 1),
  (10, 'B', 'Compiler menolak mengembalikan pointer', false, 2),
  (10, 'C', 'Pointer otomatis menjadi nullptr', false, 3),
  (10, 'D', 'Nilai variabel lokal ikut dikembalikan', false, 4),
  (11, 'A', '10', false, 1),
  (11, 'B', '20', false, 2),
  (11, 'C', '30', true, 3),
  (11, 'D', '40', false, 4),
  (12, 'A', 'Tidak - membentuk arr + n itu LEGAL menurut standar', true, 1),
  (12, 'B', 'Ya, selalu undefined behavior', false, 2),
  (12, 'C', 'Ya, tetapi hanya untuk array char', false, 3),
  (12, 'D', 'Tergantung compiler', false, 4),
  (13, 'A', 'Membentuk arr + n LEGAL; mendereferensi *(arr + n) UB', true, 1),
  (13, 'B', 'Keduanya legal', false, 2),
  (13, 'C', 'Keduanya undefined behavior', false, 3),
  (13, 'D', 'Membentuk UB; mendereferensi legal', false, 4),
  (14, 'A', 'Karena membentuk arr + n itu legal menurut standar', true, 1),
  (14, 'B', 'Karena compiler mengoptimalkan loop', false, 2),
  (14, 'C', 'Karena arr + n tidak pernah dievaluasi', false, 3),
  (14, 'D', 'Karena pointer tidak pernah dibandingkan', false, 4),
  (15, 'A', 'arr + i legal untuk 0 <= i <= n; *(arr + i) legal untuk 0 <= i < n', true, 1),
  (15, 'B', 'Keduanya legal untuk 0 <= i <= n', false, 2),
  (15, 'C', 'Keduanya legal untuk 0 <= i < n', false, 3),
  (15, 'D', 'Tidak ada batas selama alamatnya valid', false, 4),
  (16, 'A', 'Dengan mengirim alamat variabel, lalu fungsi mendereferensinya', true, 1),
  (16, 'B', 'Dengan mengirim variabel sebagai nilai', false, 2),
  (16, 'C', 'Dengan mendeklarasikan variabel sebagai global', false, 3),
  (16, 'D', 'Dengan mengembalikan nilai dari fungsi', false, 4),
  (17, 'A', '42', true, 1),
  (17, 'B', 'Alamat x', false, 2),
  (17, 'C', 'Error', false, 3),
  (17, 'D', '0', false, 4),
  (18, 'A', 'Tidak, tetapi semua nama Python adalah referensi ke objek', true, 1),
  (18, 'B', 'Ya, sama seperti C++', false, 2),
  (18, 'C', 'Ya, tetapi hanya untuk list', false, 3),
  (18, 'D', 'Tidak, dan Python juga tidak punya referensi', false, 4),
  (19, 'A', 'C++ bisa aritmetika pointer dan manajemen memori manual; Python tidak bisa aritmetika dan memori otomatis', true, 1),
  (19, 'B', 'C++ dan Python sama-sama punya aritmetika pointer', false, 2),
  (19, 'C', 'Python punya aritmetika pointer, C++ tidak', false, 3),
  (19, 'D', 'Keduanya tidak bisa menunjuk objek', false, 4),
  (20, 'A', 'copy.deepcopy()', true, 1),
  (20, 'B', 'x.copy()', false, 2),
  (20, 'C', 'x[:]', false, 3),
  (20, 'D', 'list(x)', false, 4)
) as v(urutan_soal, label, teks, benar, urutan)
  on v.urutan_soal = s.urutan
where m.slug = 'pointer-dasar';
