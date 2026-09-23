-- =========================================================
-- Seed: Modul 6 — struct-memori
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

Kalau `int b` diletakkan pada offset 1, CPU perlu membaca dua blok dan menggabungkan hasilnya — jauh lebih lambat.

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

**Tapi hati-hati — saran ini TIDAK selalu benar.**

## Bukti Pengukuran

Mari bandingkan pada GCC 16.2.1, x86-64:

| Struct | sizeof | Hemat? |
|--------|--------|--------|
| `{char a; int b;}` | **8** | — |
| `{int b; char a;}` | **8** | **TIDAK hemat!** |
| `{char a; long b; char c;}` | **24** | — |
| `{long b; char a; char c;}` | **16** | Hemat 8 byte |
| `{char a; int b; short c;}` | **12** | — |
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
> 1. **Lebih lambat** — CPU harus membaca beberapa blok dan menggabungkan
> 2. **Tidak portabel** — perilaku berbeda antar compiler
> 3. **Bahaya pada ARM** — akses tidak selaras bisa menyebabkan crash
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

Padding diisi dengan apa saja — sisa data lama di memori, nilai nol, atau apa pun. Standar C++ **tidak menentukan** isinya.

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
> Untuk serialisasi, gunakan format yang tidak bergantung layout memori — misalnya JSON, Protocol Buffers, atau tulis setiap anggota satu per satu dengan urutan yang disepakati.$md$, 4),

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

-- ============ FLASHCARD (10 kartu) ============
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

-- ============ SOAL QUIZ (10 soal) ============
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

-- ============ OPSI JAWABAN (40 opsi) ============
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
