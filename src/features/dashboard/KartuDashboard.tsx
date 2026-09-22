import { Link } from 'react-router-dom';
import { Check, Lightbulb } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { cn } from '@/lib/cn';
import { LearningStages } from '@/components/ui/LearningStages';
import { ProgressBar } from '@/components/ui/Progress';
import { statusSemuaTahap, persenProgresModul } from '@/features/progres/aturan';
import type { ProgresModul } from '@/features/progres/schema';
import type { Rekomendasi } from './rekomendasi';

/**
 * Kartu rekomendasi — komponen terpenting di Dashboard.
 *
 * Selalu menampilkan ALASAN, bukan hanya aksi. "Lanjutkan" tanpa alasan
 * tidak membantu pengguna memahami di mana posisinya.
 *
 * Rincian: docs/06-SPESIFIKASI-HALAMAN.md §3.3
 */

export function KartuRekomendasi({
  rekomendasi,
  progresModul,
}: {
  rekomendasi: Rekomendasi;
  progresModul?: ProgresModul;
}) {
  const persen = persenProgresModul(progresModul);
  return (
    <section className="recommendation" aria-label="Modul yang disarankan">
      <div className="recommendation-copy">
        <p className="recommendation-label">Modul yang disarankan</p>
        <h2>{rekomendasi.modulJudul}</h2>
        <p className="recommendation-reason">{rekomendasi.alasan}</p>
        <Link to={rekomendasi.ctaRute} className="action-link">
          {rekomendasi.ctaLabel}
        </Link>
      </div>
      <div className="recommendation-stages">
        {/* Comp: blok progress setinggi 45px (label + bar + persen), lalu
            jarak 22px ke kartu tahap. Nilai ini diukur dari spec.json
            region lesson-progress (y=216 h=45) dan stage-1 (y=283). */}
        <div className="progress-head">
          <span>Progres modul</span>
          <span>{persen === 0 ? 'Belum dimulai' : `${persen}% selesai`}</span>
        </div>
        <div className="progress-bar">
          <ProgressBar nilai={persen} label="Progres modul yang disarankan" tanpaLabelVisual />
          <span className="tabular-nums">{persen}%</span>
        </div>
        <LearningStages tahap={statusSemuaTahap(progresModul)} />
      </div>
    </section>
  );
}

/**
 * Kartu saat semua modul sudah tuntas.
 *
 * Menyarankan cara memperkuat, bukan sekadar "selamat, selesai".
 */
export function KartuSemuaSelesai({
  modulTerlemah,
}: {
  modulTerlemah: { slug: string; judul: string; akurasi: number } | null;
}) {
  return (
    <Card className="border-success/40 bg-success/5 p-5 sm:p-6">
      <div className="flex items-start gap-4">
        <div
          className="flex size-11 shrink-0 items-center justify-center rounded-full bg-success/15"
          aria-hidden="true"
        >
          <Check className="size-5 text-success" />
        </div>

        <div className="min-w-0 flex-1">
          <p className="text-xs font-semibold uppercase tracking-wide text-success">Selesai</p>

          <h2 className="mt-1.5 font-heading text-lg font-semibold text-fg">
            Semua modul sudah tuntas
          </h2>

          <p className="mt-2 text-sm leading-relaxed text-fg">
            Kamu sudah menuntaskan seluruh modul. Untuk memperkuat, ulangi quiz dengan akurasi
            terendah atau ulangi deck yang sudah lama tidak dibuka.
          </p>

          {modulTerlemah && (
            <div className="mt-4 rounded-lg border border-border bg-surface p-3">
              <p className="text-sm text-fg">
                <span className="font-medium">Akurasi terendah: </span>
                {modulTerlemah.judul} ({modulTerlemah.akurasi}%)
              </p>
              <Link
                to={`/soal/quiz/${modulTerlemah.slug}`}
                className="mt-3 inline-block no-underline"
              >
                <Button ukuran="sm" varian="secondary">
                  Ulangi Quiz Terlemah
                </Button>
              </Link>
            </div>
          )}
        </div>
      </div>
    </Card>
  );
}

/**
 * Saran tambahan saat semua selesai — memperkuat tanpa menghakimi.
 */
export function SaranMemperkuat() {
  const saran = [
    {
      ikon: Lightbulb,
      judul: 'Ulangi deck lama',
      pesan: 'Kartu yang sudah lama tidak dibuka akan muncul lebih awal di sesi berikutnya.',
    },
    {
      ikon: Check,
      judul: 'Fokus ke topik lemah',
      pesan: 'Lihat analisis topik di hasil quiz — bagian di bawah 50% perlu diulang.',
    },
  ];

  return (
    <div className="grid gap-4 sm:grid-cols-2">
      {saran.map((s) => (
        <Card key={s.judul} className="p-4">
          <div className="flex items-start gap-3">
            <s.ikon className="mt-0.5 size-5 shrink-0 text-fg-muted" aria-hidden="true" />
            <div>
              <p className="text-sm font-medium text-fg">{s.judul}</p>
              <p className="mt-1 text-xs text-fg-muted">{s.pesan}</p>
            </div>
          </div>
        </Card>
      ))}
    </div>
  );
}

/** Baris progres satu topik */
export function BarisTopik({
  label,
  selesai,
  total,
  persen,
  warna,
}: {
  label: string;
  selesai: number;
  total: number;
  persen: number;
  warna: string;
}) {
  return (
    <div>
      <div className="mb-1.5 flex items-baseline justify-between gap-3 text-sm">
        <span className="font-medium text-fg">{label}</span>
        <span className="shrink-0 tabular-nums text-fg-muted">
          {selesai} dari {total} modul
        </span>
      </div>
      <div
        role="progressbar"
        aria-valuenow={persen}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-label={`Progres topik ${label}`}
        className="h-2 w-full overflow-hidden rounded-full bg-surface-raised"
      >
        <div
          className="h-full rounded-full transition-[width] duration-500"
          style={{ width: `${persen}%`, backgroundColor: warna }}
        />
      </div>
    </div>
  );
}

/** Kartu statistik satu angka */
export function StatCard({
  nilai,
  label,
  keterangan,
  ajakan,
  warna,
}: {
  nilai: string | number;
  label: string;
  keterangan?: string;
  ajakan?: string;
  warna?: string;
}) {
  const kosong = nilai === 0 || nilai === '0' || nilai === '0%';

  return (
    <Card className={cn('p-4 text-center sm:p-5')}>
      <div
        className="font-heading text-3xl font-bold tabular-nums sm:text-4xl"
        style={{ color: warna ?? 'var(--fg)' }}
      >
        {nilai}
      </div>
      <div className="mt-1 text-sm font-medium text-fg">{label}</div>
      {keterangan && <div className="mt-0.5 text-xs text-fg-muted">{keterangan}</div>}

      {/* Ajakan bertindak saat kosong — kartu nol tanpa arah membingungkan */}
      {kosong && ajakan && <div className="mt-2 text-xs font-medium text-link">{ajakan}</div>}
    </Card>
  );
}
