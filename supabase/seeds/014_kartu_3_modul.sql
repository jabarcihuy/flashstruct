-- =========================================================
-- FlashStruct — Flashcard untuk 3 Modul Inti
--
-- Prasyarat: jalankan 013_kurikulum_ringkas_3_modul.sql DULU
-- (skrip itu yang membuat modul dan bagiannya).
--
-- Isi: 3 modul x 5 kartu = 15 kartu
-- Soal TIDAK di sini — ada di 015_soal_3_modul.sql (tetap 10 per modul).
--
-- CATATAN PENTING soal format:
--   Flashcard dirender sebagai TEKS POLOS (whitespace-pre-wrap di
--   Flashcard.tsx), BUKAN markdown. Jadi:
--     - backtick akan tampil mentah -> jangan dipakai
--     - tanda * akan tampil mentah  -> jangan dipakai untuk miring
--   Tanda baca ditulis apa adanya, dan kode ditulis di baris terpisah.
--
-- Batas skema yang dipatuhi:
--   depan <= 400, belakang <= 800
--   kode terisi -> bahasa_kode wajib
-- =========================================================

begin;

delete from public.flashcard
where modul_id in (select id from public.modul where slug in ('array-dasar','struct-dasar','pointer-dasar'));

-- =========================================================
-- ARRAY — 5 kartu
-- =========================================================
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa sifat utama tipe data elemen pada Array?',
 E'Homogen, yaitu semua elemen harus bertipe data yang sama.',
 'ISTILAH', null, null, 1),

(E'Bagaimana letak penyimpanan elemen Array di dalam memori komputer?',
 E'Kontigu, yaitu tersimpan secara berurutan.',
 'MEMORI', null, null, 2),

(E'Tuliskan contoh deklarasi Array 5 elemen integer dalam bahasa C!',
 E'int A[5];',
 'SINTAKS', E'int A[5];', 'cpp', 3),

(E'Apa sebutan untuk penunjuk nomor posisi elemen di dalam Array?',
 E'Indeks.',
 'ISTILAH', null, null, 4),

(E'Apa keunggulan utama Array dalam hal akses data?',
 E'Pengaksesan acak secara langsung (random access) tanpa harus melewati elemen lain.',
 'KAPAN', null, null, 5)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'array-dasar';

-- =========================================================
-- STRUCT — 5 kartu
-- =========================================================
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa pengertian dari Struct dalam bahasa C?',
 E'Koleksi variabel dengan berbagai tipe data berbeda yang dikelompokkan dalam satu nama.',
 'ISTILAH', null, null, 1),

(E'Operator apa yang digunakan untuk mengakses anggota (field) dari variabel Struct?',
 E'Operator titik (.).',
 'SINTAKS', null, null, 2),

(E'Berbeda dengan Array, bagaimana sifat elemen atau variabel di dalam Struct?',
 E'Heterogen, yaitu dapat memiliki tipe data yang berbeda-beda.',
 'BANDING', null, null, 3),

(E'Jika ada lebih dari satu variabel struktur yang dideklarasikan secara bersamaan, tanda pemisahnya adalah...',
 E'Tanda koma (,).',
 'SINTAKS', null, null, 4),

(E'Sebutkan contoh penggunaan Struct untuk mengelompokkan informasi!',
 E'Data tanggal (tanggal, bulan, tahun) atau data mahasiswa (NIM, nama, IPK).',
 'KAPAN', null, null, 5)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'struct-dasar';

-- =========================================================
-- POINTER — 5 kartu
-- =========================================================
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa isi utama yang disimpan oleh sebuah variabel Pointer?',
 E'Alamat memori dari suatu nilai atau variabel lain.',
 'ISTILAH', null, null, 1),

(E'Tanda apa yang diletakkan sebelum nama variabel saat mendeklarasikan Pointer?',
 E'Tanda asterisk (*).',
 'SINTAKS', null, null, 2),

(E'Fungsi dalam bahasa C yang digunakan untuk alokasi memori dinamis adalah...',
 E'Fungsi malloc().',
 'SINTAKS', null, null, 3),

(E'Apa fungsi tanda asterisk (*) saat diletakkan di depan variabel Pointer yang sudah dideklarasikan?',
 E'Dereferencing, yaitu mengakses atau mengubah nilai pada lokasi memori yang ditunjuk.',
 'MEMORI', null, null, 4),

(E'Apa keunggulan utama Pointer dibandingkan Array statis?',
 E'Pointer memungkinkan pengalokasian memori secara dinamis saat runtime.',
 'KAPAN', null, null, 5)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'pointer-dasar';

commit;

-- =========================================================
-- VERIFIKASI
-- Harapan: 5 kartu per modul, total 15 kartu
-- =========================================================
-- select m.slug, count(f.id) as jumlah_kartu
-- from public.modul m left join public.flashcard f on f.modul_id = m.id
-- group by m.slug order by m.slug;
