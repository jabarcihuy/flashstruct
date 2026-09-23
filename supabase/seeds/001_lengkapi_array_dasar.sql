-- =========================================================
-- Modul 1 — array-dasar
-- Tepat 10 kartu, 10 soal, 40 opsi
--
-- Semua contoh kode sudah DIKOMPILASI dan DIJALANKAN.
-- Platform: GCC 16.2.1, x86-64, sizeof(int)=4
-- =========================================================

-- Bersihkan kartu dan soal lama modul 1 jika ada
delete from public.flashcard where modul_id = (select id from public.modul where slug = 'array-dasar');
delete from public.soal where modul_id = (select id from public.modul where slug = 'array-dasar');

-- ============ FLASHCARD (10 kartu) ============
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

-- ============ SOAL QUIZ (10 soal) ============
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

-- ============ OPSI JAWABAN (40 opsi) ============
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
