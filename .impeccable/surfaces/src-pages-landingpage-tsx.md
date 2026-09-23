# Landing FlashStruct

Mode: Persuade. Rute `/` adalah halaman publik dengan header, footer, dan navigasi sendiri. Kerangka aplikasi dan navigasi belajar dimulai di `/dashboard`; header publik menyediakan jangkar Cara belajar/Kurikulum, pengalih tema, dan tautan Buka aplikasi.

Pengunjung utama ialah mahasiswa TI Indonesia yang sedang menghadapi Array, Struct, dan Pointer. Dalam satu layar ia harus memahami manfaat FlashStruct, melihat contoh nyata cara produk menjelaskan hasil kode, dan menemukan langkah untuk mulai belajar. Tidak ada testimoni, statistik pemakaian, atau janji hasil belajar tanpa bukti.

Komposisi terpasang: hero dua kolom berisi judul yang menantang kemampuan menjelaskan hasil kode dan demo C++ Array. Pengunjung memilih 30, 40, atau 50 untuk `*(p + 3)`; jawaban memunculkan sorotan indeks 3 dan penjelasan hasil 40. Setelah itu ada baris terbuka Pahami → Hafalkan → Buktikan, baris topik Array/Struct/Pointer, CTA penutup, dan footer. Pada ≤680px hero menumpuk dan jangkar header disembunyikan. Aksi utama menuju `/materi/array-dasar` bila belum ada progres modul, atau `/dashboard` bila sudah ada.

Judul fallback modul pembuka telah dicocokkan dengan kurikulum dan seed: Dasar Array & Indeks, Mendefinisikan Struct, Dasar Pointer & Alamat Memori. Baris topik memakai judul modul pertama dan hitungan modul dari `useDaftarModul`; hitungan baru terlihat saat data tersedia. Rencana kurikulum memuat 3 Array, 3 Struct, dan 4 Pointer, tetapi landing tidak mengunci angka tersebut sebagai klaim statis.

Satu timeline GSAP berjalan setelah jawaban dipilih: sel target membesar dari 0.9 ke 1 selama 350ms, lalu penjelasan muncul dari offset 12px selama 350ms dengan overlap 120ms. State akhir berasal dari React dan tetap terbaca tanpa animasi; `prefers-reduced-motion: reduce` langsung menampilkannya. Tombol Coba lagi mengulang demo.

Batas visual: warisi putih, navy, biru aksi, Encode Sans, bidang datar dan radius kecil dari DESIGN.md. Hindari grid kartu fitur seragam, klaim palsu, ikon dekoratif, dan elemen terlalu membulat.
