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

-- ============ FLASHCARD (26 kartu) ============
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values

('Apa perbedaan stack dan heap?',
 E'STACK:\n- sangat cepat\n- kecil (1-8 MB)\n- masa hidup otomatis (keluar scope)\n- dikelola compiler\n\nHEAP:\n- lebih lambat\n- besar\n- masa hidup MANUAL (sampai delete)\n- dikelola programmer',
 'BANDING', null, null, 1),

('Bagaimana cara mengalokasikan satu nilai di heap?',
 E'int* p = new int(42);   // alokasi + inisialisasi\n\ncout << *p;             // 42\n\ndelete p;               // WAJIB dibebaskan',
 'SINTAKS', 'int* p = new int(42);\ndelete p;', 'cpp', 2),

('Bagaimana cara mengalokasikan array di heap?',
 E'int* arr = new int[5];   // 5 elemen\n\nfor (int i = 0; i < 5; i++) arr[i] = i * 10;\n\ndelete[] arr;             // PERHATIKAN: delete[]',
 'SINTAKS', 'int* arr = new int[5];\ndelete[] arr;   // pakai delete[]!', 'cpp', 3),

('Mengapa new[] harus dipasangkan delete[]?',
 E'Karena keduanya BERBEDA:\n\nnew int      -> delete p\nnew int[5]   -> delete[] arr\n\nMencampurnya adalah UNDEFINED BEHAVIOR:\n\nint* arr = new int[5];\ndelete arr;      // UB! seharusnya delete[]',
 'JEBAKAN', 'int* arr = new int[5];\ndelete arr;   // UB! seharusnya delete[]', 'cpp', 4),

('Apakah delete mengubah pointer menjadi nullptr?',
 E'TIDAK!\n\nint* p = new int(42);\ncout << p;      // 0x557d611d7030\n\ndelete p;\ncout << p;      // 0x557d611d7030 - MASIH ALAMAT LAMA!\n\ndelete membebaskan MEMORI, tapi TIDAK mengubah nilai pointer.\n\nPraktik baik: p = nullptr; setelah delete.',
 'JEBAKAN', 'delete p;\ncout << p;  // masih alamat lama!\np = nullptr;  // set sendiri', 'cpp', 5),

('Apa itu memory leak?',
 E'Memori heap yang TIDAK dibebaskan karena lupa delete.\n\nvoid bocor() {\n    int* p = new int(42);\n    // lupa delete -> LEAK\n}\n\nAkibat: memori terpakai sampai program berakhir.\nDalam program panjang, memori habis -> crash.',
 'ISTILAH', null, null, 6),

('Apakah lupa delete itu undefined behavior?',
 E'TIDAK.\n\nLupa delete = memory leak (bukan UB).\nPakai setelah delete = UB.\n\nBedanya penting:\n- Leak: memori terpakai terus, akhirnya habis\n- UB: bisa apa saja, termasuk crash seketika\n\nKeduanya buruk, tapi dengan cara berbeda.',
 'BANDING', null, null, 7),

('Apa itu dangling pointer?',
 E'Pointer yang menunjuk ke memori yang SUDAH dibebaskan.\n\nint* p = new int(42);\ndelete p;\ncout << *p;   // UB! p adalah dangling pointer\n\nBAHAYANYA: mungkin tampak berjalan normal karena\nnilai lama masih ada. Tapi itu undefined behavior.\n\nPerbaikan: p = nullptr; setelah delete.',
 'JEBAKAN', 'int* p = new int(42);\ndelete p;\ncout << *p;  // UB! dangling pointer', 'cpp', 8),

('Apa itu double free?',
 E'Memanggil delete DUA KALI pada pointer yang sama.\n\nint* p = new int(42);\ndelete p;\ndelete p;      // UB!\n\nPerbaikan:\ndelete p;\np = nullptr;\ndelete p;      // AMAN - delete pada nullptr tidak apa-apa',
 'JEBAKAN', 'delete p;\ndelete p;  // UB!\n\n// Perbaikan:\ndelete p; p = nullptr;\ndelete p;  // aman', 'cpp', 9),

('Mengapa selalu set pointer ke nullptr setelah delete?',
 E'Dua alasan:\n\n1. Mencegah DANGLING POINTER\n   Akses lewat nullptr akan jelas salah,\n   bukan UB yang tersembunyi\n\n2. Membuat DELETE KEDUA aman\n   delete pada nullptr tidak melakukan apa-apa\n\ndelete p;\np = nullptr;',
 'KAPAN', 'delete p;\np = nullptr;   // selalu lakukan ini', 'cpp', 10),

('Apa itu smart pointer?',
 E'Pointer yang membebaskan memori OTOMATIS.\n\n#include <memory>\n\n{\n    auto p = make_unique<int>(99);\n    cout << *p;   // 99\n}   // <- OTOMATIS dibebaskan\n\nTidak perlu delete.\nTidak mungkin lupa.\nTidak mungkin double free.',
 'ISTILAH', null, null, 11),

('Apa itu unique_ptr?',
 E'Smart pointer dengan kepemilikan TUNGGAL.\n\n#include <memory>\n\nauto p = make_unique<int>(99);\ncout << *p;   // 99\n\n// keluar scope -> OTOMATIS dibebaskan\n\nTidak bisa DISALIN (kepemilikan tunggal),\ntapi bisa DIPINDAHKAN dengan move().',
 'ISTILAH', 'auto p = make_unique<int>(99);\n// otomatis dibebaskan saat keluar scope', 'cpp', 12),

('Mengapa unique_ptr tidak bisa disalin?',
 E'Karena kepemilikannya TUNGGAL.\n\nKalau bisa disalin, dua pointer akan memiliki\nobjek yang sama -> double free.\n\nauto p1 = make_unique<int>(7);\n// auto p2 = p1;        // ERROR: tidak bisa disalin\nauto p2 = move(p1);     // BOLEH: dipindahkan\n\nSetelah move, p1 menjadi nullptr.',
 'MEMORI', 'auto p2 = move(p1);  // boleh\n// auto p2 = p1;     // ERROR', 'cpp', 13),

('Apa yang terjadi pada unique_ptr setelah dipindahkan?',
 E'Menjadi NULLPTR (kosong).\n\nauto p1 = make_unique<int>(7);\nauto p2 = move(p1);\n\ncout << *p2;             // 7\ncout << (p1 == nullptr); // 1 (true)\n\nIni mencegah dua unique_ptr memiliki objek sama.\nSumber daya hanya bisa dimiliki satu pihak.',
 'MEMORI', null, null, 14),

('Apa itu shared_ptr?',
 E'Smart pointer dengan kepemilikan BERSAMA.\n\nBisa disalin, dan memori dibebaskan saat\npenghitung referensi mencapai NOL.\n\nauto s1 = make_shared<int>(55);\ncout << s1.use_count();   // 1\n{\n    auto s2 = s1;\n    cout << s1.use_count();  // 2\n}\ncout << s1.use_count();   // 1',
 'ISTILAH', 'auto s1 = make_shared<int>(55);\ncout << s1.use_count();  // 1', 'cpp', 15),

(E'auto s1 = make_shared<int>(55);\ncout << s1.use_count();\n{\n    auto s2 = s1;\n    cout << s1.use_count();\n}\ncout << s1.use_count();',
 E'Output: 1 2 1\n\nuse_count() menghitung berapa banyak shared_ptr\nyang memiliki objek itu.\n\n1 -> hanya s1\n2 -> s1 dan s2\n1 -> s2 keluar scope\n\nMemori dibebaskan saat count mencapai 0.',
 'TRACING', 'auto s1 = make_shared<int>(55);\ncout << s1.use_count();  // 1\n{ auto s2 = s1; cout << s1.use_count(); }  // 2\ncout << s1.use_count();  // 1', 'cpp', 16),

('Bagaimana cara membuat unique_ptr untuk array?',
 E'auto arr = make_unique<int[]>(3);\n\narr[0] = 1; arr[1] = 2; arr[2] = 3;\n\n// otomatis dibebaskan, TIDAK perlu delete[]\n\nLebih aman dari new[] + delete[] manual.',
 'SINTAKS', 'auto arr = make_unique<int[]>(3);\n// otomatis dibebaskan', 'cpp', 17),

('Kapan pakai unique_ptr dan kapan shared_ptr?',
 E'unique_ptr (PALING UMUM):\n- kepemilikan tunggal\n- tidak perlu dibagi\n- lebih ringan\n\nshared_ptr:\n- kepemilikan BERSAMA\n- beberapa bagian kode perlu memiliki objek sama\n- sedikit lebih mahal (menghitung referensi)\n\nDefault: pakai unique_ptr.',
 'KAPAN', null, null, 18),

('Mengapa C++ modern menganjurkan smart pointer?',
 E'Karena menghilangkan TIGA bug klasik sekaligus:\n\n| Bug          | Dengan unique_ptr     |\n|--------------|-----------------------|\n| Memory leak  | Tidak mungkin         |\n| Dangling     | Tidak mungkin         |\n| Double free  | Tidak mungkin         |\n\nIni bukan sekadar kenyamanan -\nini menghilangkan SELURUH KATEGORI bug.',
 'MEMORI', null, null, 19),

('Bagaimana Python mengelola memori?',
 E'OTOMATIS, dengan dua mekanisme:\n\n1. REFERENCE COUNTING (utama)\n   Menghitung berapa nama menunjuk ke objek.\n   Saat mencapai nol -> dibebaskan.\n\n2. GARBAGE COLLECTOR (untuk siklus)\n   Mendeteksi objek yang saling menunjuk\n   sehingga penghitungnya tidak pernah nol.\n\nTidak ada new, tidak ada delete.',
 'ISTILAH', null, null, 20),

('Apa itu siklus referensi di Python?',
 E'Dua objek yang saling menunjuk, sehingga\npenghitung referensinya tidak pernah mencapai nol.\n\na.teman = b\nb.teman = a      # SIKLUS!\n\nReference counting TIDAK bisa menangani ini.\n\nSolusinya: Python punya GARBAGE COLLECTOR\nterpisah yang mendeteksi siklus dan membersihkannya.',
 'MEMORI', null, null, 21),

('Apakah Python bebas dari masalah memori?',
 E'TIDAK sepenuhnya.\n\nKebocoran tetap mungkin:\n1. Siklus referensi yang tidak ditangani GC\n2. Cache yang tidak dibatasi\n3. Referensi global yang menahan objek besar\n\n"Otomatis" bukan berarti "bebas masalah".',
 'JEBAKAN', null, null, 22),

('Kapan alokasi dinamis benar-benar diperlukan?',
 E'EMPAT situasi:\n\n1. Ukuran baru diketahui saat runtime\n   int n; cin >> n; int* arr = new int[n];\n\n2. Masa hidup melebihi scope\n   return pointer dari fungsi\n\n3. Struktur data rekursif\n   linked list, tree, graph\n\n4. Objek besar\n   menghindari stack overflow',
 'KAPAN', null, null, 23),

('Mengapa linked list butuh alokasi dinamis?',
 E'Karena:\n\n1. Jumlah node baru diketahui saat runtime\n2. Node harus hidup selama belum dihapus\n3. Node saling menunjuk (rekursif)\n\nstruct Node {\n    int data;\n    Node* next;   // menunjuk node lain di heap\n};\n\nTidak mungkin dibuat dengan array biasa.',
 'MEMORI', 'struct Node {\n    int data;\n    Node* next;   // butuh heap\n};', 'cpp', 24),

('Apa risiko alokasi besar di stack?',
 E'STACK OVERFLOW.\n\nvoid bahaya() {\n    int besar[1000000];   // 4 MB di stack!\n}\n\nStack hanya 1-8 MB. Alokasi besar bisa\nmenyebabkan program crash.\n\nSolusi: alokasikan di HEAP:\nint* besar = new int[1000000];',
 'JEBAKAN', 'int besar[1000000];   // 4 MB - bisa stack overflow!\n// Solusi: int* besar = new int[1000000];', 'cpp', 25),

('Apa aturan C++ modern tentang new/delete manual?',
 E'HINDARI new/delete manual di kode produksi.\n\nGAYA LAMA:\nint* data = new int[n];\n// ...\ndelete[] data;\n\nGAYA MODERN:\nvector<int> data(n);\n// otomatis dibebaskan\n\nUntuk struktur data, pakai smart pointer:\nunique_ptr<Node> next;\n\nPahami new/delete untuk ujian,\npakai vector/smart pointer untuk kerja.',
 'KAPAN', 'vector<int> data(n);   // bukan new int[n]', 'cpp', 26)

) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'pointer-dinamis';

-- ============ SOAL QUIZ (22 soal) ============
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values

('Apa perbedaan utama stack dan heap?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Stack dikelola otomatis dan cepat; heap dikelola manual dan lebih lambat.\n\nSTACK: sangat cepat, kecil (1-8 MB), masa hidup otomatis saat keluar scope.\nHEAP: lebih lambat, besar, masa hidup manual sampai delete.\n\nPengecoh "stack lebih besar" salah - justru heap yang besar.',
 1),

('Bagaimana cara mengalokasikan satu nilai di heap?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: int* p = new int(42);\n\nnew mengalokasikan di heap dan mengembalikan pointer. delete membebaskannya.\n\nint* p = &x; salah - itu menunjuk variabel stack, bukan alokasi heap.\nint p = new int; salah - p bukan pointer.\nmalloc saja tanpa free adalah gaya C, bukan C++.',
 2),

('Bagaimana cara mengalokasikan array di heap?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: int* arr = new int[5];\n\nPerhatikan tanda kurung siku [5] untuk array.\n\nint* arr = new int; salah - itu alokasi SATU int, bukan array.\nint arr[5] = new int[5]; salah - itu array stack, bukan heap.\nint* arr = new int(5); salah - itu satu int bernilai 5.',
 3),

('Apa yang terjadi jika memakai delete (bukan delete[]) untuk memori dari new[]?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Undefined behavior.\n\nint* arr = new int[5];\ndelete arr;      // UB! seharusnya delete[]\n\nnew[] HARUS dipasangkan delete[], dan new harus dipasangkan delete. Mencampurnya bisa menyebabkan crash atau kerusakan heap.\n\nAturan ini tidak boleh dilanggar.',
 4),

(E'int* p = new int(42);\ncout << p << " ";\ndelete p;\ncout << p;',
 'int* p = new int(42);\ncout << p << " ";\ndelete p;\ncout << p;',
 'cpp', 'TRACE', 'MEMORI',
 E'Output: alamat yang SAMA dua kali\n\nContoh: 0x557d611d7030 0x557d611d7030\n\ndelete membebaskan MEMORI, tetapi TIDAK mengubah nilai pointer. p masih menyimpan alamat lama.\n\nIni alasan penting untuk set p = nullptr setelah delete.',
 5),

('Apa itu memory leak?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Memori heap yang tidak dibebaskan karena lupa delete.\n\nvoid bocor() {\n    int* p = new int(42);\n    // lupa delete\n}\n\nAkibat: memori terpakai sampai program berakhir. Dalam program panjang, memori habis dan program crash.\n\nPengecoh "crash seketika" salah - leak bekerja perlahan.',
 6),

('Apakah lupa memanggil delete itu undefined behavior?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: TIDAK - itu memory leak, bukan UB.\n\nLupa delete = memory leak (memori terpakai terus).\nPakai setelah delete = UB (bisa apa saja).\n\nBedanya penting: leak menyebabkan masalah perlahan, UB bisa crash seketika. Keduanya buruk, tetapi dengan cara berbeda.',
 7),

('Apa itu dangling pointer?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Pointer yang menunjuk ke memori yang sudah dibebaskan.\n\nint* p = new int(42);\ndelete p;\ncout << *p;   // UB! p adalah dangling pointer\n\nBahayanya: mungkin tampak berjalan normal karena nilai lama masih ada di memori. Tapi itu undefined behavior.\n\nPerbaikan: set p = nullptr setelah delete.',
 8),

('Apa itu double free?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Memanggil delete dua kali pada pointer yang sama.\n\ndelete p;\ndelete p;      // UB!\n\nPerbaikannya:\ndelete p;\np = nullptr;\ndelete p;      // AMAN - delete pada nullptr tidak melakukan apa-apa\n\nIni salah satu alasan selalu set nullptr setelah delete.',
 9),

('Mengapa selalu set pointer ke nullptr setelah delete?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: Untuk mencegah dangling pointer dan membuat delete kedua aman.\n\n1. Akses lewat nullptr akan jelas salah (bukan UB tersembunyi)\n2. delete pada nullptr tidak melakukan apa-apa, sehingga double free terhindar\n\ndelete p;\np = nullptr;   // selalu lakukan',
 10),

('Apa itu smart pointer?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Pointer yang membebaskan memori otomatis.\n\n{\n    auto p = make_unique<int>(99);\n    cout << *p;\n}   // <- otomatis dibebaskan\n\nTidak perlu delete, tidak mungkin lupa, tidak mungkin double free.\n\nIni menghilangkan seluruh kategori bug manajemen memori.',
 11),

('Apa itu unique_ptr?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Smart pointer dengan kepemilikan tunggal.\n\nauto p = make_unique<int>(99);\n// keluar scope -> otomatis dibebaskan\n\nTidak bisa DISALIN karena kepemilikannya tunggal, tetapi bisa DIPINDAHKAN dengan move().\n\nPengecoh "kepemilikan bersama" salah - itu shared_ptr.',
 12),

('Mengapa unique_ptr tidak bisa disalin?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena kepemilikannya tunggal - kalau bisa disalin, dua pointer akan memiliki objek yang sama dan menyebabkan double free.\n\nauto p2 = p1;        // ERROR\nauto p2 = move(p1);  // BOLEH\n\nSetelah move, p1 menjadi nullptr. Sumber daya hanya bisa dimiliki satu pihak pada satu waktu.',
 13),

(E'auto p1 = make_unique<int>(7);\nauto p2 = move(p1);\ncout << *p2 << " " << (p1 == nullptr);',
 'auto p1 = make_unique<int>(7);\nauto p2 = move(p1);\ncout << *p2 << " " << (p1 == nullptr);',
 'cpp', 'TRACE', 'MEMORI',
 E'Output: 7 1\n\n*p2 = 7 karena kepemilikan sudah dipindah ke p2.\np1 == nullptr bernilai true (1) karena setelah move, p1 menjadi kosong.\n\nIni mencegah dua unique_ptr memiliki objek yang sama.',
 14),

('Apa itu shared_ptr?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Smart pointer dengan kepemilikan bersama, dibebaskan saat penghitung referensi mencapai nol.\n\nauto s1 = make_shared<int>(55);\ncout << s1.use_count();   // 1\n\nBerbeda dari unique_ptr yang kepemilikannya tunggal. shared_ptr sedikit lebih mahal karena menghitung referensi.',
 15),

(E'auto s1 = make_shared<int>(55);\ncout << s1.use_count();\n{\n    auto s2 = s1;\n    cout << s1.use_count();\n}\ncout << s1.use_count();',
 'auto s1 = make_shared<int>(55);\ncout << s1.use_count();\n{ auto s2 = s1; cout << s1.use_count(); }\ncout << s1.use_count();',
 'cpp', 'TRACE', 'MEMORI',
 E'Output: 1 2 1\n\nuse_count() menghitung berapa shared_ptr yang memiliki objek itu.\n\n1 -> hanya s1\n2 -> s1 dan s2\n1 -> s2 keluar scope\n\nMemori dibebaskan saat count mencapai 0.',
 16),

('Bagaimana cara membuat unique_ptr untuk array?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: auto arr = make_unique<int[]>(3);\n\narr[0] = 1; arr[1] = 2; arr[2] = 3;\n// otomatis dibebaskan, tidak perlu delete[]\n\nPerhatikan tanda [] pada tipe: make_unique<int[]>(3).\n\nmake_unique<int>(3) salah - itu satu int bernilai 3, bukan array 3 elemen.',
 17),

('Kapan sebaiknya memakai shared_ptr daripada unique_ptr?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: Saat beberapa bagian kode perlu memiliki objek yang sama.\n\nunique_ptr (PALING UMUM): kepemilikan tunggal, lebih ringan.\nshared_ptr: kepemilikan bersama, sedikit lebih mahal karena menghitung referensi.\n\nDefault: pakai unique_ptr. Gunakan shared_ptr hanya kalau benar-benar perlu berbagi kepemilikan.',
 18),

('Mengapa C++ modern menganjurkan smart pointer?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena menghilangkan tiga bug klasik sekaligus.\n\nDengan unique_ptr:\n- Memory leak -> tidak mungkin (dibebaskan otomatis)\n- Dangling -> tidak mungkin (pointer menjadi kosong)\n- Double free -> tidak mungkin (hanya dibebaskan sekali)\n\nIni bukan sekadar kenyamanan - ini menghilangkan seluruh kategori bug.',
 19),

('Bagaimana Python mengelola memori?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Otomatis dengan reference counting, plus garbage collector untuk siklus referensi.\n\n1. REFERENCE COUNTING: menghitung berapa nama menunjuk objek. Saat mencapai nol, dibebaskan.\n2. GARBAGE COLLECTOR: mendeteksi objek yang saling menunjuk sehingga penghitungnya tidak pernah nol.\n\nTidak ada new, tidak ada delete.',
 20),

('Apa itu siklus referensi di Python?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Dua objek yang saling menunjuk, sehingga penghitung referensinya tidak pernah mencapai nol.\n\na.teman = b\nb.teman = a      # SIKLUS!\n\nReference counting tidak bisa menangani ini karena masing-masing masih punya referensi.\n\nSolusinya: Python punya garbage collector terpisah yang mendeteksi siklus dan membersihkannya.',
 21),

('Apakah Python bebas dari masalah memori?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Tidak sepenuhnya - kebocoran tetap mungkin.\n\n1. Siklus referensi yang tidak ditangani GC\n2. Cache yang tidak dibatasi (objek disimpan terus)\n3. Referensi global yang menahan objek besar\n\n"Otomatis" bukan berarti "bebas masalah". Memahami cara kerja memori tetap penting.',
 22)

) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'pointer-dinamis';

insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', 'Stack dikelola otomatis dan cepat; heap dikelola manual dan lebih lambat', true, 1),
  (1, 'B', 'Stack lebih besar dari heap', false, 2),
  (1, 'C', 'Heap otomatis, stack manual', false, 3),
  (1, 'D', 'Keduanya dikelola otomatis', false, 4),
  (2, 'A', 'int* p = new int(42);', true, 1),
  (2, 'B', 'int* p = &x;', false, 2),
  (2, 'C', 'int p = new int;', false, 3),
  (2, 'D', 'int* p = malloc(4);', false, 4),
  (3, 'A', 'int* arr = new int[5];', true, 1),
  (3, 'B', 'int* arr = new int;', false, 2),
  (3, 'C', 'int arr[5] = new int[5];', false, 3),
  (3, 'D', 'int* arr = new int(5);', false, 4),
  (4, 'A', 'Undefined behavior', true, 1),
  (4, 'B', 'Hanya membebaskan elemen pertama', false, 2),
  (4, 'C', 'Compiler menolak dan gagal build', false, 3),
  (4, 'D', 'Aman, karena delete sama dengan delete[]', false, 4),
  (5, 'A', 'Alamat yang sama dua kali - delete tidak mengubah nilai pointer', true, 1),
  (5, 'B', 'Alamat pertama, lalu 0', false, 2),
  (5, 'C', 'Alamat pertama, lalu alamat acak', false, 3),
  (5, 'D', 'Error karena p sudah dibebaskan', false, 4),
  (6, 'A', 'Memori heap yang tidak dibebaskan karena lupa delete', true, 1),
  (6, 'B', 'Program crash seketika', false, 2),
  (6, 'C', 'Memori yang dibebaskan dua kali', false, 3),
  (6, 'D', 'Pointer yang menunjuk memori tidak valid', false, 4),
  (7, 'A', 'Tidak - itu memory leak, bukan undefined behavior', true, 1),
  (7, 'B', 'Ya, selalu undefined behavior', false, 2),
  (7, 'C', 'Ya, tetapi hanya pada array', false, 3),
  (7, 'D', 'Tergantung compiler', false, 4),
  (8, 'A', 'Pointer yang menunjuk ke memori yang sudah dibebaskan', true, 1),
  (8, 'B', 'Pointer yang bernilai nullptr', false, 2),
  (8, 'C', 'Pointer yang tidak diinisialisasi', false, 3),
  (8, 'D', 'Pointer yang menunjuk array', false, 4),
  (9, 'A', 'Memanggil delete dua kali pada pointer yang sama', true, 1),
  (9, 'B', 'Menghapus dua elemen sekaligus', false, 2),
  (9, 'C', 'Menghapus array dengan delete biasa', false, 3),
  (9, 'D', 'Menghapus pointer yang belum dialokasikan', false, 4),
  (10, 'A', 'Mencegah dangling pointer dan membuat delete kedua aman', true, 1),
  (10, 'B', 'Agar memori lebih cepat dibebaskan', false, 2),
  (10, 'C', 'Agar compiler tidak memberi peringatan', false, 3),
  (10, 'D', 'Karena delete memerlukan nilai nullptr', false, 4),
  (11, 'A', 'Pointer yang membebaskan memori otomatis', true, 1),
  (11, 'B', 'Pointer yang lebih cepat diakses', false, 2),
  (11, 'C', 'Pointer yang tidak bisa diubah', false, 3),
  (11, 'D', 'Pointer yang menyimpan dua alamat', false, 4),
  (12, 'A', 'Smart pointer dengan kepemilikan tunggal', true, 1),
  (12, 'B', 'Smart pointer dengan kepemilikan bersama', false, 2),
  (12, 'C', 'Pointer yang tidak bisa dipindahkan', false, 3),
  (12, 'D', 'Pointer untuk array saja', false, 4),
  (13, 'A', 'Karena kepemilikannya tunggal - kalau disalin akan menyebabkan double free', true, 1),
  (13, 'B', 'Karena penyalinan terlalu lambat', false, 2),
  (13, 'C', 'Karena compiler belum mendukungnya', false, 3),
  (13, 'D', 'Karena unique_ptr tidak punya konstruktor salinan di C++17', false, 4),
  (14, 'A', '7 1', true, 1),
  (14, 'B', '7 0', false, 2),
  (14, 'C', '0 1', false, 3),
  (14, 'D', 'Error', false, 4),
  (15, 'A', 'Smart pointer dengan kepemilikan bersama, dibebaskan saat penghitung mencapai nol', true, 1),
  (15, 'B', 'Smart pointer dengan kepemilikan tunggal', false, 2),
  (15, 'C', 'Pointer yang menunjuk beberapa objek', false, 3),
  (15, 'D', 'Pointer yang dipakai bersama thread', false, 4),
  (16, 'A', '1 2 1', true, 1),
  (16, 'B', '1 1 1', false, 2),
  (16, 'C', '1 2 2', false, 3),
  (16, 'D', '2 2 1', false, 4),
  (17, 'A', 'auto arr = make_unique<int[]>(3);', true, 1),
  (17, 'B', 'auto arr = make_unique<int>(3);', false, 2),
  (17, 'C', 'auto arr = new unique_ptr<int>(3);', false, 3),
  (17, 'D', 'unique_ptr tidak bisa untuk array', false, 4),
  (18, 'A', 'Saat beberapa bagian kode perlu memiliki objek yang sama', true, 1),
  (18, 'B', 'Saat ingin lebih cepat', false, 2),
  (18, 'C', 'Saat objeknya kecil', false, 3),
  (18, 'D', 'Selalu, karena lebih aman', false, 4),
  (19, 'A', 'Karena menghilangkan memory leak, dangling pointer, dan double free sekaligus', true, 1),
  (19, 'B', 'Karena smart pointer lebih cepat', false, 2),
  (19, 'C', 'Karena smart pointer memakai memori lebih sedikit', false, 3),
  (19, 'D', 'Karena C++ tidak lagi mendukung new/delete', false, 4),
  (20, 'A', 'Otomatis dengan reference counting, plus garbage collector untuk siklus referensi', true, 1),
  (20, 'B', 'Manual dengan new dan delete', false, 2),
  (20, 'C', 'Hanya dengan garbage collector', false, 3),
  (20, 'D', 'Dengan smart pointer', false, 4),
  (21, 'A', 'Dua objek yang saling menunjuk sehingga penghitung referensinya tidak pernah nol', true, 1),
  (21, 'B', 'Objek yang terlalu besar untuk dibebaskan', false, 2),
  (21, 'C', 'Objek yang tidak punya referensi', false, 3),
  (21, 'D', 'Objek yang dibuat di dalam fungsi', false, 4),
  (22, 'A', 'Tidak sepenuhnya - siklus referensi, cache tak terbatas, dan referensi global tetap bisa bocor', true, 1),
  (22, 'B', 'Ya, Python sepenuhnya bebas masalah memori', false, 2),
  (22, 'C', 'Tidak, karena Python tidak punya garbage collector', false, 3),
  (22, 'D', 'Ya, karena Python tidak mengalokasikan memori', false, 4)
) as v(urutan_soal, label, teks, benar, urutan)
  on v.urutan_soal = s.urutan
where m.slug = 'pointer-dinamis';
