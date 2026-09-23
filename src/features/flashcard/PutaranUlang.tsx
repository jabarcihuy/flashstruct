import { RotateCcw } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';

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
  return (
    <div className="mx-auto w-full max-w-md">
      <Card className="p-6 text-center sm:p-8">
        <div className="mx-auto mb-4 flex size-12 items-center justify-center rounded-md bg-primary/10">
          <RotateCcw className="size-6 text-primary" aria-hidden="true" />
        </div>

        <h2 className="font-heading text-xl font-semibold text-fg">Putaran Ulang</h2>

        <p className="mt-2 text-sm text-fg-muted">
          Dari {jumlahTotal} kartu, <strong className="text-fg">{jumlahLupa} kartu</strong> kamu
          tandai lupa. Mari ulangi kartu itu supaya benar-benar menempel.
        </p>

        <div className="mt-6 flex flex-col gap-3">
          <Button onClick={onMulai} ikonKiri={<RotateCcw className="size-4" aria-hidden="true" />}>
            Ulangi {jumlahLupa} Kartu
          </Button>
          <Button varian="ghost" onClick={onLewati}>
            Lewati, lihat hasil
          </Button>
        </div>

        <p className="mt-4 text-xs text-fg-muted">
          Putaran ulang hanya sekali. Kartu yang masih lupa akan muncul lagi di sesi berikutnya.
        </p>
      </Card>
    </div>
  );
}
