import { Suspense, useEffect } from 'react';
import { Outlet, ScrollRestoration, useLocation } from 'react-router-dom';
import { Header } from './Header';
import { BottomNav } from './BottomNav';

/**
 * Kerangka halaman.
 *
 * Bertanggung jawab atas:
 *  - Navigasi (Header desktop, BottomNav mobile)
 *  - Skip link untuk pengguna keyboard
 *  - Suspense fallback saat halaman dimuat lazy
 *  - Pemulihan posisi scroll saat navigasi
 *  - Memindahkan fokus ke judul halaman setelah navigasi (SPA)
 */
export function RootLayout() {
  const { pathname } = useLocation();

  // Pada SPA, berpindah halaman tidak memindahkan fokus otomatis.
  // Tanpa ini, pengguna keyboard harus menekan Tab berkali-kali.
  useEffect(() => {
    const h1 = document.querySelector('h1');
    if (h1) {
      h1.setAttribute('tabindex', '-1');
      h1.focus({ preventScroll: true });
    }
  }, [pathname]);

  return (
    <div className="min-h-dvh bg-bg text-fg">
      <a href="#konten-utama" className="skip-link">
        Lewati ke konten utama
      </a>

      <Header />

      {/*
        tabIndex={-1}: wajib agar skip link benar-benar memindahkan fokus.
        Tanpa ini, href="#konten-utama" hanya menggulir halaman — fokus tetap
        di <body>, sehingga pengguna keyboard harus menekan Tab puluhan kali
        untuk melewati navigasi. Terverifikasi lewat audit keyboard.
      */}
      <main id="konten-utama" tabIndex={-1} className="konten-utama outline-none">
        <Suspense fallback={<PageSkeleton />}>
          <Outlet />
        </Suspense>
      </main>

      <BottomNav />
      <ScrollRestoration />
    </div>
  );
}

/** Fallback sederhana saat halaman lazy sedang dimuat */
function PageSkeleton() {
  return (
    <div className="container-base py-8" aria-busy="true" aria-live="polite">
      <span className="sr-only">Memuat halaman…</span>
      <div className="h-8 w-1/3 animate-pulse rounded-md bg-surface-raised" />
      <div className="mt-3 h-4 w-2/3 animate-pulse rounded-md bg-surface-raised" />
      <div className="mt-8 space-y-3">
        <div className="h-32 animate-pulse rounded-lg bg-surface-raised" />
        <div className="h-32 animate-pulse rounded-lg bg-surface-raised" />
      </div>
    </div>
  );
}
