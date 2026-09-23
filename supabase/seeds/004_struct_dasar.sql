-- =========================================================
-- Seed: Modul 4 — struct-dasar
-- Mendefinisikan Struct
--
-- Semua contoh kode DIKOMPILASI dan DIJALANKAN.
-- Platform: GCC 16.2.1, x86-64
-- =========================================================

insert into public.modul (slug, judul, topik, deskripsi, estimasi_menit, urutan)
values (
  'struct-dasar',
  'Mendefinisikan Struct',
  'struct',
  'Mengelompokkan data bertipe berbeda jadi satu kesatuan, plus padanannya di Python.',
  11,
  4
);

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

Tipe anggotanya **boleh berbeda-beda** — inilah yang membedakan struct dari array yang harus bertipe seragam.

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
| `void f(const Titik& t)` | **Paling umum** — hanya membaca, tidak menyalin |

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

Tanpa `@dataclass`, kelas ini hanya anotasi tipe — tidak ada `__init__` yang menerima argumen.

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

-- ============ FLASHCARD (10 kartu) ============
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

-- ============ SOAL QUIZ (10 soal) ============
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

-- ============ OPSI JAWABAN (40 opsi) ============
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
