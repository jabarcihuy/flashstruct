import { ArrowLeft, ArrowRight, Lock } from 'lucide-react';
import { Link } from 'react-router-dom';
import { LearningStages } from './LearningStages';
import type { StatusTahap } from './Progress';
import { useBahasa } from '@/app/BahasaProvider';

interface StageGateProps {
  judul: string;
  modulJudul?: string;
  alasan: string;
  penjelasan: string;
  aksiLabel: string;
  aksiKe: string;
  tahap: [StatusTahap, StatusTahap, StatusTahap];
}

/** Jalan kembali ke tahap yang tersedia, sama untuk Flashcard dan Quiz. */
export function StageGate({
  judul,
  modulJudul,
  alasan,
  penjelasan,
  aksiLabel,
  aksiKe,
  tahap,
}: StageGateProps) {
  const { bahasa } = useBahasa();
  const en = bahasa === 'en';
  return (
    <div className="container-base stage-gate">
      <Link to="/soal" className="stage-gate-back">
        <ArrowLeft className="size-4" aria-hidden="true" />
        {en ? 'Quiz list' : 'Daftar soal'}
      </Link>
      <div className="stage-gate-layout">
        <div className="stage-gate-copy">
          <div className="stage-gate-lock" aria-hidden="true">
            <Lock className="size-6" />
          </div>
          <h1>{judul}</h1>
          <p className="stage-gate-reason">
            {modulJudul ? <strong>{modulJudul} — </strong> : null}
            {alasan}
          </p>
          <p className="stage-gate-detail">{penjelasan}</p>
          <div className="stage-gate-actions">
            <Link to={aksiKe} className="stage-gate-primary">
              {aksiLabel}
              <ArrowRight className="size-4" aria-hidden="true" />
            </Link>
            <Link to="/soal" className="stage-gate-secondary">
              {en ? 'Back to quizzes' : 'Kembali ke Soal'}
            </Link>
          </div>
        </div>
        <section className="stage-gate-overview">
          <h2>{en ? 'Learning path for this module' : 'Urutan belajar modul ini'}</h2>
          <p>
            {en
              ? 'Each stage unlocks the next. Continue with the available step.'
              : 'Setiap tahap membuka tahap berikutnya. Lanjutkan dari langkah yang tersedia.'}
          </p>
          <LearningStages tahap={tahap} />
        </section>
      </div>
    </div>
  );
}
