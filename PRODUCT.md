# FlashStruct

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Mahasiswa TI Indonesia yang sudah mengenal dasar pemrograman dan sedang mempelajari Struktur Data. Laptop mendukung sesi belajar mendalam; ponsel mendukung pengulangan di sela kegiatan. Mobile dan desktop harus menyediakan kemampuan yang sama.

## Product Purpose

Membantu mahasiswa memahami, mengingat, dan membuktikan penguasaan Array, Struct, dan Pointer melalui alur **Pahami → Hafalkan → Buktikan**. Keberhasilan berarti pengguna mengetahui langkah belajar berikutnya, dapat membaca materi dengan nyaman, dan dapat meninjau bagian yang belum dikuasai.

## Positioning

Tiga tahap berurutan per modul menggabungkan materi, latihan mengingat secara mandiri, dan quiz dengan penjelasan. Tahap berikutnya terbuka setelah tahap sebelumnya selesai. Contoh C++ dan Python membantu memahami konsep dari dua bahasa.

## Operating Context

Materi tertulis menjadi awal pembelajaran; video merupakan pendukung opsional. Flashcard memakai penilaian diri Lupa/Ingat. Quiz menguji pemahaman dan memberi umpan balik. Dashboard menunjukkan progres dan rekomendasi langkah berikutnya.

## Capabilities and Constraints

- v1 tanpa akun; progres tersimpan lokal di browser. Menghapus data browser dapat menghapus progres; tidak ada sinkronisasi akun antarperangkat.
- Implementasi menyediakan ekspor/impor progres JSON dan pengaturan tema.
- v1 non-komersial; tidak mencakup panel admin, fitur sosial, sertifikat, atau AI tutor.
- Pertahankan isi pembelajaran, aturan penguncian, dan perilaku progres dalam redesign.
- Aturan belajar rinci tercatat di `docs/01-PRD.md`; implementasi penguncian berada di `src/features/progres/aturan.ts`.

## Brand Commitments

Nama FlashStruct, bahasa Indonesia, dan istilah Pahami, Hafalkan, Buktikan dipertahankan. Konten dan kode menggunakan teks serta ikon SVG, tanpa emoji, sesuai dokumentasi proyek. Pengguna mengizinkan penggantian visual dan layout seluruh UI, lalu memilih pola aplikasi belajar yang familier. Pengguna secara eksplisit meminta hasil yang tidak terasa generik atau seperti “AI slop”; keputusan visual harus mendukung tugas belajar dan konten sebenarnya.

## Evidence on Hand

PRD dan kurikulum: `docs/01-PRD.md`, `docs/02-KURIKULUM.md`. Implementasi halaman: `src/pages/`. Aset identitas yang ada: `public/favicon.svg`, `public/icons.svg`. Dokumentasi desain sebelumnya berada di `docs/03-DESIGN-SYSTEM.md`; bukan bukti bahwa hasil redesign sudah diterapkan. Status milestone README tertinggal dari keberadaan fitur di kode dan tidak menjadi bukti kesiapan rilis. Klaim hasil belajar, testimoni, dan angka pemakaian membutuhkan bukti sebelum ditambahkan.

## Product Principles

- Tampilkan langkah belajar berikutnya beserta alasan pengunciannya.
- Utamakan pemahaman dan pengulangan jujur dibanding kompetisi atau kecepatan.
- Pertahankan kenyamanan membaca dan kelengkapan fungsi pada ponsel maupun desktop.
- Jelaskan batas penyimpanan progres lokal dan sediakan kendali atas data pengguna.

## Accessibility & Inclusion

Persyaratan proyek mencakup navigasi keyboard, fokus yang terlihat, kontras teks yang memadai, dukungan reduced motion, dan zoom browser. Rujukan pemeriksaan: `docs/08-CHECKLIST-QA.md`. Ini persyaratan yang harus diverifikasi, bukan klaim kelulusan audit redesign.
