import { Link } from 'react-router-dom';
import { ArrowRight, Check, RotateCcw, X } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { LABEL_TIPE_KARTU, AMBANG_LULUS_QUIZ } from '@/lib/constants';
import { cn } from '@/lib/cn';
import type { AkurasiTopik, HasilSesiQuiz } from './sesi';

/**
 * Halaman hasil quiz.
 *
 * Aturan nada pesan (docs/06-SPESIFIKASI-HALAMAN.md §6.8):
 *   Saat gagal, pesannya TIDAK menghakimi. Pengguna yang gagal sudah
 *   tahu ia gagal — pesan yang menyalahkan akan membuatnya berhenti.
 *
 * Aturan penting lain: Tahap 3 dianggap SELESAI apapun nilainya.
 * Memaksa nilai tinggi akan membuat pengguna terjebak mengulang.
 */

interface HasilQuizProps {
  hasil: HasilSesiQuiz;
  akurasiTopik: AkurasiTopik[];
  modulSlug: string;
  modulJudul: string;
  onUlangi: () => void;
}

export function HasilQuiz({
  hasil,
  akurasiTopik,
  modulSlug,
  modulJudul,
  onUlangi,
}: HasilQuizProps) {
  const topikLemah = akurasiTopik.filter((a) => a.kategori === 'lemah');

  return (
    <div className="mx-auto w-full max-w-2xl space-y-6">
      {/* Skor besar */}
      <Card className="p-6 text-center sm:p-8">
        <p className="text-sm text-fg-muted">{modulJudul}</p>

        <div className="mt-4">
          <span
            className={cn(
              'font-heading text-6xl font-bold tabular-nums',
              hasil.lulus ? 'text-success' : 'text-fg',
            )}
          >
            {hasil.skor}
          </span>
          <p className="mt-1 text-sm text-fg-muted">dari 100</p>
        </div>

        {/* Status lulus */}
        <div
          className={cn(
            'mx-auto mt-4 inline-flex items-center gap-2 rounded-full px-4 py-1.5 text-sm font-semibold',
            hasil.lulus ? 'bg-success/15 text-success' : 'bg-surface-raised text-fg-muted',
          )}
        >
          {hasil.lulus ? (
            <>
              <Check className="size-4" aria-hidden="true" />
              Lulus
            </>
          ) : (
            <>
              <X className="size-4" aria-hidden="true" />
              Belum lulus
            </>
          )}
        </div>

        <p className="mt-4 text-sm text-fg-muted">
          {hasil.jumlahBenar} benar · {hasil.jumlahSoal - hasil.jumlahBenar} salah · ambang lulus{' '}
          {AMBANG_LULUS_QUIZ}
        </p>

        {/* Pesan saat tidak lulus — nada mendukung, tidak menghakimi */}
        {!hasil.lulus && (
          <p className="mx-auto mt-4 max-w-md text-sm text-fg">
            Nilai belum mencapai {AMBANG_LULUS_QUIZ}. Ini bukan masalah — artinya ada bagian yang
            perlu diperkuat. Lihat analisis di bawah untuk tahu bagian mana.
          </p>
        )}
      </Card>

      {/* Analisis per topik */}
      <Card className="p-6">
        <h2 className="mb-4 font-heading text-lg font-semibold text-fg">Analisis per Topik</h2>

        <div className="space-y-4">
          {akurasiTopik.map((a) => (
            <BarTopik key={a.cardType} akurasi={a} />
          ))}
        </div>

        {/* Saran untuk topik lemah */}
        {topikLemah.length > 0 && (
          <div className="mt-5 rounded-lg border border-danger/30 bg-danger/5 p-4">
            <p className="text-sm font-semibold text-fg">
              Perlu diulang: {topikLemah.map((t) => LABEL_TIPE_KARTU[t.cardType]).join(', ')}
            </p>
            <p className="mt-1 text-sm text-fg-muted">
              Baca ulang modulnya, lalu ulangi kartu dengan topik ini.
            </p>
          </div>
        )}
      </Card>

      {/* Status tahap */}
      <Card className="border-success/40 bg-success/5 p-6">
        <div className="flex items-start gap-3">
          <Check className="mt-0.5 size-5 shrink-0 text-success" aria-hidden="true" />
          <div className="min-w-0 flex-1">
            <p className="font-semibold text-fg">Tahap 3 dari 3 selesai</p>
            <p className="mt-1 text-sm text-fg-muted">
              {hasil.lulus
                ? 'Modul ini tuntas. Lanjut ke modul berikutnya?'
                : 'Modul ini tuntas. Kamu bisa mengulang quiz kapan saja untuk memperkuat pemahaman.'}
            </p>
            <div className="mt-4 flex flex-wrap gap-2">
              <Link to="/dashboard" className="inline-flex no-underline">
                <Button ikonKanan={<ArrowRight className="size-4" aria-hidden="true" />}>
                  Ke Dashboard
                </Button>
              </Link>
              <Link to={`/materi/${modulSlug}`} className="inline-flex no-underline">
                <Button varian="secondary">Baca Ulang Modul</Button>
              </Link>
            </div>
          </div>
        </div>
      </Card>

      {/* Aksi */}
      <div className="flex flex-col gap-3 sm:flex-row sm:justify-center">
        <Button
          varian="secondary"
          onClick={onUlangi}
          ikonKiri={<RotateCcw className="size-4" aria-hidden="true" />}
        >
          Ulangi Quiz
        </Button>
        <Link to="/soal" className="inline-flex no-underline">
          <Button varian="ghost" className="w-full">
            Kembali ke Soal
          </Button>
        </Link>
      </div>
    </div>
  );
}

/** Bar akurasi satu topik */
function BarTopik({ akurasi }: { akurasi: AkurasiTopik }) {
  const warna =
    akurasi.kategori === 'lemah'
      ? 'var(--danger)'
      : akurasi.kategori === 'cukup'
        ? 'var(--topik-pointer)'
        : 'var(--success)';

  const labelKategori =
    akurasi.kategori === 'lemah' ? 'perlu diulang' : akurasi.kategori === 'cukup' ? 'hampir' : 'kuat';

  return (
    <div>
      <div className="mb-1.5 flex items-baseline justify-between gap-3 text-sm">
        <span className="font-medium text-fg">{LABEL_TIPE_KARTU[akurasi.cardType]}</span>
        <span className="shrink-0 tabular-nums text-fg-muted">
          {akurasi.persen}% ({akurasi.benar}/{akurasi.total}) · {labelKategori}
        </span>
      </div>
      <div
        role="progressbar"
        aria-valuenow={akurasi.persen}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-label={`Akurasi ${LABEL_TIPE_KARTU[akurasi.cardType]}`}
        className="h-2 w-full overflow-hidden rounded-full bg-surface-raised"
      >
        <div
          className="h-full rounded-full transition-[width] duration-500"
          style={{ width: `${akurasi.persen}%`, backgroundColor: warna }}
        />
      </div>
    </div>
  );
}
