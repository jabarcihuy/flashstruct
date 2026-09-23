import { useJudulHalaman } from '@/lib/useJudulHalaman';
import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ArrowLeft, Layers } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { StageGate } from '@/components/ui/StageGate';
import { EmptyState, ErrorState, Skeleton } from '@/components/ui/States';
import { Dialog } from '@/components/ui/Dialog';
import { ProgressBar } from '@/components/ui/Progress';
import { useSesiFlashcard } from '@/features/flashcard/useSesiFlashcard';
import { Flashcard, PetunjukKeyboard } from '@/features/flashcard/Flashcard';
import { PenilaianDiri } from '@/features/flashcard/PenilaianDiri';
import { RingkasanSesi } from '@/features/flashcard/RingkasanSesi';
import { PutaranUlang } from '@/features/flashcard/PutaranUlang';
import { useProgres } from '@/features/progres/context';
import { hitungStatistikModul } from '@/features/progres/util';
import { kartuLupa } from '@/features/flashcard/sesi';
import { alasanTerkunci, statusSemuaTahap, statusTahap } from '@/features/progres/aturan';

/**
 * Halaman sesi flashcard — Tahap 2 (Hafalkan).
 *
 * PENGUNCIAN PENTING:
 * Halaman ini memeriksa status tahap 1. Kalau modul belum ditandai
 * selesai, pengguna TIDAK bisa mengerjakan flashcard walaupun mengetik
 * URL langsung. Tanpa pemeriksaan ini, seluruh metode tiga tahap bisa
 * dilewati — dan itu merusak inti produk.
 */
export default function FlashcardPage() {
  useJudulHalaman('Flashcard');
  const { slug = '' } = useParams();
  const {
    state,
    kartu,
    ringkasan,
    isPending,
    isError,
    error,
    refetch,
    balik,
    nilai,
    mulaiUlangan,
    lewatiUlangan,
    modulId,
    jumlahKartuTotal,
  } = useSesiFlashcard(slug);

  const { ambilModul, sedangMemuat: progresMemuat } = useProgres();
  const [dialogKeluar, setDialogKeluar] = useState(false);

  const progresModul = modulId ? ambilModul(modulId) : undefined;
  const statistik = hitungStatistikModul(progresModul);

  const sudahDinilai = Object.keys(state.hasil).length;
  const totalSesi = state.kartu.length;
  const judulModul = kartu?.modul.judul ?? '';

  /* =========================================================
     Keluar
     ========================================================= */

  function cobaKeluar() {
    if (sudahDinilai === 0 || state.fase === 'selesai') {
      window.location.href = '/soal';
      return;
    }
    setDialogKeluar(true);
  }

  /* =========================================================
     State: memuat
     ========================================================= */

  if (isPending || progresMemuat) return <FlashcardSkeleton />;

  /* =========================================================
     State: error
     ========================================================= */

  if (isError) {
    return (
      <div className="container-narrow py-8">
        <ErrorState
          judul="Gagal memuat kartu"
          pesan="Tidak bisa terhubung ke server. Periksa koneksi internet, lalu coba lagi."
          onCobaLagi={() => void refetch()}
        />
        {import.meta.env.DEV && error && (
          <p className="mt-4 text-center text-xs text-fg-muted">Detail: {error.message}</p>
        )}
      </div>
    );
  }

  /* =========================================================
     State: modul tanpa kartu
     ========================================================= */

  if (jumlahKartuTotal === 0) {
    return (
      <div className="container-narrow py-8">
        <EmptyState
          ikon={<Layers className="size-12" strokeWidth={1.5} />}
          judul="Modul ini belum punya kartu"
          pesan="Kartu hafalan untuk modul ini sedang disiapkan. Untuk sekarang, kamu bisa membaca modulnya atau mencoba modul lain."
          aksi={
            <div className="flex flex-wrap justify-center gap-2">
              <Link to={`/materi/${slug}`} className="inline-flex no-underline">
                <Button>Baca Modul</Button>
              </Link>
              <Link to="/soal" className="inline-flex no-underline">
                <Button varian="secondary">Pilih Modul Lain</Button>
              </Link>
            </div>
          }
        />
      </div>
    );
  }

  /* =========================================================
     PENGUNCIAN: tahap 1 harus selesai dulu
     ========================================================= */

  const statusTahap2 = statusTahap(progresModul, 2);

  if (statusTahap2 === 'terkunci') {
    return (
      <StageGate
        judul="Flashcard masih terkunci"
        modulJudul={judulModul}
        alasan={alasanTerkunci(2)}
        penjelasan="Selesaikan dulu membaca minimal 80% bagian modul, lalu tandai selesai untuk membuka kartu hafalan."
        aksiLabel="Baca Modul"
        aksiKe={`/materi/${slug}`}
        tahap={statusSemuaTahap(progresModul)}
      />
    );
  }

  /* =========================================================
     State: sesi selesai
     ========================================================= */

  if (state.fase === 'selesai') {
    return (
      <div className="container-base py-8">
        <HeaderSesi judul={judulModul} slug={slug} onKeluar={cobaKeluar} />

        <div className="mt-8">
          <RingkasanSesi
            ringkasan={ringkasan}
            modulSlug={slug}
            kartuDikuasai={statistik.kartuDikuasai}
            kartuTotal={jumlahKartuTotal}
            onUlangi={() => window.location.reload()}
          />
        </div>
      </div>
    );
  }

  /* =========================================================
     State: putaran ulang
     ========================================================= */

  if (state.fase === 'putaran-ulang') {
    return (
      <div className="container-base py-8">
        <HeaderSesi judul={judulModul} slug={slug} onKeluar={cobaKeluar} />

        <div className="mt-12">
          <PutaranUlang
            jumlahLupa={kartuLupa(state).length}
            jumlahTotal={state.kartu.length}
            onMulai={mulaiUlangan}
            onLewati={lewatiUlangan}
          />
        </div>
      </div>
    );
  }

  /* =========================================================
     State: mengerjakan
     ========================================================= */

  return (
    <div className="container-base practice-session flex min-h-[calc(100dvh-3.5rem)] flex-col py-6">
      <HeaderSesi judul={judulModul} slug={slug} onKeluar={cobaKeluar} putaran={state.putaran} />

      <div className="mt-4">
        <ProgressBar
          nilai={sudahDinilai}
          maks={totalSesi}
          label={`Kartu ${Math.min(state.indeks + 1, totalSesi)} dari ${totalSesi}`}
        />
      </div>

      <div className="flex flex-1 flex-col items-center justify-center gap-6 py-8">
        {kartu && (
          <Flashcard
            kartu={kartu}
            terbuka={state.terbuka}
            keluar={state.keluar}
            arahKeluar={state.arahKeluar}
            nomor={state.indeks + 1}
            total={totalSesi}
            onBalik={balik}
          />
        )}

        {state.terbuka && <PenilaianDiri onNilai={nilai} nonaktif={state.keluar} />}

        <PetunjukKeyboard terbuka={state.terbuka} />
      </div>

      <Dialog
        terbuka={dialogKeluar}
        onTutup={() => setDialogKeluar(false)}
        judul="Keluar dari sesi?"
        deskripsi={`Kamu sudah menyelesaikan ${sudahDinilai} dari ${totalSesi} kartu. Progres sesi ini akan hilang.`}
        ukuran="sm"
      >
        <div className="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
          <Button varian="secondary" onClick={() => setDialogKeluar(false)}>
            Lanjut Belajar
          </Button>
          <Button
            varian="danger"
            onClick={() => {
              window.location.href = '/soal';
            }}
          >
            Keluar
          </Button>
        </div>
      </Dialog>
    </div>
  );
}

/* =========================================================
   Header sesi
   ========================================================= */

function HeaderSesi({
  judul,
  slug,
  onKeluar,
  putaran,
}: {
  judul: string;
  slug: string;
  onKeluar: () => void;
  putaran?: number;
}) {
  return (
    <div className="flex items-center justify-between gap-4">
      <Link
        to={`/materi/${slug}`}
        className="inline-flex h-11 items-center gap-2 text-sm text-fg-muted no-underline hover:text-fg md:h-9"
      >
        <ArrowLeft className="size-4" aria-hidden="true" />
        <span className="hidden sm:inline">Kembali</span>
      </Link>

      <div className="min-w-0 flex-1 text-center">
        <p className="truncate text-sm font-medium text-fg">{judul}</p>
        <p className="text-xs text-fg-muted">
          Flashcard{putaran && putaran > 0 ? ' · Putaran ulang' : ''}
        </p>
      </div>

      <button
        type="button"
        onClick={onKeluar}
        className="inline-flex h-11 cursor-pointer items-center px-3 text-sm text-fg-muted hover:text-fg"
      >
        Keluar
      </button>
    </div>
  );
}

/* =========================================================
   Skeleton
   ========================================================= */

function FlashcardSkeleton() {
  return (
    <div className="container-base py-6" aria-busy="true" aria-live="polite">
      <span className="sr-only">Memuat kartu…</span>
      <div className="flex items-center justify-between">
        <Skeleton className="h-9 w-24" />
        <Skeleton className="h-5 w-40" />
        <Skeleton className="h-9 w-16" />
      </div>
      <Skeleton className="mt-4 h-2 w-full" />
      <div className="mt-8 flex justify-center">
        <Skeleton className="h-[min(420px,65dvh)] min-h-[320px] w-full max-w-[560px] rounded-md" />
      </div>
    </div>
  );
}
