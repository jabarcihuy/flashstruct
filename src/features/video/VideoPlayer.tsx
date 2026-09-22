import { useEffect, useRef } from 'react';
import { ExternalLink, X } from 'lucide-react';
import { cn } from '@/lib/cn';
import type { VideoDenganModul } from '@/types/database';

/**
 * Modal pemutar video YouTube.
 *
 * Keputusan penting:
 *   - Memakai youtube-nocookie.com untuk mengurangi pelacakan
 *     (sesuai N-09 di docs/01-PRD.md)
 *   - autoplay=1 karena pengguna sudah menyatakan niat dengan mengklik
 *   - iframe WAJIB punya title untuk aksesibilitas
 *   - Scroll body dikunci saat modal terbuka
 *   - Escape menutup modal
 *
 * Rincian: docs/06-SPESIFIKASI-HALAMAN.md §5.4
 */

interface VideoPlayerProps {
  video: VideoDenganModul;
  onTutup: () => void;
}

export function VideoPlayer({ video, onTutup }: VideoPlayerProps) {
  const refDialog = useRef<HTMLDivElement>(null);

  // Kunci scroll body + Escape + perangkap fokus
  useEffect(() => {
    const overflowAsli = document.body.style.overflow;
    document.body.style.overflow = 'hidden';

    const pemicu = document.activeElement;

    function onKeyDown(e: KeyboardEvent) {
      if (e.key === 'Escape') {
        e.preventDefault();
        onTutup();
        return;
      }

      if (e.key !== 'Tab' || !refDialog.current) return;

      const bisaDifokus = refDialog.current.querySelectorAll<HTMLElement>(
        'a[href], button:not([disabled]), iframe, [tabindex]:not([tabindex="-1"])',
      );
      if (bisaDifokus.length === 0) return;

      const pertama = bisaDifokus[0]!;
      const terakhir = bisaDifokus[bisaDifokus.length - 1]!;

      if (e.shiftKey && document.activeElement === pertama) {
        e.preventDefault();
        terakhir.focus();
      } else if (!e.shiftKey && document.activeElement === terakhir) {
        e.preventDefault();
        pertama.focus();
      }
    }

    document.addEventListener('keydown', onKeyDown);

    // Fokuskan tombol tutup agar keyboard langsung bisa memakai Escape
    window.setTimeout(() => {
      refDialog.current?.querySelector<HTMLElement>('button')?.focus();
    }, 0);

    return () => {
      document.body.style.overflow = overflowAsli;
      document.removeEventListener('keydown', onKeyDown);
      if (pemicu instanceof HTMLElement) pemicu.focus();
    };
  }, [onTutup]);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-0 sm:p-4">
      <div className="absolute inset-0 bg-black/70" onClick={onTutup} aria-hidden="true" />

      <div
        ref={refDialog}
        role="dialog"
        aria-modal="true"
        aria-label={video.judul}
        className={cn(
          'relative max-h-[90dvh] w-full overflow-y-auto bg-surface',
          'sm:max-w-3xl sm:rounded-xl',
        )}
      >
        <div className="flex items-start justify-between gap-4 p-4 pb-0">
          <div className="min-w-0">
            <h2 className="font-heading text-lg font-semibold text-fg">{video.judul}</h2>
            <p className="mt-0.5 text-sm text-fg-muted">dari: {video.modul.judul}</p>
          </div>
          <button
            type="button"
            onClick={onTutup}
            aria-label="Tutup pemutar video"
            className="inline-flex size-11 shrink-0 cursor-pointer items-center justify-center rounded-md text-fg-muted hover:bg-surface-raised hover:text-fg sm:size-9"
          >
            <X className="size-5" aria-hidden="true" />
          </button>
        </div>

        <div className="p-4">
          <iframe
            src={`https://www.youtube-nocookie.com/embed/${video.youtube_id}?autoplay=1`}
            title={video.judul}
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
            className="aspect-video w-full rounded-lg border border-border"
          />

          {video.deskripsi && <p className="mt-4 text-sm text-fg-muted">{video.deskripsi}</p>}

          <a
            href={`https://www.youtube.com/watch?v=${video.youtube_id}`}
            target="_blank"
            rel="noopener noreferrer"
            className="mt-4 inline-flex h-11 items-center gap-2 text-sm text-primary underline underline-offset-2 md:h-9"
          >
            Buka di YouTube
            <ExternalLink className="size-4" aria-hidden="true" />
          </a>
        </div>
      </div>
    </div>
  );
}
