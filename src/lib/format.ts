/**
 * Fungsi format untuk tampilan.
 */

/** Format persentase bulat: 82.4 -> "82%" */
export function persen(nilai: number): string {
  return `${Math.round(nilai)}%`;
}

/** Format durasi detik menjadi "8:00" atau "1:05:30" */
export function durasi(detik: number): string {
  const jam = Math.floor(detik / 3600);
  const menit = Math.floor((detik % 3600) / 60);
  const sisaDetik = detik % 60;

  if (jam > 0) {
    return `${jam}:${String(menit).padStart(2, '0')}:${String(sisaDetik).padStart(2, '0')}`;
  }
  return `${menit}:${String(sisaDetik).padStart(2, '0')}`;
}

/** Konten seed lama menyimpan pemisah baris sebagai teks `\\n`. */
export function barisKonten(isi: string): string {
  let hasil = '';
  let kutip: '"' | "'" | null = null;

  for (let i = 0; i < isi.length; i++) {
    const karakter = isi[i];
    const berikutnya = isi[i + 1];

    if (karakter === '\\' && berikutnya === 'n' && !kutip) {
      hasil += '\n';
      i++;
    } else if (karakter === '\\' && kutip && berikutnya) {
      hasil += karakter + berikutnya;
      i++;
    } else {
      if (karakter === '"' || karakter === "'") kutip = kutip === karakter ? null : karakter;
      hasil += karakter;
    }
  }

  return hasil;
}

/** Format tanggal Indonesia: "21 September 2026" */
export function tanggal(epochMs: number): string {
  return new Intl.DateTimeFormat('id-ID', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  }).format(new Date(epochMs));
}

/** Selisih hari antara dua epoch (dibulatkan ke bawah) */
export function selisihHari(a: number, b: number): number {
  const satuHari = 24 * 60 * 60 * 1000;
  return Math.floor(Math.abs(a - b) / satuHari);
}

/** Kunci tanggal lokal "YYYY-MM-DD" — untuk perhitungan streak */
export function kunciTanggal(epochMs: number): string {
  const d = new Date(epochMs);
  const tahun = d.getFullYear();
  const bulan = String(d.getMonth() + 1).padStart(2, '0');
  const hari = String(d.getDate()).padStart(2, '0');
  return `${tahun}-${bulan}-${hari}`;
}

/**
 * Urutkan array berdasarkan kolom `urutan`.
 *
 * Supabase tidak menjamin urutan anak hasil embedding, jadi
 * pengurutan dilakukan di client. Jumlah baris kecil
 * (maks 6 bagian, 26 kartu, 4 opsi) sehingga aman.
 */
export function urutkan<T extends { urutan: number }>(items: T[] | null | undefined): T[] {
  return (items ?? []).slice().sort((a, b) => a.urutan - b.urutan);
}

/** Acak array dengan Fisher-Yates (tidak mengubah array asli) */
export function acak<T>(items: T[]): T[] {
  const hasil = items.slice();
  for (let i = hasil.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    const temp = hasil[i]!;
    hasil[i] = hasil[j]!;
    hasil[j] = temp;
  }
  return hasil;
}
