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

-- ============ FLASHCARD (10 kartu) ============
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

-- ============ SOAL QUIZ (10 soal) ============
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

-- ============ OPSI JAWABAN (40 opsi) ============
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
