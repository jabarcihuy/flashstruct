-- Pastikan urutan modul mengikuti kurikulum Array → Struct → Pointer.
update public.modul
set urutan = case slug
  when 'array-dasar' then 1
  when 'struct-dasar' then 4
  when 'pointer-dasar' then 7
  else urutan
end
where slug in ('array-dasar', 'struct-dasar', 'pointer-dasar');
