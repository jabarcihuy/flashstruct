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

-- ============ FLASHCARD (10 kartu) ============
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

-- ============ SOAL QUIZ (10 soal) ============
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

-- ============ OPSI JAWABAN (40 opsi) ============
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
