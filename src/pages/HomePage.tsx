import { Link } from 'react-router-dom';
import { useJudulHalaman } from '@/lib/useJudulHalaman';
import { ArrowRight, BookOpen, Layers, PlayCircle } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card, Badge } from '@/components/ui/Card';
import { useDaftarModul } from '@/features/materi/hooks';
import { useProgres } from '@/features/progres/context';
import { LABEL_TOPIK } from '@/lib/constants';
import { hitungStatistik } from '@/features/progres/util';
import { Skeleton } from '@/components/ui/States';
import type { ModulRingkas, TopikModul } from '@/types/database';

/**
 * Halaman Home.
 *
 * Tujuan: pengunjung baru paham produk dalam 10 detik.
 * Menjawab tiga pertanyaan: ini apa, kenapa beda, bagaimana mulai.
 *
 * Prinsip: tidak ada testimoni palsu, tidak ada klaim tanpa bukti.
 * Lebih baik halaman jujur daripada penuh klaim.
 *
 * Rincian: docs/06-SPESIFIKASI-HALAMAN.md §2
 */
export default function HomePage() {
  useJudulHalaman('FlashStruct — Belajar Struktur Data dengan Flashcard', true);
  const { data: daftarModul, isPending } = useDaftarModul();
  const { progres } = useProgres();

  const adaProgres = Object.keys(progres.modul).length > 0;
  const statistik = hitungStatistik(progres);

  /**
   * Tujuan tombol "Mulai Belajar".
   *
   * Pengguna baru diarahkan LANGSUNG ke modul pertama — kalau diarahkan
   * ke Dashboard, dia akan melihat semua angka nol dan tidak tahu
   * harus apa.
   *
   * Pengguna yang sudah punya progres diarahkan ke Dashboard untuk
   * melihat rekomendasi.
   */
  const tujuanMulai = adaProgres
    ? '/dashboard'
    : daftarModul?.[0]
      ? `/materi/${daftarModul[0].slug}`
      : '/materi';

  return (
    <div>
      {/* ============ HERO ============ */}
      <section className="container-base py-12 md:py-16">
        <div className="max-w-2xl">
          <h1 className="font-heading text-4xl font-bold leading-tight text-fg md:text-5xl">
            Hafal dulu.
            <br />
            Baru praktik.
          </h1>

          <p className="mt-5 max-w-xl text-lg leading-relaxed text-fg-muted">
            Dunia TI berat di praktik, tapi praktik tanpa hafalan yang kuat akan rapuh. FlashStruct
            membuktikannya lewat satu mata kuliah paling menantang: <strong>Struktur Data</strong>.
          </p>

          <div className="mt-7 flex flex-wrap gap-3">
            <Link to={tujuanMulai} className="inline-flex no-underline">
              <Button ukuran="lg" varian="accent" ikonKanan={<ArrowRight className="size-4" aria-hidden="true" />}>
                {adaProgres ? 'Lanjutkan Belajar' : 'Mulai Belajar'}
              </Button>
            </Link>
            <a href="#cara-kerja" className="no-underline">
              <Button ukuran="lg" varian="secondary">
                Lihat Cara Kerjanya
              </Button>
            </a>
          </div>
        </div>
      </section>

      {/* ============ MASALAH ============ */}
      <section className="border-t border-border bg-surface py-12 md:py-16">
        <div className="container-base">
          <h2 className="font-heading text-2xl font-semibold text-fg md:text-3xl">
            Kenapa &ldquo;langsung ngoding&rdquo; tidak cukup
          </h2>

          <div className="mt-6 grid gap-6 md:grid-cols-2">
            <p className="text-lg leading-relaxed text-fg-muted">
              Mahasiswa bisa menyalin kode linked list dari internet. Tapi saat ditanya:
            </p>

            <Card className="border-l-4 border-l-primary p-5">
              <p className="text-lg font-medium leading-relaxed text-fg">
                &ldquo;Apa yang terjadi pada memori saat <code className="rounded bg-surface-raised px-1.5 py-0.5 font-mono text-base">delete current</code> dipanggil?&rdquo;
              </p>
              <p className="mt-3 text-sm text-fg-muted">— tidak ada jawaban.</p>
            </Card>
          </div>

          <p className="mt-6 max-w-2xl text-fg-muted">
            Bukan karena tidak mampu. Tapi karena tidak pernah benar-benar{' '}
            <strong className="text-fg">menghafal</strong> apa yang terjadi di balik kode itu.
          </p>
        </div>
      </section>

      {/* ============ CARA KERJA ============ */}
      <section id="cara-kerja" className="scroll-mt-20 py-12 md:py-16">
        <div className="container-base">
          <h2 className="font-heading text-2xl font-semibold text-fg md:text-3xl">
            Tiga tahap, berurutan, terkunci
          </h2>
          <p className="mt-3 max-w-2xl text-fg-muted">
            Tahap berikutnya terbuka setelah tahap sebelumnya selesai. Tidak bisa dilompati.
          </p>

          <div className="mt-8 grid gap-4 md:grid-cols-3">
            <KartuTahap
              nomor={1}
              ikon={BookOpen}
              judul="Pahami"
              deskripsi="Baca modul dengan penjelasan, diagram, dan contoh kode C++ serta Python."
              ke="/materi"
              labelTombol="Buka Materi"
            />
            <KartuTahap
              nomor={2}
              ikon={Layers}
              judul="Hafalkan"
              deskripsi="Kartu yang sering lupa muncul lebih dulu. Nilai dirimu sendiri, jujur lebih bermanfaat."
              ke="/soal"
              labelTombol="Buka Flashcard"
            />
            <KartuTahap
              nomor={3}
              ikon={PlayCircle}
              judul="Buktikan"
              deskripsi="Kerjakan quiz dan lihat bagian mana yang masih perlu diperkuat."
              ke="/soal"
              labelTombol="Buka Quiz"
            />
          </div>
        </div>
      </section>

      {/* ============ TOPIK ============ */}
      <section className="border-t border-border bg-surface py-12 md:py-16">
        <div className="container-base">
          <h2 className="font-heading text-2xl font-semibold text-fg md:text-3xl">
            Yang akan kamu kuasai
          </h2>

          {isPending ? (
            <div className="mt-8 grid gap-4 md:grid-cols-3">
              {[0, 1, 2].map((i) => (
                <Skeleton key={i} className="h-32 rounded-lg" />
              ))}
            </div>
          ) : (
            <div className="mt-8 grid gap-4 md:grid-cols-3">
              <KartuTopik topik="array" modul={daftarModul ?? []} />
              <KartuTopik topik="struct" modul={daftarModul ?? []} />
              <KartuTopik topik="pointer" modul={daftarModul ?? []} />
            </div>
          )}
        </div>
      </section>

      {/* ============ ALASAN HAFALAN ============ */}
      <section className="py-12 md:py-16">
        <div className="container-base">
          <h2 className="font-heading text-2xl font-semibold text-fg md:text-3xl">
            Praktik tanpa hafalan itu rapuh
          </h2>

          <div className="mt-8 grid gap-6 md:grid-cols-3">
            <Alasan
              nomor="01"
              judul="Di wawancara kerja, kamu tidak bisa membuka Google"
              isi="Pewawancara akan bertanya tanpa memberimu waktu mencari jawaban. Yang keluar saat itu hanya yang benar-benar kamu ingat."
            />
            <Alasan
              nomor="02"
              judul="Di ujian tulis, tidak ada compiler yang membantu"
              isi="Menulis kode di kertas memaksa kamu tahu sintaks dan konsepnya tanpa bantuan autocomplete atau pesan error."
            />
            <Alasan
              nomor="03"
              judul="Saat debug, kamu butuh tahu apa yang SEHARUSNYA terjadi"
              isi="Tidak bisa menemukan bug kalau tidak tahu perilaku yang benar. Hafalan adalah peta yang membantumu melihat keanehan."
            />
          </div>
        </div>
      </section>

      {/* ============ CTA AKHIR ============ */}
      <section className="border-t border-border bg-surface py-12 md:py-16">
        <div className="container-base text-center">
          <h2 className="font-heading text-2xl font-semibold text-fg md:text-3xl">
            Siap mulai?
          </h2>

          {!isPending && daftarModul && (
            <p className="mx-auto mt-3 max-w-md text-fg-muted">
              {daftarModul.length} modul, sekitar 4,5 jam untuk tuntas. Semua gratis, tanpa perlu
              daftar akun.
            </p>
          )}

          {adaProgres && statistik.modulSelesai > 0 && (
            <p className="mt-2 text-sm text-fg-muted">
              Kamu sudah menyelesaikan {statistik.modulSelesai} modul.
            </p>
          )}

          <div className="mt-6">
            <Link to={tujuanMulai} className="inline-flex no-underline">
              <Button ukuran="lg" varian="accent">
                {adaProgres ? 'Lanjutkan Belajar' : 'Mulai Belajar'}
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* ============ FOOTER ============ */}
      <footer className="border-t border-border py-8">
        <div className="container-base">
          <div className="flex flex-wrap items-center justify-between gap-4">
            <div>
              <p className="font-heading font-bold text-fg">FlashStruct</p>
              <p className="mt-1 text-xs text-fg-muted">
                Platform belajar Struktur Data berbasis flashcard
              </p>
            </div>

            <nav aria-label="Navigasi footer">
              <ul className="flex flex-wrap gap-4 text-sm">
                <li>
                  <Link to="/materi" className="inline-flex h-11 items-center text-fg-muted no-underline hover:text-fg">
                    Materi
                  </Link>
                </li>
                <li>
                  <Link to="/video" className="inline-flex h-11 items-center text-fg-muted no-underline hover:text-fg">
                    Video
                  </Link>
                </li>
                <li>
                  <Link to="/soal" className="inline-flex h-11 items-center text-fg-muted no-underline hover:text-fg">
                    Soal
                  </Link>
                </li>
                <li>
                  <Link to="/dashboard" className="inline-flex h-11 items-center text-fg-muted no-underline hover:text-fg">
                    Dashboard
                  </Link>
                </li>
              </ul>
            </nav>
          </div>

          <p className="mt-6 text-xs text-fg-muted">
            Progres belajarmu disimpan di browser ini saja, tidak di server. Tidak ada akun, tidak
            ada pelacakan.
          </p>
        </div>
      </footer>
    </div>
  );
}

/* =========================================================
   Komponen
   ========================================================= */

function KartuTahap({
  nomor,
  ikon: Ikon,
  judul,
  deskripsi,
  ke,
  labelTombol,
}: {
  nomor: number;
  ikon: typeof BookOpen;
  judul: string;
  deskripsi: string;
  ke: string;
  labelTombol: string;
}) {
  return (
    <Card className="flex flex-col p-5">
      <div className="flex items-center gap-3">
        <span
          className="flex size-8 items-center justify-center rounded-full bg-primary/15 font-heading text-sm font-bold text-primary"
          aria-hidden="true"
        >
          {nomor}
        </span>
        <Ikon className="size-5 text-fg-muted" aria-hidden="true" />
      </div>

      <h3 className="mt-3 font-heading text-lg font-semibold text-fg">{judul}</h3>
      <p className="mt-2 flex-1 text-sm leading-relaxed text-fg-muted">{deskripsi}</p>

      <Link to={ke} className="mt-4 inline-flex no-underline">
        <span className="inline-flex h-11 items-center text-sm font-medium text-primary hover:underline md:h-9">
          {labelTombol}
          <ArrowRight className="ml-1.5 size-3.5" aria-hidden="true" />
        </span>
      </Link>
    </Card>
  );
}

/** Kartu topik dengan angka dari DATA NYATA, bukan ditulis manual */
function KartuTopik({ topik, modul }: { topik: TopikModul; modul: ModulRingkas[] }) {
  const modulTopik = modul.filter((m) => m.topik === topik);
  const jumlahModul = modulTopik.length;
  const jumlahKartu = modulTopik.reduce((n, m) => n + (m.flashcard?.length ?? 0), 0);
  const warna = `var(--topik-${topik})`;

  return (
    <Card className="p-5" >
      <div className="flex items-center gap-3">
        <span
          className="h-8 w-1 rounded-full"
          style={{ backgroundColor: warna }}
          aria-hidden="true"
        />
        <Badge warna={warna}>{LABEL_TOPIK[topik]}</Badge>
      </div>

      <p className="mt-4 font-heading text-3xl font-bold tabular-nums text-fg">{jumlahModul}</p>
      <p className="text-sm text-fg-muted">modul</p>

      <p className="mt-3 text-sm text-fg-muted">{jumlahKartu} kartu hafalan</p>
    </Card>
  );
}

function Alasan({ nomor, judul, isi }: { nomor: string; judul: string; isi: string }) {
  return (
    <div>
      <span className="font-mono text-sm font-semibold text-primary" aria-hidden="true">
        {nomor}
      </span>
      <h3 className="mt-2 font-medium leading-snug text-fg">{judul}</h3>
      <p className="mt-2 text-sm leading-relaxed text-fg-muted">{isi}</p>
    </div>
  );
}
