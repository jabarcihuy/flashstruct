# 01 — Riset Teknis: Supabase & Deployment Web App React (FlashStruct)

> **Tanggal riset:** 21 September 2026 (UTC)
> **Metode:** Semua klaim diambil dari sumber primer (dokumentasi resmi Supabase, Vercel, Netlify, GitHub, Vite, React Router, PostgreSQL, npm registry). Setiap klaim disertai tautan sumber. Hal yang tidak dapat diverifikasi dicatat di section terakhir.
> **Konteks proyek:** FlashStruct — React (Vite + TypeScript), konten edukasi (modul, flashcard, quiz) di Supabase, tanpa login user, progres di localStorage. Supabase hanya dipakai sebagai content database read-only dari sisi client.

---

## Catatan Penamaan Tabel: Contoh vs Skema Final

**Baca ini lebih dulu agar tidak bingung.**

Dokumen ini berisi **contoh** SQL dan query yang diambil langsung dari dokumentasi resmi Supabase. Contoh-contoh itu memakai nama tabel **bahasa Inggris** (`modules`, `lessons`, `flashcards`, `quiz_questions`, `quiz_options`).

Skema final FlashStruct memakai nama **bahasa Indonesia**, sesuai istilah domain yang dipakai di seluruh dokumen proyek.

**Pemetaannya:**

| Contoh di riset ini | Skema final FlashStruct | Berkas definisi |
|---------------------|-------------------------|-----------------|
| `modules` | `modul` | `05-SKEMA-DATABASE.md` §3 |
| `lessons` | `bagian_modul` | `05-SKEMA-DATABASE.md` §3 |
| `flashcards` | `flashcard` | `05-SKEMA-DATABASE.md` §3 |
| `quiz_questions` | `soal` | `05-SKEMA-DATABASE.md` §3 |
| `quiz_options` | `opsi_soal` | `05-SKEMA-DATABASE.md` §3 |
| — | `video` | Tidak ada padanan di contoh riset |

**Aturan pembacaan:**

- Bagian §3 (RLS) dan §4 (skema) di dokumen ini memakai **contoh bahasa Inggris** karena diambil langsung dari dokumentasi Supabase. **Yang dipakai proyek adalah versi bahasa Indonesia** di `05-SKEMA-DATABASE.md`.
- Perbedaan nama kolom juga ada: riset memakai `title`, `content_md`, `position`; skema final memakai `judul`, `konten_md`, `urutan`.
- **Yang bisa dipakai langsung dari riset ini:** sintaks query embedding (§4.3), cara kerja RLS (§3), pola grant/revoke, dan semua tautan sumber resmi. Ganti saja nama tabelnya.

**Mengapa tidak diseragamkan?** Mengubah contoh di dokumen riset akan membuatnya tidak lagi cocok dengan kutipan dokumentasi resmi yang disitir. Riset harus tetap setia pada sumbernya; skema final harus setia pada istilah domain proyek. Catatan pemetaan ini menjembatani keduanya.

---

## 1. Supabase Free Tier (2026)

### 1.1 Batasan free tier

Berdasarkan halaman harga resmi Supabase (diakses 21 Sep 2026):

| Item | Batasan Free Plan | Sumber |
|---|---|---|
| API request | **Unlimited API requests** | [supabase.com/pricing](https://supabase.com/pricing) |
| Ukuran database | **500 MB per project** (Shared CPU, 500 MB RAM) | [supabase.com/pricing](https://supabase.com/pricing) |
| Egress (bandwidth keluar) | **5 GB/bulan**, plus 5 GB cached egress | [supabase.com/pricing](https://supabase.com/pricing) |
| File storage | 1 GB | [supabase.com/pricing](https://supabase.com/pricing) |
| Jumlah project | **Limit 2 active projects** (project paused tidak dihitung; bisa punya banyak project paused) | [supabase.com/pricing](https://supabase.com/pricing), [Pricing FAQ](https://supabase.com/pricing) |
| MAU (Auth) | 50.000 — tidak relevan untuk FlashStruct (tanpa login) | [supabase.com/pricing](https://supabase.com/pricing) |
| Edge Function invocations | 500.000/bulan | [supabase.com/pricing](https://supabase.com/pricing) |
| Realtime | 200 concurrent peak connections, 2 juta pesan/bulan | [supabase.com/pricing](https://supabase.com/pricing) |
| Log retention | 1 hari | [supabase.com/pricing](https://supabase.com/pricing) |
| Backup | **Tidak termasuk** (backup tidak bisa diunduh di Free Plan) | [supabase.com/pricing](https://supabase.com/pricing), [Production Checklist](https://supabase.com/docs/guides/platform/going-into-prod) |
| Support | Community support | [supabase.com/pricing](https://supabase.com/pricing) |

Catatan teknis:

- "Unlimited API requests" berlaku untuk semua plan termasuk Free — [supabase.com/pricing](https://supabase.com/pricing).
- Free Plan tetap tunduk pada perlindungan abuse/rate limit platform. Dokumentasi menyebut Supabase "employs a number of safeguards against bursts of incoming traffic" — [Production Checklist](https://supabase.com/docs/guides/platform/going-into-prod). Angka rate limit untuk Data API tidak dipublikasikan secara detail (lihat Catatan Ketidakpastian).

### 1.2 Pausing karena idle — berapa lama?

**Free plan project di-pause otomatis setelah 1 minggu (7 hari) aktivitas rendah** — [supabase.com/pricing](https://supabase.com/pricing), halaman [Project Pausing](https://supabase.com/docs/guides/platform/free-project-pausing).

Detail mekanisme pausing (dari [Project Pausing](https://supabase.com/docs/guides/platform/free-project-pausing)):

- Project dianggap tidak aktif jika tidak menerima aktivitas database yang cukup selama seminggu terakhir.
- "Typically a few user requests to the database each day over the previous week is enough to keep the project from being paused."
- Supabase mengirim **2 email**: (1) peringatan sekitar 1 minggu sebelum pause efektif, (2) konfirmasi setelah project di-pause.
- Pause bisa dicegah dengan membuka project dari Dashboard (menghasilkan aktivitas) atau mengirim API call ke project.
- Project paused bisa di-restore **hingga 1 tahun** setelah pause, dari Dashboard → **Resume project**.
- Project pada paid plan **tidak pernah** di-pause otomatis; upgrade ke Pro untuk menghindari pausing — [Project Pausing](https://supabase.com/docs/guides/platform/free-project-pausing).

**Implikasi untuk FlashStruct:** karena tidak ada traffic saat libur kuliah/masa tidak aktif, project Free Plan akan kena pause. Solusinya: (a) unpause manual dari Dashboard saat mau dipakai, (b) buat "ping" berkala ke database (misalnya cron sederhana / health check dari aplikasi), atau (c) upgrade ke Pro. Halaman pausing resmi menyatakan "a few user requests to the database each day" sudah cukup — [Project Pausing](https://supabase.com/docs/guides/platform/free-project-pausing).

> Ada inkonsistensi kecil di dokumentasi: teks halaman menyebut jendela restore "1-year window", sedangkan anchor heading-nya bernama `#90-day-window-to-restore`. Yang tertulis di body teks adalah **1 tahun** — lihat Catatan Ketidakpastian.

---

## 2. Supabase Client SDK untuk React

### 2.1 Package npm

- Package: **`@supabase/supabase-js`** — [React Quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/reactjs).
- Versi terbaru saat riset: **2.116.0** (dipublikasikan di npm; diverifikasi langsung dari metadata registry `https://registry.npmjs.org/@supabase/supabase-js/latest` pada 21 Sep 2026).
- `engines.node` pada package versi 2.116.0: **`>=22.0.0`** (metadata npm registry).
- SDK mendukung browser modern yang punya `fetch` native; Node.js yang didukung hanya versi Active LTS/Maintenance, dan **dukungan Node.js 20 di-drop sejak versi 2.110.0** — [README resmi supabase-js](https://github.com/supabase/supabase-js/blob/master/packages/core/supabase-js/README.md).
- Instalasi: `npm install @supabase/supabase-js` — [React Quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/reactjs).

### 2.2 Inisialisasi client di React/Vite (contoh minimal)

Pola resmi dari [React Quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/reactjs), diadaptasi ke TypeScript:

```bash
npm create vite@latest my-app -- --template react-ts
cd my-app && npm install @supabase/supabase-js
```

`src/lib/supabaseClient.ts`:

```ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabasePublishableKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY

export const supabase = createClient(supabaseUrl, supabasePublishableKey)
```

Pemakaian di komponen:

```tsx
import { useEffect, useState } from 'react'
import { supabase } from './lib/supabaseClient'

function App() {
  const [modules, setModules] = useState<{ id: string; title: string }[]>([])

  useEffect(() => {
    supabase
      .from('modules')
      .select('id, title')
      .then(({ data, error }) => {
        if (error) {
          console.error(error)
          return
        }
        setModules(data)
      })
  }, [])

  return <ul>{modules.map((m) => <li key={m.id}>{m.title}</li>)}</ul>
}
```

Sumber pola `createClient` + query `.from().select()`: [React Quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/reactjs) dan [README supabase-js](https://github.com/supabase/supabase-js/blob/master/packages/core/supabase-js/README.md).

### 2.3 Environment variable & aturan prefix `VITE_`

Nama variabel yang dipakai quickstart resmi Supabase untuk Vite — [React Quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/reactjs):

```text
# .env.local
VITE_SUPABASE_URL=https://<project-ref>.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

Aturan Vite — [Vite: Env Variables and Modes](https://vite.dev/guide/env-and-mode):

- Vite mengekspos env var ke client lewat objek **`import.meta.env`**.
- **Hanya variabel dengan prefix `VITE_`** yang di-bundle dan tersedia di source code client. Contoh: `VITE_SOME_KEY` terekspos, `DB_PASSWORD` menjadi `undefined` di client.
- Variabel di-inline **saat build time** — nilainya harus ada saat `vite build`, bukan saat runtime server.
- File `.env`, `.env.local`, `.env.[mode]`, `.env.[mode].local` didukung; `.env.[mode]` menang atas `.env`; restart dev server setelah mengubah `.env`.
- Vite memperingatkan: "`VITE_*` variables should *not* contain sensitive information such as API keys." **Publishable key Supabase adalah pengecualian yang didesain publik**, tetapi **secret key tidak boleh** diberi prefix `VITE_` (lihat 2.4).
- Untuk IntelliSense TypeScript, augment `ImportMetaEnv` di `src/vite-env.d.ts` — [Vite docs](https://vite.dev/guide/env-and-mode):

```ts
interface ImportMetaEnv {
  readonly VITE_SUPABASE_URL: string
  readonly VITE_SUPABASE_PUBLISHABLE_KEY: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
```

> Catatan 2026: dokumentasi terbaru memakai **`VITE_SUPABASE_PUBLISHABLE_KEY`** (key `sb_publishable_...`), bukan `VITE_SUPABASE_ANON_KEY` lama. Nama lama hanya relevan untuk project yang masih memakai legacy JWT `anon` key.

### 2.4 Apakah `anon` key aman diekspos di frontend?

**Ya — dengan syarat RLS aktif dan yang diekspos adalah publishable key (pengganti resmi `anon` key), bukan secret key.** Dasar dari [API Keys docs](https://supabase.com/docs/guides/api/api-keys):

- Tabel pemilihan key resmi: untuk "Anything you ship: browser, mobile app, CLI, script" → gunakan **Publishable key**, "Because: Anyone can read it, so it only reaches what Row Level Security allows".
- Publishable key (`sb_publishable_...`) dideskripsikan: "**Safe to expose online**: web page, mobile or desktop app, GitHub actions, CLIs, source code."
- Sebaliknya, **Secret key** (`sb_secret_...`) "provides full access to your project's data, **bypassing Row Level Security**" dan "must never leave your control". Secret key bahkan diblokir dari browser (HTTP 401 berdasar User-Agent).
- Key memetakan ke Postgres role: publishable key tanpa user login → role **`anon`**; publishable key + user login → `authenticated`; secret key → `service_role` (BYPASSRLS) — [API Keys docs](https://supabase.com/docs/guides/api/api-keys).
- Alasan amannya: "Row Level Security decides what this client can reach, so enable it on every table before you deploy" — [API Keys docs](https://supabase.com/docs/guides/api/api-keys).
- Publishable key **bukan** proteksi terhadap: reverse engineering, Network inspector, CSRF/XSS, MITM. Proteksi data bertumpu pada RLS + role `anon`/`authenticated` — [API Keys docs, "What publishable keys don't protect against"](https://supabase.com/docs/guides/api/api-keys).
- **Deprecation penting:** "Supabase is deprecating the `anon` and `service_role` keys **by the end of 2026**. Use the publishable (`sb_publishable_xxx`) and secret (`sb_secret_xxx`) keys instead." — [API Keys docs](https://supabase.com/docs/guides/api/api-keys). Untuk project baru di 2026, langsung pakai publishable key.

**Untuk FlashStruct (tanpa login):** client hanya memegang publishable key → semua request berjalan sebagai role `anon` → RLS yang membatasi hanya boleh `SELECT`. Tidak ada secret key di aplikasi frontend, sama sekali.

---

## 3. Row Level Security (RLS)

### 3.1 Membuat tabel yang bisa dibaca publik tapi tidak bisa ditulis publik

Pola resmi ada di dua tempat:

1. [React Quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/reactjs) — grant `select` ke `anon`, enable RLS, policy SELECT untuk `anon`.
2. [RLS docs, contoh "announcements"](https://supabase.com/docs/guides/database/postgres/row-level-security) — pola yang lebih ketat: **revoke semua grant dulu, lalu grant hanya `select`**, plus policy SELECT.

Poin krusial dari dokumentasi RLS:

> "A table in an exposed schema without RLS is readable and writable by any role with a grant on it. Enable RLS on every table in an exposed schema. On projects that still grant `anon` and `authenticated` by default, revoke those grants. **Adding policies doesn't remove them.**" — [RLS docs](https://supabase.com/docs/guides/database/postgres/row-level-security)

Artinya: **grant dan policy adalah dua lapis berbeda.**

- Grant menentukan role boleh menjalankan operasi apa (SELECT/INSERT/UPDATE/DELETE) — kalau grant `insert` masih ada, menambah policy saja tidak mencabutnya.
- Policy menentukan baris mana yang boleh diakses.
- Error `42501` = masalah grant (gagal sebelum policy dievaluasi). Hasil kosong = policy memfilter baris — [RLS docs](https://supabase.com/docs/guides/database/postgres/row-level-security).

### 3.2 Contoh policy SQL SELECT-only public access

Contoh ini persis mengikuti pola resmi (perhatikan: revoke semua, grant `select` saja, policy select saja). Contoh dari [RLS docs](https://supabase.com/docs/guides/database/postgres/row-level-security) untuk tabel `announcements`, di sini diterapkan ke tabel konten FlashStruct:

```sql
-- 1) Aktifkan RLS di semua tabel konten
alter table public.modules         enable row level security;
alter table public.lessons         enable row level security;
alter table public.flashcards      enable row level security;
alter table public.quiz_questions  enable row level security;
alter table public.quiz_options    enable row level security;

-- 2) Cabut SEMUA grant dari role client (anon & authenticated)
revoke all on table public.modules, public.lessons, public.flashcards,
                   public.quiz_questions, public.quiz_options
  from anon, authenticated;

-- 3) Beri kembali HANYA hak baca (SELECT)
grant select on table public.modules, public.lessons, public.flashcards,
                       public.quiz_questions, public.quiz_options
  to anon, authenticated;

-- 4) Policy: siapa pun boleh membaca semua baris (read-only)
create policy "public can read modules"
on public.modules for select
to anon, authenticated
using ( true );

create policy "public can read lessons"
on public.lessons for select
to anon, authenticated
using ( true );

create policy "public can read flashcards"
on public.flashcards for select
to anon, authenticated
using ( true );

create policy "public can read quiz questions"
on public.quiz_questions for select
to anon, authenticated
using ( true );

create policy "public can read quiz options"
on public.quiz_options for select
to anon, authenticated
using ( true );
```

Catatan tambahan dari dokumentasi RLS:

- Selalu tulis nama role di klausa `to` (jangan policy tanpa `to`) — [RLS docs](https://supabase.com/docs/guides/database/postgres/row-level-security).
- Jangan pakai satu policy `for all`; tulis policy terpisah per operasi — [RLS docs](https://supabase.com/docs/guides/database/postgres/row-level-security).
- Dokumentasi menyarankan uji policy dengan pgTAP (`supabase test db`) yang memverifikasi allow & deny untuk `anon` dan `authenticated` — [RLS docs](https://supabase.com/docs/guides/database/postgres/row-level-security).
- Karena proyek ini read-only, tidak ada policy INSERT/UPDATE/DELETE sama sekali. Tanpa policy untuk operasi tulis + grant tulis sudah dicabut, role `anon`/`authenticated` **tidak bisa menulis**.
- Kalau memakai view, set `security_invoker = true` (Postgres 15+) atau view akan bypass RLS — [RLS docs](https://supabase.com/docs/guides/database/postgres/row-level-security).

### 3.3 Apa yang terjadi kalau RLS tidak diaktifkan?

Dari sumber resmi:

- [RLS docs](https://supabase.com/docs/guides/database/postgres/row-level-security): "A table in an exposed schema without RLS is **readable and writable by any role with a grant on it**."
- [Production Checklist](https://supabase.com/docs/guides/platform/going-into-prod): "Tables that do not have RLS enabled with reasonable policies **allow any client to access and modify their data**. This is usually not what you want."
- [API Keys docs](https://supabase.com/docs/guides/api/api-keys): "When you use a publishable key, Postgres guards access to your project's data through the built-in `anon` and `authenticated` roles. For full protection, confirm that: You have enabled Row Level Security on all tables..."

**Konsekuensi konkret untuk FlashStruct:** jika RLS tidak diaktifkan dan tabel masih punya grant default (project lama memberi `select, insert, update, delete` ke `anon`), siapa pun yang mengambil publishable key dari bundle JS (yang memang selalu bisa diambil) dapat **membaca, mengubah, dan menghapus seluruh konten edukasi** lewat REST API. Untuk tabel read-only, wajib: enable RLS + revoke grant tulis + policy SELECT saja.

---

## 4. Skema Database untuk Konten Edukasi

### 4.1 Cara menyimpan struktur bertingkat (materi > sub-materi > flashcard/soal)

Rekomendasi berbasis PostgreSQL: gunakan **tabel terpisah per level** dengan **foreign key** (bukan JSON blob), karena:

- PostgREST (Data API Supabase) otomatis mendeteksi relasi dari **foreign key** dan bisa meng-embed resource terkait dalam satu API call — [PostgREST Resource Embedding](https://postgrest.org/en/stable/references/api/resource_embedding.html), [Supabase: Querying Joins and Nested tables](https://supabase.com/docs/guides/database/joins-and-nesting).
- FK menjaga integritas referensial; `ON DELETE CASCADE` menghapus anak saat induk dihapus — [PostgreSQL: Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html).
- Kolom `position` (integer) untuk urutan tampil, `slug` unik untuk URL, `timestamptz default now()` untuk metadata.

### 4.2 Contoh DDL `CREATE TABLE` dengan foreign key

```sql
-- Ekstensi untuk gen_random_uuid() (umumnya sudah aktif di Supabase)
create extension if not exists pgcrypto;

-- =========================================================
-- Level 1: Modul (mis. "Array", "Struct", "Pointer")
-- =========================================================
create table public.modules (
  id          uuid primary key default gen_random_uuid(),
  slug        text not null unique,
  title       text not null,
  description text,
  position    int  not null default 0,
  created_at  timestamptz not null default now()
);

-- =========================================================
-- Level 2: Sub-materi / lesson (anak dari modul)
-- =========================================================
create table public.lessons (
  id         uuid primary key default gen_random_uuid(),
  module_id  uuid not null references public.modules (id) on delete cascade,
  slug       text not null,
  title      text not null,
  content_md text not null,
  position   int  not null default 0,
  created_at timestamptz not null default now(),
  unique (module_id, slug)
);

create index lessons_module_id_idx on public.lessons (module_id, position);

-- =========================================================
-- Level 3a: Flashcard (anak dari lesson)
-- =========================================================
create table public.flashcards (
  id         uuid primary key default gen_random_uuid(),
  lesson_id  uuid not null references public.lessons (id) on delete cascade,
  front      text not null,
  back       text not null,
  position   int  not null default 0
);

create index flashcards_lesson_id_idx on public.flashcards (lesson_id, position);

-- =========================================================
-- Level 3b: Soal quiz (anak dari lesson) + opsi jawaban
-- =========================================================
create table public.quiz_questions (
  id         uuid primary key default gen_random_uuid(),
  lesson_id  uuid not null references public.lessons (id) on delete cascade,
  question   text not null,
  explanation text,
  position   int  not null default 0
);

create index quiz_questions_lesson_id_idx on public.quiz_questions (lesson_id, position);

create table public.quiz_options (
  id          uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.quiz_questions (id) on delete cascade,
  label       text not null,          -- 'A', 'B', 'C', 'D'
  text        text not null,
  is_correct  boolean not null default false,
  position    int not null default 0
);

create index quiz_options_question_id_idx on public.quiz_options (question_id, position);
```

Dasar desain:

- `REFERENCES ... ON DELETE CASCADE`: "CASCADE specifies that when a referenced row is deleted, row(s) referencing it should be automatically deleted as well" — [PostgreSQL: Foreign Keys](https://www.postgresql.org/docs/current/ddl-constraints.html).
- `UNIQUE (module_id, slug)` memakai table constraint untuk kombinasi kolom — [PostgreSQL: Unique Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html).
- Index pada kolom FK disarankan karena FK tidak otomatis membuat index di sisi referencing — [PostgreSQL: Foreign Keys](https://www.postgresql.org/docs/current/ddl-constraints.html).
- Index pada kolom yang dipakai filter RLS disarankan — [RLS docs](https://supabase.com/docs/guides/database/postgres/row-level-security). (Untuk proyek ini policy `using (true)` tidak memfilter kolom, jadi index murni untuk performa join/urutan.)

Setelah DDL di atas, jangan lupa jalankan blok RLS di section 3.2 dan pastikan tabel diekspos oleh Data API (Integrations → Data API; aktifkan **Automatically expose new tables** bila perlu) — [React Quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/reactjs).

### 4.3 Query nested data dengan Supabase client (select + embedding)

Supabase Data API otomatis mendeteksi relasi dari foreign key dan mengizinkan embedding bertingkat dalam satu request — [Supabase: Joins and Nested tables](https://supabase.com/docs/guides/database/joins-and-nesting), [PostgREST: Nested Embedding](https://postgrest.org/en/stable/references/api/resource_embedding.html).

**Contoh 1 — semua modul dengan lesson, flashcard, dan quiz (satu request):**

```ts
import { supabase } from './lib/supabaseClient'

const { data, error } = await supabase
  .from('modules')
  .select(`
    id, slug, title, description, position,
    lessons (
      id, slug, title, content_md, position,
      flashcards ( id, front, back, position ),
      quiz_questions (
        id, question, explanation, position,
        quiz_options ( id, label, text, is_correct, position )
      )
    )
  `)

if (error) throw error
// data: array modul, tiap modul punya array `lessons`, dst.
```

**Contoh 2 — satu sub-materi + flashcard + soal (untuk halaman lesson):**

```ts
const { data, error } = await supabase
  .from('lessons')
  .select(`
    id, slug, title, content_md,
    flashcards ( id, front, back, position ),
    quiz_questions (
      id, question, explanation, position,
      quiz_options ( id, label, text, is_quiz_correct:is_correct, position )
    )
  `)
  .eq('slug', slug)

if (error) throw error
const lesson = data?.[0] ?? null
```

Catatan sintaks embedding (dari [Supabase: Joins and Nested tables](https://supabase.com/docs/guides/database/joins-and-nesting)):

| Sintaks | Arti |
|---|---|
| `relation(columns)` | Embed relasi (default **left join**) |
| `relation!inner(columns)` | **Inner join** — parent tanpa anak yang match akan difilter |
| `alias:relation(columns)` | Rename nama relasi di response (mis. `is_quiz_correct:is_correct`) |
| `relation!fk_name(columns)` | Pilih FK tertentu bila ada lebih dari satu FK antara dua tabel |

- Default embedding = left join: parent tetap muncul walau tidak ada anak; relasi one-to-many menjadi `[]`, many-to-one menjadi `null` — [Supabase docs](https://supabase.com/docs/guides/database/joins-and-nesting).
- Filter pada kolom relasi bisa dilakukan dengan `joined_table.column` (mis. `.eq('flashcards.position', 0)`) — [Supabase docs](https://supabase.com/docs/guides/database/joins-and-nesting).
- Embedded ordering/limit didukung di level URL PostgREST (mis. `?select=...&lessons.order=position`) — [PostgREST: Embedded Filters](https://postgrest.org/en/stable/references/api/resource_embedding.html). Untuk kesederhanaan, urutan juga bisa di-sort di client setelah data diterima.

**Rekomendasi untuk FlashStruct:** karena konten relatif kecil dan read-only, ambil seluruh struktur sekali (Contoh 1) lalu cache di memori/localStorage; hindari N+1 request per lesson. Data di bawah 500 MB akan muat nyaman di Free Plan.

---

## 5. Deployment Frontend

### 5.1 Vercel

**Build & output (auto-detect):**

- Vercel mendeteksi framework Vite dan mengaktifkan setting yang benar secara otomatis — [Vite: Deploying a Static Site](https://vite.dev/guide/static-deploy) ("Vercel will detect that you are using Vite and will enable the correct settings").
- Setting standar Vite: build command `npm run build` (script `vite build`), output `dist` — [Vite: Deploying a Static Site](https://vite.dev/guide/static-deploy).
- Jika perlu override, Vercel menyediakan **Settings → Build and Deployment → Framework Settings**: Framework Preset (ada preset **Vite**), Build Command, Output Directory, Install Command, Root Directory — [Vercel: Configuring a Build](https://vercel.com/docs/builds/configure-a-build).
- "If Vercel detects a framework, the output directory will automatically be configured" — [Vercel: Configuring a Build](https://vercel.com/docs/builds/configure-a-build).

**Environment variables di Vercel:**

- Env var didefinisikan per project/team, per Environment (Production/Preview/Development), terenkripsi at rest; **perubahan hanya berlaku untuk deployment baru** — [Vercel: Environment Variables](https://vercel.com/docs/environment-variables).
- Untuk Vite, akses System/Env Variables saat build memerlukan prefix **`VITE_`** — [Vercel: Vite on Vercel](https://vercel.com/docs/frameworks/frontend/vite) ("To access Vercel's System Environment Variables in Vite during the build process, prefix the variable name with `VITE`").
- Jadi tambahkan `VITE_SUPABASE_URL` dan `VITE_SUPABASE_PUBLISHABLE_KEY` di Project Settings → Environment Variables untuk environment Production (dan Preview bila perlu).
- Lokal: `vercel env pull` membuat `.env` dari Development Environment — [Vercel: Environment Variables](https://vercel.com/docs/environment-variables).

**SPA rewrite (agar refresh React Router tidak 404):**

Buat `vercel.json` di root project — contoh resmi dari [Vercel: Vite on Vercel](https://vercel.com/docs/frameworks/frontend/vite):

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

> Catatan dari docs: "If `cleanUrls` is set to `true` in your project's `vercel.json`, do not include the file extension in the source or destination path. For example, `/index.html` would be `/`" — [Vercel: Vite on Vercel](https://vercel.com/docs/frameworks/frontend/vite).

### 5.2 Netlify

**Build & publish (auto-detect):**

- "If your site is built with Vite, Netlify provides a suggested build command and publish directory: **`npm run build`** or `yarn build` and **`dist`**" — [Netlify: Vite on Netlify](https://docs.netlify.com/build/frameworks/framework-setup-guides/vite/).
- Setting bisa diubah di UI (Project configuration → Developer settings → Continuous deployment → Build settings), lewat `netlify.toml` (`command` dan `publish` di bawah `[build]`), atau via Netlify CLI — [Netlify: Build configuration overview](https://docs.netlify.com/build/configure-builds/overview/).
- Environment variables diatur lewat Netlify UI/CLI (Build environment variables) — [Netlify: Build configuration overview](https://docs.netlify.com/build/configure-builds/overview/) (lihat juga [Build environment variables](https://docs.netlify.com/build/configure-builds/environment-variables/)).

**SPA rewrite:**

"**Avoid 404s for SPAs:** If your project is a single page app (SPA) that uses the history `pushState` method to get clean URLs, you must add a rewrite rule to serve the `index.html` file no matter what URL the browser requests." — [Netlify: Vite on Netlify](https://docs.netlify.com/build/frameworks/framework-setup-guides/vite/).

Opsi A — file `_redirects` di folder publish (`public/` pada Vite, ikut ter-copy ke `dist`):

```text
/*  /index.html  200
```

Opsi B — `netlify.toml` di root repo:

```toml
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

Keduanya dari [Netlify: Rewrites and proxies](https://docs.netlify.com/manage/routing/redirects/rewrites-proxies/). Penjelasan: status `200` = **rewrite** (URL di address bar tetap, konten `index.html` yang disajikan). "This will effectively serve the `index.html` instead of giving a `404` no matter what URL the browser requests." — [Netlify docs](https://docs.netlify.com/manage/routing/redirects/rewrites-proxies/).

### 5.3 GitHub Pages

**Cara deploy (dari [Vite: Deploying a Static Site](https://vite.dev/guide/static-deploy)):**

1. Set `base` di `vite.config.ts`:
   - Deploy ke `https://<USERNAME>.github.io/` atau custom domain → `base: '/'`.
   - Deploy ke `https://<USERNAME>.github.io/<REPO>/` (project site) → `base: '/<REPO>/'`.
2. Di repo: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
3. Buat `.github/workflows/deploy.yml` — contoh resmi dari Vite docs:

```yaml
# Simple workflow for deploying static content to GitHub Pages
name: Deploy static content to Pages

on:
  push:
    branches: ['main']
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: 'pages'
  cancel-in-progress: true

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7
      - name: Set up Node
        uses: actions/setup-node@820762786026740c76f36085b0efc47a31fe5020 # v7
        with:
          node-version: lts/*
          cache: 'npm'
      - name: Install dependencies
        run: npm ci
      - name: Build
        run: npm run build
      - name: Setup Pages
        uses: actions/configure-pages@45bfe0192ca1faeb007ade9deae92b16b8254a0d # v6
      - name: Upload artifact
        uses: actions/upload-pages-artifact@fc324d3547104276b827a68afc52ff2a11cc49c9 # v5
        with:
          path: './dist'
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@368f82528645a54fb793d4d04e342629a3f51346 # v5
```

**Keterbatasan/komplikasi untuk SPA (routing):**

- GitHub Pages adalah **static site hosting** murni: "takes HTML, CSS, and JavaScript files straight from a repository" — [GitHub Docs: What is GitHub Pages?](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages). **Tidak ada dukungan rewrite/redirect server-side** seperti `vercel.json` atau `_redirects`. Jadi deep link seperti `https://user.github.io/repo/modul/array` akan menghasilkan **404** saat refresh/dibuka langsung, karena tidak ada file di path itu.
- Satu-satunya mekanisme fallback yang didokumentasikan GitHub adalah **custom 404 page**: buat file `404.html` di publishing source; GitHub akan menampilkannya untuk path yang tidak ada — [GitHub Docs: Creating a custom 404 page](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-custom-404-page-for-your-github-pages-site). Trik umum "404.html yang me-redirect ke index.html" **tidak didokumentasikan resmi** sebagai solusi SPA (lihat Catatan Ketidakpastian).
- Alternatif yang didukung dokumentasi: gunakan **`HashRouter`** dari React Router — "A declarative `<Router>` that stores the location in the `hash` portion of the URL **so it is not sent to the server**" — [React Router: HashRouter](https://reactrouter.com/api/declarative-routers/HashRouter). Dengan hash routing (`/#/modul/array`), refresh tidak pernah meminta path ke server, sehingga tidak ada 404. Trade-off: URL kurang "bersih" dan tidak ideal untuk SEO.
- Komplikasi tambahan project site: aset akan salah path jika `base` Vite tidak di-set `/<REPO>/` — [Vite docs](https://vite.dev/guide/static-deploy).
- Limit GitHub Pages: **1 GB** ukuran site, **soft bandwidth 100 GB/bulan**, **soft limit 10 builds/jam** (tidak berlaku jika build lewat custom GitHub Actions workflow — seperti contoh di atas), deployment timeout **10 menit**, maksimum satu site per akun (user/org) dan satu per repo — [GitHub Docs: GitHub Pages limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits).
- Untuk situs edukasi ini (bukan bisnis, tidak transaksi), GitHub Pages boleh dipakai selama memenuhi ToS; ada aturan khusus untuk "educational exercises" — [GitHub Docs: GitHub Pages limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits).

**Rekomendasi:** untuk SPA React Router dengan URL bersih, Vercel atau Netlify lebih tepat (rewrite didukung resmi). GitHub Pages cocok hanya jika memakai `HashRouter` atau menerima deep-link 404.

### 5.4 Ringkasan SPA fallback per platform

| Platform | Mekanisme | Snippet | Sumber |
|---|---|---|---|
| Vercel | `rewrites` di `vercel.json` | `{"source":"/(.*)","destination":"/index.html"}` | [Vercel: Vite on Vercel](https://vercel.com/docs/frameworks/frontend/vite) |
| Netlify | `_redirects` atau `netlify.toml` | `/* /index.html 200` | [Netlify: Rewrites and proxies](https://docs.netlify.com/manage/routing/redirects/rewrites-proxies/) |
| GitHub Pages | Tidak ada rewrite; gunakan `HashRouter` atau terima 404 pada deep link | — | [GitHub Docs](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages), [React Router: HashRouter](https://reactrouter.com/api/declarative-routers/HashRouter) |
| Vite `preview` lokal | Bukan production server; hanya untuk cek build | `npm run preview` (default `http://localhost:4173`) | [Vite: Deploying a Static Site](https://vite.dev/guide/static-deploy) |

---

## 6. Alternatif Lokal / Offline

> **Catatan keputusan proyek:** FlashStruct **tidak memakai Docker**. Bagian 6.1 dan 6.2 di bawah dicatat sebagai fakta riset (apa yang didokumentasikan Supabase), tetapi **bukan** pendekatan yang dipakai proyek ini. Pendekatan yang dipakai adalah **PostgreSQL lokal langsung tanpa Docker** — lihat `09-PANDUAN-SETUP.md` §4.

### 6.1 Supabase lokal dengan Supabase CLI + Docker

**Ya, Supabase bisa dijalankan lokal.** Dokumentasi resmi: "The Supabase CLI enables you to run the entire Supabase stack locally, on your machine or in a CI environment. With two commands, you can set up and start a new local project" — [Supabase CLI: Getting Started](https://supabase.com/docs/guides/local-development/cli/getting-started).

**Kendala untuk proyek ini:** pendekatan ini membutuhkan container runtime (Docker atau sejenisnya), sehingga tidak dipakai.

Perintah (dari [Supabase CLI: Getting Started](https://supabase.com/docs/guides/local-development/cli/getting-started)):

```bash
# Instalasi CLI (pilih salah satu)

# a) Sebagai dev dependency project (tanpa global command, pakai npx):
npm install supabase --save-dev
npx supabase --help

# b) Global (macOS/Linux via Homebrew):
brew install supabase/tap/supabase

# Menjalankan stack lokal:
supabase init     # membuat folder supabase/ + config.toml (aman di-commit)
supabase start    # menjalankan seluruh stack di Docker
```

Persyaratan & detail dari [Supabase CLI: Getting Started](https://supabase.com/docs/guides/local-development/cli/getting-started):

- Butuh **container runtime**: Docker Desktop, atau alternatif kompatibel seperti Rancher Desktop, Podman, OrbStack (macOS), colima (macOS).
- CLI via `npx`/`npm` **butuh Node.js 20 atau lebih baru**.
- Run pertama mengunduh Docker images (butuh internet); setelah itu stack berjalan lokal.
- Endpoint default setelah `supabase start`:
  - Studio: `http://localhost:54323`
  - API Gateway: `http://127.0.0.1:54321` (REST: `/rest/v1`)
  - Database: `postgresql://postgres:postgres@localhost:54322/postgres`
  - `supabase start` mencetak **publishable key** (`sb_publishable_...`) dan **secret key** (`sb_secret_...`) lokal.
- Menghentikan: `supabase stop`.
- Key lokal **berbeda** dari key project hosted dan tidak bisa mengakses data hosted — [API Keys docs](https://supabase.com/docs/guides/api/api-keys).

Arahkan aplikasi ke stack lokal dengan mengubah `.env.local`:

```text
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_PUBLISHABLE_KEY=<publishable key dari output `supabase start` / `supabase status`>
```

### 6.2 Self-hosting penuh dengan Docker Compose

> **Tidak dipakai proyek ini** (membutuhkan Docker). Dicatat hanya sebagai referensi jika suatu saat perlu menjalankan Supabase di server sendiri.

Untuk menjalankan stack sebagai layanan mandiri (mis. server kampus), Supabase menyediakan konfigurasi Docker Compose resmi — [Self-Hosting with Docker](https://supabase.com/docs/guides/self-hosting/docker):

```bash
# Quick start (Linux): install & setup otomatis
curl -fsSL https://supabase.link/setup.sh | sh
cd supabase-project && sh run.sh start

# Atau manual (semua OS dengan git):
git clone --depth 1 --branch self-hosted/v0.8.1 https://github.com/supabase/supabase
mkdir supabase-project
cp -rf supabase/docker/. supabase-project
cd supabase-project && cp .env.example .env
docker compose pull
sh utils/generate-keys.sh
sh utils/add-new-auth-keys.sh
sh run.sh start
```

Kebutuhan minimum untuk seluruh komponen: RAM 4 GB (rekomendasi 8 GB+), CPU 2 core (rekomendasi 4+), disk 40 GB SSD — [Self-Hosting with Docker](https://supabase.com/docs/guides/self-hosting/docker).

**Offline:** setelah Docker images terunduh, stack lokal (`supabase start`) berjalan di mesin sendiri tanpa koneksi ke server Supabase. Namun run pertama tetap butuh internet untuk menarik images, dan saya tidak menemukan dokumentasi resmi yang menjamin mode "fully offline" untuk CLI (lihat Catatan Ketidakpastian).

**Untuk FlashStruct:** cara paling praktis adalah `supabase init` + `supabase start` untuk development, lalu seed SQL yang sama dipakai baik di lokal maupun di project hosted.

---

## 7. Biaya

### 7.1 Kapan Free Tier mulai tidak cukup?

Berdasarkan batasan Free Plan ([supabase.com/pricing](https://supabase.com/pricing)):

| Skenario | Free tier cukup? | Yang dibutuhkan |
|---|---|---|
| Konten teks (modul/flashcard/quiz) < 500 MB | Ya | Free |
| Egress < 5 GB/bulan (teks kecil; gambar/audio bisa cepat habis) | Ya | Free |
| Tidak ingin project di-pause saat idle | Tidak | Pro ($25/bulan) — "Paid projects cannot be paused and are not subject to pausing for inactivity" ([Project Pausing](https://supabase.com/docs/guides/platform/free-project-pausing)) |
| Butuh backup / PITR | Tidak | Pro (daily backups 7 hari) atau add-on PITR $100/bulan ([pricing](https://supabase.com/pricing)) |
| > 2 active projects | Tidak | Pro (project tambahan menambah biaya compute) ([pricing FAQ](https://supabase.com/pricing)) |
| Butuh support email | Tidak | Pro ([pricing](https://supabase.com/pricing)) |
| Database > 500 MB | Tidak | Pro (8 GB disk per project, lalu $0.125/GB) ([pricing](https://supabase.com/pricing)) |

Untuk FlashStruct (konten teks, read-only, tanpa login): **Free Plan hampir pasti cukup dari sisi kapasitas** (500 MB database sangat besar untuk teks). Masalah utama Free Plan adalah **auto-pause setelah 7 hari idle** dan **tidak ada backup** — [Project Pausing](https://supabase.com/docs/guides/platform/free-project-pausing), [Production Checklist](https://supabase.com/docs/guides/platform/going-into-prod).

### 7.2 Harga tier berikutnya (Pro)

Dari [supabase.com/pricing](https://supabase.com/pricing) (diakses 21 Sep 2026):

- **Pro — mulai $25/bulan** (organization-level, dibayar di muka bulanan).
- Termasuk: 100.000 MAU, **8 GB disk per project** (lalu $0.125/GB), **250 GB egress** (lalu $0.09/GB), 250 GB cached egress, **100 GB file storage**, **daily backups 7 hari**, 7-day log retention, email support, **tidak pernah di-pause**.
- **Compute dibilling terpisah per project.** Pro/Team mendapat **$10/bulan compute credits**, yang menutup satu instance **Micro** (1 GB RAM). Contoh resmi: "A Pro org with 2 projects on Micro compute costs: $25 (plan) + $10 (project 1) + $10 (project 2) − $10 (credits) = **$35/month**" — [supabase.com/pricing](https://supabase.com/pricing).
- **Spend caps aktif secara default** di Pro; pengguna harus mematikannya untuk mengaktifkan pay-as-you-grow — [pricing FAQ](https://supabase.com/pricing).
- Add-on relevan: Custom Domain $10/domain/bulan/project; PITR $100/bulan per 7 hari retensi; Branching $0.01344/branch/jam — [supabase.com/pricing](https://supabase.com/pricing).

**Kesimpulan biaya:** untuk satu project FlashStruct dengan satu instance Micro, Pro = **$25/bulan** (plan) + $10 (compute Micro) − $10 (kredit) = **$25/bulan**. Tambahan project kedua di Micro menjadi +$10/bulan.

---

## Catatan Ketidakpastian

Bagian ini mencatat hal yang **tidak dapat saya verifikasi** dari sumber primer, atau yang perlu dicek ulang sebelum dijadikan keputusan final:

1. **Angka free tier bisa berubah.** Semua angka di section 1 dan 7 diambil dari [supabase.com/pricing](https://supabase.com/pricing) pada 21 Sep 2026. Supabase sendiri menyatakan "Pricing may change in the future" — verifikasi ulang saat implementasi.
2. **Inkonsistensi jendela restore project paused.** Teks halaman [Project Pausing](https://supabase.com/docs/guides/platform/free-project-pausing) menyebut jendela restore "**1-year window**", tetapi anchor heading-nya bernama `#90-day-window-to-restore` (menyiratkan 90 hari pada versi sebelumnya). Yang tertulis di body teks saat ini adalah 1 tahun; ini perlu dianggap tidak sepenuhnya konsisten.
3. **Rate limit Data API Free Plan tidak dipublikasikan angkanya.** Dokumentasi hanya menyebut "unlimited API requests" untuk semua plan, dan Production Checklist menyebut adanya "safeguards against bursts of incoming traffic", tanpa angka pasti untuk Data API/REST. Tidak dapat diverifikasi berapa request/detik yang ditoleransi sebelum throttling.
4. **Offline mode CLI tidak terdokumentasi eksplisit.** Saya memverifikasi bahwa stack lokal berjalan di Docker dan bahwa run pertama mengunduh images ([CLI Getting Started](https://supabase.com/docs/guides/local-development/cli/getting-started)), tetapi tidak menemukan pernyataan resmi bahwa seluruh operasi CLI (mis. `supabase start`, `supabase db`) bisa berjalan tanpa internet sama sekali (CLI mungkin melakukan pengecekan versi/telemetry; telemetry bisa dimatikan dengan `supabase telemetry disable` atau `SUPABASE_TELEMETRY_DISABLED=1`).
5. **Trik `404.html` untuk SPA di GitHub Pages tidak didokumentasikan resmi.** Dokumentasi GitHub hanya mendokumentasikan custom 404 page ([link](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-custom-404-page-for-your-github-pages-site)); trik redirect 404 → index.html adalah praktik komunitas yang tidak saya verifikasi dari sumber primer. Yang terverifikasi resmi adalah: GitHub Pages tidak punya rewrite server-side dan `HashRouter` menyimpan lokasi di hash sehingga tidak dikirim ke server.
6. **Versi `@supabase/supabase-js` bersifat moving target.** 2.116.0 adalah versi `latest` di npm registry saat riset (21 Sep 2026). Versi akan terus berubah; selalu cek `npm view @supabase/supabase-js version` sebelum mengunci versi.
7. **Halaman referensi JavaScript API Supabase (`/reference/javascript/select` dan `/reference/javascript/order`) gagal saya ambil** karena melebihi batas ukuran tool (5 MB). Contoh query embedding di section 4.3 karena itu saya dasarkan pada [panduan resmi Joins and Nested tables](https://supabase.com/docs/guides/database/joins-and-nesting) dan [dokumentasi PostgREST](https://postgrest.org/en/stable/references/api/resource_embedding.html). API seperti `.single()`, `.order(..., { referencedTable })` tidak saya verifikasi di sesi ini — gunakan `data?.[0]` atau cek referensi resmi terbaru.
8. **Angka limit Vercel/Netlify Free/Hobby tidak diriset.** Riset ini hanya memverifikasi cara deploy, bukan kuota bandwidth/build menit masing-masing platform. Untuk FlashStruct yang statis, hampir pasti tidak masalah, tetapi bukan hasil verifikasi.
9. **`gen_random_uuid()` dan ekstensi `pgcrypto`.** Contoh DDL memakai `create extension if not exists pgcrypto;` — pada project Supabase baru umumnya sudah tersedia, tetapi saya tidak memverifikasi status ekstensi default pada semua project. Alternatif: hapus baris extension dan gunakan tipe `bigint generated always as identity` seperti pada contoh resmi quickstart.
10. **Konten `is_correct` yang terekspos ke client.** Karena seluruh tabel dibaca publik (termasuk `quiz_options.is_correct`), jawaban benar dapat dilihat pengguna lewat API call. Ini masalah desain produk, bukan masalah dokumentasi — jika ingin menyembunyikan kunci jawaban, perlu pendekatan lain (mis. pindahkan penilaian ke Edge Function dengan secret key, atau pisahkan kunci ke tabel yang tidak diekspos). Catatan ini bukan klaim dari sumber resmi, melainkan konsekuensi langsung dari arsitektur read-only yang dipilih.

---

### Referensi utama (sumber primer)

- Supabase Pricing — <https://supabase.com/pricing>
- Supabase Project Pausing (Free Plan) — <https://supabase.com/docs/guides/platform/free-project-pausing>
- Supabase React Quickstart — <https://supabase.com/docs/guides/getting-started/quickstarts/reactjs>
- Supabase Row Level Security — <https://supabase.com/docs/guides/database/postgres/row-level-security>
- Supabase API Keys — <https://supabase.com/docs/guides/api/api-keys>
- Supabase Joins and Nested tables — <https://supabase.com/docs/guides/database/joins-and-nesting>
- Supabase CLI Getting Started — <https://supabase.com/docs/guides/local-development/cli/getting-started>
- Supabase Self-Hosting with Docker — <https://supabase.com/docs/guides/self-hosting/docker>
- Supabase Production Checklist — <https://supabase.com/docs/guides/platform/going-into-prod>
- PostgREST Resource Embedding — <https://postgrest.org/en/stable/references/api/resource_embedding.html>
- PostgreSQL Constraints (FK, UNIQUE, CASCADE) — <https://www.postgresql.org/docs/current/ddl-constraints.html>
- Vite: Deploying a Static Site — <https://vite.dev/guide/static-deploy>
- Vite: Env Variables and Modes — <https://vite.dev/guide/env-and-mode>
- Vercel: Vite on Vercel — <https://vercel.com/docs/frameworks/frontend/vite>
- Vercel: Configuring a Build — <https://vercel.com/docs/builds/configure-a-build>
- Vercel: Environment Variables — <https://vercel.com/docs/environment-variables>
- Netlify: Vite on Netlify — <https://docs.netlify.com/build/frameworks/framework-setup-guides/vite/>
- Netlify: Build configuration overview — <https://docs.netlify.com/build/configure-builds/overview/>
- Netlify: Rewrites and proxies — <https://docs.netlify.com/manage/routing/redirects/rewrites-proxies/>
- GitHub: What is GitHub Pages? — <https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages>
- GitHub: Pages limits — <https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits>
- GitHub: Custom 404 page — <https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-custom-404-page-for-your-github-pages-site>
- React Router: HashRouter — <https://reactrouter.com/api/declarative-routers/HashRouter>
- npm registry: @supabase/supabase-js — <https://registry.npmjs.org/@supabase/supabase-js/latest>
- supabase-js README — <https://github.com/supabase/supabase-js/blob/master/packages/core/supabase-js/README.md>
