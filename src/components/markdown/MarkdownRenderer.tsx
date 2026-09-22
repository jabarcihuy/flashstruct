import { Children, isValidElement, type ReactNode } from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { CodeBlock } from '@/components/code/CodeBlock';
import { Callout } from './Callout';
import { slugHeading, tipeDariPenanda } from './util';

/**
 * Renderer markdown untuk konten modul.
 *
 * Menangani:
 *   - Blok kode dengan pewarnaan sintaks (Shiki)
 *   - Callout lewat sintaks `> [!INFO]` dan sejenisnya
 *   - Tabel (lewat remark-gfm — tabel BUKAN bagian dari markdown standar)
 *   - Heading dengan id agar bisa ditautkan dari daftar isi
 *
 * Sintaks callout dipilih karena tetap valid sebagai markdown biasa —
 * kalau penanganan gagal, ia tetap tampil sebagai kutipan, bukan teks
 * rusak.
 *
 * Catatan penting: react-markdown TIDAK mengaktifkan tabel secara
 * default. Tabel butuh plugin remark-gfm.
 */

/** Ambil teks dari children React */
function teksDari(node: ReactNode): string {
  if (typeof node === 'string') return node;
  if (typeof node === 'number') return String(node);
  if (Array.isArray(node)) return node.map(teksDari).join('');
  if (isValidElement<{ children?: ReactNode }>(node)) return teksDari(node.props.children);
  return '';
}

interface MarkdownRendererProps {
  konten: string;
  className?: string;
}

export function MarkdownRenderer({ konten, className }: MarkdownRendererProps) {
  return (
    <div className={className}>
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        components={{
          /* ---------- Heading dengan id ---------- */
          h2: ({ children }) => {
            const id = slugHeading(teksDari(children));
            return (
              <h2
                id={id}
                className="mt-10 mb-4 scroll-mt-20 font-heading text-2xl font-semibold text-fg"
              >
                {children}
              </h2>
            );
          },
          h3: ({ children }) => {
            const id = slugHeading(teksDari(children));
            return (
              <h3
                id={id}
                className="mt-8 mb-3 scroll-mt-20 font-heading text-xl font-semibold text-fg"
              >
                {children}
              </h3>
            );
          },
          h4: ({ children }) => (
            <h4 className="mt-6 mb-2 scroll-mt-20 font-semibold text-fg">{children}</h4>
          ),

          /* ---------- Paragraf dan daftar ---------- */
          p: ({ children }) => <p className="my-4 leading-relaxed text-fg">{children}</p>,
          ul: ({ children }) => (
            <ul className="my-4 list-disc space-y-2 pl-6 text-fg">{children}</ul>
          ),
          ol: ({ children }) => (
            <ol className="my-4 list-decimal space-y-2 pl-6 text-fg">{children}</ol>
          ),
          li: ({ children }) => <li className="leading-relaxed">{children}</li>,

          /* ---------- Penekanan ---------- */
          strong: ({ children }) => <strong className="font-semibold text-fg">{children}</strong>,
          em: ({ children }) => <em className="italic">{children}</em>,

          /* ---------- Tautan ---------- */
          a: ({ href, children }) => (
            <a
              href={href}
              target={href?.startsWith('http') ? '_blank' : undefined}
              rel={href?.startsWith('http') ? 'noopener noreferrer' : undefined}
              className="text-primary underline underline-offset-2"
            >
              {children}
            </a>
          ),

          /* ---------- Blok kode ---------- */
          pre: ({ children }) => {
            // react-markdown membungkus code dalam pre. Kita ambil
            // isinya dan render lewat CodeBlock agar ada pewarnaan
            // dan tombol salin.
            const anak = Children.toArray(children)[0];
            if (isValidElement<{ className?: string; children?: ReactNode }>(anak)) {
              const kelas = anak.props.className ?? '';
              const cocok = /language-(\w+)/.exec(kelas);
              const bahasa = cocok?.[1];
              const isi = teksDari(anak.props.children).replace(/\n$/, '');
              return <CodeBlock kode={isi} bahasa={bahasa} />;
            }
            return <pre>{children}</pre>;
          },

          /* Kode inline — biarkan default, hanya atur gayanya */
          code: ({ className, children }) => {
            // Blok kode ditangani oleh `pre` di atas
            if (className?.includes('language-')) {
              return <code className={className}>{children}</code>;
            }
            return (
              <code className="rounded bg-surface-raised px-1.5 py-0.5 font-mono text-[0.9em] text-fg">
                {children}
              </code>
            );
          },

          /* ---------- Kutipan dan callout ---------- */
          blockquote: ({ children }) => {
            /*
             * Deteksi callout.
             *
             * Sintaks yang didukung:
             *   > [!INFO]
             *   > isi pesan
             *
             * react-markdown mengubahnya menjadi blockquote yang berisi
             * satu atau lebih paragraf. Penanda [!TIPE] bisa berada:
             *   a) di paragraf yang sama dengan isinya
             *   b) di paragraf terpisah (karena baris baru setelah penanda)
             *
             * Keduanya harus ditangani.
             */
            const anakArray = Children.toArray(children);

            // Kumpulkan seluruh teks dari blockquote
            const teksLengkap = teksDari(anakArray);

            const cocok = /^\s*\[!(\w+)\]\s*/.exec(teksLengkap);
            if (cocok) {
              const tipe = tipeDariPenanda(cocok[1] ?? '');
              if (tipe) {
                // Buang penanda dari teks, lalu render sisanya
                const sisaTeks = teksLengkap.replace(cocok[0], '').trim();
                return (
                  <Callout tipe={tipe}>
                    {sisaTeks ? <p>{sisaTeks}</p> : null}
                  </Callout>
                );
              }
            }

            // Kutipan biasa
            return (
              <blockquote className="my-5 border-l-2 border-border-strong/50 pl-4 italic text-fg-muted">
                {children}
              </blockquote>
            );
          },

          /* ---------- Tabel (bisa di-scroll di mobile) ---------- */
          table: ({ children }) => (
            <div className="my-5 overflow-x-auto">
              <table className="w-full border-collapse text-sm">{children}</table>
            </div>
          ),
          th: ({ children }) => (
            <th className="border border-border bg-surface-raised px-3 py-2 text-left font-semibold text-fg">
              {children}
            </th>
          ),
          td: ({ children }) => (
            <td className="border border-border px-3 py-2 text-fg">{children}</td>
          ),

          /* ---------- Garis pemisah ---------- */
          hr: () => <hr className="my-8 border-border" />,
        }}
      >
        {konten}
      </ReactMarkdown>
    </div>
  );
}
