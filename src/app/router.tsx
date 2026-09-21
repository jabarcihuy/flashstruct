import { lazy } from 'react';
import { createBrowserRouter } from 'react-router-dom';
import { RootLayout } from '@/components/layout/RootLayout';

/**
 * Semua halaman dimuat lazy agar bundle awal tetap kecil.
 * Target: < 200 KB gzip untuk bundle awal (docs/README.md §Standar Kualitas).
 */
const HomePage = lazy(() => import('@/pages/HomePage'));
const DashboardPage = lazy(() => import('@/pages/DashboardPage'));
const MateriPage = lazy(() => import('@/pages/MateriPage'));
const ModulDetailPage = lazy(() => import('@/pages/ModulDetailPage'));
const VideoPage = lazy(() => import('@/pages/VideoPage'));
const SoalPage = lazy(() => import('@/pages/SoalPage'));
const FlashcardPage = lazy(() => import('@/pages/FlashcardPage'));
const QuizPage = lazy(() => import('@/pages/QuizPage'));
const NotFoundPage = lazy(() => import('@/pages/NotFoundPage'));

/**
 * Halaman demo komponen — HANYA untuk pengembangan.
 * Di build produksi rute ini tidak terdaftar, sehingga tidak
 * bisa diakses publik (lihat docs/08-CHECKLIST-QA.md §12.1).
 */
const DemoPage = import.meta.env.DEV ? lazy(() => import('@/pages/DemoPage')) : null;

/**
 * Catatan: createBrowserRouter dipakai (bukan HashRouter) agar URL bersih.
 * Vercel/Netlify perlu SPA rewrite — lihat vercel.json.
 * Jika deploy ke GitHub Pages, ganti ke createHashRouter.
 */
export const router = createBrowserRouter([
  {
    path: '/',
    element: <RootLayout />,
    children: [
      { index: true, element: <HomePage /> },
      { path: 'dashboard', element: <DashboardPage /> },
      { path: 'materi', element: <MateriPage /> },
      { path: 'materi/:slug', element: <ModulDetailPage /> },
      { path: 'video', element: <VideoPage /> },
      { path: 'soal', element: <SoalPage /> },
      { path: 'soal/flashcard/:slug', element: <FlashcardPage /> },
      { path: 'soal/quiz/:slug', element: <QuizPage /> },
      ...(DemoPage ? [{ path: 'demo', element: <DemoPage /> }] : []),
      { path: '*', element: <NotFoundPage /> },
    ],
  },
]);
