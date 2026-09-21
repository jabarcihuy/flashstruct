import { createContext, useContext } from 'react';
import { KUNCI_TEMA } from '@/lib/constants';

export type Tema = 'terang' | 'gelap' | 'sistem';

export interface TemaContextValue {
  /** Pilihan pengguna: terang, gelap, atau ikut sistem */
  tema: Tema;
  /** Tema yang sedang aktif setelah resolusi 'sistem' */
  temaAktif: 'terang' | 'gelap';
  /** Ubah pilihan tema */
  setTema: (tema: Tema) => void;
}

export const TemaContext = createContext<TemaContextValue | null>(null);

/** Baca pilihan tema dari localStorage dengan aman */
export function bacaTemaTersimpan(): Tema {
  try {
    const tersimpan = localStorage.getItem(KUNCI_TEMA);
    if (tersimpan === 'terang' || tersimpan === 'gelap' || tersimpan === 'sistem') {
      return tersimpan;
    }
  } catch {
    // localStorage bisa gagal di mode privat — abaikan dan pakai default
  }
  return 'sistem';
}

/** Baca preferensi tema sistem operasi */
export function preferensiSistem(): 'terang' | 'gelap' {
  // matchMedia tidak selalu tersedia (jsdom, browser lama, SSR).
  // Jangan sampai aplikasi crash hanya karena tema tidak bisa dideteksi.
  if (typeof window === 'undefined' || typeof window.matchMedia !== 'function') {
    return 'terang';
  }
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'gelap' : 'terang';
}

/** Urutan perputaran tema saat tombol ditekan */
export const URUTAN_TEMA: Tema[] = ['terang', 'gelap', 'sistem'];

/** Hook untuk mengakses tema */
export function useTema() {
  const ctx = useContext(TemaContext);
  if (!ctx) throw new Error('useTema harus dipakai di dalam TemaProvider');
  return ctx;
}
