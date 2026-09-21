import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

/**
 * Gabungkan className dengan aman.
 *
 * clsx menangani nilai kondisional, tailwind-merge menyelesaikan
 * konflik kelas Tailwind (mis. `p-2 p-4` menjadi `p-4`).
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
