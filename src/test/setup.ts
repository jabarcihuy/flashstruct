import '@testing-library/jest-dom/vitest';

/**
 * jsdom belum mengimplementasikan beberapa API browser.
 * Beri stub agar tidak memunculkan peringatan yang mengaburkan hasil uji.
 */

// scrollTo dipakai ScrollRestoration React Router
if (!window.scrollTo) {
  window.scrollTo = () => {};
} else {
  // Tetap timpa karena jsdom hanya mencetak "Not implemented"
  window.scrollTo = () => {};
}

// matchMedia belum ada di jsdom
if (typeof window.matchMedia !== 'function') {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: (query: string) => ({
      matches: false,
      media: query,
      onchange: null,
      addEventListener: () => {},
      removeEventListener: () => {},
      addListener: () => {},
      removeListener: () => {},
      dispatchEvent: () => false,
    }),
  });
}
