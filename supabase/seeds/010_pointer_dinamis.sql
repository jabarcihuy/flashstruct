-- =========================================================
-- Seed: Modul 10 — pointer-dinamis
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
> Aturan praktis: data kecil dan berumur pendek -> stack. Data besar atau berumur panjang -> heap. Tapi di C++ modern, **hindari `new`/`delete` manual** — pakai `std::vector` atau *smart pointer*.$md$, 1),

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

Setelah `delete`, `p` masih menyimpan alamat lama. Alamat itu sekarang tidak valid — memakainya adalah **undefined behavior**.

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

**Penting:** lupa `delete` **bukan** undefined behavior — hanya kebocoran memori. Bedanya penting:

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

Inilah salah satu alasan **selalu set pointer ke `nullptr` setelah `delete`** — ia membuat `delete` kedua menjadi aman.

## Ringkasan

| Bug | Penyebab | UB? | Pencegahan |
|-----|----------|-----|------------|
| Memory leak | Lupa `delete` | Tidak | Selalu bebaskan, atau pakai smart pointer |
| Dangling | Pakai setelah `delete` | **Ya** | Set `nullptr` setelah `delete` |
| Double free | `delete` dua kali | **Ya** | Set `nullptr` setelah `delete` |

> [!BAHAYA]
> Ketiga bug ini adalah alasan mengapa C++ modern menganjurkan **smart pointer**. Dengan `unique_ptr`, ketiganya **tidak mungkin terjadi** — memori dibebaskan otomatis saat pointer keluar scope.$md$, 3),

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

**Output terukur:** `1 → 2 → 1`

Memori dibebaskan ketika **penghitung mencapai nol** — artinya tidak ada lagi yang memiliki objek itu.

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
> **Aturan C++ modern:** hindari `new`/`delete` manual. Pakai `make_unique` sebagai default. Gunakan `shared_ptr` hanya kalau benar-benar perlu kepemilikan bersama — ia sedikit lebih mahal karena menghitung referensi.

## Mengapa Ini Penting

Dengan smart pointer, tiga bug klasik **tidak mungkin terjadi**:

| Bug | Dengan unique_ptr |
|-----|-------------------|
| Memory leak | Tidak mungkin — dibebaskan otomatis |
| Dangling | Tidak mungkin — pointer menjadi kosong |
| Double free | Tidak mungkin — hanya dibebaskan sekali |

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
2. **Cache yang tidak dibatasi** — objek disimpan terus dan tidak pernah dilepas
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

-- ============ FLASHCARD (10 kartu) ============
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

-- ============ SOAL QUIZ (10 soal) ============
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

-- ============ OPSI JAWABAN (40 opsi) ============
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
