-- =========================================================
-- Seed: Modul 9 — pointer-struct
-- Pointer ke Struct & Arrow Operator
-- Semua contoh kode DIKOMPILASI dan DIJALANKAN (GCC 16.2.1)
-- =========================================================

insert into public.modul (slug, judul, topik, deskripsi, estimasi_menit, urutan)
values ('pointer-struct', 'Pointer ke Struct & Arrow Operator', 'pointer',
  'Operator -> dan (*)., plus mengapa pointer lebih efisien untuk struct besar.', 12, 9);

insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
select m.id, v.slug, v.judul, v.konten_md, v.urutan
from public.modul m, (values

('pointer-ke-struct', 'Pointer ke Struct', $md$Pointer bisa menunjuk ke struct, sama seperti ke tipe lain.

```cpp
struct Titik { int x; int y; };

Titik t = {3, 7};
Titik* pt = &t;      // pointer ke struct
```

## Cara Mengakses Anggota

Ada **dua cara**, dan keduanya setara:

```cpp
(*pt).x      // BENAR - dereferensi dulu, lalu akses anggota
pt->x        // BENAR - cara singkat
```

**Bukti terukur:** ketiganya menghasilkan nilai yang sama.

```cpp
cout << t.x;        // 3
cout << pt->x;      // 3
cout << (*pt).x;    // 3
```

## Mengapa Ada Operator ->

`(*pt).x` benar tetapi **merepotkan ditulis** dan mudah salah. Tanda kurung wajib ada karena operator `.` lebih tinggi prioritasnya daripada `*`.

Tanpa tanda kurung:

```cpp
*pt.x        // SALAH - dibaca sebagai *(pt.x)
```

Ini akan error karena `pt.x` tidak valid (pt adalah pointer, bukan struct).

Karena itu C++ menyediakan `->` sebagai singkatan:

```cpp
pt->x   ==   (*pt).x
```

> [!TIPS]
> Pakai `->` untuk pointer. Pakai `.` untuk nilai atau referensi. Aturan sederhana ini mencegah kebingungan.

## Mengubah Anggota Lewat Pointer

```cpp
Titik t = {3, 7};
Titik* pt = &t;

pt->x = 99;

cout << t.x;   // 99 - struct ASLI berubah
```

Karena pointer menunjuk ke `t` yang asli, mengubah lewat pointer mengubah `t`.

## Tabel Ringkasan

| Ekspresi | Valid? | Keterangan |
|----------|--------|------------|
| `t.x` | Ya | `t` adalah struct |
| `pt->x` | Ya | `pt` adalah pointer |
| `(*pt).x` | Ya | Dereferensi lalu akses |
| `pt.x` | **Tidak** | `pt` pointer, bukan struct |
| `*pt.x` | **Tidak** | Prioritas salah |
| `t->x` | **Tidak** | `t` bukan pointer |$md$, 1),

('struct-besar-dan-pointer', 'Struct Besar & Pointer', $md$Mengapa pointer penting untuk struct? Karena **menghindari penyalinan**.

## Masalah: Struct Besar Disalin

```cpp
struct Besar {
    int data[1000];
};

cout << sizeof(Besar);   // 4000 byte
```

Kalau struct ini dikirim **sebagai nilai** ke fungsi:

```cpp
void proses(Besar b) {    // menyalin 4000 byte!
    // ...
}
```

Setiap pemanggilan menyalin **4000 byte**. Kalau dipanggil 1000 kali, itu 4 juta byte penyalinan yang tidak perlu.

**Bukti terukur:** `sizeof(Besar)` = 4000 byte, sedangkan `sizeof(Besar*)` hanya 8 byte.

## Solusi: Kirim Pointer

```cpp
void proses(Besar* b) {   // menyalin 8 byte saja
    // ...
}

proses(&data);
```

Hanya **8 byte** yang disalin (ukuran pointer), bukan 4000 byte.

## Tiga Cara Mengirim Struct

| Cara | Disalin? | Bisa diubah? | Kapan dipakai |
|------|----------|--------------|---------------|
| `void f(Titik t)` | **Ya** (seluruh struct) | Tidak | Struct kecil + perlu salinan |
| `void f(Titik* t)` | Hanya 8 byte | **Ya** | Perlu mengubah data asli |
| `void f(const Titik* t)` | Hanya 8 byte | Tidak | **Paling umum** - hanya membaca |

## Bukti: Nilai vs Pointer

**Kirim sebagai nilai — TIDAK berubah:**

```cpp
void ubahNilai(Mahasiswa m) {
    m.ipk = 4.0;
}

Mahasiswa m = {"Rani", 20, 3.5};
ubahNilai(m);
// m.ipk tetap 3.5
```

**Kirim sebagai pointer — BERUBAH:**

```cpp
void ubahPointer(Mahasiswa* m) {
    m->ipk = 4.0;
}

ubahPointer(&m);
// m.ipk jadi 4.0
```

**Output terukur:**

```
Sebelum:               Rani ipk=3.5
Setelah ubahNilai:     Rani ipk=3.5   <- TIDAK berubah
Setelah ubahPointer:   Rani ipk=4     <- BERUBAH
```

## Pola Paling Umum: const Pointer

```cpp
void cetak(const Mahasiswa* m) {
    cout << m->nama << " ipk=" << m->ipk;
    // m->ipk = 4.0;   // ERROR - tidak bisa diubah
}
```

`const` mencegah fungsi mengubah data, sementara pointer mencegah penyalinan. Ini pola yang paling sering dipakai di kode C++ profesional.

> [!TIPS]
> Aturan praktis: kirim struct sebagai `const T*` kalau hanya membaca, dan `T*` kalau perlu mengubah. Kirim sebagai nilai (`T`) hanya untuk struct kecil (di bawah ~16 byte) yang memang perlu disalin.$md$, 2),

('array-of-struct-pointer', 'Array of Struct Lewat Pointer', $md$Pointer juga berguna untuk mengakses array of struct.

## Akses dengan Aritmetika Pointer

```cpp
Mahasiswa daftar[3] = {
    {"Rani", 20, 3.75},
    {"Budi", 21, 3.20},
    {"Citra", 22, 3.90}
};

Mahasiswa* p = daftar;   // decay ke &daftar[0]

for (int i = 0; i < 3; i++) {
    cout << (p + i)->nama;
}
```

**Output terukur:**

```
(p+0)->nama = Rani
(p+1)->nama = Budi
(p+2)->nama = Citra
```

## Bentuk yang Setara

Keempat bentuk ini menghasilkan hasil yang sama:

```cpp
daftar[i].nama        // cara indeks biasa
p[i].nama             // pointer + indeks
(p + i)->nama         // aritmetika pointer + arrow
(*(p + i)).nama       // eksplisit
```

**Bukti:** `p[1].nama` = `Budi`, sama dengan `(p+1)->nama`.

## Kapan Pakai yang Mana

| Bentuk | Kapan dipakai |
|--------|---------------|
| `daftar[i].nama` | **Paling jelas** - pakai ini untuk kode baru |
| `p[i].nama` | Saat `p` sudah pointer |
| `(p + i)->nama` | Saat menjelaskan aritmetika pointer |

> [!TIPS]
> Walaupun `(p + i)->nama` valid, `p[i].nama` lebih mudah dibaca. Pakai bentuk yang paling jelas kecuali ada alasan khusus.

## Mengubah Elemen Lewat Pointer

```cpp
Mahasiswa* p = daftar;

p[1].ipk = 4.0;      // atau (p + 1)->ipk = 4.0

cout << daftar[1].ipk;   // 4.0 - array ASLI berubah
```

## Iterasi dengan Pointer

```cpp
// Gaya pointer
for (Mahasiswa* p = daftar; p != daftar + 3; ++p) {
    cout << p->nama << "\n";
}
```

Perhatikan `daftar + 3` — ini **one-past-the-end**, dan seperti dijelaskan di modul 7, ini **LEGAL** (bukan UB). Yang UB hanya mendereferensinya.

## Jebakan: nullptr

```cpp
Mahasiswa* kosong = nullptr;

if (kosong) {
    // tidak dijalankan
}

// kosong->nama;   // UB - tidak dijalankan
```

Selalu periksa pointer sebelum mengakses anggotanya, terutama kalau pointer berasal dari parameter fungsi.$md$, 3),

('padanan-python', 'Padanan di Python', $md$Python tidak punya pointer, tetapi ada perbedaan penting yang perlu dipahami.

## Python Tidak Butuh Arrow Operator

```python
@dataclass
class Titik:
    x: int
    y: int

t = Titik(3, 7)
print(t.x)     # 3 - selalu pakai titik
```

Tidak ada `t->x` karena tidak ada pointer. Semua akses memakai titik.

## Perbedaan Penting: Objek Disalin atau Dibagi?

Ini sumber kebingungan terbesar saat pindah dari C++ ke Python.

**Di C++, struct disalin:**

```cpp
Titik a = {3, 7};
Titik b = a;      // SALINAN

b.x = 99;
cout << a.x;      // 3 - TIDAK berubah
```

**Di Python, objek dibagi:**

```python
a = Titik(3, 7)
b = a             # REFERENSI yang sama

b.x = 99
print(a.x)        # 99 - IKUT berubah!
```

## Mengapa Berbeda

| Aspek | C++ struct | Python objek |
|-------|-----------|--------------|
| `b = a` | Menyalin **nilai** | Menyalin **referensi** |
| Mengubah `b` | Tidak mempengaruhi `a` | **Mempengaruhi `a`** |
| Butuh pointer? | Ya, untuk berbagi | Tidak, sudah otomatis |

Di C++, untuk membuat dua variabel menunjuk objek yang sama, kamu **butuh pointer**. Di Python, itu terjadi **secara otomatis**.

## Cara Membuat Salinan di Python

```python
import copy

a = Titik(3, 7)
b = copy.copy(a)      # salinan dangkal

b.x = 99
print(a.x)            # 3 - TIDAK berubah
```

Untuk objek bersarang, gunakan `copy.deepcopy()`.

## Ringkasan Perbandingan

| Operasi | C++ | Python |
|---------|-----|--------|
| Akses anggota | `t.x` (nilai) atau `pt->x` (pointer) | `t.x` selalu |
| `b = a` | Menyalin nilai | Menyalin referensi |
| Berbagi objek | Butuh pointer | Otomatis |
| Salinan | Otomatis saat `=` | Perlu `copy()` |
| Null check | Perlu (`if (p)`) | Tidak ada null pointer |

> [!INFO]
> Python menghilangkan pointer dengan membuat semua nama menjadi referensi. Ini menghilangkan banyak bug (dangling pointer, null dereference), tetapi juga menghilangkan kontrol tingkat rendah yang kadang dibutuhkan.$md$, 4)

) as v(slug, judul, konten_md, urutan)
where m.slug = 'pointer-struct';

-- ============ FLASHCARD (10 kartu) ============
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Bagaimana cara mendeklarasikan pointer ke struct?',
 E'struct Titik { int x; int y; };\n\nTitik t = {3, 7};\nTitik* pt = &t;   // pointer ke struct',
 'SINTAKS', E'Titik t = {3, 7};\\nTitik* pt = &t;', 'cpp', 1),

(E'Apa dua cara mengakses anggota struct lewat pointer?',
 E'1. (*pt).x   - dereferensi dulu, lalu akses anggota\n2. pt->x     - cara SINGKAT (arrow operator)\n\nKeduanya SETARA dan menghasilkan nilai yang sama.',
 'SINTAKS', E'(*pt).x    // cara panjang\\npt->x      // cara singkat', 'cpp', 2),

(E'Mengapa operator -> diperlukan?',
 E'Karena (*pt).x merepotkan ditulis dan mudah salah.\n\nTanda kurung WAJIB karena operator . lebih tinggi\nprioritasnya daripada *.\n\nTanpa kurung:\n*pt.x  SALAH - dibaca sebagai *(pt.x)\n\nKarena itu C++ menyediakan -> sebagai singkatan.',
 'ISTILAH', null, null, 3),

(E'Apa perbedaan aturan pakai . dan ->?',
 E'. (titik)   : untuk NILAI atau REFERENSI\n-> (arrow)  : untuk POINTER\n\nTitik t = {3,7};\nt.x        // BENAR\nt->x       // SALAH\n\nTitik* pt = &t;\npt->x      // BENAR\npt.x       // SALAH',
 'BANDING', null, null, 4),

(E'Mengapa pointer penting untuk struct besar?',
 E'Karena MENGHINDARI penyalinan.\n\nstruct Besar { int data[1000]; };\nsizeof(Besar) = 4000 byte\n\nKirim sebagai nilai  -> salin 4000 byte setiap panggilan\nKirim sebagai pointer -> salin 8 byte saja\n\nSelisihnya 500x lebih hemat!',
 'MEMORI', null, null, 5),

(E'struct Mahasiswa { double ipk; };\n\nvoid ubahPointer(Mahasiswa* m) { m->ipk = 4.0; }\n\nMahasiswa m = {3.5};\nubahPointer(&m);\ncout << m.ipk;',
 E'Output: 4\n\nKirim sebagai POINTER = alamat dikirim.\nMengubah m->ipk mengubah struct ASLI.\n\nBandingkan dengan kirim nilai: hasilnya tetap 3.5.',
 'TRACING', E'void ubahPointer(Mahasiswa* m) { m->ipk = 4.0; }\\nMahasiswa m = {3.5};\\nubahPointer(&m);\\ncout << m.ipk;  // jadi 4', 'cpp', 6),

(E'Bagaimana cara mengakses array of struct lewat pointer?',
 E'Mahasiswa daftar[3];\nMahasiswa* p = daftar;\n\nEmpat bentuk SETARA:\n  daftar[i].nama\n  p[i].nama\n  (p + i)->nama\n  (*(p + i)).nama\n\nPaling jelas: p[i].nama',
 'SINTAKS', E'Mahasiswa* p = daftar;\\ncout << (p + i)->nama;\\ncout << p[i].nama;   // setara', 'cpp', 7),

(E'Mengapa perlu memeriksa pointer sebelum mengakses anggotanya?',
 E'Karena mengakses anggota lewat nullptr adalah UB.\n\nMahasiswa* p = nullptr;\np->nama;   // UB!\n\nSelalu periksa:\nif (p) { cout << p->nama; }\n\nTerutama penting kalau pointer berasal dari parameter fungsi.',
 'JEBAKAN', E'Mahasiswa* p = nullptr;\\nif (p) { cout << p->nama; }', 'cpp', 8),

(E'Bagaimana cara mengirim struct agar tidak disalin dan tidak bisa diubah?',
 E'Pakai const pointer:\n\nvoid cetak(const Mahasiswa* m) {\n    cout << m->nama;\n    // m->ipk = 4.0;   // ERROR\n}\n\nconst mencegah perubahan, pointer mencegah penyalinan.\nIni pola PALING UMUM di kode C++ profesional.',
 'KAPAN', E'void cetak(const Mahasiswa* m) {\\n    cout << m->nama;\\n}', 'cpp', 9),

(E'Apa perbedaan perilaku b = a pada struct C++ dan objek Python?',
 E'C++ : b = a menyalin NILAI. Mengubah b TIDAK\n      mempengaruhi a.\n\nPython: b = a menyalin REFERENSI. Mengubah b IKUT\n        mempengaruhi a.\n\nIni perbedaan MENDASAR:\n- C++ struct = tipe nilai\n- Python objek = tipe referensi',
 'BANDING', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'pointer-struct';

-- ============ SOAL QUIZ (10 soal) ============
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Apa dua cara mengakses anggota struct lewat pointer?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: (*pt).x dan pt->x\n\nKeduanya setara dan menghasilkan nilai yang sama.\n\npt->x adalah cara singkat untuk (*pt).x. Tanda kurung pada cara panjang WAJIB ada karena operator . lebih tinggi prioritasnya daripada *.\n\npt.x salah - pt adalah pointer, bukan struct.',
 1),

(E'Mengapa operator -> diperlukan?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Karena (*pt).x merepotkan ditulis dan mudah salah.\n\nTanda kurung wajib ada karena operator . lebih tinggi prioritasnya daripada *. Tanpa kurung, *pt.x dibaca sebagai *(pt.x) yang error.\n\nKarena itu C++ menyediakan -> sebagai singkatan yang lebih jelas.',
 2),

(E'Apa aturan pakai operator . dan ->?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: . untuk nilai/referensi; -> untuk pointer.\n\nTitik t = {3,7};\nt.x        // BENAR (t adalah nilai)\nt->x       // SALAH\n\nTitik* pt = &t;\npt->x      // BENAR (pt adalah pointer)\npt.x       // SALAH',
 3),

(E'struct Titik { int x; int y; };\nTitik t = {3, 7};\nTitik* pt = &t;\npt->x = 99;\ncout << t.x;',
 E'struct Titik { int x; int y; };\\nTitik t = {3, 7};\\nTitik* pt = &t;\\npt->x = 99;\\ncout << t.x;', 'cpp', 'TRACE', 'TRACING',
 E'Output: 99\n\npt menunjuk ke t yang ASLI.\nMengubah pt->x sama dengan mengubah t.x.\n\nPengecoh 3 = nilai awal sebelum diubah.',
 4),

(E'Mengapa pointer penting untuk struct besar?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena menghindari penyalinan seluruh struct.\n\nstruct Besar { int data[1000]; };\nsizeof(Besar) = 4000 byte\n\nKirim sebagai nilai  -> salin 4000 byte setiap panggilan\nKirim sebagai pointer -> salin 8 byte saja\n\nSelisihnya 500x lebih hemat. Untuk fungsi yang dipanggil sering, ini sangat signifikan.',
 5),

(E'struct Mahasiswa { double ipk; };\nvoid ubah(Mahasiswa m) { m.ipk = 4.0; }\n\nMahasiswa m = {3.5};\nubah(m);\ncout << m.ipk;',
 E'void ubah(Mahasiswa m) { m.ipk = 4.0; }\\nMahasiswa m = {3.5};\\nubah(m);\\ncout << m.ipk;', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 3.5\n\nKirim sebagai NILAI = SALINAN. Mengubah m.ipk di dalam fungsi tidak mempengaruhi struct asli.\n\nPengecoh 4 salah - itu hasil kalau dikirim sebagai pointer.\n\nUntuk mengubah aslinya: void ubah(Mahasiswa* m) { m->ipk = 4.0; }',
 6),

(E'Mahasiswa daftar[3] = {{"Rani"},{"Budi"},{"Citra"}};\nMahasiswa* p = daftar;\ncout << (p + 1)->nama;',
 E'Mahasiswa* p = daftar;\\ncout << (p + 1)->nama;', 'cpp', 'TRACE', 'TRACING',
 E'Output: Budi\n\np menunjuk ke daftar[0]. p + 1 menunjuk ke daftar[1]. (p + 1)->nama = daftar[1].nama = "Budi"\n\nSetara dengan p[1].nama.\n\nPengecoh Rani = daftar[0]. Citra = daftar[2].',
 7),

(E'Bagaimana cara mengirim struct agar tidak disalin dan tidak bisa diubah?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: Pakai const pointer.\n\nvoid cetak(const Mahasiswa* m) {\n    cout << m->nama;\n    // m->ipk = 4.0;   // ERROR\n}\n\nconst mencegah perubahan, pointer mencegah penyalinan. Ini pola paling umum di kode C++ profesional.\n\nMahasiswa m (nilai) juga tidak bisa diubah kalau const, tetapi tetap disalin.',
 8),

(E'Mengapa mengakses anggota lewat nullptr berbahaya?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena itu undefined behavior.\n\nMahasiswa* p = nullptr;\np->nama;   // UB!\n\nSelalu periksa: if (p) { cout << p->nama; }\n\nTerutama penting kalau pointer berasal dari parameter fungsi, karena pemanggil mungkin mengirim nullptr.',
 9),

(E'Apa perbedaan perilaku b = a pada struct C++ dan objek Python?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: C++ menyalin NILAI; Python menyalin REFERENSI.\n\nC++: Titik b = a; -> salinan. Mengubah b tidak mempengaruhi a.\n\nPython: b = a -> referensi yang sama. Mengubah b IKUT mempengaruhi a.\n\nIni perbedaan mendasar antara tipe nilai (C++ struct) dan tipe referensi (Python objek).',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'pointer-struct';

-- ============ OPSI JAWABAN (40 opsi) ============
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'(*pt).x dan pt->x', true, 1),
  (1, 'B', E'pt.x dan pt->x', false, 2),
  (1, 'C', E'*pt.x dan pt->x', false, 3),
  (1, 'D', E'pt.x dan (*pt)->x', false, 4),
  (2, 'A', E'Karena (*pt).x merepotkan ditulis dan tanda kurungnya mudah terlupa', true, 1),
  (2, 'B', E'Karena (*pt).x tidak valid', false, 2),
  (2, 'C', E'Karena operator . tidak bisa dipakai pada struct', false, 3),
  (2, 'D', E'Karena -> lebih cepat dijalankan', false, 4),
  (3, 'A', E'. untuk nilai/referensi; -> untuk pointer', true, 1),
  (3, 'B', E'. untuk pointer; -> untuk nilai', false, 2),
  (3, 'C', E'Keduanya bisa dipakai bergantian', false, 3),
  (3, 'D', E'-> hanya untuk array', false, 4),
  (4, 'A', E'99', true, 1),
  (4, 'B', E'3', false, 2),
  (4, 'C', E'7', false, 3),
  (4, 'D', E'Error', false, 4),
  (5, 'A', E'Karena menghindari penyalinan seluruh struct', true, 1),
  (5, 'B', E'Karena pointer lebih mudah dibaca', false, 2),
  (5, 'C', E'Karena struct tidak bisa disalin', false, 3),
  (5, 'D', E'Karena pointer menghemat memori saat disimpan', false, 4),
  (6, 'A', E'3.5', true, 1),
  (6, 'B', E'4', false, 2),
  (6, 'C', E'0', false, 3),
  (6, 'D', E'Error', false, 4),
  (7, 'A', E'Budi', true, 1),
  (7, 'B', E'Rani', false, 2),
  (7, 'C', E'Citra', false, 3),
  (7, 'D', E'Error', false, 4),
  (8, 'A', E'Pakai const pointer: void cetak(const Mahasiswa* m)', true, 1),
  (8, 'B', E'Pakai nilai biasa: void cetak(Mahasiswa m)', false, 2),
  (8, 'C', E'Pakai referensi biasa: void cetak(Mahasiswa& m)', false, 3),
  (8, 'D', E'Tidak bisa dilakukan di C++', false, 4),
  (9, 'A', E'Karena itu undefined behavior', true, 1),
  (9, 'B', E'Karena compiler menolak', false, 2),
  (9, 'C', E'Karena nullptr tidak bisa diakses', false, 3),
  (9, 'D', E'Karena struct tidak punya anggota', false, 4),
  (10, 'A', E'C++ menyalin NILAI; Python menyalin REFERENSI', true, 1),
  (10, 'B', E'Keduanya menyalin nilai', false, 2),
  (10, 'C', E'Keduanya menyalin referensi', false, 3),
  (10, 'D', E'C++ menyalin referensi; Python menyalin nilai', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'pointer-struct';
