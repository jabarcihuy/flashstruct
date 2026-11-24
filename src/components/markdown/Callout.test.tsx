import { describe, it, expect } from 'vitest';
import { useEffect, type ReactNode } from 'react';
import { render, screen } from '@testing-library/react';
import { Callout } from './Callout';
import { slugHeading, tipeDariPenanda } from './util';
import { BahasaProvider, useBahasa } from '@/app/BahasaProvider';

function EnglishWrapper({ children }: { children: ReactNode }) {
  const { setBahasa } = useBahasa();
  useEffect(() => setBahasa('en'), [setBahasa]);
  return <>{children}</>;
}

describe('tipeDariPenanda', () => {
  it('mengenali penanda INFO', () => {
    expect(tipeDariPenanda('INFO')).toBe('info');
    expect(tipeDariPenanda('info')).toBe('info');
  });

  it('mengenali penanda PERHATIAN dan WARNING', () => {
    expect(tipeDariPenanda('PERHATIAN')).toBe('perhatian');
    expect(tipeDariPenanda('WARNING')).toBe('perhatian');
  });

  it('mengenali penanda BAHAYA dan DANGER', () => {
    expect(tipeDariPenanda('BAHAYA')).toBe('bahaya');
    expect(tipeDariPenanda('DANGER')).toBe('bahaya');
  });

  it('mengenali penanda TIPS', () => {
    expect(tipeDariPenanda('TIPS')).toBe('tips');
    expect(tipeDariPenanda('TIP')).toBe('tips');
  });

  it('mengabaikan spasi di sekitar penanda', () => {
    expect(tipeDariPenanda('  INFO  ')).toBe('info');
  });

  it('mengembalikan null untuk penanda yang tidak dikenal', () => {
    expect(tipeDariPenanda('NGARANG')).toBeNull();
    expect(tipeDariPenanda('')).toBeNull();
  });
});

describe('slugHeading', () => {
  it('mengubah judul menjadi slug', () => {
    expect(slugHeading('Apa Itu Array')).toBe('apa-itu-array');
  });

  it('menghapus tanda baca', () => {
    expect(slugHeading('C++ vs Python!')).toBe('c-vs-python');
  });

  it('mengubah spasi berlebih menjadi satu tanda hubung', () => {
    expect(slugHeading('Memori    Berurutan')).toBe('memori-berurutan');
  });

  it('menangani judul dengan angka', () => {
    expect(slugHeading('Rumus Alamat Elemen')).toBe('rumus-alamat-elemen');
  });
});

describe('Callout', () => {
  it('merender isi callout', () => {
    render(
      <Callout tipe="info">
        <p>Indeks dimulai dari nol.</p>
      </Callout>,
    );
    expect(screen.getByText('Indeks dimulai dari nol.')).toBeInTheDocument();
  });

  it('memakai role="note" agar dikenali pembaca layar', () => {
    render(
      <Callout tipe="bahaya">
        <p>Undefined behavior.</p>
      </Callout>,
    );
    expect(screen.getByRole('note')).toBeInTheDocument();
  });

  it('menampilkan label sesuai tipe', () => {
    render(
      <Callout tipe="perhatian">
        <p>Hati-hati.</p>
      </Callout>,
    );
    expect(screen.getByText('Perhatian')).toBeInTheDocument();
  });

  it('menerjemahkan label callout saat bahasa Inggris dipilih', async () => {
    render(
      <BahasaProvider>
        <EnglishWrapper>
          <Callout tipe="bahaya">
            <p>Pointer warning.</p>
          </Callout>
        </EnglishWrapper>
      </BahasaProvider>,
    );
    expect(await screen.findByText('Danger')).toBeInTheDocument();
  });

  it('memakai judul kustom bila diberikan', () => {
    render(
      <Callout tipe="tips" judul="Cara Mengingat">
        <p>Ingat rumusnya.</p>
      </Callout>,
    );
    expect(screen.getByText('Cara Mengingat')).toBeInTheDocument();
  });

  it('memberi aria-label pada elemen note', () => {
    render(
      <Callout tipe="info">
        <p>Isi</p>
      </Callout>,
    );
    expect(screen.getByRole('note')).toHaveAttribute('aria-label', 'Info');
  });

  it('menyertakan ikon untuk penanda visual', () => {
    const { container } = render(
      <Callout tipe="bahaya">
        <p>Bahaya</p>
      </Callout>,
    );
    expect(container.querySelector('svg')).toBeInTheDocument();
  });
});
