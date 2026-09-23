---
name: FlashStruct
description: Belajar struktur data (array, struct, pointer) dengan flashcard tiga tahap.
colors:
  primary: '#2460cf'
  on-primary: '#ffffff'
  link: '#245ab8'
  accent: '#2460cf'
  on-accent: '#ffffff'
  bg: '#ffffff'
  surface: '#ffffff'
  surface-raised: '#edf1f6'
  fg: '#111c32'
  fg-muted: '#52627b'
  success: '#23664f'
  danger: '#b12d3c'
  on-danger: '#ffffff'
  border: '#dde4ee'
  border-strong: '#7d8ca3'
  ring: '#2460cf'
  code-bg: '#f5f7fb'
  code-fg: '#22314b'
  code-keyword: '#60509c'
  code-type: '#245bb1'
  code-func: '#236957'
  code-string: '#23664f'
  code-number: '#a33143'
  code-comment: '#596b80'
  topik-array: '#245bb1'
  topik-struct: '#62529c'
  topik-pointer: '#236957'
typography:
  display:
    fontFamily: "'Encode Sans', system-ui, sans-serif"
    fontSize: '37px'
    fontWeight: 700
    lineHeight: 1.24
    letterSpacing: '-0.025em'
  headline:
    fontFamily: "'Encode Sans', system-ui, sans-serif"
    fontSize: '30px'
    fontWeight: 700
    lineHeight: 1.2
  title:
    fontFamily: "'Encode Sans', system-ui, sans-serif"
    fontSize: '24px'
    fontWeight: 600
    lineHeight: 1.25
  body:
    fontFamily: "'Encode Sans', system-ui, -apple-system, sans-serif"
    fontSize: '1rem'
    fontWeight: 400
    lineHeight: 1.6
  label:
    fontFamily: "'Encode Sans', system-ui, -apple-system, sans-serif"
    fontSize: '14px'
    fontWeight: 600
    lineHeight: 1.5
  mono:
    fontFamily: "'JetBrains Mono', 'Fira Code', ui-monospace, monospace"
    fontSize: '0.9em'
    fontWeight: 400
    lineHeight: 1.6
rounded:
  sm: '5px'
  md: '7px'
  lg: '10px'
  xl: '14px'
  full: '9999px'
spacing:
  sm: '0.5rem'
  md: '1rem'
  lg: '1.5rem'
  xl: '2rem'
  2xl: '3rem'
  3xl: '4rem'
components:
  button-primary:
    backgroundColor: '{colors.primary}'
    textColor: '{colors.on-primary}'
    rounded: '{rounded.md}'
    padding: '0 16px'
    height: '40px'
  button-primary-hover:
    backgroundColor: '{colors.primary}'
    textColor: '{colors.on-primary}'
    rounded: '{rounded.md}'
    padding: '0 16px'
    height: '40px'
  button-secondary:
    backgroundColor: 'transparent'
    textColor: '{colors.fg}'
    rounded: '{rounded.md}'
    padding: '0 16px'
    height: '40px'
  button-ghost:
    backgroundColor: 'transparent'
    textColor: '{colors.fg-muted}'
    rounded: '{rounded.md}'
    padding: '0 16px'
    height: '40px'
  button-accent:
    backgroundColor: '{colors.accent}'
    textColor: '{colors.on-accent}'
    rounded: '{rounded.md}'
    padding: '0 16px'
    height: '40px'
  button-danger:
    backgroundColor: '{colors.danger}'
    textColor: '{colors.on-danger}'
    rounded: '{rounded.md}'
    padding: '0 16px'
    height: '40px'
  action-link:
    backgroundColor: '{colors.primary}'
    textColor: '{colors.on-primary}'
    rounded: '{rounded.md}'
    padding: '12px 28px'
    height: '52px'
  card:
    backgroundColor: '{colors.surface}'
    textColor: '{colors.fg}'
    rounded: '{rounded.md}'
    padding: '23px 23px 28px'
  badge:
    backgroundColor: 'transparent'
    textColor: '{colors.topik-array}'
    rounded: '{rounded.sm}'
    padding: '2px 10px'
  chip-stage-number:
    backgroundColor: '{colors.surface-raised}'
    textColor: '{colors.fg}'
    rounded: '{rounded.md}'
    size: '32px'
---

# Design System: FlashStruct

## Overview

**Creative North Star: "Ruang Belajar yang Tenang"**

FlashStruct adalah aplikasi belajar struktur data dengan tiga tahap berurutan
(Pahami, Hafalkan, Buktikan). Bahasa visualnya tertahan: latar putih, teks
navy gelap, biru hanya untuk aksi dan penanda aktif, border tipis satu piksel,
radius sedang. Tidak ada dekorasi yang bersaing dengan materi — kartu,
tabel, dan blok kode tampil datar di atas permukaan putih.

Kepadatan sedang dan membaca duluan: lebar baca dibatasi 720px
(`container-narrow`), halaman aplikasi 1280px (`container-base`), dan
permukaan dasbor sampai 1600px (`container-wide`). Target sentuh minimum
44px di mobile, lebih rapat di desktop karena mouse lebih presisi.

**Keputusan yang disengaja:** ikon gembok tahap terkunci tampil inline di
sebelah label ("Hafalkan [gembok]"), bukan sebagai pil terpisah seperti di
comp. Ini dipertahankan karena lebih jelas — status terkunci terbaca tepat
di nama tahapnya. Lihat `src/components/ui/LearningStages.tsx`.

**Key Characteristics:**

- Latar putih, teks navy gelap, biru tertahan untuk aksi.
- Border tipis satu piksel sebagai pemisah utama, bukan bayangan.
- Sudut tegas (5–7px) pada kartu, label topik, dan nomor tahap; pil hanya pada trek progres.
- Satu keluarga font untuk UI dan heading (Encode Sans), mono untuk kode.
- Datar secara default; bayangan hanya untuk dialog/lapisan mengambang.

## Colors

Palet bicara seperlunya: satu biru aksi di atas netral putih/navy, dengan
warna topik dan semantik sebagai aksen.

### Primary

- **Biru Aksi Tertahan** ({colors.primary}): satu-satunya warna ajakan.
  Dipakai tombol primary/accent, tautan aktif, nomor tahap yang tersedia,
  dan latar seleksi teks. Kelangkaannya adalah pesannya — tidak dipakai
  untuk dekorasi.
- **Tinta Tautan** ({colors.link}): warna tautan dan label kategori
  (mis. label panel rekomendasi). Sedikit lebih gelap dari primary agar
  tetap terbaca di atas putih.

### Secondary

- **Topik Array** ({colors.topik-array}): penanda materi bertopik array.
- **Topik Struct** ({colors.topik-struct}): penanda materi bertopik struct.
- **Topik Pointer** ({colors.topik-pointer}): penanda materi bertopik
  pointer; dipakai juga untuk callout perhatian.

### Tertiary

- **Hijau Berhasil** ({colors.success}): status selesai, ikon centang
  tahap, callout tips.
- **Merah Bahaya** ({colors.danger}): aksi destruktif (reset progres) dan
  callout bahaya.
- **Kode** ({colors.code-keyword}, {colors.code-type},
  {colors.code-func}, {colors.code-string}, {colors.code-number},
  {colors.code-comment}): pewarnaan sintaks di atas {colors.code-bg}
  dengan teks {colors.code-fg}. Setiap tema (terang/gelap) punya ramp
  sendiri di `src/styles/tokens.css`.

### Neutral

- **Kertas Putih** ({colors.bg}): latar aplikasi tema terang.
- **Permukaan** ({colors.surface}): latar kartu dan header; sama dengan
  latar di tema terang, terangkat di tema gelap.
- **Permukaan Terangkat** ({colors.surface-raised}): latar trek progres,
  nomor tahap netral, header blok kode, kode inline.
- **Tinta Navy** ({colors.fg}): teks utama, navy sangat gelap.
- **Tinta Sekunder** ({colors.fg-muted}): teks pendukung, label, deskripsi.
- **Garis Tipis** ({colors.border}): border kartu, baris modul, pemisah.
- **Garis Tegas** ({colors.border-strong}): border tombol secondary dan
  kutipan; satu-satunya border yang menuntut perhatian.
- **Cincin Fokus** ({colors.ring}): outline fokus keyboard 2px yang selalu
  terlihat.

**Tema gelap** (`[data-theme='gelap']` di `src/styles/tokens.css`) memetakan
ulang token yang sama: latar menjadi navy malam ({colors.bg} → `#111925`),
tinta menjadi terang (`#edf2fa`), dan biru aksi menjadi biru es (`#a3c5ff`)
agar kontras tetap lolos. Pilihan pengguna (terang/gelap/sistem) tersimpan
di localStorage; tanpa akun.

### Named Rules

- **The One Voice Rule.** Biru aksi muncul pada ≤10% layar mana pun.
  Kalau semuanya biru, tidak ada yang penting.
- **The Border-Not-Shadow Rule.** Pemisahan memakai border 1px
  ({colors.border}); bayangan bukan alat pemisah.

## Typography

**Display Font:** Encode Sans (dengan system-ui, sans-serif)
**Body Font:** Encode Sans (dengan system-ui, -apple-system, sans-serif)
**Label/Mono Font:** JetBrains Mono (dengan Fira Code, ui-monospace, monospace)

**Character:** Satu keluarga humanis untuk semuanya — display 700 yang
tegas, body 400 yang lega. Encode Sans di-self-host di `public/fonts/`
(400/500/600/700) dan di-preload di `index.html`. Kode memakai mono
dengan ligatur kontekstual dan angka tabular.

### Hierarchy

- **Display** (700, 37px desktop / 29px mobile, 1.24): judul halaman
  dasbor (`dashboard-page h1`).
- **Headline** (700, 30px desktop / 25px mobile, 1.2): judul panel
  rekomendasi (`.recommendation h2`).
- **Title** (600, 24px h2 / 20px h3 modul, 1.25): heading konten modul
  (`MarkdownRenderer`: h2 `text-2xl`, h3 `text-xl`).
- **Body** (400, 1rem, 1.6): teks isi; angka memakai tabular-nums.
- **Label** (600, 14px): label panel, kepala progres, nama tahap;
  deskripsi tahap 13px regular.
- **Mono** (400, 0.9em): kode inline dan blok kode (blok 14px).

### Named Rules

- **The Balance Rule.** Judul display memakai `text-wrap: balance` dan
  letter-spacing −0.025em — tidak pernah gradient text.
- **The Tabular Numbers Rule.** Angka progres dan statistik memakai
  `tabular-nums` agar tidak bergeser saat berubah.

## Layout

Model spasial: tiga kontainer terpusat — baca (720px), aplikasi (1280px),
lebar (1600px dengan padding fluid `clamp(20px, 3.35vw, 54px)`). Dasbor
menumpuk vertikal: judul → panel rekomendasi (grid 2 kolom: copy + tahap)
→ ringkasan 3 kolom → daftar modul → detail 2 kolom. Panel rekomendasi
menambatkan tombol ke dasar (`margin-top: auto`) agar posisinya stabil
untuk deskripsi sepanjang apa pun.

Responsif: di ≤1100px padding dan kolom menyempit; di ≤767px semuanya
menjadi satu kolom — ringkasan menjadi baris label-kiri/angka-kanan,
modul menjadi kartu wrap, footer kerangka aplikasi disembunyikan karena bottom nav sudah
mengambil alih. Header aplikasi 62px (64px mobile) dengan tautan nav 40px;
footer kerangka aplikasi hanya desktop. Landing pada `/` memakai header dan footer
publik sendiri tanpa bottom nav; halaman belajar dimulai di `/dashboard`.
Header publik tetap terlihat saat menggulir, menyediakan jangkar Cara belajar dan
Kurikulum serta tautan Buka aplikasi. Hero memakai dua kolom (janji belajar dan
demo kode) hingga 680px, lalu menumpuk; bagian berikutnya memakai baris terbuka
untuk tiga tahap dan kurikulum. Area materi dan kuis tetap berada dalam kerangka
aplikasi.
Safe-area notch dihormati (`viewport-fit=cover`); konten
mobile diberi ruang gesture bar.

Ritme spacing mengikuti skala `--space-*` (0.25 / 0.5 / 0.75 / 1 / 1.5 /
2 / 3 / 4rem).

### Komposisi Halaman

- **Landing:** halaman publik di `/` membuka dengan tantangan menjelaskan hasil kode,
  demo C++ Array dengan pilihan 30/40/50, lalu urutan Pahami → Hafalkan → Buktikan,
  daftar topik, CTA penutup, dan footer publik. Setelah satu jawaban dipilih, sel indeks
  3 disorot dan penjelasan hasil 40 muncul. Satu timeline GSAP menggerakkan sel dan
  umpan balik; saat `prefers-reduced-motion: reduce`, keduanya langsung tampil tanpa
  animasi. CTA utama menuju `/materi/array-dasar` bila belum ada progres, atau
  `/dashboard` bila progres modul sudah ada. Baris topik memakai judul modul pertama
  dan hitungan modul dari `useDaftarModul`; judul fallback berasal dari modul pembuka
  yang tercatat di kurikulum. Hitungan tidak ditampilkan sebelum data tersedia.
- **Dashboard:** rekomendasi berikutnya tetap memimpin, diikuti ringkasan dan daftar modul.
- **Materi:** kurikulum dikelompokkan per topik dengan baris modul, informasi durasi,
  status tiga tahap, serta aksi berikutnya yang terlihat pada setiap baris.
- **Pembaca modul:** daftar isi tetap di sisi kiri pada desktop dan tersedia sebagai drawer
  pada mobile; lebar konten utama dibatasi agar paragraf, tabel, dan kode nyaman dibaca.
- **Video:** jika belum ada video pembelajaran yang sah, halaman menjelaskan jalur belajar
  lewat Materi. Video bersifat pendukung dan tidak memblokir progres.
- **Soal:** daftar dikelompokkan per topik. Setiap modul menunjukkan Hafalkan dan Buktikan
  dalam satu baris dengan alasan penguncian dan tautan untuk membaca modul.
- **Flashcard dan Quiz:** sesi aktif menggunakan ruang fokus yang lebih sempit. Keadaan
  terkunci memakai tata letak dua kolom: alasan dan aksi di kiri, urutan tiga tahap di kanan.
  Di mobile kolom tahap berpindah ke bawah. Aksi utama menuju tahap yang sudah tersedia;
  tautan kembali ke daftar soal tetap terlihat.

Semua komposisi mengikuti sudut tegas, pemisah tipis, dan target sentuh mobile 44px.

## Elevation & Depth

Sistem ini datar secara default. Kedalaman disampaikan lewat tonal layering
(putih → `--surface-raised`) dan border 1px, bukan bayangan. Dua bayangan
ada di token tetapi cadangannya sempit.

### Shadow Vocabulary

- **Bayangan Lembut** (`box-shadow: 0 2px 5px rgb(17 28 50 / 4%)`):
  pengangkatan minimal saat hover (mis. baris modul).
- **Bayangan Dialog** (`box-shadow: 0 12px 32px rgb(17 28 50 / 12%)`):
  lapisan mengambang (dialog, toast). Di tema gelap memakai hitam
  (12% / 28%).

### Named Rules

- **The Flat-By-Default Rule.** Permukaan datar saat diam; bayangan hanya
  sebagai respons state (hover, dialog, fokus) — tidak pernah sebagai
  dekorasi permanen atau offset keras.

## Shapes

Bahasanya: sudut tegas dan konsisten. Skala radius 5px (label topik,
fokus, tombol salin) → 7px (tombol, kartu, baris modul, blok kode,
nomor tahap) → penuh hanya untuk trek progres. Token 10px dan 14px tetap
tersedia bagi lapisan khusus seperti dialog. Border selalu 1px (`--border`), 1.5–2px hanya
untuk ikon status dan kutipan. Tidak ada aksen border kiri/kanan pada kartu,
tidak ada kliping dekoratif, tidak ada nomor section dekoratif.

## Components

### Buttons

Lima varian (`primary | secondary | ghost | accent | danger`), tiga ukuran
(sm/md/lg). Bentuk lembut sedang (7px), teks medium, transisi 150ms pada
filter/warna. Primary/accent/danger: isi solid + terang saat hover
(`brightness-110`) + redup saat aktif; secondary: transparan dengan border
tegas + isi permukaan saat hover; ghost: teks sekunder polos. Ukuran
menjamin target sentuh 44px di mobile (`h-11`/`h-12`), lebih rapat di
desktop (`md:h-9`/`md:h-10`). State memuat memakai spinner; nonaktif
meredup 50%.

### Action Link

Tombol-rasa-tautan untuk CTA dasbor: isi primary, teks putih 600 16px,
min-tinggi 52px (55px di panel rekomendasi, min-lebar 214px), padding
12px 28px, hover meredup (`brightness(0.92)`). Varian secondary:
permukaan putih dengan border tegas.

### Chips

Badge bersudut 5px, teks 12px semibold, tint 6% dari warnanya sendiri
dengan border 28% (`color-mix`) — 6% adalah nilai tertinggi yang tetap
lolos WCAG AA di semua kombinasi topik × permukaan × tema (terendah
4.54:1; 14% gagal di 4.07:1). Lihat `Card.tsx`.

### Cards / Containers

Sudut sedang (7px), latar permukaan, border tipis, padding 23px/bawah 28px
(panel rekomendasi). Baris modul: sudut sedang (7px), min-tinggi 84px,
hover mengangkat ke permukaan-raised dengan border tegas. Kutipan biasa:
border-kiri 2px tegas-meredup + italic sekunder. Tidak ada border
kiri/kanan berwarna pada kartu.

### Inputs / Fields

Tidak ada input teks kustom di sistem ini — satu-satunya field adalah
kotak pencarian dengan `scroll-margin-bottom: 100px` agar tidak tertutup
keyboard virtual. Caret memakai primary di seluruh aplikasi.

### Navigation

Header sticky dengan border bawah: brand 27px/700/−0.045em, tautan nav
600 dengan hover permukaan-raised, halaman aktif ditandai garis bawah
2px primary + warna (tidak pernah warna saja). Mobile memakai bottom nav
tetap (ikon + label 11px, garis atas untuk aktif); footer disembunyikan
di mobile untuk kerangka aplikasi. Pengalih tema memutar terang → gelap → sistem (ikon
Sun/Moon/Monitor).

Navigasi publik pada `/` berdiri sendiri: brand, jangkar Cara belajar/Kurikulum,
pengalih tema, dan tautan Buka aplikasi. Pada lebar ≤680px, jangkar header
disembunyikan; konten dan CTA tetap tersedia lewat halaman. Navigasi belajar,
termasuk bottom nav mobile, dimulai di `/dashboard`.

### Demo Landing (signature)

Wadah datar dengan border 1px dan radius 7px memuat kode C++, lima sel memori,
serta tiga tombol jawaban. Pilihan memakai `aria-pressed`; umpan balik memakai
`role=status` dan menjelaskan bahwa `*(p + 3)` membaca nilai 40 di indeks 3.
Sorotan biru memakai tint token primary, bukan warna baru. Gerak satu kali per
jawaban memakai skala sel 0.9 → 1 selama 350ms lalu penjelasan naik 12px dan
muncul selama 350ms, tumpang tindih 120ms. Reduced motion langsung menampilkan
keadaan akhir. Tombol Coba lagi mengembalikan pilihan ke keadaan awal.

### Sel Tahap (signature)

Tiga sel ber-border dalam grid (`Pahami / Hafalkan / Buktikan`): lingkaran
nomor 32px (28px ringkas, 25px mobile), nama 14px 600, deskripsi 13px
sekunder. Status: tersedia = lingkaran primary; selesai = tint sukses
12% + centang; terkunci = nomor biasa + **ikon gembok inline di sebelah
label** (keputusan disengaja, berbeda dari comp) + teks "Selesaikan X
untuk membuka." Perubahan status bertransisi 180ms. Varian ringkas
menampilkan lingkaran + sr-only; indikator tiga tahap (Progress.tsx)
memakai ikon centang/gembok dengan label teks wajib.

### Gerbang Tahap (signature)

Flashcard dan Quiz berbagi `StageGate`: ikon gembok netral, judul dan alasan
prasyarat yang jelas, penjelasan singkat, aksi utama menuju tahap yang
tersedia, serta aksi sekunder kembali ke Soal. Ringkasan urutan
Pahami → Hafalkan → Buktikan terletak di kolom samping pada desktop dan
di bawah pada mobile. Pemisahnya garis 1px, tanpa permukaan peringatan
atau dekorasi yang membuat status terkunci terasa seperti kesalahan.

### Progres

Bar linier 8px pil-penuh di atas trek permukaan-raised dengan isian
primary + label "nilai / maks" tabular; ring SVG 96px dengan tutup bulat.
Setiap indikator wajib punya label untuk pembaca layar (`role=progressbar`
dan `aria-label`). Angka statistik: 32px/700 tabular dengan label sekunder.
Progres tersimpan di `localStorage` (`flashstruct:progres:v1`) dengan
export/import/reset; penguncian 3 tahap dipertahankan.

### Blok Kode (signature)

Wadah sudut sedang dengan border tipis: header label-bahasa + tombol
Salin di atas permukaan-raised, isi di atas latar kode dengan pewarnaan
Shiki per-tema (fallback: kode polos tetap terbaca bila Shiki gagal).
Dapat difokus keyboard (`tabIndex=0`, `role=region`) agar bisa digulir
horizontal tanpa mouse. Tombol salin mengapung bila tanpa header.

### Callout (signature)

Empat tipe lewat sintaks `> [!INFO|PERHATIAN|BAHAYA|TIPS]`: info (biru),
perhatian (pointer-hijau), bahaya (merah), tips (sukses). Latar tint
8–10%, border 32%, ikon Lucide 20px (bukan emoji), judul 14px semibold
berwarna. Maksimal dua callout per bagian modul.

### Konten Markdown

Heading modul dengan id tautan (`scroll-mt-20`), paragraf lega
(`my-4 leading-relaxed`), tautan biru bergaris bawah, kode inline di atas
permukaan-raised, tabel dengan header permukaan-raised yang dapat
difokus keyboard, pemisah `my-8`. Struktur nyata: 10 modul, 206 kartu,
183 soal (comp hanya mencontohkan 4 modul).

## Do's and Don'ts

### Do:

- **Do** pakai biru primary hanya untuk aksi dan status aktif; biarkan
  netral yang bicara.
- **Do** pisahkan permukaan dengan border 1px (`--border`); naikkan ke
  `--border-strong` hanya saat hover/fokus.
- **Do** beri setiap indikator progres label teks untuk pembaca layar.
- **Do** buat wilayah scroll (blok kode, tabel) dapat difokus keyboard
  (`tabIndex=0` + `role=region`).
- **Do** ganti flip kartu dengan pergantian langsung saat
  `prefers-reduced-motion` — jangan hanya mematikan animasi.
- **Do** tambatkan CTA panel ke dasar (`margin-top: auto`), bukan jarak
  tetap dari deskripsi.
- **Do** tandai nav aktif dengan garis + warna, bukan warna saja.

### Don't:

- **Don't** memakai gradient text untuk judul atau angka apa pun.
- **Don't** memakai border kiri/kanan berwarna pada kartu atau callout
  sebagai penanda (callout memakai tint latar penuh + border 32%).
- **Don't** memakai hard offset shadow / neubrutalisme.
- **Don't** memakai emoji sebagai ikon — pakai ikon Lucide inline SVG.
- **Don't** memakai font monospace kustom di luar JetBrains Mono untuk kode.
- **Don't** menambah kicker/eyebrow atau nomor section dekoratif.
- **Don't** mendokumentasikan palet lama cream/ungu/coklat sebagai identitas
  — token `--palet-*` hanya sisa kompatibilitas dan bukan bahasa visual
  (tetap ada di `tokens.css`, jangan dipakai untuk permukaan baru).
- **Don't** mematikan gerak global dengan kill `0.01ms` — hormati
  `prefers-reduced-motion` dengan pengganti yang tetap informatif.
- **Don't** menghilangkan outline fokus tanpa pengganti yang terlihat.
