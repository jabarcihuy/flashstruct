-- 012_video_pembelajaran.sql
-- Mengisi video pembelajaran C++ (Bahasa Indonesia) untuk setiap modul (1 s.d. 10).
-- Sumber: Seri Belajar C++ Dasar & OOP oleh Kelas Terbuka (Faqihza Mukhlish).
-- =========================================================

begin;

delete from public.video;

insert into public.video (modul_id, youtube_id, judul, deskripsi, durasi_detik, urutan)
select m.id, v.youtube_id, v.judul, v.deskripsi, v.durasi_detik, v.urutan
from public.modul m
join (values
  ('array-dasar',
   '8WhUADLI4RQ',
   E'Belajar C++ [Dasar] - 42 - Pendahuluan Array',
   E'Konsep dasar array, deklarasi, pengindeksan elemen, serta representasi elemen array yang tersimpan berurutan di memori.',
   1033,
   1),

  ('array-multidimensi',
   '-hsKUD4fVRE',
   E'Belajar C++ [Dasar] - 46 - Multidimensi Array | Built-in',
   E'Pemahaman array 2 dimensi (matriks), representasi baris dan kolom, serta pemetaan indeks baris-kolom di memori.',
   594,
   1),

  ('array-dinamis',
   'o1DegduG140',
   E'Belajar C++ [Dasar] - 43 - Array || Standard Library',
   E'Pengenalan std::array dan konsep container modern C++, fungsi utilitas ukuran (.size()), dan transisi menuju array dinamis.',
   535,
   1),

  ('struct-dasar',
   'ELCI_U4OF5w',
   E'Belajar C++ [Dasar] - 56 - Struct',
   E'Membuat tipe data bentukan baru dengan struct, mengelompokkan variabel bertipe heterogen, serta mengakses member dengan operator titik.',
   595,
   1),

  ('struct-nested',
   'b2N3_dA8VBU',
   E'Belajar C++ [Dasar] - 57 - Nesting Struct',
   E'Struktur bertingkat (nested struct), array of struct, dan pemodelan entitas yang saling berhubungan secara terstruktur.',
   640,
   1),

  ('struct-memori',
   '4wWobjVejnU',
   E'Belajar C++ [OOP] - 08 - Memory dan Address dari Object',
   E'Bedah struktur memori objek/struct di C++, analisis alamat memori tiap member, ukuran sizeof, serta konsep padding dan alignment.',
   1654,
   1),

  ('pointer-dasar',
   'O1kWNj5Ikro',
   E'Belajar C++ [Dasar] - 38 - Pointer',
   E'Konsep pointer di C++, operator alamat (&), operator dereferensi (*), dan cara memanipulasi nilai variabel lewat alamat memori.',
   873,
   1),

  ('pointer-array',
   'ah8RcGXoK5A',
   E'Belajar C++ [Dasar] - 40 - Fungsi dengan Pointer',
   E'Mengirim pointer dan array ke parameter fungsi, konsep decay array menjadi pointer, serta manipulasi data array lewat pointer.',
   560,
   1),

  ('pointer-struct',
   '9C03NT254rA',
   E'Belajar C++ [OOP] - 20 - This & Cascading Function Calls',
   E'Mengakses anggota struct/objek lewat pointer menggunakan arrow operator (->) dan peran pointer implisit this pada C++.',
   1130,
   1),

  ('pointer-dinamis',
   'LaFxsl8rhTs',
   E'Belajar C++ [OOP] - 07 - Berbagai cara membuat Object',
   E'Alokasi memori dinamis di heap menggunakan keyword new, menyimpan alamat ke pointer, dan membebaskan memori dengan delete.',
   896,
   1)
) as v(slug, youtube_id, judul, deskripsi, durasi_detik, urutan)
  on m.slug = v.slug;

commit;
