# 03 — Design System

> Token visual, tipografi, dan spesifikasi komponen FlashStruct.
> Status: `[FINAL]` · Semua rasio kontras di dokumen ini **sudah dihitung dan diverifikasi** dengan rumus WCAG 2.1.

---

## 1. Arah Desain

### 1.1 Prinsip

FlashStruct adalah alat belajar untuk mahasiswa TI. Arah desainnya ditentukan oleh empat prinsip:

| Prinsip | Artinya dalam praktik |
|---------|----------------------|
| **Materi adalah bintangnya** | UI tidak boleh bersaing dengan kode. Warna aksen dipakai hemat, bukan untuk dekorasi |
| **Teknis, bukan kekanak-kanakan** | Target pengguna mahasiswa, bukan anak-anak. Tidak ada ilustrasi kartun, maskot, atau emoji sebagai ikon |
| **Padat tapi lapang** | Konten teknis butuh kepadatan informasi, tetapi dibungkus dengan ruang kosong yang cukup agar tidak melelahkan |
| **Hangat, bukan dingin** | Palet cream dan coklat memberi kehangatan yang nyaman untuk sesi belajar panjang. Ini bukan aplikasi korporat yang dingin dan steril |

### 1.2 Gaya yang Dipilih

**Basis:** Minimalism & Swiss Style, dengan sentuhan Bento Box Grid untuk halaman Dashboard, dan **palet warna hangat** sebagai identitas.

Alasan pemilihan:

- **Minimalism** memberi struktur grid yang jelas — penting untuk halaman yang banyak berisi kode dan tabel.
- **Bento Grid** cocok untuk Dashboard karena memungkinkan kartu statistik dengan ukuran berbeda (1×1, 2×1) tanpa terlihat berantakan.
- **Palet hangat** (cream, biru pastel, ungu pastel, coklat) membedakan FlashStruct dari aplikasi edukasi lain yang umumnya memakai biru-putih korporat. Nuansa hangat menurunkan ketegangan saat belajar materi sulit seperti pointer.
- Semuanya berbiaya performa rendah (tanpa blur, tanpa gradien berat), sesuai target FCP < 1.8s.

### 1.3 Gaya yang **Ditolak** dan Alasannya

Ini dicatat supaya tidak ada yang menambahkannya kembali tanpa berpikir:

| Gaya | Alasan ditolak |
|------|----------------|
| **Claymorphism** | Direkomendasikan sistem untuk kategori "educational app", tetapi gaya ini dirancang untuk aplikasi anak-anak. Terlalu *playful* untuk mahasiswa TI |
| **Cyberpunk / Neon** | Mengganggu konsentrasi membaca kode, kontras neon menyiksa mata untuk sesi panjang. Juga bertentangan dengan palet hangat yang dipilih |
| **Glassmorphism** | Membutuhkan `backdrop-filter: blur()` yang mahal secara performa, dan kontrasnya sulit dijamin |
| **Neumorphism** | Kontras sangat rendah — gagal standar aksesibilitas untuk teks |
| **Dark mode murni (OLED `#000000`)** | Kontras ekstrem hitam-putih menyebabkan *halation* (bayangan teks) saat membaca lama. Mode gelap di sini memakai coklat sangat gelap, bukan hitam |
| **Biru-putih korporat** | Terlalu generik dan dingin. Palet yang dipilih sudah membedakan FlashStruct dari aplikasi serupa |

### 1.4 Mode

**Terang dan gelap sama-sama didukung penuh.** Mengikuti preferensi sistem secara default, dapat diubah manual, dan pilihan disimpan.

Alasan: mahasiswa sering belajar malam hari. Memaksa mode terang akan membuat mereka menghindari aplikasi.

**Catatan penting tentang palet ini di mode gelap:** keempat warna palet adalah pastel dengan kontras rendah terhadap latar terang — itulah kelemahannya di mode terang. Tetapi di mode gelap, sifat pastel itu justru menjadi kelebihan: warna-warna ini berkilau dan sangat terbaca di atas latar coklat gelap.

**Konsekuensinya:**

| Mode | Palet asli dipakai sebagai | Teks memakai |
|------|---------------------------|--------------|
| **Terang** | Latar (cream) dan badge pastel | Varian turunan yang digelapkan |
| **Gelap** | Warna aksen dan teks langsung | Palet asli, atau cream |

**Catatan:** gelap bukan versi "terang yang dibalik". Kedua mode punya token sendiri yang sudah diverifikasi kontrasnya.

---

## 2. Token Warna

### 2.1 Cara Menggunakan Token

Tiga lapis token, dari primitif ke semantik. **Komponen hanya boleh memakai token semantik**, tidak pernah nilai heksadesimal mentah.

```
Primitif (palet mentah)  →  Semantik (peran)  →  Komponen (pemakaian)
      ungu #A290B7               --primary           --button-bg
```

Alasan: jika nanti warna brand berubah, cukup ubah lapis semantik. Tidak perlu menyisir seluruh komponen.

### 2.2 Palet Sumber

Palet proyek terdiri dari empat warna. Ini adalah **sumber warna** — semua token lain diturunkan darinya.

| Nama | Heksadesimal | Karakter | Peran dalam palet |
|------|--------------|----------|-------------------|
| **Cream** | `#FDF4D2` | Hangat, terang | Latar utama mode terang; teks utama mode gelap |
| **Biru** | `#B0CDE6` | Sejuk, tenang | Identitas topik **Array** |
| **Ungu** | `#A290B7` | Netral, intelektual | Identitas topik **Struct**; warna aksi utama |
| **Coklat** | `#946D6D` | Hangat, membumi | Identitas topik **Pointer**; warna aksen |

**Mengapa pembagian ini masuk akal:** tiga warna non-cream persis berjumlah tiga topik. Ini kebetulan yang menguntungkan — setiap topik mendapat identitas warna yang khas tanpa perlu mengarang warna tambahan.

**Catatan penting tentang palet ini:** keempat warna adalah **pastel**, artinya semuanya punya kontras rendah terhadap latar terang. Hasil pengukuran:

| Warna | Kontras di atas cream | Bisa jadi teks? |
|-------|----------------------|-----------------|
| Cream `#FDF4D2` | 1.00 | Tidak — ini latarnya |
| Biru `#B0CDE6` | 1.50 | Tidak — 1.50 jauh dari 4.5 |
| Ungu `#A290B7` | 2.64 | Tidak — 2.64 jauh dari 4.5 |
| Coklat `#946D6D` | 4.08 | Tidak — 4.08 hanya cukup untuk teks besar |

**Konsekuensi desain:** palet ini **tidak boleh dipakai langsung sebagai warna teks**. Semua teks harus memakai varian yang digelapkan (mode terang) atau diterangkan (mode gelap). Palet asli tetap dipakai untuk:

- Latar halaman (cream)
- Latar kartu, badge, dan callout (biru, ungu, coklat pastel)
- Isian elemen grafis: batang progres, titik status, garis aksen
- Warna identitas topik pada elemen non-teks

**Cara menurunkan varian:** dengan menggeser *lightness* pada ruang warna HLS sambil mempertahankan *hue* dan *saturation*. Ini menjaga karakter warna tetap sama, hanya tingkat keterangannya yang berubah.

### 2.3 Warna Topik

Setiap topik punya warna identitas agar mahasiswa bisa mengenali konteksnya sekilas.

| Topik | Warna Sumber | Mode Terang (teks) | Mode Gelap (teks) |
|-------|--------------|-------------------|-------------------|
| **Array** | Biru `#B0CDE6` | `#1A5A92` | `#B0CDE6` |
| **Struct** | Ungu `#A290B7` | `#593781` | `#A290B7` |
| **Pointer** | Coklat `#946D6D` | `#6C4343` | `#BF9E9E` |

**Verifikasi kontras:**

| Pasangan | Rasio | Status |
|----------|-------|--------|
| Array `#1A5A92` di atas cream `#FDF4D2` | **6.52** | AA |
| Struct `#593781` di atas cream `#FDF4D2` | **8.32** | AAA |
| Pointer `#6C4343` di atas cream `#FDF4D2` | **7.55** | AAA |
| Array `#B0CDE6` di atas `#1D1818` | **10.64** | AAA |
| Struct `#A290B7` di atas `#1D1818` | **6.03** | AA |
| Pointer `#BF9E9E` di atas `#1D1818` | **7.19** | AAA |

> **Catatan `--topik-pointer` mode gelap:** warna asli `#946D6D` hanya mencapai rasio **3.90** di atas latar gelap — gagal untuk teks kecil. Karena itu diterangkan menjadi `#BF9E9E` (rasio 7.19). Ini contoh nyata bahwa warna yang sama sering butuh dua varian berbeda untuk dua mode.

### 2.4 Palet Pastel untuk Latar

Warna asli palet dipakai sebagai **latar** elemen, dengan teks gelap di atasnya.

| Token | Nilai | Dipakai untuk | Teks di atasnya | Kontras |
|-------|-------|---------------|-----------------|---------|
| `--pastel-cream` | `#FDF4D2` | Latar halaman, kartu sorotan | `#181212` | **16.80** AAA |
| `--pastel-biru` | `#B0CDE6` | Badge topik Array, callout info | `#181212` | **11.22** AAA |
| `--pastel-ungu` | `#A290B7` | Badge topik Struct, callout tips | `#181212` | **6.36** AA |
| `--pastel-coklat` | `#946D6D` | Badge topik Pointer, callout peringatan | `#FDF4D2` | **4.08** AA-Large |

> **Catatan `--pastel-coklat`:** ini satu-satunya pastel yang lebih baik memakai teks cream daripada teks gelap (4.08 vs 3.15). Karena rasionya hanya 4.08, pastikan teks di atasnya **berukuran minimal 18px tebal atau 24px biasa** agar memenuhi syarat teks besar. Untuk teks kecil, pakai versi gelap `#6C4343` dengan latar cream.

### 2.5 Token Semantik — Mode Terang

Latar memakai **cream** dari palet, bukan putih. Alasan: cream memberi kehangatan yang sesuai untuk sesi belajar panjang, dan tidak menyilaukan seperti putih murni di ruangan gelap.

| Token | Nilai | Peran | Kontras vs latar | Status |
|-------|-------|-------|------------------|--------|
| `--bg` | `#FDF4D2` | Latar halaman (cream) | — | — |
| `--surface` | `#FFFFFF` | Latar kartu/panel | — | — |
| `--surface-raised` | `#FAF3E0` | Panel di atas surface | — | — |
| `--fg` | `#181212` | Teks utama | **16.80** | AAA |
| `--fg-muted` | `#463737` | Teks sekunder | **10.23** | AAA |
| `--primary` | `#593781` | Aksi utama | **8.32** | AAA |
| `--on-primary` | `#FFFFFF` | Teks di atas primary | **9.18** | AAA |
| `--accent` | `#6C4343` | Aksen/CTA | **7.55** | AAA |
| `--on-accent` | `#FFFFFF` | Teks di atas accent | **8.33** | AAA |
| `--success` | `#30665D` | Jawaban benar | **5.98** | AA |
| `--danger` | `#A33A3A` | Jawaban salah, hapus | **5.91** | AA |
| `--border` | `#E3D5AE` | Garis pemisah | 1.13 | Non-teks |
| `--border-strong` | `#675353` | Batas kontrol input | **6.48** | Lolos 3:1 |
| `--ring` | `#593781` | Cincin fokus | **8.32** | AAA |

> **Catatan `--fg` dan `--fg-muted`:** keduanya bukan hitam atau abu-abu netral, melainkan **coklat sangat gelap** (`#181212` dan `#463737`). Ini menjaga kehangatan palet tetap konsisten — teks abu-abu netral akan terasa asing di atas latar cream.

> **Catatan `--success` dan `--danger`:** palet tidak menyediakan warna hijau atau merah. Karena itu keduanya diturunkan agar selaras: hijau `#30665D` adalah **teal** yang dekat dengan biru palet, dan merah `#A33A3A` adalah **maroon** yang dekat dengan coklat palet. Pendekatan ini menjaga harmoni tanpa mengorbankan kejelasan makna benar/salah.

> **Catatan `--border-strong`:** rasio 6.48 jauh melebihi syarat 3:1 untuk batas kontrol UI. Ini perbaikan dari desain sebelumnya yang hanya mencapai 2.94.

### 2.6 Token Semantik — Mode Gelap

Latar memakai **coklat yang digelapkan sangat dalam** (`#1D1818`), bukan hitam murni. Alasan: hitam murni dengan teks cream menyebabkan *halation* yang melelahkan mata, dan warna coklat gelap menjaga kehangatan palet tetap terasa.

**Di mode gelap, pastel justru berkilau.** Warna yang gagal sebagai teks di latar terang menjadi sangat terbaca di latar gelap — inilah keuntungan palet pastel.

| Token | Nilai | Peran | Kontras vs latar | Status |
|-------|-------|-------|------------------|--------|
| `--bg` | `#1D1818` | Latar halaman | — | — |
| `--surface` | `#302929` | Latar kartu/panel | — | — |
| `--surface-raised` | `#433939` | Panel di atas surface | — | — |
| `--fg` | `#FDF4D2` | Teks utama (cream) | **15.92** | AAA |
| `--fg-muted` | `#E2CD7C` | Teks sekunder | **11.08** | AAA |
| `--primary` | `#A290B7` | Aksi utama (ungu) | **6.03** | AA |
| `--on-primary` | `#1D1818` | Teks di atas primary | **6.03** | AA |
| `--accent` | `#B0CDE6` | Aksen/CTA (biru) | **10.64** | AAA |
| `--on-accent` | `#1D1818` | Teks di atas accent | **10.64** | AAA |
| `--success` | `#7FD1C0` | Jawaban benar | **9.85** | AAA |
| `--danger` | `#E8A0A0` | Jawaban salah, hapus | **8.33** | AAA |
| `--border` | `#554646` | Garis pemisah | 1.97 | Non-teks |
| `--border-strong` | `#8A7575` | Batas kontrol input | **4.10** | Lolos 3:1 |
| `--ring` | `#A290B7` | Cincin fokus | **6.03** | AA |

> **Catatan pertukaran primary dan accent:** di mode terang, primary adalah ungu dan accent adalah coklat. Di mode gelap, primary tetap ungu tetapi **accent berubah menjadi biru**, bukan coklat. Alasannya: coklat `#946D6D` hanya mencapai 3.90 di latar gelap, dan menerangkannya sampai lolos akan membuatnya kehilangan karakter coklatnya. Biru `#B0CDE6` mencapai 10.64 dan justru lebih menonjol.

> **Catatan `--on-primary` dan `--on-accent`:** di mode gelap keduanya **gelap** (`#1D1818`), kebalikan dari mode terang. Ini disengaja — teks putih di atas ungu pastel `#A290B7` hanya menghasilkan rasio 3.45, yang gagal untuk teks kecil. Memakai teks gelap memberi rasio 6.03.

### 2.7 Warna Sintaks Kode

Blok kode butuh warna sendiri. Dipilih agar terbaca di kedua mode **dan tetap selaras dengan palet**.

| Elemen | Terang | Gelap | Rasio (terang) | Rasio (gelap) |
|--------|--------|-------|----------------|---------------|
| Latar kode | `#FFFFFF` | `#322121` | — | — |
| Teks biasa | `#493333` | `#FDF4D2` | **10.55** | **13.85** |
| Kata kunci (`int`, `struct`) | `#6A5582` | `#A290B7` | **5.89** | **5.24** |
| Tipe (`int`, `char`) | `#336EA1` | `#B0CDE6` | **4.90** | **9.25** |
| Fungsi | `#543D3D` | `#B49494` | **9.02** | **5.53** |
| String | `#305A4F` | `#BCD7D0` | **7.05** | **10.01** |
| Angka | `#822929` | `#EBC9C9` | **8.29** | **9.98** |
| Komentar | `#6E5C5C` | `#B0A0A0` | **6.20** | **5.72** |

> **Catatan:** warna sintaks diturunkan dari palet agar blok kode terasa bagian dari desain, bukan tempelan. Kata kunci memakai ungu, tipe memakai biru, fungsi memakai coklat, string memakai turunan hijau-teal, angka memakai turunan merah-maroon.

> **Catatan komentar:** warna komentar sengaja lebih redup karena tidak wajib dibaca, tetapi tetap lolos AA di kedua mode (6.20 dan 5.72). Ini perbaikan dari desain sebelumnya yang hanya mencapai 3.53 di mode gelap.

### 2.8 Definisi Token dalam CSS

```css
/* src/styles/tokens.css */
/* Diturunkan dari palet: cream #FDF4D2, biru #B0CDE6, ungu #A290B7, coklat #946D6D */

:root {
  /* === Palet sumber (dipakai langsung sebagai latar) === */
  --palet-cream:  #FDF4D2;
  --palet-biru:   #B0CDE6;
  --palet-ungu:   #A290B7;
  --palet-coklat: #946D6D;

  /* === Warna topik (varian teks) === */
  --topik-array:   #336EA1;   /* dari biru   */
  --topik-struct:  #6A5582;   /* dari ungu   */
  --topik-pointer: #543D3D;   /* dari coklat */

  /* === Semantik === */
  --bg:             #FDF4D2;  /* cream */
  --surface:        #FFFFFF;
  --surface-raised: #FBF6E4;
  --fg:             #1A1111;  /* coklat sangat gelap */
  --fg-muted:       #493333;
  --primary:        #6A5582;
  --on-primary:     #FFFFFF;
  --accent:         #543D3D;
  --on-accent:      #FFFFFF;
  --success:        #305A4F;
  --danger:         #822929;
  --border:         #D9D5D5;
  --border-strong:  #836060;
  --ring:           #6A5582;

  /* === Sintaks === */
  --code-bg:      #FFFFFF;
  --code-fg:      #493333;
  --code-keyword: #6A5582;
  --code-type:    #336EA1;
  --code-func:    #543D3D;
  --code-string:  #305A4F;
  --code-number:  #822929;
  --code-comment: #6E5C5C;

  /* === Spacing === */
  --space-1: 0.25rem;   /*  4px */
  --space-2: 0.5rem;    /*  8px */
  --space-3: 0.75rem;   /* 12px */
  --space-4: 1rem;      /* 16px */
  --space-6: 1.5rem;    /* 24px */
  --space-8: 2rem;      /* 32px */
  --space-12: 3rem;     /* 48px */
  --space-16: 4rem;     /* 64px */

  /* === Radius === */
  --radius-sm: 6px;
  --radius-md: 10px;
  --radius-lg: 14px;
  --radius-xl: 20px;
  --radius-full: 9999px;

  /* === Bayangan — tipis, bukan dekoratif === */
  --shadow-sm: 0 1px 2px rgba(84, 61, 61, 0.06);
  --shadow-md: 0 4px 12px rgba(84, 61, 61, 0.08);

  /* === Transisi === */
  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);
  --dur-fast: 120ms;
  --dur-base: 200ms;
  --dur-slow: 320ms;
}

[data-theme="dark"] {
  /* Di mode gelap, pastel palet justru berkilau */
  --topik-array:   #B0CDE6;   /* biru asli   */
  --topik-struct:  #A290B7;   /* ungu asli   */
  --topik-pointer: #B49494;   /* coklat diterangkan */

  --bg:             #322121;  /* coklat sangat gelap */
  --surface:        #452D2D;
  --surface-raised: #573A3A;
  --fg:             #FDF4D2;  /* cream */
  --fg-muted:       #FDE58B;
  --primary:        #A290B7;
  --on-primary:     #322121;
  --accent:         #B0CDE6;
  --on-accent:      #322121;
  --success:        #BCD7D0;
  --danger:         #EBC9C9;
  --border:         #6A4646;
  --border-strong:  #987373;
  --ring:           #A290B7;

  --code-bg:      #322121;
  --code-fg:      #FDF4D2;
  --code-keyword: #A290B7;
  --code-type:    #B0CDE6;
  --code-func:    #B49494;
  --code-string:  #BCD7D0;
  --code-number:  #EBC9C9;
  --code-comment: #B0A0A0;

  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.35);
  --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.45);
}
```

### 2.9 Aturan Penggunaan Warna

| Aturan | Alasan |
|--------|--------|
| **Jangan pakai warna palet asli sebagai teks** | Keempatnya pastel; rasio terbaik hanya 4.08 dan itu pun untuk teks besar. Selalu pakai varian turunan |
| Palet asli **hanya untuk latar** (badge, callout, kartu sorotan) | Di sana kontrasnya aman karena teks di atasnya gelap |
| Warna topik hanya di **aksen kecil** (border kiri, label, titik), bukan latar penuh | Latar berwarna penuh mengurangi kontras teks dan melelahkan mata |
| Jangan pakai warna sebagai **satu-satunya** penanda | Buta warna: benar/salah juga ditandai ikon centang/silang, bukan hanya warna |
| `--danger` hanya untuk aksi merusak dan jawaban salah | Kalau dipakai untuk hal biasa, kekuatan sinyalnya hilang |
| Maksimal **satu** warna topik per layar | Dua warna topik bersamaan membingungkan konteks |
| `--border` hanya untuk garis dekoratif | Rasio 1.32 memang tidak lolos 3:1, dan itu tidak masalah untuk garis pemisah. Untuk batas kontrol interaktif, **wajib** pakai `--border-strong` (5.0) |

### 2.10 Ringkasan Verifikasi Kontras

Seluruh pasangan berikut sudah dihitung dengan rumus WCAG 2.1.

**Mode terang (latar cream `#FDF4D2`):**

| Token | Nilai | Rasio | Status |
|-------|-------|-------|--------|
| `--fg` | `#1A1111` | 16.82 | AAA |
| `--fg-muted` | `#493333` | 10.55 | AAA |
| `--primary` | `#6A5582` | 5.89 | AA |
| `--accent` | `#543D3D` | 9.02 | AAA |
| `--topik-array` | `#336EA1` | 4.90 | AA |
| `--topik-struct` | `#6A5582` | 5.89 | AA |
| `--topik-pointer` | `#543D3D` | 9.02 | AAA |
| `--success` | `#305A4F` | 7.05 | AAA |
| `--danger` | `#822929` | 8.29 | AAA |
| `--border-strong` | `#836060` | 5.00 | Lolos 3:1 |
| `--ring` | `#6A5582` | 5.89 | Lolos 3:1 |
| `--on-primary` (putih di primary) | `#FFFFFF` | 6.49 | AA |
| `--on-accent` (putih di accent) | `#FFFFFF` | 9.94 | AAA |

**Mode gelap (latar `#322121`):**

| Token | Nilai | Rasio | Status |
|-------|-------|-------|--------|
| `--fg` | `#FDF4D2` | 13.85 | AAA |
| `--fg-muted` | `#FDE58B` | 12.19 | AAA |
| `--primary` | `#A290B7` | 5.24 | AA |
| `--accent` | `#B0CDE6` | 9.25 | AAA |
| `--topik-array` | `#B0CDE6` | 9.25 | AAA |
| `--topik-struct` | `#A290B7` | 5.24 | AA |
| `--topik-pointer` | `#B49494` | 5.53 | AA |
| `--success` | `#BCD7D0` | 10.01 | AAA |
| `--danger` | `#EBC9C9` | 9.98 | AAA |
| `--border-strong` | `#987373` | 3.66 | Lolos 3:1 |
| `--ring` | `#A290B7` | 5.24 | Lolos 3:1 |
| `--on-primary` (gelap di primary) | `#322121` | 5.24 | AA |
| `--on-accent` (gelap di accent) | `#322121` | 9.25 | AAA |

**Pastel sebagai latar:**

| Latar | Teks | Rasio | Status |
|-------|------|-------|--------|
| Cream `#FDF4D2` | `#1A1111` | 16.82 | AAA |
| Biru `#B0CDE6` | `#1A1111` | 11.24 | AAA |
| Ungu `#A290B7` | `#1A1111` | 6.37 | AA |
| Coklat `#946D6D` | Cream `#FDF4D2` | 4.08 | AA-Large |

> **Peringatan untuk `--pastel-coklat`:** rasionya 4.08 hanya memenuhi syarat **teks besar** (minimal 18px tebal atau 24px biasa). Untuk teks kecil di atas coklat, gunakan `--topik-pointer` (`#543D3D`) di atas latar cream, bukan coklat pastel.

---

## 3. Tipografi

### 3.1 Pemilihan Font

| Peran | Font | Ukuran | Alasan |
|-------|------|--------|--------|
| **UI & teks** | **Inter** | 16px dasar | Dirancang untuk layar, angka tabular, x-height tinggi, gratis. Pilihan standar untuk dashboard dan dokumentasi |
| **Kode** | **JetBrains Mono** | 14px dasar | Ligatur jelas, membedakan `0/O` dan `1/l/I` dengan baik — krusial untuk kode pointer |
| **Judul** | **Space Grotesk** | — | Geometris, sedikit teknis, memberi karakter tanpa mengorbankan keterbacaan |

Alasan `Space Grotesk` untuk judul: memberi nuansa teknis yang tidak dimiliki Inter, tanpa menjadi norak seperti font "futuristik" atau "hacker".

**Font yang ditolak:**

| Font | Alasan |
|------|--------|
| Baloo 2, Comic Neue | Direkomendasikan sistem untuk kategori edukasi anak — tidak sesuai target mahasiswa |
| Fira Code sebagai font UI | Dirancang untuk kode, terlalu lebar untuk teks paragraf |
| Roboto | Terlalu generik, tidak memberi identitas |
| Font serif (Crimson, EB Garamond) | Memberi nuansa akademik, tetapi kurang tajam di layar untuk konten teknis |

### 3.2 Skala Tipe

Rasio 1.25 (Major Third), dibulatkan ke nilai praktis.

| Token | Ukuran | Line-height | Weight | Pemakaian |
|-------|--------|-------------|--------|-----------|
| `--text-xs` | 12px | 1.5 | 500 | Label, badge, meta |
| `--text-sm` | 14px | 1.5 | 400 | Teks sekunder, tabel |
| `--text-base` | 16px | 1.6 | 400 | Teks utama |
| `--text-lg` | 18px | 1.6 | 400 | Teks baca panjang (modul) |
| `--text-xl` | 20px | 1.4 | 600 | Sub-judul |
| `--text-2xl` | 25px | 1.3 | 600 | Judul bagian |
| `--text-3xl` | 31px | 1.2 | 700 | Judul halaman |
| `--text-4xl` | 39px | 1.1 | 700 | Judul hero |

**Aturan:**

- **Teks isi modul memakai 18px, bukan 16px.** Materi teknis dengan banyak istilah butuh keterbacaan lebih tinggi untuk sesi baca panjang.
- **Lebar baris maksimal 72 karakter** (sekitar `65ch`). Baris lebih panjang dari itu membuat mata sulit menemukan awal baris berikutnya.
- **Line-height 1.6 untuk teks isi**, 1.2 untuk judul besar.

### 3.3 Aturan Font Kode

| Aturan | Nilai |
|--------|-------|
| Ukuran dasar | 14px |
| Line-height | 1.7 (lebih longgar, agar mudah menelusuri baris) |
| Lebar tab | 4 spasi |
| Ligatur | **Aktif** (membantu membaca `->`, `!=`, `<=`) |
| Angka tabular | **Aktif** (agar kolom angka lurus) |
| Baris maksimal | 80 karakter sebelum scroll horizontal |

Alasan line-height kode lebih longgar dari teks biasa: saat menelusuri kode baris demi baris (terutama soal tracing), mata butuh pemisah visual yang jelas antar baris.

### 3.4 Pemuatan Font

```html
<!-- index.html -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;700&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">
```

```css
:root {
  --font-ui: 'Inter', system-ui, -apple-system, sans-serif;
  --font-heading: 'Space Grotesk', 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', ui-monospace, monospace;
}

body {
  font-family: var(--font-ui);
  font-size: var(--text-base);
  line-height: 1.6;
  font-feature-settings: 'tnum' 1; /* angka tabular */
  -webkit-font-smoothing: antialiased;
}

code, pre, .font-mono {
  font-family: var(--font-mono);
  font-variant-ligatures: contextual;
  font-feature-settings: 'tnum' 1, 'liga' 1;
}
```

**Catatan performa:** `display=swap` mencegah teks tidak terlihat saat font dimuat. Untuk mengurangi *layout shift*, ukuran font sistem diatur sebagai cadangan agar tinggi barisnya mirip.

---

## 4. Spacing & Layout

### 4.1 Skala Spacing

Basis 4px. Semua jarak harus kelipatan 4.

| Token | Nilai | Pemakaian umum |
|-------|-------|----------------|
| `--space-1` | 4px | Jarak ikon ke label |
| `--space-2` | 8px | Jarak antar elemen dalam grup |
| `--space-3` | 12px | Padding dalam badge/chip |
| `--space-4` | 16px | Padding kartu kecil, jarak antar field |
| `--space-6` | 24px | Padding kartu, jarak antar grup |
| `--space-8` | 32px | Jarak antar section |
| `--space-12` | 48px | Jarak antar blok besar |
| `--space-16` | 64px | Padding vertikal section hero |

### 4.2 Lebar Kontainer

| Nama | Maks Lebar | Dipakai di |
|------|-----------|------------|
| `container-narrow` | 720px | Teks modul (lebar baca optimal) |
| `container-base` | 1080px | Halaman umum, daftar kartu |
| `container-wide` | 1320px | Dashboard, grid |

### 4.3 Breakpoint

| Nama | Lebar | Perangkat | Perubahan utama |
|------|-------|-----------|-----------------|
| *(dasar)* | 320px+ | HP kecil | 1 kolom, bottom nav, drawer |
| `sm` | 640px | HP besar / landscape | Grid 1 → 2 kolom |
| `md` | 768px | Tablet portrait | Navigasi jadi horizontal, grid → 3 kolom |
| `lg` | 1024px | Tablet landscape / laptop | Sidebar modul muncul, grid → 3 kolom lebar |
| `xl` | 1280px | Desktop | Grid → 4 kolom |

**Pendekatan: mobile-first.** Semua style dasar untuk 320px, lalu ditambah di breakpoint yang lebih besar. Alasan: lebih mudah menambahkan daripada mengurangi, dan HP adalah perangkat yang paling sering dipakai untuk mengulang materi.

### 4.4 Dua Pengalaman, Satu Basis Kode

**Mobile dan desktop sama-sama prioritas penuh** — bukan mobile sebagai "versi yang dipaksakan". Keduanya punya tata letak yang dirancang sendiri.

Yang **berbeda** antar perangkat:

| Aspek | Mobile | Desktop |
|-------|--------|---------|
| **Navigasi utama** | Bottom nav 5 ikon, atau menu drawer | Header horizontal sticky |
| **Daftar isi modul** | Drawer yang bisa dibuka (tombol di header) | Sidebar sticky di kiri |
| **Daftar materi** | 1 kolom, kartu penuh lebar | 3–4 kolom grid |
| **Kartu flashcard** | Lebar penuh, tinggi menyesuaikan viewport | Maks 560px, tinggi tetap 320–480px |
| **Blok kode** | Scroll horizontal, font 13px | Font 14px, kadang bisa muat penuh |
| **Target sentuh** | 44×44px wajib | 40×40px cukup (mouse lebih presisi) |
| **Padding halaman** | 16px | 24–32px |
| **Opsi jawaban quiz** | Tombol besar, mudah disentuh | Bisa lebih rapat |

Yang **sama** di keduanya:

- Isi konten — tidak ada konten yang disembunyikan di salah satu perangkat
- Alur tiga tahap — penguncian berjalan identik
- Token warna dan tipografi
- Semua fitur — tidak ada fitur "hanya desktop"

**Aturan penting: jangan sembunyikan fitur di mobile.** Jika sebuah fitur tidak nyaman di layar kecil, rancang ulang — jangan hilangkan. Mahasiswa yang hanya punya HP harus bisa menuntaskan seluruh 10 modul.

### 4.5 Titik Perhatian Khusus Mobile

#### Safe Area (Layar dengan Notch / Dynamic Island)

HP modern punya area yang tertutup notch, kamera, atau gesture bar. Konten tidak boleh tertutup.

```css
/* Bottom nav harus menghindari gesture bar */
.bottom-nav {
  padding-bottom: env(safe-area-inset-bottom);
}

/* Header harus menghindari notch saat landscape */
.header {
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}
```

```html
<!-- index.html — wajib ada agar env() berfungsi -->
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
```

**`viewport-fit=cover` wajib.** Tanpa ini, `env(safe-area-inset-*)` selalu bernilai 0 dan konten akan tertutup notch.

#### Tinggi Viewport

Jangan pakai `100vh` — di browser mobile, address bar yang muncul/hilang membuat `100vh` lebih tinggi dari layar sebenarnya, sehingga konten terpotong.

```css
/* Salah — konten bisa terpotong di HP */
.kartu { height: 100vh; }

/* Benar — menyesuaikan tinggi viewport dinamis */
.kartu { min-height: 100dvh; }
```

Satuan yang dipakai:

| Satuan | Arti | Kapan dipakai |
|--------|------|---------------|
| `dvh` | Dynamic viewport height | Default — menyesuaikan address bar |
| `svh` | Small viewport height | Saat butuh ukuran terkecil yang pasti |
| `lvh` | Large viewport height | Jarang dipakai |
| `vh` | **Hindari** | Tidak menyesuaikan address bar |

#### Orientasi Landscape

Saat HP diputar ke landscape, tinggi layar menjadi sangat pendek (± 375px). Ini masalah untuk kartu flashcard yang butuh ruang vertikal.

| Elemen | Perilaku saat landscape |
|--------|-------------------------|
| Kartu flashcard | Tinggi berkurang jadi `min(320px, 60dvh)`, konten bisa di-scroll di dalam |
| Header | Tetap terlihat, tapi lebih tipis |
| Bottom nav | Tetap, tapi padding lebih kecil |
| Tombol aksi | Tetap minimal 44px tinggi |

```css
@media (orientation: landscape) and (max-height: 500px) {
  .flashcard {
    min-height: 60dvh;
    max-height: 70dvh;
  }
  .header {
    padding-block: var(--space-2);
  }
}
```

#### Tombol Virtual Keyboard

Saat keyboard muncul (misalnya di kotak pencarian), viewport mengecil. Pastikan:

- Elemen yang difokus **tidak tertutup keyboard**
- Gunakan `scroll-margin-bottom` pada input

```css
input,
textarea {
  /* Beri ruang saat keyboard muncul */
  scroll-margin-bottom: 100px;
}
```

#### Zoom Tidak Dimatikan

```html
<!-- JANGAN tambahkan user-scalable=no -->
<!-- Pengguna dengan gangguan penglihatan butuh zoom -->
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
```

**Dilarang** memakai `maximum-scale=1` atau `user-scalable=no`. Ini melanggar WCAG 1.4.4 dan membuat aplikasi tidak dapat diakses.

### 4.6 Titik Perhatian Khusus Desktop

| Aspek | Aturan |
|-------|--------|
| **Lebar konten** | Maks 720px untuk teks baca (72 karakter per baris). Jangan biarkan teks melebar penuh di monitor lebar |
| **Navigasi** | Header horizontal sticky di atas. Tidak ada bottom nav |
| **Hover** | Boleh dipakai sebagai tambahan, tapi **jangan pernah** satu-satunya cara mengakses sesuatu |
| **Keyboard** | Harus lengkap. Desktop adalah tempat pengguna keyboard |
| **Kursor** | `cursor: pointer` pada semua elemen yang bisa diklik |
| **Grid** | Manfaatkan ruang lebar: 3–4 kolom untuk daftar, bukan 1 kolom memanjang |

**Aturan penting tentang hover:** semua yang bisa dilakukan dengan hover harus bisa dilakukan dengan keyboard dan sentuh. Hover hanya mempercepat, bukan menggerbang.

### 4.7 Target Sentuh

| Elemen | Ukuran minimum |
|--------|----------------|
| Tombol | 44 × 44px |
| Tautan dalam teks | 44px tinggi area klik (padding vertikal) |
| Ikon yang bisa diklik | 44 × 44px area klik, ikon boleh 20px |
| Jarak antar target | ≥ 8px |

Alasan: standar aksesibilitas untuk pengguna jari besar atau tremor. Ini juga nyaman untuk semua orang.

---

## 5. Ikon

**Perpustakaan:** Lucide React. Alasan: ringan (dapat di-*tree-shake*), konsisten secara visual, lisensi permisif, dan bergaya garis yang sesuai dengan arah minimalis.

### 5.1 Ikon Standar

| Konsep | Nama Ikon Lucide | Dipakai di |
|--------|------------------|------------|
| Home | `house` | Navigasi |
| Dashboard | `layout-dashboard` | Navigasi |
| Materi | `book-open` | Navigasi |
| Video | `play-circle` | Navigasi |
| Soal / Latihan | `circle-help` | Navigasi |
| Flashcard | `layers` | Mode flashcard |
| Quiz | `clipboard-check` | Mode quiz |
| Selesai | `check` | Status modul |
| Terkunci | `lock` | Tahap terkunci |
| Sedang berjalan | `circle-dot` | Status progres |
| Kembali | `arrow-left` | Navigasi |
| Berikutnya | `arrow-right` | Navigasi |
| Buka / lanjut | `arrow-up-right` | CTA |
| Mode terang | `sun` | Pengalih tema |
| Mode gelap | `moon` | Pengalih tema |
| Benar | `check-circle-2` | Umpan balik quiz |
| Salah | `x-circle` | Umpan balik quiz |
| Peringatan | `alert-triangle` | Jebakan di modul |
| Info | `info` | Catatan |
| Salin kode | `copy` | Blok kode |
| Kode tersalin | `check` | Blok kode (setelah salin) |
| Ulangi | `rotate-ccw` | Ulangi sesi |
| Reset progres | `trash-2` | Pengaturan |
| Pencarian | `search` | Pencarian |
| Filter | `sliders-horizontal` | Filter materi |
| Perbesar | `maximize-2` | Mode baca fokus |

### 5.2 Aturan Ikon

| Aturan | Alasan |
|--------|--------|
| **DILARANG memakai emoji, di mana pun** | Emoji dirender berbeda di setiap OS dan versi font, tidak dapat diwarnai dengan token, tidak konsisten ukurannya, dan tidak dapat diberi `aria-label`. Ini berlaku untuk UI, konten modul, kartu flashcard, soal, dan dokumentasi |
| **Semua ikon memakai SVG Lucide** | Satu sumber, konsisten, dapat diwarnai dengan `currentColor` |
| **Ikon sendiri harus punya label** | Ikon tanpa teks tidak jelas bagi pengguna baru |
| **Ukuran default 20px**, minimum 16px | Lebih kecil dari itu sulit dikenali |
| **`stroke-width` 1.5** | 2 terlalu tebal untuk arah minimalis, 1 terlalu tipis |
| **Selalu `aria-hidden="true"` jika ada teks di sebelahnya** | Mencegah pembaca layar membacakan dua kali |

**Cara menegakkan aturan ini:** tambahkan pemeriksaan di *lint* atau *pre-commit hook* yang menolak karakter di rentang Unicode emoji (`U+1F300–U+1FAFF`, `U+2600–U+27BF`, `U+FE0F`) pada berkas sumber dan berkas konten. Aturan yang tidak ditegakkan otomatis akan dilanggar.

---

## 6. Spesifikasi Komponen

Setiap komponen mencantumkan state yang wajib ada. Komponen tanpa state lengkap akan terlihat rusak saat data kosong atau error.

### 6.1 Tombol

| Varian | Latar | Teks | Border | Dipakai untuk |
|--------|-------|------|--------|---------------|
| `primary` | `--primary` | `--on-primary` | — | Aksi utama (1 per layar) |
| `secondary` | transparan | `--fg` | `--border-strong` | Aksi pendukung |
| `ghost` | transparan | `--fg-muted` | — | Aksi tersier, ikon |
| `accent` | `--accent` | `--on-accent` | — | CTA pemasaran di Home |
| `danger` | `--danger` | `#FFFFFF` | — | Hapus, reset |

**State wajib:**

| State | Perubahan visual |
|-------|------------------|
| Default | Sesuai tabel |
| Hover | Gelapkan latar 8%, `--dur-fast` |
| Active | Turunkan 1px, gelapkan 12% |
| Focus | Cincin `--ring` 2px, offset 2px |
| Disabled | Opasitas 50%, `cursor: not-allowed`, tanpa hover |
| Loading | Spinner ganti label, tidak bisa diklik |

**Ukuran:**

| Ukuran | Tinggi | Padding-x | Font |
|--------|--------|-----------|------|
| `sm` | 32px | 12px | 14px |
| `md` | 40px | 16px | 14px |
| `lg` | 48px | 24px | 16px |

Aturan: aksi utama memakai `lg` di mobile (agar mudah disentuh), `md` di desktop.

### 6.2 Kartu Modul

Ini komponen paling penting karena muncul di Dashboard, Home, dan Materi.

```
┌─────────────────────────────────────────────────────┐
│  (garis) Array                             [3 tahap] │  ← garis topik kiri 3px
│                                                     │
│  Dasar Array & Indeks                               │  ← judul
│  Memori berurutan, indeks, dan batas array.         │  ← deskripsi (maks 2 baris)
│                                                     │
│  5 bagian · 20 kartu · 12 mnt                       │  ← meta (ikon Lucide + teks)
│                                                     │
│  ─────────────────────────────────────────────      │
│  [v] Pahami  [v] Hafal  [ ] Buktikan                │  ← indikator 3 tahap
│                                                     │
│  [ Lanjutkan Flashcard → ]                          │  ← CTA sesuai progres
└─────────────────────────────────────────────────────┘
```

**State:**

| State | Visual |
|-------|--------|
| `belum-mulai` | Border normal, indikator tahap semua abu-abu |
| `sedang` | Border kiri warna topik, CTA `primary` |
| `selesai` | Latar `--surface`, ikon centang, CTA jadi `ghost` "Ulangi" |
| `terkunci` | Opasitas 60%, ikon kunci, CTA `disabled` dengan keterangan alasan |

**Indikator 3 tahap** adalah elemen kunci: tiga label dengan ikon centang. Ikon terisi = selesai, ikon kosong = belum. Ini memberi gambaran progres tanpa perlu membuka modul.

### 6.3 Kartu Flashcard

```
                    ┌───────────────────────────────┐
                    │                          [3/20]│
                    │                               │
                    │           ARRAY               │  ← label topik
                    │                               │
                    │  Apa itu array-to-pointer     │
                    │  decay?                       │  ← pertanyaan, 24px
                    │                               │
                    │                               │
                    │      [ Ketuk untuk lihat ]     │  ← petunjuk
                    └───────────────────────────────┘
                                  ↓ flip
                    ┌───────────────────────────────┐
                    │                          [3/20]│
                    │           ARRAY               │
                    │                               │
                    │  Perubahan otomatis nama      │
                    │  array menjadi pointer ke     │  ← jawaban, 20px
                    │  elemen pertamanya saat       │
                    │  dipakai dalam ekspresi       │
                    │  tertentu...                  │
                    │                               │
                    │  [  Lupa  ]   [  Ingat  ]      │  ← penilaian diri
                    └───────────────────────────────┘
```

**Aturan interaksi:**

| Aksi | Keyboard | Hasil |
|------|----------|-------|
| Balik kartu | `Space` / `Enter` | Animasi flip 320ms |
| Tandai lupa | `1` atau `←` | Kartu lanjut, ditandai lupa |
| Tandai ingat | `2` atau `→` | Kartu lanjut, ditandai ingat |
| Keluar sesi | `Esc` | Konfirmasi jika belum selesai |

**Detail penting:**

- **Tinggi kartu tetap** (min 320px). Kalau kartu berubah tinggi saat flip, mata kehilangan posisi.
- **Konten panjang bisa di-scroll di dalam kartu**, tidak memaksa kartu memanjang.
- **Indikator sisa** selalu terlihat (`3/20`).
- **Tombol penilaian hanya muncul setelah flip.** Sebelum flip tidak ada tombol — memaksa membaca jawaban dulu.

### 6.4 Blok Kode

```cpp
// C++ · contoh.cpp
struct Mahasiswa {
    char nama[50];
    int umur;
};                    // ← perhatikan titik koma
```

| Elemen | Detail |
|--------|--------|
| Header | Label bahasa + nama file (opsional) + tombol salin |
| Latar | `--code-bg` |
| Border-radius | `--radius-md` |
| Padding | `--space-4` |
| Overflow | Scroll horizontal, tidak pernah wrap |
| Tombol salin | Ikon `copy` → berubah `check` selama 2 detik |
| Nomor baris | Hanya jika kode > 5 baris |

**Tab bahasa:** jika sebuah konsep punya versi C++ dan Python, tampilkan sebagai tab, bukan dua blok bertumpuk. Alasannya hemat ruang, tapi **kedua tab harus bisa dibuka tanpa scroll horizontal di mobile.**

### 6.5 Callout

Dipakai di modul untuk menyorot hal penting.

| Tipe | Ikon | Warna | Dipakai untuk |
|------|------|-------|---------------|
| `info` | `info` | `--primary` | Konteks tambahan |
| `warning` | `alert-triangle` | `--topik-pointer` | Jebakan, kesalahan umum |
| `danger` | `alert-triangle` | `--danger` | Undefined behavior, kehilangan data |
| `tip` | `lightbulb` | `--success` | Cara mengingat, jalan pintas |

**Aturan:** maksimal **dua** callout per bagian modul. Lebih dari itu, tidak ada lagi yang menonjol.

### 6.6 Indikator Progres

| Bentuk | Dipakai untuk |
|--------|---------------|
| **Bar** | Progres linier dalam satu sesi (kartu 3 dari 20) |
| **Ring** | Progres keseluruhan deck (persentase) |
| **Titik 3 tahap** | Status modul (pahami/hafalkan/buktikan) |
| **Angka besar** | Statistik di Dashboard (mis. "82%") |

**Aturan aksesibilitas:** setiap indikator harus punya teks pendamping. Bar tanpa label tidak berarti apa-apa bagi pembaca layar.

```html
<div role="progressbar"
     aria-valuenow="3"
     aria-valuemin="0"
     aria-valuemax="20"
     aria-label="Kartu 3 dari 20">
```

### 6.7 Notifikasi (Toast)

| Tipe | Warna | Contoh pesan |
|------|-------|--------------|
| Sukses | `--success` | "Progres tersimpan" |
| Info | `--primary` | "Kamu menandai 5 kartu perlu diulang" |
| Peringatan | `--topik-pointer` | "Progres disimpan hanya di browser ini" |
| Error | `--danger` | "Gagal memuat materi. Coba lagi." |

**Aturan:** muncul di kanan bawah (desktop) atau atas (mobile), hilang otomatis setelah 4 detik, kecuali tipe error (harus ditutup manual). Maksimal 3 notifikasi bertumpuk.

### 6.8 Navigasi

**Desktop:** header horizontal, sticky di atas.

```
┌──────────────────────────────────────────────────────────────┐
│  FlashStruct     Home  Dashboard  Materi  Video  Soal   [Tema]│
└──────────────────────────────────────────────────────────────┘
```

**Mobile:** header dengan tombol menu, atau bottom nav 5 item.

```
┌──────────────────────┐
│ [Menu] FlashStruct [Tema] │
└──────────────────────┘
...
┌──────────────────────┐
│  Home  Dash  Materi  │  ← maksimal 5 item
│  Video  Soal         │
└──────────────────────┘
```

**Aturan:** navigasi aktif ditandai **garis bawah + warna `--fg`** (bukan hanya warna, karena warna saja tidak cukup untuk pengguna dengan gangguan penglihatan warna).

**Aturan penting:** halaman Materi punya sub-navigasi (daftar bagian modul) yang muncul sebagai sidebar di `lg` ke atas, dan sebagai *dropdown* yang bisa dibuka di mobile.

---

## 7. Animasi

### 7.1 Prinsip

Animasi di FlashStruct hanya punya tiga tugas:

1. **Menjelaskan perubahan** — dari mana ke mana sebuah elemen bergerak
2. **Memberi umpan balik** — aksi sudah diterima
3. **Menjaga kontinuitas** — perpindahan tidak terasa seperti lompatan

Animasi yang tidak memenuhi salah satu dari tiga ini **tidak dibuat**.

### 7.2 Durasi

| Token | Durasi | Dipakai untuk |
|-------|--------|---------------|
| `--dur-fast` | 120ms | Hover, warna, opacity |
| `--dur-base` | 200ms | Tombol, transisi kecil |
| `--dur-slow` | 320ms | Flip kartu, buka panel |
| `--dur-slower` | 480ms | Perpindahan halaman |

**Aturan:** elemen keluar selalu **lebih cepat** dari elemen masuk. Ini membuat UI terasa responsif.

### 7.3 Easing

| Token | Nilai | Dipakai untuk |
|-------|-------|---------------|
| `--ease-out` | `cubic-bezier(0.16, 1, 0.3, 1)` | Default untuk hampir semua |
| `--ease-in-out` | `cubic-bezier(0.65, 0, 0.35, 1)` | Elemen yang bergerak dan berhenti |
| `--ease-spring` | `cubic-bezier(0.34, 1.56, 0.64, 1)` | Hanya untuk umpan balik benar/salah |

### 7.4 Animasi Kunci

| Nama | Trigger | Durasi | Detail |
|------|---------|--------|--------|
| **Flip kartu** | Klik/Enter | 320ms | `rotateY` 0° → 180°, `perspective: 1200px`, `backface-visibility: hidden` |
| **Kartu masuk** | Muat sesi | 200ms | `opacity` 0→1, `translateY` 8px→0 |
| **Kartu keluar** | Setelah penilaian | 160ms | `opacity` 1→0, `translateX` ±40px sesuai arah |
| **Umpan balik quiz** | Jawab soal | 300ms | `scale` 1→1.03→1 (spring) |
| **Stagger daftar** | Muat halaman | 300ms | `opacity` 0→1, `y` 8→0, stagger 30ms per item |
| **Panel buka** | Klik | 240ms | `height` + `opacity` |
| **Toast masuk** | Muncul | 200ms | `translateY` 16px→0, `opacity` 0→1 |

### 7.5 Animasi Flip Kartu — Implementasi

```css
.flashcard {
  perspective: 1200px;
}

.flashcard-inner {
  position: relative;
  width: 100%;
  height: 100%;
  transform-style: preserve-3d;
  transition: transform var(--dur-slow) var(--ease-in-out);
}

.flashcard.flipped .flashcard-inner {
  transform: rotateY(180deg);
}

.flashcard-face {
  position: absolute;
  inset: 0;
  backface-visibility: hidden;
  -webkit-backface-visibility: hidden;
}

.flashcard-back {
  transform: rotateY(180deg);
}

@media (prefers-reduced-motion: reduce) {
  .flashcard-inner {
    transition: none;
  }
  /* Fallback: ganti tampilan tanpa rotasi */
  .flashcard.flipped .flashcard-front { display: none; }
  .flashcard:not(.flipped) .flashcard-back { display: none; }
}
```

**Catatan teknis:** animasi memakai `transform` dan `opacity` saja, tidak pernah `width`/`height`/`top`/`left`. Properti tersebut memicu *reflow* dan menyebabkan *jank*.

### 7.6 Menghormati Prefers-Reduced-Motion

Ini **wajib**, bukan opsional. Animasi flip 3D dapat memicu *motion sickness*.

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

Namun **jangan hanya mematikan animasi** — ganti dengan alternatif yang tetap memberi informasi:

| Animasi asli | Alternatif tanpa gerak |
|--------------|------------------------|
| Flip kartu | Ganti isi kartu seketika, dengan indikator "Sisi jawaban" |
| Kartu keluar | Langsung hilang |
| Stagger daftar | Semua item langsung tampil |
| Umpan balik benar/salah | Warna + ikon langsung berubah |

---

## 8. Aksesibilitas

### 8.1 Yang Sudah Dijamin

| Kriteria | Status | Cara |
|----------|--------|------|
| Kontras teks ≥ 4.5:1 | **Terverifikasi** | Semua pasangan dihitung, hasil di §2.3–2.5 |
| Fokus terlihat | Ya | Cincin `--ring` 2px, offset 2px |
| Target sentuh ≥ 44px | Ya | Lihat §4.4 |
| `prefers-reduced-motion` | Ya | Lihat §7.6 |
| Warna bukan penanda tunggal | Ya | Benar/salah pakai ikon + warna |
| Ikon dekoratif disembunyikan | Ya | `aria-hidden="true"` |

### 8.2 Aturan Implementasi

| Aturan | Contoh |
|--------|--------|
| **Jangan hapus outline fokus** | `outline: none` dilarang kecuali diganti cincin yang lebih baik |
| **Gunakan elemen semantik** | `<button>` bukan `<div onclick>` |
| **Label eksplisit** | `<label for="x">` bukan hanya placeholder |
| **Heading berurutan** | `h1` → `h2` → `h3`, jangan melompat |
| **Status live** | Hasil quiz pakai `aria-live="polite"` |
| **Alternatif teks** | Setiap gambar/diagram punya `alt` deskriptif |
| **Struktur landmark** | `<header>`, `<nav>`, `<main>`, `<footer>` |

### 8.3 Yang Perlu Diperhatikan Khusus

**1. Kartu flashcard harus bisa dioperasikan keyboard sepenuhnya.**

```html
<div
  role="button"
  tabindex="0"
  aria-label="Kartu 3 dari 20. Tekan Enter untuk melihat jawaban"
  aria-pressed={isFlipped}
  onKeyDown={handleKey}>
```

**2. Kode harus terbaca pembaca layar.** Blok kode diberi `role="region"` dengan label:

```html
<pre role="region" aria-label="Contoh kode C++: deklarasi struct">
```

**3. Hasil quiz tidak boleh hanya berupa warna.**

```html
<div role="status" aria-live="polite">
  <span class="icon-check" aria-hidden="true"></span>
  <span class="sr-only">Benar.</span>
  Jawaban benar: 20 byte
</div>
```

**4. Progress bar butuh nilai teks**, lihat §6.6.

---

## 9. Checklist Sebelum Menandai UI Selesai

Salin checklist ini untuk setiap komponen atau halaman baru.

- [ ] Hanya memakai token semantik, tidak ada nilai heksadesimal mentah di komponen
- [ ] Semua state ada: default, hover, active, focus, disabled, loading, empty, error
- [ ] Kontras teks ≥ 4.5:1 (sudah dijamin jika memakai token)
- [ ] Target sentuh ≥ 44×44px
- [ ] Dapat dioperasikan keyboard penuh (Tab, Enter, Space, Escape)
- [ ] Cincin fokus terlihat jelas
- [ ] Animasi dihormati saat `prefers-reduced-motion`
- [ ] Tidak ada emoji di mana pun — semua ikon memakai Lucide SVG
- [ ] Teks tidak terpotong pada 375px
- [ ] Tidak ada scroll horizontal pada 375px, 768px, 1024px, 1440px
- [ ] Teks alternatif untuk gambar dan diagram
- [ ] Struktur heading berurutan
- [ ] Berfungsi di mode terang **dan** gelap
- [ ] Tidak ada *layout shift* saat konten dimuat (ruang sudah dipesan)
- [ ] Angka memakai angka tabular (kolom lurus)
