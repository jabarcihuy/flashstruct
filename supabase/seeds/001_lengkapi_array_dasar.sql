-- =========================================================
-- Melengkapi Modul 1 — array-dasar
-- Dari 8 kartu -> 20 kartu, 3 soal -> 18 soal
--
-- Semua contoh kode sudah DIKOMPILASI dan DIJALANKAN.
-- Platform: GCC 16.2.1, x86-64, sizeof(int)=4
-- =========================================================

-- ============ KARTU TAMBAHAN (12 kartu) ============
insert into public.flashcard (modul_id, depan, belakang, card_type, kode, bahasa_kode, urutan)
select m.id, v.depan, v.belakang, v.card_type::tipe_kartu, v.kode, v.bahasa::bahasa_kode, v.urutan
from public.modul m, (values

('Bagaimana cara mendeklarasikan array 5 bilangan bulat di C++?',
 E'int arr[5];\n\nDengan nilai awal:\nint arr[5] = {10, 20, 30, 40, 50};',
 'SINTAKS', 'int arr[5] = {10, 20, 30, 40, 50};', 'cpp', 9),

('Bagaimana cara membuat array 5 elemen di Python?',
 E'arr = [0] * 5\n\nDengan nilai langsung:\narr = [10, 20, 30, 40, 50]\n\nPython memakai LIST, bukan array seperti C++.',
 'SINTAKS', 'arr = [0] * 5', 'python', 10),

('Apa rumus alamat elemen ke-i pada array?',
 E'alamat(i) = alamat(0) + i x sizeof(Tipe)\n\nKarena itu pengaksesan array sangat cepat:\nalamatnya bisa dihitung langsung tanpa mencari.',
 'MEMORI', null, null, 11),

(E'int arr[5] = {10,20,30,40,50};\ncout << arr[2];\n\nApa outputnya?',
 E'Output: 30\n\narr[2] adalah elemen KETIGA karena indeks dimulai dari 0:\narr[0]=10, arr[1]=20, arr[2]=30',
 'TRACING', 'int arr[5] = {10,20,30,40,50};\ncout << arr[2];', 'cpp', 12),

(E'arr = [10, 20, 30, 40, 50]\nprint(arr[2])\n\nApa outputnya?',
 E'Output: 30\n\nSama seperti C++, indeks Python dimulai dari 0.\narr[0]=10, arr[1]=20, arr[2]=30',
 'TRACING', 'arr = [10, 20, 30, 40, 50]\nprint(arr[2])', 'python', 13),

(E'int arr[5] = {10,20,30,40,50};\nint* p = arr;\ncout << *(p + 3);\n\nApa outputnya?',
 E'Output: 40\n\np menunjuk ke arr[0].\np + 3 menunjuk ke arr[3] (menambah 3 x sizeof(int) byte).\n*(p + 3) = arr[3] = 40',
 'TRACING', 'int arr[5] = {10,20,30,40,50};\nint* p = arr;\ncout << *(p + 3);', 'cpp', 14),

('Apa yang salah dari kode ini?\nint arr[5];\narr[5] = 100;',
 E'Indeks 5 berada DI LUAR BATAS.\n\nArray berukuran 5 punya indeks 0 sampai 4.\nMenulis arr[5] adalah undefined behavior:\nmungkin tampak berhasil, tetapi merusak memori di sekitarnya.',
 'JEBAKAN', 'int arr[5];\narr[5] = 100;  // di luar batas!', 'cpp', 15),

('Apa yang terjadi jika mengakses indeks di luar batas di Python?',
 E'Python melempar IndexError dan program berhenti\ndengan pesan yang jelas.\n\nIni BERBEDA dari C++ yang tidak memeriksa batas\nsehingga menghasilkan undefined behavior.',
 'BANDING', null, null, 16),

('Apa perbedaan array C++ dan list Python?',
 E'Array C++ (int arr[5]):\n- ukuran tetap saat kompilasi\n- tipe elemen seragam\n- satu blok memori berurutan\n\nList Python ([0]*5):\n- ukuran bisa berubah\n- tipe elemen bebas\n- menyimpan referensi ke objek',
 'BANDING', null, null, 17),

('Kapan sebaiknya memakai std::array daripada array C biasa?',
 E'Pakai std::array bila:\n- ukuran tetap saat kompilasi\n- ingin punya .size() yang benar\n- ingin array tidak otomatis menjadi pointer saat dikirim ke fungsi\n\nArray C biasa masih tepat bila berinteraksi dengan API gaya C.',
 'KAPAN', null, null, 18),

('Berapa nilai arr[0] jika dideklarasikan int arr[5] = {1, 2};?',
 E'1\n\nElemen pertama diisi 1, elemen kedua 2.\nSisanya (arr[2], arr[3], arr[4]) otomatis diisi NOL\ndi C++.\n\nIni berbeda dari variabel lokal biasa yang tidak diinisialisasi\n(mengandung nilai sampah).',
 'TRACING', 'int arr[5] = {1, 2};\ncout << arr[0];', 'cpp', 19),

('Mengapa pengaksesan array sangat cepat?',
 E'Karena alamat elemen bisa DIHITUNG LANGSUNG:\nalamat(i) = alamat(0) + i x sizeof(Tipe)\n\nTidak perlu mencari atau menelusuri.\nKompleksitasnya O(1) - waktu konstan,\ntidak bergantung pada posisi elemen.',
 'MEMORI', null, null, 20)

) as v(depan, belakang, card_type, kode, bahasa, urutan)
where m.slug = 'array-dasar';

-- ============ SOAL TAMBAHAN (15 soal) ============
insert into public.soal (modul_id, pertanyaan, kode, bahasa_kode, tipe, card_type, penjelasan, urutan)
select m.id, v.pertanyaan, v.kode, v.bahasa::bahasa_kode, v.tipe::tipe_soal, v.card_type::tipe_kartu, v.penjelasan, v.urutan
from public.modul m, (values

('Dari indeks berapa array dimulai di C++ dan Python?',
 null, null, 'PG', 'ISTILAH',
 E'Jawaban: 0\n\nBaik C++ maupun Python memulai indeks dari 0.\nElemen pertama adalah arr[0], bukan arr[1].\n\nPengecoh 1 adalah kesalahan paling umum bagi pemula.',
 4),

(E'int arr[5] = {10, 20, 30, 40, 50};\ncout << arr[4];\n\nApa outputnya?',
 'int arr[5] = {10, 20, 30, 40, 50};\ncout << arr[4];',
 'cpp', 'TRACE', 'TRACING',
 E'Output: 50\n\narr[4] adalah elemen KELIMA (indeks terakhir) karena indeks mulai dari 0.\n\nPengecoh 40 = arr[3]. Pengecoh 10 = arr[0].',
 5),

(E'arr = [10, 20, 30, 40, 50]\nprint(arr[-1])\n\nApa outputnya?',
 'arr = [10, 20, 30, 40, 50]\nprint(arr[-1])',
 'python', 'TRACE', 'TRACING',
 E'Output: 50\n\nPython mendukung indeks NEGATIF:\narr[-1] = elemen terakhir\narr[-2] = kedua dari belakang\n\nFitur ini TIDAK ada di C++.',
 6),

('Bagaimana cara mendeklarasikan array 3 bilangan bulat dengan nilai awal di C++?',
 null, null, 'PG', 'SINTAKS',
 E'Jawaban: int arr[3] = {1, 2, 3};\n\nint arr(3) salah: itu sintaks untuk memanggil fungsi, bukan array.\nint arr{1,2,3} benar di C++ modern tapi tanpa ukuran eksplisit - kurang jelas.\narr = [1,2,3] adalah sintaks Python, bukan C++.',
 7),

(E'int arr[3];\narr[3] = 100;\n\nApa yang terjadi?',
 'int arr[3];\narr[3] = 100;',
 'cpp', 'ANALISIS', 'JEBAKAN',
 E'Undefined behavior.\n\nArray berukuran 3 punya indeks valid 0, 1, 2.\narr[3] berada DI LUAR BATAS.\n\nC++ TIDAK memeriksa batas indeks - program bisa:\n- tampak berjalan normal\n- mencetak nilai sampah\n- crash\n- merusak data lain tanpa terlihat\n\nIni bukan error yang bisa ditangkap, melainkan perilaku yang tidak didefinisikan standar.',
 8),

('Apa yang terjadi jika mengakses indeks di luar batas di Python?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Python melempar IndexError dan program berhenti dengan pesan jelas.\n\nIni perbedaan penting dari C++ yang menghasilkan undefined behavior (bisa tampak berhasil).\n\nPengecoh "mengembalikan 0" salah - Python tidak mengisi nilai default.\nPengecoh "mengembalikan None" juga salah - Python melempar exception.',
 9),

(E'int arr[5] = {1, 2};\ncout << arr[4];\n\nApa outputnya?',
 'int arr[5] = {1, 2};\ncout << arr[4];',
 'cpp', 'TRACE', 'MEMORI',
 E'Output: 0\n\nKetika array diinisialisasi dengan nilai lebih sedikit dari ukurannya, sisanya otomatis diisi NOL.\n\narr[0]=1, arr[1]=2, arr[2]=0, arr[3]=0, arr[4]=0.\n\nIni BERBEDA dari variabel lokal tanpa inisialisasi yang berisi nilai sampah.',
 10),

('Apa rumus menghitung alamat elemen ke-i pada array?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: alamat(0) + i x sizeof(Tipe)\n\nKarena elemen array tersimpan berurutan dengan jarak tetap (sebesar ukuran tipe), alamat elemen ke-i bisa dihitung langsung.\n\nInilah alasan pengaksesan array O(1) - waktu konstan.',
 11),

(E'int arr[5] = {10, 20, 30, 40, 50};\ncout << *(arr + 2);\n\nApa outputnya?',
 'int arr[5] = {10, 20, 30, 40, 50};\ncout << *(arr + 2);',
 'cpp', 'TRACE', 'TRACING',
 E'Output: 30\n\n*(arr + 2) sama dengan arr[2].\n\nNama array arr "meluruh" menjadi pointer ke elemen pertama.\narr + 2 menunjuk ke elemen ketiga (indeks 2).',
 12),

('Apa perbedaan utama array C++ dan list Python?',
 null, null, 'PG', 'BANDING',
 E'Jawaban: Array C++ berukuran tetap dan bertipe seragam; list Python bisa berubah ukuran dan tipe elemennya bebas.\n\nArray C++: satu blok memori berurutan, ukuran ditentukan saat kompilasi.\nList Python: menyimpan referensi ke objek, ukuran bisa bertambah/berkurang, tipe elemen bebas.\n\nKeduanya sama-sama memakai indeks mulai dari 0.',
 13),

(E'arr = [1, 2, 3]\narr.append(4)\nprint(len(arr))\n\nApa outputnya?',
 'arr = [1, 2, 3]\narr.append(4)\nprint(len(arr))',
 'python', 'TRACE', 'TRACING',
 E'Output: 4\n\nList Python bisa bertambah ukurannya.\nSetelah append(4), list berisi [1,2,3,4] dengan panjang 4.\n\nIni TIDAK mungkin pada array C++ yang ukurannya tetap.',
 14),

('Apa yang salah dari kode ini?',
 E'int arr[5];\nfor (int i = 0; i <= 5; i++) {\n    cout << arr[i];\n}',
 'cpp', 'ANALISIS', 'JEBAKAN',
 E'Kondisi loop memakai <= sehingga i mencapai 5.\nIndeks 5 di luar batas (valid hanya 0-4).\n\nAkibat: undefined behavior pada iterasi terakhir.\n\nPerbaikan: pakai i < 5, bukan i <= 5.\nIni kesalahan "off-by-one" yang sangat umum.',
 15),

('Kapan sebaiknya memakai std::array daripada array C biasa?',
 null, null, 'PG', 'KAPAN',
 E'Jawaban: Saat ukuran tetap saat kompilasi dan ingin punya .size() serta tidak otomatis menjadi pointer.\n\nstd::array keunggulannya:\n- .size() mengembalikan ukuran BENAR (array C biasa kehilangan ukuran saat jadi pointer)\n- bisa disalin dengan =\n- tidak "meluruh" menjadi pointer saat dikirim ke fungsi\n\nArray C biasa masih tepat untuk berinteraksi dengan API gaya C.',
 16),

(E'int arr[5] = {10, 20, 30, 40, 50};\nint* p = arr;\ncout << p[3];\n\nApa outputnya?',
 'int arr[5] = {10, 20, 30, 40, 50};\nint* p = arr;\ncout << p[3];',
 'cpp', 'TRACE', 'TRACING',
 E'Output: 40\n\np[3] sama dengan *(p + 3) sama dengan arr[3].\n\nPointer bisa diindeks seperti array.\np[3] = arr[3] = 40',
 17),

('Mengapa pengaksesan elemen array berkompleksitas O(1)?',
 null, null, 'PG', 'MEMORI',
 E'Jawaban: Karena alamat elemen bisa dihitung langsung tanpa mencari.\n\nRumus alamat(i) = alamat(0) + i x sizeof(Tipe) memungkinkan komputer melompat langsung ke elemen mana pun.\n\nTidak seperti linked list yang harus menelusuri satu per satu (O(n)).',
 18)

) as v(pertanyaan, kode, bahasa, tipe, card_type, penjelasan, urutan)
where m.slug = 'array-dasar';

-- ============ OPSI TAMBAHAN ============
insert into public.opsi_soal (soal_id, label, teks, benar, urutan)
select s.id, v.label, v.teks, v.benar, v.urutan
from public.soal s
join public.modul m on m.id = s.modul_id
join (values
  (4, 'A', '0', true, 1),
  (4, 'B', '1', false, 2),
  (4, 'C', 'Tergantung bahasa', false, 3),
  (4, 'D', 'Tergantung tipe data', false, 4),
  (5, 'A', '40', false, 1),
  (5, 'B', '50', true, 2),
  (5, 'C', '10', false, 3),
  (5, 'D', 'Error', false, 4),
  (6, 'A', '10', false, 1),
  (6, 'B', '50', true, 2),
  (6, 'C', 'IndexError', false, 3),
  (6, 'D', '40', false, 4),
  (7, 'A', 'int arr[3] = {1, 2, 3};', true, 1),
  (7, 'B', 'int arr(3);', false, 2),
  (7, 'C', 'arr = [1, 2, 3];', false, 3),
  (7, 'D', 'array arr[3];', false, 4),
  (8, 'A', 'Compiler menolak kode dan gagal build', false, 1),
  (8, 'B', 'Program otomatis berhenti dengan pesan error', false, 2),
  (8, 'C', 'Undefined behavior: bisa cetak nilai sampah, crash, atau tampak normal', true, 3),
  (8, 'D', 'Array otomatis diperbesar agar muat', false, 4),
  (9, 'A', 'Mengembalikan 0', false, 1),
  (9, 'B', 'Melempar IndexError dan program berhenti', true, 2),
  (9, 'C', 'Mengembalikan None', false, 3),
  (9, 'D', 'Memperbesar list otomatis', false, 4),
  (10, 'A', '0', true, 1),
  (10, 'B', 'Nilai sampah', false, 2),
  (10, 'C', 'Error kompilasi', false, 3),
  (10, 'D', '2', false, 4),
  (11, 'A', 'alamat(0) + i x sizeof(Tipe)', true, 1),
  (11, 'B', 'alamat(0) + i', false, 2),
  (11, 'C', 'alamat(0) + sizeof(Tipe)', false, 3),
  (11, 'D', 'alamat(i) = i x alamat(0)', false, 4),
  (12, 'A', '10', false, 1),
  (12, 'B', '20', false, 2),
  (12, 'C', '30', true, 3),
  (12, 'D', '40', false, 4),
  (13, 'A', 'Array C++ ukuran tetap dan tipe seragam; list Python ukuran bisa berubah dan tipe bebas', true, 1),
  (13, 'B', 'Array C++ dimulai dari indeks 1, list Python dari 0', false, 2),
  (13, 'C', 'Array C++ bisa menyimpan tipe campuran', false, 3),
  (13, 'D', 'List Python tidak bisa diindeks', false, 4),
  (14, 'A', '3', false, 1),
  (14, 'B', '4', true, 2),
  (14, 'C', '5', false, 3),
  (14, 'D', 'Error', false, 4),
  (15, 'A', 'Kondisi loop memakai <= sehingga indeks mencapai 5, di luar batas', true, 1),
  (15, 'B', 'Array tidak boleh diinisialisasi kosong', false, 2),
  (15, 'C', 'cout tidak bisa mencetak array', false, 3),
  (15, 'D', 'Variabel i harus bertipe long', false, 4),
  (16, 'A', 'Saat ukuran tetap saat kompilasi dan ingin punya .size() serta tidak otomatis jadi pointer', true, 1),
  (16, 'B', 'Saat ukuran berubah saat program berjalan', false, 2),
  (16, 'C', 'Saat butuh menyimpan tipe data berbeda', false, 3),
  (16, 'D', 'Saat butuh array dengan indeks mulai dari 1', false, 4),
  (17, 'A', '30', false, 1),
  (17, 'B', '40', true, 2),
  (17, 'C', '50', false, 3),
  (17, 'D', '10', false, 4),
  (18, 'A', 'Karena alamat elemen bisa dihitung langsung tanpa mencari', true, 1),
  (18, 'B', 'Karena array selalu kecil', false, 2),
  (18, 'C', 'Karena compiler mengoptimalkan semua array', false, 3),
  (18, 'D', 'Karena array disimpan di cache CPU', false, 4)
) as v(urutan_soal, label, teks, benar, urutan)
  on v.urutan_soal = s.urutan
where m.slug = 'array-dasar';
