import { useState, type ReactNode } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { TemaProvider } from './TemaProvider';

function buatQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        // Konten edukasi hampir tidak pernah berubah.
        // 5 menit mencegah fetch ulang saat navigasi bolak-balik.
        staleTime: 5 * 60 * 1000,

        // Simpan di cache selama 30 menit.
        gcTime: 30 * 60 * 1000,

        // Coba 2 kali — jaringan kampus sering tidak stabil.
        retry: 2,
        retryDelay: (attempt) => Math.min(1000 * 2 ** attempt, 10_000),

        // Jangan fetch ulang hanya karena window kembali fokus —
        // mengganggu saat pengguna sedang membaca modul panjang.
        refetchOnWindowFocus: false,

        // Fetch ulang saat koneksi kembali.
        refetchOnReconnect: true,
      },
    },
  });
}

export function Providers({ children }: { children: ReactNode }) {
  const [queryClient] = useState(buatQueryClient);

  return (
    <QueryClientProvider client={queryClient}>
      <TemaProvider>{children}</TemaProvider>
    </QueryClientProvider>
  );
}
