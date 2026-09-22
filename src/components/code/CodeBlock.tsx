import { useEffect, useState } from 'react';
import { Check, Copy } from 'lucide-react';
import { cn } from '@/lib/cn';
import { useTema } from '@/app/tema';
import { LABEL_BAHASA, bahasaDidukung, warnaiKode } from './shiki';

/**
 * Blok kode dengan pewarnaan sintaks dan tombol salin.
 *
 * Fallback penting: kalau Shiki gagal dimuat (misalnya offline),
 * kode tetap ditampilkan TANPA warna — bukan pesan error. Kode tetap
 * terbaca, hanya belum berwarna. Ini lebih baik daripada spinner
 * yang tidak pernah selesai.
 */

/**
 * Fallback salin untuk browser tanpa navigator.clipboard.
 *
 * navigator.clipboard hanya tersedia di HTTPS atau localhost.
 * Di lingkungan lain, cara lama ini masih berfungsi.
 */
function salinFallback(teks: string): void {
  const area = document.createElement('textarea');
  area.value = teks;
  area.setAttribute('readonly', '');
  area.style.position = 'fixed';
  area.style.opacity = '0';
  document.body.appendChild(area);
  area.select();
  document.execCommand('copy');
  document.body.removeChild(area);
}

interface CodeBlockProps {
  kode: string;
  bahasa?: string;
  /** Nama berkas, ditampilkan di header */
  namaBerkas?: string;
  /** Tampilkan nomor baris — otomatis jika kode > 5 baris */
  nomorBaris?: boolean;
  className?: string;
}

export function CodeBlock({ kode, bahasa, namaBerkas, nomorBaris, className }: CodeBlockProps) {
  const { temaAktif } = useTema();
  const [html, setHtml] = useState<string | null>(null);
  const [tersalin, setTersalin] = useState(false);

  const baris = kode.trimEnd().split('\n');
  const tampilkanNomor = nomorBaris ?? baris.length > 5;
  const label = bahasaDidukung(bahasa) ? LABEL_BAHASA[bahasa] : undefined;

  // Warnai kode saat tema berubah
  useEffect(() => {
    let dibatalkan = false;

    void warnaiKode(kode, bahasa, temaAktif).then((hasil) => {
      if (!dibatalkan) setHtml(hasil);
    });

    return () => {
      dibatalkan = true;
    };
  }, [kode, bahasa, temaAktif]);

  async function salin() {
    try {
      // navigator.clipboard butuh HTTPS atau localhost. Di lingkungan
      // lain (mis. HTTP biasa), ia bisa tidak tersedia. Ada fallback
      // memakai textarea + execCommand.
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(kode);
      } else {
        salinFallback(kode);
      }
      setTersalin(true);
      window.setTimeout(() => setTersalin(false), 2000);
    } catch {
      // Kalau tetap gagal, coba fallback terakhir
      try {
        salinFallback(kode);
        setTersalin(true);
        window.setTimeout(() => setTersalin(false), 2000);
      } catch {
        // Menyerah dengan tenang — pengguna masih bisa memilih manual
      }
    }
  }

  return (
    <div
      className={cn(
        'group relative my-5 overflow-hidden rounded-md border border-border',
        className,
      )}
    >
      {/* Header: label bahasa + nama berkas + tombol salin */}
      {(label || namaBerkas) && (
        <div className="flex items-center justify-between gap-3 border-b border-border bg-surface-raised px-3 py-2">
          <span className="font-mono text-xs text-fg-muted">
            {label}
            {namaBerkas && <span className="ml-2 opacity-70">{namaBerkas}</span>}
          </span>
          <button
            type="button"
            onClick={() => void salin()}
            aria-label={tersalin ? 'Kode tersalin' : 'Salin kode'}
            className={cn(
              'inline-flex cursor-pointer items-center gap-1.5 rounded px-2.5',
              // Target sentuh 44px di mobile, lebih rapat di desktop
              'h-11 text-xs md:h-8',
              'text-fg-muted transition-colors duration-150',
              'hover:bg-surface hover:text-fg',
            )}
          >
            {tersalin ? (
              <>
                <Check className="size-3.5 text-success" aria-hidden="true" />
                <span>Tersalin</span>
              </>
            ) : (
              <>
                <Copy className="size-3.5" aria-hidden="true" />
                <span>Salin</span>
              </>
            )}
          </button>
        </div>
      )}

      {/* Isi kode */}
      <div className="relative bg-code-bg">
        {html ? (
          <div
            className={cn(
              'shiki-wrapper overflow-x-auto text-sm',
              '[&>pre]:m-0 [&>pre]:bg-transparent [&>pre]:p-4',
              tampilkanNomor && '[&>pre]:pl-0',
            )}
            /**
             * tabIndex + role: blok kode bisa di-scroll horizontal, jadi
             * pengguna keyboard harus bisa memfokusnya untuk menggulir
             * (WCAG 2.1.1). Tanpa ini, kode panjang hanya bisa dibaca
             * dengan mouse — axe melaporkan `scrollable-region-focusable`.
             */
            tabIndex={0}
            role="region"
            aria-label={label ? `Kode ${label}` : 'Blok kode'}
            // Aman: HTML dihasilkan Shiki dari konten yang kita kontrol
            dangerouslySetInnerHTML={{ __html: html }}
          />
        ) : (
          // Fallback: kode tanpa warna, tetap terbaca
          <pre
            tabIndex={0}
            role="region"
            aria-label={label ? `Kode ${label}` : 'Kode'}
            className="overflow-x-auto p-4 font-mono text-sm text-code-fg"
          >
            <code>{kode}</code>
          </pre>
        )}

        {/* Tombol salin mengapung saat tidak ada header */}
        {!label && !namaBerkas && (
          <button
            type="button"
            onClick={() => void salin()}
            aria-label={tersalin ? 'Kode tersalin' : 'Salin kode'}
            className={cn(
              'absolute right-2 top-2 cursor-pointer rounded p-1.5',
              'bg-surface/90 text-fg-muted opacity-0 transition-opacity duration-150',
              'hover:text-fg focus-visible:opacity-100 group-hover:opacity-100',
            )}
          >
            {tersalin ? (
              <Check className="size-4 text-success" aria-hidden="true" />
            ) : (
              <Copy className="size-4" aria-hidden="true" />
            )}
          </button>
        )}
      </div>
    </div>
  );
}
