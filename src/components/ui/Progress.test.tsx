import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import {
  IndikatorTigaTahap,
  ProgressBar,
  ProgressRing,
  StatAngka,
  type StatusTahap,
} from './Progress';

describe('ProgressBar', () => {
  it('mengekspos nilai ke pembaca layar lewat role progressbar', () => {
    render(<ProgressBar nilai={3} maks={20} label="Kartu" />);
    const bar = screen.getByRole('progressbar', { name: 'Kartu' });
    expect(bar).toHaveAttribute('aria-valuenow', '3');
    expect(bar).toHaveAttribute('aria-valuemin', '0');
    expect(bar).toHaveAttribute('aria-valuemax', '20');
  });

  it('menampilkan label dan angka secara visual', () => {
    render(<ProgressBar nilai={3} maks={20} label="Kartu" />);
    expect(screen.getByText('Kartu')).toBeInTheDocument();
    expect(screen.getByText('3 / 20')).toBeInTheDocument();
  });

  it('menyembunyikan label visual bila diminta, tapi aria-label tetap ada', () => {
    render(<ProgressBar nilai={5} maks={10} label="Progres" tanpaLabelVisual />);
    expect(screen.queryByText('Progres')).not.toBeInTheDocument();
    expect(screen.getByRole('progressbar', { name: 'Progres' })).toBeInTheDocument();
  });

  it('tidak melebihi 100% walau nilai lebih besar dari maks', () => {
    render(<ProgressBar nilai={30} maks={20} label="Kartu" />);
    expect(screen.getByRole('progressbar')).toBeInTheDocument();
  });

  it('menangani maks bernilai 0 tanpa error', () => {
    render(<ProgressBar nilai={0} maks={0} label="Kosong" />);
    expect(screen.getByRole('progressbar', { name: 'Kosong' })).toBeInTheDocument();
  });
});

describe('ProgressRing', () => {
  it('mengekspos nilai ke pembaca layar', () => {
    render(
      <ProgressRing nilai={82} label="Deck dikuasai">
        <span>82%</span>
      </ProgressRing>,
    );
    const ring = screen.getByRole('progressbar', { name: 'Deck dikuasai' });
    expect(ring).toHaveAttribute('aria-valuenow', '82');
  });

  it('menampilkan konten di tengah ring', () => {
    render(
      <ProgressRing nilai={82} label="Deck dikuasai">
        <span>82%</span>
      </ProgressRing>,
    );
    expect(screen.getByText('82%')).toBeInTheDocument();
  });
});

describe('IndikatorTigaTahap', () => {
  const baru: [StatusTahap, StatusTahap, StatusTahap] = ['tersedia', 'terkunci', 'terkunci'];

  it('menampilkan tiga label tahap', () => {
    render(<IndikatorTigaTahap tahap={baru} />);
    expect(screen.getByText('Pahami')).toBeInTheDocument();
    expect(screen.getByText('Hafalkan')).toBeInTheDocument();
    expect(screen.getByText('Buktikan')).toBeInTheDocument();
  });

  it('memberi teks status untuk pembaca layar', () => {
    render(<IndikatorTigaTahap tahap={baru} />);
    // Tahap 1 tersedia, tahap 2 dan 3 terkunci
    expect(screen.getByText('belum selesai')).toBeInTheDocument();
    expect(screen.getAllByText('terkunci')).toHaveLength(2);
  });

  it('menandai tahap selesai dengan teks yang tepat', () => {
    render(<IndikatorTigaTahap tahap={['selesai', 'tersedia', 'terkunci']} />);
    expect(screen.getByText('selesai')).toBeInTheDocument();
  });

  it('tetap punya label untuk pembaca layar saat label visual dimatikan', () => {
    render(<IndikatorTigaTahap tahap={baru} denganLabel={false} />);
    expect(screen.getByText('Pahami')).toHaveClass('sr-only');
  });
});

describe('StatAngka', () => {
  it('menampilkan nilai dan label', () => {
    render(<StatAngka nilai={48} label="kartu dikuasai" />);
    expect(screen.getByText('48')).toBeInTheDocument();
    expect(screen.getByText('kartu dikuasai')).toBeInTheDocument();
  });

  it('menampilkan ajakan bertindak saat nilai 0', () => {
    render(<StatAngka nilai={0} label="modul selesai" ajakan="Mulai modul pertama" />);
    expect(screen.getByText('Mulai modul pertama')).toBeInTheDocument();
  });

  it('tidak menampilkan ajakan saat nilai bukan 0', () => {
    render(<StatAngka nilai={3} label="modul selesai" ajakan="Mulai modul pertama" />);
    expect(screen.queryByText('Mulai modul pertama')).not.toBeInTheDocument();
  });

  it('mengenali nilai string "0" sebagai kosong', () => {
    render(<StatAngka nilai="0" label="streak" ajakan="Mulai belajar" />);
    expect(screen.getByText('Mulai belajar')).toBeInTheDocument();
  });
});
