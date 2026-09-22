-- =========================================================
-- Seed: Modul 5 — struct-nested
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

Gunakan **dua titik** — satu untuk setiap level:

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

-- KARTU (20 kartu)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values

('Apa itu nested struct?',
 E'Struct yang salah satu anggotanya bertipe struct lain.\n\nstruct Alamat { string kota; };\nstruct Mahasiswa {\n    string nama;\n    Alamat alamat;   <- struct sebagai anggota\n};',
 'ISTILAH', null, null, 1),

('Bagaimana cara menginisialisasi nested struct?',
 E'Mahasiswa m = {"Rani", 20, {"Bandung", "40123"}};\n\nPerhatikan kurung kurawal BERSARANG:\n{"Bandung", "40123"} adalah nilai untuk alamat.',
 'SINTAKS', 'Mahasiswa m = {"Rani", 20, {"Bandung", "40123"}};', 'cpp', 2),

('Bagaimana cara mengakses anggota nested struct?',
 E'Pakai DUA TITIK - satu untuk setiap level:\n\nm.alamat.kota\n\nCara membaca: m punya alamat, dan alamat punya kota.\n\nURUTAN PENTING: dari luar ke dalam.',
 'SINTAKS', 'cout << m.alamat.kota;', 'cpp', 3),

('Apa yang salah dari m.kota.alamat?',
 E'URUTAN AKSES TERTUKAR.\n\nm.kota.alamat salah karena m tidak punya anggota kota.\n\nYang benar: m.alamat.kota\nm (luar) -> alamat (tengah) -> kota (dalam)',
 'JEBAKAN', null, null, 4),

('Bagaimana cara mendeklarasikan array of struct?',
 E'Barang daftar[3] = {\n    {"Buku", 25000},\n    {"Pulpen", 3000},\n    {"Tas", 150000}\n};\n\nSetiap elemen adalah struct lengkap.',
 'SINTAKS', 'Barang daftar[3] = {{"Buku", 25000}, {"Pulpen", 3000}};', 'cpp', 5),

('Bagaimana cara mengiterasi array of struct?',
 E'for (int i = 0; i < 3; i++) {\n    cout << daftar[i].nama;\n    cout << daftar[i].harga;\n}\n\nAkses anggota tiap elemen dengan operator titik.',
 'SINTAKS', 'for (int i = 0; i < 3; i++) {\n    cout << daftar[i].nama;\n}', 'cpp', 6),

('Bagaimana cara mengurutkan array of struct berdasarkan satu field?',
 E'Pakai std::sort dengan lambda pembanding:\n\nsort(kelas, kelas + 3, [](const Kelas& a, const Kelas& b) {\n    return a.ipk > b.ipk;   // menurun\n});\n\nUbah > jadi < untuk menaik.',
 'SINTAKS', 'sort(kelas, kelas + 3, [](const Kelas& a, const Kelas& b) {\n    return a.ipk > b.ipk;\n});', 'cpp', 7),

('Apa perbedaan array of struct dan struct of array?',
 E'Array of Struct (AoS):\nstruct Mhs { string nama; double ipk; };\nMhs daftar[100];\n-> satu objek utuh, data berdekatan\n\nStruct of Array (SoA):\nstruct Daftar { string nama[100]; double ipk[100]; };\n-> satu field untuk semua objek\n\nAoS lebih mudah dibaca - direkomendasikan.',
 'BANDING', null, null, 8),

('Apa padanan array of struct di Python?',
 E'List of dataclass:\n\ndaftar = [\n    Mahasiswa("Rani", 20, Alamat("Bandung", "40123")),\n    Mahasiswa("Budi", 21, Alamat("Jakarta", "10110")),\n]',
 'SINTAKS', 'daftar = [Mahasiswa("Rani", 20), Mahasiswa("Budi", 21)]', 'python', 9),

('Bagaimana cara mengurutkan list of dataclass di Python?',
 E'Pakai sorted() dengan key:\n\nterurut = sorted(kelas, key=lambda k: k.ipk, reverse=True)\n\nreverse=True untuk urutan menurun.\nTanpa reverse, urutan menaik (default).',
 'SINTAKS', 'terurut = sorted(kelas, key=lambda k: k.ipk, reverse=True)', 'python', 10),

(E'struct Alamat { string kota; string kodePos; };\nstruct Mahasiswa { string nama; Alamat alamat; };\n\nMahasiswa m = {"Rani", {"Bandung", "40123"}};\ncout << m.alamat.kota;\n\nApa outputnya?',
 E'Output: Bandung\n\nm.alamat.kota mengakses:\n- m (struct Mahasiswa)\n- .alamat (struct Alamat di dalamnya)\n- .kota (string di dalam alamat)\n\n"Bandung" adalah nilai kota, "40123" adalah kodePos.',
 'TRACING', 'struct Alamat { string kota; string kodePos; };\nstruct Mahasiswa { string nama; Alamat alamat; };\nMahasiswa m = {"Rani", {"Bandung", "40123"}};\ncout << m.alamat.kota;', 'cpp', 11),

(E'struct Alamat { string kota; };\nstruct Mahasiswa { string nama; Alamat alamat; };\n\nMahasiswa a = {"Rani", {"Bandung"}};\nMahasiswa b = a;\nb.alamat.kota = "Jakarta";\ncout << a.alamat.kota;\n\nApa outputnya?',
 E'Output: Bandung\n\nb = a membuat SALINAN LENGKAP, termasuk struct alamat di dalamnya.\nMengubah b.alamat.kota tidak mempengaruhi a.\n\nStruct bersarang disalin seluruhnya, bukan hanya sebagian.',
 'TRACING', 'Mahasiswa a = {"Rani", {"Bandung"}};\nMahasiswa b = a;\nb.alamat.kota = "Jakarta";\ncout << a.alamat.kota;', 'cpp', 12),

(E'struct Mahasiswa { string nama; Alamat alamat; };\nMahasiswa m = {"Rani", {"Bandung"}};\ncout << m->nama;\n\nApa masalahnya?',
 E'm bukan POINTER, jadi operator -> tidak berlaku.\n\nm->nama  SALAH\nm.nama   BENAR\n\nAturan:\n- operator . untuk nilai/referensi\n- operator -> untuk pointer',
 'JEBAKAN', 'Mahasiswa m = {"Rani", {"Bandung"}};\ncout << m->nama;  // SALAH!', 'cpp', 13),

(E'struct Barang { string nama; double harga; };\nBarang daftar[3] = {{"Buku",25000},{"Pulpen",3000},{"Tas",150000}};\n\nint n = sizeof(daftar) / sizeof(daftar[0]);\n\nBerapa nilai n?',
 E'Output: 3\n\nsizeof(daftar)    = ukuran seluruh array\nsizeof(daftar[0]) = ukuran SATU elemen\n\nPembagian menghasilkan JUMLAH ELEMEN = 3.\n\nIni hanya bekerja kalau array masih di scope yang sama.\nKalau dikirim ke fungsi, informasi ukuran hilang (decay).',
 'TRACING', 'int n = sizeof(daftar) / sizeof(daftar[0]);', 'cpp', 14),

('Bagaimana cara membaca m.alamat.negara.nama?',
 E'Dari LUAR ke DALAM:\n\nm          -> struct Mahasiswa\n.alamat    -> struct Alamat\n.negara    -> struct Negara\n.nama      -> string\n\nUrutannya mengikuti struktur data, bukan dibalik.',
 'ISTILAH', null, null, 15),

('Apa yang salah dari inisialisasi ini?\nMahasiswa m = {"Rani", "Bandung"};',
 E'Kurung kurawal BERSARANG tidak dipakai untuk alamat.\n\nSALAH: {"Rani", "Bandung"}\nBENAR: {"Rani", {"Bandung"}}\n\nKarena alamat adalah struct, nilainya harus dibungkus kurung kurawal sendiri.',
 'JEBAKAN', 'Mahasiswa m = {"Rani", "Bandung"};  // SALAH', 'cpp', 16),

('Mengapa kesalahan urutan inisialisasi struct bersarang berbahaya?',
 E'Karena TIDAK terdeteksi compiler kalau tipenya sama.\n\nSALAH: {"Rani", {"40123", "Bandung"}}\n-> kota berisi "40123", kodePos berisi "Bandung"\n\nCompiler tidak error karena keduanya string.\nKesalahan hanya terlihat saat program berjalan.\n\nSolusi: pakai inisialisasi dengan nama (C++20):\n{.nama="Rani", .alamat={.kota="Bandung"}}',
 'MEMORI', null, null, 17),

('Kapan sebaiknya memakai struct bersarang?',
 E'Kalau ada data yang SELALU muncul bersama sebagai satu kesatuan.\n\nContoh:\n- Mahasiswa punya Alamat\n- Barang punya Dimensi\n- Pesanan punya Pengiriman\n\nKalau data itu bisa berdiri sendiri, jadikan struct terpisah\ndan simpan sebagai dua field, bukan bersarang.',
 'KAPAN', null, null, 18),

('Apa perbedaan cara menyalin struct bersarang di C++ dan objek bersarang di Python?',
 E'C++ : b = a menyalin SELURUH struct termasuk yang bersarang.\n      Mengubah b tidak mempengaruhi a.\n\nPython: b = a hanya menyalin REFERENSI ke objek yang sama.\n        Mengubah b IKUT mengubah a.\n        Untuk salinan sebenarnya: copy.deepcopy(a)\n\nIni perbedaan mendasar nilai vs referensi.',
 'BANDING', null, null, 19),

('Bagaimana cara mengubah anggota nested struct?',
 E'Sama seperti mengaksesnya - pakai dua titik:\n\nm.alamat.kota = "Jakarta";\n\nSetelah itu:\ncout << m.alamat.kota;   // Jakarta',
 'SINTAKS', 'm.alamat.kota = "Jakarta";', 'cpp', 20)

) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'struct-nested';

-- SOAL (18 soal)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values

('Bagaimana cara mengakses kota dari struct Mahasiswa yang punya anggota Alamat?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: m.alamat.kota\n\nAkses mengikuti struktur dari LUAR ke DALAM:\nm (struct Mahasiswa) -> .alamat (struct Alamat) -> .kota (string).\n\nm.kota.alamat salah karena m tidak punya anggota kota langsung.',
 1),

(E'struct Alamat { string kota; };\nstruct Mahasiswa { string nama; Alamat alamat; };\n\nMahasiswa m = {"Rani", {"Bandung"}};\ncout << m.alamat.kota;',
 'struct Alamat { string kota; };\nstruct Mahasiswa { string nama; Alamat alamat; };\n\nMahasiswa m = {"Rani", {"Bandung"}};\ncout << m.alamat.kota;',
 'cpp', 'TRACE', 'TRACING',
 E'Output: Bandung\n\nm.alamat.kota mengakses string kota di dalam struct Alamat, yang merupakan anggota dari Mahasiswa.\n\n"Rani" adalah nama, "Bandung" adalah kota.',
 2),

('Bagaimana cara mendeklarasikan array 3 barang dengan nilai awal?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Barang daftar[3] = {{"Buku",25000},{"Pulpen",3000},{"Tas",150000}};\n\nSetiap elemen dibungkus kurung kurawal sendiri.\n\nBarang daftar[3] = {"Buku", 25000, "Pulpen", 3000} salah - compiler tidak tahu mana batas tiap elemen.\nBarang daftar[] = {"Buku"} salah - hanya satu field yang diisi.',
 3),

('Bagaimana cara mengurutkan array of struct berdasarkan field ipk menurun?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: sort(kelas, kelas + 3, [](const Kelas& a, const Kelas& b) { return a.ipk > b.ipk; });\n\nLambda pembanding menerima dua elemen dan mengembalikan true jika a harus datang sebelum b.\n\nTanda > untuk menurun, < untuk menaik.\n\nPerlu #include <algorithm>.',
 4),

('Apa perbedaan array of struct dan struct of array?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Array of struct menyimpan satu objek utuh per elemen; struct of array menyimpan satu field untuk semua objek.\n\nAoS: struct Mhs { string nama; double ipk; }; Mhs daftar[100];\n-> daftar[0] berisi nama DAN ipk mahasiswa pertama\n\nSoA: struct Daftar { string nama[100]; double ipk[100]; };\n-> semua nama dalam satu array, semua ipk dalam array lain\n\nAoS lebih mudah dibaca dan direkomendasikan untuk kebanyakan kasus.',
 5),

('Apa yang salah dari m->nama jika m bukan pointer?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Operator -> hanya berlaku untuk pointer.\n\nAturan:\n- operator . untuk nilai/referensi: m.nama\n- operator -> untuk pointer: p->nama\n\nKalau m bukan pointer, gunakan m.nama.\n\nKesalahan ini sangat umum saat pertama kali belajar pointer ke struct.',
 6),

(E'struct Barang { string nama; double harga; };\nBarang daftar[3] = {{"Buku",25000},{"Pulpen",3000},{"Tas",150000}};\n\nint n = sizeof(daftar) / sizeof(daftar[0]);\ncout << n;',
 'int n = sizeof(daftar) / sizeof(daftar[0]);\ncout << n;',
 'cpp', 'TRACE', 'MEMORI',
 E'Output: 3\n\nsizeof(daftar) adalah ukuran SELURUH array.\nsizeof(daftar[0]) adalah ukuran SATU elemen.\nPembagiannya menghasilkan jumlah elemen = 3.\n\nPENTING: ini hanya bekerja kalau array masih di scope yang sama. Kalau dikirim ke fungsi, array decay jadi pointer dan informasi ukuran hilang.',
 7),

('Apa yang salah dari Mahasiswa m = {"Rani", "Bandung"};?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Nilai untuk alamat harus dibungkus kurung kurawal sendiri.\n\nSALAH: {"Rani", "Bandung"}\nBENAR: {"Rani", {"Bandung"}}\n\nKarena alamat adalah struct, nilainya harus berupa daftar tersendiri.\n\nCompiler akan memberi error karena tidak bisa mengonversi "Bandung" menjadi struct Alamat.',
 8),

('Bagaimana cara mengiterasi array of struct dan menjumlahkan field harganya?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: double total = 0; for (int i = 0; i < 3; i++) { total += daftar[i].harga; }\n\nSetiap elemen diakses dengan indeks, lalu field-nya dengan titik.\n\ndaftar.harga salah karena daftar adalah array, bukan struct tunggal.\n\nHasil untuk data contoh: 25000 + 3000 + 150000 = 178000.',
 9),

(E'struct Alamat { string kota; };\nstruct Mahasiswa { string nama; Alamat alamat; };\n\nMahasiswa a = {"Rani", {"Bandung"}};\nMahasiswa b = a;\nb.alamat.kota = "Jakarta";\ncout << a.alamat.kota;',
 'Mahasiswa a = {"Rani", {"Bandung"}};\nMahasiswa b = a;\nb.alamat.kota = "Jakarta";\ncout << a.alamat.kota;',
 'cpp', 'TRACE', 'MEMORI',
 E'Output: Bandung\n\nb = a membuat SALINAN LENGKAP, termasuk struct alamat di dalamnya.\n\nMengubah b.alamat.kota TIDAK mempengaruhi a.alamat.kota.\n\nIni berbeda dari Python: b = a pada objek Python hanya menyalin REFERENSI, sehingga mengubah b ikut mengubah a.',
 10),

('Apa padanan array of struct di Python?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: list of dataclass\n\ndaftar = [Mahasiswa("Rani", 20), Mahasiswa("Budi", 21)]\n\nPython memakai list (ukuran dinamis) bukan array (ukuran tetap).\n\nSetiap elemen adalah objek dataclass lengkap.\n\nPengecoh "list of tuple" bisa dipakai tapi tidak punya nama field - kurang jelas.',
 11),

('Bagaimana cara mengurutkan list of dataclass berdasarkan field ipk menurun?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: sorted(kelas, key=lambda k: k.ipk, reverse=True)\n\nkey menentukan field yang dipakai untuk mengurutkan.\nreverse=True membuat urutan menurun.\n\nkelas.sort(key=...) juga bisa tapi mengubah list asli (in-place).\n\nC++ memakai std::sort dengan lambda pembanding - konsepnya mirip.',
 12),

('Mengapa kesalahan urutan inisialisasi struct bersarang sulit ditemukan?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena tidak terdeteksi compiler kalau tipe anggotanya sama.\n\nSALAH: {"Rani", {"40123", "Bandung"}}\n-> kota berisi "40123", kodePos berisi "Bandung"\n\nKedua field bertipe string, jadi compiler tidak bisa mendeteksi kesalahan. Program berjalan tapi datanya tertukar.\n\nSolusi: pakai inisialisasi dengan nama (C++20): {.kota = "Bandung", .kodePos = "40123"}',
 13),

('Bagaimana cara mengubah kota pada struct bersarang?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: m.alamat.kota = "Jakarta";\n\nSama seperti mengakses, pengubahan juga memakai dua titik.\n\nSetelah itu m.alamat.kota bernilai "Jakarta".\n\nm.alamat = "Jakarta" salah karena alamat adalah struct, bukan string.',
 14),

('Kapan sebaiknya memakai struct bersarang?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: Saat ada data yang selalu muncul bersama sebagai satu kesatuan.\n\nContoh tepat: Mahasiswa punya Alamat (setiap mahasiswa pasti punya alamat).\n\nContoh kurang tepat: Mahasiswa punya DosenPembimbing - dosen bisa berdiri sendiri dan punya banyak mahasiswa, jadi lebih tepat jadi struct terpisah yang direferensikan.',
 15),

(E'struct Barang { string nama; double harga; };\nBarang daftar[3] = {{"Buku",25000},{"Pulpen",3000},{"Tas",150000}};\n\nfor (int i = 0; i < 3; i++) {\n    cout << daftar[i].nama << " ";\n}\n\nApa outputnya?',
 'Barang daftar[3] = {{"Buku",25000},{"Pulpen",3000},{"Tas",150000}};\nfor (int i = 0; i < 3; i++) { cout << daftar[i].nama << " "; }',
 'cpp', 'TRACE', 'TRACING',
 E'Output: Buku Pulpen Tas\n\nLoop mengiterasi ketiga elemen array.\nSetiap iterasi mengakses field nama dari elemen ke-i.\n\nUrutan sesuai urutan deklarasi array, bukan diurutkan berdasarkan harga.',
 16),

('Apa perbedaan cara menyalin struct bersarang C++ dan objek Python?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: C++ menyalin seluruh nilai; Python hanya menyalin referensi.\n\nC++: Mahasiswa b = a; -> salinan lengkap, termasuk struct di dalamnya. Mengubah b tidak mempengaruhi a.\n\nPython: b = a; -> hanya referensi ke objek yang sama. Mengubah b IKUT mengubah a. Untuk salinan sebenarnya perlu copy.deepcopy(a).\n\nIni perbedaan mendasar antara bahasa dengan nilai dan bahasa dengan referensi.',
 17),

('Apa yang terjadi jika array of struct dikirim ke fungsi lalu dihitung dengan sizeof?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: sizeof menghasilkan ukuran POINTER (8 byte), bukan ukuran array - informasi ukuran hilang.\n\nIni disebut array decay. Terjadi pada semua array C, termasuk array of struct.\n\nSolusinya: kirim ukurannya sebagai parameter terpisah, atau pakai std::vector/std::array yang menyimpan ukurannya.\n\nIni salah satu alasan std::vector lebih aman.',
 18)

) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'struct-nested';

-- OPSI JAWABAN
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', 'm.alamat.kota', true, 1),
  (1, 'B', 'm.kota.alamat', false, 2),
  (1, 'C', 'm.kota', false, 3),
  (1, 'D', 'm->alamat->kota', false, 4),
  (2, 'A', 'Bandung', true, 1),
  (2, 'B', 'Rani', false, 2),
  (2, 'C', 'Error', false, 3),
  (2, 'D', 'm.alamat.kota', false, 4),
  (3, 'A', 'Barang daftar[3] = {{"Buku",25000},{"Pulpen",3000},{"Tas",150000}};', true, 1),
  (3, 'B', 'Barang daftar[3] = {"Buku",25000,"Pulpen",3000,"Tas",150000};', false, 2),
  (3, 'C', 'Barang daftar[] = {"Buku"};', false, 3),
  (3, 'D', 'Barang daftar(3) = {{"Buku",25000}};', false, 4),
  (4, 'A', 'sort(kelas, kelas+3, [](const Kelas& a, const Kelas& b) { return a.ipk > b.ipk; });', true, 1),
  (4, 'B', 'sort(kelas.ipk);', false, 2),
  (4, 'C', 'sort(kelas, kelas+3);', false, 3),
  (4, 'D', 'kelas.sort(ipk);', false, 4),
  (5, 'A', 'AoS menyimpan satu objek utuh per elemen; SoA menyimpan satu field untuk semua objek', true, 1),
  (5, 'B', 'AoS lebih hemat memori dari SoA', false, 2),
  (5, 'C', 'SoA tidak bisa diurutkan', false, 3),
  (5, 'D', 'AoS hanya bisa menyimpan tipe primitif', false, 4),
  (6, 'A', 'Operator -> hanya berlaku untuk pointer; untuk nilai gunakan .', true, 1),
  (6, 'B', 'nama adalah keyword yang dilindungi', false, 2),
  (6, 'C', 'Struct tidak boleh punya anggota string', false, 3),
  (6, 'D', 'Perlu menambahkan tanda kurung: m->(nama)', false, 4),
  (7, 'A', '3', true, 1),
  (7, 'B', 'Ukuran satu elemen dalam byte', false, 2),
  (7, 'C', '1', false, 3),
  (7, 'D', 'Error kompilasi', false, 4),
  (8, 'A', 'Nilai untuk alamat harus dibungkus kurung kurawal sendiri: {"Rani", {"Bandung"}}', true, 1),
  (8, 'B', 'Struct tidak boleh punya anggota bertipe struct', false, 2),
  (8, 'C', 'Perlu menambahkan titik koma di akhir', false, 3),
  (8, 'D', 'Nama mahasiswa harus diletakkan setelah alamat', false, 4),
  (9, 'A', 'double total = 0; for (int i = 0; i < 3; i++) { total += daftar[i].harga; }', true, 1),
  (9, 'B', 'double total = daftar.harga;', false, 2),
  (9, 'C', 'double total = sum(daftar);', false, 3),
  (9, 'D', 'double total = daftar[0].harga + daftar.harga;', false, 4),
  (10, 'A', 'Bandung', true, 1),
  (10, 'B', 'Jakarta', false, 2),
  (10, 'C', 'Error', false, 3),
  (10, 'D', 'Rani', false, 4),
  (11, 'A', 'list of dataclass', true, 1),
  (11, 'B', 'list of tuple', false, 2),
  (11, 'C', 'dictionary bersarang', false, 3),
  (11, 'D', 'array NumPy', false, 4),
  (12, 'A', 'sorted(kelas, key=lambda k: k.ipk, reverse=True)', true, 1),
  (12, 'B', 'sort(kelas, ipk, menurun)', false, 2),
  (12, 'C', 'kelas.urutkan("ipk")', false, 3),
  (12, 'D', 'sorted(kelas, ipk, True)', false, 4),
  (13, 'A', 'Karena tidak terdeteksi compiler kalau tipe anggotanya sama - program jalan tapi data tertukar', true, 1),
  (13, 'B', 'Karena compiler selalu menolak inisialisasi bersarang', false, 2),
  (13, 'C', 'Karena struct bersarang tidak bisa diinisialisasi', false, 3),
  (13, 'D', 'Karena Python tidak mendukung struct bersarang', false, 4),
  (14, 'A', 'm.alamat.kota = "Jakarta";', true, 1),
  (14, 'B', 'm.alamat = "Jakarta";', false, 2),
  (14, 'C', 'm.kota = "Jakarta";', false, 3),
  (14, 'D', 'm->alamat.kota = "Jakarta";', false, 4),
  (15, 'A', 'Saat ada data yang selalu muncul bersama sebagai satu kesatuan', true, 1),
  (15, 'B', 'Saat butuh menghemat memori', false, 2),
  (15, 'C', 'Saat struct punya lebih dari 10 anggota', false, 3),
  (15, 'D', 'Saat data perlu disimpan ke berkas', false, 4),
  (16, 'A', 'Buku Pulpen Tas', true, 1),
  (16, 'B', 'Tas Pulpen Buku', false, 2),
  (16, 'C', '25000 3000 150000', false, 3),
  (16, 'D', 'Error', false, 4),
  (17, 'A', 'C++ menyalin seluruh nilai; Python hanya menyalin referensi', true, 1),
  (17, 'B', 'C++ dan Python sama-sama menyalin referensi', false, 2),
  (17, 'C', 'Python menyalin nilai; C++ menyalin referensi', false, 3),
  (17, 'D', 'Keduanya tidak bisa menyalin struct bersarang', false, 4),
  (18, 'A', 'sizeof menghasilkan ukuran POINTER, bukan ukuran array - informasi ukuran hilang (decay)', true, 1),
  (18, 'B', 'sizeof tetap menghasilkan ukuran array yang benar', false, 2),
  (18, 'C', 'Program gagal kompilasi', false, 3),
  (18, 'D', 'Array otomatis dikonversi jadi vector', false, 4)
) as v(urutan_soal, label, teks, benar, urutan)
  on v.urutan_soal = s.urutan
where m.slug = 'struct-nested';
