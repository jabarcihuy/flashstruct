import { createClient } from '@supabase/supabase-js';

/**
 * Client Supabase — satu instance untuk seluruh aplikasi.
 *
 * Key yang dipakai adalah `publishable` key, yang memang dirancang
 * untuk diekspos ke browser. Yang melindungi data adalah RLS
 * (Row Level Security) di database, bukan kerahasiaan key ini.
 *
 * JANGAN pernah memakai `service_role` atau `sb_secret_` key di sini —
 * key itu melewati RLS dan memberi akses penuh ke database.
 *
 * Rincian: docs/16-KENAPA-RLS-WAJIB.md
 */

const url = import.meta.env.VITE_SUPABASE_URL;
const key = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY;

if (!url || !key) {
  throw new Error(
    'VITE_SUPABASE_URL dan VITE_SUPABASE_PUBLISHABLE_KEY harus diisi di .env.local\n' +
      'Lihat docs/15-SETUP-SUPABASE-UNTUK-ANDA.md',
  );
}

export const supabase = createClient(url, key, {
  auth: {
    // v1 tidak memakai autentikasi. Matikan agar tidak ada
    // request sesi yang tidak perlu.
    persistSession: false,
    autoRefreshToken: false,
    detectSessionInUrl: false,
  },
});
