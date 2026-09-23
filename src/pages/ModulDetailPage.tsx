import { useEffect, useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ArrowLeft, ExternalLink, PlayCircle } from 'lucide-react';
import { PageHeader, Badge, Card } from '@/components/ui/Card';
import { EmptyState, ErrorState, Skeleton } from '@/components/ui/States';
import { MarkdownRenderer } from '@/components/markdown/MarkdownRenderer';
import { useModulLengkap } from '@/features/materi/hooks';
import { useProgres } from '@/features/progres/context';
import { useProgresBaca } from '@/features/materi/useProgresBaca';
import { SidebarDaftarIsi, TombolDaftarIsiMobile } from '@/features/materi/DaftarIsi';
import { PanelLanjut } from '@/features/materi/PanelLanjut';
import { VideoPlayer } from '@/features/video/VideoPlayer';
import { LABEL_TOPIK, YOUTUBE_ID_VIDEO_CONTOH } from '@/lib/constants';
import { durasi, urutkan } from '@/lib/format';
import type { VideoDenganModul } from '@/types/database';

/**
 * Halaman baca modul — Tahap 1 (Pahami).
 *
 * Tata letak berbeda antara desktop dan mobile:
 *   Desktop (lg+): sidebar daftar isi sticky di kiri
 *   Mobile       : drawer daftar isi yang bisa dibuka
 *
 * Pelacakan progres baca memakai IntersectionObserver: bagian
 * dianggap dibaca setelah 60% isinya terlihat.
 */
export default function ModulDetailPage() {
  const { slug = '' } = useParams();
  const { data: modul, isPending, isError, error, refetch } = useModulLengkap(slug);
  const { ambilModul, tandaiModulSelesai, batalkanModulSelesai } = useProgres();

  const bagian = useMemo(() => urutkan(modul?.bagian_modul), [modul?.bagian_modul]);
  const slugBagian = useMemo(() => bagian.map((b) => b.slug), [bagian]);

  const progresModul = modul ? ambilModul(modul.id) : undefined;
  const tahap1Selesai = progresModul?.tahap1Selesai ?? false;

  const { bagianDibaca, persen } = useProgresBaca(modul?.id ?? '', slugBagian);

  // Bagian yang sedang terlihat — untuk menandai item aktif di daftar isi
  const [bagianAktif, setBagianAktif] = useState<string | undefined>();
  const [videoDiputar, setVideoDiputar] = useState<VideoDenganModul | null>(null);

  useEffect(() => {
    function periksaBagianAktif() {
      const daftarElemen = document.querySelectorAll<HTMLElement>('[data-bagian-slug]');
      if (daftarElemen.length === 0) return;

      // Garis fokus pembacaan: 140px dari bagian atas viewport
      const garisBaca = 140;
      let kandidat: string | undefined;

      for (const el of daftarElemen) {
        const rect = el.getBoundingClientRect();
        // Bagian yang telah mencapai garis baca dan belum lewat sepenuhnya
        if (rect.top <= garisBaca && rect.bottom > 80) {
          kandidat = el.getAttribute('data-bagian-slug') ?? undefined;
        }
      }

      // Bila masih di paling atas halaman (sebelum garis baca), tandai bagian pertama
      if (!kandidat && daftarElemen[0]) {
        const rectPertama = daftarElemen[0].getBoundingClientRect();
        if (rectPertama.bottom > 0) {
          kandidat = daftarElemen[0].getAttribute('data-bagian-slug') ?? undefined;
        }
      }

      if (kandidat) {
        setBagianAktif(kandidat);
      }
    }

    window.addEventListener('scroll', periksaBagianAktif, { passive: true });
    periksaBagianAktif();

    return () => {
      window.removeEventListener('scroll', periksaBagianAktif);
    };
  }, [slug]);

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

  const warnaTopik = `var(--topik-${modul.topik})`;
  const video = urutkan(modul.video).filter((v) => v.youtube_id !== YOUTUBE_ID_VIDEO_CONTOH);

  return (
    <div className="container-base reader-page py-8">
      {/* Bilah progres baca di puncak viewport */}
      <div className="fixed top-0 left-0 right-0 z-50 h-1 bg-transparent" aria-hidden="true">
        <div
          className="h-full bg-primary transition-[width] duration-150 ease-out"
          style={{ width: `${persen}%` }}
        />
      </div>

      {/* Header modul */}
      <Link
        to="/materi"
        className="mb-6 inline-flex h-11 items-center gap-2 text-sm text-fg-muted no-underline hover:text-fg md:h-9"
      >
        <ArrowLeft className="size-4" aria-hidden="true" />
        Kembali ke daftar materi
      </Link>

      <div className="reader-heading">
        <Badge warna={warnaTopik}>{LABEL_TOPIK[modul.topik]}</Badge>
        <PageHeader
          judul={modul.judul}
          deskripsi={`${modul.estimasi_menit} menit baca · ${bagian.length} bagian${video.length > 0 ? ` · ${video.length} video` : ''}`}
        />
        <p className="reader-intro text-fg-muted">{modul.deskripsi}</p>
      </div>

      {/* Tombol daftar isi untuk MOBILE saja.
          Sidebar desktop dirender terpisah di dalam layout flex di bawah,
          supaya tidak ikut tersembunyi oleh lg:hidden. */}
      {bagian.length > 0 && (
        <div className="mb-6 lg:hidden">
          <TombolDaftarIsiMobile
            bagian={bagian}
            bagianDibaca={bagianDibaca}
            bagianAktif={bagianAktif}
            persen={persen}
          />
        </div>
      )}

      {/* Isi modul — dua kolom di desktop, satu kolom di mobile */}
      <div className="reader-layout lg:flex lg:gap-10">
        {bagian.length > 0 && (
          <div className="reader-sidebar hidden lg:block lg:w-60 lg:shrink-0">
            <SidebarDaftarIsi
              bagian={bagian}
              bagianDibaca={bagianDibaca}
              bagianAktif={bagianAktif}
              persen={persen}
            />
          </div>
        )}

        <div className="reader-body min-w-0 flex-1">
          {bagian.map((b) => (
            <article
              key={b.id}
              id={b.slug}
              data-bagian-slug={b.slug}
              className="reader-section scroll-mt-20 border-b border-border py-8 first:pt-0 last:border-0"
            >
              <h2 className="mb-4 font-heading text-2xl font-semibold text-fg">{b.judul}</h2>
              <MarkdownRenderer konten={b.konten_md} />
            </article>
          ))}

          {/* Video pendukung */}
          {video.length > 0 && (
            <section className="mt-10">
              <h2 className="mb-4 font-heading text-xl font-semibold text-fg">Video Pendukung</h2>
              <div className="space-y-4">
                {video.map((v) => (
                  <Card key={v.id} className="overflow-hidden border border-border">
                    <div className="flex flex-col sm:flex-row">
                      <button
                        type="button"
                        onClick={() =>
                          setVideoDiputar({
                            ...v,
                            modul: {
                              slug: modul.slug,
                              judul: modul.judul,
                              topik: modul.topik,
                              urutan: modul.urutan,
                            },
                          })
                        }
                        className="group relative block aspect-video w-full shrink-0 cursor-pointer overflow-hidden bg-surface-sunken sm:w-56"
                        aria-label={`Putar video: ${v.judul}`}
                      >
                        <img
                          src={`https://img.youtube.com/vi/${v.youtube_id}/hqdefault.jpg`}
                          alt=""
                          width={480}
                          height={270}
                          loading="lazy"
                          decoding="async"
                          className="size-full object-cover transition-transform duration-200 group-hover:scale-105"
                        />
                        <span
                          aria-hidden="true"
                          className="absolute inset-0 flex items-center justify-center bg-black/30 transition-opacity duration-150 group-hover:bg-black/40"
                        >
                          <PlayCircle
                            className="size-10 text-white drop-shadow"
                            strokeWidth={1.5}
                          />
                        </span>
                        {v.durasi_detik && (
                          <span className="absolute bottom-2 right-2 rounded bg-black/80 px-1.5 py-0.5 font-mono text-xs text-white">
                            {durasi(v.durasi_detik)}
                          </span>
                        )}
                      </button>

                      <div className="flex flex-1 flex-col justify-between p-4">
                        <div>
                          <h3 className="font-heading text-base font-semibold text-fg">
                            {v.judul}
                          </h3>
                          {v.deskripsi && (
                            <p className="mt-1.5 text-sm text-fg-muted">{v.deskripsi}</p>
                          )}
                        </div>

                        <div className="mt-4 flex flex-wrap items-center gap-3">
                          <button
                            type="button"
                            onClick={() =>
                              setVideoDiputar({
                                ...v,
                                modul: {
                                  slug: modul.slug,
                                  judul: modul.judul,
                                  topik: modul.topik,
                                  urutan: modul.urutan,
                                },
                              })
                            }
                            className="inline-flex cursor-pointer items-center gap-1.5 text-xs font-semibold text-link hover:underline"
                          >
                            <PlayCircle className="size-3.5" aria-hidden="true" />
                            Tonton Sekarang
                          </button>
                          <span className="text-fg-muted/40" aria-hidden="true">
                            •
                          </span>
                          <a
                            href={`https://www.youtube.com/watch?v=${v.youtube_id}`}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="inline-flex items-center gap-1 text-xs text-fg-muted hover:text-fg hover:underline"
                          >
                            Buka di YouTube
                            <ExternalLink className="size-3" aria-hidden="true" />
                          </a>
                        </div>
                      </div>
                    </div>
                  </Card>
                ))}
              </div>
            </section>
          )}

          {/* Tombol selesai + arah ke tahap berikutnya */}
          <div className="mt-10">
            <PanelLanjut
              modulSlug={modul.slug}
              modulId={modul.id}
              persen={persen}
              tahap1Selesai={tahap1Selesai}
              onTandaiSelesai={() => tandaiModulSelesai(modul.id)}
              onBatalkan={() => batalkanModulSelesai(modul.id)}
            />
          </div>
        </div>
      </div>

      {videoDiputar && <VideoPlayer video={videoDiputar} onTutup={() => setVideoDiputar(null)} />}
    </div>
  );
}

function ModulSkeleton() {
  return (
    <div className="container-base py-8" aria-busy="true" aria-live="polite">
      <span className="sr-only">Memuat modul…</span>
      <Skeleton className="h-4 w-40" />
      <Skeleton className="mt-6 h-5 w-16" />
      <Skeleton className="mt-3 h-9 w-3/4" />
      <Skeleton className="mt-3 h-4 w-1/2" />
      <div className="mt-8 lg:grid lg:grid-cols-[240px_1fr] lg:gap-10">
        <div className="hidden lg:block">
          <Skeleton className="h-4 w-24" />
          <div className="mt-3 space-y-2">
            {[0, 1, 2, 3, 4].map((i) => (
              <Skeleton key={i} className="h-6 w-full" />
            ))}
          </div>
        </div>
        <div className="space-y-4">
          {[0, 1, 2].map((i) => (
            <div key={i}>
              <Skeleton className="h-7 w-1/2" />
              <Skeleton className="mt-3 h-4 w-full" />
              <Skeleton className="mt-2 h-4 w-full" />
              <Skeleton className="mt-2 h-4 w-2/3" />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
