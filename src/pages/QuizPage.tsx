import { useJudulHalaman } from '@/lib/useJudulHalaman';
import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ArrowLeft, ClipboardCheck } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { StageGate } from '@/components/ui/StageGate';
import { EmptyState, ErrorState, Skeleton } from '@/components/ui/States';
import { Dialog } from '@/components/ui/Dialog';
import { ProgressBar } from '@/components/ui/Progress';
import { useSesiQuiz } from '@/features/quiz/useSesiQuiz';
import { SoalPilihanGanda } from '@/features/quiz/SoalPilihanGanda';
import { UmpanBalik } from '@/features/quiz/UmpanBalik';
import { HasilQuiz } from '@/features/quiz/HasilQuiz';
import { useDaftarModul } from '@/features/materi/hooks';
import { useProgres } from '@/features/progres/context';
import { alasanTerkunci, statusSemuaTahap, statusTahap } from '@/features/progres/aturan';
import { useBahasa } from '@/app/BahasaProvider';

/**
 * Halaman sesi quiz — Tahap 3 (Buktikan).
 *
 * PENGUNCIAN PENTING:
 * Halaman ini memeriksa status tahap 2. Kalau kartu belum dikuasai
 * semua, pengguna TIDAK bisa mengerjakan quiz walaupun mengetik URL
 * langsung.
 *
 * Catatan: Tahap 3 dianggap SELESAI apapun nilainya. Yang dikunci
 * hanya pembukaan tahap ini, bukan kelulusannya.
 */
export default function QuizPage() {
  const { bahasa } = useBahasa();
  const en = bahasa === 'en';
  useJudulHalaman('Quiz');
  const { slug = '' } = useParams();
  const {
    state,
    soal,
    hasil,
    akurasiTopik,
    isPending,
    isError,
    error,
    refetch,
    jawab,
    lanjut,
    soalTerakhir,
    modulId,
    jumlahSoalBank,
  } = useSesiQuiz(slug);

  const { data: daftarModul, isPending: modulMemuat } = useDaftarModul();
  const { ambilModul, sedangMemuat: progresMemuat } = useProgres();
  const [dialogKeluar, setDialogKeluar] = useState(false);

  const modul = daftarModul?.find((m) => m.slug === slug);
  const progresModul = modulId ? ambilModul(modulId) : modul ? ambilModul(modul.id) : undefined;

  const sudahDijawab = Object.keys(state.jawaban).length;
  const totalSoal = state.soal.length;

  // Scroll kembali ke atas saat soal berganti atau quiz selesai
  useEffect(() => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }, [state.indeks, state.fase]);

  /* =========================================================
     Keluar
     ========================================================= */

  function cobaKeluar() {
    if (sudahDijawab === 0 || state.fase === 'selesai') {
      window.location.href = '/soal';
      return;
    }
    setDialogKeluar(true);
  }

  /* =========================================================
     State: memuat
     ========================================================= */

  if (isPending || progresMemuat || modulMemuat) return <QuizSkeleton />;

  /* =========================================================
     State: error
     ========================================================= */

  if (isError) {
    return (
      <div className="container-narrow py-8">
        <ErrorState
          judul={en ? 'Could not load quiz' : 'Gagal memuat soal'}
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

  /* =========================================================
     PENGUNCIAN: tahap 2 harus selesai dulu
     ========================================================= */

  const statusTahap3 = statusTahap(progresModul, 3);

  if (statusTahap3 === 'terkunci') {
    return (
      <StageGate
        judul={en ? 'Quiz is locked' : 'Quiz masih terkunci'}
        modulJudul={modul?.judul}
        alasan={
          modul
            ? en
              ? 'Complete the previous learning stage to unlock this quiz.'
              : alasanTerkunci(3)
            : en
              ? 'Module not found.'
              : 'Modul tidak ditemukan.'
        }
        penjelasan={
          en
            ? 'Master all flashcards before taking the quiz. You can review cards you forgot until you are ready.'
            : 'Kuasai semua kartu di tahap menghafal sebelum mengerjakan quiz. Kartu yang lupa dapat diulang sampai siap.'
        }
        aksiLabel={
          statusTahap(progresModul, 2) === 'terkunci'
            ? en
              ? 'Read module'
              : 'Baca Modul'
            : en
              ? 'Start flashcards'
              : 'Mulai Flashcard'
        }
        aksiKe={
          statusTahap(progresModul, 2) === 'terkunci'
            ? `/materi/${slug}`
            : `/soal/flashcard/${slug}`
        }
        tahap={statusSemuaTahap(progresModul)}
      />
    );
  }

  /* =========================================================
     State: bank soal kosong
     ========================================================= */

  if (jumlahSoalBank === 0) {
    return (
      <div className="container-narrow py-8">
        <EmptyState
          ikon={<ClipboardCheck className="size-12" strokeWidth={1.5} />}
          judul={en ? 'This module has no quiz questions yet' : 'Modul ini belum punya soal'}
          pesan={
            en
              ? 'Quiz questions for this module are being prepared. For now, you can reread the module.'
              : 'Bank soal untuk modul ini sedang disiapkan. Untuk sekarang, kamu bisa membaca ulang modulnya.'
          }
          aksi={
            <div className="flex flex-wrap justify-center gap-2">
              <Link to={`/materi/${slug}`} className="inline-flex no-underline">
                <Button>{en ? 'Read module' : 'Baca Modul'}</Button>
              </Link>
              <Link to="/soal" className="inline-flex no-underline">
                <Button varian="secondary">
                  {en ? 'Choose another module' : 'Pilih Modul Lain'}
                </Button>
              </Link>
            </div>
          }
        />
      </div>
    );
  }

  /* =========================================================
     State: selesai
     ========================================================= */

  if (state.fase === 'selesai') {
    return (
      <div className="container-base py-8">
        <HasilQuiz
          hasil={hasil}
          akurasiTopik={akurasiTopik}
          modulSlug={slug}
          modulJudul={modul?.judul ?? ''}
          onUlangi={() => window.location.reload()}
        />
      </div>
    );
  }

  /* =========================================================
     State: mengerjakan
     ========================================================= */

  const jawabanDipilih = soal ? state.jawaban[soal.id] : undefined;

  return (
    <div className="container-narrow practice-session py-6">
      {/* Header */}
      <div className="flex items-center justify-between gap-4">
        <Link
          to={`/materi/${slug}`}
          className="inline-flex h-11 items-center gap-2 text-sm text-fg-muted no-underline hover:text-fg md:h-9"
        >
          <ArrowLeft className="size-4" aria-hidden="true" />
          <span className="hidden sm:inline">{en ? 'Back' : 'Kembali'}</span>
        </Link>

        <div className="min-w-0 flex-1 text-center">
          <p className="truncate text-sm font-medium text-fg">{modul?.judul ?? ''}</p>
          <p className="text-xs text-fg-muted">
            {en
              ? `Question ${state.indeks + 1} of ${totalSoal}`
              : `Soal ${state.indeks + 1} dari ${totalSoal}`}
          </p>
        </div>

        <button
          type="button"
          onClick={cobaKeluar}
          className="inline-flex h-11 cursor-pointer items-center px-3 text-sm text-fg-muted hover:text-fg"
        >
          {en ? 'Exit' : 'Keluar'}
        </button>
      </div>

      {/* Progres */}
      <div className="mt-4">
        <ProgressBar
          nilai={sudahDijawab}
          maks={totalSoal}
          label={
            en
              ? `Question ${state.indeks + 1} of ${totalSoal}`
              : `Soal ${state.indeks + 1} dari ${totalSoal}`
          }
          tanpaLabelVisual
        />
      </div>

      {/* Soal */}
      <div className="mt-6">
        {soal && (
          <SoalPilihanGanda
            soal={soal}
            dipilih={jawabanDipilih}
            sudahDijawab={state.sudahDijawab}
            onPilih={jawab}
          />
        )}
      </div>

      {/* Umpan balik — muncul segera setelah menjawab */}
      {state.sudahDijawab && soal && jawabanDipilih && (
        <div className="mt-5">
          <UmpanBalik
            soal={soal}
            dipilih={jawabanDipilih}
            onLanjut={lanjut}
            soalTerakhir={soalTerakhir}
          />
        </div>
      )}

      {/* Petunjuk keyboard — desktop saja */}
      {!state.sudahDijawab && (
        <p className="mt-5 hidden text-center text-xs text-fg-muted md:block">
          Tekan{' '}
          <kbd className="rounded border border-border bg-surface-raised px-1.5 py-0.5 font-mono">
            1
          </kbd>
          {' – '}
          <kbd className="rounded border border-border bg-surface-raised px-1.5 py-0.5 font-mono">
            4
          </kbd>{' '}
          {en ? 'to choose an answer' : 'untuk memilih jawaban'}
        </p>
      )}

      {/* Dialog konfirmasi keluar */}
      <Dialog
        terbuka={dialogKeluar}
        onTutup={() => setDialogKeluar(false)}
        judul={en ? 'Leave the quiz?' : 'Keluar dari quiz?'}
        deskripsi={
          en
            ? `You have answered ${sudahDijawab} of ${totalSoal} questions. Your answers will be lost.`
            : `Kamu sudah menjawab ${sudahDijawab} dari ${totalSoal} soal. Jawaban akan hilang.`
        }
        ukuran="sm"
      >
        <div className="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
          <Button varian="secondary" onClick={() => setDialogKeluar(false)}>
            {en ? 'Keep working' : 'Lanjut Mengerjakan'}
          </Button>
          <Button
            varian="danger"
            onClick={() => {
              window.location.href = '/soal';
            }}
          >
            {en ? 'Leave' : 'Keluar'}
          </Button>
        </div>
      </Dialog>
    </div>
  );
}

function QuizSkeleton() {
  const { bahasa } = useBahasa();
  return (
    <div className="container-narrow py-6" aria-busy="true" aria-live="polite">
      <span className="sr-only">{bahasa === 'en' ? 'Loading quiz…' : 'Memuat quiz…'}</span>
      <div className="flex items-center justify-between">
        <Skeleton className="h-9 w-24" />
        <Skeleton className="h-5 w-32" />
        <Skeleton className="h-9 w-16" />
      </div>
      <Skeleton className="mt-4 h-2 w-full" />
      <Skeleton className="mt-6 h-6 w-24" />
      <Skeleton className="mt-3 h-16 w-full" />
      <div className="mt-5 space-y-2.5">
        {[0, 1, 2, 3].map((i) => (
          <Skeleton key={i} className="h-16 rounded-lg" />
        ))}
      </div>
    </div>
  );
}
