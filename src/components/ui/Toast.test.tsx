import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ToastProvider } from './Toast';
import { useToast } from './toast-context';

function PemicuToast() {
  const { tampilkan } = useToast();
  return (
    <div>
      <button onClick={() => tampilkan('Progres tersimpan', 'sukses')}>Sukses</button>
      <button onClick={() => tampilkan('Info biasa', 'info')}>Info</button>
      <button onClick={() => tampilkan('Gagal memuat', 'error')}>Error</button>
    </div>
  );
}

function renderToast() {
  return render(
    <ToastProvider>
      <PemicuToast />
    </ToastProvider>,
  );
}

describe('Toast', () => {
  it('menampilkan notifikasi saat dipicu', async () => {
    const user = userEvent.setup();
    renderToast();

    await user.click(screen.getByRole('button', { name: 'Sukses' }));

    expect(screen.getByText('Progres tersimpan')).toBeInTheDocument();
  });

  it('memakai role status untuk notifikasi non-error', async () => {
    const user = userEvent.setup();
    renderToast();

    await user.click(screen.getByRole('button', { name: 'Info' }));

    expect(screen.getByRole('status')).toHaveTextContent('Info biasa');
  });

  it('memakai role alert dan aria-live assertive untuk error', async () => {
    const user = userEvent.setup();
    renderToast();

    await user.click(screen.getByRole('button', { name: 'Error' }));

    const alert = screen.getByRole('alert');
    expect(alert).toHaveTextContent('Gagal memuat');
    expect(alert).toHaveAttribute('aria-live', 'assertive');
  });

  it('bisa ditutup manual', async () => {
    const user = userEvent.setup();
    renderToast();

    await user.click(screen.getByRole('button', { name: 'Error' }));
    expect(screen.getByText('Gagal memuat')).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: 'Tutup notifikasi' }));
    expect(screen.queryByText('Gagal memuat')).not.toBeInTheDocument();
  });

  it('membatasi maksimal 3 notifikasi bertumpuk', async () => {
    const user = userEvent.setup();
    renderToast();

    const tombol = screen.getByRole('button', { name: 'Error' });
    await user.click(tombol);
    await user.click(tombol);
    await user.click(tombol);
    await user.click(tombol);

    // Yang tertua dibuang, tersisa 3
    expect(screen.getAllByRole('alert')).toHaveLength(3);
  });

  it('melempar error jelas bila useToast dipakai di luar provider', () => {
    // Redam error React di console untuk uji ini
    const spy = vi.spyOn(console, 'error').mockImplementation(() => {});

    expect(() => render(<PemicuToast />)).toThrow(/ToastProvider/);

    spy.mockRestore();
  });
});
