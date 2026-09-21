# Riset Deploy Gratis untuk FlashStruct (React 19 + Vite + TS)

> **Tanggal riset:** September 2026
> **Metode:** Semua data diambil dari sumber primer (halaman pricing resmi, dokumentasi resmi, Terms of Service resmi). Setiap klaim disertai tautan sumber. Klaim yang tidak dapat diverifikasi ditandai eksplisit.
> **Konteks proyek:** Aplikasi edukasi gratis "FlashStruct" — React 19 + Vite + TypeScript, tanpa login, progres di localStorage, konten read-only dari database via API, target 100–1.000 pengunjung/bulan, anggaran Rp0.

---

## Ringkasan Eksekutif (5 Poin Kunci)

1. **Vercel Hobby DILARANG untuk penggunaan komersial — dan ini tertulis eksplisit di dua tempat.** Fair Use Guidelines: *"Hobby teams are restricted to non-commercial personal use only. All commercial usage of the platform requires either a Pro or Enterprise plan."* ([vercel.com/docs/limits/fair-use-guidelines](https://vercel.com/docs/limits/fair-use-guidelines)). ToS §4: *"You shall only use the Services under a Hobby plan for your personal or non-commercial use."* ([vercel.com/legal/terms](https://vercel.com/legal/terms)). **Kabar baik untuk FlashStruct:** definisi "commercial" Vercel adalah *"any Deployment that is used for the purpose of financial gain of anyone involved in any part of the production"* — aplikasi edukasi gratis tanpa iklan, tanpa pembayaran, tanpa afiliasi, dan tanpa bayaran untuk pembuatnya TIDAK masuk definisi ini (bahkan donasi secara eksplisit diperbolehkan). **Kabar buruk:** jika ada pihak yang dibayar untuk membuat/mengelola situs ini (termasuk "paid consultant writing the code"), statusnya berubah menjadi komersial dan melanggar ketentuan Hobby.

2. **Vercel tidak menyediakan database sendiri lagi.** Dokumentasi resmi mengarahkan ke Vercel Marketplace untuk database (Neon, Supabase, Upstash, dll.) — *"Provision databases through Vercel Marketplace... providers like Neon, Upstash, and Supabase"* ([vercel.com/docs/storage](https://vercel.com/docs/storage)). Integrasi Supabase di Vercel resmi dan bisa dipasang via CLI `vercel install supabase` ([vercel.com/docs/marketplace-storage](https://vercel.com/docs/marketplace-storage)).

3. **Firestore (Spark) BISA dipakai untuk data bertingkat, tapi ada biaya kompleksitas nyata.** Dokumentasi resmi Firestore mendukung subcollection (hingga 100 level), nested object, dan collection group query ([firebase.google.com/docs/firestore/data-model](https://firebase.google.com/docs/firestore/data-model)). Namun: (a) tidak ada JOIN — relasi modul → bagian → flashcard harus di-denormalisasi atau di-query berlapis; (b) *"Deleting a document does not delete its subcollections!"* ([data-model](https://firebase.google.com/docs/firestore/data-model)); (c) dokumen maksimal 1 MiB sehingga daftar besar tidak boleh ditanam dalam satu dokumen ([firebase.google.com/docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas)). Untuk konten kurikulum yang naturalnya relasional dan read-only, Postgres (Supabase/Neon) jauh lebih cocok. Spark plan tidak butuh kartu kredit — *"No payment method needed"* ([firebase.google.com/pricing](https://firebase.google.com/pricing)).

4. **Supabase Free paling pas untuk database konten read-only proyek ini:** Postgres relasional, API REST otomatis (PostgREST), 500 MB database, 5 GB egress, unlimited API requests ([supabase.com/pricing](https://supabase.com/pricing)). Satu catatan penting: *"Free projects are paused after 1 week of inactivity"* — untuk trafik 100–1.000 pengunjung/bulan, proyek bisa ter-pause di sela-sela aktivitas dan perlu di-unpause manual dari dashboard (data tidak hilang).

5. **Semua stack gratis yang diuji mampu menampung trafik 100–1.000 pengunjung/bulan dengan sangat lega.** Yang membedakan bukan kapasitas, tapi: (a) batasan komersial (Vercel Hobby), (b) risiko jangka panjang (Netlify sekarang memakai sistem kredit 300/bulan dengan hard limit; PlanetScale sudah tidak punya free tier sama sekali; Fly.io hanya trial; Railway free plan hanya $1 kredit/bulan), dan (c) kecocokan data relasional (Supabase/Neon Postgres >> Firestore NoSQL).

---

## 1. Vercel Free Tier (Hobby Plan)

**Sumber utama:** [vercel.com/pricing](https://vercel.com/pricing), [vercel.com/docs/limits](https://vercel.com/docs/limits), [vercel.com/docs/limits/fair-use-guidelines](https://vercel.com/docs/limits/fair-use-guidelines), [vercel.com/legal/terms](https://vercel.com/legal/terms)

### 1.1 Batasan kuota Hobby

Dari [halaman pricing](https://vercel.com/pricing) dan [dokumentasi limits](https://vercel.com/docs/limits):

| Resource | Batasan Hobby | Sumber |
|---|---|---|
| Harga | $0/bulan | [pricing](https://vercel.com/pricing) |
| Fast Data Transfer (bandwidth) | 100 GB/bulan included | [pricing](https://vercel.com/pricing), [fair-use](https://vercel.com/docs/limits/fair-use-guidelines) |
| Edge Requests | 1 juta/bulan | [pricing](https://vercel.com/pricing) |
| Function Invocations | 1 juta/bulan | [pricing](https://vercel.com/pricing) |
| Fluid Active CPU | 4 jam/bulan | [pricing](https://vercel.com/pricing) |
| Fluid Provisioned Memory | 360 GB-jam/bulan | [pricing](https://vercel.com/pricing) |
| Build minutes | "Basic machines: Included" (tanpa biaya tambahan) | [pricing](https://vercel.com/pricing) |
| Batas waktu per build | 45 menit (build gagal jika lewat) | [docs/limits](https://vercel.com/docs/limits) |
| Concurrent builds | 1 | [docs/limits](https://vercel.com/docs/limits) |
| Deployments | Unlimited (rate limit 100 deploy/hari, 100 deploy/jam) | [pricing](https://vercel.com/pricing), [docs/limits](https://vercel.com/docs/limits) |
| Jumlah proyek | 200 proyek per akun | [docs/limits](https://vercel.com/docs/limits) |
| Runtime logs | Disimpan 1 jam | [docs/limits](https://vercel.com/docs/limits) |
| Durasi function (proyek lama non-Fluid) | Default 10 detik, maksimum 60 detik | [docs/limits](https://vercel.com/docs/limits) |
| Static file upload (via CLI) | 100 MB | [docs/limits](https://vercel.com/docs/limits) |
| Blob storage | 1 GB/bulan | [pricing](https://vercel.com/pricing) |

Catatan: untuk proyek baru dengan Fluid compute, durasi maksimum function berbeda dari tabel legacy di atas — angka pastinya **tidak terverifikasi** di halaman yang ditinjau.

### 1.2 Batasan komersial — KUTIPAN PERSIS

Ini bagian terpenting. **Ada dua sumber resmi yang menyatakannya secara eksplisit:**

**Kutipan 1 — Fair Use Guidelines** ([vercel.com/docs/limits/fair-use-guidelines](https://vercel.com/docs/limits/fair-use-guidelines)):

> **"Hobby teams are restricted to non-commercial personal use only. All commercial usage of the platform requires either a Pro or Enterprise plan."**
>
> "Commercial usage is defined as any Deployment that is used for the purpose of financial gain of **anyone** involved in **any part of the production** of the project, including a paid employee or consultant writing the code. Examples of this include, but are not limited to, the following:
> - Any method of requesting or processing payment from visitors of the site
> - Advertising the sale of a product or service
> - Receiving payment to create, update, or host the site
> - Affiliate linking is the primary purpose of the site
> - The inclusion of advertisements, including but not limited to online advertising platforms like Google AdSense
>
> **Note:** Asking for Donations **does not** fall under commercial usage."

**Kutipan 2 — Terms of Service, Section 4 (Hobby Plan)** ([vercel.com/legal/terms](https://vercel.com/legal/terms)):

> **"You shall only use the Services under a Hobby plan for your personal or non-commercial use.** We may change the features, limitations, or other conditions applicable to the Hobby plan or discontinue offering the Hobby plan at any time. **We reserve the right to disable or remove any Project or website deployment on the Hobby plan with or without notice at our sole discretion.** We may shut down and terminate projects or deployments using the Hobby plan without notice for any reason or no reason."

**Kutipan 3 — Knowledge Base resmi Vercel** ([vercel.com/kb/guide/why-is-my-account-deployment-blocked](https://vercel.com/kb/guide/why-is-my-account-deployment-blocked)):

> **"Can I run a commercial site on a Hobby account? No.** Hobby teams are restricted to non-commercial personal use, and all commercial usage requires a Pro or Enterprise plan."

### 1.3 Apakah aplikasi edukasi gratis boleh pakai Hobby?

**Analisis berdasarkan definisi resmi di atas:** Ya, selama memenuhi semua kondisi berikut:

- Tidak ada iklan (Google AdSense dll.) — FlashStruct tidak punya iklan.
- Tidak ada pembayaran/penggalangan dana dari pengunjung — tidak ada.
- Tidak ada afiliasi sebagai tujuan utama — tidak ada.
- **Tidak ada pihak yang dibayar** untuk membuat, mengupdate, atau menghosting situs — **INI YANG PERLU DIPERHATIKAN**. Jika proyek ini adalah tugas kuliah yang dikerjakan sendiri tanpa bayaran, aman. Jika ada developer/consultant yang dibayar, berubah menjadi komersial.
- Donasi (jika suatu saat ada) secara eksplisit tidak dianggap komersial.

**Kesimpulan:** FlashStruct sebagai aplikasi edukasi gratis tanpa monetisasi **boleh memakai Hobby plan**, dengan catatan tidak ada pekerja berbayar di baliknya. Jika ada keraguan, Vercel menyarankan menghubungi support sebelum deploy: *"If you are unsure whether or not your site would be defined as commercial usage, please contact the Vercel Support team"* ([fair-use-guidelines](https://vercel.com/docs/limits/fair-use-guidelines)).

### 1.4 Catatan penting: ToS Vercel mengizinkan training AI atas konten Hobby

Dari [vercel.com/legal/terms](https://vercel.com/legal/terms) Section 3:

> "In addition, **if you are on a Hobby plan or trial Pro plan, you agree that we may use Your Content to train our artificial intelligence ("AI") and machine learning models**, and we may share Your Content with third parties for the purpose of developing and improving their products, including training and improving their AI and machine learning models."

Untuk konten edukasi publik ini risikonya rendah, tetapi perlu diketahui karena konten kurikulum akan di-upload ke platform mereka. (Pada Pro plan, Model Training tidak aktif secara default.)

### 1.5 Database di Vercel?

**Vercel tidak menyediakan database sendiri di paket Hobby.** Yang tersedia:

- **Vercel Blob** — object storage untuk file, 1 GB/bulan di Hobby ([pricing](https://vercel.com/pricing)).
- **Global Config** — penyimpanan konfigurasi (bukan database konten) ([docs/global-config](https://vercel.com/docs/global-config)).
- **Marketplace Storage** — database dari provider pihak ketiga. Dokumentasi resmi: *"The Vercel Marketplace connects agents and applications to relational data... through providers like Neon, Upstash, and Supabase. Vercel injects provisioned resource credentials as environment variables."* ([vercel.com/docs/storage](https://vercel.com/docs/storage), [vercel.com/docs/marketplace-storage](https://vercel.com/docs/marketplace-storage))

Artinya: rekomendasi resmi Vercel untuk database adalah integrasi pihak ketiga (Neon, Supabase, Upstash). Integrasi resmi Supabase tercantum di [vercel.com/marketplace/supabase](https://vercel.com/marketplace/supabase) dan didukung CLI: `vercel install supabase` ([docs/marketplace-storage](https://vercel.com/docs/marketplace-storage)).

### 1.6 Apa yang terjadi kalau melebihi batas?

Tiga hal berbeda bisa terjadi, semuanya dari sumber resmi:

1. **Tidak bisa membeli kapasitas tambahan (tidak akan ditagih).** Dari FAQ pricing: *"If you have a free Hobby account, you are limited to the usage caps and **cannot purchase additional usage**."* ([vercel.com/pricing](https://vercel.com/pricing))
2. **Deployment bisa di-pause (berhenti melayani, 503).** Dari KB resmi: salah satu penyebab pause adalah *"Usage limits or quotas: Your account exceeded the limits or quotas for your plan"*; situs berhenti melayani dan visitor melihat error `503 DEPLOYMENT_PAUSED`. Pause harus di-resume manual per proyek dari dashboard. ([vercel.com/kb/guide/why-is-my-account-deployment-blocked](https://vercel.com/kb/guide/why-is-my-account-deployment-blocked))
3. **Secara ToS, akun bisa diterminasi.** ToS §18: *"Vercel may terminate your account and this Agreement immediately if you exceed any Vercel limits concerning use of the Services."* ([vercel.com/legal/terms](https://vercel.com/legal/terms))

Untuk pelanggaran kebijakan (termasuk pemakaian komersial di Hobby), Vercel mengirim email lalu dapat mem-pause akun — *"When a deployment breaches the Terms of Service... Vercel's team may pause the account or deployment directly"* ([KB](https://vercel.com/kb/guide/why-is-my-account-deployment-blocked)).

---

## 2. Supabase Free Tier

**Sumber utama:** [supabase.com/pricing](https://supabase.com/pricing), [supabase.com/terms](https://supabase.com/terms)

### 2.1 Batasan kuota Free

Dari [halaman pricing resmi](https://supabase.com/pricing):

| Resource | Free | Sumber |
|---|---|---|
| Harga | $0/bulan | [pricing](https://supabase.com/pricing) |
| Database size | 500 MB per proyek | [pricing](https://supabase.com/pricing) |
| Egress (bandwidth) | 5 GB/bulan | [pricing](https://supabase.com/pricing) |
| Cached egress | 5 GB/bulan | [pricing](https://supabase.com/pricing) |
| API requests | **Unlimited** | [pricing](https://supabase.com/pricing) |
| Jumlah proyek aktif | 2 proyek (proyek yang di-pause tidak dihitung) | [pricing](https://supabase.com/pricing) |
| File storage | 1 GB | [pricing](https://supabase.com/pricing) |
| MAU (auth) | 50.000 | [pricing](https://supabase.com/pricing) |
| Edge Functions | 500.000 invocations | [pricing](https://supabase.com/pricing) |
| Realtime | 200 koneksi puncak, 2 juta pesan/bulan | [pricing](https://supabase.com/pricing) |
| Log retention | 1 hari | [pricing](https://supabase.com/pricing) |
| Backups | Tidak ada di Free | [pricing](https://supabase.com/pricing) |

Catatan: angka "500 MB database size" dan "5 GB egress" sudah dikonfirmasi dari tabel perbandingan resmi di halaman pricing (kolom Free).

### 2.2 Pause saat idle

Dari [halaman pricing resmi](https://supabase.com/pricing):

> "Note: **Free projects are paused after 1 week of inactivity.** Limit of 2 active projects."

Dan di tabel perbandingan: "Pausing — **After 1 week of inactivity**" (kolom Free), sedangkan Pro/Team "Never" ([supabase.com/pricing](https://supabase.com/pricing)).

Implikasi untuk FlashStruct: dengan 100–1.000 pengunjung/bulan, ada kemungkinan proyek tidak menerima request selama 7 hari berturut-turut (mis. saat libur semester), lalu ter-pause. Saat dipanggil lagi, proyek perlu di-unpause dari dashboard — halaman FAQ menyebut *"Can I pause a free project? Yes, you can pause a project at any time"* ([supabase.com/pricing](https://supabase.com/pricing)); detail perilaku auto-unpause saat request masuk **tidak terverifikasi**.

### 2.3 Batasan komersial di Terms Supabase

Saya meninjau [Terms of Service Supabase](https://supabase.com/terms) (versi yang diakses September 2026). **Tidak ditemukan klausa yang membatasi pemakaian hanya untuk non-komersial.** ToS berisi pembatasan penggunaan wajar (larangan menjual ulang layanan, reverse engineering, dsb.) dan ketentuan lisensi *"solely for use by Authorized Users... limited to Customer's internal business purposes"* — frasa "internal business purposes" justru mengindikasikan penggunaan bisnis diperbolehkan ([supabase.com/terms](https://supabase.com/terms) §2a). Tidak ada larangan "no commercial use" seperti di Vercel Hobby.

**Kesimpulan:** proyek edukasi gratis sangat boleh memakai Supabase Free; tidak ada hambatan komersial yang ditemukan. Status: **tidak ditemukan batasan** (bukan berarti tidak ada batasan tersembunyi di dokumen lain yang tidak ditinjau).

### 2.4 Integrasi dengan Vercel

Integrasi resmi tersedia:

- Halaman marketplace Vercel: [vercel.com/marketplace/supabase](https://vercel.com/marketplace/supabase).
- Dokumentasi Vercel untuk Marketplace Storage mencantumkan Supabase sebagai provider Postgres resmi, termasuk fitur query database langsung dari dashboard Vercel: *"For supported Marketplace Postgres integrations... This feature is available for the following integrations: AWS Aurora Postgres, Neon, Prisma Postgres, **Supabase**"* ([vercel.com/docs/marketplace-storage](https://vercel.com/docs/marketplace-storage)).
- Instalasi via CLI: `vercel install supabase` — *"This installs the integration, connects it to the linked project, and pulls credentials into `.env.local`"* ([vercel.com/docs/marketplace-storage](https://vercel.com/docs/marketplace-storage)).
- Halaman integrasi Supabase di situs Supabase ([supabase.com/partners/integrations/vercel](https://supabase.com/partners/integrations/vercel)) ada tetapi isinya dimuat via JavaScript dan tidak dapat saya baca penuh — detail langkah-langkah dari sisi Supabase **tidak terverifikasi**; langkah dari sisi Vercel sudah terverifikasi di dokumentasi Vercel.

---

## 3. Firebase Free Tier (Spark Plan)

**Sumber utama:** [firebase.google.com/pricing](https://firebase.google.com/pricing), [firebase.google.com/docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas), [firebase.google.com/docs/firestore/data-model](https://firebase.google.com/docs/firestore/data-model), [firebase.google.com/docs/firestore/manage-data/structure-data](https://firebase.google.com/docs/firestore/manage-data/structure-data), [firebase.google.com/terms](https://firebase.google.com/terms)

### 3.1 Batasan Firestore (Spark)

Dari [dokumentasi kuota resmi Firestore](https://firebase.google.com/docs/firestore/quotas):

| Resource | Kuota gratis | Sumber |
|---|---|---|
| Stored data | 1 GiB | [docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas) |
| Document reads | 50.000/hari | [docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas) |
| Document writes | 20.000/hari | [docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas) |
| Document deletes | 20.000/hari | [docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas) |
| Outbound data transfer | 10 GiB/bulan | [docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas) |

> "**Important:** Cloud Firestore allows **exactly one free database** per project." ([docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas))
>
> "Quotas are applied daily and reset around midnight Pacific time." ([docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas))

Fitur yang **tidak** termasuk gratis (butuh billing/Blaze): TTL deletes, PITR data, backup data, restore operations, clone operations ([docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas)).

### 3.2 Batasan Firebase Hosting (Spark)

Dari [halaman pricing](https://firebase.google.com/pricing):

| Resource | Free (Spark) |
|---|---|
| Storage | 10 GB |
| Data transfer | 360 MB/hari (setara ±10 GB/bulan) |
| Custom domain & SSL | Termasuk |
| Multiple sites per project | Termasuk |

Catatan: 360 MB/hari adalah batas **harian**, bukan bulanan ([firebase.google.com/pricing](https://firebase.google.com/pricing)).

### 3.3 Apakah Spark butuh kartu kredit?

**Tidak.** Halaman pricing menampilkan pada bagian Spark: *"Generous no-cost usage limits"* dan *"**No payment method needed**"* ([firebase.google.com/pricing](https://firebase.google.com/pricing)).

### 3.4 Batasan komersial

Dari [Terms of Service Firebase](https://firebase.google.com/terms) (dimodifikasi 2 September 2026), kalimat pembuka:

> "**I agree that my use of any Firebase service is for purposes related to my trade, business, craft, or profession**, and that my use is subject to the applicable terms below."

ToS Firebase justru mengasumsikan penggunaan untuk trade/business/profession — **tidak ditemukan batasan "non-commercial only"** pada Spark plan. Firebase adalah layanan Google Cloud yang memang menyasar penggunaan bisnis sejak awal. Untuk proyek edukasi gratis, jelas diperbolehkan. Status: **tidak ditemukan batasan komersial** ([firebase.google.com/terms](https://firebase.google.com/terms)).

### 3.5 Kecocokan Firestore untuk data hierarkis/relasional — PENTING

Ini pertanyaan krusial untuk FlashStruct. Berikut temuan dari dokumentasi resmi:

**Yang didukung:**

- **Struktur data:** *"All documents must be stored in collections. Documents can contain subcollections and nested objects, both of which can include primitive fields like strings or complex objects like lists."* ([docs/firestore/data-model](https://firebase.google.com/docs/firestore/data-model))
- **Subcollection untuk hierarki:** *"Subcollections allow you to structure data hierarchically, making data easier to access... You can nest data up to 100 levels deep."* ([docs/firestore/data-model](https://firebase.google.com/docs/firestore/data-model))
- **Collection group query:** *"A collection group consists of all collections with the same ID... Use a collection group query to retrieve documents from a collection group instead of from a single collection."* ([docs/firestore/query-data/queries](https://firebase.google.com/docs/firestore/query-data/queries))
- **Query field bersarang:** field path menggunakan notasi titik — *"Constraints on field paths: Must separate field names with a single period (.)"* ([docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas)).

**Batasan dan jebakan (dari sumber resmi):**

1. **Tidak ada JOIN.** Firestore adalah NoSQL; join baru tersedia sebagai fitur *Pipeline operations* di **Enterprise edition**, bukan Standard edition ([firebase.google.com/docs/firestore/enterprise/pipelines-overview](https://firebase.google.com/docs/firestore/enterprise/pipelines-overview)). Untuk Standard edition (yang dipakai Spark), relasi harus di-denormalisasi atau di-query berlapis dari client.
2. **Dokumen maksimal 1 MiB.** *"Maximum size for a document: 1 MiB (1,048,576 bytes)"* ([docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas)). Jadi seluruh daftar flashcard/soal tidak boleh ditanam dalam satu dokumen besar.
3. **Nested list tidak scalable.** Dokumentasi resmi memperingatkan: *"This isn't as scalable as other options, especially if your data expands over time. With larger or growing lists, the document also grows, which can lead to slower document retrieval times."* ([docs/firestore/manage-data/structure-data](https://firebase.google.com/docs/firestore/manage-data/structure-data))
4. **Menghapus dokumen tidak menghapus subcollection-nya.** *"Warning: Deleting a document does not delete its subcollections!... If you want to delete documents in subcollections when deleting a parent document, you must do so manually."* ([docs/firestore/data-model](https://firebase.google.com/docs/firestore/data-model))
5. **Root-level collection menyulitkan hierarki.** *"Limitations: Getting data that is naturally hierarchical might become increasingly complex as your database grows."* ([docs/firestore/manage-data/structure-data](https://firebase.google.com/docs/firestore/manage-data/structure-data))
6. **Batas indeks saat tanpa billing:** maksimum 200 composite index dan 200 single-field configuration per database selama billing belum diaktifkan ([docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas)).
7. **Batas kedalaman field di map/array: 20 level** ([docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas)).

**Contoh pemodelan untuk FlashStruct (modul > bagian, modul > flashcard, soal > opsi jawaban):**

Opsi yang lazim digunakan (berdasarkan pola yang didokumentasikan):

```
modules/{moduleId}                      // dokumen modul: {title, order, description}
modules/{moduleId}/sections/{sectionId} // subcollection: bagian materi
modules/{moduleId}/flashcards/{cardId}  // subcollection: flashcard
modules/{moduleId}/questions/{qId}      // subcollection: soal
  └─ field "options": [ {text, isCorrect}, ... ]  // array nested di dalam dokumen soal
```

- Untuk mengambil semua bagian satu modul: query subcollection `modules/{id}/sections`.
- Untuk mengambil semua flashcard lintas modul: collection group query pada `flashcards`.
- Opsi jawaban disimpan sebagai array nested di dokumen soal (aman, karena opsi soal biasanya < 1 MiB dan jumlahnya tetap).
- **Konsekuensi:** setiap modul = minimal 3–4 query terpisah; tidak ada cara "JOIN" satu query untuk mengambil modul + bagian + flashcard sekaligus. Total pembacaan dokumen juga lebih tinggi (setiap dokumen yang dibaca dihitung 1 read terhadap kuota 50.000/hari).

**Apakah NoSQL Firestore menyulitkan untuk kasus ini?** Ya, relatif. Untuk data yang secara alami relasional (modul → bagian → item; soal → opsi) dan read-only, Postgres memberi foreign key, JOIN, dan constraint yang langsung memetakan skema. Firestore menuntut denormalisasi, query berlapis, dan penanganan manual untuk delete/relasi. Dokumentasi resmi sendiri mengakui *"Getting data that is naturally hierarchical might become increasingly complex as your database grows"* ([structure-data](https://firebase.google.com/docs/firestore/manage-data/structure-data)).

### 3.6 SDK dan cara query

- **Butuh SDK khusus:** Ya. Firestore menyediakan SDK Web (`firebase/firestore`) — daftar lengkap SDK ada di [docs/firestore/client/libraries](https://firebase.google.com/docs/firestore/client/libraries), referensi Web di [docs/reference/js/firestore_](https://firebase.google.com/docs/reference/js/firestore_). Alternatif tanpa SDK: [REST API](https://firebase.google.com/docs/firestore/use-rest-api) dan [RPC](https://firebase.google.com/docs/firestore/reference/rpc). Tidak ada API PostgREST-style otomatis seperti Supabase; query kompleks dilakukan via SDK.
- **Query nested data:** via collection group query (`collectionGroup(db, 'flashcards')`) dan field path dengan notasi titik, keduanya didokumentasikan di [docs/firestore/query-data/queries](https://firebase.google.com/docs/firestore/query-data/queries) dan [docs/firestore/quotas](https://firebase.google.com/docs/firestore/quotas).

---

## 4. Alternatif Lain (Hosting Gratis untuk React + Vite)

### 4.1 Netlify Free

**Sumber:** [netlify.com/pricing](https://www.netlify.com/pricing/), [docs.netlify.com — how credits work](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/how-credits-work/), [netlify.com/legal/acceptable-use-policy](https://www.netlify.com/legal/acceptable-use-policy/)

**Perubahan besar:** Sejak 4 September 2025, semua akun Netlify baru memakai **model kredit**, bukan lagi kuota bandwidth/build minutes terpisah:

> "Starting on September 4, 2025, all new Netlify accounts will use the new credit-based pricing plans." ([docs.netlify.com](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/how-credits-work/))

Kuota Free:

| Item | Nilai | Sumber |
|---|---|---|
| Kredit | 300 credits/bulan, **Hard limit** | [how credits work](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/how-credits-work/) |
| Production deploy | 15 credits per deploy | [how credits work](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/how-credits-work/) |
| Bandwidth | 20 credits per GB | [how credits work](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/how-credits-work/) |
| Web requests | 2 credits per 10.000 requests | [how credits work](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/how-credits-work/) |
| Compute (functions) | 10 credits per GB-hour | [how credits work](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/how-credits-work/) |
| Deploy previews | 0 credits (gratis) | [how credits work](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/how-credits-work/) |

**Yang terjadi saat kredit habis:** *"Once your credit balance is completely used up, all of your web projects (sites/apps) are paused and visitors to your web projects will find a `Site not available` page"* ([how credits work](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/how-credits-work/)). Pada Free plan, tidak ada opsi beli kredit tambahan (hanya Personal/Pro).

**Contoh kapasitas 300 kredit/bulan:** ±15 GB bandwidth (jika seluruh kredit untuk bandwidth), atau kombinasi mis. 10 deploy produksi (150 kredit) + 5 GB bandwidth (100 kredit) + 250k web requests (50 kredit). Untuk 100–1.000 pengunjung/bulan, ini lega.

**SPA:** Netlify mendukung rewrite untuk SPA dengan aturan `/* /index.html 200` ([docs.netlify.com — rewrites](https://docs.netlify.com/manage/routing/redirects/rewrites-proxies/)).

**Batasan komersial:** Saya meninjau [Acceptable Use Policy](https://www.netlify.com/legal/acceptable-use-policy/) dan [Website Terms of Use](https://www.netlify.com/legal/terms-of-use/). **Tidak ditemukan klausa yang melarang penggunaan komersial pada paket Free** — AUP poin 5 melarang *"commercially exploit the Netlify Services or website"* yang konteksnya adalah mengeksploitasi layanan Netlify itu sendiri (menjual ulang), bukan melarang situs Anda berbisnis. Dokumen yang mengatur layanan adalah **Self-Serve Subscription Agreement (PDF)** ([netlify.com/pdf/self-serve-subscription-agreement.pdf](https://www.netlify.com/pdf/self-serve-subscription-agreement.pdf)) — PDF ini **tidak dapat saya baca sebagai teks**, sehingga verifikasi lengkap klausul komersial Netlify **tidak terverifikasi**.

### 4.2 Cloudflare Pages

**Sumber:** [developers.cloudflare.com/pages/platform/limits](https://developers.cloudflare.com/pages/platform/limits/), [developers.cloudflare.com/pages/configuration/serving-pages](https://developers.cloudflare.com/pages/configuration/serving-pages/), [developers.cloudflare.com/pages/functions/pricing](https://developers.cloudflare.com/pages/functions/pricing/)

| Item | Free | Sumber |
|---|---|---|
| Builds | 500/bulan, 1 build bersamaan, timeout 20 menit | [pages/platform/limits](https://developers.cloudflare.com/pages/platform/limits/) |
| Custom domains per project | 100 | [pages/platform/limits](https://developers.cloudflare.com/pages/platform/limits/) |
| Files per site | 20.000 file | [pages/platform/limits](https://developers.cloudflare.com/pages/platform/limits/) |
| Max file size | 25 MiB per aset | [pages/platform/limits](https://developers.cloudflare.com/pages/platform/limits/) |
| Proyek per akun | 100 | [pages/platform/limits](https://developers.cloudflare.com/pages/platform/limits/) |
| Preview deployments | Unlimited | [pages/platform/limits](https://developers.cloudflare.com/pages/platform/limits/) |
| **Bandwidth aset statis** | **"requests to static assets are free and unlimited"** | [pages/functions/pricing](https://developers.cloudflare.com/pages/functions/pricing/) |
| Functions (jika dipakai) | 100.000 request/hari (kuota Workers Free) | [pages/functions/pricing](https://developers.cloudflare.com/pages/functions/pricing/) |

**Apakah gratis tanpa batas bandwidth?** Untuk **aset statis**: ya — *"On both free and paid plans, requests to static assets are free and unlimited. A request is considered static when it does not invoke Functions."* ([pages/functions/pricing](https://developers.cloudflare.com/pages/functions/pricing/)). Ini berlaku untuk SPA React yang hanya menyajikan file statis. Jika memakai Pages Functions, kena kuota Workers Free 100.000 request/hari ([pages/functions/pricing](https://developers.cloudflare.com/pages/functions/pricing/)).

**SPA:** Didukung otomatis — *"If your project does not include a top-level 404.html file, Pages assumes that you are deploying a single-page application. This includes frameworks like React, Vue, and Angular. Pages' default single-page application behavior matches all incoming paths to the root (/)"* ([pages/configuration/serving-pages](https://developers.cloudflare.com/pages/configuration/serving-pages/)).

**Batasan komersial:** **Tidak terverifikasi** — saya tidak meninjau ToS Cloudflare secara menyeluruh dalam riset ini.

### 4.3 Render

**Sumber:** [render.com/pricing](https://render.com/pricing), [render.com/docs/free](https://render.com/docs/free)

**Free tier masih ada di 2026, tapi terbatas:**

- **Static sites: gratis** — *"Static sites are free to deploy on Render"*, menghitung bandwidth bulanan workspace (Hobby: 5 GB included) dan pipeline minutes (500 menit/bulan) ([render.com/docs/free](https://render.com/docs/free), [render.com/pricing](https://render.com/pricing)).
- **Free web services (server):** spin-down setelah 15 menit idle, spin-up ±1 menit; 750 free instance hours/bulan per workspace; filesystem ephemeral (perubahan lokal hilang saat restart); tidak mendukung persistent disk/scaling ([render.com/docs/free](https://render.com/docs/free)).
- **Free Postgres: kedaluwarsa 30 hari setelah dibuat** — *"Free Render Postgres databases expire 30 days after creation"*; setelah kedaluwarsa ada grace period 14 hari lalu database dihapus ([render.com/docs/free](https://render.com/docs/free)). **Tidak cocok untuk database produksi.**
- Free Key Value: in-memory only, data hilang saat restart ([render.com/docs/free](https://render.com/docs/free)).

Untuk FlashStruct, Render bisa dipakai sebagai **hosting statis gratis** (menggantikan Vercel/Netlify), tetapi bukan sebagai penyedia database.

**Batasan komersial:** **tidak terverifikasi** (tidak ditinjau dalam riset ini).

### 4.4 Railway

**Sumber:** [railway.com/pricing](https://railway.com/pricing)

- **Free Trial:** $5 kredit sekali pakai, berlaku 30 hari, tanpa kartu kredit ([railway.com/pricing](https://railway.com/pricing)).
- **Free plan (permanen):** $0/bulan dengan **$1 kredit usage per bulan**, maksimum 1 vCPU / 0.5 GB per service, 1 proyek, 3 services, **0 custom domain**, log 3 hari ([railway.com/pricing](https://railway.com/pricing)).
- **Hobby:** $5/bulan dengan $5 kredit usage ([railway.com/pricing](https://railway.com/pricing)).

Kesimpulan: Railway masih punya "Free" plan pada 2026, tetapi kredit $1/bulan hanya cukup untuk beban sangat kecil dan **tidak ada custom domain** — kurang praktis untuk proyek yang ingin URL sendiri. Untuk React static site, Railway bukan pilihan hemat (bisa jadi opsi deploy static, tetapi tanpa domain kustom di Free).

### 4.5 Fly.io

**Sumber:** [fly.io/docs/about/free-trial](https://fly.io/docs/about/free-trial/), [fly.io/docs/about/pricing](https://fly.io/docs/about/pricing/)

- **Tidak ada free tier permanen.** Yang tersedia hanya **Free Trial**: *"A free trial on Fly.io includes 2 hours of machine runtime or 7 days of access, whichever comes first."* ([free-trial](https://fly.io/docs/about/free-trial/)).
- Setelah trial habis atau resource terpakai: *"your apps will stop until you add a payment method"* ([free-trial](https://fly.io/docs/about/free-trial/)).
- Semua organisasi memerlukan kartu kredit: *"All organizations (except for Linked Organizations) require a credit card on file."* ([pricing](https://fly.io/docs/about/pricing/)).

**Kesimpulan: Fly.io tidak layak untuk hosting gratis jangka panjang pada 2026.**

### 4.6 GitHub Pages

**Sumber:** [docs.github.com — what is github pages](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages), [docs.github.com — github pages limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits)

| Batasan | Nilai | Sumber |
|---|---|---|
| Ukuran site yang dipublikasikan | Maks 1 GB | [github pages limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits) |
| Bandwidth | Soft limit 100 GB/bulan | [github pages limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits) |
| Builds | Soft limit 10 build/jam (tidak berlaku jika pakai GitHub Actions workflow) | [github pages limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits) |
| Timeout deploy | 10 menit | [github pages limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits) |
| Situs user/org | Maks 1 per akun | [what is github pages](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages) |

**Batasan komersial:** GitHub Pages *"is not intended for or allowed to be used as a free web-hosting service to run your online business, e-commerce site, or any other website that is primarily directed at either facilitating commercial transactions or providing commercial software as a service (SaaS)"* ([github pages limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits)). Aplikasi edukasi non-komersial tidak termasuk larangan ini.

**SPA rewrite:** Klaim "GitHub Pages tidak punya SPA rewrite" **tidak dapat diverifikasi dari dokumentasi resmi** (dokumentasi tidak menyediakan fitur rewrite/redirect server-side; satu-satunya mekanisme halaman kustom adalah `404.html`). Status: tidak ada fitur rewrite yang didokumentasikan → workaround yang umum adalah menyalin `index.html` menjadi `404.html`. Detail perilaku SPA **tidak terverifikasi** di dokumen yang ditinjau.

---

## 5. Database Gratis Alternatif

### 5.1 Neon (Postgres)

**Sumber:** [neon.com/pricing](https://neon.com/pricing)

| Item | Free | Sumber |
|---|---|---|
| Harga | $0/bulan, **permanen (bukan trial)**, tanpa kartu kredit | [neon.com/pricing](https://neon.com/pricing) |
| Storage | 0.5 GB/proyek | [neon.com/pricing](https://neon.com/pricing) |
| Compute | 100 CU-hours/proyek (0.25 CU × 4 jam = 1 CU-hour) | [neon.com/pricing](https://neon.com/pricing) |
| Egress | 5 GB/proyek | [neon.com/pricing](https://neon.com/pricing) |
| Scale to zero | Otomatis setelah 5 menit idle (tidak bisa dimatikan di Free) | [neon.com/pricing](https://neon.com/pricing) |
| Projects | 100 | [neon.com/pricing](https://neon.com/pricing) |
| Branches per project | 10 | [neon.com/pricing](https://neon.com/pricing) |
| Auth (MAU) | s.d. 60.000 | [neon.com/pricing](https://neon.com/pricing) |

Perilaku saat limit: *"Running out of CU-hours or egress (5 GB) suspends compute until the next billing period. Exceeding 0.5 GB storage blocks writes... None of these limits delete your data."* ([neon.com/pricing](https://neon.com/pricing)).

Integrasi Vercel: resmi — *"For Postgres, you can use providers like Neon, Supabase, or AWS Aurora Postgres"* dan `vercel install neon` ([vercel.com/docs/marketplace-storage](https://vercel.com/docs/marketplace-storage)).

### 5.2 Turso (SQLite)

**Sumber:** [turso.tech/pricing](https://turso.tech/pricing)

| Item | Free | Sumber |
|---|---|---|
| Harga | $0/bulan, tanpa kartu kredit | [turso.tech/pricing](https://turso.tech/pricing) |
| Databases | 100 | [turso.tech/pricing](https://turso.tech/pricing) |
| Storage | 5 GB | [turso.tech/pricing](https://turso.tech/pricing) |
| Rows read | 500 juta/bulan | [turso.tech/pricing](https://turso.tech/pricing) |
| Rows written | 10 juta/bulan | [turso.tech/pricing](https://turso.tech/pricing) |
| Syncs | 3 GB | [turso.tech/pricing](https://turso.tech/pricing) |
| Point-in-time restore | 1 hari | [turso.tech/pricing](https://turso.tech/pricing) |
| Support | Community | [turso.tech/pricing](https://turso.tech/pricing) |

Turso adalah SQLite terdistribusi (libSQL) — cocok untuk data kecil read-heavy. Untuk browser React murni, akses perlu via serverless function atau token read-only (detail integrasi browser **tidak diverifikasi** dalam riset ini).

### 5.3 PlanetScale

**Sumber:** [planetscale.com/docs/planetscale-plans](https://planetscale.com/docs/planetscale-plans)

**Tidak ada free tier di 2026.** Kutipan persis:

> "**PlanetScale does not offer a free plan**, previously known as the 'Developer' or 'Hobby' plan. All databases require a paid subscription starting with our Base plan... Single-node Postgres databases are available starting at $5 per month." ([planetscale.com/docs/planetscale-plans](https://planetscale.com/docs/planetscale-plans))

### 5.4 Supabase vs Neon vs Turso untuk konten read-only kecil

| Kriteria | Supabase Free | Neon Free | Turso Free |
|---|---|---|---|
| Tipe | Postgres + REST API otomatis | Postgres murni | SQLite (libSQL) |
| Storage | 500 MB | 0.5 GB | 5 GB |
| Egress | 5 GB | 5 GB | 500M rows read (bukan GB) |
| Idle | Pause setelah 1 minggu inactivity | Scale-to-zero 5 menit (otomatis, cepat) | — (selalu siap; detail **tidak diverifikasi**) |
| API langsung dari browser | Ya (PostgREST + anon key, cocok untuk read-only) | Tidak langsung (perlu serverless function/proxy) | Perlu token/SDK khusus (detail **tidak diverifikasi**) |
| Integrasi Vercel resmi | Ya ([marketplace](https://vercel.com/marketplace/supabase)) | Ya ([docs](https://vercel.com/docs/marketplace-storage)) | — (tidak ditinjau) |
| Relasional | Ya (Postgres penuh) | Ya (Postgres penuh) | SQLite (relasional, tapi edge) |

**Paling cocok untuk FlashStruct: Supabase Free**, karena (1) Postgres relasional penuh untuk data modul/flashcard/soal, (2) REST API otomatis yang bisa diakses langsung dari React tanpa backend tambahan, (3) integrasi resmi Vercel, dan (4) tanpa batasan komersial. **Neon** adalah alternatif terbaik kedua (scale-to-zero cepat, tidak pernah "pause" dalam arti butuh intervensi), tetapi butuh perantara serverless untuk query dari browser.

---

## 6. Perbandingan Langsung Stack

Asumsi: aplikasi edukasi non-komersial, tanpa login, konten read-only, 100–1.000 pengunjung/bulan.

| Aspek | **A: Vercel Hobby + Supabase** | **B: Vercel Hobby + Firestore Spark** | **C: Firebase Hosting + Firestore** | **D: Cloudflare Pages + Supabase** | **E: Netlify + Supabase** |
|---|---|---|---|---|---|
| **Total biaya** | $0 | $0 | $0 | $0 | $0 (300 kredit/bulan, hard limit) |
| **Batasan hosting** | 100 GB transfer, 1M invocations, 1M edge requests/bulan; 100 deploy/hari; 1 build bersamaan ([pricing](https://vercel.com/pricing), [limits](https://vercel.com/docs/limits)) | Sama seperti A | 10 GB storage, 360 MB transfer/**hari** ([pricing](https://firebase.google.com/pricing)) | Aset statis **unlimited**; 500 build/bulan; 20.000 file; 25 MiB/file ([limits](https://developers.cloudflare.com/pages/platform/limits/), [functions pricing](https://developers.cloudflare.com/pages/functions/pricing/)) | 300 kredit/bulan: mis. 15 GB bandwidth atau kombinasi ([credits](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/how-credits-work/)) |
| **Batasan database** | 500 MB DB, 5 GB egress, unlimited API, pause 1 minggu idle ([pricing](https://supabase.com/pricing)) | 1 GiB, 50k read/20k write/20k delete per hari, 10 GiB egress/bulan ([quotas](https://firebase.google.com/docs/firestore/quotas)) | Sama seperti B | Sama seperti A | Sama seperti A |
| **Batasan komersial** | **Hobby = non-commercial only** ([fair-use](https://vercel.com/docs/limits/fair-use-guidelines), [ToS](https://vercel.com/legal/terms)) — proyek gratis edukasi memenuhi syarat | Sama seperti A | Tidak ditemukan batasan ([ToS](https://firebase.google.com/terms)) | **Tidak terverifikasi** | **Tidak terverifikasi** (SSA PDF tidak terbaca) |
| **Kemudahan setup** | Mudah: `vercel install supabase`, env otomatis ([docs](https://vercel.com/docs/marketplace-storage)) | Sedang: setup Firebase console + SDK + security rules + denormalisasi data | Mudah–sedang: satu platform (firebase deploy), tapi pemodelan NoSQL tetap | Mudah: hubungkan repo Git; SPA otomatis ([docs](https://developers.cloudflare.com/pages/configuration/serving-pages/)) | Mudah: hubungkan repo; rewrite SPA 1 baris ([docs](https://docs.netlify.com/manage/routing/redirects/rewrites-proxies/)) |
| **Kesesuaian data relasional** | **Sangat baik** (Postgres: FK, JOIN, constraint) | **Kurang** (NoSQL: tanpa JOIN, perlu denormalisasi, delete subcollection manual) ([data-model](https://firebase.google.com/docs/firestore/data-model)) | **Kurang** (sama seperti B) | **Sangat baik** | **Sangat baik** |
| **Risiko jangka panjang** | Hobby bisa dihapus tanpa notice ([ToS §4](https://vercel.com/legal/terms)); Supabase pause idle (data aman) | Sama + risiko lock-in ke Firestore SDK & model data | Risiko perubahan kuota Spark; lock-in Google | Rendah untuk hosting statis (tidak ada batas bandwidth statis); risiko ToS belum diverifikasi | Model kredit bisa berubah; free plan hard limit tanpa top-up |
| **Cocok untuk FlashStruct?** | Ya (jika tidak ada pekerja berbayar) | Kurang (kompleksitas NoSQL tidak sepadan) | Kurang (sama + transfer 360 MB/hari) | Ya (alternatif aman) | Ya (dengan pantau kredit) |

---

## Rekomendasi

### Rekomendasi utama: **Stack A — Vercel Hobby + Supabase Free**

Alasan:

1. **Kecocokan data terbaik.** Konten FlashStruct (modul → bagian → flashcard → soal → opsi jawaban) naturalnya relasional. Postgres Supabase memberi foreign key, JOIN, dan constraint; Firestore memaksa denormalisasi dan query berlapis ([perbandingan di §3.5](#35-kecocokan-firestore-untuk-data-hierarkisrelasional--penting)).
2. **API siap pakai untuk React tanpa backend.** Supabase menyediakan REST API otomatis (PostgREST) + SDK, dan "unlimited API requests" di Free ([supabase.com/pricing](https://supabase.com/pricing)) — cocok dengan arsitektur "konten read-only diambil lewat API" tanpa perlu menulis server sendiri.
3. **Integrasi resmi & mudah.** `vercel install supabase` otomatis meng-inject kredensial ke env Vercel ([vercel.com/docs/marketplace-storage](https://vercel.com/docs/marketplace-storage)).
4. **Kuota lebih dari cukup.** 100 GB transfer + 1M invocations (Vercel) dan 500 MB DB + 5 GB egress (Supabase) sangat lega untuk 100–1.000 pengunjung/bulan.
5. **Kepatuhan komersial.** FlashStruct gratis, tanpa iklan, tanpa monetisasi → memenuhi definisi non-commercial Vercel. **Syarat mutlak: tidak boleh ada pihak yang dibayar untuk membuat/mengelola/menghosting situs ini** ([fair-use](https://vercel.com/docs/limits/fair-use-guidelines)).

**Mitigasi risiko yang perlu dilakukan:**

- **Pause Supabase:** siapkan pengingat/uptime ping mingguan, atau terima unpause manual saat proyek ter-pause setelah 1 minggu idle ([supabase.com/pricing](https://supabase.com/pricing)).
- **Hobby bisa dihapus tanpa notice:** simpan kode di GitHub (bisa redeploy cepat ke Cloudflare Pages/Netlify jika terjadi).
- **Konten Hobby untuk training AI:** disetujui secara otomatis oleh ToS ([vercel.com/legal/terms §3](https://vercel.com/legal/terms)) — jika tidak nyaman, pertimbangkan Cloudflare Pages.

### Alternatif jika ragu dengan aturan Hobby Vercel: **Stack D — Cloudflare Pages + Supabase**

Alasan: Cloudflare Pages tidak memiliki batasan bandwidth untuk aset statis — *"requests to static assets are free and unlimited"* ([pages/functions/pricing](https://developers.cloudflare.com/pages/functions/pricing/)) — dan SPA didukung otomatis ([serving-pages](https://developers.cloudflare.com/pages/configuration/serving-pages/)). Tidak ada klausa komersial yang ditemukan pada halaman yang ditinjau (namun ToS Cloudflare **belum diverifikasi menyeluruh** — lihat catatan ketidakpastian).

### Tidak direkomendasikan untuk proyek ini

- **Firebase/Firestore (Stack B & C):** bukan karena gratisannya kurang, tapi karena pemodelan NoSQL untuk data relasional menambah kompleksitas tanpa manfaat. Transfer Hosting 360 MB/hari juga lebih ketat dari alternatif lain.
- **Netlify (Stack E):** layak, tetapi model 300 kredit dengan hard limit lebih mudah habis tanpa disadari dibanding kuota Vercel/Cloudflare; tetap layak sebagai fallback.
- **Render/Railway/Fly.io:** Render free tidak punya database permanen (Postgres free expired 30 hari); Railway Free hanya $1 kredit/bulan tanpa custom domain; Fly.io hanya trial. Tidak cocok sebagai stack utama.
- **GitHub Pages:** tidak menyediakan rewrite SPA resmi dan bandwidth soft limit 100 GB — bukan pilihan utama untuk SPA React (butuh workaround `404.html`).

---

## Catatan Ketidakpastian

Klaim berikut **tidak dapat diverifikasi** dari sumber yang ditinjau, atau memiliki keterbatasan:

1. **Durasi maksimum Vercel Function untuk proyek baru dengan Fluid compute.** Halaman limits hanya memuat tabel legacy (proyek sebelum 23 April 2025): Hobby default 10 detik / maks 60 detik. Angka untuk proyek baru dengan Fluid **tidak terverifikasi**.
2. **Perilaku tepat saat melebihi kuota gratis Firestore pada Spark (tanpa billing).** Dokumentasi menyatakan kuota direset tengah malam Pacific Time dan bahwa billing diperlukan untuk kuota lebih, tetapi tidak menjelaskan secara eksplisit apakah request gagal total atau dibatasi sebagian. **Tidak terverifikasi.**
3. **Terms of Service Netlify (Self-Serve Subscription Agreement).** Dokumen resmi berbentuk PDF ([tautan](https://www.netlify.com/pdf/self-serve-subscription-agreement.pdf)) dan tidak dapat saya baca sebagai teks; klausul komersialnya **tidak terverifikasi**. Yang terverifikasi hanya ToU website dan Acceptable Use Policy.
4. **Terms of Service Cloudflare.** Tidak ditinjau dalam riset ini; ada atau tidaknya batasan komersial untuk Pages Free **tidak terverifikasi**.
5. **Terms of Service Render, Railway, dan Fly.io.** Tidak ditinjau; batasan komersial mereka **tidak terverifikasi**.
6. **Terms of Service Turso.** Tidak ditinjau; batasan komersial **tidak terverifikasi**.
7. **Detail auto-unpause Supabase.** Apakah proyek yang ter-pause karena idle otomatis aktif saat ada request, atau harus manual, **tidak terverifikasi** dari halaman yang ditinjau.
8. **Klaim "GitHub Pages tidak ada SPA rewrite".** Dokumentasi resmi tidak menyebutkan fitur rewrite (artinya fitur itu memang tidak ada), tetapi tidak ada pernyataan eksplisit "tidak mendukung SPA rewrite" — status klaim: **tidak terverifikasi secara eksplisit**, meskipun secara praktik tidak ada mekanisme rewrite yang didokumentasikan.
9. **Detail integrasi Supabase–Vercel dari sisi Supabase** ([supabase.com/partners/integrations/vercel](https://supabase.com/partners/integrations/vercel) tidak dapat dibaca karena JavaScript rendering). Yang terverifikasi hanya dari dokumentasi Vercel.
10. **Angka pastinya "build minutes" Hobby Vercel.** Halaman pricing menyebut "Basic machines: Included" tanpa angka kuota bulanan eksplisit; dokumen fair use hanya menyebut guideline. Kuota build minutes Hobby yang spesifik **tidak terverifikasi** (yang terverifikasi: build termasuk, maks 45 menit/build, 1 build bersamaan, 100 deploy/hari).
11. **Legacy pricing Netlify** (akun sebelum 4 September 2025) memiliki kuota berbeda (100 GB bandwidth / 300 build minutes adalah angka legacy yang beredar) — angka legacy ini **tidak saya verifikasi** dari halaman resmi; yang diverifikasi adalah model kredit untuk akun baru.
12. **Biaya detail Render static site** — dinyatakan gratis dan menghitung bandwidth/pipeline minutes workspace, tetapi kombinasi persisnya untuk static site saja tidak dirinci lebih jauh di halaman yang ditinjau.

---

*Dokumen ini disusun dari sumber primer yang diakses pada September 2026. Harga dan ketentuan dapat berubah; verifikasi ulang sebelum keputusan final.*
