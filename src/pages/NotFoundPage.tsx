import { Link } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { EmptyState } from '@/components/ui/States';
import { Compass } from 'lucide-react';

export default function NotFoundPage() {
  return (
    <div className="container-base py-16">
      <EmptyState
        ikon={<Compass className="size-12" strokeWidth={1.5} />}
        judul="Halaman tidak ditemukan"
        pesan="Tautan yang kamu buka mungkin salah, atau halamannya sudah dipindahkan."
        aksi={
          <Link to="/" className="no-underline">
            <Button>Kembali ke beranda</Button>
          </Link>
        }
      />
    </div>
  );
}
