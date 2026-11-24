import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { BahasaProvider, useBahasa } from './BahasaProvider';

function Probe() {
  const { bahasa, setBahasa } = useBahasa();
  return <button onClick={() => setBahasa('en')}>{bahasa}</button>;
}

describe('BahasaProvider', () => {
  beforeEach(() => {
    localStorage.clear();
    document.documentElement.removeAttribute('lang');
  });

  it('menyimpan pilihan bahasa dan mengatur lang dokumen', async () => {
    render(
      <BahasaProvider>
        <Probe />
      </BahasaProvider>,
    );
    fireEvent.click(screen.getByRole('button'));
    expect(await screen.findByText('en')).toBeInTheDocument();
    expect(localStorage.getItem('flashstruct:bahasa:v1')).toBe('en');
    expect(document.documentElement.lang).toBe('en');
  });

  it('memulihkan bahasa yang tersimpan', () => {
    localStorage.setItem('flashstruct:bahasa:v1', 'en');
    render(
      <BahasaProvider>
        <Probe />
      </BahasaProvider>,
    );
    expect(screen.getByRole('button')).toHaveTextContent('en');
  });
});
