import { Link } from 'react-router-dom';
import { useJudulHalaman } from '@/lib/useJudulHalaman';
import { ArrowRight, BookOpen, PlayCircle } from 'lucide-react';
import { Card, Badge, PageHeader } from '@/components/ui/Card';
import { ErrorState, Skeleton } from '@/components/ui/States';
import { useSemuaVideo } from '@/features/video/hooks';
import { VideoPlayer } from '@/features/video/VideoPlayer';
import { LABEL_TOPIK, YOUTUBE_ID_VIDEO_CONTOH } from '@/lib/constants';
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
  useJudulHalaman('Video');
  const { data: daftarVideo, isPending, isError, error, refetch } = useSemuaVideo();
  const [videoDiputar, setVideoDiputar] = useState<VideoDenganModul | null>(null);
  const videoTayang = daftarVideo?.filter((video) => video.youtube_id !== YOUTUBE_ID_VIDEO_CONTOH);

  if (isPending) return <VideoSkeleton />;

  if (isError) {
    return (
      <div className="container-base video-page py-8">
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
  if (!videoTayang || videoTayang.length === 0) {
    return (
      <div className="container-base py-8">
        <PageHeader
          judul="Video"
          deskripsi="Penjelasan visual untuk konsep yang sulit dibayangkan"
        />
        <section className="video-empty">
          <div className="video-empty-copy">
            <PlayCircle className="size-8 text-link" strokeWidth={1.5} aria-hidden="true" />
            <h2>Video sedang disiapkan</h2>
            <p>
              Untuk saat ini, semua konsep sudah dijelaskan lengkap di halaman Materi. Video hanya
              pendukung, dan tidak wajib untuk menyelesaikan tahap belajar.
            </p>
            <Link to="/materi" className="video-empty-action">
              <BookOpen className="size-4" aria-hidden="true" />
              Buka Halaman Materi
              <ArrowRight className="size-4" aria-hidden="true" />
            </Link>
          </div>
          <div className="video-empty-path">
            <h3>Belajar tetap bisa lanjut</h3>
            <ol>
              <li>
                <span>1</span>
                <strong>Pahami</strong>
                <small>Baca modul dan contoh kodenya.</small>
              </li>
              <li>
                <span>2</span>
                <strong>Hafalkan</strong>
                <small>Ulangi konsep lewat flashcard.</small>
              </li>
              <li>
                <span>3</span>
                <strong>Buktikan</strong>
                <small>Kerjakan quiz untuk mengecek pemahaman.</small>
              </li>
            </ol>
          </div>
        </section>
      </div>
    );
  }

  // Kelompokkan per topik modul
  const perTopik = new Map<TopikModul, VideoDenganModul[]>();
  for (const v of videoTayang) {
    const daftar = perTopik.get(v.modul.topik) ?? [];
    daftar.push(v);
    perTopik.set(v.modul.topik, daftar);
  }

  return (
    <div className="container-base video-page py-8">
      <PageHeader judul="Video" deskripsi="Penjelasan visual untuk konsep yang sulit dibayangkan" />

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

      {videoDiputar && <VideoPlayer video={videoDiputar} onTutup={() => setVideoDiputar(null)} />}
    </div>
  );
}

/** Kartu satu video dengan thumbnail */
function KartuVideo({ video, onPutar }: { video: VideoDenganModul; onPutar: () => void }) {
  const warnaTopik = `var(--topik-${video.modul.topik})`;

  return (
    <Card className="video-card flex flex-col overflow-hidden">
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
            <div key={i} className="overflow-hidden rounded-md border border-border">
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
