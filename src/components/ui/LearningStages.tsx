import { Check, Lock } from 'lucide-react';
import type { StatusTahap } from './Progress';

const LABEL = ['Pahami', 'Hafalkan', 'Buktikan'];
const PENJELASAN = ['Baca dan pahami materi dasar.', 'Ingat kembali konsep dengan flashcard.', 'Uji pemahamanmu melalui quiz.'];

/** Satu urutan yang sama di rekomendasi, materi, dan sesi belajar. */
export function LearningStages({ tahap, ringkas = false }: {
  tahap: [StatusTahap, StatusTahap, StatusTahap];
  ringkas?: boolean;
}) {
  return (
    <ol className={ringkas ? 'learning-stages compact' : 'learning-stages'} aria-label="Status tiga tahap">
      {tahap.map((status, i) => (
        <li key={LABEL[i]} data-status={status} title={`${LABEL[i]}: ${status}`}>
          <span className="stage-number" aria-hidden="true">
            {status === 'selesai' ? <Check size={16} /> : ringkas && status === 'terkunci' ? <Lock size={14} /> : i + 1}
          </span>
          {ringkas ? <span className="sr-only">{LABEL[i]}: {status}</span> : <>
            <strong>{LABEL[i]} {status === 'terkunci' && <Lock size={13} aria-label="Terkunci" />}</strong>
            <span className="stage-description">{status === 'terkunci' ? `Selesaikan ${LABEL[i - 1]} untuk membuka.` : status === 'selesai' ? 'Sudah selesai. Bisa diulang kapan saja.' : PENJELASAN[i]}</span>
          </>}
        </li>
      ))}
    </ol>
  );
}
