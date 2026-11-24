import { RotateCcw } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { useBahasa } from '@/app/BahasaProvider';

/**
 * Layar transisi sebelum putaran ulang kartu lupa.
 *
 * Menjelaskan APA yang akan terjadi dan BERAPA kartu yang diulang.
 * Pengguna perlu tahu mengapa sesi belum berakhir.
 *
 * Putaran ulang hanya SATU kali. Alasannya: putaran tak terbatas bisa
 * membuat sesi tidak pernah selesai. Kartu yang masih lupa akan muncul
 * lagi di sesi berikutnya — dan karena kartu lupa diprioritaskan,
 * kartu itu pasti muncul lebih awal.
 */

interface PutaranUlangProps {
  jumlahLupa: number;
  jumlahTotal: number;
  onMulai: () => void;
  onLewati: () => void;
}

export function PutaranUlang({ jumlahLupa, jumlahTotal, onMulai, onLewati }: PutaranUlangProps) {
  const { bahasa } = useBahasa();
  const en = bahasa === 'en';
  return (
    <div className="mx-auto w-full max-w-md">
      <Card className="p-6 text-center sm:p-8">
        <div className="mx-auto mb-4 flex size-12 items-center justify-center rounded-md bg-primary/10">
          <RotateCcw className="size-6 text-primary" aria-hidden="true" />
        </div>

        <h2 className="font-heading text-xl font-semibold text-fg">
          {en ? 'Review round' : 'Putaran Ulang'}
        </h2>

        <p className="mt-2 text-sm text-fg-muted">
          {en ? (
            <>
              You marked{' '}
              <strong className="text-fg">
                {jumlahLupa} of {jumlahTotal} cards
              </strong>{' '}
              as forgotten. Review them now to help the concepts stick.
            </>
          ) : (
            <>
              Dari {jumlahTotal} kartu, <strong className="text-fg">{jumlahLupa} kartu</strong> kamu
              tandai lupa. Mari ulangi kartu itu supaya benar-benar menempel.
            </>
          )}
        </p>

        <div className="mt-6 flex flex-col gap-3">
          <Button onClick={onMulai} ikonKiri={<RotateCcw className="size-4" aria-hidden="true" />}>
            {en ? `Review ${jumlahLupa} cards` : `Ulangi ${jumlahLupa} Kartu`}
          </Button>
          <Button varian="ghost" onClick={onLewati}>
            {en ? 'Skip to results' : 'Lewati, lihat hasil'}
          </Button>
        </div>

        <p className="mt-4 text-xs text-fg-muted">
          {en
            ? 'This review round happens once. Cards you still forget will return in a future session.'
            : 'Putaran ulang hanya sekali. Kartu yang masih lupa akan muncul lagi di sesi berikutnya.'}
        </p>
      </Card>
    </div>
  );
}
