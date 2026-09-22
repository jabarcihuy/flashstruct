import { useParams, Link } from 'react-router-dom';
import { Lock } from 'lucide-react';
import { Card, PageHeader } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Skeleton } from '@/components/ui/States';
import { useDaftarModul } from '@/features/materi/hooks';
import { useProgres } from '@/features/progres/context';
import { statusTahap, alasanTerkunci } from '@/features/progres/aturan';

/**
 * Halaman Quiz — Tahap 3 (Buktikan).
 *
 * Pada M5, halaman ini hanya menampilkan PENGUNCIAN. Sesi quiz
 * sebenarnya dikerjakan di M6.
 *
 * PENGUNCIAN PENTING:
 * Halaman ini memeriksa status tahap 2. Kalau kartu belum dikuasai
 * semua, pengguna TIDAK bisa mengerjakan quiz walaupun mengetik URL
 * langsung.
 */
export default function QuizPage() {
  const { slug = '' } = useParams();
  const { data: daftarModul, isPending } = useDaftarModul();
  const { ambilModul, sedangMemuat: progresMemuat } = useProgres();

  if (isPending || progresMemuat) return <QuizSkeleton />;

  const modul = daftarModul?.find((m) => m.slug === slug);
  const progresModul = modul ? ambilModul(modul.id) : undefined;
  const status = statusTahap(progresModul, 3);
  const terkunci = status === 'terkunci';

  if (terkunci) {
    return (
      <div className="container-narrow py-12">
        <Card className="border-dashed p-6 text-center sm:p-8">
          <div className="mx-auto mb-4 flex size-12 items-center justify-center rounded-full bg-surface-raised">
            <Lock className="size-6 text-fg-muted" aria-hidden="true" />
          </div>

          <h1 className="font-heading text-xl font-semibold text-fg">Quiz masih terkunci</h1>

          <p className="mx-auto mt-3 max-w-md text-sm text-fg-muted">
            {modul ? (
              <>
                <strong className="text-fg">{modul.judul}</strong> — {alasanTerkunci(3)}
              </>
            ) : (
              'Modul tidak ditemukan.'
            )}
          </p>

          <p className="mx-auto mt-2 max-w-md text-xs text-fg-muted">
            Kamu membuka halaman ini lewat tautan langsung. Untuk membukanya, kuasai dulu semua
            kartu di tahap menghafal.
          </p>

          <div className="mt-6 flex flex-wrap justify-center gap-2">
            <Link to={`/soal/flashcard/${slug}`} className="no-underline">
              <Button>Mulai Flashcard</Button>
            </Link>
            <Link to="/soal" className="no-underline">
              <Button varian="secondary">Kembali ke Soal</Button>
            </Link>
          </div>
        </Card>
      </div>
    );
  }

  // Sesi quiz sebenarnya dikerjakan di M6
  return (
    <div className="container-narrow py-8">
      <PageHeader
        judul="Quiz"
        deskripsi={modul ? `${modul.judul} · ${modul.soal?.length ?? 0} soal` : undefined}
      />
      <Card className="border-dashed p-6">
        <p className="text-sm text-fg-muted">
          <strong className="text-fg">Sesi quiz belum tersedia.</strong> Tahap 3 kamu sudah
          terbuka, tetapi pengerjaan soal dikerjakan pada milestone berikutnya (M6).
        </p>
      </Card>
    </div>
  );
}

function QuizSkeleton() {
  return (
    <div className="container-narrow py-8" aria-busy="true" aria-live="polite">
      <span className="sr-only">Memuat quiz…</span>
      <Skeleton className="h-9 w-24" />
      <Skeleton className="mt-3 h-4 w-64" />
      <Skeleton className="mt-6 h-32 rounded-lg" />
    </div>
  );
}
