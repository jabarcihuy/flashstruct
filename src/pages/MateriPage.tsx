import { useEffect, useState, useMemo } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useJudulHalaman } from '@/lib/useJudulHalaman';
import { ArrowRight, BookOpen, Check, Clock, HelpCircle, Layers, Lock } from 'lucide-react';
import { EmptyState, ErrorState, Skeleton } from '@/components/ui/States';
import { IndikatorTigaTahap, ProgressBar } from '@/components/ui/Progress';
import { useDaftarModul } from '@/features/materi/hooks';
import { useProgres } from '@/features/progres/context';
import {
  statusSemuaTahap,
  alasanTerkunci,
  modulTuntas,
  persenProgresModul,
} from '@/features/progres/aturan';
import { LABEL_TOPIK } from '@/lib/constants';
import { urutkan } from '@/lib/format';
import { cn } from '@/lib/cn';
import type { ModulRingkas, TopikModul } from '@/types/database';

type FilterTopik = 'semua' | TopikModul;

/**
 * Halaman daftar materi (Syllabus & Course Catalog).
 *
 * Menampilkan modul terkelompok per topik (Array, Struct, Pointer)
 * dengan kartu belajar mandiri yang lega, indikator tiga tahap,
 * filter topik, dan ringkasan progres keseluruhan.
 */
export default function MateriPage() {
  useJudulHalaman('Materi');
  const { hash } = useLocation();
  const [filterTopik, setFilterTopik] = useState<FilterTopik>('semua');
  const { data: daftarModul, isPending, isError, error, refetch } = useDaftarModul();
  const { sedangMemuat: progresMemuat, ambilModul } = useProgres();

  useEffect(() => {
    if (!hash || isPending || progresMemuat) return;
    document.getElementById(hash.slice(1))?.scrollIntoView({ behavior: 'smooth' });
  }, [hash, isPending, progresMemuat]);

  // Kelompokkan per topik
  const perTopik = useMemo(() => {
    const map = new Map<TopikModul, ModulRingkas[]>();
    for (const m of urutkan(daftarModul)) {
      const daftar = map.get(m.topik) ?? [];
      daftar.push(m);
      map.set(m.topik, daftar);
    }
    return map;
  }, [daftarModul]);

  // Hitung progres global
  const statistikGlobal = useMemo(() => {
    if (!daftarModul || daftarModul.length === 0) return { total: 0, selesai: 0, persen: 0 };
    const total = daftarModul.length;
    const selesai = daftarModul.filter((m) => modulTuntas(ambilModul(m.id))).length;
    const persen = Math.round(
      daftarModul.reduce((acc, m) => acc + persenProgresModul(ambilModul(m.id)), 0) / total,
    );
    return { total, selesai, persen };
  }, [daftarModul, ambilModul]);

  // Tunggu data siap
  if (isPending || progresMemuat) return <MateriSkeleton />;

  if (isError) {
    return (
      <div className="container-base py-8">
        <h1 className="font-heading text-3xl font-bold tracking-tight text-fg sm:text-4xl">
          Materi
        </h1>
        <p className="mt-2 text-base text-fg-muted">
          Pelajari konsepnya sebelum menghafal dan menguji pemahaman.
        </p>
        <div className="mt-8">
          <ErrorState
            judul="Gagal memuat materi"
            pesan="Tidak bisa terhubung ke server. Periksa koneksi internet, lalu coba lagi."
            onCobaLagi={() => void refetch()}
          />
          {import.meta.env.DEV && (
            <p className="mt-4 text-center text-xs text-fg-muted">Detail: {error.message}</p>
          )}
        </div>
      </div>
    );
  }

  if (!daftarModul || daftarModul.length === 0) {
    return (
      <div className="container-base py-8">
        <h1 className="font-heading text-3xl font-bold tracking-tight text-fg sm:text-4xl">
          Materi
        </h1>
        <p className="mt-2 text-base text-fg-muted">
          Pelajari konsepnya sebelum menghafal dan menguji pemahaman.
        </p>
        <div className="mt-8">
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
      </div>
    );
  }

  const topikDaftar =
    filterTopik === 'semua' ? (['array', 'struct', 'pointer'] as const) : [filterTopik];

  return (
    <div className="container-base py-8 sm:py-10 pb-16 sm:pb-10">
      {/* Header Halaman & Strip Progres */}
      <header className="mb-8 flex flex-col gap-5 sm:flex-row sm:items-end sm:justify-between border-b border-border pb-6">
        <div>
          <h1 className="font-heading text-3xl font-bold tracking-tight text-fg sm:text-4xl">
            Materi
          </h1>
          <p className="mt-2 text-base text-fg-muted max-w-2xl">
            Pelajari konsep Struktur Data secara bertahap dengan modul mendalam sebelum menghafal
            dan menguji diri.
          </p>
        </div>

        {/* Ringkasan Progres Belajar */}
        <div className="flex w-full sm:w-auto shrink-0 items-center justify-between sm:justify-start gap-4 rounded-lg border border-border bg-surface px-4 py-2.5">
          <div>
            <span className="block text-xs text-fg-muted">Progres Materi</span>
            <span className="text-sm font-semibold tabular-nums text-fg">
              {statistikGlobal.selesai} dari {statistikGlobal.total} tuntas
            </span>
          </div>
          <div className="flex items-center gap-2.5">
            <div className="w-20">
              <ProgressBar
                nilai={statistikGlobal.persen}
                label="Progres materi keseluruhan"
                tanpaLabelVisual
              />
            </div>
            <span className="text-xs font-semibold tabular-nums text-fg-muted">
              {statistikGlobal.persen}%
            </span>
          </div>
        </div>
      </header>

      {/* Filter Topik Navigasi */}
      <nav className="mb-8 flex flex-wrap gap-2.5" aria-label="Filter topik materi">
        <button
          type="button"
          onClick={() => setFilterTopik('semua')}
          className={cn(
            'inline-flex min-h-[44px] cursor-pointer items-center justify-center rounded-md px-4 py-2 text-sm font-medium transition-colors',
            filterTopik === 'semua'
              ? 'bg-primary font-semibold text-on-primary shadow-sm'
              : 'border border-border bg-surface text-fg hover:bg-surface-raised',
          )}
        >
          Semua ({daftarModul.length})
        </button>
        {(['array', 'struct', 'pointer'] as const).map((t) => {
          const modulDalamTopik = perTopik.get(t) ?? [];
          return (
            <button
              key={t}
              type="button"
              onClick={() => setFilterTopik(t)}
              className={cn(
                'inline-flex min-h-[44px] cursor-pointer items-center justify-center rounded-md px-4 py-2 text-sm font-medium transition-colors',
                filterTopik === t
                  ? 'bg-primary font-semibold text-on-primary shadow-sm'
                  : 'border border-border bg-surface text-fg hover:bg-surface-raised',
              )}
            >
              {LABEL_TOPIK[t]} ({modulDalamTopik.length})
            </button>
          );
        })}
      </nav>

      {/* Daftar Topik & Kartu Modul */}
      <div className="space-y-12">
        {topikDaftar.map((topik) => {
          const modulTopik = perTopik.get(topik) ?? [];
          if (modulTopik.length === 0) return null;

          const selesaiTopik = modulTopik.filter((m) => modulTuntas(ambilModul(m.id))).length;

          return (
            <section key={topik} id={topik} className="scroll-mt-24">
              {/* Header Topik */}
              <div className="mb-4 flex flex-wrap items-baseline justify-between gap-2 border-b border-border pb-3">
                <div className="flex items-center gap-3">
                  <h2 className="font-heading text-xl font-bold text-fg">{LABEL_TOPIK[topik]}</h2>
                  <span className="text-sm font-medium text-fg-muted">
                    {modulTopik.length} modul
                  </span>
                </div>
                <span className="text-xs text-fg-muted">
                  {selesaiTopik === modulTopik.length && modulTopik.length > 0 ? (
                    <span className="font-semibold text-success">Semua tuntas</span>
                  ) : selesaiTopik > 0 ? (
                    `${selesaiTopik} dari ${modulTopik.length} tuntas`
                  ) : (
                    'Belum dimulai'
                  )}
                </span>
              </div>

              {/* Grid Kartu Modul */}
              <div className="grid gap-4">
                {modulTopik.map((m) => (
                  <KartuModulMateri key={m.id} modul={m} progresModul={ambilModul(m.id)} />
                ))}
              </div>
            </section>
          );
        })}
      </div>
    </div>
  );
}

/** Kartu satu modul yang mandiri, proporsional, dan adaptif */
function KartuModulMateri({
  modul,
  progresModul,
}: {
  modul: ModulRingkas;
  progresModul: ReturnType<ReturnType<typeof useProgres>['ambilModul']>;
}) {
  const jumlahBagian = modul.bagian_modul?.length ?? 0;
  const jumlahKartu = modul.flashcard?.length ?? 0;
  const jumlahSoal = modul.soal?.length ?? 0;

  const status = statusSemuaTahap(progresModul);
  const tahap1Selesai = status[0] === 'selesai';
  const tahap2Terkunci = status[1] === 'terkunci';
  const tuntas = modulTuntas(progresModul);
  const sedangBerjalan =
    !tuntas &&
    (tahap1Selesai ||
      (progresModul?.bagianDibaca !== undefined && progresModul.bagianDibaca.length > 0));

  // Tentukan aksi CTA kontekstual
  const cta = !tahap1Selesai
    ? { label: 'Baca Modul', ke: `/materi/${modul.slug}`, varian: 'primary' as const }
    : tahap2Terkunci
      ? { label: 'Baca Modul', ke: `/materi/${modul.slug}`, varian: 'primary' as const }
      : status[1] === 'tersedia'
        ? {
            label: 'Mulai Flashcard',
            ke: `/soal/flashcard/${modul.slug}`,
            varian: 'primary' as const,
          }
        : status[2] === 'tersedia'
          ? { label: 'Mulai Quiz', ke: `/soal/quiz/${modul.slug}`, varian: 'primary' as const }
          : { label: 'Buka Materi', ke: `/materi/${modul.slug}`, varian: 'secondary' as const };

  return (
    <article className="group relative rounded-lg border border-border bg-surface p-5 sm:p-6 transition-all duration-200 hover:border-border-strong hover:bg-surface-raised/40">
      <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
        {/* Kolom Kiri: Nomor, Judul, Status, Deskripsi, Catatan Terkunci */}
        <div className="flex items-start gap-4 min-w-0 flex-1">
          {/* Badge nomor / status */}
          <div
            className={cn(
              'flex size-10 sm:size-11 shrink-0 items-center justify-center rounded-md font-semibold text-sm transition-colors',
              tuntas
                ? 'border border-success/30 bg-success/15 text-success'
                : sedangBerjalan
                  ? 'bg-primary font-bold text-on-primary shadow-sm'
                  : 'border border-border bg-surface-raised text-fg-muted',
            )}
            aria-hidden="true"
          >
            {tuntas ? <Check className="size-5" /> : modul.urutan}
          </div>

          <div className="min-w-0 flex-1">
            <div className="flex flex-wrap items-center gap-2">
              <h3 className="font-heading text-lg font-bold text-fg group-hover:text-primary transition-colors">
                <Link to={`/materi/${modul.slug}`} className="hover:underline">
                  {modul.judul}
                </Link>
              </h3>
              <span
                className={cn(
                  'rounded-full px-2.5 py-0.5 text-xs font-medium',
                  tuntas
                    ? 'bg-success/10 text-success'
                    : sedangBerjalan
                      ? 'bg-primary/10 text-primary'
                      : 'bg-surface-raised text-fg-muted',
                )}
              >
                {tuntas ? 'Tuntas' : sedangBerjalan ? 'Sedang Dipelajari' : 'Belum Dimulai'}
              </span>
            </div>

            <p className="mt-1.5 text-sm leading-relaxed text-fg-muted max-w-3xl">
              {modul.deskripsi}
            </p>

            {/* Keterangan mengapa terkunci jika ada */}
            {tahap2Terkunci && !tahap1Selesai && (
              <p className="mt-2 flex items-center gap-1.5 text-xs text-fg-muted">
                <Lock className="size-3.5 shrink-0 text-fg-muted" aria-hidden="true" />
                <span>{alasanTerkunci(2)}</span>
              </p>
            )}
          </div>
        </div>

        {/* Kolom Kanan: Tombol Aksi CTA */}
        <div className="shrink-0 self-start sm:self-auto w-full sm:w-auto lg:w-44">
          <Link
            to={cta.ke}
            className={cn(
              'inline-flex min-h-[44px] w-full items-center justify-center gap-2 rounded-md px-4 py-2.5 text-sm font-semibold transition-colors',
              cta.varian === 'primary'
                ? 'bg-primary text-on-primary hover:brightness-110'
                : 'border border-border-strong bg-surface text-fg hover:bg-surface-raised',
            )}
          >
            {cta.label}
            <ArrowRight className="size-4" aria-hidden="true" />
          </Link>
        </div>
      </div>

      {/* Bagian Bawah: Metadata & Status Tiga Tahap */}
      <div className="mt-4 flex flex-col gap-3 border-t border-border pt-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-fg-muted">
          <span className="inline-flex items-center gap-1.5">
            <BookOpen className="size-3.5" aria-hidden="true" />
            {jumlahBagian} bagian
          </span>
          <span>·</span>
          <span className="inline-flex items-center gap-1.5">
            <Layers className="size-3.5" aria-hidden="true" />
            {jumlahKartu} kartu
          </span>
          <span>·</span>
          <span className="inline-flex items-center gap-1.5">
            <HelpCircle className="size-3.5" aria-hidden="true" />
            {jumlahSoal} soal
          </span>
          <span>·</span>
          <span className="inline-flex items-center gap-1.5">
            <Clock className="size-3.5" aria-hidden="true" />
            {modul.estimasi_menit} mnt
          </span>
        </div>

        <div>
          <IndikatorTigaTahap tahap={status} />
        </div>
      </div>
    </article>
  );
}

/** Skeleton dengan ukuran yang konsisten (cegah CLS) */
function MateriSkeleton() {
  return (
    <div className="container-base py-8" aria-busy="true" aria-live="polite">
      <span className="sr-only">Memuat materi…</span>
      <div className="mb-8">
        <Skeleton className="h-10 w-44" />
        <Skeleton className="mt-3 h-5 w-80" />
      </div>
      {[0, 1].map((i) => (
        <div key={i} className="mb-10">
          <Skeleton className="mb-4 h-6 w-32" />
          <div className="grid gap-4">
            {[0, 1, 2].map((j) => (
              <div
                key={j}
                className="rounded-lg border border-border p-6"
                style={{ minHeight: 140 }}
              >
                <div className="flex items-start gap-4">
                  <Skeleton className="size-11 rounded-md" />
                  <div className="flex-1 space-y-2">
                    <Skeleton className="h-5 w-1/3" />
                    <Skeleton className="h-4 w-2/3" />
                  </div>
                  <Skeleton className="h-10 w-36 rounded-md" />
                </div>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
