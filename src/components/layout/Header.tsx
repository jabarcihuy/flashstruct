import { NavLink } from 'react-router-dom';
import { Monitor, Moon, Sun } from 'lucide-react';
import { cn } from '@/lib/cn';
import { useTema, URUTAN_TEMA } from '@/app/tema';
import { NAV_ITEMS } from './nav-items';

/** Tombol pengalih tema: terang -> gelap -> ikuti sistem */
export function ThemeToggle() {
  const { tema, setTema } = useTema();

  const berikutnya = () => {
    const idx = URUTAN_TEMA.indexOf(tema);
    setTema(URUTAN_TEMA[(idx + 1) % URUTAN_TEMA.length]!);
  };

  const Ikon = tema === 'terang' ? Sun : tema === 'gelap' ? Moon : Monitor;
  const label = tema === 'terang' ? 'Terang' : tema === 'gelap' ? 'Gelap' : 'Ikuti Sistem';

  return (
    <button
      type="button"
      onClick={berikutnya}
      aria-label={`Tema: ${label}. Klik untuk mengubah.`}
      title={`Tema: ${label}`}
      className={cn(
        'inline-flex size-11 items-center justify-center rounded-md md:size-10',
        'cursor-pointer text-fg-muted transition-colors duration-150',
        'hover:bg-surface hover:text-fg',
      )}
    >
      <Ikon className="size-5" aria-hidden="true" />
    </button>
  );
}

export function Header() {
  return (
    <header className="site-header safe-top safe-x sticky top-0 z-40 border-b border-border bg-bg">
      <div className="site-header-inner container-wide flex items-center gap-10">
        <NavLink
          to="/"
          className="site-brand inline-flex items-center font-heading font-bold text-fg no-underline"
          aria-label="FlashStruct — ke beranda"
        >
          FlashStruct
        </NavLink>

        {/* Navigasi desktop — disembunyikan di mobile karena ada BottomNav */}
        <nav aria-label="Navigasi utama" className="hidden md:block">
          <ul className="flex items-center gap-1">
            {NAV_ITEMS.map(({ ke, label, tepat }) => (
              <li key={ke}>
                <NavLink
                  to={ke}
                  end={tepat}
                  className={({ isActive }) =>
                    cn(
                      'relative inline-flex items-center rounded-md px-3 py-2 text-sm no-underline',
                      'transition-colors duration-150',
                      isActive
                        ? 'font-semibold text-fg'
                        : 'text-fg-muted hover:bg-surface hover:text-fg',
                    )
                  }
                >
                  {({ isActive }) => (
                    <>
                      {label}
                      {/* Penanda aktif: garis bawah + warna, bukan warna saja */}
                      {isActive && (
                        <span
                          aria-hidden="true"
                          className="absolute inset-x-3 -bottom-px h-0.5 rounded-full bg-primary"
                        />
                      )}
                    </>
                  )}
                </NavLink>
              </li>
            ))}
          </ul>
        </nav>

        <div className="ml-auto"><ThemeToggle /></div>
      </div>
    </header>
  );
}
