# 19 — Catatan Skill yang Terpasang

> Skill agen yang dipasang di proyek ini, dan cara memasangnya ulang.
> Status: `[CATATAN]`

---

## 1. Daftar Skill

| Skill | Fungsi | Ukuran | Sumber |
|-------|--------|--------|--------|
| `supabase` | Panduan kerja dengan Supabase (RLS, migrasi, debug) | 288 KB | `supabase/agent-skills` |
| `supabase-postgres-best-practices` | Praktik terbaik PostgreSQL | — | `supabase/agent-skills` |
| `neon` | Panduan Neon (untuk referensi, tidak dipakai) | 288 KB | `neondatabase/agent-skills` |
| `neon-postgres` | Praktik Neon | — | `neondatabase/agent-skills` |
| `impeccable` | Pemeriksa kualitas UI/UX | 2,2 MB (tanpa binary) | Dipasang manual |

---

## 2. Cara Memasang Ulang

### 2.1 Skill Supabase

```bash
npx skills add supabase/agent-skills --agent '*' -y
```

Menghasilkan:

```
.agents/skills/supabase/
.agents/skills/supabase-postgres-best-practices/
```

### 2.2 Skill Neon

```bash
npx neon@latest skills -s neon -s neon-postgres -y
```

Menghasilkan:

```
.agents/skills/neon/
.agents/skills/neon-postgres/
```

**Catatan:** Neon tidak dipakai di proyek ini (lihat `14-KEPUTUSAN-ARSITEKTUR-DATA.md`). Skill ini disimpan sebagai referensi kalau nanti diperlukan.

### 2.3 Skill Impeccable

Skill ini punya **binary platform-specific** yang tidak di-commit karena berukuran 16 MB. Setelah clone, binary-nya perlu dipasang ulang.

**Cara memasang:**

Ikuti dokumentasi resmi skill impeccable di repositori asalnya. Binary akan tersimpan di:

```
.agents/skills/impeccable/scripts/bin/linux-x64/impeccable
```

**Yang di-commit:** semua berkas teks (SKILL.md, reference/, scripts/*.js, data/).
**Yang tidak di-commit:** folder `scripts/bin/` (binary 16 MB).

Alasan binary tidak di-commit:

1. Ukurannya 16 MB — memperlambat clone untuk semua orang
2. Bersifat platform-specific — binary Linux tidak berguna di macOS/Windows
3. Bukan bagian dari kode aplikasi

---

## 3. Duplikat untuk Agen Lain

Tool pemasang skill membuat **salinan** di beberapa lokasi untuk kompatibilitas berbagai agen:

```
.agents/skills/       <- SUMBER ASLI (di-commit)
.claude/skills/       <- salinan untuk Claude Code (di-gitignore)
.codex/               <- konfigurasi hook Codex (di-commit, kecil)
```

**Yang di-commit hanya `.agents/skills/`** karena isinya identik dengan salinan lainnya. Meng-commit semuanya akan menggandakan ukuran repo tanpa manfaat.

---

## 4. Isi `.gitignore` yang Relevan

```gitignore
# Duplikat skill untuk agen lain (sumber asli di .agents/skills/)
/.claude/skills/

# Binary skill impeccable (platform-specific, 16 MB)
.agents/skills/impeccable/scripts/bin/
```

---

## 5. Cara Memakai Skill

Skill dimuat otomatis oleh agen saat topiknya relevan. Contoh:

| Situasi | Skill yang aktif |
|---------|------------------|
| Bekerja dengan Supabase, RLS, migrasi | `supabase` |
| Menulis query SQL atau mendesain skema | `supabase-postgres-best-practices` |
| Memeriksa kualitas UI/UX | `impeccable` |

Skill **tidak perlu dipanggil manual** — agen membacanya saat deskripsi skill cocok dengan tugas yang sedang dikerjakan.

---

## 6. Referensi Silang

| Topik | Dokumen |
|-------|---------|
| Keputusan memakai Supabase (bukan Neon) | `14-KEPUTUSAN-ARSITEKTUR-DATA.md` |
| Skema database | `05-SKEMA-DATABASE.md` |
| Design system (dipakai skill impeccable) | `03-DESIGN-SYSTEM.md` |
