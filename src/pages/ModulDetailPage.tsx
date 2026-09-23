import { useEffect, useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import { PageHeader, Badge, Card } from '@/components/ui/Card';
import { EmptyState, ErrorState, Skeleton } from '@/components/ui/States';
import { MarkdownRenderer } from '@/components/markdown/MarkdownRenderer';
import { useModulLengkap } from '@/features/materi/hooks';
import { useProgres } from '@/features/progres/context';
import { useProgresBaca } from '@/features/materi/useProgresBaca';
import { SidebarDaftarIsi, TombolDaftarIsiMobile } from '@/features/materi/DaftarIsi';
import { PanelLanjut } from '@/features/materi/PanelLanjut';
import { LABEL_TOPIK, YOUTUBE_ID_VIDEO_CONTOH } from '@/lib/constants';
import { urutkan } from '@/lib/format';

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

  useEffect(() => {
    if (typeof IntersectionObserver === 'undefined') return;

    const pengamat = new IntersectionObserver(
      (entri) => {
        // Ambil bagian yang paling terlihat
        const terlihat = entri
          .filter((e) => e.isIntersecting)
          .sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];

        const slugBagian = terlihat?.target.getAttribute('data-bagian-slug');
        if (slugBagian) setBagianAktif(slugBagian);
      },
      { threshold: [0.1, 0.5, 0.9] },
    );

    document.querySelectorAll('[data-bagian-slug]').forEach((el) => pengamat.observe(el));
    return () => pengamat.disconnect();
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
              <div className="space-y-3">
                {video.map((v) => (
                  <Card key={v.id} className="p-4">
                    <h3 className="font-medium text-fg">{v.judul}</h3>
                    {v.deskripsi && <p className="mt-1 text-sm text-fg-muted">{v.deskripsi}</p>}
                    <a
                      href={`https://www.youtube.com/watch?v=${v.youtube_id}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="mt-2 inline-block font-mono text-xs text-link underline"
                    >
                      youtube.com/watch?v={v.youtube_id}
                    </a>
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
