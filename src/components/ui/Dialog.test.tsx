import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useState } from 'react';
import { Dialog } from './Dialog';

/** Dialog terkontrol untuk pengujian */
function DialogUji({ onTutup }: { onTutup?: () => void } = {}) {
  const [terbuka, setTerbuka] = useState(false);
  return (
    <>
      <button onClick={() => setTerbuka(true)}>Buka</button>
      <Dialog
        terbuka={terbuka}
        onTutup={() => {
          setTerbuka(false);
          onTutup?.();
        }}
        judul="Judul Dialog"
        deskripsi="Deskripsi dialog"
      >
        <button>Tombol Isi</button>
      </Dialog>
    </>
  );
}

describe('Dialog', () => {
  it('tidak merender apa pun saat tertutup', () => {
    render(<DialogUji />);
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('merender dialog saat dibuka', async () => {
    const user = userEvent.setup();
    render(<DialogUji />);

    await user.click(screen.getByRole('button', { name: 'Buka' }));

    expect(screen.getByRole('dialog')).toBeInTheDocument();
    expect(screen.getByText('Judul Dialog')).toBeInTheDocument();
    expect(screen.getByText('Deskripsi dialog')).toBeInTheDocument();
  });

  it('menandai dialog sebagai modal', async () => {
    const user = userEvent.setup();
    render(<DialogUji />);
    await user.click(screen.getByRole('button', { name: 'Buka' }));

    const dialog = screen.getByRole('dialog');
    expect(dialog).toHaveAttribute('aria-modal', 'true');
    expect(dialog).toHaveAttribute('aria-labelledby', 'judul-dialog');
    expect(dialog).toHaveAttribute('aria-describedby', 'deskripsi-dialog');
  });

  it('menutup dialog saat Escape ditekan', async () => {
    const user = userEvent.setup();
    const onTutup = vi.fn();
    render(<DialogUji onTutup={onTutup} />);

    await user.click(screen.getByRole('button', { name: 'Buka' }));
    await user.keyboard('{Escape}');

    expect(onTutup).toHaveBeenCalled();
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('menutup dialog saat tombol tutup diklik', async () => {
    const user = userEvent.setup();
    render(<DialogUji />);

    await user.click(screen.getByRole('button', { name: 'Buka' }));
    await user.click(screen.getByRole('button', { name: 'Tutup dialog' }));

    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('menyembunyikan tombol tutup bila diminta', async () => {
    const user = userEvent.setup();
    render(
      <DialogUjiKhusus tanpaTombolTutup />,
    );
    await user.click(screen.getByRole('button', { name: 'Buka' }));

    expect(screen.queryByRole('button', { name: 'Tutup dialog' })).not.toBeInTheDocument();
  });

  it('mengunci scroll body saat terbuka dan memulihkannya saat tertutup', async () => {
    const user = userEvent.setup();
    render(<DialogUji />);

    const overflowAwal = document.body.style.overflow;

    await user.click(screen.getByRole('button', { name: 'Buka' }));
    expect(document.body.style.overflow).toBe('hidden');

    await user.keyboard('{Escape}');
    expect(document.body.style.overflow).toBe(overflowAwal);
  });
});

function DialogUjiKhusus({ tanpaTombolTutup }: { tanpaTombolTutup?: boolean }) {
  const [terbuka, setTerbuka] = useState(false);
  return (
    <>
      <button onClick={() => setTerbuka(true)}>Buka</button>
      <Dialog
        terbuka={terbuka}
        onTutup={() => setTerbuka(false)}
        judul="Tanpa Tombol Tutup"
        tanpaTombolTutup={tanpaTombolTutup}
      >
        <p>Isi</p>
      </Dialog>
    </>
  );
}
