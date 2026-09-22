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

## Contoh 1: char, int

```cpp
struct A { char a; int b; };
```

| Anggota | Alignment | Offset | Keterangan |
|---------|-----------|--------|------------|
| `a` | 1 | 0 | mulai di 0, ok |
| `b` | 4 | **4** | harus kelipatan 4; setelah `a` di 1, dibulatkan ke 4 |

Padding: offset 1-3 (3 byte). Total: 4 + 4 = **8 byte**.

## Contoh 2: char, long, char

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

## Contoh 3: long, char, char

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

## Cara 1: Mengurutkan Anggota

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

## Cara 2: #pragma pack

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

## Cara 3: Verifikasi Sendiri

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

-- KARTU (22 kartu)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values

('Berapa sizeof(struct { char a; int b; }) jika sizeof(int)=4?',
 E'8 byte, bukan 5.\n\n1 (char) + 3 (padding) + 4 (int) = 8\n\nPadding 3 byte muncul agar int b dimulai\npada offset yang merupakan kelipatan 4.',
 'MEMORI', 'struct Campur { char a; int b; };\ncout << sizeof(Campur);  // 8', 'cpp', 1),

('Apa itu padding pada struct?',
 E'Byte KOSONG yang disisipkan compiler di antara anggota struct\nagar setiap anggota dimulai pada alamat yang sesuai alignment-nya.\n\nPadding TIDAK berisi data apa pun - isinya nilai tak tentu.',
 'ISTILAH', null, null, 2),

('Mengapa padding diperlukan?',
 E'Karena CPU membaca memori dalam BLOK (biasanya 4 atau 8 byte),\nbukan byte demi byte.\n\nKalau int diletakkan pada offset 1, CPU perlu membaca dua blok\ndan menggabungkan hasilnya - jauh lebih lambat.\n\nDengan alignment, CPU bisa membaca dalam SATU operasi.',
 'MEMORI', null, null, 3),

('Bagaimana cara memeriksa offset anggota struct?',
 E'Pakai offsetof dari <cstddef>:\n\n#include <cstddef>\n\nstruct Campur { char a; int b; };\n\ncout << offsetof(Campur, a);   // 0\ncout << offsetof(Campur, b);   // 4',
 'SINTAKS', '#include <cstddef>\ncout << offsetof(Campur, b);  // 4', 'cpp', 4),

('Apa aturan alignment untuk anggota struct?',
 E'Setiap anggota harus dimulai pada alamat yang merupakan\nKELIPATAN alignment-nya.\n\nAlignment biasanya sama dengan ukuran tipe:\nchar=1, short=2, int=4, long=8, pointer=8\n\nSelain itu, total ukuran struct dibulatkan ke kelipatan\nalignment TERBESAR di antara anggotanya.',
 'MEMORI', null, null, 5),

('Berapa sizeof(struct { char a; long b; char c; })?',
 E'24 byte.\n\nOffset: a=0, b=8 (butuh kelipatan 8), c=16\nTotal sebelum pembulatan: 17\nAlignment terbesar: 8\nDibulatkan ke kelipatan 8 -> 24\n\nRincian: 1 + 7 pad + 8 + 1 + 7 pad akhir = 24',
 'MEMORI', 'struct B { char a; long b; char c; };\ncout << sizeof(B);  // 24', 'cpp', 6),

('Berapa sizeof(struct { long b; char a; char c; })?',
 E'16 byte.\n\nOffset: b=0, a=8, c=9\nTotal: 10\nDibulatkan ke kelipatan 8 -> 16\n\nHEMAT 8 byte dibanding {char, long, char}!\n\nIni contoh pengurutan yang BERHASIL menghemat.',
 'MEMORI', 'struct C { long b; char a; char c; };\ncout << sizeof(C);  // 16', 'cpp', 7),

('Apakah mengurutkan anggota struct SELALU mengurangi padding?',
 E'TIDAK.\n\n{char a; int b;} = 8 byte\n{int b; char a;} = 8 byte\n\nSAMA! Pengurutan tidak membantu pada struct 2 anggota.\n\nPengurutan baru membantu kalau ada BEBERAPA anggota kecil\nyang bisa dikemas berdampingan.',
 'JEBAKAN', null, null, 8),

('Apa aturan yang lebih akurat tentang mengurangi padding?',
 E'Padding berkurang ketika anggota-anggota kecil dikelompokkan\nberdampingan sehingga mereka muat dalam satu blok alignment.\n\nIni BIASANYA tercapai dengan mengurutkan dari besar ke kecil,\ntetapi BUKAN JAMINAN.\n\nPada struct 2 anggota, pengurutan sering tidak mengubah apa pun.',
 'MEMORI', null, null, 9),

('Bagaimana cara mengurangi padding dengan #pragma pack?',
 E'#pragma pack(push, 1)\nstruct Padat {\n    char a;\n    int b;\n};\n#pragma pack(pop)\n\nDengan pack(1), sizeof(Padat) menjadi 5 byte.\n\nBAHAYA: lebih lambat, tidak portabel, dan bisa crash di ARM.',
 'SINTAKS', '#pragma pack(push, 1)\nstruct Padat { char a; int b; };\n#pragma pack(pop)', 'cpp', 10),

('Apa risiko memakai #pragma pack(1)?',
 E'1. LEBIH LAMBAT - CPU harus membaca beberapa blok dan menggabungkan\n2. TIDAK PORTABEL - perilaku berbeda antar compiler\n3. BAHAYA DI ARM - akses tidak selaras bisa menyebabkan crash\n\nGunakan hanya kalau benar-benar perlu,\nmisalnya untuk protokol jaringan atau format biner tertentu.',
 'JEBAKAN', null, null, 11),

('Mengapa struct TIDAK boleh dibandingkan dengan memcmp?',
 E'Karena padding berisi nilai TAK TENTU.\n\nmemcmp membandingkan SELURUH byte termasuk padding.\nDua struct dengan data identik bisa dianggap BERBEDA\nkalau padding-nya berbeda.\n\nBandingkan anggota satu per satu, atau pakai\noperator== default (C++20).',
 'JEBAKAN', null, null, 12),

('Bagaimana cara membandingkan dua struct dengan benar?',
 E'Bandingkan anggota satu per satu:\n\nbool sama(const Titik& a, const Titik& b) {\n    return a.x == b.x && a.y == b.y;\n}\n\nAtau di C++20, pakai operator== default:\n\nstruct Titik {\n    int x, y;\n    bool operator==(const Titik&) const = default;\n};',
 'SINTAKS', 'struct Titik {\n    int x, y;\n    bool operator==(const Titik&) const = default;\n};', 'cpp', 13),

('Apa bahaya menulis struct langsung ke berkas?',
 E'Byte padding yang isinya tak tentu IKUT TERTULIS.\n\nKalau berkas dibaca di platform lain dengan aturan alignment\nberbeda, hasilnya bisa kacau.\n\nSolusi: gunakan format yang tidak bergantung layout memori\n(JSON, Protocol Buffers), atau tulis setiap anggota\nsatu per satu dengan urutan yang disepakati.',
 'JEBAKAN', null, null, 14),

('Apakah alignment struct sama di semua platform?',
 E'TIDAK - alignment bersifat IMPLEMENTATION-DEFINED.\n\nAngka seperti sizeof(int)=4, sizeof(long)=8 berlaku untuk\nx86-64. Di platform lain (ARM, embedded) bisa BERBEDA.\n\nSelalu verifikasi dengan sizeof dan offsetof\ndi platform yang kamu pakai.',
 'MEMORI', null, null, 15),

('Bagaimana cara memverifikasi padding di platform sendiri?',
 E'Ukur langsung, jangan menghafal:\n\n#include <cstddef>\n#include <iostream>\nusing namespace std;\n\nstruct A2 { char a; int b; };\nstruct B2 { int b; char a; };\n\ncout << sizeof(A2) << " " << sizeof(B2) << "\\n";\ncout << offsetof(A2, a) << " " << offsetof(A2, b) << "\\n";',
 'SINTAKS', 'cout << sizeof(A2) << " " << sizeof(B2) << "\\n";\ncout << offsetof(A2, a) << " " << offsetof(A2, b) << "\\n";', 'cpp', 16),

('Berapa sizeof(struct { int x; int y; })?',
 E'8 byte (4 + 4).\n\nTIDAK ada padding karena kedua anggota berukuran sama (4 byte).\n\nPadding hanya muncul saat ukuran anggota BERBEDA-BEDA.',
 'TRACING', 'struct Titik { int x; int y; };\ncout << sizeof(Titik);  // 8', 'cpp', 17),

('Berapa sizeof(struct { int x; int y; int z; })?',
 E'12 byte (4 + 4 + 4).\n\nTidak ada padding - semua anggota berukuran sama\ndan sudah selaras.',
 'TRACING', 'struct Titik3D { int x, y, z; };\ncout << sizeof(Titik3D);  // 12', 'cpp', 18),

('Apakah Python punya padding seperti C++?',
 E'TIDAK, karena objek Python disimpan sebagai REFERENSI,\nbukan nilai berurutan.\n\nUntuk data biner, Python punya modul struct:\n\nimport struct\ndata = struct.pack("bi", 65, 100)\nprint(len(data))   # 5 byte (tanpa padding)\n\nModul struct secara default TIDAK menambahkan padding.',
 'BANDING', null, null, 19),

('Bagaimana cara membuat padding eksplisit di Python?',
 E'Pakai prefix @ atau = pada format string:\n\nimport struct\n\n# Tanpa padding (default untuk jaringan)\nstruct.pack("bi", 65, 100)     # 5 byte\n\n# Dengan alignment native\nstruct.pack("@bi", 65, 100)    # 8 byte (ada padding)',
 'SINTAKS', 'struct.pack("@bi", 65, 100)  # 8 byte dengan padding', 'python', 20),

('Kapan padding struct perlu diperhatikan?',
 E'1. Saat menghitung ukuran array of struct\n2. Saat serialisasi data (tulis ke berkas, kirim jaringan)\n3. Saat berinteraksi dengan perangkat keras\n4. Saat membaca data biner dari program C lain\n\nUntuk aplikasi biasa, padding TIDAK perlu dipikirkan -\ncukup gunakan sizeof kalau butuh ukuran.',
 'KAPAN', null, null, 21),

('Mengapa struct {int,int} TIDAK punya padding?',
 E'Karena kedua anggota berukuran SAMA (4 byte) dan\nalignment-nya juga sama.\n\nTidak ada anggota kecil yang perlu "dikemas" atau disisipkan\nbyte kosong.\n\nPadding muncul saat ukuran anggota berbeda-beda,\nseperti char (1 byte) di samping int (4 byte).',
 'MEMORI', null, null, 22)

) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'struct-memori';

-- SOAL (20 soal)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values

('Berapa sizeof(struct { char a; int b; }) jika sizeof(int) = 4?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: 8 byte\n\n1 (char) + 3 (padding) + 4 (int) = 8.\n\nPengecoh 5 = menjumlahkan tanpa memperhitungkan padding.\nPengecoh 4 = hanya ukuran int. Pengecoh 12 = salah hitung alignment.',
 1),

('Mengapa padding diperlukan dalam struct?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Agar setiap anggota dimulai pada alamat yang selaras, sehingga CPU bisa membacanya dalam satu operasi.\n\nCPU membaca memori dalam blok (4 atau 8 byte), bukan byte demi byte. Kalau int diletakkan pada offset tidak selaras, CPU perlu dua operasi baca dan menggabungkannya - jauh lebih lambat.\n\nPengecoh "untuk menghemat memori" salah - padding justru MEMBUANG memori demi kecepatan.',
 2),

(E'struct Campur { char a; int b; };\ncout << offsetof(Campur, b);\n\nBerapa outputnya jika sizeof(int)=4?',
 'struct Campur { char a; int b; };\ncout << offsetof(Campur, b);',
 'cpp', 'TRACE', 'MEMORI',
 E'Output: 4\n\nb harus dimulai pada offset yang merupakan kelipatan 4 (alignment int).\nSetelah char a di offset 0, offset berikutnya adalah 1.\nDibulatkan ke kelipatan 4 -> 4.\n\nTiga byte di offset 1-3 adalah padding.',
 3),

('Apa aturan alignment untuk anggota struct?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Setiap anggota harus dimulai pada alamat yang merupakan kelipatan alignment-nya.\n\nSelain itu, total ukuran struct dibulatkan ke kelipatan alignment terbesar di antara anggotanya.\n\nContoh: struct {char a; long b; char c;} -> alignment terbesar 8, total 17 dibulatkan jadi 24.',
 4),

('Berapa sizeof(struct { char a; long b; char c; })?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: 24 byte\n\nOffset: a=0, b=8 (butuh kelipatan 8), c=16.\nTotal sebelum pembulatan: 17.\nAlignment terbesar = 8, dibulatkan ke 24.\n\nRincian: 1 + 7 padding + 8 + 1 + 7 padding akhir = 24.\n\nPengecoh 10 = 1+8+1 tanpa padding. Pengecoh 16 = lupa padding setelah c.',
 5),

(E'struct A { char a; long b; char c; };\nstruct B { long b; char a; char c; };\n\ncout << sizeof(A) << " " << sizeof(B);\n\nApa outputnya?',
 'struct A { char a; long b; char c; };\nstruct B { long b; char a; char c; };\ncout << sizeof(A) << " " << sizeof(B);',
 'cpp', 'TRACE', 'MEMORI',
 E'Output: 24 16\n\nA: a=0, b=8, c=16 -> total 17 dibulatkan ke 24\nB: b=0, a=8, c=9  -> total 10 dibulatkan ke 16\n\nB menghemat 8 byte karena anggota kecil (a dan c) dikelompokkan berdampingan.\n\nIni contoh pengurutan yang BERHASIL menghemat.',
 6),

('Apakah mengurutkan anggota struct selalu mengurangi padding?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: TIDAK selalu.\n\n{char a; int b;} = 8 byte\n{int b; char a;} = 8 byte\n\nKeduanya SAMA. Pengurutan tidak mengubah apa pun pada struct dengan 2 anggota.\n\nPengurutan baru membantu kalau ada BEBERAPA anggota kecil yang bisa dikemas berdampingan.\n\nIni penting: aturan "urutkan dari besar ke kecil" adalah penyederhanaan yang tidak selalu berlaku.',
 7),

('Apa aturan yang lebih akurat tentang mengurangi padding?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Padding berkurang ketika anggota kecil dikelompokkan berdampingan sehingga muat dalam satu blok alignment.\n\nIni BIASANYA tercapai dengan mengurutkan dari besar ke kecil, tetapi BUKAN JAMINAN.\n\nPada struct dengan hanya 2 anggota, pengurutan sering tidak mengubah apa pun karena tidak ada anggota kecil yang bisa dikemas bersama.',
 8),

('Apa yang dilakukan #pragma pack(1)?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Memaksa compiler mengurangi atau menghilangkan padding.\n\n#pragma pack(push, 1)\nstruct Padat { char a; int b; };\n#pragma pack(pop)\n\nDengan pack(1), sizeof(Padat) menjadi 5 byte (bukan 8).\n\nTapi ada konsekuensi serius: lebih lambat, tidak portabel, dan bisa crash di ARM.',
 9),

('Apa risiko memakai #pragma pack(1)?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Lebih lambat, tidak portabel, dan bisa crash di ARM.\n\n1. LEBIH LAMBAT - CPU harus membaca beberapa blok dan menggabungkan\n2. TIDAK PORTABEL - perilaku berbeda antar compiler\n3. BAHAYA DI ARM - akses tidak selaras bisa menyebabkan crash\n\nGunakan hanya kalau benar-benar perlu (protokol jaringan, format biner tertentu).',
 10),

('Mengapa struct TIDAK boleh dibandingkan dengan memcmp?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena padding berisi nilai tak tentu, sehingga dua struct dengan data identik bisa dianggap berbeda.\n\nmemcmp membandingkan SELURUH byte termasuk padding. Standar C++ tidak menentukan isi padding - bisa nilai nol, sisa data lama, atau apa pun.\n\nBandingkan anggota satu per satu, atau pakai operator== default (C++20).',
 11),

('Bagaimana cara membandingkan dua struct dengan benar?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Bandingkan anggota satu per satu, atau pakai operator== default C++20.\n\nbool sama(const Titik& a, const Titik& b) {\n    return a.x == b.x && a.y == b.y;\n}\n\nAtau:\nstruct Titik {\n    int x, y;\n    bool operator==(const Titik&) const = default;\n};\n\nmemcmp salah karena ikut membandingkan padding.',
 12),

('Apa bahaya menulis struct langsung ke berkas?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Byte padding yang isinya tak tentu ikut tertulis, sehingga data bisa kacau saat dibaca di platform lain.\n\nberkas.write((char*)&x, sizeof(Campur));\n\nYang tertulis termasuk padding. Kalau dibaca di platform dengan aturan alignment berbeda, layout-nya tidak cocok.\n\nSolusi: gunakan JSON, Protocol Buffers, atau tulis setiap anggota satu per satu.',
 13),

('Apakah alignment struct sama di semua platform?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: TIDAK - alignment bersifat implementation-defined.\n\nAngka seperti sizeof(int)=4 dan sizeof(long)=8 berlaku untuk x86-64. Di platform lain (ARM, embedded) bisa berbeda.\n\nKarena itu, jangan hafalkan angka padding. Selalu verifikasi dengan sizeof dan offsetof di platform yang kamu pakai.',
 14),

(E'struct Titik { int x; int y; };\ncout << sizeof(Titik);\n\nBerapa outputnya?',
 'struct Titik { int x; int y; };\ncout << sizeof(Titik);',
 'cpp', 'TRACE', 'MEMORI',
 E'Output: 8\n\n4 + 4 = 8, TANPA padding.\n\nKedua anggota berukuran sama (4 byte) dan alignment-nya juga sama.\nTidak ada anggota kecil yang perlu dikemas atau disisipkan byte kosong.\n\nPadding hanya muncul saat ukuran anggota BERBEDA-BEDA.',
 15),

('Bagaimana cara memverifikasi padding di platform sendiri?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: Ukur langsung dengan sizeof dan offsetof.\n\n#include <cstddef>\nstruct A2 { char a; int b; };\nstruct B2 { int b; char a; };\n\ncout << sizeof(A2) << " " << sizeof(B2) << "\\n";\ncout << offsetof(A2, a) << " " << offsetof(A2, b) << "\\n";\n\nIni jauh lebih berharga daripada menghafal aturan yang tidak selalu berlaku.',
 16),

('Apakah Python punya padding seperti C++?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Tidak, karena objek Python disimpan sebagai referensi, bukan nilai berurutan.\n\nUntuk data biner, Python punya modul struct:\n\nimport struct\ndata = struct.pack("bi", 65, 100)\nprint(len(data))   # 5 byte, tanpa padding\n\nModul struct secara default TIDAK menambahkan padding - berbeda dari C++ yang menambah otomatis.',
 17),

(E'import struct\nprint(len(struct.pack("bi", 65, 100)))',
 'import struct\nprint(len(struct.pack("bi", 65, 100)))',
 'python', 'TRACE', 'MEMORI',
 E'Output: 5\n\nFormat "bi" = signed char (1 byte) + int (4 byte) = 5 byte.\n\nModul struct Python TIDAK menambahkan padding secara default.\n\nKalau ingin padding seperti C++, gunakan prefix @:\nstruct.pack("@bi", 65, 100)  # 8 byte',
 18),

('Kapan padding struct perlu diperhatikan?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: Saat menghitung ukuran array of struct, serialisasi data, berinteraksi dengan perangkat keras, atau membaca data biner dari program C.\n\nUntuk aplikasi Python atau C++ biasa, padding TIDAK perlu dipikirkan - cukup pakai sizeof kalau butuh ukuran.\n\nYang penting: jangan membandingkan struct dengan memcmp, dan jangan kirim struct mentah antar platform.',
 19),

('Mengapa struct {int, int} tidak punya padding?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena kedua anggota berukuran sama (4 byte) dan alignment-nya juga sama.\n\nTidak ada anggota kecil yang perlu dikemas atau disisipkan byte kosong. Setiap anggota sudah selaras secara alami.\n\nPadding muncul saat ukuran anggota berbeda, seperti char (1 byte) di samping int (4 byte) - int harus mulai pada kelipatan 4, sehingga 3 byte dilewati.',
 20)

) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'struct-memori';

insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', '5', false, 1),
  (1, 'B', '8', true, 2),
  (1, 'C', '4', false, 3),
  (1, 'D', '12', false, 4),
  (2, 'A', 'Agar setiap anggota dimulai pada alamat selaras sehingga CPU bisa membacanya dalam satu operasi', true, 1),
  (2, 'B', 'Untuk menghemat penggunaan memori', false, 2),
  (2, 'C', 'Untuk memudahkan compiler membaca kode', false, 3),
  (2, 'D', 'Untuk mencegah akses tidak sah', false, 4),
  (3, 'A', '1', false, 1),
  (3, 'B', '4', true, 2),
  (3, 'C', '5', false, 3),
  (3, 'D', '8', false, 4),
  (4, 'A', 'Setiap anggota harus dimulai pada alamat kelipatan alignment-nya', true, 1),
  (4, 'B', 'Setiap anggota harus berukuran sama', false, 2),
  (4, 'C', 'Anggota harus diurutkan dari kecil ke besar', false, 3),
  (4, 'D', 'Total struct harus kelipatan 4', false, 4),
  (5, 'A', '10', false, 1),
  (5, 'B', '16', false, 2),
  (5, 'C', '24', true, 3),
  (5, 'D', '32', false, 4),
  (6, 'A', '24 16', true, 1),
  (6, 'B', '16 24', false, 2),
  (6, 'C', '24 24', false, 3),
  (6, 'D', '10 10', false, 4),
  (7, 'A', 'Tidak selalu - pada struct 2 anggota hasilnya sering sama', true, 1),
  (7, 'B', 'Ya, selalu mengurangi padding', false, 2),
  (7, 'C', 'Ya, tapi hanya pada struct dengan 2 anggota', false, 3),
  (7, 'D', 'Tidak pernah mengurangi padding', false, 4),
  (8, 'A', 'Padding berkurang ketika anggota kecil dikelompokkan berdampingan, biasanya tercapai dengan mengurutkan', true, 1),
  (8, 'B', 'Padding selalu berkurang dengan mengurutkan dari besar ke kecil', false, 2),
  (8, 'C', 'Padding tidak bisa dikurangi dengan cara apa pun', false, 3),
  (8, 'D', 'Padding berkurang dengan menambah anggota', false, 4),
  (9, 'A', 'Memaksa compiler mengurangi atau menghilangkan padding', true, 1),
  (9, 'B', 'Mengurutkan anggota secara otomatis', false, 2),
  (9, 'C', 'Menambah padding agar alignment lebih baik', false, 3),
  (9, 'D', 'Mengubah tipe anggota agar seragam', false, 4),
  (10, 'A', 'Lebih lambat, tidak portabel, dan bisa crash di ARM', true, 1),
  (10, 'B', 'Struct tidak bisa dikompilasi', false, 2),
  (10, 'C', 'Anggota struct tidak bisa diakses', false, 3),
  (10, 'D', 'Struct tidak bisa disalin', false, 4),
  (11, 'A', 'Padding berisi nilai tak tentu, sehingga struct dengan data sama bisa dianggap berbeda', true, 1),
  (11, 'B', 'memcmp tidak mendukung struct', false, 2),
  (11, 'C', 'memcmp terlalu lambat untuk struct besar', false, 3),
  (11, 'D', 'memcmp hanya bisa membandingkan tipe primitif', false, 4),
  (12, 'A', 'Bandingkan anggota satu per satu, atau pakai operator== default C++20', true, 1),
  (12, 'B', 'Pakai memcmp dengan ukuran yang tepat', false, 2),
  (12, 'C', 'Bandingkan alamat memorinya', false, 3),
  (12, 'D', 'Konversi ke string lalu bandingkan', false, 4),
  (13, 'A', 'Byte padding yang isinya tak tentu ikut tertulis, data bisa kacau di platform lain', true, 1),
  (13, 'B', 'Struct tidak bisa ditulis ke berkas', false, 2),
  (13, 'C', 'Berkas menjadi terlalu besar', false, 3),
  (13, 'D', 'Program akan crash saat menulis', false, 4),
  (14, 'A', 'Tidak - alignment bersifat implementation-defined, bisa berbeda antar platform', true, 1),
  (14, 'B', 'Ya, sama di semua platform', false, 2),
  (14, 'C', 'Ya, karena diatur standar C++', false, 3),
  (14, 'D', 'Sama untuk semua compiler tetapi berbeda antar OS', false, 4),
  (15, 'A', '4', false, 1),
  (15, 'B', '8', true, 2),
  (15, 'C', '12', false, 3),
  (15, 'D', '16', false, 4),
  (16, 'A', 'Ukur langsung dengan sizeof dan offsetof', true, 1),
  (16, 'B', 'Hafalkan aturan alignment setiap tipe', false, 2),
  (16, 'C', 'Baca dokumentasi compiler saja', false, 3),
  (16, 'D', 'Asumsikan sama seperti x86-64', false, 4),
  (17, 'A', 'Tidak, karena objek Python disimpan sebagai referensi bukan nilai berurutan', true, 1),
  (17, 'B', 'Ya, sama seperti C++', false, 2),
  (17, 'C', 'Ya, tetapi hanya untuk dataclass', false, 3),
  (17, 'D', 'Ya, tetapi padding-nya selalu nol', false, 4),
  (18, 'A', '5', true, 1),
  (18, 'B', '8', false, 2),
  (18, 'C', '4', false, 3),
  (18, 'D', 'Error', false, 4),
  (19, 'A', 'Saat menghitung ukuran array of struct, serialisasi, atau membaca data biner dari program C', true, 1),
  (19, 'B', 'Setiap kali mendefinisikan struct', false, 2),
  (19, 'C', 'Saat struct punya lebih dari 5 anggota', false, 3),
  (19, 'D', 'Saat memakai pointer ke struct', false, 4),
  (20, 'A', 'Karena kedua anggota berukuran sama dan alignment-nya juga sama', true, 1),
  (20, 'B', 'Karena int tidak memerlukan alignment', false, 2),
  (20, 'C', 'Karena compiler mengoptimalkan struct kecil', false, 3),
  (20, 'D', 'Karena struct dengan 2 anggota selalu tanpa padding', false, 4)
) as v(urutan_soal, label, teks, benar, urutan)
  on v.urutan_soal = s.urutan
where m.slug = 'struct-memori';
