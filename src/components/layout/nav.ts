import type { LucideIcon } from 'lucide-react';

export interface ItemNav {
  ke: string;
  label: string;
  ikon: LucideIcon;
  /** true untuk rute yang harus cocok persis */
  tepat?: boolean;
}
