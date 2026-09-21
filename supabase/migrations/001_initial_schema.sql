-- =========================================================
-- FlashStruct — Skema Awal (001)
--
-- CARA PAKAI:
--   1. Buka project Supabase Anda
--   2. Klik "SQL Editor" di sidebar kiri
--   3. Klik "New query"
--   4. Salin SELURUH isi file ini
--   5. Tempel dan klik Run
--
-- File ini hanya membuat tabel, index, dan constraint.
-- RLS ada di file terpisah: 002_rls_policies.sql
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
  kode        text,
  bahasa_kode bahasa_kode,
  urutan      int not null default 0,

  constraint kode_butuh_bahasa
    check (kode is null or bahasa_kode is not null),

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
  kode        text,
  bahasa_kode bahasa_kode,
  tipe        tipe_soal not null,
  card_type   tipe_kartu not null,
  penjelasan  text not null,
  urutan      int not null default 0,

  constraint soal_kode_butuh_bahasa
    check (kode is null or bahasa_kode is not null),

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

create unique index opsi_soal_satu_benar_idx
  on public.opsi_soal (soal_id)
  where benar = true;


-- =========================================================
-- VERIFIKASI
-- Jalankan query ini untuk memastikan semua tabel dibuat.
-- Harapan: 6 tabel.
-- =========================================================

-- select table_name
-- from information_schema.tables
-- where table_schema = 'public'
-- order by table_name;
