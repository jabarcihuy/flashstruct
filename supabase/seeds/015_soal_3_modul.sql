-- =========================================================
-- FlashStruct — Soal & Opsi untuk 3 Modul Inti
--
-- Prasyarat: 013 (modul + bagian) dan 014 (kartu) sudah dijalankan.
--
-- Isi: 30 soal x 4 opsi = 120 opsi
-- Aturan: tepat 1 jawaban benar per soal (dijaga unique index
--         opsi_soal_satu_benar_idx)
-- =========================================================

begin;

delete from public.soal
where modul_id in (select id from public.modul where slug in ('array-dasar','struct-dasar','pointer-dasar'));

-- =========================================================
-- ARRAY — 10 soal
-- =========================================================

-- Soal 1
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa sifat tipe data elemen pada array?', null, null, 'PG', 'ISTILAH',
 E'Semua elemen array harus bertipe data sama (homogen). Kalau butuh tipe berbeda, gunakan struct.', 1
from public.modul m where m.slug = 'array-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Homogen — semua elemen bertipe sama', true, 1),
 ('B', 'Heterogen — tiap elemen boleh berbeda tipe', false, 2),
 ('C', 'Tergantung bahasa pemrograman', false, 3),
 ('D', 'Tidak ada ketentuan', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='array-dasar') and s.urutan = 1;

-- Soal 2
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Bagaimana elemen array disimpan di dalam memori?', null, null, 'PG', 'MEMORI',
 E'Elemen array disimpan kontigu (berurutan tanpa celah). Sifat inilah yang membuat alamat setiap elemen bisa dihitung langsung.', 2
from public.modul m where m.slug = 'array-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Tersebar acak di memori', false, 1),
 ('B', 'Berurutan tanpa celah (kontigu)', true, 2),
 ('C', 'Disimpan di hard disk', false, 3),
 ('D', 'Tergantung besar elemen', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='array-dasar') and s.urutan = 2;

-- Soal 3
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Berapa nilai yang dicetak kode berikut?', E'int A[5] = {10, 20, 30, 40, 50};\ncout << A[2];', 'cpp', 'TRACE', 'TRACING',
 E'A[2] adalah elemen ketiga, karena indeks dimulai dari 0: A[0]=10, A[1]=20, A[2]=30.', 3
from public.modul m where m.slug = 'array-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', '20', false, 1),
 ('B', '30', true, 2),
 ('C', '40', false, 3),
 ('D', 'Error', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='array-dasar') and s.urutan = 3;

-- Soal 4
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Array berukuran 5 memiliki indeks dari berapa sampai berapa?', null, null, 'PG', 'ISTILAH',
 E'Indeks dimulai dari 0, jadi array berukuran 5 punya indeks 0 sampai 4 — bukan 1 sampai 5.', 4
from public.modul m where m.slug = 'array-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', '1 sampai 5', false, 1),
 ('B', '0 sampai 5', false, 2),
 ('C', '0 sampai 4', true, 3),
 ('D', '1 sampai 4', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='array-dasar') and s.urutan = 4;

-- Soal 5
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Mengapa akses elemen array sangat cepat?', null, null, 'PG', 'MEMORI',
 E'Alamat elemen bisa dihitung langsung dengan rumus alamat(i) = alamat(0) + i x sizeof(Tipe), tanpa menelusuri elemen sebelumnya. Kompleksitasnya O(1).', 5
from public.modul m where m.slug = 'array-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Karena array menyimpan indeksnya', false, 1),
 ('B', 'Karena alamat elemen bisa dihitung langsung', true, 2),
 ('C', 'Karena array diurutkan otomatis', false, 3),
 ('D', 'Karena array disimpan di cache', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='array-dasar') and s.urutan = 5;

-- Soal 6
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa yang terjadi pada kode berikut?', E'int A[5];\nA[5] = 100;', 'cpp', 'ANALISIS', 'JEBAKAN',
 E'Indeks 5 di luar batas — array berukuran 5 hanya punya indeks 0 sampai 4. Ini undefined behavior: program mungkin tampak berhasil, tetapi merusak memori di sekitarnya.', 6
from public.modul m where m.slug = 'array-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Menyimpan 100 di elemen terakhir', false, 1),
 ('B', 'Muncul pesan error saat kompilasi', false, 2),
 ('C', 'Undefined behavior — merusak memori di luar batas', true, 3),
 ('D', 'Array otomatis diperbesar', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='array-dasar') and s.urutan = 6;

-- Soal 7
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Bagaimana cara menyalin seluruh isi array A ke array B di C++?', null, null, 'PG', 'SINTAKS',
 E'Isi array harus disalin elemen per elemen dengan perulangan. Menulis B = A pada array tidak menyalin isinya.', 7
from public.modul m where m.slug = 'array-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'B = A;', false, 1),
 ('B', 'Perulangan menyalin tiap elemen', true, 2),
 ('C', 'copy(A, B);', false, 3),
 ('D', 'B.copy(A);', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='array-dasar') and s.urutan = 7;

-- Soal 8
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa rumus alamat elemen ke-i pada array?', null, null, 'PG', 'MEMORI',
 E'alamat(i) = alamat(0) + i x sizeof(Tipe). Karena rumusnya sederhana, komputer bisa melompat ke elemen mana pun dalam waktu yang sama.', 8
from public.modul m where m.slug = 'array-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'alamat(0) + i', false, 1),
 ('B', 'alamat(0) + i x sizeof(Tipe)', true, 2),
 ('C', 'alamat(0) x i', false, 3),
 ('D', 'alamat(i) = i', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='array-dasar') and s.urutan = 8;

-- Soal 9
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa perbedaan perilaku akses di luar batas antara C++ dan Python?', null, null, 'PG', 'BANDING',
 E'C++ tidak memeriksa batas — terjadi undefined behavior. Python melempar IndexError dan program berhenti dengan pesan jelas.', 9
from public.modul m where m.slug = 'array-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Keduanya melempar error', false, 1),
 ('B', 'Keduanya mengabaikan kesalahan', false, 2),
 ('C', 'C++ undefined behavior; Python melempar IndexError', true, 3),
 ('D', 'Python undefined behavior; C++ melempar IndexError', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='array-dasar') and s.urutan = 9;

-- Soal 10
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Berapa nilai A[1] pada array berikut?', E'int A[5] = {10, 20, 30, 40, 50};', 'cpp', 'TRACE', 'TRACING',
 E'A[1] adalah elemen kedua, yaitu 20. A[0]=10 adalah elemen pertama.', 10
from public.modul m where m.slug = 'array-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', '10', false, 1),
 ('B', '20', true, 2),
 ('C', '30', false, 3),
 ('D', '0', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='array-dasar') and s.urutan = 10;

-- =========================================================
-- STRUCT — 10 soal
-- =========================================================

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa pengertian struct dalam bahasa C?', null, null, 'PG', 'ISTILAH',
 E'Struct adalah koleksi variabel dengan tipe data berbeda yang dikelompokkan dalam satu nama.', 1
from public.modul m where m.slug = 'struct-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Kumpulan elemen bertipe sama', false, 1),
 ('B', 'Koleksi variabel bertipe berbeda dalam satu nama', true, 2),
 ('C', 'Fungsi yang mengembalikan banyak nilai', false, 3),
 ('D', 'Alias untuk tipe data dasar', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='struct-dasar') and s.urutan = 1;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Operator apa yang dipakai untuk mengakses anggota struct?', null, null, 'PG', 'SINTAKS',
 E'Operator titik (.) dipakai untuk variabel struct biasa. Contoh: mhs.nama', 2
from public.modul m where m.slug = 'struct-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Tanda panah (->)', false, 1),
 ('B', 'Operator titik (.)', true, 2),
 ('C', 'Kurung siku ([])', false, 3),
 ('D', 'Tanda bintang (*)', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='struct-dasar') and s.urutan = 2;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa perbedaan sifat elemen antara array dan struct?', null, null, 'PG', 'BANDING',
 E'Array bersifat homogen (semua elemen bertipe sama). Struct bersifat heterogen (anggotanya boleh berbeda tipe).', 3
from public.modul m where m.slug = 'struct-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Keduanya homogen', false, 1),
 ('B', 'Keduanya heterogen', false, 2),
 ('C', 'Array homogen, struct heterogen', true, 3),
 ('D', 'Array heterogen, struct homogen', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='struct-dasar') and s.urutan = 3;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Tanda apa yang memisahkan beberapa variabel struct yang dideklarasikan bersamaan?', null, null, 'PG', 'SINTAKS',
 E'Tanda koma. Contoh: Mahasiswa mhs1, mhs2, mhs3;', 4
from public.modul m where m.slug = 'struct-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Titik koma (;)', false, 1),
 ('B', 'Tanda koma (,)', true, 2),
 ('C', 'Tanda titik (.)', false, 3),
 ('D', 'Garis miring (/)', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='struct-dasar') and s.urutan = 4;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa yang salah dari kode berikut?', E'struct Mahasiswa { string nama; };\nMahasiswa mhs;\nmhs->nama = "Rina";', 'cpp', 'ANALISIS', 'JEBAKAN',
 E'mhs bukan pointer, jadi tidak boleh memakai tanda panah (->). Untuk variabel struct biasa dipakai operator titik: mhs.nama = "Rina";', 5
from public.modul m where m.slug = 'struct-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Struct tidak boleh punya anggota string', false, 1),
 ('B', 'Tanda panah dipakai padahal mhs bukan pointer', true, 2),
 ('C', 'Deklarasi struct kurang titik koma', false, 3),
 ('D', 'Nama anggota harus huruf kapital', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='struct-dasar') and s.urutan = 5;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Bagaimana mengakses anggota struct yang bersarang (nested struct)?', null, null, 'PG', 'SINTAKS',
 E'Memakai dua operator titik, melewati dua lapisan. Contoh: mhs.lahir.tahun', 6
from public.modul m where m.slug = 'struct-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'mhs->lahir->tahun', false, 1),
 ('B', 'mhs.lahir.tahun', true, 2),
 ('C', 'mhs[lahir][tahun]', false, 3),
 ('D', 'mhs::lahir::tahun', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='struct-dasar') and s.urutan = 6;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Bolehkah struct disalin langsung dengan tanda sama dengan (=)?', null, null, 'PG', 'BANDING',
 E'Boleh. Struct bisa disalin langsung dan seluruh anggotanya ikut tersalin. Ini berbeda dari array, yang tidak bisa disalin dengan cara tersebut.', 7
from public.modul m where m.slug = 'struct-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Tidak boleh, harus elemen per elemen', false, 1),
 ('B', 'Boleh, seluruh anggota ikut tersalin', true, 2),
 ('C', 'Hanya boleh untuk struct kosong', false, 3),
 ('D', 'Hanya boleh kalau anggotanya sejenis', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='struct-dasar') and s.urutan = 7;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Bagaimana mengakses anggota struct di dalam array of struct?', null, null, 'PG', 'TRACING',
 E'Kurung siku memilih elemen, lalu titik memilih anggota. Contoh: daftar[0].nama', 8
from public.modul m where m.slug = 'struct-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'daftar.nama[0]', false, 1),
 ('B', 'daftar[0].nama', true, 2),
 ('C', 'daftar[0]->nama', false, 3),
 ('D', 'daftar->[0].nama', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='struct-dasar') and s.urutan = 8;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa nilai yang dicetak kode berikut?', E'struct Mhs { string nama; float ipk; };\nMhs m;\nm.nama = "Rina";\nm.ipk = 3.75;\ncout << m.ipk;', 'cpp', 'TRACE', 'TRACING',
 E'3.75. Anggota struct diakses lewat operator titik, dan nilainya bisa dicetak seperti variabel biasa.', 9
from public.modul m where m.slug = 'struct-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Rina', false, 1),
 ('B', '3.75', true, 2),
 ('C', 'm.ipk', false, 3),
 ('D', 'Error', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='struct-dasar') and s.urutan = 9;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Sebutkan contoh penggunaan struct yang tepat!', null, null, 'PG', 'KAPAN',
 E'Struct tepat dipakai untuk mengelompokkan data yang saling terkait dengan tipe berbeda, misalnya data mahasiswa (NIM, nama, IPK) atau data tanggal (hari, bulan, tahun).', 10
from public.modul m where m.slug = 'struct-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Daftar nilai ujian matematika', false, 1),
 ('B', 'Data mahasiswa: NIM, nama, dan IPK', true, 2),
 ('C', 'Menghitung rata-rata bilangan', false, 3),
 ('D', 'Menyimpan satu angka saja', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='struct-dasar') and s.urutan = 10;

-- =========================================================
-- POINTER — 10 soal
-- =========================================================

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa isi utama sebuah variabel pointer?', null, null, 'PG', 'ISTILAH',
 E'Pointer menyimpan alamat memori, bukan nilai langsung. Untuk mengakses nilainya, dipakai operator dereference (*).', 1
from public.modul m where m.slug = 'pointer-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Nilai variabel lain', false, 1),
 ('B', 'Alamat memori suatu nilai', true, 2),
 ('C', 'Nama variabel lain', false, 3),
 ('D', 'Ukuran variabel lain', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='pointer-dasar') and s.urutan = 1;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Tanda apa yang dipakai saat mendeklarasikan pointer?', null, null, 'PG', 'SINTAKS',
 E'Tanda asterisk (*). Contoh: int *p;', 2
from public.modul m where m.slug = 'pointer-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Ampersand (&)', false, 1),
 ('B', 'Asterisk (*)', true, 2),
 ('C', 'Tanda pagar (#)', false, 3),
 ('D', 'Tanda persen (%)', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='pointer-dasar') and s.urutan = 2;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa fungsi operator & pada pointer?', null, null, 'PG', 'MEMORI',
 E'Operator & (address-of) mengambil alamat sebuah variabel. Contoh: int *p = &nilai;', 3
from public.modul m where m.slug = 'pointer-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Mengambil nilai di alamat', false, 1),
 ('B', 'Mengambil alamat sebuah variabel', true, 2),
 ('C', 'Membebaskan memori', false, 3),
 ('D', 'Mengalokasikan memori', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='pointer-dasar') and s.urutan = 3;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa fungsi dalam C yang dipakai untuk alokasi memori dinamis?', null, null, 'PG', 'SINTAKS',
 E'Fungsi malloc() — singkatan dari memory allocation. Memori yang dialokasikan wajib dikembalikan dengan free().', 4
from public.modul m where m.slug = 'pointer-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'alloc()', false, 1),
 ('B', 'malloc()', true, 2),
 ('C', 'new()', false, 3),
 ('D', 'create()', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='pointer-dasar') and s.urutan = 4;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa arti operator * saat dipakai di depan pointer yang sudah dideklarasikan?', null, null, 'PG', 'MEMORI',
 E'Dereferencing — mengakses atau mengubah nilai pada lokasi memori yang ditunjuk. Contoh: *p = 100;', 5
from public.modul m where m.slug = 'pointer-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Mendeklarasikan pointer baru', false, 1),
 ('B', 'Mengakses nilai di alamat yang ditunjuk', true, 2),
 ('C', 'Menghapus pointer', false, 3),
 ('D', 'Menyalin alamat', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='pointer-dasar') and s.urutan = 5;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa nilai akhir variabel nilai?', E'int nilai = 42;\nint *p = &nilai;\n*p = 100;\ncout << nilai;', 'cpp', 'TRACE', 'TRACING',
 E'100. *p = 100 mengubah nilai pada alamat yang ditunjuk p. Karena p menunjuk ke nilai, variabel aslinya ikut berubah.', 6
from public.modul m where m.slug = 'pointer-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', '42', false, 1),
 ('B', '100', true, 2),
 ('C', 'Alamat memori', false, 3),
 ('D', 'Error', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='pointer-dasar') and s.urutan = 6;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa masalah pada kode berikut?', E'int *p = malloc(5 * sizeof(int));\n// ... dipakai ...\n// program selesai tanpa free(p);', 'cpp', 'ANALISIS', 'JEBAKAN',
 E'Terjadi memory leak — memori yang dialokasikan tidak pernah dikembalikan. Setiap malloc() wajib dipasangkan dengan free().', 7
from public.modul m where m.slug = 'pointer-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Ukuran alokasi salah', false, 1),
 ('B', 'Memory leak karena tidak ada free()', true, 2),
 ('C', 'Pointer tidak boleh diinisialisasi', false, 3),
 ('D', 'malloc tidak butuh argumen', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='pointer-dasar') and s.urutan = 7;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa arti *(B + 2) jika B adalah array?', null, null, 'PG', 'MEMORI',
 E'Sama dengan B[2] — elemen ketiga. Nama array adalah alamat elemen pertamanya, sehingga B[2] == *(B + 2).', 8
from public.modul m where m.slug = 'pointer-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'Alamat elemen B[2]', false, 1),
 ('B', 'Nilai elemen B[2]', true, 2),
 ('C', 'Alamat elemen B[0] ditambah 2', false, 3),
 ('D', 'Error kompilasi', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='pointer-dasar') and s.urutan = 8;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Apa perbedaan operator & dan * pada pointer?', null, null, 'PG', 'BANDING',
 E'& mengambil alamat variabel (address-of). * mengambil nilai di alamat yang ditunjuk (dereference).', 9
from public.modul m where m.slug = 'pointer-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', '& mengambil nilai, * mengambil alamat', false, 1),
 ('B', '& mengambil alamat, * mengambil nilai', true, 2),
 ('C', 'Keduanya mengambil alamat', false, 3),
 ('D', 'Keduanya mengambil nilai', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='pointer-dasar') and s.urutan = 9;

insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, E'Bagaimana cara mengakses anggota struct lewat pointer?', null, null, 'PG', 'SINTAKS',
 E'Memakai tanda panah (->). Contoh: p->nama, yang sama dengan (*p).nama', 10
from public.modul m where m.slug = 'pointer-dasar';
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s, (values
 ('A', 'p.nama', false, 1),
 ('B', 'p->nama', true, 2),
 ('C', 'p[nama]', false, 3),
 ('D', '*p.nama', false, 4)
) as v(label, teks, benar, urutan)
where s.modul_id = (select id from public.modul where slug='pointer-dasar') and s.urutan = 10;

commit;

-- =========================================================
-- VERIFIKASI
-- Harapan: setiap modul punya 10 soal, total 30 soal dan 120 opsi
-- =========================================================
-- select m.slug, count(distinct s.id) as soal, count(o.id) as opsi
-- from modul m
--   left join soal s on s.modul_id = m.id
--   left join opsi_soal o on o.soal_id = s.id
-- group by m.slug order by m.slug;
