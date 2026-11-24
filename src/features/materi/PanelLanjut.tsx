import { Link } from 'react-router-dom';
import { ArrowRight, Check, Lock } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { cn } from '@/lib/cn';
import { PERSEN_MINIMAL_BACA } from '@/lib/constants';
import { useBahasa } from '@/app/BahasaProvider';

/**
 * Panel di bawah modul: tombol "Tandai Selesai" dan arah ke tahap 2.
 *
 * Aturan penting: saat tahap berikutnya terkunci, tombolnya TETAP
 * TERLIHAT tetapi tidak aktif, disertai alasan. Menyembunyikannya
 * membuat pengguna tidak tahu ada tahap berikutnya.
 *
 * Rincian: docs/06-SPESIFIKASI-HALAMAN.md §4.4, §4.5
 */

interface PanelLanjutProps {
  modulSlug: string;
  modulId: string;
  persen: number;
  tahap1Selesai: boolean;
  onTandaiSelesai: () => void;
  onBatalkan: () => void;
}

export function PanelLanjut({
  modulSlug,
  persen,
  tahap1Selesai,
  onTandaiSelesai,
  onBatalkan,
}: PanelLanjutProps) {
  const { bahasa } = useBahasa();
  const en = bahasa === 'en';
  const cukup = persen >= PERSEN_MINIMAL_BACA;

  /* ---------- Sudah selesai ---------- */
  if (tahap1Selesai) {
    return (
      <Card className="border-success/40 bg-success/5 p-5">
        <div className="flex items-start gap-3">
          <Check className="mt-0.5 size-5 shrink-0 text-success" aria-hidden="true" />
          <div className="min-w-0 flex-1">
            <p className="font-semibold text-fg">{en ? 'Module complete' : 'Modul selesai'}</p>
            <p className="mt-1 text-sm text-fg-muted">
              {en
                ? 'Stage 1 of 3 complete. Next, remember the concepts with this module’s flashcards.'
                : 'Tahap 1 dari 3 tuntas. Berikutnya: hafalkan kartu dari modul ini.'}
            </p>

            <div className="mt-4 flex flex-wrap gap-2">
              <Link to={`/soal/flashcard/${modulSlug}`} className="inline-flex no-underline">
                <Button ikonKanan={<ArrowRight className="size-4" aria-hidden="true" />}>
                  {en ? 'Continue to flashcards' : 'Lanjut ke Flashcard'}
                </Button>
              </Link>
              <Button varian="ghost" ukuran="sm" onClick={onBatalkan}>
                {en ? 'Undo completion' : 'Batalkan tanda selesai'}
              </Button>
            </div>
          </div>
        </div>
      </Card>
    );
  }

  /* ---------- Belum cukup dibaca ---------- */
  if (!cukup) {
    return (
      <Card className="border-dashed p-5">
        <div className="flex items-start gap-3">
          <Lock className="mt-0.5 size-5 shrink-0 text-fg-muted" aria-hidden="true" />
          <div className="min-w-0 flex-1">
            <p className="font-semibold text-fg">
              {en ? 'Not ready to complete' : 'Belum bisa ditandai selesai'}
            </p>
            <p className="mt-1 text-sm text-fg-muted">
              {en ? (
                <>
                  Read at least {PERSEN_MINIMAL_BACA}% of the module. You’re at{' '}
                  <strong className="text-fg">{persen}%</strong> — keep scrolling to continue.
                </>
              ) : (
                <>
                  Baca dulu minimal {PERSEN_MINIMAL_BACA}% bagian modul. Sekarang{' '}
                  <strong className="text-fg">{persen}%</strong> — scroll terus untuk melanjutkan.
                </>
              )}
            </p>

            <div className="mt-4">
              <Button disabled aria-disabled="true">
                {en ? 'Mark as complete' : 'Tandai Selesai'}
              </Button>
            </div>
          </div>
        </div>
      </Card>
    );
  }

  /* ---------- Siap ditandai selesai ---------- */
  return (
    <Card className="p-5">
      <p className="font-semibold text-fg">{en ? 'Finished reading?' : 'Sudah selesai membaca?'}</p>
      <p className="mt-1 text-sm text-fg-muted">
        {en
          ? `You’ve viewed ${persen}% of the module. Mark it complete to unlock the next stage.`
          : `Kamu sudah membuka ${persen}% bagian modul. Tandai selesai untuk membuka tahap berikutnya.`}
      </p>

      <div className="mt-4 flex flex-wrap items-center gap-3">
        <Button onClick={onTandaiSelesai}>{en ? 'Mark as complete' : 'Tandai Selesai'}</Button>
        <Link to={`/soal/flashcard/${modulSlug}`} className="inline-flex no-underline">
          <Button
            varian="ghost"
            disabled
            aria-disabled="true"
            ikonKiri={<Lock className="size-4" aria-hidden="true" />}
          >
            {en ? 'Flashcards' : 'Flashcard'}
          </Button>
        </Link>
      </div>

      <p className={cn('mt-3 text-xs text-fg-muted')}>
        {en
          ? 'Flashcards unlock after you mark the module complete.'
          : 'Tombol flashcard aktif setelah modul ditandai selesai.'}
      </p>
    </Card>
  );
}
