import { PageHeader } from '@/components/ui/Card';

export default function HomePage() {
  return (
    <div className="container-base py-8 md:py-12">
      <PageHeader
        judul="Hafal dulu. Baru praktik."
        deskripsi="Dunia TI berat di praktik, tapi praktik tanpa hafalan yang kuat akan rapuh."
      />
    </div>
  );
}
