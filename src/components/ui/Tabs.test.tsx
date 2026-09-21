import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Tabs } from './Tabs';

const ITEM = [
  { nilai: 'cpp', label: 'C++', konten: <p>Kode C++</p> },
  { nilai: 'python', label: 'Python', konten: <p>Kode Python</p> },
];

describe('Tabs', () => {
  it('menampilkan tab pertama sebagai aktif secara default', () => {
    render(<Tabs item={ITEM} />);
    expect(screen.getByRole('tab', { name: 'C++' })).toHaveAttribute('aria-selected', 'true');
    expect(screen.getByText('Kode C++')).toBeInTheDocument();
  });

  it('mengganti panel saat tab diklik', async () => {
    const user = userEvent.setup();
    render(<Tabs item={ITEM} />);

    await user.click(screen.getByRole('tab', { name: 'Python' }));

    expect(screen.getByText('Kode Python')).toBeInTheDocument();
    expect(screen.queryByText('Kode C++')).not.toBeInTheDocument();
  });

  it('hanya tab aktif yang bisa dijangkau Tab', () => {
    render(<Tabs item={ITEM} />);
    expect(screen.getByRole('tab', { name: 'C++' })).toHaveAttribute('tabindex', '0');
    expect(screen.getByRole('tab', { name: 'Python' })).toHaveAttribute('tabindex', '-1');
  });

  it('menghubungkan tab dengan panelnya lewat aria', () => {
    render(<Tabs item={ITEM} />);
    const tab = screen.getByRole('tab', { name: 'C++' });
    const panel = screen.getByRole('tabpanel');
    expect(tab).toHaveAttribute('aria-controls', panel.id);
    expect(panel).toHaveAttribute('aria-labelledby', tab.id);
  });

  it('berpindah tab dengan panah kanan', async () => {
    const user = userEvent.setup();
    render(<Tabs item={ITEM} />);

    screen.getByRole('tab', { name: 'C++' }).focus();
    await user.keyboard('{ArrowRight}');

    expect(screen.getByRole('tab', { name: 'Python' })).toHaveAttribute('aria-selected', 'true');
  });

  it('berpindah tab dengan panah kiri dan memutar kembali ke akhir', async () => {
    const user = userEvent.setup();
    render(<Tabs item={ITEM} />);

    screen.getByRole('tab', { name: 'C++' }).focus();
    await user.keyboard('{ArrowLeft}');

    expect(screen.getByRole('tab', { name: 'Python' })).toHaveAttribute('aria-selected', 'true');
  });

  it('melompat ke tab terakhir dengan End', async () => {
    const user = userEvent.setup();
    render(<Tabs item={ITEM} />);

    screen.getByRole('tab', { name: 'C++' }).focus();
    await user.keyboard('{End}');

    expect(screen.getByRole('tab', { name: 'Python' })).toHaveAttribute('aria-selected', 'true');
  });

  it('melompat ke tab pertama dengan Home', async () => {
    const user = userEvent.setup();
    render(<Tabs item={ITEM} awal="python" />);

    screen.getByRole('tab', { name: 'Python' }).focus();
    await user.keyboard('{Home}');

    expect(screen.getByRole('tab', { name: 'C++' })).toHaveAttribute('aria-selected', 'true');
  });

  it('menghormati nilai awal yang diberikan', () => {
    render(<Tabs item={ITEM} awal="python" />);
    expect(screen.getByRole('tab', { name: 'Python' })).toHaveAttribute('aria-selected', 'true');
    expect(screen.getByText('Kode Python')).toBeInTheDocument();
  });
});
