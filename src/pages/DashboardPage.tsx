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
  useJudulHalaman('Dashboard');
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
        <PageHeader judul="Dashboard" deskripsi="Ringkasan progres belajarmu" />
        <ErrorState
          judul="Gagal memuat data"
          pesan="Tidak bisa terhubung ke server. Periksa koneksi internet, lalu coba lagi."
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
        <PageHeader judul="Dashboard" deskripsi="Ringkasan progres belajarmu" />
        <EmptyState
          ikon={<LayoutDashboard className="size-12" strokeWidth={1.5} />}
          judul="Belum ada modul"
          pesan="Konten sedang disiapkan. Coba muat ulang halaman sebentar lagi."
        />
      </div>
    );
  }

  const jumlahModul = daftarModul.length;
  const persenKeseluruhan = Math.round(
    daftarModul.reduce((n, m) => n + persenProgresModul(ambilModul(m.id)), 0) / jumlahModul,
  );

  return (
    <div className="dashboard-page container-wide">
      <PageHeader
        judul="Lanjutkan belajarmu"
        deskripsi="Bangun pemahaman Struktur Data secara bertahap dan konsisten."
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
          <dt>Total modul</dt>
          <dd>
            {jumlahModul}
            <span>modul tersedia</span>
          </dd>
        </div>
        <div>
          <dt>Modul selesai</dt>
          <dd>
            {statistik.modulSelesai}
            <span>dari {jumlahModul} modul</span>
          </dd>
        </div>
        <div>
          <dt>Progres belajar</dt>
          <dd>
            {persenKeseluruhan}%<span>keseluruhan</span>
          </dd>
        </div>
      </dl>

      {/* Daftar modul */}
      <section className="dashboard-modules">
        <div className="module-list-heading">
          {/* Ukuran dari comp: cap height 16,7px -> font 23px (spec.json region list-title) */}
          <h2 className="font-heading text-[23px] font-bold text-fg">Daftar Modul</h2>

          {/* Filter topik — tombol, bukan dropdown, karena hanya 4 pilihan */}
          <div className="flex flex-wrap gap-1.5" role="group" aria-label="Filter topik">
            <TombolFilter
              aktif={filterTopik === 'semua'}
              onClick={() => setFilterTopik('semua')}
              label="Semua"
            />
            {(['array', 'struct', 'pointer'] as const).map((t) => (
              <TombolFilter
                key={t}
                aktif={filterTopik === t}
                onClick={() => setFilterTopik(t)}
                label={LABEL_TOPIK[t]}
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
          <h2 className="mb-4 font-heading text-lg font-semibold text-fg">Statistik</h2>
          <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
            <StatCard
              nilai={statistik.modulSelesai}
              label="modul selesai"
              keterangan={`dari ${jumlahModul}`}
              ajakan={statistik.modulSelesai === 0 ? 'Mulai modul pertama' : ''}
              warna="var(--primary)"
            />
            <StatCard
              nilai={statistik.kartuDikuasai}
              label="kartu dikuasai"
              keterangan={`dari ${totalKartu}`}
              ajakan={statistik.kartuDikuasai === 0 ? 'Hafalkan kartu' : ''}
              warna="var(--success)"
            />
            <StatCard
              nilai={`${statistik.akurasiQuiz}%`}
              label="akurasi quiz"
              keterangan={statistik.akurasiQuiz === 0 ? 'belum ada quiz' : 'rata-rata'}
              ajakan={statistik.akurasiQuiz === 0 ? 'Kerjakan quiz' : ''}
              warna="var(--topik-pointer)"
            />
            <StatCard
              nilai={statistik.streak}
              label="hari beruntun"
              keterangan={statistik.streak === 0 ? 'mulai hari ini' : 'terus jaga'}
              ajakan={statistik.streak === 0 ? 'Belajar hari ini' : ''}
              warna="var(--topik-struct)"
            />
          </div>
        </section>

        {/* Progres per topik */}
        <section>
          <h2 className="mb-4 font-heading text-lg font-semibold text-fg">Progres per Topik</h2>
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
  const status = statusSemuaTahap(progresModul);
  const warnaTopik = `var(--topik-${modul.topik})`;

  // CTA sesuai tahap berikutnya
  const cta =
    status[0] !== 'selesai'
      ? { label: 'Baca Modul', ke: `/materi/${modul.slug}` }
      : status[1] === 'tersedia'
        ? { label: 'Flashcard', ke: `/soal/flashcard/${modul.slug}` }
        : status[2] === 'tersedia'
          ? { label: 'Quiz', ke: `/soal/quiz/${modul.slug}` }
          : { label: 'Ulangi', ke: `/materi/${modul.slug}` };

  const persen = persenProgresModul(progresModul);
  return (
    <Link to={cta.ke} className="module-row" aria-label={`${modul.judul} — ${cta.label}`}>
      <span className="module-index" aria-hidden="true">
        {modul.urutan}
      </span>
      <div className="module-row-copy">
        <div className="flex flex-wrap items-center gap-x-3 gap-y-1">
          <h3>{modul.judul}</h3>
          <Badge warna={warnaTopik}>{LABEL_TOPIK[modul.topik]}</Badge>
        </div>
        <p>{modul.deskripsi}</p>
      </div>
      <div className="module-row-progress">
        <span>
          {persen === 0 ? 'Belum dimulai' : persen === 100 ? 'Selesai' : 'Sedang dipelajari'}
        </span>
        <div className="flex items-center gap-3">
          <ProgressBar nilai={persen} label={`Progres ${modul.judul}`} tanpaLabelVisual />
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
