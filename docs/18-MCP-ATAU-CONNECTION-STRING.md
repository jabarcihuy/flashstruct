# 18 — MCP atau Connection String?

> Jawaban atas pertanyaan: "apakah mcp atau connection string?"
> Status: `[PANDUAN]` · Berisi perbandingan dan rekomendasi

---

## 1. Jawaban Singkat

**Pakai keduanya, untuk tugas berbeda.**

| Tugas | Pakai apa |
|-------|-----------|
| Membuat tabel, jalankan DDL | **MCP** |
| Menambah konten (seed) | **MCP** |
| Cek struktur tabel | **MCP** |
| Lihat data | **MCP** |
| Uji keamanan RLS | **Connection string** (via `psql`) |
| Backup / `pg_dump` | **Connection string** |
| Perbaikan darurat saat MCP mati | **Connection string** |

**Rekomendasi: setup MCP dulu** (lebih aman, tidak perlu bagikan password). Connection string hanya kalau perlu `pg_dump` atau backup.

---

## 2. Perbandingan Jujur

| Aspek | MCP | Connection String |
|-------|-----|-------------------|
| **Apa yang Anda bagikan** | OAuth token (bisa dicabut kapan saja) | Password database (permanen) |
| **Apakah saya lihat password?** | **Tidak** | Ya |
| **Bisa dicabut?** | Ya, dari dashboard | Harus reset password |
| **Bisa `pg_dump`?** | Tidak | **Ya** |
| **Bisa jalankan DDL?** | **Ya** | Ya |
| **Setup** | Perlu OAuth browser | Salin string |
| **Kalau bocor, dampaknya** | Akses ke project | **Akses penuh ke database** |
| **Audit log** | Ya, di dashboard | Terbatas |

### Kesimpulan

**MCP lebih aman** karena:
1. Anda tidak perlu membagikan password
2. Token bisa dicabut kapan saja tanpa ganti password
3. Ada audit log — Anda bisa lihat apa yang saya lakukan

**Connection string lebih powerful** karena bisa `pg_dump`, tapi risikonya lebih besar.

---

## 3. Rekomendasi: MCP Dulu

### 3.1 Mengapa MCP

Bayangkan MCP seperti **memberi saya kunci tamu** ke rumah Anda:
- Kunci itu bisa Anda tarik kembali kapan saja
- Anda bisa lihat catatan kapan kunci dipakai
- Kalau hilang, cukup ganti kunci tamu — tidak perlu ganti kunci utama

Sedangkan connection string seperti **memberi kunci utama**:
- Kalau bocor, seluruh rumah terbuka
- Untuk mencabutnya, harus ganti kunci utama (reset password)
- Tidak ada catatan siapa yang masuk

### 3.2 Status Database Anda

**Kabar baik:** Anda sudah menjalankan DDL dan RLS. Saya sudah verifikasi:

| Item | Status |
|------|--------|
| 6 tabel dibuat | Ya |
| RLS aktif di semua tabel | Ya |
| Uji tulis ditolak | **Ya — benar!** |
| Data | Kosong — seed belum dijalankan |

Jadi yang tersisa hanya:
1. Jalankan seed (isi data contoh)
2. Verifikasi query bertingkat

**Keduanya bisa lewat MCP.**

---

## 4. Cara Setup MCP

### 4.1 Buat File Konfigurasi

Saya akan buatkan `.mcp.json` di root proyek:

```json
{
  "mcpServers": {
    "supabase": {
      "type": "http",
      "url": "https://mcp.supabase.com/mcp?project_ref=lxvoedfjecmmwfrfhbah"
    }
  }
}
```

Perhatikan `project_ref=lxvoedfjecmmwfrfhbah` — ini membatasi akses **hanya ke project FlashStruct**, bukan seluruh akun Supabase Anda.

### 4.2 Autentikasi

Setelah file dibuat, Anda perlu:
1. Restart sesi agen (atau muat ulang)
2. Ikuti alur OAuth yang muncul di browser
3. Login ke Supabase
4. Izinkan akses

Setelah itu, saya bisa langsung mengakses database Anda.

### 4.3 Cara Mencabut Akses

Kapan saja Anda bisa mencabut:
1. Buka Supabase Dashboard
2. **Account** > **Access Tokens** (atau **Applications**)
3. Cabut akses untuk MCP

Setelah dicabut, saya tidak bisa mengakses apa pun.

---

## 5. Kalau Butuh Connection String

Untuk tugas yang tidak bisa dilakukan MCP:

### 5.1 Ambil dari Dashboard

1. Buka project Supabase
2. Klik **Connect** (kanan atas)
3. Pilih **Session pooler**
4. Salin connection string

### 5.2 Simpan dengan Aman

**JANGAN simpan di `.env.local`** — file itu dibaca Vite dan bisa masuk bundle browser.

Simpan di `~/.pgpass`:

```bash
echo "aws-0-ap-southeast-1.pooler.supabase.com:5432:postgres:postgres.lxvoedfjecmmwfrfhbah:PASSWORD_ANDA" >> ~/.pgpass
chmod 600 ~/.pgpass
```

Setelah itu, `psql` tidak akan menanyakan password lagi.

### 5.3 Kalau Anda Beri ke Saya

Kalau Anda ingin saya bisa `pg_dump`, kirim connection string lengkapnya. Tapi pertimbangkan:

| Risiko | Mitigasi |
|--------|----------|
| Connection string tersimpan di riwayat chat | Bisa Anda hapus setelah selesai |
| Akses penuh ke database | Hanya dipakai untuk backup |
| Harus reset password kalau bocor | Reset mudah dari dashboard |

**Saran saya: coba MCP dulu.** Kalau nanti butuh backup, baru berikan connection string.

---

## 6. Yang Bisa Saya Lakukan Setelah MCP Aktif

| Tugas | Bisa? |
|-------|-------|
| Jalankan seed data | Ya |
| Cek struktur tabel | Ya |
| Lihat isi tabel | Ya |
| Tambah/ubah konten | Ya |
| Jalankan query apa pun | Ya |
| Lihat log database | Ya |
| Cek saran perbaikan | Ya |
| `pg_dump` / backup | **Tidak** — perlu connection string |
| Restore dari backup | **Tidak** — perlu connection string |

---

## 7. Perbandingan Risiko

### Dengan MCP

```
Anda ──login OAuth──> Supabase
                          │
                     token (bisa dicabut)
                          │
                          v
                    Saya akses database
```

| Kalau terjadi | Dampak |
|---------------|--------|
| Token bocor | Anda cabut dari dashboard |
| Saya salah perintah | Bisa di-rollback dari dashboard |
| Anda tidak mau lagi | Cabut token, selesai |

### Dengan Connection String

```
Anda ──kirim password──> Saya
                            │
                       password (permanen)
                            │
                            v
                      Saya akses database
```

| Kalau terjadi | Dampak |
|---------------|--------|
| Password bocor | **Siapa pun bisa akses penuh** |
| Saya salah perintah | Sama |
| Anda tidak mau lagi | **Harus reset password** |

---

## 8. Rekomendasi Akhir

| Langkah | Aksi |
|---------|------|
| 1 | **Setup MCP** — saya buatkan `.mcp.json` |
| 2 | **Anda autentikasi** lewat browser |
| 3 | **Saya jalankan seed** dan verifikasi |
| 4 | **Nanti kalau perlu backup** — baru berikan connection string |

**Mengapa:** MCP memberi Anda kendali untuk mencabut akses kapan saja, tanpa harus mengganti password. Untuk tugas-tugas yang bisa dilakukan MCP, tidak ada alasan untuk membagikan password.

---

## 9. Yang Perlu Anda Lakukan Sekarang

Kalau setuju pakai MCP:

1. **Katakan "ya"** — saya buatkan `.mcp.json`
2. **Restart sesi agen** agar konfigurasi terbaca
3. **Ikuti alur OAuth** di browser
4. Setelah itu saya bisa langsung bekerja

Kalau lebih suka connection string:

1. Ambil dari **Dashboard > Connect > Session pooler**
2. Kirim ke saya
3. Saya simpan di tempat aman (bukan `.env.local`)

**Saran saya: MCP dulu.** Kalau nanti ternyata butuh `pg_dump`, baru berikan connection string.

---

## 10. Catatan: Status Database Sekarang

Saya sudah verifikasi database Anda:

| Item | Status |
|------|--------|
| Project URL | Berfungsi |
| Publishable key | Valid |
| 6 tabel | **Dibuat** |
| RLS aktif | **Ya, di semua 6 tabel** |
| Uji tulis | **Ditolak — benar** |
| Data | Kosong |

**Anda sudah melakukan bagian tersulit dengan benar.** Yang tersisa hanya mengisi data dan verifikasi.

---

## 11. Referensi

| Topik | Dokumen |
|-------|---------|
| Kontrol database dari laptop | `17-KONTROL-DATABASE-LOKAL.md` |
| Kenapa RLS wajib | `16-KENAPA-RLS-WAJIB.md` |
| Setup Supabase | `15-SETUP-SUPABASE-UNTUK-ANDA.md` |
| Migrasi SQL | `supabase/migrations/` |
