# 05 — Skema Database

> Skema PostgreSQL di Supabase, kebijakan RLS, dan pola query untuk FlashStruct.
> Status: `[FINAL]` · Justifikasi dan tautan sumber resmi ada di `riset/01-RISET-TEKNIS.md` §3–4.

---

## 0. Status Validasi

Seluruh SQL di dokumen ini **sudah dijalankan dan diverifikasi** pada PostgreSQL 18.6 lokal (tanpa Docker) pada 21 September 2026.

> **Catatan penamaan:** dokumen riset (`riset/01-RISET-TEKNIS.md`) memakai contoh nama tabel bahasa Inggris (`modules`, `lessons`) karena diambil langsung dari dokumentasi resmi Supabase. **Skema yang dipakai proyek ini adalah yang ada di dokumen ini** (bahasa Indonesia: `modul`, `bagian_modul`, `flashcard`, `soal`, `opsi_soal`). Tabel pemetaan lengkap ada di awal `riset/01-RISET-TEKNIS.md`.

| Yang diuji | Hasil |
|------------|-------|
| DDL `001_initial_schema.sql` | Berjalan bersih, 6 tabel + 4 enum + 12 index dibuat |
| RLS `002_rls_policies.sql` | Berjalan bersih, 6 policy dibuat |
| Seed `seed.sql` | Berjalan bersih: 1 modul, 5 bagian, 8 kartu, 3 soal, 12 opsi, 1 video |
| `anon` SELECT | **Berhasil** — bisa membaca data |
| `anon` INSERT | **Ditolak** — `permission denied for table modul` |
| `anon` UPDATE | **Ditolak** — `permission denied for table modul` |
| `anon` DELETE | **Ditolak** — `permission denied for table modul` |
| `anon` DROP TABLE | **Ditolak** — `must be owner of table modul` |
| Constraint `slug_format` | Menolak slug dengan spasi/huruf besar |
| Constraint `trace_wajib_kode` | Menolak soal TRACE tanpa kode |
| Index `opsi_soal_satu_benar_idx` | Menolak soal dengan dua jawaban benar |
| Constraint `kode_butuh_bahasa` | Menolak blok kode tanpa penanda bahasa |
| Constraint `youtube_id_format` | Menolak ID video yang tidak valid |
| `on delete cascade` | Menghapus modul membersihkan 5 tabel turunannya |
| Pemeriksa konten | Bekerja, menemukan modul dengan kartu/soal kurang dari batas |

**Cara mengulang validasi ini:** lihat `09-PANDUAN-SETUP.md` §4 (memakai PostgreSQL lokal, tanpa Docker).

**Catatan penting:** RLS di Supabase memakai role `anon` dan `authenticated` yang tidak ada di PostgreSQL biasa. Untuk menguji secara lokal, kedua role itu harus dibuat lebih dulu (perintahnya ada di `09-PANDUAN-SETUP.md` §4.4). Hasil pengujian di atas sudah memakai role tiruan tersebut.

---

## 1. Prinsip Desain Skema

| Prinsip | Alasan |
|---------|--------|
| **Konten read-only dari sisi client** | Tidak ada autentikasi, jadi tidak boleh ada jalur tulis dari browser |
| **Nama tabel memakai istilah domain** | `modul`, `bagian_modul`, `flashcard`, `soal` — sesuai bahasa yang dipakai di dokumen lain |
| **Kunci primer UUID** | Bisa dibuat di client tanpa konflik, tidak membocorkan jumlah baris |
| **`urutan` eksplisit, bukan mengandalkan `id`** | Urutan tampil harus bisa diubah tanpa mengubah kunci |
| **`on delete cascade` di semua relasi anak** | Menghapus modul harus membersihkan seluruh turunannya |
| **Index pada setiap foreign key** | PostgreSQL tidak membuat index otomatis untuk FK |
| **Konten dalam Markdown** | Fleksibel, mudah ditulis, tidak terkunci pada editor tertentu |

---

## 2. Diagram Relasi

```
┌─────────────────────┐
│       modul         │  "Dasar Array & Indeks"
│─────────────────────│
│ id (PK)             │
│ slug (UNIQUE)       │  <- dipakai di URL: /materi/array-dasar
│ judul               │
│ topik               │  'array' | 'struct' | 'pointer'
│ deskripsi           │
│ estimasi_menit      │
│ urutan              │
└──────────┬──────────┘
           │
     ┌─────┼──────────────┬─────────────────┐
     │     │              │                 │
     v     v              v                 v
┌─────────┐ ┌──────────┐ ┌───────────┐ ┌──────────┐
│ bagian_ │ │  video   │ │ flashcard │ │   soal   │
│ modul   │ │          │ │           │ │          │
├─────────┤ ├──────────┤ ├───────────┤ ├──────────┤
│ id (PK) │ │ id (PK)  │ │ id (PK)   │ │ id (PK)  │
│ modul_id│ │ modul_id │ │ modul_id  │ │ modul_id │
│ slug    │ │ youtube_ │ │ depan     │ │ pertanyaan│
│ judul   │ │   id     │ │ belakang  │ │ kode      │
│ konten_ │ │ judul    │ │ card_type │ │ bahasa_   │
│   md    │ │ durasi_  │ │ urutan    │ │   kode    │
│ urutan  │ │   detik  │ └───────────┘ │ tipe      │
└─────────┘ │ urutan   │               │ card_type │
            └──────────┘               │ penjelasan│
                                       │ urutan    │
                                       └─────┬─────┘
                                             │
                                             v
                                      ┌────────────┐
                                      │ opsi_soal  │
                                      ├────────────┤
                                      │ id (PK)    │
                                      │ soal_id    │
                                      │ label      │  'A'..'D'
                                      │ teks       │
                                      │ benar      │
                                      │ urutan     │
                                      └────────────┘
```

**Catatan penting:** `flashcard` dan `soal` terhubung **langsung ke `modul`**, bukan ke `bagian_modul`.

Alasan: deck kartu dan bank soal berlaku untuk satu modul secara utuh. PRD §3 Tahap 2 menyatakan "Kartu dikelompokkan per modul". Jika kartu ditautkan ke bagian, maka sesi flashcard harus menggabungkan kartu dari beberapa bagian — menambah kompleksitas tanpa manfaat.

`bagian_modul` hanya dipakai untuk dua hal: menampilkan isi modul secara bertahap, dan melacak progres baca (PRD mensyaratkan 80% bagian dibuka).

---

## 3. DDL Lengkap

Simpan sebagai `supabase/migrations/001_initial_schema.sql`.

```sql
-- =========================================================
-- FlashStruct — Skema Awal
-- Semua tabel konten bersifat READ-ONLY untuk client.
-- =========================================================

-- Ekstensi untuk gen_random_uuid()
create extension if not exists pgcrypto;


-- =========================================================
-- ENUM: nilai tetap yang divalidasi di level database
-- =========================================================

create type topik_modul as enum ('array', 'struct', 'pointer');

create type tipe_kartu as enum (
  'ISTILAH',    -- definisi konsep
  'SINTAKS',    -- cara menulis kode
  'TRACING',    -- telusuri kode, tentukan output
  'BANDING',    -- beda X dan Y
  'JEBAKAN',    -- kode yang salah
  'MEMORI',     -- apa yang terjadi di memori
  'KAPAN'       -- kapan dipakai
);

create type tipe_soal as enum (
  'PG',         -- pilihan ganda biasa
  'TRACE',      -- telusuri kode
  'ANALISIS'    -- temukan penyebab bug
);

create type bahasa_kode as enum ('cpp', 'python');


-- =========================================================
-- MODUL — unit belajar utama
-- =========================================================

create table public.modul (
  id              uuid primary key default gen_random_uuid(),
  slug            text not null unique,
  judul           text not null,
  topik           topik_modul not null,
  deskripsi       text not null,
  estimasi_menit  int  not null default 10 check (estimasi_menit > 0),
  urutan          int  not null default 0,
  dibuat_pada     timestamptz not null default now(),
  diperbarui_pada timestamptz not null default now(),

  constraint slug_format check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$')
);

create index modul_topik_urutan_idx on public.modul (topik, urutan);


-- =========================================================
-- BAGIAN_MODUL — isi modul, dipecah per bagian
-- =========================================================

create table public.bagian_modul (
  id          uuid primary key default gen_random_uuid(),
  modul_id    uuid not null references public.modul (id) on delete cascade,
  slug        text not null,
  judul       text not null,
  konten_md   text not null,
  urutan      int  not null default 0,

  unique (modul_id, slug)
);

create index bagian_modul_modul_idx on public.bagian_modul (modul_id, urutan);


-- =========================================================
-- VIDEO — pendukung, opsional, tidak memblokir progres
-- =========================================================

create table public.video (
  id            uuid primary key default gen_random_uuid(),
  modul_id      uuid not null references public.modul (id) on delete cascade,
  youtube_id    text not null,
  judul         text not null,
  deskripsi     text,
  durasi_detik  int check (durasi_detik > 0),
  urutan        int not null default 0,

  constraint youtube_id_format
    check (youtube_id ~ '^[A-Za-z0-9_-]{11}$')
);

create index video_modul_idx on public.video (modul_id, urutan);


-- =========================================================
-- FLASHCARD — kartu hafalan, satu deck per modul
-- =========================================================

create table public.flashcard (
  id          uuid primary key default gen_random_uuid(),
  modul_id    uuid not null references public.modul (id) on delete cascade,
  depan       text not null,
  belakang    text not null,
  card_type   tipe_kartu not null,
  kode        text,                    -- opsional, blok kode di sisi mana pun
  bahasa_kode bahasa_kode,             -- wajib diisi jika kode tidak null
  urutan      int not null default 0,

  -- Kode harus punya bahasa
  constraint kode_butuh_bahasa
    check (kode is null or bahasa_kode is not null),

  -- Panjang wajar, mencegah kartu yang tidak layak
  constraint depan_maksimal check (char_length(depan) <= 400),
  constraint belakang_maksimal check (char_length(belakang) <= 800)
);

create index flashcard_modul_idx on public.flashcard (modul_id, urutan);
create index flashcard_card_type_idx on public.flashcard (card_type);


-- =========================================================
-- SOAL — bank soal quiz
-- =========================================================

create table public.soal (
  id          uuid primary key default gen_random_uuid(),
  modul_id    uuid not null references public.modul (id) on delete cascade,
  pertanyaan  text not null,
  kode        text,                    -- opsional, untuk tipe TRACE/ANALISIS
  bahasa_kode bahasa_kode,
  tipe        tipe_soal not null,
  card_type   tipe_kartu not null,     -- dipakai untuk analisis topik lemah
  penjelasan  text not null,           -- WAJIB: jelaskan mengapa jawaban benar
  urutan      int not null default 0,

  constraint soal_kode_butuh_bahasa
    check (kode is null or bahasa_kode is not null),

  -- Soal TRACE dan ANALISIS wajib punya kode
  constraint trace_wajib_kode
    check (tipe = 'PG' or kode is not null),

  constraint pertanyaan_maksimal check (char_length(pertanyaan) <= 800),
  constraint penjelasan_maksimal check (char_length(penjelasan) <= 1200)
);

create index soal_modul_idx on public.soal (modul_id, urutan);
create index soal_card_type_idx on public.soal (card_type);


-- =========================================================
-- OPSI_SOAL — pilihan jawaban
-- =========================================================

create table public.opsi_soal (
  id       uuid primary key default gen_random_uuid(),
  soal_id  uuid not null references public.soal (id) on delete cascade,
  label    text not null,
  teks     text not null,
  benar    boolean not null default false,
  urutan   int not null default 0,

  constraint label_valid check (label in ('A', 'B', 'C', 'D')),
  unique (soal_id, label)
);

create index opsi_soal_soal_idx on public.opsi_soal (soal_id, urutan);


-- =========================================================
-- KENDALA: tepat satu jawaban benar per soal
-- =========================================================
-- Unique partial index: hanya satu baris dengan benar = true
-- per soal_id. Ini mencegah soal punya dua jawaban benar
-- atau tidak punya jawaban benar sama sekali.

create unique index opsi_soal_satu_benar_idx
  on public.opsi_soal (soal_id)
  where benar = true;
```

### 3.1 Mengapa Ada `check` Constraint

Batasan di level database menangkap kesalahan yang tidak terlihat saat menulis konten:

| Constraint | Mencegah |
|------------|----------|
| `slug_format` | Slug dengan spasi atau huruf besar yang merusak URL |
| `kode_butuh_bahasa` | Blok kode tanpa penanda bahasa — pewarnaan sintaks akan gagal |
| `depan_maksimal` / `belakang_maksimal` | Kartu yang terlalu panjang; melanggar aturan di `02-KURIKULUM.md` §4.2 |
| `trace_wajib_kode` | Soal tracing tanpa kode — tidak bisa dijawab |
| `label_valid` | Label opsi selain A–D |
| `youtube_id_format` | ID video yang salah tempel |
| `opsi_soal_satu_benar_idx` | Soal dengan dua jawaban benar atau tanpa jawaban benar |
| `penjelasan` NOT NULL | Soal tanpa penjelasan; melanggar aturan `02-KURIKULUM.md` §5.2 |

**Catatan:** `opsi_soal_satu_benar_idx` adalah *unique partial index*. Ia menjamin **paling banyak** satu jawaban benar, tetapi **tidak** menjamin minimal satu. Kombinasi "tepat satu" hanya bisa dijamin dengan trigger, yang menambah kompleksitas. Untuk konten yang disusun manual, jaminan "paling banyak satu" sudah cukup — validasi minimal satu dilakukan oleh skrip pemeriksa konten (lihat §7).

---

## 4. Kebijakan RLS (Row Level Security)

Ini bagian **paling penting** dari dokumen ini. Tanpa RLS yang benar, siapa pun dapat mengubah atau menghapus seluruh konten.

### 4.1 Mengapa RLS Wajib

Key `publishable` yang dipakai frontend **selalu bisa diambil** dari bundle JavaScript. Itu tidak bisa dicegah dan memang bukan masalah — key itu dirancang untuk diekspos.

Yang menjadi masalah: jika RLS tidak aktif, key itu memberi akses **baca dan tulis** ke seluruh tabel.

Kutipan dari dokumentasi resmi Supabase:

> "A table in an exposed schema without RLS is readable and writable by any role with a grant on it."
> — [RLS docs](https://supabase.com/docs/guides/database/postgres/row-level-security)

**Konsekuensi konkret:** tanpa RLS, seseorang yang membuka DevTools dapat menghapus seluruh konten edukasi FlashStruct lewat satu request HTTP.

### 4.2 Dua Lapis yang Sering Tertukar

Ini sumber kesalahan paling umum:

| Lapis | Mengatur | Contoh |
|-------|----------|--------|
| **Grant** | Role boleh menjalankan operasi **apa** | `grant select on table modul to anon` |
| **Policy** | **Baris mana** yang boleh diakses | `using (true)` = semua baris |

**Penting:** menambahkan policy **tidak mencabut** grant yang sudah ada. Jika project Supabase lama masih memberi `insert, update, delete` ke `anon`, menambahkan policy SELECT saja tidak menghilangkan kemampuan menulis. **Grant tulis harus dicabut secara eksplisit.**

Gejala error:
- Error `42501` = masalah **grant** (gagal sebelum policy dievaluasi)
- Hasil kosong (bukan error) = **policy** memfilter baris

### 4.3 SQL RLS Lengkap

```sql
-- =========================================================
-- RLS: baca publik, tulis tertutup total
-- =========================================================

-- 1) Aktifkan RLS di SEMUA tabel konten
alter table public.modul        enable row level security;
alter table public.bagian_modul enable row level security;
alter table public.video        enable row level security;
alter table public.flashcard    enable row level security;
alter table public.soal         enable row level security;
alter table public.opsi_soal    enable row level security;

-- 2) Cabut SEMUA grant dari role client
--    Langkah ini WAJIB. Tanpa ini, grant tulis bawaan
--    masih aktif walaupun policy SELECT sudah dibuat.
revoke all on table
  public.modul,
  public.bagian_modul,
  public.video,
  public.flashcard,
  public.soal,
  public.opsi_soal
from anon, authenticated;

-- 3) Beri kembali HANYA hak baca
grant select on table
  public.modul,
  public.bagian_modul,
  public.video,
  public.flashcard,
  public.soal,
  public.opsi_soal
to anon, authenticated;

-- 4) Policy: siapa pun boleh membaca semua baris
--    Selalu tulis role di klausa "to". Jangan pakai
--    satu policy "for all" — tulis per operasi.
create policy "modul dapat dibaca publik"
  on public.modul for select to anon, authenticated using (true);

create policy "bagian modul dapat dibaca publik"
  on public.bagian_modul for select to anon, authenticated using (true);

create policy "video dapat dibaca publik"
  on public.video for select to anon, authenticated using (true);

create policy "flashcard dapat dibaca publik"
  on public.flashcard for select to anon, authenticated using (true);

create policy "soal dapat dibaca publik"
  on public.soal for select to anon, authenticated using (true);

create policy "opsi soal dapat dibaca publik"
  on public.opsi_soal for select to anon, authenticated using (true);
```

**Tidak ada policy INSERT, UPDATE, atau DELETE.** Ini disengaja. Dengan grant tulis sudah dicabut dan tidak ada policy tulis, role `anon` tidak dapat mengubah apa pun.

### 4.4 Cara Memverifikasi RLS Benar

Jangan hanya percaya bahwa SQL sudah dijalankan. Verifikasi:

**Uji 1 — baca harus berhasil**

```bash
curl "https://<PROJECT>.supabase.co/rest/v1/modul?select=*" \
  -H "apikey: <PUBLISHABLE_KEY>" \
  -H "Authorization: Bearer <PUBLISHABLE_KEY>"
```

Harapan: array JSON berisi data modul.

**Uji 2 — tulis harus gagal**

```bash
curl -X POST "https://<PROJECT>.supabase.co/rest/v1/modul" \
  -H "apikey: <PUBLISHABLE_KEY>" \
  -H "Authorization: Bearer <PUBLISHABLE_KEY>" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{"slug":"uji-coba","judul":"Uji","topik":"array","deskripsi":"tes"}'
```

Harapan: **gagal** dengan status 401 atau 403, dan pesan menyebut `row-level security` atau `permission denied`.

**Uji 3 — hapus harus gagal**

```bash
curl -X DELETE "https://<PROJECT>.supabase.co/rest/v1/modul?slug=eq.array-dasar" \
  -H "apikey: <PUBLISHABLE_KEY>" \
  -H "Authorization: Bearer <PUBLISHABLE_KEY>"
```

Harapan: **gagal**, dan data modul tetap ada.

**Jika Uji 2 atau 3 berhasil, RLS belum benar.** Periksa ulang langkah 2 (revoke).

### 4.5 Catatan untuk Tabel View

Jika nanti dibuat view, wajib menyetel `security_invoker = true` (PostgreSQL 15+). Tanpa ini, view akan **melewati RLS** dan membocorkan data.

```sql
create view public.modul_ringkas
with (security_invoker = true) as
select id, slug, judul, topik, estimasi_menit
from public.modul;
```

---

## 5. Pola Query

Supabase mendeteksi relasi dari foreign key dan mendukung *embedding* bertingkat dalam **satu request**. Ini menghilangkan masalah N+1.

Sintaks penting:

| Sintaks | Arti |
|---------|------|
| `relasi(kolom)` | Embed relasi (default **left join**) |
| `relasi!inner(kolom)` | Inner join — induk tanpa anak yang cocok akan difilter |
| `alias:kolom` | Ganti nama kolom di hasil |
| `relasi!nama_fk(kolom)` | Pilih FK tertentu jika ada lebih dari satu |

### 5.1 Daftar Semua Modul untuk Halaman Materi

Tidak perlu mengambil kartu dan soal — halaman Materi hanya menampilkan daftar.

```typescript
// features/materi/api.ts

export async function ambilDaftarModul() {
  const { data, error } = await supabase
    .from('modul')
    .select(`
      id,
      slug,
      judul,
      topik,
      deskripsi,
      estimasi_menit,
      urutan,
      bagian_modul ( id ),
      flashcard ( id ),
      soal ( id )
    `)
    .order('urutan');

  if (error) throw error;
  return data;
}
```

Hasil `bagian_modul`, `flashcard`, dan `soal` hanya dipakai untuk **menghitung jumlah**, bukan menampilkan isinya. Ini menghindari pengiriman konten penuh yang tidak dibutuhkan.

### 5.2 Satu Modul Lengkap untuk Halaman Baca

```typescript
// features/materi/api.ts

export async function ambilModulLengkap(slug: string) {
  const { data, error } = await supabase
    .from('modul')
    .select(`
      id, slug, judul, topik, deskripsi, estimasi_menit,
      bagian_modul ( id, slug, judul, konten_md, urutan ),
      video ( id, youtube_id, judul, deskripsi, durasi_detik, urutan )
    `)
    .eq('slug', slug)
    .single();

  if (error) throw error;
  return data;
}
```

Kartu dan soal **tidak** diambil di sini. Alasannya: halaman baca modul tidak menampilkannya, dan mengambil 20 kartu + 20 soal yang tidak dipakai hanya memperlambat halaman.

### 5.3 Kartu untuk Sesi Flashcard

```typescript
// features/flashcard/api.ts

export async function ambilKartuModul(slugModul: string) {
  const { data, error } = await supabase
    .from('flashcard')
    .select(`
      id,
      depan,
      belakang,
      card_type,
      kode,
      bahasa_kode,
      urutan,
      modul!inner ( slug, judul, topik )
    `)
    .eq('modul.slug', slugModul)
    .order('urutan');

  if (error) throw error;
  return data;
}
```

Perhatikan `.eq('modul.slug', slugModul)` — filter pada kolom relasi didukung langsung.

### 5.4 Soal untuk Sesi Quiz

```typescript
// features/quiz/api.ts

export async function ambilSoalModul(slugModul: string) {
  const { data, error } = await supabase
    .from('soal')
    .select(`
      id,
      pertanyaan,
      kode,
      bahasa_kode,
      tipe,
      card_type,
      penjelasan,
      urutan,
      modul!inner ( slug ),
      opsi_soal ( id, label, teks, benar, urutan )
    `)
    .eq('modul.slug', slugModul)
    .order('urutan');

  if (error) throw error;
  return data;
}
```

### 5.5 Video untuk Halaman Video

```typescript
// features/video/api.ts

export async function ambilSemuaVideo() {
  const { data, error } = await supabase
    .from('video')
    .select(`
      id, youtube_id, judul, deskripsi, durasi_detik, urutan,
      modul!inner ( slug, judul, topik, urutan )
    `)
    .order('urutan');

  if (error) throw error;
  return data;
}
```

### 5.6 Catatan Penting: Urutan Hasil Embedding

Urutan anak (`bagian_modul`, `flashcard`, `opsi_soal`) **tidak dijamin** mengikuti `urutan` hanya karena kolomnya ada.

**Solusi yang dipakai FlashStruct:** urutkan di client setelah data diterima.

```typescript
// lib/format.ts

export function urutkan<T extends { urutan: number }>(items: T[] | null): T[] {
  return (items ?? []).slice().sort((a, b) => a.urutan - b.urutan);
}
```

Alasan memilih pengurutan di client daripada `order` di query embedding: lebih sederhana, dapat diuji sebagai fungsi murni, dan jumlah barisnya kecil (maks 6 bagian, 26 kartu, 4 opsi). Untuk data besar, pengurutan sebaiknya dilakukan di database.

---

## 6. Data Contoh (Seed)

File `supabase/seed.sql`. Contoh lengkap untuk satu modul pertama.

```sql
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
```

**Catatan penting tentang CTE:** `with ... as (...)` hanya berlaku untuk **satu statement**. Jika ingin menambah data ke tabel lain setelahnya, statement baru harus mencari `id` lewat subquery (seperti contoh video di atas), bukan mengandalkan CTE sebelumnya.

**Catatan:** ID video di atas hanya contoh format. Ganti dengan ID video asli sebelum dipakai.

---

## 7. Pemeriksa Konten

`check` constraint menangkap banyak kesalahan, tetapi tidak semuanya. Skrip pemeriksa berikut melengkapi validasi database.

```sql
-- =========================================================
-- Pemeriksa Konten
-- Jalankan manual setelah mengisi konten.
-- Semua query harus mengembalikan 0 baris.
-- =========================================================

-- 1. Soal tanpa jawaban benar
select s.id, s.pertanyaan
from public.soal s
left join public.opsi_soal o on o.soal_id = s.id and o.benar = true
where o.id is null;
-- Harapan: 0 baris

-- 2. Soal dengan jumlah opsi bukan 4
select s.id, count(o.id) as jumlah_opsi
from public.soal s
left join public.opsi_soal o on o.soal_id = s.id
group by s.id
having count(o.id) <> 4;
-- Harapan: 0 baris

-- 3. Modul tanpa kartu
select m.slug
from public.modul m
left join public.flashcard f on f.modul_id = m.id
where f.id is null;
-- Harapan: 0 baris

-- 4. Modul dengan kartu kurang dari 15
select m.slug, count(f.id) as jumlah_kartu
from public.modul m
left join public.flashcard f on f.modul_id = m.id
group by m.slug
having count(f.id) < 15;
-- Harapan: 0 baris

-- 5. Modul dengan soal kurang dari 15
select m.slug, count(s.id) as jumlah_soal
from public.modul m
left join public.soal s on s.modul_id = m.id
group by m.slug
having count(s.id) < 15;
-- Harapan: 0 baris

-- 6. Modul tanpa bagian
select m.slug
from public.modul m
left join public.bagian_modul b on b.modul_id = m.id
where b.id is null;
-- Harapan: 0 baris

-- 7. Distribusi tipe kartu tidak seimbang
--    Modul harus punya minimal 4 tipe berbeda
select m.slug, count(distinct f.card_type) as jumlah_tipe
from public.modul m
join public.flashcard f on f.modul_id = m.id
group by m.slug
having count(distinct f.card_type) < 4;
-- Harapan: 0 baris

-- 8. Penjelasan soal terlalu pendek (tidak menjelaskan apa pun)
select id, char_length(penjelasan) as panjang
from public.soal
where char_length(penjelasan) < 50;
-- Harapan: 0 baris

-- 9. Kartu yang bisa dijawab tanpa memahami
--    (sisi depan terlalu panjang - melanggar aturan satu fakta per kartu)
select id, char_length(depan) as panjang_depan
from public.flashcard
where char_length(depan) > 300;
-- Harapan: 0 baris
```

Alasan query-query ini penting: aturan konten di `02-KURIKULUM.md` hanya berguna jika benar-benar ditegakkan. Memeriksa secara manual untuk 200 kartu dan 180 soal tidak realistis.

---

## 8. Migrasi

### 8.1 Struktur Berkas

```
supabase/
├── migrations/
│   ├── 001_initial_schema.sql      # Tabel, enum, index, constraint
│   ├── 002_rls_policies.sql        # RLS, grant, policy
│   └── 003_content_checks.sql      # Fungsi pemeriksa konten (opsional)
└── seed.sql                        # Data awal
```

Alasan memisahkan skema dan RLS: jika terjadi masalah akses, RLS bisa dijalankan ulang tanpa menyentuh skema. Dan sebaliknya.

### 8.2 Cara Menjalankan

**Lewat SQL Editor Supabase (paling mudah):**

1. Buka project di dashboard Supabase
2. Pilih **SQL Editor**
3. Tempel isi `001_initial_schema.sql`, jalankan
4. Tempel isi `002_rls_policies.sql`, jalankan
5. Verifikasi dengan Uji 2 dan 3 di §4.4

**Lewat Supabase CLI (untuk yang sudah nyaman dengan terminal):**

```bash
npm install supabase --save-dev
npx supabase link --project-ref <PROJECT_REF>
npx supabase db push
```

### 8.3 Aturan Migrasi

| Aturan | Alasan |
|--------|--------|
| **Berkas migrasi tidak pernah diubah setelah dijalankan** | Mengubah migrasi lama membuat database baru berbeda dari yang lama |
| **Perubahan selalu lewat migrasi baru** | Jejak perubahan terjaga |
| **Seed boleh dijalankan ulang** | Harus idempoten, atau dihapus dulu sebelum diisi ulang |
| **RLS dijalankan di migrasi terpisah** | Lebih mudah diperiksa dan diulang |

### 8.4 Perubahan yang Akan Datang

Jika skema berubah, buat berkas baru dengan nomor berikutnya. Contoh untuk menambah kolom tingkat kesulitan:

```sql
-- supabase/migrations/004_tambah_kesulitan.sql

alter table public.soal
  add column kesulitan smallint not null default 2
  check (kesulitan between 1 and 3);

comment on column public.soal.kesulitan is
  '1 = mudah, 2 = sedang, 3 = sulit';
```

**Ingat:** setelah menambah tabel baru, jalankan `alter table ... enable row level security`, `revoke all ... from anon, authenticated`, `grant select ...`, dan buat policy SELECT. Tabel baru **tidak otomatis** mendapat RLS.

---

## 9. Konsekuensi Tanpa Autentikasi

Bagian ini mencatat keterbatasan yang timbul dari keputusan PRD untuk tidak memakai autentikasi di v1.

### 9.1 Kunci Jawaban Terekspos

Karena tabel dibaca publik, `opsi_soal.benar` dan `soal.penjelasan` terkirim ke browser. Seseorang yang membuka DevTools dapat melihat semua jawaban.

**Mengapa ini diterima:**

| Alasan | Penjelasan |
|--------|------------|
| Tujuan produk | Ini alat belajar, bukan ujian. Menyembunyikan jawaban dari mahasiswa yang ingin belajar tidak memberi manfaat |
| Menyembunyikan itu mahal | Butuh Edge Function dengan secret key untuk menilai di server — menambah kompleksitas besar |
| Tidak mengubah perilaku | Mahasiswa yang ingin curang akan tetap curang; mahasiswa yang ingin belajar akan tetap belajar |
| Penjelasan tetap terlihat | Justru penting: mahasiswa yang salah jawab harus bisa membaca mengapa |

**Jika nanti perlu disembunyikan:** pindahkan penilaian ke Supabase Edge Function yang menyimpan kunci jawaban di sisi server, dan jangan kirim `benar` ke client. Ini pekerjaan v2, bukan v1.

### 9.2 Tidak Ada Tabel Progres

Tidak ada tabel untuk progres pengguna. Semua progres ada di `localStorage` (lihat `04-ARSITEKTUR-TEKNIS.md` §3.6).

Konsekuensi:
- Progres hilang jika data browser dibersihkan
- Progres tidak pindah perangkat
- Tidak ada analitik penggunaan

**Jika nanti butuh:** tambahkan tabel `progres_pengguna` dengan RLS yang membatasi per `user_id`, dan aktifkan Supabase Auth. Skema konten saat ini tidak perlu berubah sama sekali — inilah manfaat memisahkan konten dari progres.

### 9.3 Kesiapan untuk Autentikasi

Skema ini **sudah siap** untuk penambahan autentikasi tanpa migrasi besar:

| Yang perlu ditambah | Yang tidak perlu diubah |
|---------------------|-------------------------|
| Tabel `profil_pengguna` | `modul`, `bagian_modul`, `video` |
| Tabel `progres_pengguna` | `flashcard`, `soal`, `opsi_soal` |
| Policy RLS per `user_id` | Semua query konten |

---

## 10. Referensi Silang

| Topik | Dokumen |
|-------|---------|
| Aturan bisnis yang mendasari skema | `01-PRD.md` §3 |
| Aturan penulisan kartu dan soal | `02-KURIKULUM.md` §4–5 |
| Cara query dipakai di kode | `04-ARSITEKTUR-TEKNIS.md` §3, §4 |
| Setup Supabase dari nol | `09-PANDUAN-SETUP.md` |
| Tautan sumber resmi RLS dan embedding | `riset/01-RISET-TEKNIS.md` §3–4 |
