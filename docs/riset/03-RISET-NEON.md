# 03 — Riset: Bisakah Neon Menggantikan Supabase untuk FlashStruct?

> **Tanggal riset:** 21 September 2026 (UTC)
> **Metode:** Semua klaim diambil dari sumber primer — dokumentasi resmi Neon (`neon.com/docs`, `neon.com/pricing`, `neon.com/docs/changelog`), dokumentasi resmi Vercel (`vercel.com/docs`), dan metadata registry npm. Setiap klaim disertai tautan sumber. Hal yang tidak dapat diverifikasi dicatat di [§ Catatan Ketidakpastian](#catatan-ketidakpastian).
> **Konteks proyek:** FlashStruct — React 19 + Vite + TypeScript, host di Vercel Hobby. Tanpa login pengguna. Konten (modul, flashcard, soal) di PostgreSQL, diambil **read-only** oleh browser. Progres belajar di `localStorage`.
> **Pertanyaan inti:** Bisakah Neon menggantikan Supabase, dengan asumsi utama saat ini adalah PostgREST Supabase yang menyediakan REST API otomatis sehingga browser bisa query langsung tanpa backend?

---

## Ringkasan Eksekutif

**Jawaban singkat: YA — Neon bisa menggantikan Supabase untuk FlashStruct, dan untuk kasus read-only tanpa login, Neon justru secara teknis lebih cocok.**

Alasannya:

1. **Neon punya REST API otomatis yang setara PostgREST.** Namanya **Neon Data API**, dan dokumentasi resminya menyatakan secara eksplisit: *"The Neon Data API is fully compatible with PostgREST"* — [Data API Overview](https://neon.com/docs/data-api/overview). Ini bukan sekadar "ada REST API", tapi implementasi PostgREST-compatible, artinya pola query, sintaks filter, dan **embedding relasi bertingkat** yang sudah direncanakan untuk FlashStruct semuanya bekerja sama.
2. **Neon Data API baru saja GA (18 September 2026)** — 3 hari sebelum riset ini. Diumumkan dalam changelog resmi "The Neon backend is generally available", di mana Data API dideskripsikan sebagai *"An instant REST endpoint over your Postgres tables, no backend server required"* — [Changelog 2026-09-18](https://neon.com/docs/changelog).
3. **Data API memang dirancang untuk dipanggil dari browser.** Dokumentasi menyatakan standard Postgres driver tidak bisa jalan di browser, dan Data API hadir untuk mengisi celah itu: *"Browser and edge compatibility. Standard Postgres drivers don't work in web browsers and struggle in edge runtimes, so query from Cloudflare Workers, Vercel Edge, or a browser frontend over standard HTTP."* — [Data API Overview](https://neon.com/docs/data-api/overview).
4. **Ada jalur resmi untuk data publik tanpa login**, yaitu role `anonymous`. Dokumentasi menyebutkan penggunaan eksplisit: *"For public data that doesn't require login, use the `anonymous` role"* — [Data API Get Started](https://neon.com/docs/data-api/get-started). Ini persis kasus FlashStruct.
5. **Yang diekspos ke browser bukan connection string.** Ini perbedaan penting dan sering disalahpahami. Browser hanya memegang **Data API URL** (`https://ep-xxx.apirest.<region>.aws.neon.tech/<db>/rest/v1`), bukan `postgresql://user:password@...`. Jadi pertanyaan "aman tidak mengekspos kredensial ke browser" dijawab: **connection string tidak pernah masuk ke browser sejak awal.**

**Satu catatan penting yang harus dipegang:** **API-nya GA, tapi SDK kliennya masih beta.** `@neondatabase/neon-js` versi terbaru adalah `0.7.0-beta` dan `@neondatabase/postgrest-js` adalah `0.2.0-beta` (diverifikasi dari metadata npm registry, 21 Sep 2026). Untuk aplikasi read-only sederhana ini bukan penghalang serius — tapi harus disadari bahwa permukaan API klien masih bisa berubah.

**Kesimpulan praktis:** Arsitektur yang direncanakan (browser query langsung, tanpa backend) **tetap valid** jika pindah ke Neon. Yang berubah hanyalah: Supabase Client + anon key → Neon SDK + Data API URL, dan `GRANT`/policy RLS ditulis untuk role `anonymous`, bukan `anon`.

---

## 1. Apakah Neon Punya REST API Otomatis Seperti PostgREST?

### 1.1 Nama resminya: Neon Data API

Fitur ini bernama **Neon Data API**, dideskripsikan resmi sebagai:

> "The Neon Data API is the HTTP query service in the Neon backend for apps and agents. It provides a secure, stateless interface to your database, letting you access and manage your data directly from web browsers, serverless functions, and edge runtimes using standard HTTP methods."
> — [Data API Overview](https://neon.com/docs/data-api/overview)

### 1.2 Apakah PostgREST-compatible? Ya, eksplisit

Ini klaim paling penting untuk FlashStruct, karena seluruh rencana query (embedding relasi, filter, ordering) bertumpu padanya.

> "**PostgREST compatibility.** The Neon Data API is fully compatible with [PostgREST](https://postgrest.org/en/stable/). This compatibility allows you to query your database using any standard HTTP client (such as Postman or `cURL`) or integrate easily using client libraries, including [`@neondatabase/neon-js`](https://www.npmjs.com/package/@neondatabase/neon-js) and [`@neondatabase/postgrest-js`](https://www.npmjs.com/package/@neondatabase/postgrest-js)."
> — [Data API Overview](https://neon.com/docs/data-api/overview)

Changelog juga mencatat bahwa Data API di-rebuild dari nol di Rust sambil **mempertahankan 100% kompatibilitas PostgREST**:

> "We've rebuilt the Data API from the ground up in Rust while maintaining 100% PostgREST compatibility. This new architecture delivers better performance, multi-tenancy support, and improved resource efficiency, while maintaining the same PostgREST API."
> — [Changelog](https://neon.com/docs/changelog) (entri "Data API updates")

### 1.3 Status: GA atau beta?

**Ada dua lapis yang statusnya berbeda — ini nuansa penting.**

| Komponen | Status | Sumber |
|---|---|---|
| **Neon Data API (server/endpoint)** | **GA** — diumumkan 18 Sep 2026 | [Changelog 2026-09-18](https://neon.com/docs/changelog) |
| **`@neondatabase/neon-js`** (SDK klien) | **Beta** — `0.7.0-beta` | npm registry `@neondatabase/neon-js` (diverifikasi 21 Sep 2026) |
| **`@neondatabase/postgrest-js`** (SDK klien alternatif) | **Beta** — `0.2.0-beta` | npm registry `@neondatabase/postgrest-js` (diverifikasi 21 Sep 2026) |

Bukti GA dari changelog resmi (entri 2026-09-18, "The Neon backend is generally available"):

> "[Data API](https://neon.com/docs/data-api/overview): An instant REST endpoint over your Postgres tables, no backend server required."
> — [Changelog 2026-09-18](https://neon.com/docs/changelog)

Di entri changelog yang sama, bagian "Backend services are GA in `neon.ts`" menyebut `dataApi` sebagai salah satu key top-level yang sudah GA:

> "**Backend services are GA in `neon.ts`.** Declare `aiGateway`, `functions`, and `buckets` as top-level keys in `defineConfig`, alongside `auth` and `dataApi`."
> — [Changelog 2026-09-18](https://neon.com/docs/changelog)

**Catatan penting:** paket npm klien masih menyandang label `-beta`. Halaman dokumentasi SDK juga masih menulis catatan kompatibilitas versi beta secara eksplisit:

> "**Note: Version compatibility** — The single-URL form, `createClient(url)`, requires `@neondatabase/neon-js` 0.7.0-beta or later."
> — [JavaScript SDK reference](https://neon.com/docs/reference/javascript-sdk)

Artinya: **endpoint-nya stabil dan production-ready; binding kliennya belum dijanjikan stabil.** Untuk aplikasi ini risikonya rendah (API yang dipakai cuma `select` + filter), tapi bukan nol.

### 1.4 Bisa diakses langsung dari browser?

**Ya — ini use case yang didukung secara eksplisit.** Dokumentasi menyatakan Data API dirancang untuk dipanggil dari browser karena driver Postgres standar tidak bisa jalan di browser:

> "**Browser and edge compatibility.** Standard Postgres drivers don't work in web browsers and struggle in edge runtimes, so query from Cloudflare Workers, Vercel Edge, or a browser frontend over standard HTTP."
> — [Data API Overview](https://neon.com/docs/data-api/overview)

Halaman "Choosing your connection method" juga menempatkan Data API sebagai rekomendasi resmi untuk aplikasi client-side tanpa backend:

> "### Building a client-side app without a backend?
> Use the [Neon Data API](https://neon.com/docs/data-api/overview) via [`@neondatabase/neon-js`](https://www.npmjs.com/package/@neondatabase/neon-js). **Browsers cannot open TCP connections to Postgres, so the Data API provides a secure HTTP interface with Row-Level Security support.**"
> — [Choosing your connection method](https://neon.com/docs/connect/choose-connection)

SDK-nya pun dinyatakan jalan di browser, lengkap dengan contoh env var Vite:

> "**Note:** This client runs in the browser. Environment variable syntax depends on your framework: `import.meta.env.VITE_*` for Vite-based projects (Vite, SvelteKit, Astro)..."
> — [Data API Get Started](https://neon.com/docs/data-api/get-started)

Ada juga contoh aplikasi React + Vite resmi dari Neon Labs:

> "This tutorial uses a note-taking app to show how Neon's Data API works with the `@neondatabase/neon-js` client library to write queries from your frontend code... **About the sample application:** This note-taking app is built with React and Vite."
> — [Data API tutorial](https://neon.com/docs/data-api/demo)

Repository: <https://github.com/neondatabase-labs/neon-data-api-neon-auth> — live demo di <https://neon-data-api-neon-auth.vercel.app/>

**Ini persis stack FlashStruct**: React + Vite, query dari frontend, tanpa backend terpisah.

### 1.5 Bagaimana autentikasinya? Apakah aman mengekspos kredensial ke browser?

**Pertanyaan ini perlu dijawab dengan hati-hati karena premisnya sedikit keliru — dan premis yang keliru itu justru kabar baik.**

**Yang TIDAK diekspos ke browser:**

Neon **tidak** meminta connection string di browser. Ada peringatan eksplisit di dokumentasi SDK:

> "The `VITE_NEON_DATABASE_URL` value is **not your Postgres connection string**; use the HTTPS Neon database URL shown in the example above."
> — [Data API Get Started](https://neon.com/docs/data-api/get-started)

Jadi yang masuk ke bundle frontend adalah URL HTTPS seperti `https://ep-example.c-2.us-east-1.aws.neon.tech/neondb` — tanpa username, tanpa password. Dokumentasi menyatakan secara eksplisit: *"Use your Neon database URL without credentials or query parameters."* — [JavaScript SDK reference](https://neon.com/docs/reference/javascript-sdk)

**Mengapa ini penting secara keamanan:** connection string Neon (`postgresql://neondb_owner:password@...`) memberi **akses penuh ke database** dan melewati RLS. Dokumentasi memperingatkan:

> "**Important:** When using JWT self-verification with RLS, ensure your database connection string uses a role that does **not** have the `BYPASSRLS` attribute. Avoid using the `neondb_owner` role in your connection string, as it bypasses Row-Level Security policies."
> — [Neon serverless driver](https://neon.com/docs/serverless/serverless-driver)

Karena connection string tidak pernah masuk browser, risiko terbesar itu tidak pernah muncul.

**Mekanisme autentikasi Data API — dua mode:**

**(a) Dengan JWT (mode authenticated / anonymous JWT).** Data API memvalidasi JWT dari auth provider mana pun dan menerjemahkannya menjadi role Postgres:

> "The Data API uses JWTs for access control. Configure a provider now or later from the **Settings** tab. For public data that doesn't require login, use the [`anonymous` role](https://neon.com/docs/data-api/access-control#2-the-anonymous-role) instead."
> — [Data API Get Started](https://neon.com/docs/data-api/get-started)

Dengan Managed Better Auth, token anonim diambil otomatis dan di-cache:

> "**With Managed Better Auth:** Set `allowAnonymous: true` in the client config. The SDK fetches a short-lived anonymous token (`GET /token/anonymous`) on the first request, caches it, and sends it as `Authorization: Bearer <jwt>` on every query."
> — [Access control & security](https://neon.com/docs/data-api/access-control)

**(b) Tanpa header Authorization sama sekali.** Halaman manajemen menyatakan role `anonymous` dipakai justru untuk request tanpa header:

> "**Anonymous role** — **Default:** `anonymous` — Specifies the database role used for **unauthenticated requests (requests sent without an Authorization header)**. To allow public access to specific data, configure this role in your database using SQL `GRANT` statements."
> — [Managing the Data API](https://neon.com/docs/data-api/manage)

**Ada sedikit ketegangan antar dua halaman dokumentasi ini** — satu menyatakan akses anonim "tetap memakai JWT", satu lagi menyatakan role anonim dipakai untuk request tanpa header Authorization. Keduanya kemungkinan benar untuk skenario berbeda (dengan/tanpa auth provider terkonfigurasi), tapi dokumentasi tidak menjelaskan interaksinya secara eksplisit. Lihat [§ Catatan Ketidakpastian](#catatan-ketidakpastian).

**Mengapa aman mengekspos URL Data API ke browser?**

Model keamanannya sama dengan Supabase, dan itu memang desain yang disengaja: **URL publik itu boleh diketahui siapa saja, karena otorisasi ditegakkan di level database, bukan di level kerahasiaan URL.**

> "The Neon Data API is designed to be secure by default. It relies on PostgreSQL's native security model, meaning the API does not have its own separate permission system; it acts as a gateway that respects the roles and Row-Level Security (RLS) policies defined in your database."
> — [Access control & security](https://neon.com/docs/data-api/access-control)

Perbandingan langsung dengan Supabase: Supabase mengekspos `anon` key (JWT yang ditandatangani) ke browser dan mengandalkan RLS. Neon mengekspos URL Data API dan mengandalkan RLS dengan role `anonymous`. **Filosofi keamanannya identik.**

### 1.6 Apakah mendukung query bertingkat/join dalam satu request seperti PostgREST embedding?

**Ya.** Karena 100% PostgREST-compatible, sintaks embedding relasi bekerja. Contoh resmi dari dokumentasi Neon — perhatikan `paragraphs (...)` yang di-embed di dalam query `notes`:

```typescript
const { data, error } = await client
 .from('notes')
 .insert({ title: generateNameNote() })
 .select('id, title, shared, owner_id, paragraphs (id, content, created_at, note_id)')
 .single();
```

> "The `.select()` chained after `.insert()` lets you insert a record and immediately fetch it back (along with related data from other tables) in a single query. **This is a useful pattern provided by the PostgREST-compatible API.**"
> — [Data API tutorial](https://neon.com/docs/data-api/demo)

SDK juga mendokumentasikan pola relasi secara eksplisit:

> "**Select with related tables**
> ```typescript
> const { data, error } = await client.from('todos').select('*, owner:users(*)');
> ```"
> — [JavaScript SDK reference](https://neon.com/docs/reference/javascript-sdk)

Neon juga menyediakan **SQL to PostgREST Converter** resmi yang menerjemahkan SQL (termasuk join dan agregasi) menjadi panggilan PostgREST:

> "This tool supports common SELECT statements with filtering, sorting, pagination, **joins, and aggregations**."
> — [SQL to PostgREST Converter](https://neon.com/docs/data-api/sql-to-rest)

**Implikasi untuk FlashStruct:** pola `modul → bagian_modul → flashcard` dan `soal → opsi_soal` bisa di-embed dalam satu request, sama seperti rencana awal dengan Supabase. **Tidak ada perubahan arsitektur query yang diperlukan.**

### 1.7 Kemampuan lain yang relevan

| Kemampuan | Dukungan | Sumber |
|---|---|---|
| SELECT / INSERT / UPDATE / DELETE | Ya | [Data API Get Started](https://neon.com/docs/data-api/get-started) |
| RPC (stored procedure) | Ya — `client.rpc('fn', {...})` | [JavaScript SDK reference](https://neon.com/docs/reference/javascript-sdk) |
| Filter (`eq`, `neq`, `gt`, `lt`, `gte`, `lte`, `like`, `ilike`, `is`, `in`, `contains`, `range`) | Ya | [JavaScript SDK reference](https://neon.com/docs/reference/javascript-sdk) |
| Modifier (`order`, `limit`, `single`) | Ya | [JavaScript SDK reference](https://neon.com/docs/reference/javascript-sdk) |
| Agregasi | Ya — via flag `--db-aggregates-enabled` | [Neon CLI: data-api](https://neon.com/docs/cli/data-api) |
| OpenAPI spec otomatis | Ya — tapi butuh JWT, dan default **Disabled** | [Managing the Data API](https://neon.com/docs/data-api/manage) |
| Batas baris per request | Ya — setting `db_max_rows` (default kosong) | [Managing the Data API](https://neon.com/docs/data-api/manage) |
| CORS origin allowlist | Ya — setting `server_cors_allowed_origins` | [Managing the Data API](https://neon.com/docs/data-api/manage) |
| TypeScript types dari skema | Ya | [Generate TypeScript types](https://neon.com/docs/data-api/generate-types) |

**Batasan yang perlu diketahui:**

- Data API diaktifkan **per branch, untuk satu database** — *"The Neon Data API is enabled at the **branch** level for a single database."* — [Data API Get Started](https://neon.com/docs/data-api/get-started)
- **Tidak kompatibel dengan IP Allow dan Private Networking** — *"Neon Data API does not currently support projects with IP Allow or Private Networking enabled."* — [Data API Get Started](https://neon.com/docs/data-api/get-started). Ini tidak masalah untuk FlashStruct (keduanya fitur Scale, bukan Free).
- **Schema cache perlu di-refresh manual** setiap kali skema berubah: *"The Data API caches your database schema for performance. When you modify your schema... you need to refresh this cache for the changes to take effect."* — [Data API Get Started](https://neon.com/docs/data-api/get-started). Ini friksi tambahan saat migrasi skema — **catat untuk alur kerja pengembangan.**

---

## 2. Cara Akses Neon dari Browser React

### 2.1 Bisa koneksi langsung dari browser?

**Tidak untuk TCP/Postgres langsung. Ya untuk HTTP via Data API.**

| Jalur | Bisa dari browser? | Driver | Protokol |
|---|---|---|---|
| Koneksi Postgres langsung | Tidak | — | TCP (browser tidak bisa) |
| **Neon Data API** | **Ya** | `@neondatabase/neon-js` | HTTPS |
| Neon serverless driver | Secara teknis HTTP/WS, tapi **butuh connection string** | `@neondatabase/serverless` | HTTP / WebSocket |

**Mengapa TCP tidak bisa:** ini batasan browser, bukan batasan Neon. Dokumentasi menyatakannya langsung:

> "Standard Postgres drivers don't work in web browsers and struggle in edge runtimes, so query from Cloudflare Workers, Vercel Edge, or a browser frontend over standard HTTP."
> — [Data API Overview](https://neon.com/docs/data-api/overview)

### 2.2 Apakah aman? Apa risikonya mengekspos connection string ke browser?

**Mengekspos connection string ke browser = sangat berbahaya. Jangan dilakukan.** Alasannya konkret:

1. **Connection string memberi akses penuh database.** Neon connection string berformat `postgresql://[user]:[password]@[neon_hostname]/[dbname]` — [Neon serverless driver](https://neon.com/docs/serverless/serverless-driver). Siapa pun yang mendapatkannya bisa membaca, mengubah, dan menghapus seluruh isi database.
2. **Role owner melewati RLS.** Dokumentasi memperingatkan untuk menghindari `neondb_owner` saat ingin RLS berlaku: *"Avoid using the `neondb_owner` role in your connection string, as it bypasses Row-Level Security policies."* — [Neon serverless driver](https://neon.com/docs/serverless/serverless-driver). Artinya, bahkan jika RLS dikonfigurasi, connection string owner membuat RLS tidak berguna.
3. **Password bisa dipakai dari mana saja.** Tidak ada mekanisme yang mengikat kredensial ke origin browser.

**Kabar baiknya: skenario ini tidak perlu terjadi.** Dengan Data API, yang masuk bundle adalah URL HTTPS tanpa kredensial:

```env
# AMAN untuk frontend (Vite) — tidak ada username/password
VITE_NEON_DATABASE_URL=https://ep-example.c-2.us-east-1.aws.neon.tech/neondb

# BAHAYA — jangan pernah taruh ini di kode frontend
# DATABASE_URL=postgresql://user:password@ep-xxx.aws.neon.tech/neondb?sslmode=require
```

Dokumentasi contoh aplikasi Neon pun memisahkan keduanya dengan jelas — satu untuk client, satu untuk migrasi:

> ```env
> # Neon database URL for the client (no username, password, or query parameters)
> VITE_NEON_DATABASE_URL=https://ep-example.c-2.us-east-1.aws.neon.tech/neondb
>
> # Database Connection String (for migrations)
> DATABASE_URL=postgresql://user:password@your-project-id.pooler.region.neon.tech/neondb?sslmode=require
> ```
> — [Data API tutorial](https://neon.com/docs/data-api/demo)

**Kesimpulan keamanan:** selama `DATABASE_URL` hanya ada di `.env` lokal (untuk migrasi) dan tidak pernah masuk ke variabel ber-prefix `VITE_`, tidak ada kredensial yang bocor ke browser. Yang publik adalah URL endpoint + kebijakan RLS.

### 2.3 Apakah Neon menyediakan driver HTTP/WebSocket untuk browser?

**Ada dua hal berbeda yang sering tertukar — perlu dipisahkan:**

**(a) Neon serverless driver (`@neondatabase/serverless`) — HTTP & WebSocket, tapi BUKAN untuk browser.**

- Status: **GA**. *"The Neon serverless driver is now generally available (GA). The GA version of the Neon serverless driver, v1.0.0 and higher, requires Node.js version 19 or higher."* — [Neon serverless driver](https://neon.com/docs/serverless/serverless-driver)
- Versi terbaru: `1.1.0` (diverifikasi dari npm registry, 21 Sep 2026)
- Transport: HTTP (via `fetch`) untuk one-shot queries; WebSocket untuk session/interactive transaction dan kompatibilitas `node-postgres`
- **Tapi butuh connection string** — contoh resminya selalu `neon(process.env.DATABASE_URL)`. Dokumentasi menargetkannya untuk *serverless and edge environments*, bukan browser.

> "The Neon serverless driver is a low-latency Postgres driver for JavaScript and TypeScript that allows you to query data from **serverless and edge environments** over HTTP or WebSockets in place of TCP."
> — [Neon serverless driver](https://neon.com/docs/serverless/serverless-driver)

**(b) Neon Data API + `@neondatabase/neon-js` — ini yang untuk browser.**

Tabel rekomendasi resmi menempatkan keduanya di baris berbeda:

| Environment | Recommended driver | Sumber |
|---|---|---|
| Cloudflare Workers / Netlify / Deno Deploy | `@neondatabase/serverless` | [Choose connection](https://neon.com/docs/connect/choose-connection) |
| **Client-side (browser)** | **`@neondatabase/neon-js`** | [Choose connection](https://neon.com/docs/connect/choose-connection) |

> "**Client-side (browser)** → `@neondatabase/neon-js` → N/A (pooling) → [Data API](https://neon.com/docs/data-api/overview)"
> — [Choosing your connection method](https://neon.com/docs/connect/choose-connection)

### 2.4 Kalau TIDAK bisa langsung, apa alternatifnya?

Untuk FlashStruct, **tidak perlu alternatif** — Data API adalah jalur langsungnya. Tapi demi kelengkapan, tiga alternatif jika Data API tidak cocok:

| Alternatif | Cara kerja | Catatan |
|---|---|---|
| **Vercel Serverless/Edge Function** | Function memegang `DATABASE_URL`, browser memanggil function | Lihat [§ 3](#3-vercel-serverless-function-sebagai-perantara) |
| **Neon Functions** | Serverless Node.js yang berjalan di branch Neon sendiri | *"Neon Functions are serverless Node.js compute you deploy onto a Neon branch, so your backend code runs next to your database."* — [Plans](https://neon.com/docs/introduction/plans) |
| **Build-time static generation** | Query saat build, hasilnya jadi file statis | Paling murah, tapi konten tidak bisa di-update tanpa redeploy |

**Catatan:** Opsi build-time menarik untuk FlashStruct (konten read-only, jarang berubah) tapi menghilangkan kemampuan update konten tanpa deploy ulang — trade-off produk, bukan teknis.

### 2.5 Contoh setup minimal untuk FlashStruct (pola resmi, diadaptasi)

Dari [Data API Get Started](https://neon.com/docs/data-api/get-started) dan [JavaScript SDK reference](https://neon.com/docs/reference/javascript-sdk), pola untuk aplikasi tanpa login:

```bash
npm install @neondatabase/neon-js
```

```typescript
// src/lib/neon.ts
import { createClient } from '@neondatabase/neon-js';

// URL HTTPS tanpa kredensial — aman masuk bundle frontend.
// Diambil dari Neon Console → Data API, atau `neon data-api get`.
const client = createClient(import.meta.env.VITE_NEON_DATABASE_URL);

export { client };
```

```typescript
// Contoh query dengan embedding relasi
const { data, error } = await client
 .from('modul')
 .select('id, judul, bagian_modul (id, judul, flashcard (id, pertanyaan, jawaban))')
 .order('urutan', { ascending: true });
```

Pola `allowAnonymous` (jika memakai Managed Better Auth):

```typescript
const client = createClient(import.meta.env.VITE_NEON_DATABASE_URL, {
 auth: {
 allowAnonymous: true,
 },
});
```

> Sumber pola: [Access control & security](https://neon.com/docs/data-api/access-control)

**Catatan:** kode di atas adalah **adaptasi** dari contoh resmi, bukan salinan literal. Nama tabel disesuaikan dengan skema FlashStruct. Yang diambil apa adanya dari dokumentasi: bentuk `createClient()`, sintaks `.select()` dengan embedding, dan opsi `allowAnonymous`.

---

## 3. Vercel Serverless Function Sebagai Perantara

### 3.1 Kalau harus lewat serverless function, bagaimana caranya?

Untuk FlashStruct, **ini tidak diperlukan** karena Data API bisa dipanggil langsung dari browser. Tapi jika nanti butuh (misalnya untuk menyembunyikan logika bisnis, atau jika Data API tidak dipakai), polanya:

**Opsi A — Neon serverless driver over HTTP (paling sederhana):**

```typescript
// api/modul.ts — Vercel Serverless Function
import { neon } from '@neondatabase/serverless';
import type { NextApiRequest, NextApiResponse } from 'next';

export default async function handler(request: NextApiRequest, res: NextApiResponse) {
 const sql = neon(process.env.DATABASE_URL!);
 const posts = await sql`SELECT * FROM modul ORDER BY urutan`;
 return res.status(200).json(posts);
}
```

> Sumber pola: [Neon serverless driver](https://neon.com/docs/serverless/serverless-driver) — contoh "Vercel Serverless Function"

**Opsi B — TCP + connection pooling (rekomendasi resmi untuk Vercel Fluid compute):**

```typescript
// src/lib/db/client.ts
import { attachDatabasePool } from '@vercel/functions';
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';

import * as schema from './schema';

const pool = new Pool({
 connectionString: process.env.DATABASE_URL,
});
attachDatabasePool(pool);

export const db = drizzle({ client: pool, schema });
```

> "`attachDatabasePool` handles the connection lifecycle for you: the first request establishes a TCP connection, subsequent requests reuse it instantly, and idle connections close gracefully before Vercel suspends the function."
> — [Connecting to Neon from Vercel](https://neon.com/docs/guides/vercel-connection-methods)

**Rekomendasi resmi Neon untuk Vercel Fluid compute adalah TCP + pooling**, bukan HTTP driver:

> "**The short answer:** With Vercel Fluid, we recommend you use a **standard Postgres TCP connection** (for example, with the [node-postgres package](https://node-postgres.com/)) and a connection pool. This is the new fastest and most robust method."
> — [Connecting to Neon from Vercel](https://neon.com/docs/guides/vercel-connection-methods)

**Peringatan penting untuk WebSocket di serverless:**

> "In serverless environments such as Vercel Edge Functions or Cloudflare Workers, WebSocket connections can't outlive a single request. That means `Pool` or `Client` objects must be connected, used and closed within a single request handler. Don't create them outside a request handler; don't create them in one handler and try to reuse them in another; and to avoid exhausting available connections, don't forget to close them."
> — [Neon serverless driver](https://neon.com/docs/serverless/serverless-driver)

### 3.2 Batas gratis Vercel Hobby

Dari [Vercel Hobby Plan](https://vercel.com/docs/plans/hobby) (last updated 2026-09-14):

| Resource | Hobby Included Usage | Sumber |
|---|---|---|
| **Function Invocations** | **1.000.000/bulan** | [Hobby Plan](https://vercel.com/docs/plans/hobby) |
| **Active CPU** | **4 CPU-hrs** | [Hobby Plan](https://vercel.com/docs/plans/hobby) |
| **Provisioned Memory** | **360 GB-hrs** | [Hobby Plan](https://vercel.com/docs/plans/hobby) |
| Fast Data Transfer | First 100 GB | [Hobby Plan](https://vercel.com/docs/plans/hobby) |
| Fast Origin Transfer | First 10 GB | [Hobby Plan](https://vercel.com/docs/plans/hobby) |
| Edge Requests | First 1.000.000 | [Hobby Plan](https://vercel.com/docs/plans/hobby) |
| Deployments per day | 100 | [Limits](https://vercel.com/docs/limits) |
| Runtime Logs retention | 1 hour | [Hobby Plan](https://vercel.com/docs/plans/hobby) |

**Detail penting tentang cara billing Active CPU** — menguntungkan untuk aplikasi I/O-bound seperti FlashStruct:

> "You are only billed during actual code execution and not during I/O operations (database queries, like AI model calls, etc.)... **Pauses billing when your code is waiting for external services**"
> — [Vercel Functions usage and pricing](https://vercel.com/docs/functions/usage-and-pricing)

Artinya, waktu tunggu query database **tidak** dihitung sebagai Active CPU. Untuk endpoint yang tugasnya cuma "query lalu kirim JSON", konsumsi CPU sangat kecil.

**Batasan yang harus diwaspadai — Hobby hanya untuk non-komersial:**

> "**Hobby teams** are restricted to non-commercial personal use only. All commercial usage of the platform requires either a Pro or Enterprise plan."
> — [Fair Use Guidelines](https://vercel.com/docs/limits/fair-use-guidelines)

Untuk FlashStruct (proyek edukasi personal) ini kemungkinan tidak masalah, tapi jika suatu saat dimonetisasi, **wajib upgrade ke Pro**.

**Perilaku saat limit terlampaui:**

> "In most cases, if you exceed your usage limits on the Hobby plan, you will have to wait until 30 days have passed before you can use the feature again."
> — [Vercel Hobby Plan](https://vercel.com/docs/plans/hobby)

### 3.3 Apakah ada contoh resmi dari Neon untuk Vercel Functions?

**Ya, banyak.** Neon mempublikasikan contoh aplikasi resmi di organisasi GitHub-nya:

| Contoh | Deskripsi | Repository |
|---|---|---|
| Raw SQL + Vercel Edge Functions | Raw SQL dengan serverless driver | [neondatabase/neon-vercel-rawsql](https://github.com/neondatabase/neon-vercel-rawsql) |
| Raw SQL via HTTPS + Vercel Edge | Serverless driver over HTTP | [neondatabase/neon-vercel-http](https://github.com/neondatabase/neon-vercel-http) |
| Kysely + Vercel Edge Functions | Query builder + codegen | [neondatabase/neon-vercel-kysely](https://github.com/neondatabase/neon-vercel-kysely) |
| Zapatos + Vercel Edge Functions | Type-safe SQL | [neondatabase/neon-vercel-zapatos](https://github.com/neondatabase/neon-vercel-zapatos) |
| pgTyped + Vercel Edge Functions | Type generation dari SQL | [neondatabase/neon-vercel-pgtyped](https://github.com/neondatabase/neon-vercel-pgtyped) |
| Knex + Vercel Edge Functions | Query builder Knex | [neondatabase/neon-vercel-knex](https://github.com/neondatabase/neon-vercel-knex) |
| Ping Thing | Ping database via Edge Function | [neondatabase/ping-thing](https://github.com/neondatabase/ping-thing) |

> Sumber daftar: [Neon serverless driver § Example applications](https://neon.com/docs/serverless/serverless-driver)

Ada juga dokumentasi khusus untuk cara koneksi dari Vercel: [Connecting to Neon from Vercel](https://neon.com/docs/guides/vercel-connection-methods).

### 3.4 Apakah Neon punya integrasi resmi dengan Vercel?

**Ya — dua integrasi resmi, plus jalur manual.** Dari [Integrating Neon with Vercel](https://neon.com/docs/guides/vercel-overview):

| Aspek | Vercel-Managed | Neon-Managed | Manual Connection |
|---|---|---|---|
| Cocok untuk | Pengguna baru, satu tagihan Vercel | Pengguna Neon yang sudah ada | Integrasi tidak diperlukan / CI-CD kustom |
| Akun Neon | Dibuat otomatis via Vercel | Akun Neon yang sudah ada | Akun Neon yang sudah ada |
| Billing | **Via Vercel** | **Via Neon** | Via Neon |
| Setup | Vercel Marketplace → Native Integrations → "Neon Postgres" | Vercel Marketplace → Connectable Accounts → "Neon" | Manual env-vars |
| Preview Branching | Ya | | Tidak |
| Managed Better Auth support | Ya, auto-provision di preview branch | Ya, auto-provision di preview branch | Setup manual |
| Branch cleanup | Otomatis (berbasis deployment) | Otomatis (berbasis Git branch) | N/A |

**Catatan penting tentang branch cleanup** — relevan jika nanti memakai preview deployment:

> "Vercel-Managed cleanup depends on Vercel's deployment retention policy, **which can delay branch deletion by months**. Neon-Managed cleanup is triggered by Git branch deletion."
> — [Integrating Neon with Vercel](https://neon.com/docs/guides/vercel-overview)

Untuk FlashStruct dengan 10 branch/project di Free plan, branch yang menumpuk bisa menghabiskan kuota. **Neon-Managed lebih aman** jika memakai preview branching.

**Ada juga integrasi di level produk lain** — Neon AI Gateway sebagai provider Vercel AI SDK (tidak relevan untuk FlashStruct) — [Changelog 2026-08-14](https://neon.com/docs/changelog).

---

## 4. Row Level Security (RLS)

### 4.1 Apakah Neon mendukung RLS?

**Ya — ini fitur PostgreSQL, dan Neon mendukungnya penuh.** Neon bahkan menjadikannya **wajib** untuk Data API:

> "The **Data API** turns your database tables on a given branch into a REST API, and it requires RLS policies on all tables to ensure your data is secure."
> — [Row-Level Security with Neon](https://neon.com/docs/guides/row-level-security)

Neon juga menyediakan **Data API Advisors** yang secara otomatis mendeteksi tabel tanpa RLS:

> "**RLS disabled in public** — Severity: **ERROR** — Tables exposed via the Data API without row-level security... Tables in schemas exposed through the Data API are accessible to anyone with your project's API URL if RLS is not enabled. **Without RLS, all rows are fully readable and writable via the API.**"
> — [Data API Advisors](https://neon.com/docs/data-api/database-advisor)

### 4.2 Tiga status RLS yang harus dipahami

Ini tabel yang sangat penting — banyak orang salah paham di sini:

| State | Perilaku | Sumber |
|---|---|---|
| **RLS disabled** | Semua authenticated user melihat **semua baris** (tidak ada filtering) | [Access control](https://neon.com/docs/data-api/access-control) |
| **RLS enabled, no policies** | **Semua akses diblokir** (user tidak melihat apa pun) | [Access control](https://neon.com/docs/data-api/access-control) |
| **RLS enabled + policies** | Baris difilter sesuai aturan policy | [Access control](https://neon.com/docs/data-api/access-control) |

> "**Warning: RLS disabled means no filtering.** If RLS is disabled on a table, any authenticated user can see all rows in that table. This is different from 'filtering without policies'; it means there is no filtering at all."
> — [Access control & security](https://neon.com/docs/data-api/access-control)

### 4.3 Apakah RLS berguna kalau akses lewat serverless function dengan satu service account?

**Jawaban jujur: tidak banyak — dan ini poin yang sering menyesatkan.**

Jika serverless function terhubung memakai **satu role privileged** (misalnya `neondb_owner`), maka:

- **Semua request terlihat identik dari sisi database.** Database tidak tahu siapa pengguna akhirnya; yang dilihatnya hanya satu service account.
- **RLS tidak bisa membedakan pengguna**, karena tidak ada identitas pengguna di sesi database.
- **Jika role-nya owner atau punya `BYPASSRLS`, RLS dilewati sepenuhnya.** Dokumentasi memperingatkan: *"Avoid using the `neondb_owner` role in your connection string, as it bypasses Row-Level Security policies."* — [Neon serverless driver](https://neon.com/docs/serverless/serverless-driver)

**Kapan RLS tetap berguna lewat serverless function?**

Hanya jika function **secara eksplisit menyuntikkan identitas** ke sesi database. Neon mendokumentasikan pola ini menggunakan `set_config` di dalam transaksi:

```javascript
const [, my_table] = await sql.transaction([
 sql`SELECT set_config('request.jwt.claims', ${claims}, true)`,
 sql`SELECT * FROM my_table`,
]);
```

> "This pattern allows you to: Verify JWTs using your own authentication logic; Set the JWT claims in the database session context; Access JWT claims in your RLS policies; Execute multiple queries within a single transaction while maintaining the auth context."
> — [Neon serverless driver](https://neon.com/docs/serverless/serverless-driver)

**Tapi untuk FlashStruct, pola ini tidak relevan** — tidak ada login, jadi tidak ada identitas pengguna untuk disuntikkan.

### 4.4 Pola keamanan yang benar untuk Neon tanpa login pengguna

**Prinsipnya: jangan andalkan kerahasiaan URL. Andalkan pembatasan hak akses database.**

Ini pola yang direkomendasikan untuk FlashStruct, disusun dari dokumentasi resmi:

**Langkah 1 — Aktifkan RLS di semua tabel yang diekspos.**

```sql
ALTER TABLE modul ENABLE ROW LEVEL SECURITY;
ALTER TABLE bagian_modul ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcard ENABLE ROW LEVEL SECURITY;
ALTER TABLE soal ENABLE ROW LEVEL SECURITY;
ALTER TABLE opsi_soal ENABLE ROW LEVEL SECURITY;
```

> *"Once enabled, all access is blocked by default until a policy is created."* — [Access control & security](https://neon.com/docs/data-api/access-control)

**Langkah 2 — Buat policy SELECT untuk role `anonymous`.**

```sql
CREATE POLICY "public read modul" ON modul
 FOR SELECT TO anonymous
 USING (true);
```

**Langkah 3 — Berikan GRANT SELECT (dan hanya SELECT) ke role `anonymous`.**

```sql
GRANT USAGE ON SCHEMA public TO anonymous;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anonymous;
```

> "By default, this role has **no permissions**. You can explicitly `GRANT` SELECT permissions to this role to expose public data (for example, a product list or public blog posts) without requiring users to log in. **Typically, you'd only `GRANT SELECT` to this role, not write permissions.**"
> — [Access control & security](https://neon.com/docs/data-api/access-control)

**Langkah 4 — Jangan pernah grant INSERT/UPDATE/DELETE ke `anonymous`.**

Ini pertahanan utama. Bahkan jika RLS salah dikonfigurasi, tanpa `GRANT` write, tidak ada yang bisa menulis.

**Mengapa `USING (true)` aman di sini?**

Data API Advisors secara eksplisit **mengecualikan** pola ini dari peringatan:

> "Note: `USING (true)` on SELECT-only policies is excluded from this check, as it is a common pattern for **intentional public read access**."
> — [Data API Advisors](https://neon.com/docs/data-api/database-advisor)

Jadi `USING (true)` untuk `FOR SELECT TO anonymous` adalah pola yang **diakui resmi**, bukan workaround.

**Langkah 5 — Batasi CORS ke domain produksi.**

Setting `server_cors_allowed_origins` mengontrol domain mana yang boleh memanggil API dari browser:

> "**CORS allowed origins** — **Default:** `Empty (Allows all origins)` — Controls which web domains are permitted to fetch data from your API via the browser. **Empty:** Allows `*` (any domain). Useful for development. **Production:** List your specific domains (for example, `https://myapp.com`) to prevent unauthorized websites from querying your API."
> — [Managing the Data API](https://neon.com/docs/data-api/manage)

> **Catatan penting:** CORS adalah pembatasan **browser**, bukan kontrol keamanan sejati. Siapa pun bisa memanggil API dengan `curl` dan mengabaikan CORS. Jadi CORS berguna untuk mencegah penyalahgunaan dari situs lain, tapi **bukan pengganti RLS**.

**Langkah 6 — Jalankan Data API Advisors secara berkala.**

> "The advisors also check for common performance issues like unindexed foreign keys and table bloat, helping you catch issues before they reach production."
> — [Data API Advisors](https://neon.com/docs/data-api/database-advisor)

Tersedia di Console: **Monitoring > Data API Advisors**, atau via API: `GET /projects/{project_id}/advisors`.

**Ringkasan model keamanan untuk FlashStruct:**

| Lapisan | Kontrol | Sumber |
|---|---|---|
| 1 | Connection string **tidak pernah** masuk browser | [Data API Get Started](https://neon.com/docs/data-api/get-started) |
| 2 | Role `anonymous` hanya punya `GRANT SELECT` | [Access control](https://neon.com/docs/data-api/access-control) |
| 3 | RLS enabled + policy SELECT eksplisit | [Row-Level Security](https://neon.com/docs/guides/row-level-security) |
| 4 | CORS allowlist ke domain produksi | [Managing Data API](https://neon.com/docs/data-api/manage) |
| 5 | Data API Advisors untuk audit berkala | [Data API Advisors](https://neon.com/docs/data-api/database-advisor) |

**Kesimpulan:** Untuk aplikasi read-only tanpa login, model keamanannya **lebih sederhana** daripada aplikasi dengan login — karena tidak ada identitas pengguna yang perlu dibedakan. Yang perlu dijaga hanya satu hal: **`anonymous` tidak boleh punya hak tulis.**

---

## 5. Koneksi & Connection Pooling

### 5.1 Apa itu connection pooling dan kenapa penting untuk serverless?

**Masalahnya:** setiap koneksi Postgres membuat proses OS baru dan memakan memori/CPU. Postgres membatasi jumlah koneksi berdasarkan RAM yang tersedia.

> "Each Postgres connection creates a new process in the operating system, consuming memory and CPU resources. Postgres limits the number of connections based on available RAM."
> — [Connection pooling](https://neon.com/docs/connect/connection-pooling)

**Batas `max_connections` di Neon bervariasi menurut ukuran compute:**

| Compute size (CU) | RAM | `max_connections` |
|---|---|---|
| 0.25 | 1 GB | 104 |
| 0.50 | 2 GB | 209 |
| 1 | 4 GB | 419 |
| 2 | 8 GB | 839 |
| 9–56 | 36–224 GB | 4000 (capped) |

> Sumber: [Connection pooling](https://neon.com/docs/connect/connection-pooling)

**Skenario yang melampaui batas ini** — perhatikan poin pertama:

> "**Common scenarios that exceed these limits:** Serverless functions (each invocation may open a connection); Connection-per-request web frameworks; Multiple application instances without proper connection management; Applications that don't close connections properly"
> — [Connection pooling](https://neon.com/docs/connect/connection-pooling)

**Solusinya:** Neon memakai **PgBouncer** untuk pooling, dengan konfigurasi:

```ini
[pgbouncer]
pool_mode=transaction
max_client_conn=10000
default_pool_size=0.9 * max_connections
max_prepared_statements=1000
query_wait_timeout=120
```

> "These settings are not user-configurable." — [Connection pooling](https://neon.com/docs/connect/connection-pooling)

**Tiga jenis limit yang berbeda — jangan tertukar:**

| Limit | Nilai | Mengontrol apa |
|---|---|---|
| `max_client_conn` | 10.000 | Koneksi klien ke PgBouncer |
| `default_pool_size` | 90% dari `max_connections` | Koneksi aktif per user per database |
| `max_connections` | Bervariasi menurut compute | Koneksi langsung ke Postgres |

> "**Important:** The 10,000 connection limit does not mean 10,000 simultaneous query results."
> — [Connection pooling](https://neon.com/docs/connect/connection-pooling)

### 5.2 Perbedaan "pooled connection" vs "direct connection"

Perbedaannya hanya pada hostname — ada tidaknya suffix `-pooler`:

```text
# Pooled (melalui PgBouncer)
postgresql://user:pass@ep-cool-rain-123456-pooler.us-east-2.aws.neon.tech/neondb?sslmode=require

# Direct (langsung ke Postgres)
postgresql://user:pass@ep-cool-rain-123456.us-east-2.aws.neon.tech/neondb?sslmode=require
```

> Sumber: [Choosing your connection method](https://neon.com/docs/connect/choose-connection)

**Mode pooling: `transaction`.** Ini berarti koneksi dikembalikan ke pool setelah setiap transaksi selesai, yang membatasi beberapa fitur Postgres:

**Tidak didukung pada pooled connection:**
- `SET` / `RESET` (session variables)
- `LISTEN` / `NOTIFY`
- `WITH HOLD CURSOR`
- `PREPARE` / `DEALLOCATE` (SQL-level prepared statements)
- Temporary tables dengan `PRESERVE` / `DELETE ROWS`
- `LOAD` statement
- Session-level advisory locks

> Sumber: [Connection pooling](https://neon.com/docs/connect/connection-pooling)

**Masalah paling umum — `SET search_path`:**

```sql
SET search_path TO myschema;
SELECT * FROM mytable; -- Works in this transaction
-- Transaction ends, connection returns to pool
SELECT * FROM mytable; -- ERROR: relation "mytable" does not exist
```

**Solusi:** pakai direct connection, sebutkan schema eksplisit (`SELECT * FROM myschema.mytable`), atau set di level role (`ALTER ROLE user1 SET search_path TO myschema, public;`).

### 5.3 Kapan pakai yang mana?

Tabel resmi dari [Connection pooling](https://neon.com/docs/connect/connection-pooling):

| Use Case | Connection Type | Alasan |
|---|---|---|
| Serverless functions | **Pooled** | Banyak koneksi berumur pendek |
| Web applications | **Pooled** | Banyak request konkuren |
| Connection-per-request frameworks | **Pooled** | Churn koneksi tinggi |
| Schema migrations | **Direct** | Tool mungkin tidak mendukung transaction pooling |
| Long-running analytics queries | **Direct** | Menghindari pool contention |
| `pg_dump` / `pg_restore` | **Direct** | Memakai statement `SET` |
| Logical replication | **Direct** | Butuh koneksi persisten |
| Admin tasks | **Direct** | Mungkin butuh fitur session-level |

**Rekomendasi umum:** *"Use pooled connections by default."* — [Choosing your connection method](https://neon.com/docs/connect/choose-connection)

### 5.4 Bagaimana dengan FlashStruct?

**Untuk FlashStruct, connection pooling praktis tidak relevan — dan ini kabar baik.**

Alasannya: **Data API tidak memakai connection pool sama sekali.** Ia memakai HTTP stateless:

> "**Connectionless scalability.** Short-lived HTTP requests replace persistent TCP connections, so you avoid connection pool exhaustion and scale to thousands of concurrent users."
> — [Data API Overview](https://neon.com/docs/data-api/overview)

> "Applications can query tables **without a connection pool or SQL driver**."
> — [Data API Get Started](https://neon.com/docs/data-api/get-started)

Tabel rekomendasi resmi pun menulis **"N/A"** di kolom Pooling untuk baris "Client-side (browser)" — [Choose connection](https://neon.com/docs/connect/choose-connection).

**Di mana pooling tetap perlu diperhatikan:**

Hanya di **workflow migrasi** (dari mesin lokal, bukan dari browser). Dokumentasi contoh aplikasi Neon memakai pooled connection string untuk migrasi:

```env
# Database Connection String (for migrations)
# ... (select "Pooled connection")
DATABASE_URL=postgresql://user:password@your-project-id.pooler.region.neon.tech/neondb?sslmode=require
```

> — [Data API tutorial](https://neon.com/docs/data-api/demo)

Namun untuk **schema migrations**, tabel rekomendasi menyatakan **Direct** lebih tepat — *"Schema migrations → Direct → Tools may not support transaction pooling"* — [Connection pooling](https://neon.com/docs/connect/connection-pooling).

**Saran praktis:** untuk migrasi skema (Drizzle Kit, Prisma Migrate), pakai **direct connection**. Untuk aplikasi runtime (browser → Data API), tidak perlu memikirkan pooling sama sekali.

---

## 6. Scale to Zero

### 6.1 Berapa lama Neon "tidur" saat idle?

**5 menit.**

> "When your database is inactive, it automatically scales to zero after **5 minutes**. This means you pay only for active time instead of 24/7 compute usage. No manual intervention is required."
> — [Scale to Zero](https://neon.com/docs/introduction/scale-to-zero)

**Bisa dikonfigurasi? Tergantung plan:**

| Plan | Scale to zero | Sumber |
|---|---|---|
| **Free** | **Setelah 5 menit; tidak bisa dimatikan** | [Plans](https://neon.com/docs/introduction/plans) |
| Launch | Setelah 5 menit; bisa dimatikan | [Plans](https://neon.com/docs/introduction/plans) |
| Scale | Bisa dikonfigurasi (1 menit sampai selalu aktif) | [Plans](https://neon.com/docs/introduction/plans) |

> "For Neon Free plan users, this setting is fixed. Paid plan users can disable the scale-to-zero setting to maintain an always-active compute."
> — [Scale to Zero](https://neon.com/docs/introduction/scale-to-zero)

**Catatan:** *"Scale to zero is only available for computes up to 16 CU in size. Computes larger than 16 CU remain always active."* — [Scale to Zero](https://neon.com/docs/introduction/scale-to-zero). Tidak relevan untuk FlashStruct (Free plan maksimal 2 CU).

**Saat suspended, compute = $0:** *"Compute suspends automatically after inactivity (scale-to-zero); no CU-hours accrue while suspended."* — [Pricing](https://neon.com/pricing)

### 6.2 Berapa lama "bangun" saat ada request? Apakah ada cold start yang terasa?

**"Dalam beberapa ratus milidetik" — dan ini terukur, bukan klaim pemasaran.**

> "Once you query the database again, it reactivates automatically within **a few hundred milliseconds**."
> — [Scale to Zero](https://neon.com/docs/introduction/scale-to-zero)

> "During this process, a compute transitions from an idle state to an active state to process requests. Currently, **activating a Neon compute from an idle state typically takes a few hundred milliseconds** not counting other factors that can add to latencies such as the physical distance between your application and database or startup times of other services that participate in your connection process."
> — [Connection latency and timeouts](https://neon.com/docs/connect/connection-latency)

**Apakah terasa oleh pengguna? Jawaban jujur: tergantung.**

Untuk FlashStruct — aplikasi belajar dengan konten read-only — skenario terburuknya adalah: pengguna pertama setelah 5 menit idle merasakan tambahan **~300 ms** pada request pertama. Setelah itu compute aktif dan request berikutnya normal. Untuk aplikasi seperti ini, itu **umumnya tidak terasa** karena:

- Hanya terjadi sekali per periode idle, bukan setiap request
- Halaman React umumnya sudah dimuat; yang tertunda hanya data fetch
- 300 ms berada di ambang batas persepsi manusia (~100–200 ms untuk "instan", tapi masih di bawah ambang "mengganggu")

**Yang bisa dilakukan untuk memitigasi:**

> "Consider combining this strategy with Neon's _Autoscaling_ feature... For workloads where occasional cold starts are acceptable, you can also adjust the timeout period. The default is 5 minutes. You can extend it up to 7 days to reduce how often cold starts occur."
> — [Connection latency and timeouts](https://neon.com/docs/connect/connection-latency)

**Catatan penting:** memperpanjang timeout atau mematikan scale-to-zero **hanya tersedia di paid plan** — di Free plan ini fixed 5 menit.

**Strategi lain yang direkomendasikan dokumentasi:**
- Tempatkan aplikasi dan database di region yang sama: *"A key strategy for reducing connection latency is ensuring that your application and database are hosted in the same region, or as close as possible, geographically."* — [Connection latency](https://neon.com/docs/connect/connection-latency)
- Bangun retry dengan exponential backoff: *"Like any cloud database service, Neon may occasionally experience brief connection drops during maintenance, updates, or network interruptions. When using the Neon serverless driver, especially over HTTP, you should implement retry logic to handle these transient errors gracefully."* — [Neon serverless driver](https://neon.com/docs/serverless/serverless-driver)

**Region Neon yang tersedia** (pilih yang terdekat dengan pengguna FlashStruct):

> US East (N. Virginia) `aws-us-east-1` · US East (Ohio) `aws-us-east-2` · US West (Oregon) `aws-us-west-2` · Europe (Frankfurt) `aws-eu-central-1` · Europe (London) `aws-eu-west-2` · Asia Pacific (Singapore) `aws-ap-southeast-1` · Asia Pacific (Sydney) `aws-ap-southeast-2` · South America (São Paulo) `aws-sa-east-1`
> — [Regions](https://neon.com/docs/introduction/regions)

**Penting:** *"After you select a region for a Neon project, it cannot be changed for that project."* — [Regions](https://neon.com/docs/introduction/regions). **Pilih region dengan benar saat membuat project.** Untuk pengguna di Indonesia, `aws-ap-southeast-1` (Singapore) adalah pilihan paling logis.

**Catatan tambahan khusus Data API:** changelog menyebut Neon telah mengeliminasi cold start di lapisan API:

> "We've also continued our performance enhancements, including **eliminating API cold starts**, as we prepare the Data API for GA."
> — [Changelog](https://neon.com/docs/changelog) (entri "Data API — more improvements")

Ini berarti cold start yang tersisa hanyalah cold start **compute database**, bukan cold start lapisan API. Perlu dicatat bahwa klaim "eliminating API cold starts" ini berasal dari entri changelog sebelum GA dan **tidak diverifikasi ulang** apakah benar-benar nol dalam praktik — lihat [§ Catatan Ketidakpastian](#catatan-ketidakpastian).

### 6.3 Apakah data hilang saat scale to zero?

**Tidak. Data sama sekali tidak hilang.**

Ini bukan jaminan kosong — ada alasan arsitekturalnya. Neon memisahkan **compute** dan **storage** menjadi dua lapisan independen:

> "Instead of running Postgres as a single stateful system tied to a VM and its filesystem, Lakebase Postgres is a serverless database that splits the system into two independent layers: compute and storage. These layers communicate over the network, with a stream of write-ahead log (WAL) records connecting them. **This separation is what puts Lakebase Postgres in the lakebase category of OLTP databases. Compute can scale up, scale down, go idle, and be restarted instantly without risking data loss or requiring data movement.**"
> — [The lakebase architecture](https://neon.com/docs/introduction/architecture-overview)

**Compute layer bersifat ephemeral:**

> "**Ephemeral compute layer**: optimized for latency and execution. This layer runs Postgres, executing queries and transactions using RAM and local NVMe for performance. **Compute nodes do not own durable state and can be replaced freely.**"
> — [The lakebase architecture](https://neon.com/docs/introduction/architecture-overview)

**Storage layer bersifat durable:**

> "**Durable storage layer**: optimized for correctness, history, and scale. This layer defines durability by replicating WAL via quorum, materializes Postgres pages on demand, and stores long-term, immutable history in object storage."
> — [The lakebase architecture](https://neon.com/docs/introduction/architecture-overview)

**Mekanisme durability:**

> "A transaction is considered committed once that WAL has been acknowledged by a quorum of safekeepers... **No single machine defines the durable state of the database.**"
> — [The lakebase architecture](https://neon.com/docs/introduction/architecture-overview)

**Ringkasnya:** scale to zero hanya mematikan compute (mesin yang menjalankan query). Data ada di lapisan storage yang terpisah dan tetap utuh. Saat compute bangun, ia "attach" ke history yang sudah ada:

> "When compute starts, it simply attaches to existing database history rather than reconstructing local state."
> — [The lakebase architecture](https://neon.com/docs/introduction/architecture-overview)

**Untuk FlashStruct, ini berarti:** konten di database aman sepenuhnya, tidak peduli seberapa lama aplikasi tidak diakses.

### 6.4 Perbandingan scale-to-zero: Neon vs Supabase

Ini salah satu **perbedaan paling penting** untuk FlashStruct.

| Aspek | Neon Free | Supabase Free |
|---|---|---|
| **Perilaku saat idle** | Scale to zero setelah **5 menit** | **Pause setelah 1 minggu** tidak aktif |
| **Recovery** | **Otomatis** — request berikutnya membangunkan dalam ~beberapa ratus ms | **Manual** — harus resume dari Dashboard |
| **Bisa dimatikan?** | Tidak (Free) | Tidak berlaku |
| **Data hilang?** | Tidak | Tidak |
| **Window pemulihan** | N/A (selalu bisa bangun) | Hingga 1 tahun setelah pause |
| **Sumber** | [Scale to Zero](https://neon.com/docs/introduction/scale-to-zero) | [supabase.com/pricing](https://supabase.com/pricing) |

**Detail Supabase** (dari [supabase.com/pricing](https://supabase.com/pricing), diakses 21 Sep 2026):

> "**Free** — Note: Free projects are paused after 1 week of inactivity. Limit of 2 active projects."
> "**Pausing** — After 1 week of inactivity (Free) / Never (Pro)"

**Mengapa ini penting untuk FlashStruct:**

FlashStruct adalah aplikasi belajar yang mungkin **tidak diakses selama berhari-hari** (misalnya saat libur kuliah atau masa sibuk). Dengan Supabase Free:

- Setelah 1 minggu tidak ada traffic → project **pause**
- Pengguna yang datang kembali akan menemukan **aplikasi error**
- Harus **resume manual** dari Dashboard — tidak bisa dilakukan pengguna

Dengan Neon Free:

- Setelah 5 menit idle → compute **suspend**
- Pengguna yang datang kembali → compute **bangun otomatis dalam beberapa ratus ms**
- **Aplikasi tetap berfungsi tanpa intervensi siapa pun**

**Ini keunggulan arsitektural Neon yang signifikan untuk kasus ini.** Dokumentasi Supabase sendiri mengakui perlunya mencegah pause dengan aktivitas berkala: *"Typically a few user requests to the database each day over the previous week is enough to keep the project from being paused."* — [Supabase Project Pausing](https://supabase.com/docs/guides/platform/free-project-pausing) (dirujuk dari riset sebelumnya, [01-RISET-TEKNIS.md](./01-RISET-TEKNIS.md)).

**Perbandingan kuota Free plan:**

| Item | Neon Free | Supabase Free |
|---|---|---|
| Jumlah project | **100** | 2 aktif |
| Storage database | 0.5 GB/project | 500 MB/project |
| Egress | 5 GB/project | 5 GB |
| Compute | **100 CU-hours/project** (≈ 0.25 CU × 400 jam) | Shared CPU, 500 MB RAM |
| API requests | Tidak disebutkan batasnya | **Unlimited API requests** |
| Auth MAU | 60.000 | 50.000 |
| Log retention | 1 hari | 1 hari |
| Backup | 1 manual snapshot | Tidak termasuk |
| Support | Community | Community |
| **Sumber** | [Neon Pricing](https://neon.com/pricing), [Neon Plans](https://neon.com/docs/introduction/plans) | [Supabase Pricing](https://supabase.com/pricing) |

**Catatan tentang 100 CU-hours:** *"Free: 100 CU-hours/project/month (enough to run a 0.25 CU compute in a project for 400 hours/month)."* — [Plans](https://neon.com/docs/introduction/plans). Karena compute suspend saat idle, CU-hours hanya terpakai saat benar-benar ada traffic. Untuk aplikasi belajar dengan traffic sporadis, **100 CU-hours sangat longgar.**

**Yang terjadi jika kuota Free habis:**

> "On the Free plan, when you run out of CU-hours or public network transfer, your compute is suspended until the next billing period or until you upgrade. Exceeding the 0.5 GB storage cap causes operations that increase storage (inserts, updates, and deletes) to fail until you free space or upgrade. Branch creation fails once you reach 10 branches per project. **None of these limits delete your data.**"
> — [Plans](https://neon.com/docs/introduction/plans)

Poin terakhir itu penting: **melebihi kuota tidak menghapus data.**

---

## 7. Perbandingan Jujur: Neon vs Supabase untuk FlashStruct

### 7.1 Tabel perbandingan utama

| Kriteria | Neon | Supabase | Untuk FlashStruct |
|---|---|---|---|
| **REST API otomatis** | Neon Data API, PostgREST-compatible, **GA 18 Sep 2026** | PostgREST, sudah mature bertahun-tahun | **Seri** — keduanya memenuhi |
| **Status SDK klien** | `@neondatabase/neon-js` `0.7.0-beta` (beta) | `@supabase/supabase-js` `2.116.0` stabil | **Supabase unggul** |
| **Query embedding/join** | PostgREST-compatible penuh | PostgREST asli | **Seri** |
| **Akses browser tanpa backend** | Resmi didukung & direkomendasikan | Resmi didukung | **Seri** |
| **Pola data publik tanpa login** | Role `anonymous` + `GRANT SELECT` | Role `anon` + `GRANT SELECT` | **Seri** — filosofi identik |
| **RLS** | Wajib untuk Data API | Wajib untuk Data API | **Seri** |
| **Kredensial di browser** | URL HTTPS tanpa kredensial | URL + anon key (JWT) | **Neon sedikit lebih bersih** |
| **Perilaku idle** | Scale to zero 5 mnt, **bangun otomatis** | **Pause setelah 1 minggu**, resume manual | **Neon unggul jelas** |
| **Cold start** | ~beberapa ratus ms | N/A (selama tidak pause) | **Seri** (masing-masing punya trade-off) |
| **Free tier: storage** | 0.5 GB | **500 MB** | **Neon** (0.5 GB = ~512 MB, hampir sama) |
| **Free tier: jumlah project** | **100** | 2 aktif | **Neon unggul** |
| **Free tier: compute** | 100 CU-hours/project | Shared CPU, 500 MB RAM | **Neon** (lebih terukur) |
| **Free tier: egress** | 5 GB/project | 5 GB | **Seri** |
| **Backup di Free** | 1 manual snapshot | Tidak termasuk | **Neon unggul** |
| **Database branching** | 10 branch/project di Free | Hanya Pro ($0.01344/branch/jam) | **Neon unggul** |
| **Integrasi Vercel resmi** | Vercel-Managed + Neon-Managed | Ada integrasi | **Seri** |
| **Ekonomi serverless (pooling)** | PgBouncer built-in + Data API stateless | Supavisor + PostgREST | **Seri** |
| **Kematangan ekosistem** | Baru GA (Sep 2026) | Mature, komunitas besar | **Supabase unggul** |
| **Dokumentasi** | Sangat baik, baru diperbarui | Sangat baik | **Seri** |
| **Menggantikan Supabase** | Ada panduan migrasi resmi | — | **Neon menyediakan jalur** |

### 7.2 Dari sisi kemudahan setup

| Langkah | Neon | Supabase |
|---|---|---|
| Buat project | Console / CLI / API | Console |
| Aktifkan REST API | Enable Data API (per branch, per database) | Otomatis aktif |
| Konfigurasi auth | Pilih provider atau `anonymous` role | Sudah ada (anon key) |
| Set RLS | Wajib, tulis SQL | Wajib, tulis SQL |
| Grant permissions | Manual `GRANT SELECT TO anonymous` | Manual `GRANT SELECT TO anon` |
| Env var di frontend | 1 URL (tanpa kredensial) | URL + anon key (2 nilai) |
| Install SDK | `npm i @neondatabase/neon-js` (beta) | `npm i @supabase/supabase-js` (stabil) |

**Penilaian jujur:** Neon butuh **satu langkah ekstra** (enable Data API), dan Data API diaktifkan per-branch sehingga perlu diingat saat membuat branch baru. Supabase REST API aktif otomatis sejak project dibuat.

**Tapi Neon punya satu keuntungan:** hanya **satu** env var di frontend, dan nilai itu tidak sensitif sama sekali. Dengan Supabase, `anon` key adalah JWT — tidak sensitif jika RLS benar, tapi secara psikologis lebih terasa "seperti rahasia" dan lebih mudah salah ditangani.

### 7.3 Dari sisi jumlah kode yang harus ditulis

**Praktis identik.** Bandingkan:

```typescript
// Supabase
import { createClient } from '@supabase/supabase-js';
const supabase = createClient(
 import.meta.env.VITE_SUPABASE_URL,
 import.meta.env.VITE_SUPABASE_ANON_KEY
);
const { data } = await supabase.from('modul').select('*');
```

```typescript
// Neon
import { createClient } from '@neondatabase/neon-js';
const client = createClient(import.meta.env.VITE_NEON_DATABASE_URL);
const { data } = await client.from('modul').select('*');
```

Panduan migrasi resmi Neon menegaskan query tidak perlu diubah:

> "**Your database queries stay the same** — Your existing `client.from()` queries work without any code changes:
> ```typescript
> // Same as Supabase - no changes needed
> const { data: posts } = await client.from('posts').select('*');
> ```"
> — [Migrate from Supabase](https://neon.com/docs/auth/migrate/from-supabase)

Bahkan ada adapter kompatibilitas Supabase:

> "**SupabaseAuthAdapter**: Supabase-compatible API for easy migration. See the [migration guide](https://neon.com/docs/auth/migrate/from-supabase)."
> — [JavaScript SDK reference](https://neon.com/docs/reference/javascript-sdk)

**Catatan:** adapter ini untuk **Auth**, yang tidak dipakai FlashStruct. Tapi fakta bahwa Neon membangun jalur migrasi dari Supabase menunjukkan kompatibilitasnya memang diprioritaskan.

**SQL yang harus ditulis:** keduanya sama-sama butuh RLS + GRANT. Tidak ada perbedaan jumlah kode yang berarti.

### 7.4 Dari sisi keamanan

| Aspek | Neon | Supabase |
|---|---|---|
| Connection string di browser | Tidak pernah | Tidak pernah |
| Yang diekspos | URL HTTPS | URL + anon key (JWT) |
| Kontrol akses | RLS + GRANT ke role `anonymous` | RLS + GRANT ke role `anon` |
| Isolasi default | RLS disabled = **semua baris terlihat** | Sama (perilaku Postgres) |
| Tooling audit | Data API Advisors built-in | Supabase Lints |
| CORS allowlist | Setting tersedia | Setting tersedia |

**Keduanya sama-sama mengandalkan RLS dengan benar.** Dan keduanya punya jebakan yang sama: **jika RLS tidak diaktifkan, semua data terbuka.** Neon memperingatkan ini secara eksplisit:

> "**Warning: RLS disabled means no filtering.** If RLS is disabled on a table, any authenticated user can see all rows in that table."
> — [Access control & security](https://neon.com/docs/data-api/access-control)

**Untuk FlashStruct, keamanan bukan pembeda utama** — karena datanya memang publik (konten edukasi). Yang perlu dijaga hanya: **tidak ada yang bisa menulis.** Itu dicapai dengan tidak memberi `GRANT` write ke `anonymous`, dan berlaku sama di kedua platform.

**Satu detail menarik:** Neon Data API Advisors dibangun berdasarkan lints Supabase:

> "Database lints originally based on [open-source lints](https://github.com/supabase/supabase/blob/master/apps/studio/lib/api/self-hosted/lints.ts) from the Supabase project, Apache 2.0."
> — [Data API Advisors](https://neon.com/docs/data-api/database-advisor)

Ini bukti bahwa tooling keamanannya setara secara konsep.

### 7.5 Dari sisi risiko

| Risiko | Neon | Supabase |
|---|---|---|
| **API berubah** | Rendah (GA), tapi SDK masih beta | Sangat rendah (mature) |
| **Vendor lock-in** | Rendah — Postgres standar, bisa `pg_dump` | Sedang — PostgREST + Auth terintegrasi |
| **Data hilang** | Sangat rendah (arsitektur durable storage) | Sangat rendah |
| **Aplikasi mati karena idle** | **Sangat rendah** (auto-wake) | **Sedang-tinggi** (pause 1 minggu, resume manual) |
| **Perubahan harga** | Tidak ada jaminan | Tidak ada jaminan |
| **Free tier dihapus** | Tidak ada jaminan | Tidak ada jaminan |
| **Kuota habis** | Compute suspend sampai periode berikutnya | Project pause |

**Risiko terbesar untuk FlashStruct adalah pause, dan itu ada di Supabase, bukan Neon.**

**Risiko terbesar Neon adalah kematangan SDK.** Tapi mitigasinya mudah: pakai HTTP langsung (`fetch`) alih-alih SDK, karena PostgREST adalah protokol HTTP biasa:

```bash
curl -X GET 'https://your-data-api-endpoint/rest/v1/modul?select=*' \
 -H 'Content-Type: application/json'
```

> Sumber pola: [Data API Get Started](https://neon.com/docs/data-api/get-started) — *"Query the Data API directly using any HTTP client."*

Dengan `fetch` langsung, FlashStruct **tidak bergantung pada SDK beta sama sekali** — hanya pada endpoint HTTP yang sudah GA dan PostgREST-compatible. Ini menghilangkan risiko SDK beta sepenuhnya.

### 7.6 Dari sisi biaya

| Skenario | Neon Free | Supabase Free |
|---|---|---|
| Biaya bulanan | **$0** | **$0** |
| Jika melebihi kuota | Compute suspend sampai periode berikutnya; data aman | Project pause; data aman |
| Upgrade jika perlu | Launch: pay-as-you-go, tanpa minimum bulanan | Pro: **$25/bulan** + compute |
| Biaya compute tambahan | $0.106/CU-hour (Launch) | $10/bulan untuk Micro instance |
| **Sumber** | [Neon Pricing](https://neon.com/pricing) | [Supabase Pricing](https://supabase.com/pricing) |

**Detail penting tentang struktur biaya:**

**Neon** — pay-as-you-go murni, **tanpa minimum bulanan**:
> "Paid plans are pay-as-you-go: usage is metered hourly and billed at the end of the month, with no monthly minimum."
> — [Neon Pricing](https://neon.com/pricing)

> "Invoices under $0.50 are not collected." — [Neon Pricing](https://neon.com/pricing)

**Supabase** — ada langganan tetap:
> "**Pro** - from $25/month" — [Supabase Pricing](https://supabase.com/pricing)

**Untuk FlashStruct, keduanya $0.** Jika nanti butuh upgrade, Neon secara struktural lebih murah untuk beban kerja sporadis — karena biaya hanya muncul saat compute aktif, dan compute otomatis suspend saat idle.

**Contoh estimasi Neon Launch** untuk beban kerja ringan (dari dokumentasi):
- Compute: ~10 CU-hours = $1.06
- Root branch storage 2 GB = $0.70
- **Total: $2.31/bulan**

> — [Neon Plans § Usage-based cost examples](https://neon.com/docs/introduction/plans)

### 7.7 Mana yang lebih tepat untuk aplikasi read-only tanpa login?

**Neon lebih tepat, dengan alasan yang spesifik dan bukan preferensi.**

**Alasan 1 — Perilaku idle sesuai dengan pola pemakaian FlashStruct.**

FlashStruct adalah aplikasi belajar. Pola pemakaiannya **sporadik**: dipakai intensif menjelang ujian, lalu tidak dibuka berhari-hari atau berminggu-minggu. Ini persis skenario terburuk untuk Supabase Free (pause 1 minggu, resume manual) dan persis skenario terbaik untuk Neon (suspend 5 menit, auto-wake).

Dengan Supabase Free, ada risiko nyata: pengguna kembali setelah 2 minggu dan menemukan aplikasi mati, tanpa cara memperbaikinya selain membuka Dashboard Supabase. Dengan Neon, aplikasi **selalu berfungsi** tanpa intervensi.

**Alasan 2 — Tidak ada login berarti RLS disederhanakan, bukan dihilangkan.**

Untuk aplikasi read-only tanpa login, RLS tidak perlu logika `auth.user_id()` yang kompleks. Cukup satu policy `FOR SELECT TO anonymous USING (true)`. Neon mengakui pola ini sebagai valid: *"`USING (true)` on SELECT-only policies is excluded from this check, as it is a common pattern for intentional public read access."* — [Data API Advisors](https://neon.com/docs/data-api/database-advisor)

Keamanan dijaga dengan **tidak memberi hak tulis** ke role `anonymous` — kontrol yang sederhana dan sulit salah.

**Alasan 3 — Data API menghilangkan kebutuhan connection pooling sepenuhnya.**

Karena tidak ada backend, tidak ada masalah "setiap invocation membuka koneksi baru". Data API stateless: *"Short-lived HTTP requests replace persistent TCP connections, so you avoid connection pool exhaustion."* — [Data API Overview](https://neon.com/docs/data-api/overview)

**Alasan 4 — Kuota Free lebih longgar untuk kasus ini.**

100 project, 0.5 GB storage, 100 CU-hours/project, 10 branch/project, 1 manual snapshot. Untuk konten edukasi teks (modul, flashcard, soal), 0.5 GB sangat longgar. Bandingkan dengan Supabase: 2 project aktif, 500 MB.

**Kapan Supabase tetap lebih tepat?**

- Jika butuh **Auth terintegrasi** dengan UI siap pakai (Neon punya Managed Better Auth, tapi lebih baru)
- Jika butuh **Storage/Realtime** yang sudah matang (Neon punya Object Storage, tapi dalam beta per changelog 2026-09-04)
- Jika **stabilitas SDK adalah prioritas absolut** dan tidak mau menyentuh apa pun yang berlabel beta
- Jika sudah punya kode Supabase yang berjalan dan tidak ada masalah — **migrasi tanpa alasan jelas tidak sepadan**

**Untuk FlashStruct secara spesifik:** proyek ini masih dalam tahap perencanaan (belum ada kode produksi). Jadi tidak ada biaya migrasi. Dan masalah pause Supabase adalah **masalah nyata** yang akan dihadapi. **Pindah ke Neon sebelum menulis kode lebih baik daripada bermigrasi nanti.**

---

## Rekomendasi

### Rekomendasi utama: Gunakan Neon, bukan Supabase

**Alasan ringkas:**

1. **Kemampuan teknis yang dibutuhkan Supabase sudah setara di Neon.** Neon Data API adalah PostgREST-compatible penuh, GA sejak 18 Sep 2026, dan dirancang untuk browser. Semua pola yang direncanakan (embedding relasi, filter, ordering) bekerja tanpa perubahan arsitektur.

2. **Masalah pause Supabase adalah masalah nyata untuk FlashStruct.** Supabase Free pause setelah 1 minggu idle dan butuh resume manual. Neon scale-to-zero setelah 5 menit tapi **bangun otomatis**. Untuk aplikasi belajar dengan pemakaian sporadis, ini perbedaan yang menentukan.

3. **Keamanan setara, dan lebih sederhana.** Tidak ada connection string di browser. Yang diekspos hanya URL HTTPS. Otorisasi lewat RLS + GRANT ke role `anonymous`, tanpa hak tulis. Ini model yang sama dengan Supabase, hanya dengan satu env var alih-alih dua.

4. **Biaya Free lebih longgar.** 100 project (vs 2), 0.5 GB (vs 500 MB), 100 CU-hours/project, plus branching dan snapshot yang tidak ada di Supabase Free.

5. **Tidak ada biaya migrasi.** FlashStruct belum menulis kode produksi. Keputusan ini harus diambil sekarang, bukan nanti.

### Arsitektur yang direkomendasikan

```
┌─────────────────────────────────────────────────────────────┐
│ Browser (React 19 + Vite + TS, di Vercel Hobby) │
│ │
│ • Konten: fetch dari Neon Data API (read-only) │
│ • Progres: localStorage │
│ • TIDAK ada: connection string, login, backend │
└──────────────────────────┬──────────────────────────────────┘
 │ HTTPS
 │ GET https://ep-xxx.apirest.../rest/v1/modul?select=...
 │ (tanpa Authorization header, atau anonymous JWT)
 ▼
┌─────────────────────────────────────────────────────────────┐
│ Neon Data API (GA) — stateless, PostgREST-compatible │
│ • Validasi request → switch ke role `anonymous` │
│ • Enforce RLS │
│ • TIDAK ada connection pooling yang perlu dikelola │
└──────────────────────────┬──────────────────────────────────┘
 │
 ▼
┌─────────────────────────────────────────────────────────────┐
│ PostgreSQL (Neon Free, region aws-ap-southeast-1) │
│ • RLS enabled di semua tabel │
│ • GRANT SELECT TO anonymous (hanya SELECT!) │
│ • Scale to zero 5 menit, auto-wake ~beberapa ratus ms │
└─────────────────────────────────────────────────────────────┘
```

### Langkah implementasi

**1. Buat project Neon di region yang tepat.**
Region **tidak bisa diubah** setelah project dibuat — [Regions](https://neon.com/docs/introduction/regions). Untuk pengguna Indonesia: `aws-ap-southeast-1` (Singapore).

**2. Enable Data API.**
Via Console (**Postgres database > Data API**) atau CLI: `neon data-api create --database neondb`. Karena tidak ada login, **tidak perlu** mengonfigurasi auth provider. Biarkan role `anonymous` menangani akses publik — [Data API Get Started](https://neon.com/docs/data-api/get-started).

**3. Tulis skema + RLS + GRANT.**

```sql
-- RLS wajib di setiap tabel yang diekspos
ALTER TABLE modul ENABLE ROW LEVEL SECURITY;
ALTER TABLE bagian_modul ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcard ENABLE ROW LEVEL SECURITY;
ALTER TABLE soal ENABLE ROW LEVEL SECURITY;
ALTER TABLE opsi_soal ENABLE ROW LEVEL SECURITY;

-- Policy baca publik
CREATE POLICY "public read" ON modul FOR SELECT TO anonymous USING (true);
CREATE POLICY "public read" ON bagian_modul FOR SELECT TO anonymous USING (true);
CREATE POLICY "public read" ON flashcard FOR SELECT TO anonymous USING (true);
CREATE POLICY "public read" ON soal FOR SELECT TO anonymous USING (true);
CREATE POLICY "public read" ON opsi_soal FOR SELECT TO anonymous USING (true);

-- GRANT: HANYA SELECT
GRANT USAGE ON SCHEMA public TO anonymous;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anonymous;
```

> Pola dari [Access control & security](https://neon.com/docs/data-api/access-control) dan [Data API Get Started](https://neon.com/docs/data-api/get-started). **Jangan** berikan INSERT/UPDATE/DELETE.

**4. Set CORS ke domain produksi.**
Setting `server_cors_allowed_origins` — [Managing the Data API](https://neon.com/docs/data-api/manage).

**5. Frontend: pakai `fetch` langsung, bukan SDK beta.**

```typescript
const DATA_API = import.meta.env.VITE_NEON_DATA_API_URL;

export async function getModul() {
 const res = await fetch(
 `${DATA_API}/modul?select=id,judul,urutan,bagian_modul(id,judul,urutan,flashcard(id,pertanyaan,jawaban))&order=urutan.asc`
 );
 if (!res.ok) throw new Error(`Data API error: ${res.status}`);
 return res.json();
}
```

> **Mengapa `fetch` dan bukan SDK:** Data API adalah HTTP + PostgREST — protokol stabil yang sudah GA. SDK `@neondatabase/neon-js` masih `0.7.0-beta`. Dengan `fetch` langsung, FlashStruct hanya bergantung pada bagian yang sudah GA, menghilangkan risiko API beta berubah. Sintaks query-nya sama karena keduanya PostgREST — [SQL to PostgREST Converter](https://neon.com/docs/data-api/sql-to-rest).

**6. Jalankan Data API Advisors setelah setup.**
Console: **Monitoring > Data API Advisors**. Pastikan tidak ada error `rls_disabled_in_public` — [Data API Advisors](https://neon.com/docs/data-api/database-advisor).

**7. Setelah setiap perubahan skema, refresh schema cache.**
Console: tombol **Refresh schema cache**, atau `neon data-api refresh-schema`. Tanpa ini, tabel/kolom baru tidak akan dikenali — [Data API Get Started](https://neon.com/docs/data-api/get-started).

**8. Simpan `DATABASE_URL` hanya untuk migrasi — jangan pernah beri prefix `VITE_`.**

```env
# .env — HANYA untuk migrasi lokal, JANGAN di-commit
DATABASE_URL=postgresql://user:pass@ep-xxx.aws.neon.tech/neondb?sslmode=require

# Aman untuk frontend
VITE_NEON_DATA_API_URL=https://ep-xxx.apirest.ap-southeast-1.aws.neon.tech/neondb/rest/v1
```

### Kapan rekomendasi ini perlu ditinjau ulang

- Jika `@neondatabase/neon-js` keluar dari beta dan ada alasan kuat untuk memakainya
- Jika FlashStruct berubah dari read-only menjadi butuh write dari pengguna (akan butuh auth + RLS per-user)
- Jika Vercel mengubah kebijakan Hobby secara signifikan
- Jika Neon mengubah kuota Free plan

---

## Catatan Ketidakpastian

Hal-hal berikut **tidak dapat diverifikasi** dari sumber primer pada 21 September 2026, atau memiliki ambiguitas yang perlu dicatat jujur.

### 1. Ketegangan dokumentasi tentang akses anonim tanpa JWT

**Dua halaman dokumentasi resmi menyatakan hal yang tampak berbeda:**

- [Access control & security](https://neon.com/docs/data-api/access-control) menyatakan akses anonim **tetap memakai JWT**: *"Anonymous access still uses a JWT, but no user sign-in is required."*
- [Managing the Data API](https://neon.com/docs/data-api/manage) menyatakan role `anonymous` dipakai untuk **request tanpa header Authorization**: *"Specifies the database role used for unauthenticated requests (requests sent without an Authorization header)."*

**Yang tidak terverifikasi:** apakah request **tanpa** header `Authorization` sama sekali benar-benar diterima dan dipetakan ke role `anonymous`, atau apakah JWT anonim tetap wajib. Dokumentasi tidak menjelaskan interaksi antara kedua mode ini secara eksplisit, dan tidak ada contoh `curl` tanpa header `Authorization` di dokumentasi.

**Implikasi:** rencana implementasi di atas mengasumsikan mode "tanpa Authorization header" berfungsi. **Perlu diuji langsung** dengan `curl` sebelum diandalkan:

```bash
curl -X GET 'https://<endpoint>.apirest.<region>.aws.neon.tech/<db>/rest/v1/modul?select=*'
# Tanpa header Authorization — apakah berhasil?
```

**Mitigasi jika tidak berfungsi:** aktifkan Managed Better Auth dengan `allowAnonymous: true` — jalur ini terdokumentasi lengkap dengan contoh kode dan endpoint `GET /token/anonymous` yang eksplisit.

### 2. Klaim "eliminating API cold starts"

Changelog menyatakan *"We've also continued our performance enhancements, including eliminating API cold starts, as we prepare the Data API for GA."* — [Changelog](https://neon.com/docs/changelog).

**Tidak terverifikasi:** apakah ini berarti cold start benar-benar **nol** dalam praktik, atau hanya "dikurangi secara signifikan". Kalimat itu ditulis dalam konteks *"as we prepare the Data API for GA"* — jadi mungkin menggambarkan kondisi pra-GA, dan tidak ada konfirmasi ulang setelah GA. Angka latensi aktual untuk Data API tidak dipublikasikan.

**Yang terverifikasi:** cold start **compute** adalah *"a few hundred milliseconds"* — [Scale to Zero](https://neon.com/docs/introduction/scale-to-zero). Itu angka yang bisa diandalkan.

### 3. Batas rate limit Data API

**Tidak ditemukan** dokumentasi yang menyebutkan rate limit spesifik untuk Neon Data API (request per detik/menit).

**Yang ada:** setting `db_max_rows` untuk membatasi jumlah baris per request — [Managing the Data API](https://neon.com/docs/data-api/manage). Tapi ini batas baris, bukan batas laju request.

**Implikasi:** untuk aplikasi dengan traffic normal, kemungkinan tidak masalah. Tapi jika FlashStruct menjadi populer secara tiba-tiba, perilaku rate limiting tidak dapat diprediksi dari dokumentasi.

### 4. Harga dan kebijakan bisa berubah

Semua angka harga dan kuota di dokumen ini diambil dari halaman resmi pada **21 September 2026**. Baik Neon maupun Supabase **tidak memberikan jaminan** bahwa harga atau kuota Free plan akan tetap. Halaman pricing tidak menyertakan komitmen stabilitas harga.

### 5. Kematangan SDK klien

`@neondatabase/neon-js` ada di `0.7.0-beta` dan `@neondatabase/postgrest-js` di `0.2.0-beta` (diverifikasi dari metadata npm registry, 21 Sep 2026). **Tidak ada roadmap publik** yang menyatakan kapan versi stabil akan dirilis, dan tidak ada jaminan API tidak akan berubah.

**Catatan:** `@neondatabase/postgrest-js` versi `0.2.0-beta` bergantung pada `@supabase/postgrest-js` versi `2.79.0` (dari metadata npm) — ini menjelaskan mengapa kompatibilitasnya tinggi, tapi juga berarti SDK ini adalah wrapper tipis di atas kode Supabase. Deskripsi paketnya berbunyi *"PostgreSQL client for Neon Data API - query your database without authentication"*.

### 6. Perilaku scale-to-zero terhadap latensi Data API secara spesifik

Dokumentasi menyatakan compute bangun *"within a few hundred milliseconds"* — [Scale to Zero](https://neon.com/docs/introduction/scale-to-zero). Tapi ini diukur untuk koneksi database langsung, **bukan untuk Data API**.

**Tidak terverifikasi:** berapa total latensi request pertama melalui Data API setelah compute suspend — apakah tetap "beberapa ratus ms", atau ada overhead tambahan dari lapisan Data API. Tidak ada benchmark resmi yang dipublikasikan untuk skenario ini.

### 7. Kompatibilitas PostgREST yang diklaim "100%"

Dokumentasi mengklaim *"fully compatible with PostgREST"* dan changelog mengklaim *"100% PostgREST compatibility"*. **Klaim ini tidak diverifikasi secara independen.**

**Yang terverifikasi:** embedding relasi berfungsi (contoh resmi), filter dasar berfungsi (didokumentasikan), RPC berfungsi (didokumentasikan).

**Yang tidak terverifikasi:** apakah **seluruh** permukaan PostgREST — termasuk fitur lanjutan seperti full-text search, computed columns, `Prefer` headers tertentu, atau agregasi kompleks — benar-benar bekerja identik. Untuk kebutuhan FlashStruct (select + filter + embedding) tidak ada indikasi masalah, tapi klaim "100%" sebaiknya tidak dianggap sebagai jaminan menyeluruh tanpa pengujian.

### 8. Interaksi Data API dengan preview branch Vercel

Dokumentasi menyatakan Data API diaktifkan **per branch**: *"Each branch has its own Data API configuration, so you must select the correct branch before enabling the API."* — [Data API Get Started](https://neon.com/docs/data-api/get-started).

**Tidak terverifikasi:** apakah Data API otomatis aktif di preview branch yang dibuat oleh integrasi Vercel, atau harus diaktifkan manual per branch. Ini relevan jika FlashStruct memakai preview deployment.

### 9. Status beta untuk Object Storage dan Functions

Changelog 2026-09-04 menyatakan: *"Object Storage, Functions, and AI Gateway are in beta in AWS US East (Ohio) and AWS Europe (Frankfurt)"* — [Changelog](https://neon.com/docs/changelog).

Namun changelog 2026-09-18 (GA) mencantumkan keduanya sebagai bagian dari "Neon backend is generally available". **Ada ambiguitas** tentang status final keduanya. **Tidak relevan untuk FlashStruct** (tidak memakai keduanya), tapi dicatat untuk kelengkapan.

### 10. Angka "1.000.000 invocations" Vercel Hobby

Halaman Hobby Plan dan halaman Functions usage menyatakan **1.000.000 invocations/bulan** untuk Hobby. Namun ada halaman changelog Vercel yang berjudul *"Function invocations now billed per unit"* — [Functions usage and pricing](https://vercel.com/docs/functions/usage-and-pricing).

**Tidak terverifikasi:** apakah model billing invocations untuk Hobby berubah setelah changelog tersebut, karena tabel di halaman Hobby Plan masih menampilkan "First 1,000,000". Angka di dokumen ini mengikuti tabel resmi Hobby Plan, tapi **sebaiknya diverifikasi ulang** saat implementasi.

**Tidak relevan langsung** untuk FlashStruct jika memakai Data API langsung (tidak ada function invocation sama sekali) — tapi relevan jika memilih jalur serverless function.

---

## Referensi Lengkap

### Dokumentasi Neon

| Topik | URL |
|---|---|
| Data API — Overview | https://neon.com/docs/data-api/overview |
| Data API — Get Started | https://neon.com/docs/data-api/get-started |
| Data API — Access control & security | https://neon.com/docs/data-api/access-control |
| Data API — Managing | https://neon.com/docs/data-api/manage |
| Data API — Troubleshooting | https://neon.com/docs/data-api/troubleshooting |
| Data API — Tutorial (React/Vite) | https://neon.com/docs/data-api/demo |
| Data API — Advisors | https://neon.com/docs/data-api/database-advisor |
| Data API — SQL to PostgREST | https://neon.com/docs/data-api/sql-to-rest |
| Data API — Custom auth providers | https://neon.com/docs/data-api/custom-authentication-providers |
| SDK — JavaScript/TypeScript | https://neon.com/docs/reference/javascript-sdk |
| CLI — data-api | https://neon.com/docs/cli/data-api |
| RLS — Row-Level Security | https://neon.com/docs/guides/row-level-security |
| RLS — Tutorial | https://neon.com/docs/guides/rls-tutorial |
| Connect — Choosing a method | https://neon.com/docs/connect/choose-connection |
| Connect — Connection pooling | https://neon.com/docs/connect/connection-pooling |
| Connect — Latency and timeouts | https://neon.com/docs/connect/connection-latency |
| Connect — Serverless driver | https://neon.com/docs/serverless/serverless-driver |
| Intro — Scale to Zero | https://neon.com/docs/introduction/scale-to-zero |
| Intro — Architecture | https://neon.com/docs/introduction/architecture-overview |
| Intro — Plans | https://neon.com/docs/introduction/plans |
| Intro — Regions | https://neon.com/docs/introduction/regions |
| Vercel — Integration overview | https://neon.com/docs/guides/vercel-overview |
| Vercel — Connection methods | https://neon.com/docs/guides/vercel-connection-methods |
| Auth — Migrate from Supabase | https://neon.com/docs/auth/migrate/from-supabase |
| Pricing | https://neon.com/pricing |
| Changelog | https://neon.com/docs/changelog |

### Dokumentasi Vercel

| Topik | URL |
|---|---|
| Hobby Plan | https://vercel.com/docs/plans/hobby |
| Functions usage & pricing | https://vercel.com/docs/functions/usage-and-pricing |
| Limits | https://vercel.com/docs/limits |
| Fair Use Guidelines | https://vercel.com/docs/limits/fair-use-guidelines |

### Registry npm (diverifikasi 21 Sep 2026)

| Package | Versi `latest` | Status |
|---|---|---|
| `@neondatabase/neon-js` | `0.7.0-beta` | Beta |
| `@neondatabase/postgrest-js` | `0.2.0-beta` | Beta |
| `@neondatabase/serverless` | `1.1.0` | **GA** |

### Repository contoh resmi

| Repository | Deskripsi |
|---|---|
| [neondatabase-labs/neon-data-api-neon-auth](https://github.com/neondatabase-labs/neon-data-api-neon-auth) | React + Vite + Data API + RLS (demo) |
| [neondatabase/neon-vercel-http](https://github.com/neondatabase/neon-vercel-http) | Serverless driver over HTTP di Vercel Edge |
| [neondatabase/neon-vercel-rawsql](https://github.com/neondatabase/neon-vercel-rawsql) | Raw SQL di Vercel Edge Functions |
| [neondatabase/ping-thing](https://github.com/neondatabase/ping-thing) | Ping database via Vercel Edge Function |

---

**Dokumen terkait:**
- [01-RISET-TEKNIS.md](./01-RISET-TEKNIS.md) — Riset Supabase & deployment
- [02-RISET-DEPLOY-GRATIS.md](./02-RISET-DEPLOY-GRATIS.md) — Riset platform deploy gratis
- [../05-SKEMA-DATABASE.md](../05-SKEMA-DATABASE.md) — Skema database FlashStruct
- [../04-ARSITEKTUR-TEKNIS.md](../04-ARSITEKTUR-TEKNIS.md) — Arsitektur teknis
