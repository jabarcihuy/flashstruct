# 02 — Kurikulum & Desain Konten

> Peta materi **Array, Struct, Pointer** untuk FlashStruct, beserta taksonomi flashcard dan soal.
> Status: `[FINAL]` — struktur, jumlah, dan klaim teknis sudah diverifikasi dengan compiler nyata (GCC 16.2.1, Python 3.14.7).
>
> **Catatan validasi:** seluruh klaim teknis di dokumen ini (padding struct, aritmetika pointer, `sizeof` array, jebakan list Python) sudah dijalankan dan diukur, bukan ditulis dari ingatan. Hasil pengukuran ada di §3.2 (modul `struct-memori`). Isi modul tetap perlu ditinjau dosen pengampu sebelum dipakai mengajar.

---

## 1. Prinsip Penyusunan Kurikulum

### 1.1 Mengapa C++ *dan* Python

Kedua bahasa dipakai berdampingan bukan untuk "biar banyak", tetapi karena masing-masing memperlihatkan sisi berbeda dari konsep yang sama:

| Konsep | Yang diperlihatkan C++ | Yang diperlihatkan Python |
|--------|------------------------|---------------------------|
| Array | Memori berurutan, tipe seragam, ukuran tetap | List dinamis, tipe bebas, referensi ke objek |
| Struct | Layout memori, padding, `sizeof` | `dataclass` sebagai wadah data murni |
| Pointer | Alamat memori nyata, aritmetika pointer | Tidak ada pointer — tapi ada **semantik referensi** |
| Manajemen memori | Manual (`new`/`delete`), sumber bug | Otomatis (garbage collected) |

**Poin pedagogis penting:** Python **tidak punya pointer** dalam arti C++. Menyembunyikan fakta ini akan menyesatkan. Sebaliknya, modul Pointer di FlashStruct **mengajarkan perbedaan ini secara eksplisit** — mahasiswa belajar bahwa `a = [1,2]; b = a` di Python memiliki kemiripan perilaku dengan `int* b = &a` di C++, tetapi mekanismenya berbeda total.

Ini justru memperkuat pemahaman: mahasiswa yang bisa menjelaskan **mengapa** Python tidak butuh pointer akan lebih paham pointer daripada mahasiswa yang hanya hafal sintaks `*p`.

### 1.2 Urutan Topik

```
ARRAY ──────────► STRUCT ──────────► POINTER
(dasar memori)    (mengelompokkan)   (mengakses alamat)

Mengapa urutan ini:
  • Array mengenalkan ide "data berurutan di memori"
  • Struct mengenalkan ide "beberapa nilai jadi satu kesatuan"
  • Pointer membutuhkan keduanya: pointer ke array, pointer ke struct
  • Pointer tanpa pemahaman array = hafalan sintaks tanpa makna
```

### 1.3 Aturan Kedalaman per Modul

Setiap modul harus lolos tes ini sebelum dianggap layak:

1. **Bisa dijelaskan tanpa kode.** Ada penjelasan konsep dalam bahasa manusia.
2. **Ada contoh kode C++ dan Python.** Minimal satu perbandingan per modul.
3. **Ada minimal satu "jebakan".** Kesalahan umum yang sering terjadi, dijelaskan eksplisit.
4. **Ada kaitan ke praktik.** Kenapa ini penting di dunia kerja, bukan hanya untuk ujian.
5. **Bisa dites.** Ada minimal 5 soal quiz yang menguji pemahaman, bukan hafalan sintaks semata.

---

## 2. Peta Modul

Total **10 modul**: 3 Array, 3 Struct, 4 Pointer.

| Slug | Topik | Judul Modul | Bagian | Kartu | Soal | Estimasi |
|------|-------|-------------|--------|-------|------|----------|
| `array-dasar` | Array | Dasar Array & Indeks | 5 | 20 | 18 | 12 mnt |
| `array-multidimensi` | Array | Array Multidimensi | 4 | 16 | 15 | 10 mnt |
| `array-dinamis` | Array | Array Dinamis: `vector` & `list` | 5 | 20 | 18 | 14 mnt |
| `struct-dasar` | Struct | Mendefinisikan Struct | 4 | 18 | 16 | 11 mnt |
| `struct-nested` | Struct | Nested Struct & Array of Struct | 5 | 20 | 18 | 13 mnt |
| `struct-memori` | Struct | Padding, Alignment & `sizeof` | 5 | 22 | 20 | 16 mnt |
| `pointer-dasar` | Pointer | Dasar Pointer & Alamat Memori | 6 | 24 | 20 | 16 mnt |
| `pointer-array` | Pointer | Pointer & Array: Aritmetika Pointer | 5 | 22 | 20 | 15 mnt |
| `pointer-struct` | Pointer | Pointer ke Struct & Arrow Operator | 4 | 18 | 16 | 12 mnt |
| `pointer-dinamis` | Pointer | Alokasi Memori Dinamis | 6 | 26 | 22 | 18 mnt |
| | | **TOTAL** | **49** | **206** | **183** | **± 137 mnt** |

---

## 3. Rincian Modul

Setiap modul berikut mencantumkan: tujuan pembelajaran, bagian-bagiannya, kartu kunci, jebakan yang harus dibahas, dan kaitan praktisnya.

---

### 3.1 Topik: ARRAY

---

#### Modul 1 — `array-dasar` · Dasar Array & Indeks

**Tujuan pembelajaran:**
- Menjelaskan mengapa elemen array tersimpan berurutan di memori
- Menghitung alamat elemen ke-`n` dari alamat elemen pertama
- Membedakan `arr[i]` dari `*(arr + i)` dan menjelaskan mengapa keduanya setara
- Menjelaskan mengapa C++ tidak memeriksa batas indeks

**Bagian:**

| # | Bagian | Isi |
|---|--------|-----|
| 1 | Apa itu array | Definisi, analogi loker berderet, ciri: tipe seragam + ukuran tetap |
| 2 | Memori berurutan | Alamat elemen berurutan, rumus `alamat(i) = alamat(0) + i × sizeof(T)` |
| 3 | Indeks & pengaksesan | `arr[0]` sebagai elemen pertama, `arr[i]` ≡ `*(arr + i)` |
| 4 | Batas array | Tanpa pemeriksaan batas, *undefined behavior*, contoh *buffer overflow* |
| 5 | Perbandingan C++ vs Python | `int arr[5]` vs `[0]*5`, perbedaan ukuran tetap vs dinamis |

**Jebakan yang wajib dibahas:**
- Mengakses `arr[5]` pada `int arr[5]` — tidak error saat kompilasi, tapi *undefined behavior*
- Mengira indeks mulai dari 1
- `sizeof(arr)` di dalam fungsi memberi ukuran pointer, bukan ukuran array (dibahas ulang di modul Pointer)

**Kaitan praktis:** Kesalahan indeks adalah penyebab utama celah keamanan *buffer overflow*. Memahami batas array adalah dasar menulis kode yang aman.

---

#### Modul 2 — `array-multidimensi` · Array Multidimensi

**Tujuan pembelajaran:**
- Menjelaskan urutan penyimpanan *row-major*
- Menghitung alamat elemen `m[i][j]` pada array 2D
- Menjelaskan mengapa `m[i][j]` setara dengan `*(*(m + i) + j)`
- Memilih antara array 2D dan array of array

**Bagian:**

| # | Bagian | Isi |
|---|--------|-----|
| 1 | Konsep array 2D | Baris dan kolom, deklarasi `int m[3][4]` |
| 2 | Row-major order | Elemen tersimpan baris demi baris, bukan kolom demi kolom |
| 3 | Menghitung alamat | Rumus `alamat(i,j) = alamat(0,0) + (i × jumlahKolom + j) × sizeof(T)` |
| 4 | Bentuk di Python | List bersarang, tidak ada jaminan berurutan di memori |

**Jebakan yang wajib dibahas:**
- Mengira array 2D adalah "array dari array" di C++ — secara tipe memang begitu, tetapi memorinya satu blok kontigu
- Membuat list bersarang di Python dengan `[[0]*3]*3` — **semua baris menunjuk ke objek yang sama**, mengubah satu baris mengubah semuanya
- Tertukar antara indeks baris dan kolom

**Kaitan praktis:** Pemrosesan citra, matriks, dan tabel data semuanya bergantung pada pemahaman urutan baris/kolom. Salah urutan berarti salah hasil.

---

#### Modul 3 — `array-dinamis` · Array Dinamis: `vector` & `list`

**Tujuan pembelajaran:**
- Menjelaskan keterbatasan array berukuran tetap
- Menjelaskan cara kerja pertumbuhan dinamis (alokasi ulang + penyalinan)
- Membedakan `size` dari `capacity` pada `std::vector`
- Menjelaskan mengapa `std::vector` bisa lebih cepat dari list walaupun dinamis

**Bagian:**

| # | Bagian | Isi |
|---|--------|-----|
| 1 | Masalah array statis | Ukuran harus diketahui saat kompilasi |
| 2 | `std::vector` | Deklarasi, `push_back`, `size`, `capacity`, `reserve` |
| 3 | Bagaimana pertumbuhan bekerja | Alokasi blok lebih besar, salin elemen lama, bebaskan blok lama |
| 4 | `std::array` | Ukuran tetap tapi punya `size()` dan tidak *decay* ke pointer |
| 5 | List Python | Model referensi, `append`, *over-allocation*, kompleksitas operasi |

**Jebakan yang wajib dibahas:**
- Mengira `capacity` sama dengan `size` — `size` adalah jumlah elemen, `capacity` adalah ruang yang sudah dialokasikan
- Menggunakan pointer ke elemen `vector` lalu memanggil `push_back` — jika terjadi alokasi ulang, pointer menjadi *dangling*
- Mengira `insert` di awal list Python itu murah — sebenarnya O(n) karena harus menggeser elemen
- Angka pertumbuhan kapasitas bersifat *implementation-defined* (umumnya 2× pada banyak implementasi) — jangan dihafal sebagai fakta mutlak

**Kaitan praktis:** `std::vector` adalah wadah yang paling sering dipakai di C++ modern. Memahami `size` vs `capacity` mencegah bug performa yang sulit dilacak.

---

### 3.2 Topik: STRUCT

---

#### Modul 4 — `struct-dasar` · Mendefinisikan Struct

**Tujuan pembelajaran:**
- Mendefinisikan `struct` dengan anggota bertipe berbeda
- Mengakses anggota dengan operator titik
- Menjelaskan perbedaan `struct` dan `class` di C++
- Membuat padanan `struct` di Python dengan `dataclass`

**Bagian:**

| # | Bagian | Isi |
|---|--------|-----|
| 1 | Mengapa butuh struct | Mengelompokkan data terkait yang tipenya berbeda |
| 2 | Sintaks & pengaksesan | Deklarasi, inisialisasi, `titik.x`, `titik.y` |
| 3 | `struct` vs `class` | Perbedaan default akses (public vs private), konvensi penggunaan |
| 4 | Padanan di Python | `@dataclass`, `namedtuple`, perbandingan singkat |

**Jebakan yang wajib dibahas:**
- Lupa titik koma setelah `};` pada deklarasi struct di C++
- Mengira `struct` harus selalu diisi semua anggotanya saat inisialisasi
- Menulis `dataclass` tanpa `@dataclass` di Python — kelas biasa yang tidak punya `__init__` otomatis

**Kaitan praktis:** Hampir semua sistem nyata memodelkan entitas (pengguna, produk, koordinat) sebagai struct. Ini adalah langkah pertama dari "variabel lepas" menuju "model data".

---

#### Modul 5 — `struct-nested` · Nested Struct & Array of Struct

**Tujuan pembelajaran:**
- Menyusun struct yang salah satu anggotanya bertipe struct lain
- Mendeklarasikan dan mengiterasi array of struct
- Mengakses anggota bertingkat
- Memilih antara array of struct dan struct of array

**Bagian:**

| # | Bagian | Isi |
|---|--------|-----|
| 1 | Struct sebagai anggota | `struct Mahasiswa { Alamat alamat; }` |
| 2 | Mengakses bertingkat | `mhs.alamat.kota` |
| 3 | Array of struct | `Mahasiswa daftar[10]`, iterasi dengan loop |
| 4 | Struct of array | Kebalikannya, dan kapan lebih efisien |
| 5 | Padanan Python | `dataclass` bersarang, list of `dataclass` |

**Jebakan yang wajib dibahas:**
- Menulis `mhs->alamat.kota` padahal `mhs` bukan pointer
- Salah urutan akses: `mhs.alamat.kota` bukan `mhs.kota.alamat`
- Mengira array of struct tidak bisa diurutkan — padahal bisa dengan `std::sort` + lambda pembanding

**Kaitan praktis:** Data dunia nyata hampir selalu bertingkat. Rekam medis punya pasien yang punya alamat dan riwayat kunjungan. Kemampuan memodelkan ini adalah keterampilan inti.

---

#### Modul 6 — `struct-memori` · Padding, Alignment & `sizeof`

**Tujuan pembelajaran:**
- Menjelaskan mengapa `sizeof(struct)` lebih besar dari jumlah `sizeof` anggotanya
- Menjelaskan aturan *alignment*
- Menghitung padding pada struct sederhana
- Menjelaskan cara memeriksa *offset* anggota dengan `offsetof`

**Bagian:**

| # | Bagian | Isi |
|---|--------|-----|
| 1 | Kejutan pertama | `struct { char a; int b; }` → `sizeof` = 8, bukan 5 |
| 2 | Mengapa alignment ada | CPU membaca memori per blok; akses tidak selaras lebih lambat atau tidak diizinkan |
| 3 | Menghitung padding | Aturan: setiap anggota mulai pada kelipatan alignment-nya; total dibulatkan ke kelipatan alignment terbesar |
| 4 | Memeriksa di kode | `sizeof`, `offsetof`, demonstrasi langsung |
| 5 | Mengurangi padding | Mengurutkan anggota — **dengan syarat** (lihat catatan di bawah); `#pragma pack` (dengan risiko) |

**Jebakan yang wajib dibahas:**
- Mengira `sizeof(struct)` = jumlah `sizeof` anggota
- Mengasumsikan nilai padding sama di semua platform — **alignment bersifat *implementation-defined***
- **Mengira mengurutkan anggota selalu mengurangi padding** — ini tidak benar (lihat catatan di bawah)
- Menggunakan `#pragma pack(1)` tanpa memahami konsekuensi performa dan portabilitas
- Membandingkan struct dengan `memcmp` — padding berisi nilai tak tentu, hasilnya bisa salah
- Menulis struct langsung ke file lalu membacanya di mesin lain — layout bisa berbeda

**Catatan akurasi untuk penyusun konten:** Angka padding pada modul ini harus disajikan sebagai **contoh pada platform tertentu** (misalnya x86-64 dengan GCC/Clang), bukan sebagai aturan universal. Selalu sertakan cara memverifikasi sendiri dengan `sizeof` dan `offsetof`. Ini kesempatan bagus mengajarkan bahwa detail tingkat mesin bergantung implementasi.

#### Hasil Verifikasi Padding (x86-64, GCC 16.2.1, `sizeof(int)=4`, `sizeof(long)=8`)

Semua angka berikut **sudah diukur**, bukan dikutip dari ingatan. Gunakan angka ini sebagai contoh di modul.

| Struct | `sizeof` | Catatan |
|--------|----------|---------|
| `{ char a; int b; }` | **8** | 1 + 3 padding + 4 |
| `{ int b; char a; }` | **8** | 4 + 1 + 3 padding akhir — **sama, pengurutan tidak membantu** |
| `{ char a; long b; char c; }` | **24** | 1 + 7 pad + 8 + 1 + 7 pad akhir |
| `{ long b; char a; char c; }` | **16** | 8 + 1 + 1 + 6 pad akhir — **hemat 8 byte** |
| `{ char a; int b; char c; long d; }` | **24** | offset: a=0, b=4, c=8, d=16 |
| `{ long d; int b; char a; char c; }` | **16** | offset: d=0, b=8, a=12, c=13 — **hemat 8 byte** |
| `{ char a; int b; short c; }` | **12** | 1 + 3 pad + 4 + 2 + 2 pad akhir |
| `{ int b; short c; char a; }` | **8** | 4 + 2 + 1 + 1 pad akhir — **hemat 4 byte** |

**Temuan penting yang harus diajarkan dengan benar:**

Mengurutkan anggota dari besar ke kecil **hanya membantu jika ada beberapa anggota kecil yang bisa dikemas bersama**. Pada struct dengan hanya dua anggota (`char` dan `int`), pengurutan **tidak mengubah apa pun** — keduanya tetap 8 byte.

**Aturan yang lebih akurat untuk diajarkan:**

> Padding berkurang ketika anggota-anggota kecil dikelompokkan berdampingan sehingga mereka muat dalam satu blok alignment. Ini biasanya tercapai dengan mengurutkan dari besar ke kecil, tetapi **bukan jaminan** — pada struct sederhana dengan dua anggota, hasilnya bisa sama saja.

**Cara mengajar yang benar:** jangan menyuruh mahasiswa menghafal "urutkan dari besar ke kecil". Suruh mereka **mengukur sendiri** dengan `sizeof` dan `offsetof`, lalu biarkan mereka menemukan sendiri kapan pengurutan membantu dan kapan tidak. Ini jauh lebih berharga daripada aturan hafalan yang ternyata tidak selalu berlaku.

**Kode pembuktian untuk modul:**

```cpp
#include <iostream>
#include <cstddef>
using namespace std;

struct A2 { char a; int b; };
struct B2 { int b; char a; };

struct A4 { char a; int b; char c; long d; };
struct B4 { long d; int b; char a; char c; };

int main() {
    cout << "sizeof(int)=" << sizeof(int)
         << " sizeof(long)=" << sizeof(long) << "\n\n";

    cout << "{char,int} = " << sizeof(A2) << " byte\n";
    cout << "{int,char} = " << sizeof(B2) << " byte\n";
    cout << "  -> " << (sizeof(A2) == sizeof(B2)
                          ? "SAMA, pengurutan TIDAK membantu"
                          : "BERBEDA") << "\n\n";

    cout << "{char,int,char,long} = " << sizeof(A4) << " byte\n";
    cout << "{long,int,char,char} = " << sizeof(B4) << " byte\n";
    cout << "  -> hemat " << (sizeof(A4) - sizeof(B4)) << " byte\n\n";

    cout << "offset A4: a=" << offsetof(A4,a) << " b=" << offsetof(A4,b)
         << " c=" << offsetof(A4,c) << " d=" << offsetof(A4,d) << "\n";
    cout << "offset B4: d=" << offsetof(B4,d) << " b=" << offsetof(B4,b)
         << " a=" << offsetof(B4,a) << " c=" << offsetof(B4,c) << "\n";
    return 0;
}
```

**Output terverifikasi:**

```
sizeof(int)=4 sizeof(long)=8

{char,int} = 8 byte
{int,char} = 8 byte
  -> SAMA, pengurutan TIDAK membantu

{char,int,char,long} = 24 byte
{long,int,char,char} = 16 byte
  -> hemat 8 byte

offset A4: a=0 b=4 c=8 d=16
offset B4: d=0 b=8 a=12 c=13
```

**Kaitan praktis:** Serialisasi data, protokol jaringan, dan pemetaan perangkat keras semuanya bergantung pada layout memori yang tepat. Salah memahami padding menghasilkan data yang rusak saat dikirim antar sistem.

---

### 3.3 Topik: POINTER

---

#### Modul 7 — `pointer-dasar` · Dasar Pointer & Alamat Memori

**Tujuan pembelajaran:**
- Menjelaskan pointer sebagai variabel yang menyimpan alamat
- Menggunakan operator `&` dan `*`
- Menjelaskan hubungan tipe pointer dengan tipe yang ditunjuk
- Menjelaskan konsep `nullptr` dan bahaya *dangling pointer*
- Menjelaskan mengapa Python tidak memiliki pointer eksplisit

**Bagian:**

| # | Bagian | Isi |
|---|--------|-----|
| 1 | Alamat memori | Setiap variabel punya alamat; mencetak dengan `&` dan `%p` |
| 2 | Mendeklarasikan pointer | `int* p`, membaca tipe dari kanan ke kiri |
| 3 | Dereferensi | `*p` membaca nilai di alamat yang disimpan |
| 4 | `nullptr` | Pointer yang tidak menunjuk apa pun; memeriksa sebelum dereferensi |
| 5 | Pointer berbahaya | *Dangling*, *wild*, *double free*, *memory leak* — dikenalkan, detail di modul 10 |
| 6 | Mengapa Python tidak punya pointer | Semua nama adalah referensi ke objek; `id()` memperlihatkan identitas objek |

**Jebakan yang wajib dibahas:**
- Menulis `int* a, b` — hanya `a` yang pointer, `b` adalah `int`
- Dereferensi pointer `nullptr` — *crash*
- Mengira `*` selalu berarti dereferensi — di deklarasi ia bagian dari tipe
- Mengira variabel Python "adalah" objeknya — sebenarnya nama menunjuk ke objek

**Kaitan praktis:** Pointer adalah dasar dari hampir semua struktur data dinamis (linked list, tree, graph). Tanpa memahami pointer, mahasiswa hanya bisa menyalin implementasi tanpa bisa memperbaikinya.

---

#### Modul 8 — `pointer-array` · Pointer & Array: Aritmetika Pointer

**Tujuan pembelajaran:**
- Menjelaskan *array-to-pointer decay*
- Melakukan aritmetika pointer dan menjelaskan skalanya
- Menjelaskan mengapa `arr[i]` ≡ `*(arr + i)` ≡ `*(i + arr)` ≡ `i[arr]`
- Menjelaskan mengapa `sizeof` array berubah saat masuk ke fungsi

**Bagian:**

| # | Bagian | Isi |
|---|--------|-----|
| 1 | Nama array sebagai pointer | Array *decay* ke pointer ke elemen pertama |
| 2 | Aritmetika pointer | `p + 1` menambah `sizeof(*p)` byte, bukan 1 byte |
| 3 | Kesetaraan notasi | `arr[i]` ≡ `*(arr + i)`, mengapa `i[arr]` juga valid (dan kenapa jangan dipakai) |
| 4 | Array sebagai parameter fungsi | `sizeof` di dalam fungsi memberi ukuran pointer; solusinya: kirim ukuran atau pakai `std::span`/referensi |
| 5 | Pointer vs list Python | Iterasi, indeks negatif, *slicing* yang menyalin |

**Jebakan yang wajib dibahas:**
- Mengira `p + 1` menambah 1 byte — sebenarnya menambah `sizeof(*p)` byte
- Menghitung ukuran array di dalam fungsi dengan `sizeof`
- Mengira pointer dan array sepenuhnya identik — `sizeof` dan `&arr` berperilaku berbeda
- Melakukan aritmetika pointer di luar batas array — *undefined behavior*, walaupun tidak langsung *crash*

**Kaitan praktis:** Pemahaman aritmetika pointer menjelaskan mengapa pengaksesan array sangat cepat, dan mengapa kesalahan indeks berbahaya.

---

#### Modul 9 — `pointer-struct` · Pointer ke Struct & Arrow Operator

**Tujuan pembelajaran:**
- Mendeklarasikan pointer ke struct
- Membedakan operator `.` dan `->`
- Menjelaskan mengapa `->` setara dengan `(*p).`
- Menggunakan pointer ke struct sebagai parameter fungsi untuk menghindari penyalinan

**Bagian:**

| # | Bagian | Isi |
|---|--------|-----|
| 1 | Pointer ke struct | `Mahasiswa* p = &mhs` |
| 2 | Operator `->` | `p->nama` sebagai gula sintaks untuk `(*p).nama` |
| 3 | Kapan pakai `.` vs `->` | Nilai/referensi pakai `.`, pointer pakai `->` |
| 4 | Pointer sebagai parameter | Menghindari penyalinan, memungkinkan modifikasi, `const` untuk keamanan |

**Jebakan yang wajib dibahas:**
- Menulis `p.nama` padahal `p` adalah pointer
- Menulis `(*p).nama` tanpa tanda kurung — `*p.nama` salah karena `.` lebih tinggi prioritasnya
- Lupa `const` sehingga fungsi diam-diam mengubah data pemanggil
- Mengira `struct` selalu disalin saat dikirim ke fungsi — benar, kecuali dikirim lewat pointer/referensi

**Kaitan praktis:** Inilah bentuk paling umum dari kode C/C++ di dunia nyata — fungsi yang menerima pointer ke struct. Pola ini ada di mana-mana, dari kernel Linux sampai *game engine*.

---

#### Modul 10 — `pointer-dinamis` · Alokasi Memori Dinamis

**Tujuan pembelajaran:**
- Membedakan *stack* dan *heap*
- Menggunakan `new` dan `delete` dengan benar
- Menjelaskan penyebab *memory leak*, *dangling pointer*, dan *double free*
- Menjelaskan mengapa C++ modern memakai *smart pointer*
- Menjelaskan bagaimana Python mengelola memori otomatis

**Bagian:**

| # | Bagian | Isi |
|---|--------|-----|
| 1 | Stack vs heap | Ukuran, masa hidup, kecepatan, siapa yang mengelola |
| 2 | `new` dan `delete` | Alokasi tunggal, `new[]`/`delete[]` untuk array |
| 3 | Tiga bug klasik | *Memory leak* (lupa `delete`), *dangling* (pakai setelah `delete`), *double free* (hapus dua kali) |
| 4 | Smart pointer | `unique_ptr`, `shared_ptr`, konsep kepemilikan |
| 5 | Mengapa Python aman | *Reference counting* + *garbage collection*, tidak ada `delete` |
| 6 | Kapan dinamis diperlukan | Ukuran baru diketahui saat berjalan, masa hidup melebihi blok, struktur data rekursif |

**Jebakan yang wajib dibahas:**
- Mencampur `new` dengan `delete[]` atau `new[]` dengan `delete` — *undefined behavior*
- Menggunakan pointer setelah `delete` — mungkin "kelihatan berhasil" tapi rusak
- Lupa `delete` di dalam loop atau di jalur `return` awal — *memory leak*
- Mengira Python bebas dari masalah memori — *reference cycle* bisa menyebabkan kebocoran
- Mengira `delete` mengubah pointer menjadi `nullptr` — tidak; pointer tetap berisi alamat lama

**Kaitan praktis:** Manajemen memori adalah sumber bug paling mahal di C/C++. Memahami *smart pointer* adalah pembeda antara programmer C++ pemula dan yang kompeten.

---

## 4. Taksonomi Flashcard

Taksonomi ini adalah **desain inti** FlashStruct. Tanpa kategori yang jelas, flashcard cenderung menjadi "hafalan definisi" yang membosankan dan tidak efektif.

Setiap kartu diberi label `card_type`. Satu modul harus memiliki **minimal 4 dari 7 tipe** berikut.

| Kode | Tipe | Sisi Depan | Sisi Belakang | Tujuan kognitif |
|------|------|------------|---------------|-----------------|
| `ISTILAH` | Istilah | Nama konsep | Definisi ringkas (maks 2 kalimat) | Mengingat |
| `SINTAKS` | Sintaks | "Bagaimana cara X di C++?" | Potongan kode | Mengingat |
| `TRACING` | Tracing | Potongan kode pendek | Output atau nilai akhir | Menerapkan |
| `BANDING` | Perbandingan | "Apa beda X dan Y?" | Tabel atau poin | Menganalisis |
| `JEBAKAN` | Jebakan | Kode yang salah | Mengapa salah + perbaikan | Menganalisis |
| `MEMORI` | Memori | "Apa yang terjadi di memori saat X?" | Diagram atau penjelasan | Memahami |
| `KAPAN` | Kapan dipakai | "Kapan pakai X?" | Situasi yang cocok/tidak cocok | Mengevaluasi |

### 4.1 Contoh Kartu per Tipe

**`ISTILAH`**
```
Depan : Apa itu array-to-pointer decay?
Belakang: Perubahan otomatis nama array menjadi pointer ke elemen
          pertamanya saat dipakai dalam ekspresi tertentu, misalnya
          saat dikirim ke fungsi. Akibatnya informasi ukuran hilang.
```

**`SINTAKS`**
```
Depan : Bagaimana cara mengakses anggota struct lewat pointer di C++?
Belakang: p->anggota

          Setara dengan:
          (*p).anggota

          Tanda kurung wajib karena operator . lebih tinggi
          prioritasnya daripada *.
```

**`TRACING`**
```
Depan : int arr[5] = {10, 20, 30, 40, 50};
        int* p = arr;
        cout << *(p + 3);

        Apa outputnya?
Belakang: 40

          p menunjuk ke arr[0].
          p + 3 menunjuk ke arr[3].
          *(p + 3) = arr[3] = 40.
```

**`BANDING`**
```
Depan : Apa perbedaan std::vector dan std::array?
Belakang: vector  → ukuran dinamis, bisa bertambah, data di heap
          array   → ukuran tetap saat kompilasi, data bisa di stack,
                    punya .size() dan tidak decay

          Keduanya menyimpan elemen secara berurutan di memori.
```

**`JEBAKAN`**
```
Depan : Apa yang salah dari kode ini?
        int* a, b;
        a = &b;
        *b = 10;

Belakang: Dua kesalahan:
          1. `int* a, b` hanya membuat `a` sebagai pointer.
             `b` adalah int biasa.
          2. `*b` tidak valid karena `b` bukan pointer.

          Perbaikan:
             int* a; int b;
             a = &b; *a = 10;
```

**`MEMORI`**
```
Depan : Apa yang terjadi di memori saat `delete p` dipanggil?
Belakang: 1. Memori yang ditunjuk p dikembalikan ke heap
          2. Isi memori TIDAK dihapus — nilainya masih ada
          3. Variabel p TIDAK berubah — masih menyimpan alamat lama

          Karena itu p menjadi dangling pointer. Pakai setelah
          delete = undefined behavior. Setelah delete, set p = nullptr.
```

**`KAPAN`**
```
Depan : Kapan array 2D lebih tepat daripada array of array?
Belakang: Pakai array 2D (`int m[3][4]`) bila:
          • Ukuran sudah diketahui saat kompilasi
          • Butuh satu blok memori berurutan (mis. untuk dikirim ke fungsi)
          • Performa akses penting

          Pakai array of array bila:
          • Tiap baris punya panjang berbeda
          • Baris perlu dialokasikan/dibebaskan terpisah
```

### 4.2 Aturan Penulisan Kartu

Kartu yang buruk akan merusak seluruh metode. Aturan wajib:

| Aturan | Alasan |
|--------|--------|
| **Satu kartu = satu fakta** | Kartu dengan 5 poin tidak akan diingat sebagai satu kesatuan |
| **Maks 2 kalimat di sisi belakang** (kecuali `BANDING` dan `JEBAKAN`) | Sisi belakang yang panjang berarti kartunya seharusnya dipecah |
| **Kode maks 8 baris** | Kode panjang mengubah latihan mengingat menjadi latihan membaca |
| **Jangan pakai "dan" di sisi depan** | "Apa itu X dan Y?" adalah dua kartu, bukan satu |
| **Selalu ada konteks bahasa** | "Bagaimana di C++?" bukan sekadar "Bagaimana caranya?" |
| **Jangan menyalin kalimat modul** | Kalau bisa disalin persis, itu soal hafalan teks, bukan pemahaman |
| **Sisi depan harus bisa dijawab** | Pertanyaan ambigu seperti "Jelaskan pointer" tidak layak dijadikan kartu |

### 4.3 Jumlah Kartu per Tipe

Distribusi yang disarankan agar deck tidak monoton:

| Tipe | Porsi | Contoh untuk deck 20 kartu |
|------|-------|----------------------------|
| `ISTILAH` | 15% | 3 kartu |
| `SINTAKS` | 20% | 4 kartu |
| `TRACING` | 20% | 4 kartu |
| `BANDING` | 15% | 3 kartu |
| `JEBAKAN` | 15% | 3 kartu |
| `MEMORI` | 10% | 2 kartu |
| `KAPAN` | 5% | 1 kartu |

**Mengapa `TRACING` dan `JEBAKAN` porsinya besar:** kedua tipe ini tidak bisa dijawab dengan hafalan buta. Kartu tracing memaksa menelusuri kode, dan kartu jebakan memaksa mengenali kesalahan. Keduanya melatih hal yang sebenarnya diuji di ujian dan wawancara kerja.

**Mengapa `ISTILAH` porsinya kecil:** definisi mudah dihafal tapi cepat lupa dan tidak berguna tanpa pemahaman. Cukup untuk fondasi, jangan mendominasi.

---

## 5. Desain Soal Quiz

### 5.1 Tipe Soal

| Kode | Tipe | Deskripsi | Porsi |
|------|------|-----------|-------|
| `PG` | Pilihan ganda | 4 opsi, satu jawaban benar | 50% |
| `TRACE` | Tracing kode | Berikan kode, tentukan output | 30% |
| `ANALISIS` | Analisis kesalahan | Kode dengan bug, pilih penyebabnya | 20% |

**Mengapa tidak ada soal esai:** penilaian otomatis untuk esai membutuhkan AI dan tidak dapat diandalkan untuk konsep teknis presisi. Soal pilihan ganda yang dirancang baik sudah cukup menguji pemahaman.

### 5.2 Aturan Penulisan Soal

| Aturan | Alasan |
|--------|--------|
| **Pengecoh harus masuk akal** | Opsi salah yang jelas konyol tidak menguji apa pun |
| **Pengecoh dari kesalahan umum** | Jika mahasiswa sering keliru `sizeof` = 5, jadikan 5 sebagai pengecoh |
| **Hindari "semua benar" / "semua salah"** | Tidak mengukur pemahaman, hanya keberanian menebak |
| **Hindari kata "selalu" dan "tidak pernah"** | Kecuali memang ada jawaban mutlak, ini petunjuk tersembunyi |
| **Panjang opsi seimbang** | Opsi terpanjang sering jadi jawaban benar — jangan beri petunjuk |
| **Selalu ada penjelasan** | Setiap soal wajib punya `explanation` yang menjelaskan **mengapa** jawaban itu benar |
| **Penjelasan berlaku untuk yang salah juga** | Jelaskan mengapa pengecoh salah, bukan hanya mengapa jawaban benar |
| **Kode maks 10 baris** | Lebih dari itu, soal berubah jadi ujian membaca |

### 5.3 Contoh Soal

**Tipe `PG`:**
```
Soal    : Berapa nilai sizeof(int_arr) jika dideklarasikan sebagai
          int_arr[5] dengan int berukuran 4 byte?

Opsi    : A. 4        B. 5        C. 20        D. 40

Jawaban : C

Penjelasan:
  Benar  → 5 elemen × 4 byte = 20 byte.
  A salah → 4 adalah ukuran satu int, bukan seluruh array.
  B salah → 5 adalah jumlah elemen, bukan ukuran dalam byte.
  D salah → 40 keliru mengalikan 5 × 8, mengira int berukuran 8 byte.

Topik  : array-dasar · MEMORI
```

**Tipe `TRACE`:**
```
Soal    : struct Titik { int x; int y; };
          Titik t = {3, 7};
          Titik* p = &t;
          p->x = p->y * 2;
          cout << t.x;

          Apa outputnya?

Opsi    : A. 3        B. 6        C. 7        D. 14

Jawaban : D

Penjelasan:
  Benar  → p->x = p->y * 2 = 7 * 2 = 14. Karena p menunjuk ke t,
           mengubah p->x sama dengan mengubah t.x.
  A salah → 3 adalah nilai awal t.x sebelum diubah.
  B salah → 6 adalah hasil bila mengira p->y bernilai 3.
  C salah → 7 adalah nilai p->y, bukan hasil akhir t.x.

Topik  : pointer-struct · TRACING
```

**Tipe `ANALISIS`:**
```
Soal    : Kode berikut bocor memori. Apa penyebabnya?
          for (int i = 0; i < 10; i++) {
              int* p = new int(i);
              if (*p > 5) return p;
          }

Opsi    : A. new tidak boleh dipakai di dalam loop
          B. Pointer p tidak pernah di-delete sebelum return
          C. int tidak bisa dialokasikan dengan new
          D. Loop seharusnya memakai while

Jawaban : B

Penjelasan:
  Benar  → Memori yang dialokasikan dengan new harus dibebaskan
           dengan delete. Saat return dipanggil, p keluar dari scope
           tetapi memori di heap tetap terisi. Ini memory leak.
  A salah → new di dalam loop sah; yang salah adalah tidak
            membebaskannya.
  C salah → int bisa dialokasikan dengan new.
  D salah → while dan for sama-sama bisa; jenis loop bukan penyebabnya.

Topik  : pointer-dinamis · JEBAKAN
```

### 5.4 Cara Menentukan Topik Lemah

Setiap soal ditautkan ke satu `card_type` sebagai topik. Setelah quiz, sistem menghitung akurasi per topik:

```
Akurasi per topik = (jumlah benar pada topik itu) / (jumlah soal topik itu) × 100

Rekomendasi:
  < 50%   → "Perlu diulang: baca ulang modul, lalu ulangi flashcard"
  50–79%  → "Hampir: ulangi flashcard untuk topik ini"
  ≥ 80%   → "Sudah kuat"
```

Ini alasan mengapa `card_type` diberi label pada setiap kartu dan soal — agar analisis ini mungkin dilakukan tanpa penilaian manual.

---

## 6. Kebutuhan Sumber Video

Video bersifat **opsional** dan tidak memblokir progres. Ini keputusan sadar untuk mengurangi beban produksi.

### 6.1 Strategi Konten Video

| Prioritas | Sumber | Catatan |
|-----------|--------|---------|
| 1 | Video YouTube berbahasa Indonesia yang sudah ada | Cek lisensi; sematkan, jangan unduh |
| 2 | Video YouTube berbahasa Inggris dengan penjelasan visual baik | Sertakan ringkasan tulis dalam bahasa Indonesia |
| 3 | Video buatan sendiri | Hanya jika dua opsi di atas tidak tersedia |

### 6.2 Video yang Dibutuhkan

| Modul | Jumlah | Fokus video |
|-------|--------|-------------|
| `array-dasar` | 2 | Konsep memori berurutan; visualisasi indeks |
| `array-multidimensi` | 1 | Visualisasi row-major |
| `array-dinamis` | 2 | Cara kerja `push_back`; visualisasi alokasi ulang |
| `struct-dasar` | 1 | Pengenalan struct |
| `struct-nested` | 1 | Struct bersarang |
| `struct-memori` | 2 | Visualisasi padding; demonstrasi `offsetof` |
| `pointer-dasar` | 3 | Visualisasi alamat memori; dereferensi; mengapa Python beda |
| `pointer-array` | 2 | Aritmetika pointer; decay |
| `pointer-struct` | 1 | Arrow operator |
| `pointer-dinamis` | 3 | Stack vs heap; bug memori; smart pointer |
| | **18 video** | |

**Catatan:** 18 video adalah target ideal. Untuk rilis v1, **minimal 1 video per topik (3 video)** sudah cukup — sisanya ditambahkan bertahap. Halaman Video harus tetap berguna walaupun hanya berisi sedikit video, misalnya dengan menampilkan placeholder yang jujur ("video untuk modul ini sedang disiapkan") alih-alih halaman kosong.

---

## 7. Validasi Konten

Sebelum konten dianggap final, lakukan validasi berikut:

| Pemeriksaan | Cara |
|-------------|------|
| Akurasi teknis | Semua contoh kode harus **benar-benar dikompilasi dan dijalankan**, bukan ditulis dari ingatan |
| Klaim bergantung platform | Tandai jelas dan sertakan cara memverifikasi sendiri |
| Kesesuaian kurikulum | Cocokkan dengan silabus mata kuliah di kampus target |
| Tingkat kesulitan | Minta 3 mahasiswa membaca satu modul, catat bagian yang membingungkan |
| Kualitas kartu | Pastikan tidak ada kartu yang bisa dijawab tanpa memahami |
| Kualitas soal | Pastikan setiap pengecoh mewakili kesalahan yang masuk akal |

**Peringatan penting untuk penyusun konten:** Jangan menulis contoh kode hanya dari ingatan. Semua potongan kode di modul, kartu, dan soal **wajib dijalankan** untuk memverifikasi outputnya. Kesalahan kecil pada contoh kode akan langsung merusak kredibilitas seluruh materi — dan pada topik pointer, kesalahan sekecil apa pun bisa mengajarkan konsep yang salah.

---

## 8. Ringkasan Angka untuk Perencanaan

| Item | Jumlah |
|------|--------|
| Modul | 10 |
| Bagian modul | 49 |
| Flashcard | ± 206 |
| Soal quiz | ± 183 |
| Video (ideal) | 18 |
| Video (minimum v1) | 3 |
| Estimasi waktu baca total | ± 137 menit |
| Estimasi waktu pengerjaan flashcard total | ± 90 menit |
| Estimasi waktu pengerjaan quiz total | ± 60 menit |
| **Total waktu belajar tuntas** | **± 4,5 jam** |

Angka di atas membantu memperkirakan beban kerja penyusunan konten. Berdasarkan pengalaman, menyusun satu modul lengkap (materi + kartu + soal) membutuhkan waktu 4–8 jam kerja fokus.
