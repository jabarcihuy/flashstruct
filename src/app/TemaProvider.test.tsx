import { describe, it, expect, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { TemaProvider } from './TemaProvider';
import { useTema } from './tema';
import { KUNCI_TEMA } from '@/lib/constants';

/** Komponen bantu untuk menguji hook useTema */
function PengujiTema() {
  const { tema, temaAktif, setTema } = useTema();
  return (
    <div>
      <span data-testid="pilihan">{tema}</span>
      <span data-testid="aktif">{temaAktif}</span>
      <button onClick={() => setTema('gelap')}>Gelap</button>
      <button onClick={() => setTema('terang')}>Terang</button>
      <button onClick={() => setTema('sistem')}>Sistem</button>
    </div>
  );
}

function renderPenguji() {
  return render(
    <TemaProvider>
      <PengujiTema />
    </TemaProvider>,
  );
}

beforeEach(() => {
  localStorage.clear();
  document.documentElement.removeAttribute('data-theme');
});

describe('TemaProvider', () => {
  it('memakai "sistem" sebagai default saat tidak ada pilihan tersimpan', () => {
    renderPenguji();
    expect(screen.getByTestId('pilihan')).toHaveTextContent('sistem');
  });

  it('membaca pilihan tersimpan dari localStorage', () => {
    localStorage.setItem(KUNCI_TEMA, 'gelap');
    renderPenguji();
    expect(screen.getByTestId('pilihan')).toHaveTextContent('gelap');
  });

  it('mengabaikan nilai localStorage yang tidak valid', () => {
    localStorage.setItem(KUNCI_TEMA, 'warna-aneh');
    renderPenguji();
    expect(screen.getByTestId('pilihan')).toHaveTextContent('sistem');
  });

  /**
   * Uji regresi penting.
   *
   * Bug yang pernah terjadi: TemaProvider menulis data-theme="gelap"
   * sedangkan CSS memakai selector [data-theme="dark"] — nilainya tidak
   * pernah cocok, sehingga mode gelap tidak pernah aktif.
   *
   * Uji ini memastikan nilai yang ditulis ke <html> SAMA PERSIS dengan
   * yang diharapkan selector CSS di tokens.css.
   */
  it('menulis data-theme="gelap" (bukan "dark") ke elemen html', async () => {
    const user = userEvent.setup();
    renderPenguji();

    await user.click(screen.getByRole('button', { name: 'Gelap' }));

    expect(document.documentElement.getAttribute('data-theme')).toBe('gelap');
  });

  it('menulis data-theme="terang" ke elemen html', async () => {
    const user = userEvent.setup();
    renderPenguji();

    await user.click(screen.getByRole('button', { name: 'Terang' }));

    expect(document.documentElement.getAttribute('data-theme')).toBe('terang');
  });

  it('menyimpan pilihan ke localStorage', async () => {
    const user = userEvent.setup();
    renderPenguji();

    await user.click(screen.getByRole('button', { name: 'Gelap' }));

    expect(localStorage.getItem(KUNCI_TEMA)).toBe('gelap');
  });

  it('tetap berfungsi walau localStorage gagal menyimpan', async () => {
    const user = userEvent.setup();
    const setItemAsli = Storage.prototype.setItem;
    Storage.prototype.setItem = () => {
      throw new Error('QuotaExceededError');
    };

    renderPenguji();
    await user.click(screen.getByRole('button', { name: 'Gelap' }));

    // Tema tetap berlaku untuk sesi ini walau gagal disimpan
    expect(document.documentElement.getAttribute('data-theme')).toBe('gelap');

    Storage.prototype.setItem = setItemAsli;
  });

  it('menyelesaikan "sistem" menjadi tema konkret yang bisa dipakai CSS', () => {
    renderPenguji();
    // matchMedia di-stub agar mengembalikan false (terang)
    expect(['terang', 'gelap']).toContain(screen.getByTestId('aktif').textContent);
  });
});
