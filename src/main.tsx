import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { RouterProvider } from 'react-router-dom';
import { Providers } from './app/providers';
import { router } from './app/router';
import './styles/global.css';
/**
 * redesign.css diimpor TERPISAH, bukan lewat `@import` di global.css.
 *
 * Tailwind 4 memproses `@import` sendiri dan diam-diam menjatuhkan
 * berkas yang tidak dikenalnya — terverifikasi: `@import './redesign.css'`
 * menghasilkan 0 rule di browser. Impor lewat JavaScript membuat Vite
 * yang menanganinya, dan itu bekerja.
 */
import './styles/redesign.css';

const rootEl = document.getElementById('root');
if (!rootEl) throw new Error('Elemen #root tidak ditemukan di index.html');

createRoot(rootEl).render(
  <StrictMode>
    <Providers>
      <RouterProvider router={router} />
    </Providers>
  </StrictMode>,
);
