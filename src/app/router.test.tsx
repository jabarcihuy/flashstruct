import { describe, it, expect, beforeEach, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import { createMemoryRouter, RouterProvider } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { RootLayout } from '@/components/layout/RootLayout';
import { LandingLayout } from '@/components/layout/LandingLayout';
import LandingPage from '@/pages/LandingPage';
import DashboardPage from '@/pages/DashboardPage';
import MateriPage from '@/pages/MateriPage';
import ModulDetailPage from '@/pages/ModulDetailPage';
import VideoPage from '@/pages/VideoPage';
import SoalPage from '@/pages/SoalPage';
import FlashcardPage from '@/pages/FlashcardPage';
import QuizPage from '@/pages/QuizPage';
import NotFoundPage from '@/pages/NotFoundPage';
import { TemaProvider } from '@/app/TemaProvider';
import { ProgresProvider } from '@/features/progres/ProgresProvider';

/**
 * Uji rute: setiap rute harus merender halaman yang tepat.
 *
 * Catatan: memakai createMemoryRouter (bukan createBrowserRouter) karena
 * jsdom tidak punya riwayat browser sungguhan.
 */

/**
 * Mock Supabase client.
 *
 * Halaman Materi dan Flashcard butuh kredensial dan koneksi database.
 * Untuk uji routing, yang diuji hanya "apakah rute merender halaman yang
 * benar", bukan apakah database mengembalikan data. Jadi Supabase
 * di-mock agar uji tidak bergantung pada jaringan atau kredensial.
 *
 * Mock ini meniru rantai builder PostgREST: from().select().eq().order()
 * dan variasinya, semuanya mengembalikan data kosong.
 */
vi.mock('@/lib/supabase', () => {
  /** Builder yang bisa dirantai, selalu mengembalikan data kosong */
  function buatBuilder() {
    const hasil = { data: [], error: null };

    const builder: Record<string, unknown> = {
      select: () => builder,
      eq: () => builder,
      order: () => builder,
      limit: () => builder,
      single: () => Promise.resolve({ data: null, error: null }),
      maybeSingle: () => Promise.resolve({ data: null, error: null }),
      // Agar `await builder` menghasilkan data kosong
      then: (resolve: (v: unknown) => unknown) => Promise.resolve(hasil).then(resolve),
    };

    return builder;
  }

  return {
    supabase: {
      from: () => buatBuilder(),
    },
  };
});

function renderRute(initialPath: string) {
  const router = createMemoryRouter(
    [
      {
        path: '/',
        element: <LandingLayout />,
        children: [{ index: true, element: <LandingPage /> }],
      },
      {
        element: <RootLayout />,
        children: [
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
        <ProgresProvider>
          <RouterProvider router={router} />
        </ProgresProvider>
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
    expect(
      await screen.findByRole('heading', { level: 1, name: /bisa menulis kodenya/i }),
    ).toBeInTheDocument();
  });

  it('memisahkan navigasi landing dari navigasi aplikasi', async () => {
    renderRute('/');
    expect(await screen.findByRole('navigation', { name: 'Navigasi landing' })).toBeInTheDocument();
    expect(screen.queryByRole('navigation', { name: 'Navigasi utama' })).not.toBeInTheDocument();
    expect(screen.getByRole('link', { name: /buka aplikasi/i })).toHaveAttribute(
      'href',
      '/dashboard',
    );
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
    // Mock Supabase mengembalikan data null, jadi halaman menampilkan
    // empty state "Modul tidak ditemukan" — yang penting rutenya
    // merender halaman detail, bukan 404.
    expect(await screen.findByText(/modul tidak ditemukan/i)).toBeInTheDocument();
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
    // Mock Supabase mengembalikan data kosong, jadi halaman menampilkan
    // empty state "belum punya kartu" — yang penting rutenya merender
    // halaman flashcard, bukan 404.
    expect(await screen.findByText(/belum punya kartu/i)).toBeInTheDocument();
  });

  it('merender Quiz di rute /soal/quiz/:slug', async () => {
    renderRute('/soal/quiz/array-dasar');
    // Mock Supabase mengembalikan data kosong, jadi modul tidak ditemukan
    // dan halaman menampilkan penguncian. Yang penting rutenya merender
    // halaman quiz, bukan 404.
    expect(await screen.findByText(/quiz masih terkunci/i)).toBeInTheDocument();
  });

  it('merender halaman 404 untuk rute yang tidak dikenal', async () => {
    renderRute('/rute-yang-tidak-ada');
    expect(
      await screen.findByRole('heading', { name: /halaman tidak ditemukan/i }),
    ).toBeInTheDocument();
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
    renderRute('/dashboard');
    await screen.findByRole('heading', { level: 1 });
    const navs = screen.getAllByRole('navigation', { name: /navigasi utama/i });
    expect(navs.length).toBeGreaterThan(0);
  });
});
