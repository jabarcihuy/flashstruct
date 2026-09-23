import { Link } from 'react-router-dom';
import { useJudulHalaman } from '@/lib/useJudulHalaman';
import { ClipboardCheck, Layers, Lock } from 'lucide-react';
import { Card, Badge, PageHeader } from '@/components/ui/Card';
import { EmptyState, ErrorState, Skeleton } from '@/components/ui/States';
import { ProgressBar } from '@/components/ui/Progress';
import { useDaftarModul } from '@/features/materi/hooks';
import { useProgres } from '@/features/progres/context';
import { statusTahap, alasanTerkunci } from '@/features/progres/aturan';
import { hitungStatistikModul } from '@/features/progres/util';
import { LABEL_TOPIK } from '@/lib/constants';
import { urutkan } from '@/lib/format';
import { cn } from '@/lib/cn';
import type { ModulRingkas, TopikModul } from '@/types/database';

/**
 * Halaman pemilih mode: Flashcard atau Quiz.
 *
 * Menampilkan setiap modul dengan dua pilihan tahap. Kartu quiz
 * terkunci dengan ALASAN yang jelas jika tahap 2 belum selesai —
 * bukan sekadar "terkunci".
 */
export default function SoalPage() {
  useJudulHalaman('Soal');
  const { data: daftarModul, isPending, isError, error, refetch } = useDaftarModul();
  const { ambilModul, sedangMemuat: progresMemuat } = useProgres();

  if (isPending || progresMemuat) return <SoalSkeleton />;

  if (isError) {
    return (
      <div className="container-base py-8">
        <PageHeader judul="Soal" deskripsi="Hafalkan, lalu buktikan" />
        <ErrorState
          judul="Gagal memuat daftar modul"
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
      <div className="container-base py-8">
        <PageHeader judul="Soal" deskripsi="Hafalkan, lalu buktikan" />
        <EmptyState
          judul="Belum ada modul"
          pesan="Konten sedang disiapkan. Coba muat ulang halaman sebentar lagi."
        />
      </div>
    );
  }

  const perTopik = new Map<TopikModul, ModulRingkas[]>();
  for (const modul of urutkan(daftarModul)) {
    const daftar = perTopik.get(modul.topik) ?? [];
    daftar.push(modul);
    perTopik.set(modul.topik, daftar);
  }

  return (
    <div className="container-base practice-index-page py-8 pb-16 sm:pb-10">
      <PageHeader
        judul="Soal"
        deskripsi="Pilih modul, lalu pilih tahapnya. Hafalkan dulu, baru buktikan."
      />

      <div className="space-y-10">
        {[...perTopik.entries()].map(([topik, modulTopik]) => (
          <section key={topik}>
            <div className="mb-4 flex items-baseline gap-3">
              <h2 className="font-heading text-xl font-semibold text-fg">{LABEL_TOPIK[topik]}</h2>
              <span className="text-sm text-fg-muted">{modulTopik.length} modul</span>
            </div>
            <div className="practice-index-list">
              {modulTopik.map((m) => (
                <KartuPilihanModul key={m.id} modul={m} progresModul={ambilModul(m.id)} />
              ))}
            </div>
          </section>
        ))}
      </div>
    </div>
  );
}

/** Satu modul dengan dua pilihan: Hafalkan dan Buktikan */
function KartuPilihanModul({
  modul,
  progresModul,
}: {
  modul: ModulRingkas;
  progresModul: ReturnType<ReturnType<typeof useProgres>['ambilModul']>;
}) {
  const warnaTopik = `var(--topik-${modul.topik})`;
  const jumlahKartu = modul.flashcard?.length ?? 0;
  const jumlahSoal = modul.soal?.length ?? 0;

  const statusTahap2 = statusTahap(progresModul, 2);
  const statusTahap3 = statusTahap(progresModul, 3);
  const statistik = hitungStatistikModul(progresModul);

  return (
    <Card className="rounded-none border-b-0 p-5 first:rounded-t-md last:rounded-b-md last:border-b sm:p-6">
      {/* Kepala: topik + judul */}
      <div className="flex items-start gap-3">
        <span className="module-index shrink-0" aria-hidden="true">
          {modul.urutan}
        </span>
        <div className="min-w-0 flex-1">
          <Badge warna={warnaTopik}>{LABEL_TOPIK[modul.topik]}</Badge>
          <h2 className="mt-2 font-heading text-lg font-semibold text-fg">{modul.judul}</h2>
          <Link
            to={`/materi/${modul.slug}`}
            className="mt-1 inline-flex min-h-11 items-center text-sm font-medium text-link no-underline hover:underline md:min-h-9"
          >
            Baca modul
          </Link>
        </div>
      </div>

      {/* Dua pilihan tahap */}
      <div className="mt-4 grid border-t border-border sm:grid-cols-2 sm:gap-5 sm:pt-4 sm:[&>*+*]:border-l sm:[&>*+*]:pl-5 [&>*+*]:border-t sm:[&>*+*]:border-t-0">
        <PanelTahap
          ikon={<Layers className="size-5" aria-hidden="true" />}
          judul="Hafalkan"
          keterangan={`${jumlahKartu} kartu`}
          statistik={
            statistik.kartuTotal > 0
              ? `${statistik.kartuDikuasai} dari ${statistik.kartuTotal} dikuasai`
              : 'Belum dimulai'
          }
          status={statusTahap2}
          ke={`/soal/flashcard/${modul.slug}`}
          labelTombol="Mulai"
          warna={warnaTopik}
          alasanTerkunci={statusTahap2 === 'terkunci' ? alasanTerkunci(2) : undefined}
          progresPersen={
            statistik.kartuTotal > 0
              ? Math.round((statistik.kartuDikuasai / statistik.kartuTotal) * 100)
              : 0
          }
        />

        <PanelTahap
          ikon={<ClipboardCheck className="size-5" aria-hidden="true" />}
          judul="Buktikan"
          keterangan={`${jumlahSoal} soal`}
          statistik={
            statistik.jumlahPercobaan > 0
              ? `Akurasi ${statistik.akurasiQuiz}% · ${statistik.jumlahPercobaan}x`
              : 'Belum pernah dikerjakan'
          }
          status={statusTahap3}
          ke={`/soal/quiz/${modul.slug}`}
          labelTombol="Mulai"
          warna={warnaTopik}
          alasanTerkunci={statusTahap3 === 'terkunci' ? alasanTerkunci(3) : undefined}
        />
      </div>
    </Card>
  );
}

/** Panel satu tahap */
function PanelTahap({
  ikon,
  judul,
  keterangan,
  statistik,
  status,
  ke,
  labelTombol,
  warna,
  alasanTerkunci: alasan,
  progresPersen,
}: {
  ikon: React.ReactNode;
  judul: string;
  keterangan: string;
  statistik: string;
  status: 'terkunci' | 'tersedia' | 'selesai';
  ke: string;
  labelTombol: string;
  warna: string;
  alasanTerkunci?: string;
  progresPersen?: number;
}) {
  const terkunci = status === 'terkunci';

  return (
    <div
      className={cn(
        'flex flex-col py-4 sm:py-0',
        terkunci ? 'border-border' : 'border-border-strong',
      )}
    >
      <div className="flex items-start gap-3">
        <span
          className={cn('mt-0.5 shrink-0', terkunci ? 'text-fg-muted' : 'text-fg')}
          style={!terkunci ? { color: warna } : undefined}
          aria-hidden="true"
        >
          {ikon}
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2">
            <p className={cn('font-semibold', terkunci ? 'text-fg-muted' : 'text-fg')}>{judul}</p>
            {terkunci && <Lock className="size-3.5 text-fg-muted" aria-label="Terkunci" />}
            {status === 'selesai' && <Badge warna="var(--success)">Selesai</Badge>}
          </div>
          <p className="mt-0.5 text-sm text-fg-muted">{keterangan}</p>
          <p className="mt-1 text-xs text-fg-muted">{statistik}</p>
        </div>
      </div>

      {/* Bar progres kartu (hanya untuk flashcard) */}
      {progresPersen !== undefined && progresPersen > 0 && !terkunci && (
        <div className="mt-3">
          <ProgressBar
            nilai={progresPersen}
            label="Kartu dikuasai"
            tanpaLabelVisual
            warna={warna}
          />
        </div>
      )}

      {/* Alasan terkunci — menjelaskan APA yang harus dilakukan */}
      {terkunci && alasan && (
        <p className="mt-3 flex items-start gap-1.5 text-xs text-fg-muted">
          <Lock className="mt-0.5 size-3 shrink-0" aria-hidden="true" />
          {alasan}
        </p>
      )}

      {terkunci ? (
        <div className="mt-auto pt-4">
          <button
            type="button"
            disabled
            aria-disabled="true"
            title={alasan}
            className={cn(
              'inline-flex h-11 w-full cursor-not-allowed items-center justify-center gap-2 rounded-md',
              'border border-border bg-surface-raised text-sm font-medium text-fg-muted transition-colors md:h-10',
            )}
          >
            <Lock className="size-4 shrink-0 text-fg-muted" aria-hidden="true" />
            <span>Terkunci</span>
          </button>
        </div>
      ) : (
        <div className="mt-auto pt-4">
          <Link to={ke} className="inline-flex w-full no-underline">
            <span
              className={cn(
                'inline-flex h-11 w-full items-center justify-center rounded-md',
                'text-sm font-medium transition-opacity duration-150 hover:opacity-90 md:h-10',
              )}
              style={{ backgroundColor: warna, color: 'var(--on-primary)' }}
            >
              {labelTombol}
            </span>
          </Link>
        </div>
      )}
    </div>
  );
}

function SoalSkeleton() {
  return (
    <div className="container-base py-8" aria-busy="true" aria-live="polite">
      <span className="sr-only">Memuat daftar soal…</span>
      <Skeleton className="h-9 w-24" />
      <Skeleton className="mt-3 h-4 w-80" />
      <div className="mt-6">
        {[0, 1].map((i) => (
          <div
            key={i}
            className="border border-b-0 border-border p-6 last:border-b"
            style={{ minHeight: 200 }}
          >
            <Skeleton className="h-5 w-16" />
            <Skeleton className="mt-3 h-6 w-2/3" />
            <div className="mt-5 grid gap-4 sm:grid-cols-2">
              <Skeleton className="h-20 rounded-md" />
              <Skeleton className="h-20 rounded-md" />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
