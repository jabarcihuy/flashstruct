/// <reference types="vitest/config" />
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import { fileURLToPath, URL } from 'node:url';

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './src/test/setup.ts',
    css: true,
    /**
     * Hanya jalankan test unit dari `src/`.
     *
     * Tanpa ini, Vitest ikut memungut spec Playwright di `e2e/` dan
     * gagal karena `test` dan `expect` di sana milik Playwright, bukan
     * Vitest. Keduanya harus dipisah: unit (Vitest) vs E2E (Playwright).
     */
    include: ['src/**/*.test.{ts,tsx}'],
    exclude: ['node_modules/**', 'dist/**', 'e2e/**', '.agents/**'],
  },
});
