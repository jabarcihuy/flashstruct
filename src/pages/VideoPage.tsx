import { Link } from 'react-router-dom';
import { BookOpen, PlayCircle } from 'lucide-react';
import { Card, Badge, PageHeader } from '@/components/ui/Card';
import { EmptyState, ErrorState, Skeleton } from '@/components/ui/States';
import { useSemuaVideo } from '@/features/video/hooks';
import { VideoPlayer } from '@/features/video/VideoPlayer';
import { LABEL_TOPIK } from '@/lib/constants';
import { durasi } from '@/lib/format';
import { useState } from 'react';
import type { TopikModul, VideoDenganModul } from '@/types/database';

/**
 * Halaman galeri video.
 *
 * Video bersifat OPSIONAL menurut PRD — tidak memblokir progres.
 * Karena itu halaman ini harus tetap berguna walau hanya berisi
 * sedikit video, dengan pesan yang jujur dan mengarahkan.
 */
export default function VideoPage() {
  const { data: daftarVideo, isPending, isError, error, refetch } = useSemuaVideo();
  const [videoDiputar, setVideoDiputar] = useState<VideoDenganModul | null>(null);

  if (isPending) return <VideoSkeleton />;

  if (isError) {
    return (
      <div className="container-base py-8">
        <PageHeader
          judul="Video"
          deskripsi="Penjelasan visual untuk konsep yang sulit dibayangkan"
        />
        <ErrorState
          judul="Gagal memuat video"
          pesan="Tidak bisa terhubung ke server. Periksa koneksi internet, lalu coba lagi."
          onCobaLagi={() => void refetch()}
        />
        {import.meta.env.DEV && (
          <p className="mt-4 text-center text-xs text-fg-muted">Detail: {error.message}</p>
        )}
      </div>
    );
  }

  // Halaman kosong harus JUJUR dan mengarahkan, bukan sekadar "Belum ada data"
  if (!daftarVideo || daftarVideo.length === 0) {
    return (
      <div className="container-base py-8">
        <PageHeader
          judul="Video"
          deskripsi="Penjelasan visual untuk konsep yang sulit dibayangkan"
        />
        <EmptyState
          ikon={<PlayCircle className="size-12" strokeWidth={1.5} />}
          judul="Video sedang disiapkan"
          pesan="Untuk saat ini, semua konsep sudah dijelaskan lengkap di halaman Materi. Video hanya pendukung, dan tidak wajib untuk menyelesaikan tahap belajar."
          aksi={
            <Link to="/materi" className="no-underline">
              <span className="inline-flex h-11 items-center gap-2 rounded-md bg-primary px-4 text-sm font-medium text-on-primary md:h-10">
                <BookOpen className="size-4" aria-hidden="true" />
                Buka Halaman Materi
              </span>
            </Link>
          }
        />
      </div>
    );
  }

  // Kelompokkan per topik modul
  const perTopik = new Map<TopikModul, VideoDenganModul[]>();
  for (const v of daftarVideo) {
    const daftar = perTopik.get(v.modul.topik) ?? [];
    daftar.push(v);
    perTopik.set(v.modul.topik, daftar);
  }

  return (
    <div className="container-base py-8">
      <PageHeader
        judul="Video"
        deskripsi="Penjelasan visual untuk konsep yang sulit dibayangkan"
      />

      <div className="space-y-10">
        {[...perTopik.entries()].map(([topik, daftarTopik]) => (
          <section key={topik}>
            <div className="mb-4 flex items-center gap-3">
              <h2 className="font-heading text-xl font-semibold text-fg">{LABEL_TOPIK[topik]}</h2>
              <span className="text-sm text-fg-muted">{daftarTopik.length} video</span>
            </div>

            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {daftarTopik.map((v) => (
                <KartuVideo key={v.id} video={v} onPutar={() => setVideoDiputar(v)} />
              ))}
            </div>
          </section>
        ))}
      </div>

      {videoDiputar && (
        <VideoPlayer video={videoDiputar} onTutup={() => setVideoDiputar(null)} />
      )}
    </div>
  );
}

/** Kartu satu video dengan thumbnail */
function KartuVideo({ video, onPutar }: { video: VideoDenganModul; onPutar: () => void }) {
  const warnaTopik = `var(--topik-${video.modul.topik})`;

  return (
    <Card className="flex flex-col overflow-hidden">
      <button
        type="button"
        onClick={onPutar}
        className="group relative block cursor-pointer text-left"
        aria-label={`Putar video: ${video.judul}`}
      >
        {/* Thumbnail dengan dimensi eksplisit — cegah layout shift */}
        <img
          src={`https://img.youtube.com/vi/${video.youtube_id}/hqdefault.jpg`}
          alt=""
          width={480}
          height={270}
          loading="lazy"
          decoding="async"
          className="aspect-video w-full object-cover"
        />

        {/* Lapisan gelap + ikon putar saat hover */}
        <span
          aria-hidden="true"
          className="absolute inset-0 flex items-center justify-center bg-black/30 opacity-0 transition-opacity duration-150 group-hover:opacity-100"
        >
          <PlayCircle className="size-12 text-white" strokeWidth={1.5} />
        </span>

        {video.durasi_detik && (
          <span className="absolute bottom-2 right-2 rounded bg-black/80 px-1.5 py-0.5 font-mono text-xs text-white">
            {durasi(video.durasi_detik)}
          </span>
        )}
      </button>

      <div className="flex flex-1 flex-col p-4">
        <Badge warna={warnaTopik}>{LABEL_TOPIK[video.modul.topik]}</Badge>
        <h3 className="mt-2 font-medium text-fg">{video.judul}</h3>
        {video.deskripsi && (
          <p className="mt-1 line-clamp-2 text-sm text-fg-muted">{video.deskripsi}</p>
        )}
        <p className="mt-auto pt-3 text-xs text-fg-muted">dari: {video.modul.judul}</p>
      </div>
    </Card>
  );
}

function VideoSkeleton() {
  return (
    <div className="container-base py-8" aria-busy="true" aria-live="polite">
      <span className="sr-only">Memuat video…</span>
      <Skeleton className="h-9 w-32" />
      <Skeleton className="mt-3 h-4 w-80" />
      <div className="mt-8">
        <Skeleton className="mb-4 h-6 w-24" />
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[0, 1, 2].map((i) => (
            <div key={i} className="overflow-hidden rounded-lg border border-border">
              <Skeleton className="aspect-video w-full rounded-none" />
              <div className="p-4">
                <Skeleton className="h-5 w-16" />
                <Skeleton className="mt-2 h-5 w-3/4" />
                <Skeleton className="mt-2 h-4 w-full" />
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
