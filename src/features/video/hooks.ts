import { useQuery } from '@tanstack/react-query';
import { ambilSemuaVideo } from './api';

/** Hook TanStack Query untuk fitur video */

export const kunciQueryVideo = {
  semua: ['video', 'semua'] as const,
};

/** Semua video untuk halaman Video */
export function useSemuaVideo() {
  return useQuery({
    queryKey: kunciQueryVideo.semua,
    queryFn: ambilSemuaVideo,
  });
}
