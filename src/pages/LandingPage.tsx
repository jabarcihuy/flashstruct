import { useLayoutEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import gsap from 'gsap';
import { ArrowRight, ArrowUpRight, Check, RotateCcw } from 'lucide-react';
import { useJudulHalaman } from '@/lib/useJudulHalaman';
import { useDaftarModul } from '@/features/materi/hooks';
import { useProgres } from '@/features/progres/context';
import { LABEL_TOPIK } from '@/lib/constants';
import type { ModulRingkas, TopikModul } from '@/types/database';
import { useBahasa } from '@/app/BahasaProvider';

const PILIHAN = [30, 40, 50] as const;
const TOPIK: TopikModul[] = ['array', 'struct', 'pointer'];
const MODUL_PEMBUKA: Record<TopikModul, string> = {
  array: 'Dasar Array & Indeks',
  struct: 'Mendefinisikan Struct',
  pointer: 'Dasar Pointer & Alamat Memori',
};

/** Halaman publik. Navigasi belajar dan progres dimulai di /dashboard. */
export default function LandingPage() {
  const { bahasa } = useBahasa();
  const en = bahasa === 'en';
  useJudulHalaman(
    en
      ? 'FlashStruct — Understand, Remember, Prove Data Structures'
      : 'FlashStruct — Pahami, Hafalkan, Buktikan Struktur Data',
    true,
  );
  const { data: daftarModul } = useDaftarModul();
  const { progres } = useProgres();
  const [jawaban, setJawaban] = useState<number | null>(null);
  const demoRef = useRef<HTMLDivElement>(null);
  const adaProgres = Object.keys(progres.modul).length > 0;
  const mulaiKe = adaProgres ? '/dashboard' : '/materi/array-dasar';

  useLayoutEffect(() => {
    if (jawaban === null || !demoRef.current) return;
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

    const context = gsap.context(() => {
      gsap
        .timeline({ defaults: { ease: 'power3.out' } })
        .fromTo('.landing-memory-cell.is-target', { scale: 0.9 }, { scale: 1, duration: 0.35 })
        .fromTo(
          '.landing-feedback',
          { autoAlpha: 0, y: 12 },
          { autoAlpha: 1, y: 0, duration: 0.35 },
          '-=0.12',
        );
    }, demoRef);

    return () => context.revert();
  }, [jawaban]);

  return (
    <div className="landing-page">
      <section className="landing-hero container-wide">
        <div className="landing-hero-copy">
          <h1>
            {en ? 'You can write the code.' : 'Bisa menulis kodenya.'}
            <br />
            <span>{en ? 'Can you explain the result?' : 'Bisa menjelaskan hasilnya?'}</span>
          </h1>
          <p>
            {en
              ? 'Short practice to remember and test Arrays, Structs, and Pointers.'
              : 'Latihan singkat untuk mengingat dan menguji Array, Struct, dan Pointer.'}
          </p>
          <div className="landing-hero-actions">
            <Link to={mulaiKe} className="landing-primary-action">
              {adaProgres
                ? en
                  ? 'Continue learning'
                  : 'Lanjutkan belajar'
                : en
                  ? 'Start learning'
                  : 'Mulai belajar'}
              <ArrowRight size={18} aria-hidden="true" />
            </Link>
            <a href="#cara-kerja" className="landing-text-action">
              {en ? 'See how it works' : 'Lihat cara belajar'}{' '}
              <ArrowRight size={16} aria-hidden="true" />
            </a>
          </div>
        </div>

        <div className="landing-demo" ref={demoRef}>
          <div className="landing-demo-top">
            <span>
              {en ? 'A quick example from the Array module' : 'Contoh singkat dari modul Array'}
            </span>
            <span>C++</span>
          </div>
          <div className="landing-demo-body">
            <h2>{en ? 'What gets printed?' : 'Apa hasil yang dicetak?'}</h2>
            <pre className="landing-code" aria-label="Contoh kode C++">
              <code>
                {'int nilai[5] = {10, 20, 30, 40, 50};\nint* p = nilai;\ncout << *(p + 3);'}
              </code>
            </pre>
            <div
              className="landing-memory"
              aria-label={
                en
                  ? 'Array values, indices zero through four'
                  : 'Isi Array nilai, indeks nol sampai empat'
              }
            >
              {[10, 20, 30, 40, 50].map((nilai, indeks) => (
                <div
                  key={nilai}
                  className={`landing-memory-cell ${jawaban !== null && indeks === 3 ? 'is-target' : ''}`}
                >
                  <span>{indeks}</span>
                  <strong>{nilai}</strong>
                </div>
              ))}
            </div>
            <div
              className="landing-question-actions"
              role="group"
              aria-label={en ? 'Choose the code output' : 'Pilih hasil kode'}
            >
              {PILIHAN.map((nilai) => (
                <button
                  key={nilai}
                  type="button"
                  onClick={() => setJawaban(nilai)}
                  aria-pressed={jawaban === nilai}
                  className={jawaban === nilai ? 'is-selected' : ''}
                >
                  {nilai}
                </button>
              ))}
            </div>
            {jawaban !== null ? (
              <div className="landing-feedback" role="status" aria-live="polite">
                <div className="landing-feedback-heading">
                  <strong>
                    {jawaban === 40
                      ? en
                        ? 'Correct. The result is 40.'
                        : 'Tepat. Hasilnya 40.'
                      : en
                        ? 'The result is 40.'
                        : 'Hasilnya 40.'}
                  </strong>
                  {jawaban === 40 && <Check size={17} aria-hidden="true" />}
                </div>
                <p>
                  {en ? (
                    <>
                      {' '}
                      <code>p</code> points to index 0. <code>p + 3</code> moves to index 3, then{' '}
                      <code>*(p + 3)</code> reads its value: 40.
                    </>
                  ) : (
                    <>
                      {' '}
                      <code>p</code> menunjuk indeks 0. <code>p + 3</code> berpindah ke indeks 3,
                      lalu <code>*(p + 3)</code> membaca nilainya: 40.
                    </>
                  )}
                </p>
                <button type="button" onClick={() => setJawaban(null)}>
                  <RotateCcw size={14} aria-hidden="true" /> {en ? 'Try again' : 'Coba lagi'}
                </button>
              </div>
            ) : (
              <p className="landing-demo-hint">
                {en
                  ? 'Choose an answer to see the explanation.'
                  : 'Pilih jawaban untuk melihat penjelasannya.'}
              </p>
            )}
          </div>
        </div>
      </section>

      <section className="landing-path" id="cara-kerja">
        <div className="container-wide">
          <div className="landing-section-heading">
            <h2>{en ? 'Remember, then prove it.' : 'Hafalkan, lalu buktikan.'}</h2>
          </div>
          <div className="landing-stage-list">
            <article className="landing-stage-row">
              <span className="landing-stage-number">1</span>
              <div>
                <h3>{en ? 'Remember' : 'Hafalkan'}</h3>
                <p>
                  {en
                    ? 'Test your memory with flashcards. Mark what you forgot or remembered, then review what needs work.'
                    : 'Uji ingatan dengan flashcard. Tandai Lupa atau Ingat, lalu ulangi yang belum kuat.'}
                </p>
              </div>
              <span className="landing-stage-proof">
                {en ? 'Flashcards & review' : 'Flashcard & pengulangan'}
              </span>
            </article>
            <article className="landing-stage-row">
              <span className="landing-stage-number">2</span>
              <div>
                <h3>{en ? 'Prove it' : 'Buktikan'}</h3>
                <p>
                  {en
                    ? 'Take quizzes and read the explanations to find gaps in your understanding.'
                    : 'Kerjakan quiz dan baca penjelasan jawabannya untuk menemukan celah pemahaman.'}
                </p>
              </div>
              <span className="landing-stage-proof">
                {en ? 'Quizzes & feedback' : 'Quiz & umpan balik'}
              </span>
            </article>
          </div>
        </div>
      </section>

      <section className="landing-curriculum container-wide" id="kurikulum">
        <div className="landing-section-heading">
          <h2>
            {en
              ? 'Start with concepts you will keep using.'
              : 'Mulai dari konsep yang akan terus kamu pakai.'}
          </h2>
          <p>
            {en
              ? 'Arrays build intuition for indices and memory. Structs organize data. Pointers connect values to their addresses.'
              : 'Array menyiapkan cara berpikir tentang indeks dan memori. Struct menyusun data. Pointer menghubungkan nilai dengan alamatnya.'}
          </p>
        </div>
        <div className="landing-topic-list">
          {TOPIK.map((topik) => (
            <TopicRow key={topik} topik={topik} modul={daftarModul ?? []} />
          ))}
        </div>
        <Link to="/materi" className="landing-inline-link">
          {en ? 'Explore all lessons' : 'Lihat seluruh materi'}{' '}
          <ArrowUpRight size={17} aria-hidden="true" />
        </Link>
      </section>

      <section className="landing-close">
        <div className="container-wide landing-close-inner">
          <div>
            <h2>
              {en
                ? 'Learn in sequence. Review until it sticks.'
                : 'Belajar berurutan. Ulangi sampai ingat.'}
            </h2>
          </div>
          <Link to={mulaiKe} className="landing-primary-action">
            {adaProgres
              ? en
                ? 'Resume learning'
                : 'Kembali belajar'
              : en
                ? 'Start with the first module'
                : 'Mulai dari modul pertama'}
            <ArrowRight size={18} aria-hidden="true" />
          </Link>
        </div>
      </section>

      <footer className="landing-footer container-wide">
        <div>
          <strong>FlashStruct</strong>
          <p>
            {en
              ? 'Learn data structures, one concept at a time.'
              : 'Belajar Struktur Data, satu konsep pada satu waktu.'}
          </p>
        </div>
        <div className="landing-footer-links">
          <Link to="/dashboard">{en ? 'App' : 'Aplikasi'}</Link>
          <Link to="/materi">{en ? 'Lessons' : 'Materi'}</Link>
          <Link to="/soal">{en ? 'Quizzes' : 'Soal'}</Link>
        </div>
      </footer>
    </div>
  );
}

function TopicRow({ topik, modul }: { topik: TopikModul; modul: ModulRingkas[] }) {
  const dalamTopik = modul.filter((item) => item.topik === topik);
  const pertama = dalamTopik[0];

  return (
    <Link to={`/materi#${topik}`} className="landing-topic-row">
      <span className={`landing-topic-mark is-${topik}`} aria-hidden="true" />
      <span className="landing-topic-name">{LABEL_TOPIK[topik]}</span>
      <span className="landing-topic-detail">{pertama ? pertama.judul : MODUL_PEMBUKA[topik]}</span>
      <span className="landing-topic-count">
        {dalamTopik.length > 0 ? `${dalamTopik.length} modul` : null}
      </span>
      <ArrowUpRight size={18} aria-hidden="true" />
    </Link>
  );
}
