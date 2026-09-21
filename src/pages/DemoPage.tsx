import { useState } from 'react';
import { Button } from '@/components/ui/Button';
import { Card, Badge, PageHeader } from '@/components/ui/Card';
import { EmptyState, ErrorState, Skeleton } from '@/components/ui/States';
import {
  IndikatorTigaTahap,
  ProgressBar,
  ProgressRing,
  StatAngka,
  type StatusTahap,
} from '@/components/ui/Progress';
import { Tabs } from '@/components/ui/Tabs';
import { Dialog } from '@/components/ui/Dialog';
import { useToast } from '@/components/ui/toast-context';

/**
 * Halaman demo komponen.
 *
 * Tujuan: melihat semua komponen di kedua tema sekaligus, agar
 * masalah kontras atau state yang hilang cepat terlihat.
 *
 * PENTING: halaman ini harus DIHAPUS atau dilindungi sebelum rilis
 * (docs/08-CHECKLIST-QA.md §12.1).
 */
export default function DemoPage() {
  const [dialogTerbuka, setDialogTerbuka] = useState(false);
  const [dialogKonfirmasi, setDialogKonfirmasi] = useState(false);
  const { tampilkan } = useToast();

  const statusTahapSelesai: [StatusTahap, StatusTahap, StatusTahap] = [
    'selesai',
    'selesai',
    'selesai',
  ];
  const statusTahapSedang: [StatusTahap, StatusTahap, StatusTahap] = [
    'selesai',
    'tersedia',
    'terkunci',
  ];
  const statusTahapBaru: [StatusTahap, StatusTahap, StatusTahap] = [
    'tersedia',
    'terkunci',
    'terkunci',
  ];

  return (
    <div className="container-base space-y-12 py-8 pb-24">
      <PageHeader
        judul="Demo Komponen"
        deskripsi="Halaman ini untuk memeriksa komponen di kedua tema. Hapus sebelum rilis."
      />

      {/* ============ Tombol ============ */}
      <Seksi judul="Tombol" catatan="5 varian x 3 ukuran, plus state disabled dan loading">
        <div className="space-y-4">
          <div className="flex flex-wrap items-center gap-2">
            <Button varian="primary">Primary</Button>
            <Button varian="secondary">Secondary</Button>
            <Button varian="ghost">Ghost</Button>
            <Button varian="accent">Accent</Button>
            <Button varian="danger">Danger</Button>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <Button ukuran="sm">Kecil</Button>
            <Button ukuran="md">Sedang</Button>
            <Button ukuran="lg">Besar</Button>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <Button disabled>Disabled</Button>
            <Button memuat>Memuat</Button>
            <Button varian="secondary" disabled>
              Secondary disabled
            </Button>
          </div>
        </div>
      </Seksi>

      {/* ============ Badge ============ */}
      <Seksi judul="Badge" catatan="Label topik memakai warna topik">
        <div className="flex flex-wrap items-center gap-2">
          <Badge warna="var(--topik-array)">Array</Badge>
          <Badge warna="var(--topik-struct)">Struct</Badge>
          <Badge warna="var(--topik-pointer)">Pointer</Badge>
          <Badge warna="var(--success)">Selesai</Badge>
          <Badge warna="var(--danger)">Salah</Badge>
        </div>
      </Seksi>

      {/* ============ Kartu ============ */}
      <Seksi judul="Kartu" catatan="Kartu modul dengan indikator tiga tahap">
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <KartuModulContoh
            topik="Array"
            warnaTopik="var(--topik-array)"
            judul="Dasar Array & Indeks"
            deskripsi="Memori berurutan, indeks, dan batas array."
            meta="5 bagian · 20 kartu · 12 mnt"
            status={statusTahapBaru}
            aksi={<Button ukuran="sm">Baca Modul</Button>}
          />
          <KartuModulContoh
            topik="Struct"
            warnaTopik="var(--topik-struct)"
            judul="Padding & Alignment"
            deskripsi="Mengapa sizeof(struct) lebih besar dari jumlah anggotanya."
            meta="5 bagian · 22 kartu · 16 mnt"
            status={statusTahapSedang}
            aksi={<Button ukuran="sm">Lanjutkan Flashcard</Button>}
          />
          <KartuModulContoh
            topik="Pointer"
            warnaTopik="var(--topik-pointer)"
            judul="Alokasi Memori Dinamis"
            deskripsi="Stack vs heap, new/delete, dan tiga bug klasik."
            meta="6 bagian · 26 kartu · 18 mnt"
            status={statusTahapSelesai}
            aksi={
              <Button ukuran="sm" varian="ghost">
                Ulangi
              </Button>
            }
          />
        </div>
      </Seksi>

      {/* ============ Progres ============ */}
      <Seksi judul="Indikator Progres" catatan="Bar, ring, tiga tahap, dan angka besar">
        <div className="space-y-8">
          <ProgressBar nilai={3} maks={20} label="Kartu" />

          <div className="flex flex-wrap items-center gap-8">
            <ProgressRing nilai={82} label="Deck dikuasai">
              <span className="font-heading text-lg font-bold tabular-nums">82%</span>
            </ProgressRing>
            <ProgressRing nilai={35} label="Deck dikuasai" warna="var(--topik-array)">
              <span className="font-heading text-lg font-bold tabular-nums">35%</span>
            </ProgressRing>
          </div>

          <div className="space-y-3">
            <IndikatorTigaTahap tahap={statusTahapBaru} />
            <IndikatorTigaTahap tahap={statusTahapSedang} />
            <IndikatorTigaTahap tahap={statusTahapSelesai} />
          </div>

          <div className="grid grid-cols-2 gap-6 sm:grid-cols-4">
            <StatAngka nilai={3} label="modul selesai" />
            <StatAngka nilai={48} label="kartu dikuasai" />
            <StatAngka nilai="76%" label="akurasi quiz" />
            <StatAngka nilai={0} label="hari streak" ajakan="Mulai belajar" />
          </div>
        </div>
      </Seksi>

      {/* ============ Tab ============ */}
      <Seksi judul="Tab" catatan="Untuk membandingkan kode C++ dan Python">
        <Tabs
          item={[
            {
              nilai: 'cpp',
              label: 'C++',
              konten: (
                <pre className="overflow-x-auto rounded-md bg-code-bg p-4 text-sm text-code-fg">
                  <code>{`struct Titik { int x; int y; };
Titik t = {3, 7};
Titik* p = &t;
cout << p->x;  // 3`}</code>
                </pre>
              ),
            },
            {
              nilai: 'python',
              label: 'Python',
              konten: (
                <pre className="overflow-x-auto rounded-md bg-code-bg p-4 text-sm text-code-fg">
                  <code>{`from dataclasses import dataclass

@dataclass
class Titik:
    x: int
    y: int

t = Titik(3, 7)
print(t.x)  # 3`}</code>
                </pre>
              ),
            },
          ]}
        />
      </Seksi>

      {/* ============ Dialog ============ */}
      <Seksi judul="Dialog" catatan="Fokus terkunci, Escape menutup, fokus kembali ke pemicu">
        <div className="flex flex-wrap gap-2">
          <Button varian="secondary" onClick={() => setDialogTerbuka(true)}>
            Buka Dialog Biasa
          </Button>
          <Button varian="danger" onClick={() => setDialogKonfirmasi(true)}>
            Dialog Konfirmasi Hapus
          </Button>
        </div>

        <Dialog
          terbuka={dialogTerbuka}
          onTutup={() => setDialogTerbuka(false)}
          judul="Contoh Dialog"
          deskripsi="Coba tekan Escape, atau Tab berulang untuk memeriksa perangkap fokus."
        >
          <p className="text-fg-muted">
            Fokus harus tetap di dalam dialog saat menekan Tab. Setelah ditutup, fokus kembali ke
            tombol yang membukanya.
          </p>
          <div className="mt-6 flex justify-end gap-2">
            <Button varian="secondary" onClick={() => setDialogTerbuka(false)}>
              Tutup
            </Button>
            <Button onClick={() => setDialogTerbuka(false)}>Mengerti</Button>
          </div>
        </Dialog>

        <Dialog
          terbuka={dialogKonfirmasi}
          onTutup={() => setDialogKonfirmasi(false)}
          judul="Reset semua progres?"
          deskripsi="Kamu akan kehilangan 3 modul selesai dan 48 kartu yang sudah dikuasai."
        >
          <p className="rounded-md border border-danger/30 bg-danger/5 p-3 text-sm text-fg">
            Tindakan ini tidak bisa dibatalkan.
          </p>
          <div className="mt-6 flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
            <Button varian="secondary" onClick={() => setDialogKonfirmasi(false)}>
              Batal
            </Button>
            <Button
              varian="danger"
              onClick={() => {
                setDialogKonfirmasi(false);
                tampilkan('Progres direset', 'sukses');
              }}
            >
              Hapus Permanen
            </Button>
          </div>
        </Dialog>
      </Seksi>

      {/* ============ Toast ============ */}
      <Seksi judul="Notifikasi" catatan="Hilang otomatis 4 detik, kecuali error. Maks 3 bertumpuk.">
        <div className="flex flex-wrap gap-2">
          <Button varian="secondary" onClick={() => tampilkan('Progres tersimpan', 'sukses')}>
            Sukses
          </Button>
          <Button varian="secondary" onClick={() => tampilkan('Kamu menandai 5 kartu perlu diulang', 'info')}>
            Info
          </Button>
          <Button
            varian="secondary"
            onClick={() => tampilkan('Progres disimpan hanya di browser ini', 'peringatan')}
          >
            Peringatan
          </Button>
          <Button varian="secondary" onClick={() => tampilkan('Gagal memuat materi. Coba lagi.', 'error')}>
            Error
          </Button>
        </div>
      </Seksi>

      {/* ============ State Kosong & Error ============ */}
      <Seksi judul="State Kosong & Error" catatan="Setiap daftar kosong harus punya arah, bukan sekadar 'Belum ada data'">
        <div className="grid gap-4 lg:grid-cols-2">
          <Card className="p-2">
            <EmptyState
              judul="Belum ada modul"
              pesan="Konten sedang disiapkan. Coba muat ulang halaman sebentar lagi."
              aksi={<Button varian="secondary">Muat Ulang</Button>}
            />
          </Card>
          <Card className="p-2">
            <ErrorState
              judul="Gagal memuat materi"
              pesan="Tidak bisa terhubung ke server. Periksa koneksi internet, lalu coba lagi."
              onCobaLagi={() => tampilkan('Mencoba ulang…', 'info')}
            />
          </Card>
        </div>
      </Seksi>

      {/* ============ Skeleton ============ */}
      <Seksi judul="Skeleton" catatan="Tinggi harus sama dengan konten akhir agar tidak ada layout shift">
        <Card className="p-6">
          <Skeleton className="h-6 w-3/4" />
          <Skeleton className="mt-3 h-4 w-full" />
          <Skeleton className="mt-2 h-4 w-2/3" />
          <div className="mt-6 flex gap-2">
            <Skeleton className="h-9 w-24" />
            <Skeleton className="h-9 w-24" />
          </div>
        </Card>
      </Seksi>
    </div>
  );
}

/* ============ Komponen bantu halaman demo ============ */

function Seksi({
  judul,
  catatan,
  children,
}: {
  judul: string;
  catatan?: string;
  children: React.ReactNode;
}) {
  return (
    <section>
      <div className="mb-4 border-b border-border pb-2">
        <h2 className="text-2xl font-semibold text-fg">{judul}</h2>
        {catatan && <p className="mt-1 text-sm text-fg-muted">{catatan}</p>}
      </div>
      {children}
    </section>
  );
}

function KartuModulContoh({
  topik,
  warnaTopik,
  judul,
  deskripsi,
  meta,
  status,
  aksi,
}: {
  topik: string;
  warnaTopik: string;
  judul: string;
  deskripsi: string;
  meta: string;
  status: [StatusTahap, StatusTahap, StatusTahap];
  aksi: React.ReactNode;
}) {
  const semuaSelesai = status.every((s) => s === 'selesai');

  return (
    <Card className="flex flex-col p-5" >
      <div className="flex items-start gap-3">
        {/* Garis topik di kiri */}
        <span
          className="mt-1 h-10 w-1 shrink-0 rounded-full"
          style={{ backgroundColor: warnaTopik }}
          aria-hidden="true"
        />
        <div className="min-w-0 flex-1">
          <Badge warna={warnaTopik}>{topik}</Badge>
          <h3 className="mt-2 font-semibold text-fg">{judul}</h3>
          <p className="mt-1 text-sm text-fg-muted">{deskripsi}</p>
        </div>
      </div>

      <p className="mt-4 text-xs text-fg-muted">{meta}</p>

      <div className="mt-4 border-t border-border pt-4">
        <IndikatorTigaTahap tahap={status} />
      </div>

      <div className="mt-4">
        {semuaSelesai ? (
          <Badge warna="var(--success)">Tuntas</Badge>
        ) : (
          aksi
        )}
      </div>
    </Card>
  );
}
