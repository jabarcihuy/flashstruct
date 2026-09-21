-- =========================================================
-- FlashStruct — RLS & Keamanan (002)
--
-- CARA PAKAI:
--   1. Jalankan 001_initial_schema.sql DULU
--   2. Buka SQL Editor di Supabase
--   3. Salin SELURUH isi file ini
--   4. Tempel dan klik Run
--
-- Setelah menjalankan ini, WAJIB uji keamanan:
--   Uji tulis harus GAGAL. Kalau berhasil, database terbuka.
--   Caranya ada di docs/15-SETUP-SUPABASE-UNTUK-ANDA.md §6
--
-- Rincian kenapa RLS wajib: docs/16-KENAPA-RLS-WAJIB.md
-- =========================================================

-- =========================================================
-- 1) Aktifkan RLS di SEMUA tabel konten
-- =========================================================

alter table public.modul        enable row level security;
alter table public.bagian_modul enable row level security;
alter table public.video        enable row level security;
alter table public.flashcard    enable row level security;
alter table public.soal         enable row level security;
alter table public.opsi_soal    enable row level security;


-- =========================================================
-- 2) Cabut SEMUA grant dari role publik
--
-- LANGKAH INI WAJIB DAN SERING DILEWATKAN.
-- Menambah policy TIDAK mencabut grant yang sudah ada.
-- Tanpa langkah ini, role anon masih bisa menulis.
-- =========================================================

revoke all on table
  public.modul,
  public.bagian_modul,
  public.video,
  public.flashcard,
  public.soal,
  public.opsi_soal
from anon, authenticated;


-- =========================================================
-- 3) Beri HANYA hak baca
--
-- grant usage on schema diperlukan agar role bisa "melihat"
-- schema public sama sekali. Tanpa ini, request bisa gagal
-- dengan error yang membingungkan.
-- =========================================================

grant usage on schema public to anon, authenticated;

grant select on table
  public.modul,
  public.bagian_modul,
  public.video,
  public.flashcard,
  public.soal,
  public.opsi_soal
to anon, authenticated;


-- =========================================================
-- 4) Policy: siapa pun boleh MEMBACA semua baris
--
-- Perhatikan: HANYA policy SELECT.
-- Tidak ada policy INSERT, UPDATE, atau DELETE.
--
-- JANGAN pakai "for all" — itu akan mengizinkan tulis.
-- Selalu tulis nama role di klausa "to".
-- =========================================================

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


-- =========================================================
-- VERIFIKASI
-- Jalankan query ini untuk memastikan RLS aktif di semua tabel.
-- Harapan: 6 baris, semuanya rls_aktif = true
-- =========================================================

-- select
--   tablename,
--   rowsecurity as rls_aktif
-- from pg_tables
-- where schemaname = 'public'
-- order by tablename;

-- Cek policy yang terpasang (harapan: 6 policy, semua cmd = SELECT)
-- select
--   tablename,
--   policyname,
--   cmd
-- from pg_policies
-- where schemaname = 'public'
-- order by tablename;
