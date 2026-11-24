import { useMemo, useState } from 'react';
import { ChevronRight, LayoutDashboard } from 'lucide-react';
import { PageHeader, Card, Badge } from '@/components/ui/Card';
import { EmptyState, ErrorState, Skeleton } from '@/components/ui/States';
import { ProgressBar } from '@/components/ui/Progress';
import { LearningStages } from '@/components/ui/LearningStages';
import { useDaftarModul } from '@/features/materi/hooks';
import { useProgres } from '@/features/progres/context';
import { hitungStatistik } from '@/features/progres/util';
import { statusSemuaTahap, persenProgresModul } from '@/features/progres/aturan';
import {
  hitungRekomendasi,
  hitungProgresPerTopik,
  urutkanModulUntukDashboard,
  cariModulTerlemah,
} from '@/features/dashboard/rekomendasi';
import {
  BarisTopik,
  KartuRekomendasi,
  KartuSemuaSelesai,
  SaranMemperkuat,
  StatCard,
} from '@/features/dashboard/KartuDashboard';
import { Pengaturan } from '@/features/dashboard/Pengaturan';
import { LABEL_TOPIK } from '@/lib/constants';
import { cn } from '@/lib/cn';
import { Link } from 'react-router-dom';
import { useJudulHalaman } from '@/lib/useJudulHalaman';
import type { ModulRingkas, TopikModul } from '@/types/database';
import { useBahasa } from '@/app/BahasaProvider';

/**
 * Halaman Dashboard.
 *
 * Tujuan: menjawab "apa yang harus saya kerjakan sekarang?"
 *
 * BUKAN halaman statistik. Statistik hanya pendukung. Yang paling
 * menonjol adalah kartu rekomendasi dengan alasannya.
 *
 * Rincian: docs/06-SPESIFIKASI-HALAMAN.md §3
 */
export default function DashboardPage() {
  const { bahasa } = useBahasa();
  const en = bahasa === 'en';
  useJudulHalaman(en ? 'Dashboard' : 'Dashboard');
  const { data: daftarModul, isPending, isError, error, refetch } = useDaftarModul();
  const { progres, sedangMemuat: progresMemuat, ambilModul } = useProgres();
  const [filterTopik, setFilterTopik] = useState<TopikModul | 'semua'>('semua');

  const statistik = useMemo(() => hitungStatistik(progres), [progres]);

  const rekomendasi = useMemo(
    () => (daftarModul ? hitungRekomendasi(daftarModul, progres) : null),
    [daftarModul, progres],
  );

  const progresTopik = useMemo(
    () => (daftarModul ? hitungProgresPerTopik(daftarModul, progres) : []),
    [daftarModul, progres],
  );

  const modulTerlemah = useMemo(
    () => (daftarModul ? cariModulTerlemah(daftarModul, progres) : null),
    [daftarModul, progres],
  );

  const modulTerurut = useMemo(
    () => (daftarModul ? urutkanModulUntukDashboard(daftarModul, progres) : []),
    [daftarModul, progres],
  );

  const modulTampil = useMemo(
    () =>
      filterTopik === 'semua' ? modulTerurut : modulTerurut.filter((m) => m.topik === filterTopik),
    [modulTerurut, filterTopik],
  );

  const totalKartu = useMemo(
    () => daftarModul?.reduce((n, m) => n + (m.flashcard?.length ?? 0), 0) ?? 0,
    [daftarModul],
  );

  if (isPending || progresMemuat) return <DashboardSkeleton />;

  if (isError) {
    return (
      <div className="container-wide py-8">
        <PageHeader
          judul="Dashboard"
          deskripsi={en ? 'Your learning progress at a glance' : 'Ringkasan progres belajarmu'}
        />
        <ErrorState
          judul={en ? 'Could not load data' : 'Gagal memuat data'}
          pesan={
            en
              ? 'Could not connect to the server. Check your internet connection and try again.'
              : 'Tidak bisa terhubung ke server. Periksa koneksi internet, lalu coba lagi.'
          }
          onCobaLagi={() => void refetch()}
        />
        {import.meta.env.DEV && error && (
          <p className="mt-4 text-center text-xs text-fg-muted">Detail: {error.message}</p>
        )}
      </div>
    );
  }

  if (!daftarModul || daftarModul.length === 0) {
    return (
      <div className="container-wide py-8">
        <PageHeader
          judul="Dashboard"
          deskripsi={en ? 'Your learning progress at a glance' : 'Ringkasan progres belajarmu'}
        />
        <EmptyState
          ikon={<LayoutDashboard className="size-12" strokeWidth={1.5} />}
          judul={en ? 'No modules yet' : 'Belum ada modul'}
          pesan={
            en
              ? 'Content is being prepared. Please reload the page in a moment.'
              : 'Konten sedang disiapkan. Coba muat ulang halaman sebentar lagi.'
          }
        />
      </div>
    );
  }

  const jumlahModul = daftarModul.length;
  const persenKeseluruhan = Math.round(
    daftarModul.reduce((n, m) => n + persenProgresModul(ambilModul(m.id)), 0) / jumlahModul,
  );

  return (
    <div className="dashboard-page container-base">
      <PageHeader
        judul={en ? 'Continue learning' : 'Lanjutkan belajarmu'}
        deskripsi={
          en
            ? 'Build your understanding of data structures step by step.'
            : 'Bangun pemahaman Struktur Data secara bertahap dan konsisten.'
        }
      />

      {/* Rekomendasi — paling atas, paling menonjol */}
      {rekomendasi ? (
        <KartuRekomendasi
          rekomendasi={rekomendasi}
          progresModul={ambilModul(rekomendasi.modulId)}
        />
      ) : (
        <>
          <KartuSemuaSelesai modulTerlemah={modulTerlemah} />
          <SaranMemperkuat />
        </>
      )}

      <dl className="dashboard-summary">
        <div>
          <dt>{en ? 'Total modules' : 'Total modul'}</dt>
          <dd>
            {jumlahModul}
            <span>{en ? 'available' : 'modul tersedia'}</span>
          </dd>
        </div>
        <div>
          <dt>{en ? 'Modules completed' : 'Modul selesai'}</dt>
          <dd>
            {statistik.modulSelesai}
            <span>{en ? `of ${jumlahModul} modules` : `dari ${jumlahModul} modul`}</span>
          </dd>
        </div>
        <div>
          <dt>{en ? 'Learning progress' : 'Progres belajar'}</dt>
          <dd>
            {persenKeseluruhan}%<span>{en ? 'overall' : 'keseluruhan'}</span>
          </dd>
        </div>
      </dl>

      {/* Daftar modul */}
      <section className="dashboard-modules">
        <div className="module-list-heading">
          <h2 className="font-heading text-title font-bold text-fg">
            {en ? 'Modules' : 'Daftar Modul'}
          </h2>

          {/* Filter topik — tombol, bukan dropdown, karena hanya 4 pilihan */}
          <div
            className="flex flex-wrap gap-1.5"
            role="group"
            aria-label={en ? 'Filter topics' : 'Filter topik'}
          >
            <TombolFilter
              aktif={filterTopik === 'semua'}
              onClick={() => setFilterTopik('semua')}
              label={en ? 'All' : 'Semua'}
            />
            {(['array', 'struct', 'pointer'] as const).map((t) => (
              <TombolFilter
                key={t}
                aktif={filterTopik === t}
                onClick={() => setFilterTopik(t)}
                label={
                  en
                    ? { array: 'Array', struct: 'Structs', pointer: 'Pointers' }[t]
                    : LABEL_TOPIK[t]
                }
              />
            ))}
          </div>
        </div>

        <div className="module-rows">
          {modulTampil.map((m) => (
            <BarisModulDashboard key={m.id} modul={m} progresModul={ambilModul(m.id)} />
          ))}
        </div>
      </section>

      <div className="dashboard-details">
        {/* Statistik */}
        <section>
          <h2 className="mb-4 font-heading text-lg font-semibold text-fg">
            {en ? 'Statistics' : 'Statistik'}
          </h2>
          <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
            <StatCard
              nilai={statistik.modulSelesai}
              label={en ? 'modules completed' : 'modul selesai'}
              keterangan={en ? `of ${jumlahModul}` : `dari ${jumlahModul}`}
              ajakan={
                statistik.modulSelesai === 0
                  ? en
                    ? 'Start the first module'
                    : 'Mulai modul pertama'
                  : ''
              }
              warna="var(--primary)"
            />
            <StatCard
              nilai={statistik.kartuDikuasai}
              label={en ? 'cards mastered' : 'kartu dikuasai'}
              keterangan={en ? `of ${totalKartu}` : `dari ${totalKartu}`}
              ajakan={
                statistik.kartuDikuasai === 0 ? (en ? 'Review flashcards' : 'Hafalkan kartu') : ''
              }
              warna="var(--success)"
            />
            <StatCard
              nilai={`${statistik.akurasiQuiz}%`}
              label={en ? 'quiz accuracy' : 'akurasi quiz'}
              keterangan={
                statistik.akurasiQuiz === 0
                  ? en
                    ? 'no quizzes yet'
                    : 'belum ada quiz'
                  : en
                    ? 'average'
                    : 'rata-rata'
              }
              ajakan={statistik.akurasiQuiz === 0 ? (en ? 'Take a quiz' : 'Kerjakan quiz') : ''}
              warna="var(--topik-pointer)"
            />
            <StatCard
              nilai={statistik.streak}
              label={en ? 'day streak' : 'hari beruntun'}
              keterangan={
                statistik.streak === 0
                  ? en
                    ? 'start today'
                    : 'mulai hari ini'
                  : en
                    ? 'keep it up'
                    : 'terus jaga'
              }
              ajakan={statistik.streak === 0 ? (en ? 'Study today' : 'Belajar hari ini') : ''}
              warna="var(--topik-struct)"
            />
          </div>
        </section>

        {/* Progres per topik */}
        <section>
          <h2 className="mb-4 font-heading text-lg font-semibold text-fg">
            {en ? 'Progress by topic' : 'Progres per Topik'}
          </h2>
          <Card className="space-y-5 p-5">
            {progresTopik.map((t) => (
              <BarisTopik
                key={t.topik}
                label={LABEL_TOPIK[t.topik]}
                selesai={t.selesai}
                total={t.total}
                persen={t.persen}
                warna={`var(--topik-${t.topik})`}
              />
            ))}
          </Card>
        </section>
      </div>

      {/* Pengaturan */}
      <section>
        <Pengaturan />
      </section>
    </div>
  );
}

/* =========================================================
   Komponen
   ========================================================= */

function TombolFilter({
  aktif,
  onClick,
  label,
}: {
  aktif: boolean;
  onClick: () => void;
  label: string;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-pressed={aktif}
      className={cn(
        'topic-filter inline-flex h-11 cursor-pointer items-center rounded-md border px-3.5 text-sm',
        'transition-colors duration-150 md:h-9',
        aktif
          ? 'border-primary bg-primary font-semibold text-on-primary'
          : 'border-border bg-surface-raised text-fg hover:border-border-strong',
      )}
    >
      {label}
    </button>
  );
}

/** Baris modul di Dashboard — lebih ringkas dari kartu di halaman Materi */
function BarisModulDashboard({
  modul,
  progresModul,
}: {
  modul: ModulRingkas;
  progresModul: ReturnType<ReturnType<typeof useProgres>['ambilModul']>;
}) {
  const { bahasa } = useBahasa();
  const en = bahasa === 'en';
  const status = statusSemuaTahap(progresModul);
  const warnaTopik = `var(--topik-${modul.topik})`;

  // CTA sesuai tahap berikutnya
  const cta =
    status[0] !== 'selesai'
      ? { label: en ? 'Read module' : 'Baca Modul', ke: `/materi/${modul.slug}` }
      : status[1] === 'tersedia'
        ? { label: en ? 'Flashcards' : 'Flashcard', ke: `/soal/flashcard/${modul.slug}` }
        : status[2] === 'tersedia'
          ? { label: en ? 'Start quiz' : 'Mulai Quiz', ke: `/soal/quiz/${modul.slug}` }
          : { label: en ? 'Review' : 'Ulangi', ke: `/materi/${modul.slug}` };

  const persen = persenProgresModul(progresModul);
  return (
    <Link to={cta.ke} className="module-row" aria-label={`${modul.judul} — ${cta.label}`}>
      <span className="module-index" aria-hidden="true">
        {modul.urutan}
      </span>
      <div className="module-row-copy">
        <div className="flex flex-wrap items-center gap-x-3 gap-y-1">
          <h3>{modul.judul}</h3>
          <Badge warna={warnaTopik}>
            {en
              ? { array: 'Array', struct: 'Structs', pointer: 'Pointers' }[modul.topik]
              : LABEL_TOPIK[modul.topik]}
          </Badge>
        </div>
        <p>{modul.deskripsi}</p>
      </div>
      <div className="module-row-progress">
        <span>
          {persen === 0
            ? en
              ? 'Not started'
              : 'Belum dimulai'
            : persen === 100
              ? en
                ? 'Completed'
                : 'Selesai'
              : en
                ? 'In progress'
                : 'Sedang dipelajari'}
        </span>
        <div className="flex items-center gap-3">
          <ProgressBar
            nilai={persen}
            label={`${en ? 'Progress' : 'Progres'} ${modul.judul}`}
            tanpaLabelVisual
          />
          <span>{persen}%</span>
        </div>
      </div>
      <LearningStages tahap={status} ringkas />
      <ChevronRight size={19} aria-hidden="true" />
    </Link>
  );
}

function DashboardSkeleton() {
  return (
    <div className="container-wide space-y-8 py-8" aria-busy="true" aria-live="polite">
      <span className="sr-only">Memuat dashboard…</span>
      <div>
        <Skeleton className="h-9 w-40" />
        <Skeleton className="mt-3 h-4 w-64" />
      </div>
      <Skeleton className="h-40 rounded-lg" />
      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        {[0, 1, 2, 3].map((i) => (
          <Skeleton key={i} className="h-28 rounded-lg" />
        ))}
      </div>
      <Skeleton className="h-44 rounded-lg" />
      <div className="space-y-3">
        {[0, 1].map((i) => (
          <Skeleton key={i} className="h-28 rounded-lg" />
        ))}
      </div>
    </div>
  );
}
