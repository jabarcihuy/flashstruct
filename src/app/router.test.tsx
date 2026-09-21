import { describe, it, expect, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { createMemoryRouter, RouterProvider } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { RootLayout } from '@/components/layout/RootLayout';
import HomePage from '@/pages/HomePage';
import DashboardPage from '@/pages/DashboardPage';
import MateriPage from '@/pages/MateriPage';
import ModulDetailPage from '@/pages/ModulDetailPage';
import VideoPage from '@/pages/VideoPage';
import SoalPage from '@/pages/SoalPage';
import FlashcardPage from '@/pages/FlashcardPage';
import QuizPage from '@/pages/QuizPage';
import NotFoundPage from '@/pages/NotFoundPage';
import { TemaProvider } from '@/app/TemaProvider';

/**
 * Uji rute: setiap rute harus merender halaman yang tepat.
 *
 * Catatan: memakai createMemoryRouter (bukan createBrowserRouter) karena
 * jsdom tidak punya riwayat browser sungguhan.
 */

function renderRute(initialPath: string) {
  const router = createMemoryRouter(
    [
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
          { path: '*', element: <NotFoundPage /> },
        ],
      },
    ],
    { initialEntries: [initialPath] },
  );

  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });

  return render(
    <QueryClientProvider client={queryClient}>
      <TemaProvider>
        <RouterProvider router={router} />
      </TemaProvider>
    </QueryClientProvider>,
  );
}

beforeEach(() => {
  localStorage.clear();
  document.documentElement.removeAttribute('data-theme');
});

describe('routing', () => {
  it('merender Home di rute /', async () => {
    renderRute('/');
    expect(await screen.findByRole('heading', { level: 1, name: /hafal dulu/i })).toBeInTheDocument();
  });

  it('merender Dashboard di rute /dashboard', async () => {
    renderRute('/dashboard');
    expect(await screen.findByRole('heading', { level: 1, name: 'Dashboard' })).toBeInTheDocument();
  });

  it('merender daftar Materi di rute /materi', async () => {
    renderRute('/materi');
    expect(await screen.findByRole('heading', { level: 1, name: 'Materi' })).toBeInTheDocument();
  });

  it('merender detail modul di rute /materi/:slug', async () => {
    renderRute('/materi/array-dasar');
    expect(await screen.findByRole('heading', { level: 1, name: /detail modul/i })).toBeInTheDocument();
  });

  it('merender Video di rute /video', async () => {
    renderRute('/video');
    expect(await screen.findByRole('heading', { level: 1, name: 'Video' })).toBeInTheDocument();
  });

  it('merender Soal di rute /soal', async () => {
    renderRute('/soal');
    expect(await screen.findByRole('heading', { level: 1, name: 'Soal' })).toBeInTheDocument();
  });

  it('merender Flashcard di rute /soal/flashcard/:slug', async () => {
    renderRute('/soal/flashcard/array-dasar');
    expect(await screen.findByRole('heading', { level: 1, name: 'Flashcard' })).toBeInTheDocument();
  });

  it('merender Quiz di rute /soal/quiz/:slug', async () => {
    renderRute('/soal/quiz/array-dasar');
    expect(await screen.findByRole('heading', { level: 1, name: 'Quiz' })).toBeInTheDocument();
  });

  it('merender halaman 404 untuk rute yang tidak dikenal', async () => {
    renderRute('/rute-yang-tidak-ada');
    expect(await screen.findByRole('heading', { name: /halaman tidak ditemukan/i })).toBeInTheDocument();
  });
});

describe('kerangka halaman', () => {
  it('menyediakan skip link untuk pengguna keyboard', async () => {
    renderRute('/');
    const skipLink = await screen.findByRole('link', { name: /lewati ke konten utama/i });
    expect(skipLink).toHaveAttribute('href', '#konten-utama');
  });

  it('menyediakan landmark main', async () => {
    renderRute('/');
    await screen.findByRole('heading', { level: 1 });
    expect(document.querySelector('main#konten-utama')).toBeInTheDocument();
  });

  it('menyediakan navigasi utama', async () => {
    renderRute('/');
    await screen.findByRole('heading', { level: 1 });
    const navs = screen.getAllByRole('navigation', { name: /navigasi utama/i });
    expect(navs.length).toBeGreaterThan(0);
  });
});
