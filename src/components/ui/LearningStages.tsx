import { Check, Lock } from 'lucide-react';
import type { StatusTahap } from './Progress';
import { useBahasa } from '@/app/BahasaProvider';

const LABEL = ['Pahami', 'Hafalkan', 'Buktikan'];
const PENJELASAN = [
  'Baca dan pahami materi dasar.',
  'Ingat kembali konsep dengan flashcard.',
  'Uji pemahamanmu melalui quiz.',
];

/** Satu urutan yang sama di rekomendasi, materi, dan sesi belajar. */
export function LearningStages({
  tahap,
  ringkas = false,
}: {
  tahap: [StatusTahap, StatusTahap, StatusTahap];
  ringkas?: boolean;
}) {
  const { bahasa } = useBahasa();
  const labels = bahasa === 'en' ? ['Understand', 'Remember', 'Prove'] : LABEL;
  const descriptions =
    bahasa === 'en'
      ? [
          'Read and understand the core material.',
          'Recall concepts with flashcards.',
          'Test your understanding with a quiz.',
        ]
      : PENJELASAN;
  return (
    <ol
      className={ringkas ? 'learning-stages compact' : 'learning-stages'}
      aria-label={bahasa === 'en' ? 'Three-stage status' : 'Status tiga tahap'}
    >
      {tahap.map((status, i) => (
        <li key={labels[i]} data-status={status} title={`${labels[i]}: ${status}`}>
          <span className="stage-number" aria-hidden="true">
            {status === 'selesai' ? (
              <Check size={16} />
            ) : ringkas && status === 'terkunci' ? (
              <Lock size={14} />
            ) : (
              i + 1
            )}
          </span>
          {ringkas ? (
            <span className="sr-only">
              {labels[i]}: {status}
            </span>
          ) : (
            <>
              <strong>
                {labels[i]}{' '}
                {status === 'terkunci' && (
                  <Lock size={13} aria-label={bahasa === 'en' ? 'Locked' : 'Terkunci'} />
                )}
              </strong>
              <span className="stage-description">
                {status === 'terkunci'
                  ? bahasa === 'en'
                    ? `Complete ${labels[i - 1]} to unlock.`
                    : `Selesaikan ${labels[i - 1]} untuk membuka.`
                  : status === 'selesai'
                    ? bahasa === 'en'
                      ? 'Completed. You can review it anytime.'
                      : 'Sudah selesai. Bisa diulang kapan saja.'
                    : descriptions[i]}
              </span>
            </>
          )}
        </li>
      ))}
    </ol>
  );
}
