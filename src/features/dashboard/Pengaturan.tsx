import { useState } from 'react';
import { Download, Monitor, Moon, Sun, Trash2, Upload } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Dialog } from '@/components/ui/Dialog';
import { useTema, type Tema } from '@/app/tema';
import { useProgres } from '@/features/progres/context';
import { useToast } from '@/components/ui/toast-context';
import { bacaBerkasImpor, unduhProgres } from '@/features/progres/store';
import { cn } from '@/lib/cn';
import { useState as useStateAlias } from 'react';
import { useBahasa } from '@/app/BahasaProvider';

/**
 * Pengaturan Dashboard: tema, ekspor/impor, reset progres.
 *
 * Reset progres memakai KONFIRMASI GANDA karena menghapus progres
 * berarti menghapus jam belajar. Satu klik salah akan sangat merugikan.
 * Dialog juga menawarkan EKSPOR lebih dulu.
 *
 * Rincian: docs/06-SPESIFIKASI-HALAMAN.md §3.6
 */

const OPSI_TEMA: { nilai: Tema; label: string; ikon: typeof Sun }[] = [
  { nilai: 'terang', label: 'Terang', ikon: Sun },
  { nilai: 'gelap', label: 'Gelap', ikon: Moon },
  { nilai: 'sistem', label: 'Ikuti Sistem', ikon: Monitor },
];

export function Pengaturan() {
  const { bahasa } = useBahasa();
  const en = bahasa === 'en';
  const { tema, setTema } = useTema();
  const { progres, resetProgres, gantiProgres, penyimpananTersedia } = useProgres();
  const { tampilkan } = useToast();

  const [dialogReset, setDialogReset] = useState(false);

  const adaProgres = Object.keys(progres.modul).length > 0;

  function ekspor() {
    try {
      unduhProgres(progres);
      tampilkan(en ? 'Progress downloaded' : 'Progres berhasil diunduh', 'sukses');
    } catch {
      tampilkan(en ? 'Could not download progress' : 'Gagal mengunduh progres', 'error');
    }
  }

  function impor(berkas: File) {
    const pembaca = new FileReader();

    pembaca.onload = () => {
      const isi = String(pembaca.result ?? '');
      const hasil = bacaBerkasImpor(isi);

      if (!hasil.berhasil) {
        tampilkan(hasil.pesan, 'error');
        return;
      }

      gantiProgres(hasil.progres);
      tampilkan(en ? 'Progress restored' : 'Progres berhasil dipulihkan', 'sukses');
    };

    pembaca.onerror = () => tampilkan(en ? 'Could not read file' : 'Gagal membaca berkas', 'error');
    pembaca.readAsText(berkas);
  }

  return (
    <Card className="p-5 sm:p-6">
      <h2 className="font-heading text-lg font-semibold text-fg">
        {en ? 'Settings' : 'Pengaturan'}
      </h2>

      {/* Peringatan penyimpanan tidak tersedia */}
      {!penyimpananTersedia && (
        <div className="mt-4 rounded-lg border border-danger/40 bg-danger/5 p-3">
          <p className="text-sm font-medium text-fg">
            {en ? 'Progress cannot be saved' : 'Progres tidak bisa disimpan'}
          </p>
          <p className="mt-1 text-xs text-fg-muted">
            {en
              ? 'This browser blocks local storage (possibly private browsing). Progress will be lost when the tab closes.'
              : 'Browser ini memblokir penyimpanan lokal (mungkin mode privat). Progres akan hilang saat tab ditutup.'}
          </p>
        </div>
      )}

      {/* Tema */}
      <div className="mt-5">
        <p className="mb-2 text-sm font-medium text-fg">{en ? 'Theme' : 'Tema'}</p>
        <div
          className="flex flex-wrap gap-2"
          role="group"
          aria-label={en ? 'Choose a theme' : 'Pilih tema'}
        >
          {OPSI_TEMA.map(({ nilai, label, ikon: Ikon }) => {
            const aktif = tema === nilai;
            return (
              <button
                key={nilai}
                type="button"
                onClick={() => setTema(nilai)}
                aria-pressed={aktif}
                className={cn(
                  'inline-flex h-11 cursor-pointer items-center gap-2 rounded-md border px-3 text-sm',
                  'transition-colors duration-150',
                  aktif
                    ? 'border-primary bg-primary/10 font-medium text-fg'
                    : 'border-border-strong text-fg-muted hover:text-fg',
                )}
              >
                <Ikon className="size-4" aria-hidden="true" />
                {en ? { terang: 'Light', gelap: 'Dark', sistem: 'System' }[nilai] : label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Ekspor / impor */}
      <div className="mt-6">
        <p className="mb-1 text-sm font-medium text-fg">
          {en ? 'Back up progress' : 'Cadangkan Progres'}
        </p>
        <p className="mb-3 text-xs text-fg-muted">
          {en
            ? 'Progress is stored only in this browser. Export it to move it to another device.'
            : 'Progres disimpan di browser ini saja. Ekspor untuk memindahkannya ke perangkat lain.'}
        </p>

        <div className="flex flex-wrap gap-2">
          <Button
            varian="secondary"
            ukuran="sm"
            onClick={ekspor}
            disabled={!adaProgres}
            ikonKiri={<Download className="size-4" aria-hidden="true" />}
          >
            {en ? 'Export progress' : 'Ekspor Progres'}
          </Button>

          <label
            className={cn(
              'inline-flex h-11 md:h-9 cursor-pointer items-center gap-2 rounded-md border border-border-strong px-3 text-sm',
              'text-fg transition-colors duration-150 hover:bg-surface',
            )}
          >
            <Upload className="size-4" aria-hidden="true" />
            {en ? 'Import progress' : 'Impor Progres'}
            <input
              type="file"
              accept="application/json,.json"
              className="sr-only"
              onChange={(e) => {
                const berkas = e.target.files?.[0];
                if (berkas) impor(berkas);
                e.target.value = '';
              }}
            />
          </label>
        </div>
      </div>

      {/* Reset */}
      <div className="mt-6 border-t border-border pt-5">
        <p className="mb-1 text-sm font-medium text-fg">
          {en ? 'Reset progress' : 'Reset Progres'}
        </p>
        <p className="mb-3 text-xs text-fg-muted">
          {en
            ? 'Removes all progress: completed modules, mastered cards, and quiz history.'
            : 'Menghapus semua progres: modul selesai, kartu dikuasai, dan riwayat quiz.'}
        </p>

        <Button
          varian="danger"
          ukuran="sm"
          onClick={() => setDialogReset(true)}
          disabled={!adaProgres}
          ikonKiri={<Trash2 className="size-4" aria-hidden="true" />}
        >
          {en ? 'Reset all progress' : 'Reset Semua Progres'}
        </Button>
      </div>

      {/* Dialog reset — konfirmasi ganda */}
      <DialogResetProgres
        terbuka={dialogReset}
        onTutup={() => setDialogReset(false)}
        progres={progres}
        onEkspor={ekspor}
        onKonfirmasi={() => {
          resetProgres();
          setDialogReset(false);
          tampilkan(en ? 'Progress reset' : 'Progres direset', 'sukses');
        }}
      />
    </Card>
  );
}

/* =========================================================
   Dialog reset dengan konfirmasi ganda
   ========================================================= */

function DialogResetProgres({
  terbuka,
  onTutup,
  progres,
  onEkspor,
  onKonfirmasi,
}: {
  terbuka: boolean;
  onTutup: () => void;
  progres: ReturnType<typeof useProgres>['progres'];
  onEkspor: () => void;
  onKonfirmasi: () => void;
}) {
  const { bahasa } = useBahasa();
  const en = bahasa === 'en';
  const kataKonfirmasi = en ? 'DELETE' : 'HAPUS';
  const [langkah, setLangkah] = useStateAlias<1 | 2>(1);
  const [teksKonfirmasi, setTeksKonfirmasi] = useStateAlias('');

  // Hitung apa yang akan hilang — pengguna perlu tahu kerugiannya
  const jumlahModulSelesai = Object.values(progres.modul).filter(
    (m) => m.tahap1Selesai && m.tahap2Selesai && m.tahap3Selesai,
  ).length;

  const jumlahKartu = Object.values(progres.modul).reduce((total, m) => {
    return (
      total + Object.values(m.kartu).filter((k) => k.jumlahIngat > 0 && k.jumlahLupa === 0).length
    );
  }, 0);

  const jumlahQuiz = Object.values(progres.modul).reduce(
    (total, m) => total + m.riwayatQuiz.length,
    0,
  );

  function tutup() {
    setLangkah(1);
    setTeksKonfirmasi('');
    onTutup();
  }

  if (langkah === 1) {
    return (
      <Dialog
        terbuka={terbuka}
        onTutup={tutup}
        judul={en ? 'Reset all progress?' : 'Reset semua progres?'}
        deskripsi={en ? 'This action cannot be undone.' : 'Tindakan ini tidak bisa dibatalkan.'}
        ukuran="sm"
      >
        <div className="rounded-lg border border-danger/30 bg-danger/5 p-3">
          <p className="text-sm font-medium text-fg">
            {en ? 'You will lose:' : 'Kamu akan kehilangan:'}
          </p>
          <ul className="mt-2 space-y-1 text-sm text-fg-muted">
            <li>
              • {jumlahModulSelesai} {en ? 'completed modules' : 'modul yang sudah selesai'}
            </li>
            <li>
              • {jumlahKartu} {en ? 'mastered cards' : 'kartu yang sudah dikuasai'}
            </li>
            <li>
              • {jumlahQuiz} {en ? 'quiz attempts' : 'riwayat quiz'}
            </li>
          </ul>
        </div>

        {/* Tawaran ekspor SEBELUM menghapus */}
        <div className="mt-4 rounded-lg border border-border bg-surface-raised p-3">
          <p className="text-xs text-fg-muted">
            {en
              ? 'Before deleting, you can export a backup to restore later.'
              : 'Sebelum menghapus, kamu bisa menyimpannya dulu untuk dipulihkan nanti.'}
          </p>
          <Button
            varian="secondary"
            ukuran="sm"
            className="mt-2"
            onClick={onEkspor}
            ikonKiri={<Download className="size-4" aria-hidden="true" />}
          >
            {en ? 'Export progress' : 'Ekspor Progres'}
          </Button>
        </div>

        <div className="mt-5 flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
          <Button varian="secondary" onClick={tutup}>
            {en ? 'Cancel' : 'Batal'}
          </Button>
          <Button varian="danger" onClick={() => setLangkah(2)}>
            {en ? 'Continue' : 'Lanjutkan'}
          </Button>
        </div>
      </Dialog>
    );
  }

  // Langkah 2: ketik HAPUS untuk konfirmasi
  const cocok = teksKonfirmasi.trim().toUpperCase() === kataKonfirmasi;

  return (
    <Dialog
      terbuka={terbuka}
      onTutup={tutup}
      judul={en ? 'Final confirmation' : 'Konfirmasi terakhir'}
      deskripsi={
        en
          ? `Type ${kataKonfirmasi} to confirm. This gives you a moment to reconsider.`
          : 'Ketik HAPUS untuk mengonfirmasi. Ini memaksa kamu berhenti dan berpikir.'
      }
      ukuran="sm"
    >
      <label className="block">
        <span className="sr-only">
          {en ? `Type ${kataKonfirmasi} to confirm` : 'Ketik HAPUS untuk konfirmasi'}
        </span>
        <input
          type="text"
          value={teksKonfirmasi}
          onChange={(e) => setTeksKonfirmasi(e.target.value)}
          placeholder={kataKonfirmasi}
          autoComplete="off"
          autoCapitalize="characters"
          className={cn(
            'w-full rounded-md border-2 bg-surface px-3 py-2.5 font-mono text-fg',
            'placeholder:text-fg-muted/50 focus:outline-none',
            cocok ? 'border-danger' : 'border-border-strong focus:border-primary',
          )}
        />
      </label>

      <div className="mt-5 flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
        <Button varian="secondary" onClick={tutup}>
          {en ? 'Cancel' : 'Batal'}
        </Button>
        <Button varian="danger" onClick={onKonfirmasi} disabled={!cocok}>
          {en ? 'Delete permanently' : 'Hapus Permanen'}
        </Button>
      </div>
    </Dialog>
  );
}
