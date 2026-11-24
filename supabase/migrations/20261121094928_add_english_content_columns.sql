-- Keep the Indonesian source columns intact and store parallel English copy.
alter table public.modul
  add column judul_en text,
  add column deskripsi_en text;

alter table public.bagian_modul
  add column judul_en text,
  add column konten_md_en text;

alter table public.video
  add column judul_en text,
  add column deskripsi_en text;

alter table public.flashcard
  add column depan_en text,
  add column belakang_en text;

alter table public.soal
  add column pertanyaan_en text,
  add column penjelasan_en text;

alter table public.opsi_soal
  add column teks_en text;
