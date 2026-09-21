import { Link, useParams } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import { Card, PageHeader, Badge } from '@/components/ui/Card';
import { EmptyState, ErrorState, Skeleton } from '@/components/ui/States';
import { useModulLengkap } from '@/features/materi/hooks';
import { LABEL_TOPIK } from '@/lib/constants';
import { urutkan } from '@/lib/format';

/**
 * Halaman baca modul.
 *
 * Pada M2, halaman ini menampilkan daftar bagian dan video dalam
 * bentuk sederhana. Rendering markdown penuh, blok kode berwarna,
 * dan pelacakan progres baca dikerjakan di M4.
 */
export default function ModulDetailPage() {
  const { slug = '' } = useParams();
  const { data: modul, isPending, isError, error, refetch } = useModulLengkap(slug);

  if (isPending) return <ModulSkeleton />;

  if (isError) {
    return (
      <div className="container-narrow py-8">
        <ErrorState
          judul="Gagal memuat modul"
          pesan="Tidak bisa terhubung ke server. Periksa koneksi internet, lalu coba lagi."
          onCobaLagi={() => void refetch()}
        />
        {import.meta.env.DEV && (
          <p className="mt-4 text-center text-xs text-fg-muted">Detail: {error.message}</p>
        )}
      </div>
    );
  }

  if (!modul) {
    return (
      <div className="container-narrow py-8">
        <EmptyState
          judul="Modul tidak ditemukan"
          pesan={`Tidak ada modul dengan alamat "${slug}". Mungkin tautannya salah.`}
          aksi={
            <Link to="/materi" className="no-underline">
              <span className="inline-flex h-11 items-center rounded-md border border-border-strong px-4 text-sm md:h-9">
                Kembali ke daftar materi
              </span>
            </Link>
          }
        />
      </div>
    );
  }

  const bagian = urutkan(modul.bagian_modul);
  const video = urutkan(modul.video);
  const warnaTopik = `var(--topik-${modul.topik})`;

  return (
    <div className="container-narrow py-8">
      <Link
        to="/materi"
        className="mb-6 inline-flex h-11 items-center gap-2 text-sm text-fg-muted no-underline hover:text-fg md:h-9"
      >
        <ArrowLeft className="size-4" aria-hidden="true" />
        Kembali ke daftar materi
      </Link>

      <div className="flex items-start gap-4">
        <span
          className="mt-1.5 h-12 w-1 shrink-0 rounded-full"
          style={{ backgroundColor: warnaTopik }}
          aria-hidden="true"
        />
        <div className="min-w-0 flex-1">
          <Badge warna={warnaTopik}>{LABEL_TOPIK[modul.topik]}</Badge>
          <PageHeader
            judul={modul.judul}
            deskripsi={`${modul.estimasi_menit} menit baca · ${bagian.length} bagian · ${video.length} video`}
          />
        </div>
      </div>

      <p className="mb-8 text-fg-muted">{modul.deskripsi}</p>

      {/* Daftar bagian */}
      <section className="mb-10">
        <h2 className="mb-4 font-heading text-xl font-semibold text-fg">Isi Modul</h2>
        <ol className="space-y-3">
          {bagian.map((b, i) => (
            <li key={b.id}>
              <Card className="p-4">
                <div className="flex items-start gap-3">
                  <span
                    className="mt-0.5 flex size-6 shrink-0 items-center justify-center rounded-full text-xs font-semibold"
                    style={{
                      backgroundColor: `color-mix(in srgb, ${warnaTopik} 15%, transparent)`,
                      color: warnaTopik,
                    }}
                    aria-hidden="true"
                  >
                    {i + 1}
                  </span>
                  <div className="min-w-0">
                    <h3 className="font-medium text-fg">{b.judul}</h3>
                    <p className="mt-1 line-clamp-2 text-sm text-fg-muted">{b.konten_md}</p>
                  </div>
                </div>
              </Card>
            </li>
          ))}
        </ol>
      </section>

      {/* Video pendukung */}
      {video.length > 0 && (
        <section className="mb-10">
          <h2 className="mb-4 font-heading text-xl font-semibold text-fg">Video Pendukung</h2>
          <div className="space-y-3">
            {video.map((v) => (
              <Card key={v.id} className="p-4">
                <h3 className="font-medium text-fg">{v.judul}</h3>
                {v.deskripsi && <p className="mt-1 text-sm text-fg-muted">{v.deskripsi}</p>}
                <p className="mt-2 font-mono text-xs text-fg-muted">youtube.com/watch?v={v.youtube_id}</p>
              </Card>
            ))}
          </div>
        </section>
      )}

      <Card className="border-dashed p-4">
        <p className="text-sm text-fg-muted">
          <strong className="text-fg">Tahap berikutnya belum tersedia.</strong> Rendering konten
          penuh, blok kode berwarna, dan tombol &ldquo;Tandai Selesai&rdquo; dikerjakan di M4.
        </p>
      </Card>
    </div>
  );
}

function ModulSkeleton() {
  return (
    <div className="container-narrow py-8" aria-busy="true" aria-live="polite">
      <span className="sr-only">Memuat modul…</span>
      <Skeleton className="h-4 w-40" />
      <Skeleton className="mt-6 h-5 w-16" />
      <Skeleton className="mt-3 h-9 w-3/4" />
      <Skeleton className="mt-3 h-4 w-1/2" />
      <div className="mt-8 space-y-3">
        {[0, 1, 2, 3, 4].map((i) => (
          <div key={i} className="rounded-lg border border-border p-4" style={{ minHeight: 76 }}>
            <Skeleton className="h-4 w-2/3" />
            <Skeleton className="mt-2 h-3 w-full" />
          </div>
        ))}
      </div>
    </div>
  );
}
