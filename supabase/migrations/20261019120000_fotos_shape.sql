-- Shape: fotos de check-in do corpo (frente, costas, lado) por dia.
-- A linha sincroniza como as outras tabelas; a imagem vai para o balde
-- PRIVADO "shape", na pasta do próprio usuário (<user_id>/<arquivo>).

create table public.fotos_shape (
  id text primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  apagado_em timestamptz,
  servidor_em timestamptz not null default now(),
  dia text not null,
  angulo text not null,
  arquivo text not null
);

create index fotos_shape_sincronizacao on public.fotos_shape (user_id, servidor_em);

create trigger fotos_shape_servidor_em
  before insert or update on public.fotos_shape
  for each row execute function public.marcar_servidor_em();

alter table public.fotos_shape enable row level security;

create policy "dono lê" on public.fotos_shape
  for select to authenticated using (user_id = (select auth.uid()));
create policy "dono cria" on public.fotos_shape
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy "dono altera" on public.fotos_shape
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- Balde privado: sem URL pública; cada conta só lê e grava a própria pasta.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('shape', 'shape', false, 5242880, array['image/jpeg'])
on conflict (id) do nothing;

create policy "shape: dono lê" on storage.objects
  for select to authenticated
  using (bucket_id = 'shape' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "shape: dono envia" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'shape' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "shape: dono troca" on storage.objects
  for update to authenticated
  using (bucket_id = 'shape' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'shape' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "shape: dono apaga" on storage.objects
  for delete to authenticated
  using (bucket_id = 'shape' and (storage.foldername(name))[1] = (select auth.uid())::text);
