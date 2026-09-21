-- =========================================================
-- FlashStruct — Data Contoh (Seed)
--
-- CARA PAKAI:
--   Jalankan SETELAH 001_initial_schema.sql dan 002_rls_policies.sql
--
-- Isi: 1 modul (array-dasar), 5 bagian, 8 kartu, 3 soal, 12 opsi, 1 video
--
-- Catatan: ini CONTOH MINIMAL untuk memverifikasi arsitektur.
-- Modul ini perlu dilengkapi menjadi 20 kartu + 18 soal
-- sesuai docs/02-KURIKULUM.md §3.1
-- =========================================================

-- =========================================================
-- Seed: modul array-dasar
-- =========================================================

with m as (
  insert into public.modul (slug, judul, topik, deskripsi, estimasi_menit, urutan)
  values (
    'array-dasar',
    'Dasar Array & Indeks',
    'array',
    'Memori berurutan, indeks, dan batas array.',
    12,
    1
  )
  returning id
),

-- Bagian modul
b as (
  insert into public.bagian_modul (modul_id, slug, judul, konten_md, urutan)
  select m.id, v.slug, v.judul, v.konten_md, v.urutan
  from m, (values
    ('apa-itu-array', 'Apa Itu Array',
     'Array adalah kumpulan elemen dengan tipe yang sama...', 1),
    ('memori-berurutan', 'Memori Berurutan',
     'Elemen array disimpan berdampingan di memori...', 2),
    ('indeks', 'Indeks dan Pengaksesan',
     'Indeks dimulai dari 0, bukan 1...', 3),
    ('batas-array', 'Batas Array',
     'C++ tidak memeriksa batas indeks...', 4),
    ('cpp-vs-python', 'C++ vs Python',
     'Perbedaan array statis dan list dinamis...', 5)
  ) as v(slug, judul, konten_md, urutan)
  returning id
),

-- Kartu flashcard
k as (
  insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
  select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
  from m, (values
    ('Apa itu array?',
     'Kumpulan elemen bertipe sama yang disimpan berurutan di memori dan diakses lewat indeks.',
     'ISTILAH', null, null, 1),

    ('Dari indeks berapa array dimulai di C++ dan Python?',
     'Dari 0. Elemen pertama adalah arr[0], bukan arr[1].',
     'ISTILAH', null, null, 2),

    ('Bagaimana cara mendeklarasikan array 5 bilangan bulat di C++?',
     E'int arr[5];\n\n// Dengan nilai awal:\nint arr[5] = {10, 20, 30, 40, 50};',
     'SINTAKS', 'int arr[5] = {10, 20, 30, 40, 50};', 'cpp', 3),

    ('Apa rumus alamat elemen ke-i pada array?',
     'alamat(i) = alamat(0) + i x sizeof(Tipe)\n\nKarena itu pengaksesan array sangat cepat: alamatnya bisa dihitung langsung.',
     'MEMORI', null, null, 4),

    ('int arr[5] = {10,20,30,40,50};\ncout << arr[2];\n\nApa outputnya?',
     '30\n\narr[2] adalah elemen ketiga karena indeks dimulai dari 0:\narr[0]=10, arr[1]=20, arr[2]=30',
     'TRACING', 'int arr[5] = {10,20,30,40,50};\ncout << arr[2];', 'cpp', 5),

    ('Apa yang salah dari kode ini?\nint arr[5];\narr[5] = 100;',
     E'Indeks 5 berada DI LUAR batas.\n\nArray berukuran 5 punya indeks 0 sampai 4.\nMenulis arr[5] adalah undefined behavior: mungkin tampak berhasil, tetapi merusak memori di sekitarnya.',
     'JEBAKAN', 'int arr[5];\narr[5] = 100;  // di luar batas!', 'cpp', 6),

    ('Apa perbedaan array C++ dan list Python?',
     E'Array C++ (int arr[5]):\n- ukuran tetap saat kompilasi\n- tipe elemen seragam\n- satu blok memori berurutan\n\nList Python ([0]*5):\n- ukuran bisa berubah\n- tipe elemen bebas\n- menyimpan referensi ke objek',
     'BANDING', null, null, 7),

    ('Kapan sebaiknya memakai std::array daripada array C biasa?',
     E'Pakai std::array bila:\n- ukuran tetap saat kompilasi\n- ingin punya .size() yang benar\n- ingin array tidak otomatis menjadi pointer saat dikirim ke fungsi\n\nArray C biasa masih tepat bila berinteraksi dengan API gaya C.',
     'KAPAN', null, null, 8)
  ) as v(depan, belakang, card_type, kode, bahasa, urutan)
  returning id
),

-- Soal quiz
s as (
  insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
  select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
  from m, (values
    ('Berapa nilai sizeof(arr) jika dideklarasikan sebagai int arr[5] dengan int berukuran 4 byte?',
     null, null, 'PG', 'MEMORI',
     E'5 elemen x 4 byte = 20 byte.\n\nOpsi 4 salah karena itu ukuran satu int. Opsi 5 salah karena itu jumlah elemen. Opsi 40 salah karena keliru mengira int berukuran 8 byte.',
     1),

    (E'int arr[5] = {10, 20, 30, 40, 50};\nint* p = arr;\ncout << *(p + 3);\n\nApa outputnya?',
     'int arr[5] = {10, 20, 30, 40, 50};\nint* p = arr;\ncout << *(p + 3);', 'cpp', 'TRACE', 'TRACING',
     E'Output: 40\n\np menunjuk ke arr[0]. p + 3 menunjuk ke arr[3]. *(p + 3) = arr[3] = 40.\n\nOpsi 30 salah karena itu arr[2]. Opsi 50 salah karena itu arr[4].',
     2),

    ('Kode berikut mengakses elemen di luar batas array. Apa akibatnya di C++?',
     E'int arr[3] = {1, 2, 3};\nfor (int i = 0; i <= 3; i++) {\n    cout << arr[i] << " ";\n}',
     'cpp', 'ANALISIS', 'JEBAKAN',
     E'Undefined behavior.\n\nC++ tidak memeriksa batas indeks. Saat i = 3, arr[3] membaca memori di luar array. Program mungkin mencetak nilai sampah, crash, atau tampak berjalan normal - semuanya mungkin.\n\nIni bukan "error yang bisa ditangkap", melainkan perilaku yang tidak didefinisikan standar.',
     3)
  ) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
  returning id, urutan
)

-- Opsi jawaban
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from s
join (values
  (1, 'A', '4',  false, 1),
  (1, 'B', '5',  false, 2),
  (1, 'C', '20', true,  3),
  (1, 'D', '40', false, 4),
  (2, 'A', '30', false, 1),
  (2, 'B', '40', true,  2),
  (2, 'C', '50', false, 3),
  (2, 'D', '10', false, 4),
  (3, 'A', 'Compiler menolak kode dan gagal build', false, 1),
  (3, 'B', 'Program otomatis berhenti dengan pesan error', false, 2),
  (3, 'C', 'Undefined behavior: bisa cetak nilai sampah, crash, atau tampak normal', true, 3),
  (3, 'D', 'Array otomatis diperbesar agar muat', false, 4)
) as v(urutan_soal, label, teks, benar, urutan)
  on v.urutan_soal = s.urutan;

-- Video pendukung
-- Catatan: CTE "m" di atas hanya berlaku untuk SATU statement.
-- Statement terpisah harus mengambil id modul lewat subquery.
insert into public.video (modul_id, youtube_id, judul, deskripsi, durasi_detik, urutan)
select m.id, v.youtube_id, v.judul, v.deskripsi, v.durasi, v.urutan
from public.modul m, (values
  ('dQw4w9WgXcQ', 'Visualisasi Memori Array', 'Melihat bagaimana elemen array tersimpan berurutan.', 480, 1)
) as v(youtube_id, judul, deskripsi, durasi, urutan)
where m.slug = 'array-dasar';
