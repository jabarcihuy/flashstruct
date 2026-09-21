import { useCallback, useEffect, useState, type ReactNode } from 'react';
import { TemaContext, bacaTemaTersimpan, preferensiSistem, type Tema } from './tema';
import { KUNCI_TEMA } from '@/lib/constants';

export function TemaProvider({ children }: { children: ReactNode }) {
  const [tema, setTemaState] = useState<Tema>(bacaTemaTersimpan);
  const [sistem, setSistem] = useState<'terang' | 'gelap'>(preferensiSistem);

  // Ikuti perubahan preferensi tema sistem operasi
  useEffect(() => {
    if (typeof window.matchMedia !== 'function') return;

    const mq = window.matchMedia('(prefers-color-scheme: dark)');
    const handler = (e: MediaQueryListEvent) => setSistem(e.matches ? 'gelap' : 'terang');
    mq.addEventListener('change', handler);
    return () => mq.removeEventListener('change', handler);
  }, []);

  const temaAktif: 'terang' | 'gelap' = tema === 'sistem' ? sistem : tema;

  // Terapkan ke <html data-theme="..."> agar token CSS berganti
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', temaAktif);
  }, [temaAktif]);

  const setTema = useCallback((baru: Tema) => {
    setTemaState(baru);
    try {
      localStorage.setItem(KUNCI_TEMA, baru);
    } catch {
      // Gagal menyimpan tidak fatal — tema tetap berlaku untuk sesi ini
    }
  }, []);

  return (
    <TemaContext.Provider value={{ tema, temaAktif, setTema }}>{children}</TemaContext.Provider>
  );
}
