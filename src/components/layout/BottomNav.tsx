import { NavLink } from 'react-router-dom';
import { cn } from '@/lib/cn';
import { NAV_ITEMS } from './nav-items';

/**
 * Navigasi bawah untuk mobile.
 *
 * Disembunyikan di md ke atas karena desktop memakai Header.
 * Tinggi minimum 56px per item agar nyaman disentuh (target 44px+).
 */
export function BottomNav() {
  return (
    <nav
      aria-label="Navigasi utama"
      className={cn(
        'bottom-nav safe-x fixed inset-x-0 bottom-0 z-40 md:hidden',
        'border-t border-border bg-surface/95 backdrop-blur-sm',
      )}
    >
      <ul className="flex items-stretch">
        {NAV_ITEMS.map(({ ke, label, ikon: Ikon, tepat }) => (
          <li key={ke} className="flex-1">
            <NavLink
              to={ke}
              end={tepat}
              className={({ isActive }) =>
                cn(
                  'relative flex min-h-14 flex-col items-center justify-center gap-1 px-1 py-2',
                  'text-[11px] no-underline transition-colors duration-150',
                  isActive ? 'font-semibold text-primary' : 'text-fg-muted',
                )
              }
            >
              {({ isActive }) => (
                <>
                  <Ikon
                    className="size-5"
                    strokeWidth={isActive ? 2.2 : 1.5}
                    aria-hidden="true"
                  />
                  <span>{label}</span>
                  {/* Penanda aktif: garis atas, bukan warna saja */}
                  {isActive && (
                    <span
                      aria-hidden="true"
                      className="absolute inset-x-3 top-0 h-0.5 rounded-full bg-primary"
                    />
                  )}
                </>
              )}
            </NavLink>
          </li>
        ))}
      </ul>
    </nav>
  );
}
