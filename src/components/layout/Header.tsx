import { NavLink } from 'react-router-dom';
import { Monitor, Moon, Sun } from 'lucide-react';
import { cn } from '@/lib/cn';
import { useTema, URUTAN_TEMA } from '@/app/tema';
import { NAV_ITEMS } from './nav-items';
import { useBahasa } from '@/app/BahasaProvider';

const LABEL_NAV_EN: Record<string, string> = { Materi: 'Learn', Soal: 'Quizzes' };

export function LanguageToggle() {
  const { bahasa, setBahasa } = useBahasa();
  const ubahKe = bahasa === 'id' ? 'en' : 'id';
  return (
    <button
      type="button"
      onClick={() => setBahasa(ubahKe)}
      aria-label={
        bahasa === 'id' ? 'Switch language to English' : 'Ganti bahasa ke Bahasa Indonesia'
      }
      title={bahasa === 'id' ? 'English' : 'Bahasa Indonesia'}
      className={cn(
        'inline-flex h-10 min-w-10 items-center justify-center rounded-md px-2 text-sm font-semibold text-fg-muted transition-colors hover:bg-surface hover:text-fg',
      )}
    >
      {ubahKe.toUpperCase()}
    </button>
  );
}

/** Tombol pengalih tema: terang -> gelap -> ikuti sistem */
export function ThemeToggle() {
  const { tema, setTema } = useTema();
  const { bahasa } = useBahasa();

  const berikutnya = () => {
    const idx = URUTAN_TEMA.indexOf(tema);
    setTema(URUTAN_TEMA[(idx + 1) % URUTAN_TEMA.length]!);
  };

  const Ikon = tema === 'terang' ? Sun : tema === 'gelap' ? Moon : Monitor;
  const label =
    bahasa === 'en'
      ? tema === 'terang'
        ? 'Light'
        : tema === 'gelap'
          ? 'Dark'
          : 'System'
      : tema === 'terang'
        ? 'Terang'
        : tema === 'gelap'
          ? 'Gelap'
          : 'Ikuti Sistem';

  return (
    <button
      type="button"
      onClick={berikutnya}
      aria-label={
        bahasa === 'en'
          ? `Theme: ${label}. Click to change.`
          : `Tema: ${label}. Klik untuk mengubah.`
      }
      title={bahasa === 'en' ? `Theme: ${label}` : `Tema: ${label}`}
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
  const { bahasa } = useBahasa();
  return (
    <header className="site-header safe-top safe-x sticky top-0 z-40 border-b border-border bg-bg">
      <div className="site-header-inner container-wide flex items-center gap-10">
        <NavLink
          to="/"
          className="site-brand inline-flex items-center font-heading font-bold text-fg no-underline"
          aria-label="FlashStruct — ke halaman depan"
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
                      {bahasa === 'en' ? (LABEL_NAV_EN[label] ?? label) : label}
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

        <div className="ml-auto flex items-center gap-1">
          <LanguageToggle />
          <ThemeToggle />
        </div>
      </div>
    </header>
  );
}
