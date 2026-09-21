import { Link } from 'react-router-dom';
import { BookOpen, Lock } from 'lucide-react';
import { PageHeader, Card, Badge } from '@/components/ui/Card';
import { EmptyState, ErrorState, Skeleton } from '@/components/ui/States';
import { IndikatorTigaTahap } from '@/components/ui/Progress';
import { useDaftarModul } from '@/features/materi/hooks';
import { useProgres } from '@/features/progres/context';
import { statusSemuaTahap, alasanTerkunci } from '@/features/progres/aturan';
import { LABEL_TOPIK } from '@/lib/constants';
import { urutkan } from '@/lib/format';
import type { ModulRingkas, TopikModul } from '@/types/database';

/**
 * Halaman daftar materi.
 *
 * Menampilkan modul terkelompok per topik (Array, Struct, Pointer)
 * beserta indikator tiga tahap dari progres pengguna.
 */
export default function MateriPage() {
  const { data: daftarModul, isPending, isError, error, refetch } = useDaftarModul();
  const { sedangMemuat: progresMemuat, ambilModul } = useProgres();

  // Tunggu keduanya siap agar tidak ada lompatan tampilan
  if (isPending || progresMemuat) return <MateriSkeleton />;

  if (isError) {
    return (
      <div className="container-base py-8">
        <PageHeader judul="Materi" deskripsi="Pelajari konsepnya sebelum menghafal" />
        <ErrorState
          judul="Gagal memuat materi"
          pesan="Tidak bisa terhubung ke server. Periksa koneksi internet, lalu coba lagi."
          onCobaLagi={() => void refetch()}
        />
        {import.meta.env.DEV && (
          <p className="mt-4 text-center text-xs text-fg-muted">Detail: {error.message}</p>
        )}
      </div>
    );
  }

  if (!daftarModul || daftarModul.length === 0) {
    return (
      <div className="container-base py-8">
        <PageHeader judul="Materi" deskripsi="Pelajari konsepnya sebelum menghafal" />
        <EmptyState
          ikon={<BookOpen className="size-12" strokeWidth={1.5} />}
          judul="Belum ada modul"
          pesan="Konten sedang disiapkan. Coba muat ulang halaman sebentar lagi."
          aksi={
            <button
              type="button"
              onClick={() => void refetch()}
              className="cursor-pointer rounded-md border border-border-strong px-4 py-2 text-sm"
            >
              Muat Ulang
            </button>
          }
        />
      </div>
    );
  }

  // Kelompokkan per topik
  const perTopik = new Map<TopikModul, ModulRingkas[]>();
  for (const m of urutkan(daftarModul)) {
    const daftar = perTopik.get(m.topik) ?? [];
    daftar.push(m);
    perTopik.set(m.topik, daftar);
  }

  return (
    <div className="container-base py-8">
      <PageHeader judul="Materi" deskripsi="Pelajari konsepnya sebelum menghafal" />

      <div className="space-y-10">
        {[...perTopik.entries()].map(([topik, modulTopik]) => (
          <section key={topik}>
            <div className="mb-4 flex items-center gap-3">
              <h2 className="font-heading text-xl font-semibold text-fg">{LABEL_TOPIK[topik]}</h2>
              <span className="text-sm text-fg-muted">{modulTopik.length} modul</span>
            </div>

            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {modulTopik.map((m) => (
                <KartuModul key={m.id} modul={m} progresModul={ambilModul(m.id)} />
              ))}
            </div>
          </section>
        ))}
      </div>
    </div>
  );
}

/** Kartu satu modul dengan indikator tiga tahap */
function KartuModul({
  modul,
  progresModul,
}: {
  modul: ModulRingkas;
  progresModul: ReturnType<ReturnType<typeof useProgres>['ambilModul']>;
}) {
  const jumlahBagian = modul.bagian_modul?.length ?? 0;
  const jumlahKartu = modul.flashcard?.length ?? 0;
  const jumlahSoal = modul.soal?.length ?? 0;
  const warnaTopik = `var(--topik-${modul.topik})`;

  const status = statusSemuaTahap(progresModul);
  const tahap1Selesai = status[0] === 'selesai';
  const tahap2Terkunci = status[1] === 'terkunci';

  // CTA sesuai kondisi tahap
  const cta = !tahap1Selesai
    ? { label: 'Baca Modul', ke: `/materi/${modul.slug}`, aktif: true }
    : tahap2Terkunci
      ? { label: 'Baca Modul', ke: `/materi/${modul.slug}`, aktif: true }
      : status[1] === 'tersedia'
        ? { label: 'Mulai Flashcard', ke: `/soal/flashcard/${modul.slug}`, aktif: true }
        : status[2] === 'tersedia'
          ? { label: 'Mulai Quiz', ke: `/soal/quiz/${modul.slug}`, aktif: true }
          : { label: 'Ulangi', ke: `/materi/${modul.slug}`, aktif: true };

  return (
    <Card className="flex flex-col p-5">
      <div className="flex items-start gap-3">
        <span
          className="mt-1 h-10 w-1 shrink-0 rounded-full"
          style={{ backgroundColor: warnaTopik }}
          aria-hidden="true"
        />
        <div className="min-w-0 flex-1">
          <Badge warna={warnaTopik}>{LABEL_TOPIK[modul.topik]}</Badge>
          <h3 className="mt-2 font-semibold text-fg">{modul.judul}</h3>
          <p className="mt-1 text-sm text-fg-muted">{modul.deskripsi}</p>
        </div>
      </div>

      <p className="mt-4 text-xs text-fg-muted">
        {jumlahBagian} bagian · {jumlahKartu} kartu · {jumlahSoal} soal ·{' '}
        {modul.estimasi_menit} mnt
      </p>

      {/* Indikator tiga tahap — inti metode belajar */}
      <div className="mt-4 border-t border-border pt-4">
        <IndikatorTigaTahap tahap={status} />
      </div>

      {/* Keterangan kenapa terkunci, bukan sekadar "terkunci" */}
      {tahap2Terkunci && !tahap1Selesai && (
        <p className="mt-3 flex items-start gap-1.5 text-xs text-fg-muted">
          <Lock className="mt-0.5 size-3 shrink-0" aria-hidden="true" />
          {alasanTerkunci(2)}
        </p>
      )}

      <div className="mt-auto pt-4">
        <Link
          to={cta.ke}
          className="inline-flex h-11 items-center text-sm font-medium text-primary no-underline hover:underline md:h-9"
        >
          {cta.label}
        </Link>
      </div>
    </Card>
  );
}

/** Skeleton dengan tinggi yang sama dengan konten akhir (cegah CLS) */
function MateriSkeleton() {
  return (
    <div className="container-base py-8" aria-busy="true" aria-live="polite">
      <span className="sr-only">Memuat materi…</span>
      <div className="mb-6">
        <Skeleton className="h-9 w-40" />
        <Skeleton className="mt-3 h-4 w-72" />
      </div>
      {[0, 1].map((i) => (
        <div key={i} className="mb-10">
          <Skeleton className="mb-4 h-6 w-28" />
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {[0, 1, 2].map((j) => (
              <div key={j} className="rounded-lg border border-border p-5" style={{ minHeight: 260 }}>
                <Skeleton className="h-5 w-16" />
                <Skeleton className="mt-3 h-5 w-3/4" />
                <Skeleton className="mt-2 h-4 w-full" />
                <Skeleton className="mt-4 h-4 w-2/3" />
                <Skeleton className="mt-4 h-4 w-full" />
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
