import { cn } from '@/lib/cn';

/* =========================================================
   Indikator Progres
   Empat bentuk sesuai docs/03-DESIGN-SYSTEM.md §6.6

   Aturan aksesibilitas: setiap indikator WAJIB punya teks
   pendamping. Bar tanpa label tidak berarti bagi pembaca layar.
   ========================================================= */

interface ProgressBarProps {
  /** Nilai saat ini */
  nilai: number;
  /** Nilai maksimum */
  maks?: number;
  /** Label untuk pembaca layar — wajib diisi */
  label: string;
  /** Sembunyikan label visual, tapi tetap ada untuk pembaca layar */
  tanpaLabelVisual?: boolean;
  /** Warna bar — default memakai --primary */
  warna?: string;
  className?: string;
}

/** Bar progres linier (mis. kartu 3 dari 20) */
export function ProgressBar({
  nilai,
  maks = 100,
  label,
  tanpaLabelVisual = false,
  warna,
  className,
}: ProgressBarProps) {
  const persen = maks > 0 ? Math.min(100, Math.max(0, (nilai / maks) * 100)) : 0;

  return (
    <div className={cn('w-full', className)}>
      {!tanpaLabelVisual && (
        <div className="mb-1.5 flex items-baseline justify-between gap-2 text-sm">
          <span className="text-fg-muted">{label}</span>
          <span className="font-medium tabular-nums text-fg">
            {nilai} / {maks}
          </span>
        </div>
      )}
      <div
        role="progressbar"
        aria-valuenow={nilai}
        aria-valuemin={0}
        aria-valuemax={maks}
        aria-label={label}
        className="h-2 w-full overflow-hidden rounded-full bg-surface-raised"
      >
        <div
          className="h-full rounded-full transition-[width] duration-300 ease-out"
          style={{
            width: `${persen}%`,
            backgroundColor: warna ?? 'var(--primary)',
          }}
        />
      </div>
    </div>
  );
}

interface ProgressRingProps {
  nilai: number;
  maks?: number;
  ukuran?: number;
  /** Label untuk pembaca layar */
  label: string;
  warna?: string;
  /** Konten di tengah ring, mis. "82%" */
  children?: React.ReactNode;
  className?: string;
}

/** Ring progres melingkar (mis. persentase deck dikuasai) */
export function ProgressRing({
  nilai,
  maks = 100,
  ukuran = 96,
  label,
  warna,
  children,
  className,
}: ProgressRingProps) {
  const persen = maks > 0 ? Math.min(100, Math.max(0, (nilai / maks) * 100)) : 0;
  const tebal = 8;
  const jari = (ukuran - tebal) / 2;
  const keliling = 2 * Math.PI * jari;
  const panjangBusur = (persen / 100) * keliling;

  return (
    <div className={cn('relative inline-flex items-center justify-center', className)}>
      <svg
        width={ukuran}
        height={ukuran}
        viewBox={`0 0 ${ukuran} ${ukuran}`}
        role="progressbar"
        aria-valuenow={nilai}
        aria-valuemin={0}
        aria-valuemax={maks}
        aria-label={label}
        className="-rotate-90"
      >
        {/* Latar ring */}
        <circle
          cx={ukuran / 2}
          cy={ukuran / 2}
          r={jari}
          fill="none"
          stroke="var(--surface-raised)"
          strokeWidth={tebal}
        />
        {/* Busur progres */}
        <circle
          cx={ukuran / 2}
          cy={ukuran / 2}
          r={jari}
          fill="none"
          stroke={warna ?? 'var(--primary)'}
          strokeWidth={tebal}
          strokeLinecap="round"
          strokeDasharray={`${panjangBusur} ${keliling - panjangBusur}`}
          className="transition-[stroke-dasharray] duration-300 ease-out"
        />
      </svg>
      {children && (
        <div className="absolute inset-0 flex items-center justify-center">{children}</div>
      )}
    </div>
  );
}

export type StatusTahap = 'terkunci' | 'tersedia' | 'selesai';

interface IndikatorTigaTahapProps {
  /** Status tiap tahap: pahami, hafalkan, buktikan */
  tahap: [StatusTahap, StatusTahap, StatusTahap];
  /** Tampilkan label teks di samping ikon */
  denganLabel?: boolean;
  className?: string;
}

const LABEL_TAHAP = ['Pahami', 'Hafalkan', 'Buktikan'] as const;

/**
 * Indikator tiga tahap — elemen kunci FlashStruct.
 *
 * Memberi gambaran progres tanpa perlu membuka modul.
 * Bentuknya: tiga label dengan ikon centang / kunci / kosong.
 */
export function IndikatorTigaTahap({
  tahap,
  denganLabel = true,
  className,
}: IndikatorTigaTahapProps) {
  return (
    <ol
      className={cn('flex flex-wrap items-center gap-x-3 gap-y-1.5', className)}
      aria-label="Status tiga tahap"
    >
      {tahap.map((status, i) => (
        <li key={LABEL_TAHAP[i]} className="flex items-center gap-1.5 text-xs">
          <IkonTahap status={status} />
          <span
            className={cn(
              status === 'terkunci' ? 'text-fg-muted' : 'text-fg',
              status === 'selesai' && 'font-medium',
            )}
          >
            {denganLabel ? LABEL_TAHAP[i] : <span className="sr-only">{LABEL_TAHAP[i]}</span>}
          </span>
          <span className="sr-only">
            {status === 'selesai'
              ? 'selesai'
              : status === 'tersedia'
                ? 'belum selesai'
                : 'terkunci'}
          </span>
        </li>
      ))}
    </ol>
  );
}

function IkonTahap({ status }: { status: StatusTahap }) {
  if (status === 'selesai') {
    return (
      <svg
        viewBox="0 0 16 16"
        className="size-4 shrink-0 text-success"
        aria-hidden="true"
        fill="none"
      >
        <circle cx="8" cy="8" r="7" fill="currentColor" opacity="0.15" />
        <circle cx="8" cy="8" r="7" stroke="currentColor" strokeWidth="1.5" />
        <path
          d="M5 8.5l2 2 4-4.5"
          stroke="currentColor"
          strokeWidth="1.75"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    );
  }

  if (status === 'terkunci') {
    return (
      <svg
        viewBox="0 0 16 16"
        className="size-4 shrink-0 text-fg-muted"
        aria-hidden="true"
        fill="none"
      >
        <rect
          x="3.5"
          y="7"
          width="9"
          height="6.5"
          rx="1.5"
          stroke="currentColor"
          strokeWidth="1.5"
        />
        <path d="M5.5 7V5a2.5 2.5 0 015 0v2" stroke="currentColor" strokeWidth="1.5" />
      </svg>
    );
  }

  // tersedia
  return (
    <svg
      viewBox="0 0 16 16"
      className="size-4 shrink-0 text-fg-muted"
      aria-hidden="true"
      fill="none"
    >
      <circle cx="8" cy="8" r="7" stroke="currentColor" strokeWidth="1.5" strokeDasharray="3 2.5" />
    </svg>
  );
}

interface StatAngkaProps {
  nilai: string | number;
  label: string;
  /** Teks pendamping saat nilai masih 0 */
  ajakan?: string;
  className?: string;
}

/** Angka besar untuk kartu statistik di Dashboard */
export function StatAngka({ nilai, label, ajakan, className }: StatAngkaProps) {
  const kosong = nilai === 0 || nilai === '0';

  return (
    <div className={cn('text-center', className)}>
      <div className="font-heading text-4xl font-bold tabular-nums text-fg">{nilai}</div>
      <div className="mt-1 text-sm text-fg-muted">{label}</div>
      {kosong && ajakan && <div className="mt-2 text-xs text-link">{ajakan}</div>}
    </div>
  );
}
