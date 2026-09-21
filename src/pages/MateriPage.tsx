import { Link } from 'react-router-dom';
import { BookOpen } from 'lucide-react';
import { PageHeader, Card, Badge } from '@/components/ui/Card';
import { EmptyState, ErrorState, Skeleton } from '@/components/ui/States';
import { useDaftarModul } from '@/features/materi/hooks';
import { LABEL_TOPIK } from '@/lib/constants';
import { urutkan } from '@/lib/format';
import type { ModulRingkas, TopikModul } from '@/types/database';

/**
 * Halaman daftar materi.
 *
 * Menampilkan modul terkelompok per topik (Array, Struct, Pointer).
 * Tujuannya eksplorasi, bukan melanjutkan — beda dengan Dashboard
 * yang mengurutkan berdasarkan progres.
 */
export default function MateriPage() {
  const { data: daftarModul, isPending, isError, error, refetch } = useDaftarModul();

  if (isPending) return <MateriSkeleton />;

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

  // Kelompokkan per topik, urutkan sesuai urutan modul
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
                <KartuModul key={m.id} modul={m} />
              ))}
            </div>
          </section>
        ))}
      </div>
    </div>
  );
}

/** Kartu satu modul */
function KartuModul({ modul }: { modul: ModulRingkas }) {
  const jumlahBagian = modul.bagian_modul?.length ?? 0;
  const jumlahKartu = modul.flashcard?.length ?? 0;
  const jumlahSoal = modul.soal?.length ?? 0;
  const warnaTopik = `var(--topik-${modul.topik})`;

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

      <div className="mt-4 border-t border-border pt-4">
        <Link
          to={`/materi/${modul.slug}`}
          className="inline-flex h-11 items-center text-sm font-medium text-primary no-underline hover:underline md:h-9"
        >
          Baca Modul
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
              <div key={j} className="rounded-lg border border-border p-5" style={{ minHeight: 200 }}>
                <Skeleton className="h-5 w-16" />
                <Skeleton className="mt-3 h-5 w-3/4" />
                <Skeleton className="mt-2 h-4 w-full" />
                <Skeleton className="mt-4 h-4 w-2/3" />
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
