import type { ButtonHTMLAttributes, ReactNode } from 'react';
import { Loader2 } from 'lucide-react';
import { cn } from '@/lib/cn';

export type VarianTombol = 'primary' | 'secondary' | 'ghost' | 'accent' | 'danger';
export type UkuranTombol = 'sm' | 'md' | 'lg';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  varian?: VarianTombol;
  ukuran?: UkuranTombol;
  memuat?: boolean;
  ikonKiri?: ReactNode;
  ikonKanan?: ReactNode;
}

const VARIAN: Record<VarianTombol, string> = {
  primary: 'bg-primary text-on-primary hover:brightness-110 active:brightness-95',
  secondary: 'bg-transparent text-fg border border-border-strong hover:bg-surface',
  ghost: 'bg-transparent text-fg-muted hover:bg-surface hover:text-fg',
  accent: 'bg-accent text-on-accent hover:brightness-110 active:brightness-95',
  danger: 'bg-danger text-white hover:brightness-110 active:brightness-95',
};

const UKURAN: Record<UkuranTombol, string> = {
  /**
   * Tinggi minimum 44px di mobile (target sentuh jari),
   * boleh lebih rapat di desktop karena mouse lebih presisi.
   * Lihat docs/03-DESIGN-SYSTEM.md §4.7
   */
  sm: 'h-11 px-3 text-sm md:h-9',
  md: 'h-11 px-4 text-sm md:h-10',
  lg: 'h-12 px-6 text-base',
};

export function Button({
  varian = 'primary',
  ukuran = 'md',
  memuat = false,
  ikonKiri,
  ikonKanan,
  className,
  children,
  disabled,
  ...props
}: ButtonProps) {
  return (
    <button
      type="button"
      disabled={disabled || memuat}
      aria-busy={memuat || undefined}
      className={cn(
        'inline-flex items-center justify-center gap-2 rounded-md font-medium',
        'transition-[filter,background-color,color] duration-150',
        'cursor-pointer',
        'disabled:cursor-not-allowed disabled:opacity-50',
        VARIAN[varian],
        UKURAN[ukuran],
        className,
      )}
      {...props}
    >
      {memuat ? (
        <Loader2 className="size-4 animate-spin" aria-hidden="true" />
      ) : (
        ikonKiri
      )}
      {children}
      {!memuat && ikonKanan}
    </button>
  );
}
