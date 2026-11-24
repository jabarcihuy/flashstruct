import { Link } from 'react-router-dom';
import { ArrowRight, Check, RotateCcw, X } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { ProgressBar } from '@/components/ui/Progress';
import type { RingkasanSesi as Ringkasan } from './sesi';
import { useBahasa } from '@/app/BahasaProvider';

/**
 * Ringkasan sesi flashcard.
 *
 * Menampilkan: jumlah kartu, diingat, perlu diulang, dan status deck.
 * Jika semua kartu dikuasai, menampilkan ajakan lanjut ke quiz —
 * karena tahap 2 sudah selesai dan tahap 3 terbuka.
 */

interface RingkasanSesiProps {
  ringkasan: Ringkasan;
  modulSlug: string;
  /** Jumlah kartu yang sudah dikuasai di seluruh deck (bukan hanya sesi ini) */
  kartuDikuasai: number;
  kartuTotal: number;
  onUlangi: () => void;
}

export function RingkasanSesi({
  ringkasan,
  modulSlug,
  kartuDikuasai,
  kartuTotal,
  onUlangi,
}: RingkasanSesiProps) {
  const { bahasa } = useBahasa();
  const en = bahasa === 'en';
  return (
    <div className="mx-auto w-full max-w-lg space-y-6">
      {/* Statistik sesi */}
      <Card className="p-6">
        <div className="grid grid-cols-3 gap-4 text-center">
          <Statistik
            nilai={ringkasan.total}
            label={en ? 'cards' : 'kartu'}
            keterangan={en ? 'completed' : 'dikerjakan'}
            warna="var(--fg)"
          />
          <Statistik
            nilai={ringkasan.ingat}
            label={en ? 'remembered' : 'diingat'}
            keterangan={en ? `${ringkasan.akurasi}% accuracy` : `${ringkasan.akurasi}% akurasi`}
            warna="var(--success)"
            ikon={<Check className="size-4" aria-hidden="true" />}
          />
          <Statistik
            nilai={ringkasan.lupa}
            label={en ? 'to review' : 'perlu diulang'}
            keterangan={
              ringkasan.lupa > 0
                ? en
                  ? 'will be reviewed'
                  : 'akan diulang'
                : en
                  ? 'none'
                  : 'tidak ada'
            }
            warna={ringkasan.lupa > 0 ? 'var(--danger)' : 'var(--fg-muted)'}
            ikon={ringkasan.lupa > 0 ? <X className="size-4" aria-hidden="true" /> : undefined}
          />
        </div>
      </Card>

      {/* Status deck keseluruhan */}
      <Card className="p-6">
        <p className="mb-3 text-sm font-semibold text-fg">{en ? 'Deck status' : 'Status Deck'}</p>
        <ProgressBar
          nilai={kartuDikuasai}
          maks={kartuTotal}
          label={
            en
              ? `${kartuDikuasai} of ${kartuTotal} cards mastered`
              : `${kartuDikuasai} dari ${kartuTotal} kartu dikuasai`
          }
        />
        <p className="mt-3 text-xs text-fg-muted">
          {en
            ? 'A card is mastered when you have marked it remembered and never marked it forgotten.'
            : 'Kartu dianggap dikuasai jika pernah kamu tandai ingat dan tidak pernah lupa.'}
        </p>
      </Card>

      {/* Status tahap */}
      {ringkasan.semuaDikuasai ? (
        <Card className="border-success/40 bg-success/5 p-6">
          <div className="flex items-start gap-3">
            <Check className="mt-0.5 size-5 shrink-0 text-success" aria-hidden="true" />
            <div className="min-w-0 flex-1">
              <p className="font-semibold text-fg">
                {en ? 'Stage 2 of 3 complete' : 'Tahap 2 dari 3 selesai'}
              </p>
              <p className="mt-1 text-sm text-fg-muted">
                {en
                  ? 'You remembered every card. The next stage is unlocked: prove it with a quiz.'
                  : 'Semua kartu sudah kamu tandai ingat. Tahap berikutnya terbuka: buktikan dengan quiz.'}
              </p>
              <div className="mt-4 flex flex-wrap gap-2">
                <Link to={`/soal/quiz/${modulSlug}`} className="inline-flex no-underline">
                  <Button ikonKanan={<ArrowRight className="size-4" aria-hidden="true" />}>
                    {en ? 'Start quiz' : 'Mulai Quiz'}
                  </Button>
                </Link>
              </div>
            </div>
          </div>
        </Card>
      ) : (
        <Card className="border-dashed p-6">
          <p className="font-semibold text-fg">
            {en ? 'Stage 2 is not complete yet' : 'Tahap 2 belum selesai'}
          </p>
          <p className="mt-1 text-sm text-fg-muted">
            {en
              ? `${ringkasan.lupa} cards still need review. Finish them all to unlock the quiz.`
              : `Masih ada ${ringkasan.lupa} kartu yang perlu diulang. Selesaikan semuanya dulu untuk membuka quiz.`}
          </p>
        </Card>
      )}

      {/* Aksi */}
      <div className="flex flex-col gap-3 sm:flex-row sm:justify-center">
        <Button
          varian="secondary"
          onClick={onUlangi}
          ikonKiri={<RotateCcw className="size-4" aria-hidden="true" />}
        >
          {en ? 'Repeat session' : 'Ulangi Sesi'}
        </Button>
        <Link to="/soal" className="no-underline sm:w-auto">
          <Button varian="ghost" className="w-full">
            {en ? 'Back to quizzes' : 'Kembali ke Soal'}
          </Button>
        </Link>
      </div>
    </div>
  );
}

/** Satu angka statistik */
function Statistik({
  nilai,
  label,
  keterangan,
  warna,
  ikon,
}: {
  nilai: number;
  label: string;
  keterangan: string;
  warna: string;
  ikon?: React.ReactNode;
}) {
  return (
    <div>
      <div
        className="flex items-center justify-center gap-1 font-heading text-3xl font-bold tabular-nums"
        style={{ color: warna }}
      >
        {ikon}
        {nilai}
      </div>
      <div className="mt-1 text-xs font-medium text-fg">{label}</div>
      <div className="mt-0.5 text-[11px] text-fg-muted">{keterangan}</div>
    </div>
  );
}
