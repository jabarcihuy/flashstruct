import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';

export type Bahasa = 'id' | 'en';
const KUNCI_BAHASA = 'flashstruct:bahasa:v1';
type KonteksBahasa = { bahasa: Bahasa; setBahasa: (bahasa: Bahasa) => void };
const BahasaContext = createContext<KonteksBahasa>({ bahasa: 'id', setBahasa: () => undefined });

function bacaBahasa(): Bahasa {
  try {
    return localStorage.getItem(KUNCI_BAHASA) === 'en' ? 'en' : 'id';
  } catch {
    return 'id';
  }
}

export function BahasaProvider({ children }: { children: ReactNode }) {
  const [bahasa, ubahBahasa] = useState<Bahasa>(bacaBahasa);
  const setBahasa = useCallback((baru: Bahasa) => {
    ubahBahasa(baru);
    try {
      localStorage.setItem(KUNCI_BAHASA, baru);
    } catch {
      // Bahasa tetap dapat diganti untuk sesi saat ini.
    }
  }, []);
  useEffect(() => {
    document.documentElement.lang = bahasa;
  }, [bahasa]);
  const value = useMemo(() => ({ bahasa, setBahasa }), [bahasa, setBahasa]);
  return <BahasaContext.Provider value={value}>{children}</BahasaContext.Provider>;
}

export function useBahasa() {
  return useContext(BahasaContext);
}
