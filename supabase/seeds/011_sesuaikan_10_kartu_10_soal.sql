-- =========================================================
-- FlashStruct — Penyesuaian 10 Flashcard & 10 Soal per Materi
--
-- Total: 10 Modul x 10 Flashcard = 100 Flashcard (urutan 1..10)
-- Total: 10 Modul x 10 Soal      = 100 Soal      (urutan 1..10)
-- Total: 100 Soal x 4 Opsi       = 400 Opsi Soal (label A..D)
--
-- Semua konten telah divalidasi terhadap batasan skema dan kurikulum:
-- - char_length(depan) <= 400, char_length(belakang) <= 800
-- - char_length(pertanyaan) <= 800, char_length(penjelasan) <= 1200
-- - trace_wajib_kode & soal_kode_butuh_bahasa dipatuhi
-- - tepat 1 jawaban benar per soal
-- =========================================================

begin;

-- 1. Hapus kartu dan soal lama (cascade ke opsi_soal)
delete from public.flashcard
where modul_id in (select id from public.modul where slug in ('array-dasar', 'array-multidimensi', 'array-dinamis', 'struct-dasar', 'struct-nested', 'struct-memori', 'pointer-dasar', 'pointer-array', 'pointer-struct', 'pointer-dinamis'));

delete from public.soal
where modul_id in (select id from public.modul where slug in ('array-dasar', 'array-multidimensi', 'array-dinamis', 'struct-dasar', 'struct-nested', 'struct-memori', 'pointer-dasar', 'pointer-array', 'pointer-struct', 'pointer-dinamis'));

-- =========================================================
-- Modul 1: array-dasar (Dasar Array & Indeks)
-- =========================================================
-- FLASHCARD (array-dasar)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa itu array?',
 E'Kumpulan elemen bertipe sama yang disimpan berurutan di memori dan diakses lewat indeks.',
 'ISTILAH', null, null, 1),

(E'Dari indeks berapa array dimulai di C++ dan Python?',
 E'Dari 0. Elemen pertama adalah arr[0], bukan arr[1].',
 'ISTILAH', null, null, 2),

(E'Bagaimana cara mendeklarasikan array 5 bilangan bulat di C++?',
 E'int arr[5];\n\n// Dengan nilai awal:\nint arr[5] = {10, 20, 30, 40, 50};',
 'SINTAKS', E'int arr[5] = {10, 20, 30, 40, 50};', 'cpp', 3),

(E'Bagaimana cara membuat array 5 elemen di Python?',
 E'arr = [0] * 5\n\nDengan nilai langsung:\narr = [10, 20, 30, 40, 50]\n\nPython memakai LIST, bukan array seperti C++.',
 'SINTAKS', E'arr = [0] * 5', 'python', 4),

(E'Apa rumus alamat elemen ke-i pada array?',
 E'alamat(i) = alamat(0) + i x sizeof(Tipe)\\n\\nKarena itu pengaksesan array sangat cepat: alamatnya bisa dihitung langsung.',
 'MEMORI', null, null, 5),

(E'Mengapa pengaksesan array sangat cepat?',
 E'Karena alamat elemen bisa DIHITUNG LANGSUNG:\nalamat(i) = alamat(0) + i x sizeof(Tipe)\n\nTidak perlu mencari atau menelusuri.\nKompleksitasnya O(1) - waktu konstan,\ntidak bergantung pada posisi elemen.',
 'MEMORI', null, null, 6),

(E'int arr[5] = {10,20,30,40,50};\\ncout << arr[2];\\n\\nApa outputnya?',
 E'30\\n\\narr[2] adalah elemen ketiga karena indeks dimulai dari 0:\\narr[0]=10, arr[1]=20, arr[2]=30',
 'TRACING', E'int arr[5] = {10,20,30,40,50};\\ncout << arr[2];', 'cpp', 7),

(E'Berapa nilai arr[0] jika dideklarasikan int arr[5] = {1, 2};?',
 E'1\n\nElemen pertama diisi 1, elemen kedua 2.\nSisanya (arr[2], arr[3], arr[4]) otomatis diisi NOL\ndi C++.\n\nIni berbeda dari variabel lokal biasa yang tidak diinisialisasi\n(mengandung nilai sampah).',
 'TRACING', E'int arr[5] = {1, 2};\\ncout << arr[0];', 'cpp', 8),

(E'Apa yang salah dari kode ini?\\nint arr[5];\\narr[5] = 100;',
 E'Indeks 5 berada DI LUAR batas.\n\nArray berukuran 5 punya indeks 0 sampai 4.\nMenulis arr[5] adalah undefined behavior: mungkin tampak berhasil, tetapi merusak memori di sekitarnya.',
 'JEBAKAN', E'int arr[5];\\narr[5] = 100;  // di luar batas!', 'cpp', 9),

(E'Apa perbedaan array C++ dan list Python?',
 E'Array C++ (int arr[5]):\n- ukuran tetap saat kompilasi\n- tipe elemen seragam\n- satu blok memori berurutan\n\nList Python ([0]*5):\n- ukuran bisa berubah\n- tipe elemen bebas\n- menyimpan referensi ke objek',
 'BANDING', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'array-dasar';

-- SOAL (array-dasar)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Dari indeks berapa array dimulai di C++ dan Python?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: 0\n\nBaik C++ maupun Python memulai indeks dari 0.\nElemen pertama adalah arr[0], bukan arr[1].\n\nPengecoh 1 adalah kesalahan paling umum bagi pemula.',
 1),

(E'Bagaimana cara mendeklarasikan array 3 bilangan bulat dengan nilai awal di C++?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: int arr[3] = {1, 2, 3};\n\nint arr(3) salah: itu sintaks untuk memanggil fungsi, bukan array.\narr = [1,2,3] adalah sintaks Python, bukan C++.\narray arr[3] bukan sintaks C++ yang valid.',
 2),

(E'int arr[5] = {10, 20, 30, 40, 50};\ncout << arr[4];\n\nApa outputnya?',
 E'int arr[5] = {10, 20, 30, 40, 50};\\ncout << arr[4];', 'cpp', 'TRACE', 'TRACING',
 E'Output: 50\n\narr[4] adalah elemen KELIMA (indeks terakhir) karena indeks mulai dari 0.\n\nPengecoh 40 = arr[3]. Pengecoh 10 = arr[0].',
 3),

(E'arr = [10, 20, 30, 40, 50]\nprint(arr[-1])\n\nApa outputnya?',
 E'arr = [10, 20, 30, 40, 50]\\nprint(arr[-1])', 'python', 'TRACE', 'TRACING',
 E'Output: 50\n\nPython mendukung indeks NEGATIF:\narr[-1] = elemen terakhir\narr[-2] = kedua dari belakang\n\nFitur ini TIDAK ada di C++.',
 4),

(E'Berapa nilai sizeof(arr) jika dideklarasikan sebagai int arr[5] dengan int berukuran 4 byte?',
 null, null, 'PG', 'MEMORI',
 E'5 elemen x 4 byte = 20 byte.\n\nOpsi 4 salah karena itu ukuran satu int. Opsi 5 salah karena itu jumlah elemen. Opsi 40 salah karena keliru mengira int berukuran 8 byte.',
 5),

(E'Apa rumus menghitung alamat elemen ke-i pada array?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: alamat(0) + i x sizeof(Tipe)\n\nKarena elemen array tersimpan berurutan dengan jarak tetap (sebesar ukuran tipe), alamat elemen ke-i bisa dihitung langsung.\n\nInilah alasan pengaksesan array O(1) - waktu konstan.',
 6),

(E'int arr[5] = {1, 2};\ncout << arr[4];\n\nApa outputnya?',
 E'int arr[5] = {1, 2};\\ncout << arr[4];', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 0\n\nKetika array diinisialisasi dengan nilai lebih sedikit dari ukurannya, sisanya otomatis diisi NOL.\n\narr[0]=1, arr[1]=2, arr[2]=0, arr[3]=0, arr[4]=0.\n\nIni BERBEDA dari variabel lokal tanpa inisialisasi yang berisi nilai sampah.',
 7),

(E'Apa yang terjadi jika menulis arr[3] = 100 pada array berukuran 3 di C++?',
 E'int arr[3];\narr[3] = 100;', 'cpp', 'ANALISIS', 'JEBAKAN',
 E'Undefined behavior.\n\nArray berukuran 3 punya indeks valid 0, 1, 2.\narr[3] berada DI LUAR BATAS.\n\nC++ TIDAK memeriksa batas indeks - program bisa tampak berjalan normal, mencetak nilai sampah, crash, atau merusak data lain tanpa terlihat.\n\nIni bukan error yang bisa ditangkap, melainkan perilaku yang tidak didefinisikan standar.',
 8),

(E'Apa yang terjadi jika mengakses indeks di luar batas di Python?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Python melempar IndexError dan program berhenti dengan pesan jelas.\n\nIni perbedaan penting dari C++ yang menghasilkan undefined behavior (bisa tampak berhasil).\n\nPengecoh "mengembalikan 0" salah - Python tidak mengisi nilai default.',
 9),

(E'Mengapa pengaksesan elemen array berkompleksitas O(1)?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena alamat elemen bisa dihitung langsung tanpa mencari.\n\nRumus alamat(i) = alamat(0) + i x sizeof(Tipe) memungkinkan komputer melompat langsung ke elemen mana pun.\n\nTidak seperti linked list yang harus menelusuri satu per satu (O(n)).',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'array-dasar';

-- OPSI SOAL (array-dasar)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'0', true, 1),
  (1, 'B', E'1', false, 2),
  (1, 'C', E'Tergantung bahasa', false, 3),
  (1, 'D', E'Tergantung tipe data', false, 4),
  (2, 'A', E'int arr[3] = {1, 2, 3};', true, 1),
  (2, 'B', E'int arr(3);', false, 2),
  (2, 'C', E'arr = [1, 2, 3];', false, 3),
  (2, 'D', E'array arr[3];', false, 4),
  (3, 'A', E'40', false, 1),
  (3, 'B', E'50', true, 2),
  (3, 'C', E'10', false, 3),
  (3, 'D', E'Error', false, 4),
  (4, 'A', E'10', false, 1),
  (4, 'B', E'50', true, 2),
  (4, 'C', E'IndexError', false, 3),
  (4, 'D', E'40', false, 4),
  (5, 'A', E'4', false, 1),
  (5, 'B', E'5', false, 2),
  (5, 'C', E'20', true, 3),
  (5, 'D', E'40', false, 4),
  (6, 'A', E'alamat(0) + i x sizeof(Tipe)', true, 1),
  (6, 'B', E'alamat(0) + i', false, 2),
  (6, 'C', E'alamat(0) + sizeof(Tipe)', false, 3),
  (6, 'D', E'alamat(i) = i x alamat(0)', false, 4),
  (7, 'A', E'0', true, 1),
  (7, 'B', E'Nilai sampah', false, 2),
  (7, 'C', E'Error kompilasi', false, 3),
  (7, 'D', E'2', false, 4),
  (8, 'A', E'Compiler menolak kode dan gagal build', false, 1),
  (8, 'B', E'Program otomatis berhenti dengan pesan error', false, 2),
  (8, 'C', E'Undefined behavior: bisa cetak nilai sampah, crash, atau tampak normal', true, 3),
  (8, 'D', E'Array otomatis diperbesar agar muat', false, 4),
  (9, 'A', E'Mengembalikan 0', false, 1),
  (9, 'B', E'Melempar IndexError dan program berhenti', true, 2),
  (9, 'C', E'Mengembalikan None', false, 3),
  (9, 'D', E'Memperbesar list otomatis', false, 4),
  (10, 'A', E'Karena alamat elemen bisa dihitung langsung tanpa mencari', true, 1),
  (10, 'B', E'Karena array selalu kecil', false, 2),
  (10, 'C', E'Karena compiler mengoptimalkan semua array', false, 3),
  (10, 'D', E'Karena array disimpan di cache CPU', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'array-dasar';

-- =========================================================
-- Modul 2: array-multidimensi (Array Multidimensi)
-- =========================================================
-- FLASHCARD (array-multidimensi)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Bagaimana cara mendeklarasikan array 2D berukuran 3 baris 4 kolom di C++?',
 E'int m[3][4];\n\nAngka pertama = jumlah baris.\nAngka kedua = jumlah kolom.',
 'SINTAKS', E'int m[3][4];', 'cpp', 1),

(E'Apa arti "row-major order"?',
 E'Urutan penyimpanan array multidimensi\ndimana elemen disimpan BARIS DEMI BARIS.\n\nBaris 0 seluruhnya dulu, baru baris 1,\ndan seterusnya.\n\nIni kebalikan dari column-major (dipakai Fortran, MATLAB, R).',
 'ISTILAH', null, null, 2),

(E'Apa rumus menghitung alamat elemen m[i][j] pada array 2D?',
 E'alamat(i,j) = alamat(0,0) + (i x jumlahKolom + j) x sizeof(Tipe)\n\nYang dikali adalah jumlah KOLOM, bukan jumlah baris.',
 'MEMORI', null, null, 3),

(E'int m[2][3] = {{1,2,3},{4,5,6}};\nint* flat = &m[0][0];\ncout << flat[5];\n\nApa outputnya?',
 E'Output: 6\n\nflat[5] adalah elemen ke-6 dari awal = m[1][2] = 6.\nIni membuktikan array 2D tersimpan berurutan (row-major).',
 'TRACING', E'int m[2][3] = {{1,2,3},{4,5,6}};\\nint* flat = &m[0][0];\\ncout << flat[5];', 'cpp', 4),

(E'int m[2][3] = {{1,2,3},{4,5,6}};\ncout << *(*(m+1)+2);\n\nApa outputnya?',
 E'Output: 6\n\n*(*(m+1)+2) sama dengan m[1][2].\n\nm+1    -> menunjuk baris 1\n*(m+1) -> baris 1 itu sendiri\n+2     -> kolom 2\n*      -> nilainya = 6',
 'TRACING', E'int m[2][3] = {{1,2,3},{4,5,6}};\\ncout << *(*(m+1)+2);', 'cpp', 5),

(E'salah = [[0] * 3] * 3\nsalah[0][0] = 99\nprint(salah)\n\nApa outputnya?',
 E'[[99, 0, 0], [99, 0, 0], [99, 0, 0]]\n\nSEMUA baris berubah, bukan hanya yang pertama.\n\nPenyebab: [x] * 3 menggandakan REFERENSI, bukan nilainya. Ketiga baris menunjuk objek list yang sama.',
 'JEBAKAN', E'salah = [[0] * 3] * 3\\nsalah[0][0] = 99\\nprint(salah)', 'python', 6),

(E'Bagaimana cara BENAR membuat list 2D di Python?',
 E'benar = [[0] * 3 for _ in range(3)]\n\nPakai list comprehension agar setiap baris\nadalah objek BARU yang terpisah.\n\nJANGAN pakai [[0] * 3] * 3.',
 'SINTAKS', E'benar = [[0] * 3 for _ in range(3)]', 'python', 7),

(E'Mengapa mengakses elemen dalam satu baris lebih cepat daripada melompat antar baris?',
 E'Karena array tersimpan baris demi baris (row-major).\n\nAkses berurutan memanfaatkan CPU cache:\ndata yang berdekatan dimuat sekaligus.\n\nMelompat antar baris menyebabkan cache miss\nsehingga lebih lambat.',
 'MEMORI', null, null, 8),

(E'Apa perbedaan array 2D di C++ dan list 2D di Python?',
 E'C++ int m[2][3]:\n- satu blok memori berurutan\n- ukuran tetap\n- tipe elemen seragam\n\nPython [[1,2],[3,4]]:\n- daftar referensi ke objek terpisah\n- ukuran bisa berubah\n- tipe elemen bebas',
 'BANDING', null, null, 9),

(E'Kapan sebaiknya memakai array 2D dan kapan list bersarang Python?',
 E'Array 2D C++:\n- ukuran diketahui saat kompilasi\n- butuh satu blok memori berurutan\n- performa akses penting\n\nList bersarang Python:\n- ukuran dinamis\n- tipe elemen bebas\n- keterbacaan lebih penting dari performa',
 'KAPAN', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'array-multidimensi';

-- SOAL (array-multidimensi)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Bagaimana cara mendeklarasikan array 2D dengan 3 baris dan 4 kolom?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: int m[3][4];\n\nAngka PERTAMA adalah jumlah baris (3), angka KEDUA jumlah kolom (4).\n\nint m[4][3] akan menghasilkan 4 baris dan 3 kolom - tertukar.\nint m[3,4] bukan sintaks C++ yang valid.\nint m[12] hanya array 1D dengan 12 elemen.',
 1),

(E'Berapa jumlah elemen array int m[4][5]?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: 20\n\n4 baris x 5 kolom = 20 elemen.\n\nPengecoh 9 = 4+5 (menjumlahkan, bukan mengalikan).\nPengecoh 5 = hanya kolom. Pengecoh 4 = hanya baris.',
 2),

(E'Apa arti "row-major order"?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Elemen array multidimensi disimpan baris demi baris.\n\nBaris 0 disimpan seluruhnya dulu, baru baris 1, dan seterusnya.\n\nKebalikannya adalah column-major (dipakai Fortran, MATLAB, R).\nC++ dan Python (untuk list) memakai row-major.',
 3),

(E'int m[3][4] = {0};\ncout << sizeof(m);\n\nBerapa outputnya jika sizeof(int) = 4?',
 E'int m[3][4] = {0};\\ncout << sizeof(m);', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 48\n\nsizeof(m) = jumlah elemen x sizeof(int) = 12 x 4 = 48 byte.\n\nPengecoh 12 = jumlah elemen, bukan ukuran byte.\nPengecoh 16 = ukuran satu baris (4 x 4).',
 4),

(E'Bagaimana cara menghitung alamat elemen m[i][j]?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: alamat(0,0) + (i x jumlahKolom + j) x sizeof(Tipe)\n\nYang dikali i adalah jumlah KOLOM, karena kita harus melewati i baris penuh terlebih dahulu.\n\nPengecoh yang memakai jumlah baris adalah kesalahan paling umum di sini.',
 5),

(E'int m[2][3] = {{1,2,3},{4,5,6}};\nint* flat = &m[0][0];\ncout << flat[4];\n\nApa outputnya?',
 E'int m[2][3] = {{1,2,3},{4,5,6}};\\nint* flat = &m[0][0];\\ncout << flat[4];', 'cpp', 'TRACE', 'TRACING',
 E'Output: 5\n\nflat[4] adalah elemen ke-5 dari awal (indeks 4).\nElemen tersimpan berurutan: m[0][0]=1, m[0][1]=2, m[0][2]=3, m[1][0]=4, m[1][1]=5.\nJadi elemen indeks 4 = 5.\n\nPengecoh 4 = m[1][0] (indeks 3). Pengecoh 6 = m[1][2] (indeks 5).',
 6),

(E'int m[2][3] = {{1,2,3},{4,5,6}};\ncout << *(*(m+1)+1);\n\nApa outputnya?',
 E'int m[2][3] = {{1,2,3},{4,5,6}};\\ncout << *(*(m+1)+1);', 'cpp', 'TRACE', 'TRACING',
 E'Output: 5\n\n*(*(m+1)+1) sama dengan m[1][1].\n\nm+1     -> baris 1\n*(m+1)  -> baris 1 (array berisi 4,5,6)\n+1      -> elemen kedua dari baris itu\n*       -> nilainya = 5',
 7),

(E'salah = [[0] * 3] * 3\nsalah[0][0] = 99\nprint(salah[1][0])\n\nApa outputnya?',
 E'salah = [[0] * 3] * 3\\nsalah[0][0] = 99\\nprint(salah[1][0])', 'python', 'TRACE', 'JEBAKAN',
 E'Output: 99\n\nKarena [[0]*3]*3 menggandakan REFERENSI, ketiga baris menunjuk objek list yang SAMA.\nMengubah salah[0][0] juga mengubah salah[1][0] dan salah[2][0].\n\nJika memakai list comprehension, hasilnya 0.',
 8),

(E'Manakah cara yang BENAR membuat list 2D 3x3 berisi nol di Python?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: [[0] * 3 for _ in range(3)]\n\nList comprehension membuat objek list BARU untuk setiap baris.\n\n[[0]*3]*3 salah: menggandakan referensi, semua baris jadi objek yang sama.\n[0]*9 salah: itu list 1D berisi 9 nol, bukan 2D.\n[[0]*3]*range(3) salah: bukan sintaks Python yang valid.',
 9),

(E'Kode berikut lambat untuk data besar.\nMengapa?',
 E'for i in range(len(m)):\n    for j in range(len(m[0])):\n        proses(m[j][i])', 'python', 'ANALISIS', 'MEMORI',
 E'Penyebab: akses m[j][i] melompat antar baris, bukan berurutan.\n\nKarena list bersarang menyimpan referensi ke objek terpisah, mengakses m[0][0], m[1][0], m[2][0] berarti berpindah antar objek list yang posisinya berjauhan.\n\nPerbaikan: tukar urutan loop agar mengakses m[i][j] - berurutan dalam satu baris.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'array-multidimensi';

-- OPSI SOAL (array-multidimensi)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'int m[3][4];', true, 1),
  (1, 'B', E'int m[4][3];', false, 2),
  (1, 'C', E'int m[3,4];', false, 3),
  (1, 'D', E'int m[12];', false, 4),
  (2, 'A', E'9', false, 1),
  (2, 'B', E'20', true, 2),
  (2, 'C', E'5', false, 3),
  (2, 'D', E'4', false, 4),
  (3, 'A', E'Elemen array multidimensi disimpan baris demi baris', true, 1),
  (3, 'B', E'Elemen array multidimensi disimpan kolom demi kolom', false, 2),
  (3, 'C', E'Elemen array disimpan berdasarkan nilainya', false, 3),
  (3, 'D', E'Elemen array disimpan berdasarkan urutan input', false, 4),
  (4, 'A', E'12', false, 1),
  (4, 'B', E'16', false, 2),
  (4, 'C', E'48', true, 3),
  (4, 'D', E'24', false, 4),
  (5, 'A', E'alamat(0,0) + (i x jumlahKolom + j) x sizeof(Tipe)', true, 1),
  (5, 'B', E'alamat(0,0) + (i x jumlahBaris + j) x sizeof(Tipe)', false, 2),
  (5, 'C', E'alamat(0,0) + (i + j) x sizeof(Tipe)', false, 3),
  (5, 'D', E'alamat(0,0) + (i x j) x sizeof(Tipe)', false, 4),
  (6, 'A', E'4', false, 1),
  (6, 'B', E'5', true, 2),
  (6, 'C', E'6', false, 3),
  (6, 'D', E'3', false, 4),
  (7, 'A', E'4', false, 1),
  (7, 'B', E'5', true, 2),
  (7, 'C', E'6', false, 3),
  (7, 'D', E'2', false, 4),
  (8, 'A', E'0', false, 1),
  (8, 'B', E'99', true, 2),
  (8, 'C', E'IndexError', false, 3),
  (8, 'D', E'None', false, 4),
  (9, 'A', E'[[0] * 3] * 3', false, 1),
  (9, 'B', E'[[0] * 3 for _ in range(3)]', true, 2),
  (9, 'C', E'[0] * 9', false, 3),
  (9, 'D', E'[[0] * 3] * range(3)', false, 4),
  (10, 'A', E'Akses m[j][i] melompat antar baris, bukan berurutan', true, 1),
  (10, 'B', E'Python lambat untuk semua operasi loop', false, 2),
  (10, 'C', E'range() tidak efisien', false, 3),
  (10, 'D', E'Variabel i dan j tertukar nama', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'array-multidimensi';

-- =========================================================
-- Modul 3: array-dinamis (Array Dinamis: vector & list)
-- =========================================================
-- FLASHCARD (array-dinamis)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa itu std::vector?',
 E'Array dinamis dari pustaka standar C++.\n\nUkurannya bisa bertambah saat program berjalan,\nberbeda dari array biasa yang ukurannya tetap.',
 'ISTILAH', null, null, 1),

(E'Bagaimana cara membuat vector kosong dan vector dengan 5 elemen bernilai 7?',
 E'vector<int> kosong;         // kosong\nvector<int> v(5, 7);      // 5 elemen, semua 7\nvector<int> w = {1,2,3};  // dengan nilai awal',
 'SINTAKS', E'vector<int> kosong;\\nvector<int> v(5, 7);', 'cpp', 2),

(E'Apa perbedaan size dan capacity pada vector?',
 E'size     = jumlah elemen yang BENAR-BENAR ada\ncapacity = jumlah elemen yang BISA ditampung\n           sebelum perlu alokasi ulang\n\nAnaloginya lemari:\nsize = 3 baju tergantung\ncapacity = lemari muat 8 baju',
 'ISTILAH', null, null, 3),

(E'Apa perbedaan v[i] dan v.at(i)?',
 E'v[i]    : TIDAK memeriksa batas (undefined behavior)\nv.at(i) : MEMERIKSA batas, melempar std::out_of_range\n\nPakai .at() kalau indeks berasal dari input pengguna.\nPakai [ ] kalau yakin indeksnya valid (lebih cepat).',
 'BANDING', null, null, 4),

(E'Apa yang terjadi saat vector perlu tumbuh (push_back ketika penuh)?',
 E'1. Alokasikan blok memori BARU yang lebih besar\n2. SALIN semua elemen lama ke blok baru\n3. BEBASKAN blok lama\n4. Tambahkan elemen baru\n\nAkibat penting: ALAMAT elemen berubah!',
 'MEMORI', null, null, 5),

(E'vector<int> v;\nfor (int i = 1; i <= 10; i++) {\n    v.push_back(i);\n    cout << v.size() << " " << v.capacity() << "\\n";\n}\n\nBagaimana pola outputnya (GCC)?',
 E'size bertambah 1 setiap kali:\n1, 2, 3, 4, 5, 6, 7, 8, 9, 10\n\ncapacity BERLIPAT: 1, 2, 4, 8, 16\n\ncapacity naik hanya saat size mencapai batasnya.',
 'TRACING', E'vector<int> v;\\nfor (int i = 1; i <= 10; i++) {\\n    v.push_back(i);\\n    cout << v.size() << " " << v.capacity() << "\\\\n";\\n}', 'cpp', 6),

(E'Mengapa kapasitas vector berlipat (2x) dan bukan bertambah 1?',
 E'Karena menambah 1 per 1 akan sangat lambat:\nsetiap push_back butuh alokasi ulang -> O(n) per operasi\n\nDengan berlipat, alokasi ulang semakin jarang\nseiring data bertambah -> O(1) rata-rata.\n\nCATATAN: angka 2x adalah implementation-defined.\nGCC memakai 2x, implementasi lain bisa 1,5x.',
 'MEMORI', null, null, 7),

(E'Mengapa lst.insert(0, x) itu mahal?',
 E'Karena harus MENGGESER semua elemen satu posisi ke kanan.\nKompleksitasnya O(n), bukan O(1).\n\nPengukuran nyata (5.000 iterasi):\nappend ke belakang : 0.8 ms\ninsert ke depan    : 155.1 ms\n\n198x lebih lambat!\n\nAlternatif: pakai collections.deque dengan appendleft().',
 'MEMORI', null, null, 8),

(E'a = [1, 2, 3]\nb = a\nb.append(4)\nprint(a)\n\nApa outputnya?',
 E'[1, 2, 3, 4]\n\nb = a TIDAK membuat salinan!\nKeduanya menunjuk objek list yang SAMA.\n\nUntuk menyalin: pakai a.copy(), a[:], atau list(a).',
 'JEBAKAN', E'a = [1, 2, 3]\\nb = a\\nb.append(4)\\nprint(a)', 'python', 9),

(E'Kapan sebaiknya pakai vector dan kapan pakai array?',
 E'Pakai VECTOR bila:\n- ukuran tidak diketahui saat kompilasi\n- butuh menambah/mengurangi elemen\n- butuh .size() dan keamanan\n\nPakai ARRAY (C atau std::array) bila:\n- ukuran tetap dan diketahui\n- butuh performa maksimal\n- berinteraksi dengan API gaya C\n\nDefault C++ modern: std::vector.',
 'KAPAN', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'array-dinamis';

-- SOAL (array-dinamis)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Apa perbedaan size dan capacity pada vector?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: size = jumlah elemen yang ada; capacity = jumlah yang bisa ditampung sebelum alokasi ulang.\n\nAnaloginya lemari: size adalah jumlah baju tergantung, capacity adalah berapa baju yang muat.\n\nPengecoh "size lebih besar dari capacity" salah - capacity selalu >= size.',
 1),

(E'vector<int> v = {1,2,3,4};\nv.push_back(5);\ncout << v.size();\n\nApa outputnya?',
 E'vector<int> v = {1,2,3,4};\\nv.push_back(5);\\ncout << v.size();', 'cpp', 'TRACE', 'TRACING',
 E'Output: 5\n\nVector awalnya berisi 4 elemen.\nSetelah push_back(5), jumlah elemen menjadi 5.\n\nPengecoh 4 = size sebelum push_back.',
 2),

(E'Apa yang terjadi saat vector perlu tumbuh?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Alokasi blok baru, salin elemen lama, bebaskan blok lama, tambah elemen baru.\n\nProses ini menyebabkan ALAMAT elemen berubah - itulah mengapa pointer ke elemen bisa menjadi dangling setelah push_back.\n\nPengecoh "memori lama otomatis diperbesar" salah - memori yang sudah dialokasikan tidak bisa diperbesar di tempat.',
 3),

(E'Apa kegunaan v.reserve(n)?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Mengalokasikan ruang untuk n elemen sehingga tidak perlu alokasi ulang sampai elemen ke-n+1.\n\nSetelah reserve(10), size tetap 0 tapi capacity menjadi 10.\n\nPengecoh "mengisi vector dengan n elemen" salah - itu yang dilakukan vector<int> v(n).',
 4),

(E'vector<int> v;\nv.reserve(10);\ncout << v.size() << " " << v.capacity();\n\nApa outputnya?',
 E'vector<int> v;\\nv.reserve(10);\\ncout << v.size() << " " << v.capacity();', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 0 10\n\nreserve() menyiapkan RUANG, bukan mengisi elemen.\nsize tetap 0 karena belum ada elemen.\ncapacity menjadi 10 karena ruang sudah dialokasikan.\n\nIni membedakan reserve() dari vector<int> v(10) yang langsung mengisi 10 elemen.',
 5),

(E'Apa perbedaan v[i] dan v.at(i)?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: v[i] tidak memeriksa batas (undefined behavior); v.at(i) memeriksa dan melempar std::out_of_range.\n\nKeduanya mengakses elemen yang sama jika indeks valid. Perbedaannya hanya pada pemeriksaan batas.\n\nv.at() sedikit lebih lambat karena ada pemeriksaan, tapi lebih aman.',
 6),

(E'Mengapa kapasitas vector berlipat (2x) dan bukan bertambah 1 setiap kali?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Agar alokasi ulang semakin jarang, sehingga push_back tetap O(1) rata-rata.\n\nJika kapasitas bertambah 1 setiap kali, setiap push_back akan memicu alokasi ulang + penyalinan seluruh elemen, sehingga O(n) per operasi. Untuk n elemen, totalnya O(n kuadrat) - sangat lambat.\n\nDengan berlipat, total waktu menjadi O(n).',
 7),

(E'Mengapa lst.insert(0, x) jauh lebih lambat dari lst.append(x)?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: insert(0, x) harus menggeser SEMUA elemen satu posisi, kompleksitasnya O(n). append hanya menambah di akhir, O(1).\n\nPengukuran nyata 5.000 iterasi: append 0.8 ms, insert 155.1 ms - 198x lebih lambat.\n\nAlternatif: collections.deque dengan appendleft() yang O(1).',
 8),

(E'a = [1, 2, 3]\nb = a\nb.append(4)\nprint(len(a))\n\nApa outputnya?',
 E'a = [1, 2, 3]\\nb = a\\nb.append(4)\\nprint(len(a))', 'python', 'TRACE', 'JEBAKAN',
 E'Output: 4\n\nb = a TIDAK membuat salinan - keduanya menunjuk objek list yang SAMA.\n\nSetelah b.append(4), list yang ditunjuk a dan b sama-sama berisi [1,2,3,4].\n\nUntuk menyalin dengan benar: a.copy(), a[:], atau list(a).',
 9),

(E'Kapan sebaiknya memakai std::vector daripada array?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: Saat ukuran tidak diketahui saat kompilasi atau butuh menambah/mengurangi elemen.\n\nvector unggul untuk:\n- data yang jumlahnya baru diketahui saat program berjalan\n- data yang perlu tumbuh/berkurang\n- kasus yang butuh .size() dan keamanan\n\nArray lebih tepat saat ukuran tetap dan butuh performa maksimal.\n\nDefault C++ modern: std::vector.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'array-dinamis';

-- OPSI SOAL (array-dinamis)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'size = jumlah elemen yang ada; capacity = jumlah yang bisa ditampung sebelum alokasi ulang', true, 1),
  (1, 'B', E'size selalu lebih besar dari capacity', false, 2),
  (1, 'C', E'size dan capacity selalu sama', false, 3),
  (1, 'D', E'capacity = jumlah elemen; size = ruang tersedia', false, 4),
  (2, 'A', E'4', false, 1),
  (2, 'B', E'5', true, 2),
  (2, 'C', E'8', false, 3),
  (2, 'D', E'1', false, 4),
  (3, 'A', E'Alokasi blok baru, salin elemen lama, bebaskan blok lama', true, 1),
  (3, 'B', E'Memori lama otomatis diperbesar di tempat', false, 2),
  (3, 'C', E'Elemen baru disimpan di lokasi terpisah', false, 3),
  (3, 'D', E'Vector membuat vector baru dan menghapus yang lama', false, 4),
  (4, 'A', E'Mengalokasikan ruang untuk n elemen sehingga tidak perlu alokasi ulang', true, 1),
  (4, 'B', E'Mengisi vector dengan n elemen bernilai nol', false, 2),
  (4, 'C', E'Membatasi vector agar maksimal n elemen', false, 3),
  (4, 'D', E'Menghapus semua elemen lalu menambah n elemen baru', false, 4),
  (5, 'A', E'0 10', true, 1),
  (5, 'B', E'10 10', false, 2),
  (5, 'C', E'0 0', false, 3),
  (5, 'D', E'10 0', false, 4),
  (6, 'A', E'v[i] tidak memeriksa batas; v.at(i) memeriksa dan melempar exception', true, 1),
  (6, 'B', E'v[i] untuk baca, v.at(i) untuk tulis', false, 2),
  (6, 'C', E'v.at(i) lebih cepat karena dioptimalkan compiler', false, 3),
  (6, 'D', E'Tidak ada perbedaan sama sekali', false, 4),
  (7, 'A', E'Agar alokasi ulang semakin jarang sehingga push_back tetap O(1) rata-rata', true, 1),
  (7, 'B', E'Karena memori komputer selalu berlipat dua', false, 2),
  (7, 'C', E'Karena standar C++ mewajibkan kapasitas 2x', false, 3),
  (7, 'D', E'Agar vector tidak bisa diakses dari luar', false, 4),
  (8, 'A', E'insert(0, x) harus menggeser semua elemen (O(n)); append hanya menambah di akhir (O(1))', true, 1),
  (8, 'B', E'insert menggunakan lebih banyak memori', false, 2),
  (8, 'C', E'append dioptimalkan oleh compiler Python', false, 3),
  (8, 'D', E'insert memerlukan konversi tipe data', false, 4),
  (9, 'A', E'3', false, 1),
  (9, 'B', E'4', true, 2),
  (9, 'C', E'1', false, 3),
  (9, 'D', E'Error', false, 4),
  (10, 'A', E'Saat ukuran tidak diketahui saat kompilasi atau butuh menambah/mengurangi elemen', true, 1),
  (10, 'B', E'Saat butuh performa maksimal dan ukuran tetap', false, 2),
  (10, 'C', E'Saat berinteraksi dengan API gaya C', false, 3),
  (10, 'D', E'Saat butuh array dengan indeks mulai dari 1', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'array-dinamis';

-- =========================================================
-- Modul 4: struct-dasar (Mendefinisikan Struct)
-- =========================================================
-- FLASHCARD (struct-dasar)
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

-- SOAL (struct-dasar)
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

-- OPSI SOAL (struct-dasar)
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

-- =========================================================
-- Modul 5: struct-nested (Nested Struct & Array of Struct)
-- =========================================================
-- FLASHCARD (struct-nested)
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

-- SOAL (struct-nested)
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

-- OPSI SOAL (struct-nested)
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

-- =========================================================
-- Modul 6: struct-memori (Padding, Alignment & sizeof)
-- =========================================================
-- FLASHCARD (struct-memori)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Berapa sizeof(struct { char a; int b; }) jika sizeof(int)=4?',
 E'8 byte, bukan 5.\n\n1 (char) + 3 (padding) + 4 (int) = 8\n\nPadding 3 byte muncul agar int b dimulai\npada offset yang merupakan kelipatan 4.',
 'MEMORI', E'struct Campur { char a; int b; };\\ncout << sizeof(Campur);  // 8', 'cpp', 1),

(E'Apa itu padding pada struct?',
 E'Byte KOSONG yang disisipkan compiler di antara anggota struct\nagar setiap anggota dimulai pada alamat yang sesuai alignment-nya.\n\nPadding TIDAK berisi data apa pun - isinya nilai tak tentu.',
 'ISTILAH', null, null, 2),

(E'Bagaimana cara memeriksa offset anggota struct?',
 E'Pakai offsetof dari <cstddef>:\n\n#include <cstddef>\n\nstruct Campur { char a; int b; };\n\ncout << offsetof(Campur, a);   // 0\ncout << offsetof(Campur, b);   // 4',
 'SINTAKS', E'#include <cstddef>\\ncout << offsetof(Campur, b);  // 4', 'cpp', 3),

(E'Apa aturan alignment untuk anggota struct?',
 E'Setiap anggota harus dimulai pada alamat yang merupakan\nKELIPATAN alignment-nya.\n\nAlignment biasanya sama dengan ukuran tipe:\nchar=1, short=2, int=4, long=8, pointer=8\n\nSelain itu, total ukuran struct dibulatkan ke kelipatan\nalignment TERBESAR di antara anggotanya.',
 'MEMORI', null, null, 4),

(E'Berapa sizeof(struct { char a; long b; char c; })?',
 E'24 byte.\n\nOffset: a=0, b=8 (butuh kelipatan 8), c=16\nTotal sebelum pembulatan: 17\nAlignment terbesar: 8\nDibulatkan ke kelipatan 8 -> 24\n\nRincian: 1 + 7 pad + 8 + 1 + 7 pad akhir = 24',
 'MEMORI', E'struct B { char a; long b; char c; };\\ncout << sizeof(B);  // 24', 'cpp', 5),

(E'Apakah mengurutkan anggota struct SELALU mengurangi padding?',
 E'TIDAK.\n\n{char a; int b;} = 8 byte\n{int b; char a;} = 8 byte\n\nSAMA! Pengurutan tidak membantu pada struct 2 anggota.\n\nPengurutan baru membantu kalau ada BEBERAPA anggota kecil\nyang bisa dikemas berdampingan.',
 'JEBAKAN', null, null, 6),

(E'Apa risiko memakai #pragma pack(1)?',
 E'1. LEBIH LAMBAT - CPU harus membaca beberapa blok dan menggabungkan\n2. TIDAK PORTABEL - perilaku berbeda antar compiler\n3. BAHAYA DI ARM - akses tidak selaras bisa menyebabkan crash\n\nGunakan hanya kalau benar-benar perlu,\nmisalnya untuk protokol jaringan atau format biner tertentu.',
 'JEBAKAN', null, null, 7),

(E'Mengapa struct TIDAK boleh dibandingkan dengan memcmp?',
 E'Karena padding berisi nilai TAK TENTU.\n\nmemcmp membandingkan SELURUH byte termasuk padding.\nDua struct dengan data identik bisa dianggap BERBEDA\nkalau padding-nya berbeda.\n\nBandingkan anggota satu per satu, atau pakai\noperator== default (C++20).',
 'JEBAKAN', null, null, 8),

(E'Bagaimana cara membandingkan dua struct dengan benar?',
 E'Bandingkan anggota satu per satu:\n\nbool sama(const Titik& a, const Titik& b) {\n    return a.x == b.x && a.y == b.y;\n}\n\nAtau di C++20, pakai operator== default:\n\nstruct Titik {\n    int x, y;\n    bool operator==(const Titik&) const = default;\n};',
 'SINTAKS', E'struct Titik {\\n    int x, y;\\n    bool operator==(const Titik&) const = default;\\n};', 'cpp', 9),

(E'Apakah alignment struct sama di semua platform?',
 E'TIDAK - alignment bersifat IMPLEMENTATION-DEFINED.\n\nAngka seperti sizeof(int)=4, sizeof(long)=8 berlaku untuk\nx86-64. Di platform lain (ARM, embedded) bisa BERBEDA.\n\nSelalu verifikasi dengan sizeof dan offsetof\ndi platform yang kamu pakai.',
 'MEMORI', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'struct-memori';

-- SOAL (struct-memori)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Berapa sizeof(struct { char a; int b; }) jika sizeof(int) = 4?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: 8 byte\n\n1 (char) + 3 (padding) + 4 (int) = 8.\n\nPengecoh 5 = menjumlahkan tanpa memperhitungkan padding.\nPengecoh 4 = hanya ukuran int. Pengecoh 12 = salah hitung alignment.',
 1),

(E'Mengapa padding diperlukan dalam struct?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Agar setiap anggota dimulai pada alamat yang selaras, sehingga CPU bisa membacanya dalam satu operasi.\n\nCPU membaca memori dalam blok (4 atau 8 byte), bukan byte demi byte. Kalau int diletakkan pada offset tidak selaras, CPU perlu dua operasi baca dan menggabungkannya - jauh lebih lambat.\n\nPengecoh "untuk menghemat memori" salah - padding justru MEMBUANG memori demi kecepatan.',
 2),

(E'struct Campur { char a; int b; };\ncout << offsetof(Campur, b);\n\nBerapa outputnya jika sizeof(int)=4?',
 E'struct Campur { char a; int b; };\\ncout << offsetof(Campur, b);', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 4\n\nb harus dimulai pada offset yang merupakan kelipatan 4 (alignment int).\nSetelah char a di offset 0, offset berikutnya adalah 1.\nDibulatkan ke kelipatan 4 -> 4.\n\nTiga byte di offset 1-3 adalah padding.',
 3),

(E'Berapa sizeof(struct { char a; long b; char c; })?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: 24 byte\n\nOffset: a=0, b=8 (butuh kelipatan 8), c=16.\nTotal sebelum pembulatan: 17.\nAlignment terbesar = 8, dibulatkan ke 24.\n\nRincian: 1 + 7 padding + 8 + 1 + 7 padding akhir = 24.\n\nPengecoh 10 = 1+8+1 tanpa padding. Pengecoh 16 = lupa padding setelah c.',
 4),

(E'struct A { char a; long b; char c; };\nstruct B { long b; char a; char c; };\n\ncout << sizeof(A) << " " << sizeof(B);\n\nApa outputnya?',
 E'struct A { char a; long b; char c; };\\nstruct B { long b; char a; char c; };\\ncout << sizeof(A) << " " << sizeof(B);', 'cpp', 'TRACE', 'MEMORI',
 E'Output: 24 16\n\nA: a=0, b=8, c=16 -> total 17 dibulatkan ke 24\nB: b=0, a=8, c=9  -> total 10 dibulatkan ke 16\n\nB menghemat 8 byte karena anggota kecil (a dan c) dikelompokkan berdampingan.\n\nIni contoh pengurutan yang BERHASIL menghemat.',
 5),

(E'Apa aturan yang lebih akurat tentang mengurangi padding?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Padding berkurang ketika anggota kecil dikelompokkan berdampingan sehingga muat dalam satu blok alignment.\n\nIni BIASANYA tercapai dengan mengurutkan dari besar ke kecil, tetapi BUKAN JAMINAN.\n\nPada struct dengan hanya 2 anggota, pengurutan sering tidak mengubah apa pun karena tidak ada anggota kecil yang bisa dikemas bersama.',
 6),

(E'Apa yang dilakukan #pragma pack(1)?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Memaksa compiler mengurangi atau menghilangkan padding.\n\n#pragma pack(push, 1)\nstruct Padat { char a; int b; };\n#pragma pack(pop)\n\nDengan pack(1), sizeof(Padat) menjadi 5 byte (bukan 8).\n\nTapi ada konsekuensi serius: lebih lambat, tidak portabel, dan bisa crash di ARM.',
 7),

(E'Apa risiko memakai #pragma pack(1)?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Lebih lambat, tidak portabel, dan bisa crash di ARM.\n\n1. LEBIH LAMBAT - CPU harus membaca beberapa blok dan menggabungkan\n2. TIDAK PORTABEL - perilaku berbeda antar compiler\n3. BAHAYA DI ARM - akses tidak selaras bisa menyebabkan crash\n\nGunakan hanya kalau benar-benar perlu (protokol jaringan, format biner tertentu).',
 8),

(E'Mengapa struct TIDAK boleh dibandingkan dengan memcmp?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena padding berisi nilai tak tentu, sehingga dua struct dengan data identik bisa dianggap berbeda.\n\nmemcmp membandingkan SELURUH byte termasuk padding. Standar C++ tidak menentukan isi padding - bisa nilai nol, sisa data lama, atau apa pun.\n\nBandingkan anggota satu per satu, atau pakai operator== default (C++20).',
 9),

(E'Apa bahaya menulis struct langsung ke berkas?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Byte padding yang isinya tak tentu ikut tertulis, sehingga data bisa kacau saat dibaca di platform lain.\n\nberkas.write((char*)&x, sizeof(Campur));\n\nYang tertulis termasuk padding. Kalau dibaca di platform dengan aturan alignment berbeda, layout-nya tidak cocok.\n\nSolusi: gunakan JSON, Protocol Buffers, atau tulis setiap anggota satu per satu.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'struct-memori';

-- OPSI SOAL (struct-memori)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'5', false, 1),
  (1, 'B', E'8', true, 2),
  (1, 'C', E'4', false, 3),
  (1, 'D', E'12', false, 4),
  (2, 'A', E'Agar setiap anggota dimulai pada alamat selaras sehingga CPU bisa membacanya dalam satu operasi', true, 1),
  (2, 'B', E'Untuk menghemat penggunaan memori', false, 2),
  (2, 'C', E'Untuk memudahkan compiler membaca kode', false, 3),
  (2, 'D', E'Untuk mencegah akses tidak sah', false, 4),
  (3, 'A', E'1', false, 1),
  (3, 'B', E'4', true, 2),
  (3, 'C', E'5', false, 3),
  (3, 'D', E'8', false, 4),
  (4, 'A', E'10', false, 1),
  (4, 'B', E'16', false, 2),
  (4, 'C', E'24', true, 3),
  (4, 'D', E'32', false, 4),
  (5, 'A', E'24 16', true, 1),
  (5, 'B', E'16 24', false, 2),
  (5, 'C', E'24 24', false, 3),
  (5, 'D', E'10 10', false, 4),
  (6, 'A', E'Padding berkurang ketika anggota kecil dikelompokkan berdampingan, biasanya tercapai dengan mengurutkan', true, 1),
  (6, 'B', E'Padding selalu berkurang dengan mengurutkan dari besar ke kecil', false, 2),
  (6, 'C', E'Padding tidak bisa dikurangi dengan cara apa pun', false, 3),
  (6, 'D', E'Padding berkurang dengan menambah anggota', false, 4),
  (7, 'A', E'Memaksa compiler mengurangi atau menghilangkan padding', true, 1),
  (7, 'B', E'Mengurutkan anggota secara otomatis', false, 2),
  (7, 'C', E'Menambah padding agar alignment lebih baik', false, 3),
  (7, 'D', E'Mengubah tipe anggota agar seragam', false, 4),
  (8, 'A', E'Lebih lambat, tidak portabel, dan bisa crash di ARM', true, 1),
  (8, 'B', E'Struct tidak bisa dikompilasi', false, 2),
  (8, 'C', E'Anggota struct tidak bisa diakses', false, 3),
  (8, 'D', E'Struct tidak bisa disalin', false, 4),
  (9, 'A', E'Padding berisi nilai tak tentu, sehingga struct dengan data sama bisa dianggap berbeda', true, 1),
  (9, 'B', E'memcmp tidak mendukung struct', false, 2),
  (9, 'C', E'memcmp terlalu lambat untuk struct besar', false, 3),
  (9, 'D', E'memcmp hanya bisa membandingkan tipe primitif', false, 4),
  (10, 'A', E'Byte padding yang isinya tak tentu ikut tertulis, data bisa kacau di platform lain', true, 1),
  (10, 'B', E'Struct tidak bisa ditulis ke berkas', false, 2),
  (10, 'C', E'Berkas menjadi terlalu besar', false, 3),
  (10, 'D', E'Program akan crash saat menulis', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'struct-memori';

-- =========================================================
-- Modul 7: pointer-dasar (Dasar Pointer & Alamat Memori)
-- =========================================================
-- FLASHCARD (pointer-dasar)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa itu pointer?',
 E'Variabel yang menyimpan ALAMAT memori,\nbukan nilai langsung.\n\nint nilai = 42;\nint* p = &nilai;   // p menyimpan alamat nilai',
 'ISTILAH', null, null, 1),

(E'Bagaimana cara mendeklarasikan pointer ke int?',
 E'int* p;\n\nCara membaca: "p adalah pointer ke int".\nBaca dari KANAN ke KIRI.',
 'SINTAKS', E'int* p;', 'cpp', 2),

(E'Bagaimana cara mengambil alamat sebuah variabel?',
 E'Pakai operator & (address-of):\n\nint nilai = 42;\ncout << &nilai;   // 0x7ffd...\n\n& adalah kebalikan dari * (dereferensi).',
 'SINTAKS', E'int nilai = 42;\\nint* p = &nilai;', 'cpp', 3),

(E'Apa yang salah dari int* a, b;?',
 E'HANYA a yang pointer. b adalah int BIASA.\n\nBukti:\nsizeof(a) = 8 (pointer)\nsizeof(b) = 4 (int)\n\nTanda * hanya berlaku untuk variabel PERTAMA.\n\nBenar: int* a; int* b;',
 'JEBAKAN', E'int* a, b;   // HANYA a yang pointer!', 'cpp', 4),

(E'Apa dua arti tanda bintang pada pointer?',
 E'1. Di DEKLARASI = bagian dari TIPE\n   int* p;\n\n2. Di EKSPRESI = operator DEREFERENSI\n   *p = 100;\n\nIni yang sering membingungkan pemula.',
 'ISTILAH', null, null, 5),

(E'Apa yang terjadi jika mendereferensi nullptr?',
 E'UNDEFINED BEHAVIOR - biasanya crash,\ntetapi standar tidak menjamin itu.\n\nint* p = nullptr;\ncout << *p;   // UB!\n\nSelalu periksa: if (p) { cout << *p; }',
 'JEBAKAN', null, null, 6),

(E'Mengapa pointer harus selalu diinisialisasi?',
 E'Pointer yang tidak diinisialisasi berisi ALAMAT ACAK\n(wild pointer).\n\nint* p;        // BAHAYA - alamat acak\ncout << *p;    // UB!\n\nKalau belum tahu mau menunjuk ke mana:\nint* p = nullptr;',
 'JEBAKAN', null, null, 7),

(E'Apa perbedaan const int* p dan int* const p?',
 E'const int* p  : nilai tidak bisa diubah, alamat BOLEH\nint* const p  : alamat tidak bisa diubah, nilai BOLEH\nconst int* const p : keduanya tidak bisa diubah\n\nCara ingat: baca dari kanan ke kiri.\nconst yang paling dekat dengan p mengunci p.',
 'BANDING', null, null, 8),

(E'Apa yang terjadi jika mengakses nilai variabel lokal yang sudah keluar scope lewat pointer?',
 E'UNDEFINED BEHAVIOR.\n\nint* f() {\n    int lokal = 42;\n    return &lokal;   // BAHAYA!\n}\n\nSetelah f() selesai, lokal sudah tidak ada.\nPointer yang dikembalikan adalah DANGLING POINTER.\n\nMemakainya = UB.',
 'JEBAKAN', E'int* f() {\\n    int lokal = 42;\\n    return &lokal;  // UB!\\n}', 'cpp', 9),

(E'int nilai = 42;\nint* p = &nilai;\n*p = 100;\ncout << nilai;',
 E'Output: 100\n\n*p = 100 mengubah nilai di alamat yang ditunjuk p.\nKarena p menunjuk ke nilai, maka nilai ikut berubah.\n\nIni kekuatan pointer: mengubah variabel lain\ntanpa menyentuh namanya.',
 'TRACING', E'int nilai = 42;\\nint* p = &nilai;\\n*p = 100;\\ncout << nilai;', 'cpp', 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'pointer-dasar';

-- SOAL (pointer-dasar)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Apa yang disimpan oleh pointer?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Alamat memori, bukan nilai langsung.\n\nint nilai = 42;\nint* p = &nilai;   // p menyimpan ALAMAT nilai\n\nPengecoh "nilai variabel" salah - itu isi, bukan alamat.\nPengecoh "salinan variabel" salah - pointer tidak menyalin.',
 1),

(E'Apa yang salah dari deklarasi int* a, b;?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Hanya a yang pointer; b adalah int biasa.\n\nBukti: sizeof(a) = 8 (pointer), sizeof(b) = 4 (int).\n\nTanda * hanya berlaku untuk variabel PERTAMA dalam deklarasi.\n\nCara benar: int* a; int* b; atau int *a, *b;',
 2),

(E'int nilai = 42;\nint* p = &nilai;\n*p = 100;\ncout << nilai;',
 E'int nilai = 42;\\nint* p = &nilai;\\n*p = 100;\\ncout << nilai;', 'cpp', 'TRACE', 'TRACING',
 E'Output: 100\n\n*p = 100 mengubah nilai di ALAMAT yang ditunjuk p.\nKarena p menunjuk ke nilai, maka nilai ikut berubah.\n\nIni kekuatan pointer: mengubah variabel lain tanpa menyentuh namanya.\n\nPengecoh 42 = nilai sebelum diubah.',
 3),

(E'Apa dua arti tanda bintang pada pointer?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Di deklarasi ia bagian dari TIPE; di ekspresi ia operator DEREFERENSI.\n\nint* p = &nilai;   // * bagian dari tipe\n*p = 100;          // * operator dereferensi\n\nIni yang sering membingungkan pemula karena simbolnya sama tetapi maknanya berbeda.',
 4),

(E'Apa yang terjadi jika mendereferensi nullptr?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Undefined behavior - biasanya crash, tetapi standar tidak menjamin itu.\n\nint* p = nullptr;\ncout << *p;   // UB!\n\nPengecoh "selalu crash" kurang tepat - standar hanya bilang UB, jadi bisa saja tampak berjalan.\nPengecoh "mengembalikan 0" salah - tidak ada nilai yang dikembalikan.',
 5),

(E'Mengapa pointer yang tidak diinisialisasi berbahaya?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena berisi alamat acak (wild pointer), dan mendereferensinya adalah undefined behavior.\n\nint* p;        // berisi alamat acak\ncout << *p;    // UB!\n\nSelalu inisialisasi: int* p = nullptr;',
 6),

(E'Apa perbedaan const int* p dan int* const p?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: const int* p mengunci NILAI; int* const p mengunci ALAMAT.\n\nconst int* p  : nilai tidak bisa diubah, alamat boleh\nint* const p  : alamat tidak bisa diubah, nilai boleh\n\nCara ingat: baca dari kanan ke kiri. const yang paling dekat dengan p mengunci p.',
 7),

(E'Mengapa mengembalikan pointer ke variabel lokal berbahaya?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena variabel lokal sudah tidak ada setelah fungsi selesai, sehingga pointer menjadi dangling dan memakainya adalah UB.\n\nint* f() {\n    int lokal = 42;\n    return &lokal;   // BAHAYA!\n}\n\nSetelah f() selesai, memori lokal sudah dibebaskan.',
 8),

(E'Bagaimana pointer bisa mengubah variabel dari dalam fungsi?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: Dengan mengirim alamat variabel, lalu fungsi mendereferensinya.\n\nvoid ubah(int* q) { *q = 777; }\nint y = 1;\nubah(&y);   // y jadi 777\n\nKalau dikirim nilai biasa, perubahan tidak mempengaruhi aslinya:\nvoid ubahSalah(int q) { q = 888; }   // y tidak berubah',
 9),

(E'Apa perbedaan utama pointer C++ dan referensi Python?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: C++ bisa aritmetika pointer dan manajemen memori manual; Python tidak bisa aritmetika dan memori dikelola otomatis.\n\nC++: p + 1 (aritmetika), delete (manual), alamat terlihat\nPython: tidak bisa aritmetika, garbage collector otomatis, id() untuk identitas\n\nKeduanya sama-sama menunjuk objek, tetapi tingkat kontrolnya berbeda jauh.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'pointer-dasar';

-- OPSI SOAL (pointer-dasar)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'Alamat memori, bukan nilai langsung', true, 1),
  (1, 'B', E'Nilai variabel', false, 2),
  (1, 'C', E'Salinan variabel', false, 3),
  (1, 'D', E'Nama variabel', false, 4),
  (2, 'A', E'Hanya a yang pointer; b adalah int biasa', true, 1),
  (2, 'B', E'a dan b keduanya pointer', false, 2),
  (2, 'C', E'Keduanya bukan pointer', false, 3),
  (2, 'D', E'Deklarasi tidak valid dan gagal kompilasi', false, 4),
  (3, 'A', E'100', true, 1),
  (3, 'B', E'42', false, 2),
  (3, 'C', E'0', false, 3),
  (3, 'D', E'Error', false, 4),
  (4, 'A', E'Di deklarasi bagian dari tipe; di ekspresi operator dereferensi', true, 1),
  (4, 'B', E'Selalu berarti perkalian', false, 2),
  (4, 'C', E'Selalu berarti dereferensi', false, 3),
  (4, 'D', E'Tidak ada arti khusus', false, 4),
  (5, 'A', E'Undefined behavior - biasanya crash, tetapi standar tidak menjamin itu', true, 1),
  (5, 'B', E'Selalu crash', false, 2),
  (5, 'C', E'Mengembalikan nilai 0', false, 3),
  (5, 'D', E'Melempar exception', false, 4),
  (6, 'A', E'Karena berisi alamat acak (wild pointer), dan mendereferensinya adalah UB', true, 1),
  (6, 'B', E'Karena pointer tidak bisa dibandingkan', false, 2),
  (6, 'C', E'Karena pointer memakan lebih banyak memori', false, 3),
  (6, 'D', E'Karena compiler menolak pointer tanpa nilai', false, 4),
  (7, 'A', E'const int* p mengunci NILAI; int* const p mengunci ALAMAT', true, 1),
  (7, 'B', E'Keduanya sama saja', false, 2),
  (7, 'C', E'const int* p mengunci alamat; int* const p mengunci nilai', false, 3),
  (7, 'D', E'Keduanya mengunci nilai dan alamat', false, 4),
  (8, 'A', E'Variabel lokal sudah tidak ada setelah fungsi selesai, pointer menjadi dangling, dan memakainya UB', true, 1),
  (8, 'B', E'Compiler menolak mengembalikan pointer', false, 2),
  (8, 'C', E'Pointer otomatis menjadi nullptr', false, 3),
  (8, 'D', E'Nilai variabel lokal ikut dikembalikan', false, 4),
  (9, 'A', E'Dengan mengirim alamat variabel, lalu fungsi mendereferensinya', true, 1),
  (9, 'B', E'Dengan mengirim variabel sebagai nilai', false, 2),
  (9, 'C', E'Dengan mendeklarasikan variabel sebagai global', false, 3),
  (9, 'D', E'Dengan mengembalikan nilai dari fungsi', false, 4),
  (10, 'A', E'C++ bisa aritmetika pointer dan manajemen memori manual; Python tidak bisa aritmetika dan memori otomatis', true, 1),
  (10, 'B', E'C++ dan Python sama-sama punya aritmetika pointer', false, 2),
  (10, 'C', E'Python punya aritmetika pointer, C++ tidak', false, 3),
  (10, 'D', E'Keduanya tidak bisa menunjuk objek', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'pointer-dasar';

-- =========================================================
-- Modul 8: pointer-array (Pointer & Array: Aritmetika Pointer)
-- =========================================================
-- FLASHCARD (pointer-array)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa itu array-to-pointer decay?',
 E'Perubahan otomatis nama array menjadi pointer ke elemen\npertamanya dalam ekspresi tertentu.\n\nint arr[5];\nint* p = arr;   // arr decay jadi &arr[0]\n\nAkibatnya informasi ukuran bisa hilang.',
 'ISTILAH', null, null, 1),

(E'int arr[5];\ncout << (arr == &arr[0]);',
 E'Output: 1 (true)\n\nNama array dan alamat elemen pertamanya\nmenghasilkan alamat yang SAMA.\n\nIni bukti decay: arr berubah jadi pointer ke arr[0].',
 'TRACING', E'int arr[5];\\ncout << (arr == &arr[0]);  // 1', 'cpp', 2),

(E'Apa perbedaan arr dan &arr?',
 E'Keduanya alamat SAMA, tapi TIPE berbeda:\n\narr  : int*        -> +1 melompat 4 byte (satu elemen)\n&arr : int(*)[5]   -> +1 melompat 20 byte (SELURUH array)\n\nBukti terukur:\n(char*)(arr+1)-(char*)arr    = 4\n(char*)(&arr+1)-(char*)&arr  = 20',
 'BANDING', null, null, 3),

(E'Apa yang terjadi pada sizeof(arr) di dalam fungsi?',
 E'Menghasilkan ukuran POINTER (8 byte), bukan ukuran array.\n\nvoid f(int arr[]) {\n    sizeof(arr);   // 8, bukan 20!\n}\n\nPenyebab: parameter int arr[] sebenarnya adalah int* arr.\nInformasi ukuran HILANG.',
 'JEBAKAN', E'void f(int arr[]) {\\n    sizeof(arr);  // 8, bukan ukuran array\\n}', 'cpp', 4),

(E'Berapa byte yang ditambah p + 1 jika p adalah int*?',
 E'4 byte (= sizeof(int)).\n\nAritmetika pointer mengikuti SKALA TIPE,\nbukan 1 byte.\n\nchar*   -> +1 byte\ndouble* -> +8 byte\nint*    -> +4 byte',
 'MEMORI', null, null, 5),

(E'int arr[5] = {10, 20, 30, 40, 50};\nint* awal = &arr[0];\nint* akhir = &arr[4];\ncout << (akhir - awal);',
 E'Output: 4\n\nSelisih dua pointer menghasilkan JUMLAH ELEMEN,\nbukan byte.\n\n(akhir - awal) = 4 elemen, bukan 16 byte.',
 'TRACING', E'int arr[5] = {10, 20, 30, 40, 50};\\ncout << (&arr[4] - &arr[0]);  // 4', 'cpp', 6),

(E'Apakah arr[i] sama dengan *(arr + i)?',
 E'YA, keduanya IDENTIK.\n\narr[i] DIDEfinisikan sebagai *(arr + i).\n\nint arr[5] = {10,20,30,40,50};\narr[3]     = 40\n*(arr + 3) = 40\n\nIni bukan kebetulan - ini definisi bahasanya.',
 'MEMORI', null, null, 7),

(E'Mengapa i[arr] juga valid?',
 E'Karena arr[i] diterjemahkan jadi *(arr + i),\ndan penjumlahan bersifat KOMUTATIF:\n\n*(arr + i) == *(i + arr)\n\nJadi 3[arr] juga valid dan bernilai sama dengan arr[3].\n\nTETAPI jangan dipakai - membingungkan pembaca.',
 'JEBAKAN', E'int arr[5] = {10,20,30,40,50};\\ncout << 3[arr];  // 40 - valid tapi jangan dipakai', 'cpp', 8),

(E'Apa keuntungan std::span dibanding int arr[] sebagai parameter?',
 E'std::span menyimpan POINTER dan UKURAN sekaligus.\n\nvoid f(std::span<int> arr) {\n    cout << arr.size();   // ukuran tersimpan!\n    for (int x : arr) cout << x;\n}\n\nMasalah decay teratasi: ukuran tidak hilang,\ndan tetap fleksibel untuk array berbagai ukuran.',
 'KAPAN', E'void f(std::span<int> arr) {\\n    cout << arr.size();\\n}', 'cpp', 9),

(E'Apa perbedaan slice Python dan pointer C++?',
 E'Slice Python MENYALIN:\n  s = arr[1:4]   -> salinan baru\n  s[0] = 999     -> arr TIDAK berubah\n\nPointer C++ TIDAK menyalin:\n  int* p = &arr[1];\n  p[0] = 999;    -> arr[1] IKUT berubah\n\nIni perbedaan mendasar: nilai vs referensi.',
 'BANDING', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'pointer-array';

-- SOAL (pointer-array)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Apa itu array-to-pointer decay?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Perubahan otomatis nama array menjadi pointer ke elemen pertamanya.\n\nint arr[5];\nint* p = arr;   // arr decay jadi &arr[0]\n\nTerjadi saat dikirim ke fungsi, di-assign ke pointer, atau dalam aritmetika.\nTIDAK terjadi pada sizeof(arr) dan &arr.',
 1),

(E'int arr[5];\ncout << (arr == &arr[0]);',
 E'int arr[5];\\ncout << (arr == &arr[0]);', 'cpp', 'TRACE', 'TRACING',
 E'Output: 1\n\nNama array dan alamat elemen pertamanya menghasilkan alamat yang SAMA.\nIni bukti decay: arr berubah jadi pointer ke arr[0].\n\nPengecoh 0 salah - keduanya memang alamat yang sama.',
 2),

(E'Apa perbedaan arr dan &arr?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Tipenya berbeda, sehingga aritmetikanya berbeda.\n\narr  : int*       -> +1 melompat 4 byte (satu elemen)\n&arr : int(*)[5]  -> +1 melompat 20 byte (SELURUH array)\n\nKeduanya menghasilkan ALAMAT yang sama, tetapi tipe dan perilaku +1 berbeda.\n\nIni detail yang sering ditanyakan di wawancara kerja.',
 3),

(E'Berapa nilai sizeof(arr) di dalam fungsi void f(int arr[])?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: 8 byte - ukuran pointer, bukan ukuran array.\n\nParameter int arr[] sebenarnya adalah int* arr. Compiler menerjemahkannya, sehingga informasi ukuran array HILANG.\n\nPengecoh "20 byte" salah - itu ukuran array di main, bukan di fungsi.',
 4),

(E'Mengapa aritmetika pointer mengikuti skala tipe, bukan 1 byte?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena tujuan p + 1 adalah menunjuk elemen berikutnya, bukan byte berikutnya.\n\nKalau int* menambah 1 byte, ia akan menunjuk ke tengah-tengah int - tidak berguna. Dengan skala tipe, p + 1 selalu tepat di elemen berikutnya.\n\nchar* +1 = 1 byte, int* +1 = 4 byte, double* +1 = 8 byte.',
 5),

(E'int arr[5] = {10, 20, 30, 40, 50};\ncout << (&arr[4] - &arr[0]);',
 E'int arr[5] = {10, 20, 30, 40, 50};\\ncout << (&arr[4] - &arr[0]);', 'cpp', 'TRACE', 'TRACING',
 E'Output: 4\n\nSelisih dua pointer menghasilkan JUMLAH ELEMEN, bukan byte.\n\n(&arr[4] - &arr[0]) = 4 elemen, bukan 16 byte.\n\nPengecoh 16 = menghitung byte (4 elemen x 4 byte).',
 6),

(E'Apakah arr[i] sama dengan *(arr + i)?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Ya, keduanya identik.\n\narr[i] DIDEFINISIKAN sebagai *(arr + i). Ini bukan kebetulan atau optimasi compiler - ini definisi bahasanya.\n\nKonsekuensinya: array tidak menyimpan informasi batas, sehingga C++ tidak bisa mendeteksi akses di luar batas.',
 7),

(E'Mengapa i[arr] juga valid?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Karena arr[i] diterjemahkan jadi *(arr + i), dan penjumlahan bersifat komutatif.\n\n*(arr + i) == *(i + arr)\n\nJadi 3[arr] valid dan bernilai sama dengan arr[3].\n\nTETAPI jangan dipakai - membingungkan pembaca dan tidak ada gunanya. Ini hanya fakta bahasa yang menarik.',
 8),

(E'Apa keuntungan utama std::span dibanding int arr[] sebagai parameter?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: std::span menyimpan pointer DAN ukuran sekaligus.\n\nvoid f(std::span<int> arr) {\n    cout << arr.size();   // ukuran tersimpan\n}\n\nMasalah decay teratasi: ukuran tidak hilang, dan tetap fleksibel untuk array berbagai ukuran.\n\nint (&arr)[5] juga menyimpan ukuran, tetapi ukurannya harus diketahui saat kompilasi.',
 9),

(E'arr = [10, 20, 30, 40, 50]\ns = arr[1:4]\ns[0] = 999\nprint(arr[1])',
 E'arr = [10, 20, 30, 40, 50]\\ns = arr[1:4]\\ns[0] = 999\\nprint(arr[1])', 'python', 'TRACE', 'BANDING',
 E'Output: 20\n\nSlicing Python MENYALIN elemen. Mengubah s[0] tidak mengubah arr[1].\n\nBandingkan C++:\nint* p = &arr[1];\np[0] = 999;   // arr[1] IKUT berubah\n\nPengecoh 999 salah - itu mengira slice menunjuk ke elemen asli.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'pointer-array';

-- OPSI SOAL (pointer-array)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'Perubahan otomatis nama array menjadi pointer ke elemen pertamanya', true, 1),
  (1, 'B', E'Penghapusan array yang tidak terpakai', false, 2),
  (1, 'C', E'Konversi array menjadi list', false, 3),
  (1, 'D', E'Pembesaran array otomatis', false, 4),
  (2, 'A', E'1', true, 1),
  (2, 'B', E'0', false, 2),
  (2, 'C', E'Error', false, 3),
  (2, 'D', E'Bergantung compiler', false, 4),
  (3, 'A', E'arr bertipe int* (+1 = 4 byte); &arr bertipe int(*)[5] (+1 = 20 byte)', true, 1),
  (3, 'B', E'Keduanya bertipe sama dan berperilaku sama', false, 2),
  (3, 'C', E'arr adalah nilai, &arr adalah alamat', false, 3),
  (3, 'D', E'&arr tidak valid untuk array', false, 4),
  (4, 'A', E'8 byte - ukuran pointer, karena parameter sebenarnya adalah int*', true, 1),
  (4, 'B', E'20 byte - sama seperti di main', false, 2),
  (4, 'C', E'4 byte - ukuran satu int', false, 3),
  (4, 'D', E'Error kompilasi', false, 4),
  (5, 'A', E'Karena tujuan p + 1 adalah menunjuk elemen berikutnya, bukan byte berikutnya', true, 1),
  (5, 'B', E'Karena compiler mengoptimalkan aritmetika', false, 2),
  (5, 'C', E'Karena pointer menyimpan tipe data', false, 3),
  (5, 'D', E'Karena memori komputer berbasis blok', false, 4),
  (6, 'A', E'4', true, 1),
  (6, 'B', E'16', false, 2),
  (6, 'C', E'1', false, 3),
  (6, 'D', E'Error', false, 4),
  (7, 'A', E'Ya, arr[i] didefinisikan sebagai *(arr + i)', true, 1),
  (7, 'B', E'Tidak, keduanya berbeda', false, 2),
  (7, 'C', E'Ya, tetapi hanya untuk array char', false, 3),
  (7, 'D', E'Ya, tetapi hanya di C++20 ke atas', false, 4),
  (8, 'A', E'Karena arr[i] menjadi *(arr + i) dan penjumlahan bersifat komutatif', true, 1),
  (8, 'B', E'Karena compiler memperbaiki urutan otomatis', false, 2),
  (8, 'C', E'Karena i[arr] adalah sintaks khusus', false, 3),
  (8, 'D', E'i[arr] sebenarnya tidak valid', false, 4),
  (9, 'A', E'std::span menyimpan pointer DAN ukuran sekaligus', true, 1),
  (9, 'B', E'std::span lebih cepat diakses', false, 2),
  (9, 'C', E'std::span menyalin array', false, 3),
  (9, 'D', E'std::span hanya untuk array char', false, 4),
  (10, 'A', E'20', true, 1),
  (10, 'B', E'999', false, 2),
  (10, 'C', E'30', false, 3),
  (10, 'D', E'Error', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'pointer-array';

-- =========================================================
-- Modul 9: pointer-struct (Pointer ke Struct & Arrow Operator)
-- =========================================================
-- FLASHCARD (pointer-struct)
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

-- SOAL (pointer-struct)
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

-- OPSI SOAL (pointer-struct)
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

-- =========================================================
-- Modul 10: pointer-dinamis (Alokasi Memori Dinamis)
-- =========================================================
-- FLASHCARD (pointer-dinamis)
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values
(E'Apa perbedaan stack dan heap?',
 E'STACK:\n- sangat cepat\n- kecil (1-8 MB)\n- masa hidup otomatis (keluar scope)\n- dikelola compiler\n\nHEAP:\n- lebih lambat\n- besar\n- masa hidup MANUAL (sampai delete)\n- dikelola programmer',
 'BANDING', null, null, 1),

(E'Bagaimana cara mengalokasikan satu nilai di heap?',
 E'int* p = new int(42);   // alokasi + inisialisasi\n\ncout << *p;             // 42\n\ndelete p;               // WAJIB dibebaskan',
 'SINTAKS', E'int* p = new int(42);\\ndelete p;', 'cpp', 2),

(E'Bagaimana cara mengalokasikan array di heap?',
 E'int* arr = new int[5];   // 5 elemen\n\nfor (int i = 0; i < 5; i++) arr[i] = i * 10;\n\ndelete[] arr;             // PERHATIKAN: delete[]',
 'SINTAKS', E'int* arr = new int[5];\\ndelete[] arr;   // pakai delete[]!', 'cpp', 3),

(E'Mengapa new[] harus dipasangkan delete[]?',
 E'Karena keduanya BERBEDA:\n\nnew int      -> delete p\nnew int[5]   -> delete[] arr\n\nMencampurnya adalah UNDEFINED BEHAVIOR:\n\nint* arr = new int[5];\ndelete arr;      // UB! seharusnya delete[]',
 'JEBAKAN', E'int* arr = new int[5];\\ndelete arr;   // UB! seharusnya delete[]', 'cpp', 4),

(E'Apa itu memory leak?',
 E'Memori heap yang TIDAK dibebaskan karena lupa delete.\n\nvoid bocor() {\n    int* p = new int(42);\n    // lupa delete -> LEAK\n}\n\nAkibat: memori terpakai sampai program berakhir.\nDalam program panjang, memori habis -> crash.',
 'ISTILAH', null, null, 5),

(E'Apa itu dangling pointer?',
 E'Pointer yang menunjuk ke memori yang SUDAH dibebaskan.\n\nint* p = new int(42);\ndelete p;\ncout << *p;   // UB! p adalah dangling pointer\n\nBAHAYANYA: mungkin tampak berjalan normal karena\nnilai lama masih ada. Tapi itu undefined behavior.\n\nPerbaikan: p = nullptr; setelah delete.',
 'JEBAKAN', E'int* p = new int(42);\\ndelete p;\\ncout << *p;  // UB! dangling pointer', 'cpp', 6),

(E'Apa itu double free?',
 E'Memanggil delete DUA KALI pada pointer yang sama.\n\nint* p = new int(42);\ndelete p;\ndelete p;      // UB!\n\nPerbaikan:\ndelete p;\np = nullptr;\ndelete p;      // AMAN - delete pada nullptr tidak apa-apa',
 'JEBAKAN', E'delete p;\\ndelete p;  // UB!\\n\\n// Perbaikan:\\ndelete p; p = nullptr;\\ndelete p;  // aman', 'cpp', 7),

(E'Mengapa selalu set pointer ke nullptr setelah delete?',
 E'Dua alasan:\n\n1. Mencegah DANGLING POINTER\n   Akses lewat nullptr akan jelas salah,\n   bukan UB yang tersembunyi\n\n2. Membuat DELETE KEDUA aman\n   delete pada nullptr tidak melakukan apa-apa\n\ndelete p;\np = nullptr;',
 'KAPAN', E'delete p;\\np = nullptr;   // selalu lakukan ini', 'cpp', 8),

(E'Apa itu unique_ptr?',
 E'Smart pointer dengan kepemilikan TUNGGAL.\n\n#include <memory>\n\nauto p = make_unique<int>(99);\ncout << *p;   // 99\n\n// keluar scope -> OTOMATIS dibebaskan\n\nTidak bisa DISALIN (kepemilikan tunggal),\ntapi bisa DIPINDAHKAN dengan move().',
 'ISTILAH', E'auto p = make_unique<int>(99);\\n// otomatis dibebaskan saat keluar scope', 'cpp', 9),

(E'Bagaimana Python mengelola memori?',
 E'OTOMATIS, dengan dua mekanisme:\n\n1. REFERENCE COUNTING (utama)\n   Menghitung berapa nama menunjuk ke objek.\n   Saat mencapai nol -> dibebaskan.\n\n2. GARBAGE COLLECTOR (untuk siklus)\n   Mendeteksi objek yang saling menunjuk\n   sehingga penghitungnya tidak pernah nol.\n\nTidak ada new, tidak ada delete.',
 'ISTILAH', null, null, 10)
) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'pointer-dinamis';

-- SOAL (pointer-dinamis)
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values
(E'Apa perbedaan utama stack dan heap?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Stack dikelola otomatis dan cepat; heap dikelola manual dan lebih lambat.\n\nSTACK: sangat cepat, kecil (1-8 MB), masa hidup otomatis saat keluar scope.\nHEAP: lebih lambat, besar, masa hidup manual sampai delete.\n\nPengecoh "stack lebih besar" salah - justru heap yang besar.',
 1),

(E'Bagaimana cara mengalokasikan satu nilai di heap?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: int* p = new int(42);\n\nnew mengalokasikan di heap dan mengembalikan pointer. delete membebaskannya.\n\nint* p = &x; salah - itu menunjuk variabel stack, bukan alokasi heap.\nint p = new int; salah - p bukan pointer.\nmalloc saja tanpa free adalah gaya C, bukan C++.',
 2),

(E'Bagaimana cara mengalokasikan array di heap?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: int* arr = new int[5];\n\nPerhatikan tanda kurung siku [5] untuk array.\n\nint* arr = new int; salah - itu alokasi SATU int, bukan array.\nint arr[5] = new int[5]; salah - itu array stack, bukan heap.\nint* arr = new int(5); salah - itu satu int bernilai 5.',
 3),

(E'Apa yang terjadi jika memakai delete (bukan delete[]) untuk memori dari new[]?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Undefined behavior.\n\nint* arr = new int[5];\ndelete arr;      // UB! seharusnya delete[]\n\nnew[] HARUS dipasangkan delete[], dan new harus dipasangkan delete. Mencampurnya bisa menyebabkan crash atau kerusakan heap.\n\nAturan ini tidak boleh dilanggar.',
 4),

(E'Apa itu memory leak?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Memori heap yang tidak dibebaskan karena lupa delete.\n\nvoid bocor() {\n    int* p = new int(42);\n    // lupa delete\n}\n\nAkibat: memori terpakai sampai program berakhir. Dalam program panjang, memori habis dan program crash.\n\nPengecoh "crash seketika" salah - leak bekerja perlahan.',
 5),

(E'Apa itu dangling pointer?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Pointer yang menunjuk ke memori yang sudah dibebaskan.\n\nint* p = new int(42);\ndelete p;\ncout << *p;   // UB! p adalah dangling pointer\n\nBahayanya: mungkin tampak berjalan normal karena nilai lama masih ada di memori. Tapi itu undefined behavior.\n\nPerbaikan: set p = nullptr setelah delete.',
 6),

(E'Apa itu double free?',
 null, null, 'PG', 'JEBAKAN',
 E'Jawaban: Memanggil delete dua kali pada pointer yang sama.\n\ndelete p;\ndelete p;      // UB!\n\nPerbaikannya:\ndelete p;\np = nullptr;\ndelete p;      // AMAN - delete pada nullptr tidak melakukan apa-apa\n\nIni salah satu alasan selalu set nullptr setelah delete.',
 7),

(E'Mengapa selalu set pointer ke nullptr setelah delete?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: Untuk mencegah dangling pointer dan membuat delete kedua aman.\n\n1. Akses lewat nullptr akan jelas salah (bukan UB tersembunyi)\n2. delete pada nullptr tidak melakukan apa-apa, sehingga double free terhindar\n\ndelete p;\np = nullptr;   // selalu lakukan',
 8),

(E'Apa itu unique_ptr?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Smart pointer dengan kepemilikan tunggal.\n\nauto p = make_unique<int>(99);\n// keluar scope -> otomatis dibebaskan\n\nTidak bisa DISALIN karena kepemilikannya tunggal, tetapi bisa DIPINDAHKAN dengan move().\n\nPengecoh "kepemilikan bersama" salah - itu shared_ptr.',
 9),

(E'Bagaimana Python mengelola memori?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: Otomatis dengan reference counting, plus garbage collector untuk siklus referensi.\n\n1. REFERENCE COUNTING: menghitung berapa nama menunjuk objek. Saat mencapai nol, dibebaskan.\n2. GARBAGE COLLECTOR: mendeteksi objek yang saling menunjuk sehingga penghitungnya tidak pernah nol.\n\nTidak ada new, tidak ada delete.',
 10)
) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'pointer-dinamis';

-- OPSI SOAL (pointer-dinamis)
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (1, 'A', E'Stack dikelola otomatis dan cepat; heap dikelola manual dan lebih lambat', true, 1),
  (1, 'B', E'Stack lebih besar dari heap', false, 2),
  (1, 'C', E'Heap otomatis, stack manual', false, 3),
  (1, 'D', E'Keduanya dikelola otomatis', false, 4),
  (2, 'A', E'int* p = new int(42);', true, 1),
  (2, 'B', E'int* p = &x;', false, 2),
  (2, 'C', E'int p = new int;', false, 3),
  (2, 'D', E'int* p = malloc(4);', false, 4),
  (3, 'A', E'int* arr = new int[5];', true, 1),
  (3, 'B', E'int* arr = new int;', false, 2),
  (3, 'C', E'int arr[5] = new int[5];', false, 3),
  (3, 'D', E'int* arr = new int(5);', false, 4),
  (4, 'A', E'Undefined behavior', true, 1),
  (4, 'B', E'Hanya membebaskan elemen pertama', false, 2),
  (4, 'C', E'Compiler menolak dan gagal build', false, 3),
  (4, 'D', E'Aman, karena delete sama dengan delete[]', false, 4),
  (5, 'A', E'Memori heap yang tidak dibebaskan karena lupa delete', true, 1),
  (5, 'B', E'Program crash seketika', false, 2),
  (5, 'C', E'Memori yang dibebaskan dua kali', false, 3),
  (5, 'D', E'Pointer yang menunjuk memori tidak valid', false, 4),
  (6, 'A', E'Pointer yang menunjuk ke memori yang sudah dibebaskan', true, 1),
  (6, 'B', E'Pointer yang bernilai nullptr', false, 2),
  (6, 'C', E'Pointer yang tidak diinisialisasi', false, 3),
  (6, 'D', E'Pointer yang menunjuk array', false, 4),
  (7, 'A', E'Memanggil delete dua kali pada pointer yang sama', true, 1),
  (7, 'B', E'Menghapus dua elemen sekaligus', false, 2),
  (7, 'C', E'Menghapus array dengan delete biasa', false, 3),
  (7, 'D', E'Menghapus pointer yang belum dialokasikan', false, 4),
  (8, 'A', E'Mencegah dangling pointer dan membuat delete kedua aman', true, 1),
  (8, 'B', E'Agar memori lebih cepat dibebaskan', false, 2),
  (8, 'C', E'Agar compiler tidak memberi peringatan', false, 3),
  (8, 'D', E'Karena delete memerlukan nilai nullptr', false, 4),
  (9, 'A', E'Smart pointer dengan kepemilikan tunggal', true, 1),
  (9, 'B', E'Smart pointer dengan kepemilikan bersama', false, 2),
  (9, 'C', E'Pointer yang tidak bisa dipindahkan', false, 3),
  (9, 'D', E'Pointer untuk array saja', false, 4),
  (10, 'A', E'Otomatis dengan reference counting, plus garbage collector untuk siklus referensi', true, 1),
  (10, 'B', E'Manual dengan new dan delete', false, 2),
  (10, 'C', E'Hanya dengan garbage collector', false, 3),
  (10, 'D', E'Dengan smart pointer', false, 4)
) as v(soal_urutan, label, teks, benar, urutan)
  on s.urutan = v.soal_urutan
where m.slug = 'pointer-dinamis';

-- =========================================================
-- VERIFIKASI AKHIR
-- =========================================================
do $$
declare
  v_kartu int;
  v_soal int;
  v_opsi int;
  v_anomali int;
begin
  select count(*) into v_kartu from public.flashcard;
  select count(*) into v_soal from public.soal;
  select count(*) into v_opsi from public.opsi_soal;

  if v_kartu != 100 then
    raise exception 'Jumlah flashcard tidak sesuai: diharapkan 100, ada %', v_kartu;
  end if;

  if v_soal != 100 then
    raise exception 'Jumlah soal tidak sesuai: diharapkan 100, ada %', v_soal;
  end if;

  if v_opsi != 400 then
    raise exception 'Jumlah opsi tidak sesuai: diharapkan 400, ada %', v_opsi;
  end if;

  -- Pastikan setiap soal punya tepat 1 jawaban benar
  select count(*) into v_anomali
  from (
    select soal_id, count(*) filter (where benar = true) as benar_cnt
    from public.opsi_soal
    group by soal_id
    having count(*) filter (where benar = true) != 1
  ) sub;

  if v_anomali > 0 then
    raise exception 'Ditemukan % soal yang tidak memiliki tepat 1 jawaban benar!', v_anomali;
  end if;

  raise notice 'VERIFIKASI BERHASIL: 100 kartu, 100 soal, 400 opsi.';
end $$;

commit;
