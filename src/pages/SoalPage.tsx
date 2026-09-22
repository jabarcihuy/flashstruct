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
import type { ModulRingkas } from '@/types/database';

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

  return (
    <div className="container-base py-8">
      <PageHeader
        judul="Soal"
        deskripsi="Pilih modul, lalu pilih tahapnya. Hafalkan dulu, baru buktikan."
      />

      <div className="space-y-5">
        {urutkan(daftarModul).map((m) => (
          <KartuPilihanModul key={m.id} modul={m} progresModul={ambilModul(m.id)} />
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
    <Card className="p-5 sm:p-6">
      {/* Kepala: topik + judul */}
      <div className="flex items-start gap-3">
        <span
          className="mt-1 h-10 w-1 shrink-0 rounded-full"
          style={{ backgroundColor: warnaTopik }}
          aria-hidden="true"
        />
        <div className="min-w-0 flex-1">
          <Badge warna={warnaTopik}>{LABEL_TOPIK[modul.topik]}</Badge>
          <h2 className="mt-2 font-heading text-lg font-semibold text-fg">{modul.judul}</h2>
        </div>
      </div>

      {/* Dua pilihan tahap */}
      <div className="mt-5 grid gap-4 sm:grid-cols-2">
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
        'flex flex-col rounded-lg border p-4',
        terkunci ? 'border-border bg-surface-raised/50' : 'border-border-strong bg-surface-raised',
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

      {/* Tombol — tetap TERLIHAT saat terkunci, tapi tidak aktif */}
      <div className="mt-4">
        {terkunci ? (
          <span
            className={cn(
              'inline-flex h-11 w-full items-center justify-center gap-2 rounded-md',
              'cursor-not-allowed border border-border bg-surface text-sm text-fg-muted opacity-60 md:h-10',
            )}
            aria-disabled="true"
          >
            <Lock className="size-4" aria-hidden="true" />
            Terkunci
          </span>
        ) : (
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
        )}
      </div>
    </div>
  );
}

function SoalSkeleton() {
  return (
    <div className="container-base py-8" aria-busy="true" aria-live="polite">
      <span className="sr-only">Memuat daftar soal…</span>
      <Skeleton className="h-9 w-24" />
      <Skeleton className="mt-3 h-4 w-80" />
      <div className="mt-6 space-y-5">
        {[0, 1].map((i) => (
          <div key={i} className="rounded-lg border border-border p-6" style={{ minHeight: 200 }}>
            <Skeleton className="h-5 w-16" />
            <Skeleton className="mt-3 h-6 w-2/3" />
            <div className="mt-5 grid gap-4 sm:grid-cols-2">
              <Skeleton className="h-32 rounded-lg" />
              <Skeleton className="h-32 rounded-lg" />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
