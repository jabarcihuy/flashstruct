import { BookOpen, CircleHelp, LayoutDashboard, PlayCircle } from 'lucide-react';
import type { ItemNav } from './nav';

/**
 * Daftar item navigasi utama.
 *
 * Maksimal 5 item — sesuai pedoman bottom nav
 * (docs/03-DESIGN-SYSTEM.md §6.8).
 */
export const NAV_ITEMS: ItemNav[] = [
  { ke: '/dashboard', label: 'Dashboard', ikon: LayoutDashboard },
  { ke: '/materi', label: 'Materi', ikon: BookOpen },
  { ke: '/video', label: 'Video', ikon: PlayCircle },
  { ke: '/soal', label: 'Soal', ikon: CircleHelp },
];
