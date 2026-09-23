import { Suspense, useEffect } from 'react';
import { Link, Outlet, ScrollRestoration, useLocation } from 'react-router-dom';
import { ArrowRight } from 'lucide-react';
import { ThemeToggle } from './Header';

/** Kerangka publik: navigasi penjelasan produk terpisah dari navigasi belajar. */
export function LandingLayout() {
  const { pathname } = useLocation();

  useEffect(() => {
    const heading = document.querySelector('h1');
    if (!heading) return;
    heading.setAttribute('tabindex', '-1');
    heading.focus({ preventScroll: true });
  }, [pathname]);

  return (
    <div className="landing-shell min-h-dvh bg-bg text-fg">
      <a href="#konten-utama" className="skip-link">
        Lewati ke konten utama
      </a>
      <header className="landing-header safe-top safe-x">
        <div className="landing-header-inner container-wide">
          <Link to="/" className="landing-brand" aria-label="FlashStruct — halaman depan">
            FlashStruct
          </Link>
          <nav aria-label="Navigasi landing" className="landing-header-nav">
            <a href="#cara-kerja">Cara belajar</a>
            <a href="#kurikulum">Kurikulum</a>
          </nav>
          <div className="landing-header-actions">
            <ThemeToggle />
            <Link to="/dashboard" className="landing-app-link">
              Buka aplikasi <ArrowRight size={16} aria-hidden="true" />
            </Link>
          </div>
        </div>
      </header>
      <main id="konten-utama" tabIndex={-1} className="outline-none">
        <Suspense fallback={<div className="container-base py-12">Memuat halaman…</div>}>
          <Outlet />
        </Suspense>
      </main>
      <ScrollRestoration />
    </div>
  );
}
