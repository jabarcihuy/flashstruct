import { useQuery } from '@tanstack/react-query';
import { ambilDaftarModul, ambilModulLengkap } from './api';

/**
 * Hook TanStack Query untuk fitur materi.
 *
 * Konfigurasi query (staleTime, retry) ada di app/providers.tsx.
 * Di sini hanya mendefinisikan queryKey dan queryFn.
 */

export const kunciQuery = {
  daftarModul: ['modul', 'daftar'] as const,
  modulLengkap: (slug: string) => ['modul', 'lengkap', slug] as const,
};

/** Daftar semua modul untuk halaman Materi dan Dashboard */
export function useDaftarModul() {
  return useQuery({
    queryKey: kunciQuery.daftarModul,
    queryFn: ambilDaftarModul,
  });
}

/** Satu modul lengkap untuk halaman baca */
export function useModulLengkap(slug: string) {
  return useQuery({
    queryKey: kunciQuery.modulLengkap(slug),
    queryFn: () => ambilModulLengkap(slug),
    // Jangan jalankan query kalau slug kosong
    enabled: Boolean(slug),
  });
}
