import { useQuery } from '@tanstack/react-query';
import { ambilSemuaVideo } from './api';
import { useBahasa } from '@/app/BahasaProvider';

/** Hook TanStack Query untuk fitur video */

export const kunciQueryVideo = {
  semua: ['video', 'semua'] as const,
};

/** Semua video untuk halaman Video */
export function useSemuaVideo() {
  const { bahasa } = useBahasa();
  return useQuery({
    queryKey: [...kunciQueryVideo.semua, bahasa],
    queryFn: () => ambilSemuaVideo(bahasa),
  });
}
