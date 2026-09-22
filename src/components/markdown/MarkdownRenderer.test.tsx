import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MarkdownRenderer } from './MarkdownRenderer';

/**
 * Uji MarkdownRenderer.
 *
 * Fokus pada hal yang mudah rusak:
 *   - Callout dikenali dari sintaks > [!TIPE]
 *   - Tabel dirender (butuh remark-gfm)
 *   - Blok kode dirender lewat CodeBlock
 *   - Heading punya id untuk anchor
 */

describe('MarkdownRenderer — callout', () => {
  it('merender callout INFO dari sintaks [!INFO]', () => {
    const md = '> [!INFO]\n> Indeks dimulai dari nol.';
    render(<MarkdownRenderer konten={md} />);

    expect(screen.getByRole('note')).toBeInTheDocument();
    expect(screen.getByText('Indeks dimulai dari nol.')).toBeInTheDocument();
  });

  it('merender callout PERHATIAN', () => {
    const md = '> [!PERHATIAN]\n> Ini jebakan umum.';
    render(<MarkdownRenderer konten={md} />);

    expect(screen.getByRole('note')).toBeInTheDocument();
    expect(screen.getByText('Perhatian')).toBeInTheDocument();
  });

  it('merender callout BAHAYA', () => {
    const md = '> [!BAHAYA]\n> Undefined behavior.';
    render(<MarkdownRenderer konten={md} />);

    expect(screen.getByText('Bahaya')).toBeInTheDocument();
  });

  it('merender callout TIPS', () => {
    const md = '> [!TIPS]\n> Ingat rumusnya.';
    render(<MarkdownRenderer konten={md} />);

    expect(screen.getByText('Tips')).toBeInTheDocument();
  });

  it('TIDAK menampilkan penanda mentah di layar', () => {
    const md = '> [!INFO]\n> Isi pesan.';
    render(<MarkdownRenderer konten={md} />);

    expect(screen.queryByText(/\[!INFO\]/)).not.toBeInTheDocument();
  });

  it('merender kutipan biasa sebagai blockquote, bukan callout', () => {
    const md = '> Ini kutipan biasa tanpa penanda.';
    const { container } = render(<MarkdownRenderer konten={md} />);

    expect(container.querySelector('blockquote')).toBeInTheDocument();
    expect(screen.queryByRole('note')).not.toBeInTheDocument();
  });
});

describe('MarkdownRenderer — tabel', () => {
  it('merender tabel markdown', () => {
    const md = `| Aspek | C++ |
|-------|-----|
| Ukuran | Tetap |`;
    render(<MarkdownRenderer konten={md} />);

    expect(screen.getByRole('table')).toBeInTheDocument();
    expect(screen.getByText('Aspek')).toBeInTheDocument();
    expect(screen.getByText('Tetap')).toBeInTheDocument();
  });

  it('membungkus tabel agar bisa scroll di mobile', () => {
    const md = `| A | B |
|---|---|
| 1 | 2 |`;
    const { container } = render(<MarkdownRenderer konten={md} />);

    const pembungkus = container.querySelector('table')?.parentElement;
    expect(pembungkus?.className).toContain('overflow-x-auto');
  });
});

describe('MarkdownRenderer — heading', () => {
  it('memberi id pada h2 agar bisa ditautkan', () => {
    const md = '## Apa Itu Array';
    render(<MarkdownRenderer konten={md} />);

    const h2 = screen.getByRole('heading', { level: 2 });
    expect(h2).toHaveAttribute('id', 'apa-itu-array');
  });

  it('memberi id pada h3', () => {
    const md = '### Contoh Kode';
    render(<MarkdownRenderer konten={md} />);

    const h3 = screen.getByRole('heading', { level: 3 });
    expect(h3).toHaveAttribute('id', 'contoh-kode');
  });
});

describe('MarkdownRenderer — elemen dasar', () => {
  it('merender paragraf', () => {
    render(<MarkdownRenderer konten="Ini paragraf." />);
    expect(screen.getByText('Ini paragraf.')).toBeInTheDocument();
  });

  it('merender list tidak berurut', () => {
    render(<MarkdownRenderer konten={'- Satu\n- Dua'} />);
    expect(screen.getAllByRole('listitem')).toHaveLength(2);
  });

  it('merender list berurut', () => {
    render(<MarkdownRenderer konten={'1. Satu\n2. Dua'} />);
    expect(screen.getAllByRole('listitem')).toHaveLength(2);
  });

  it('merender teks tebal', () => {
    render(<MarkdownRenderer konten="Ini **penting**." />);
    expect(screen.getByText('penting')).toBeInTheDocument();
  });

  it('merender kode inline', () => {
    const { container } = render(<MarkdownRenderer konten="Pakai `arr[0]` untuk elemen pertama." />);
    const kode = container.querySelector('code');
    expect(kode).toBeInTheDocument();
    expect(kode?.textContent).toBe('arr[0]');
  });

  it('membuka tautan luar di tab baru dengan rel aman', () => {
    render(<MarkdownRenderer konten="[Situs](https://example.com)" />);
    const tautan = screen.getByRole('link');

    expect(tautan).toHaveAttribute('target', '_blank');
    expect(tautan).toHaveAttribute('rel', 'noopener noreferrer');
  });

  it('tidak membuka tautan internal di tab baru', () => {
    render(<MarkdownRenderer konten="[Materi](/materi)" />);
    const tautan = screen.getByRole('link');

    expect(tautan).not.toHaveAttribute('target');
  });
});
