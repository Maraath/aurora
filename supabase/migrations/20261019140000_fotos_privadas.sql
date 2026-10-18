-- Fotos do usuário (Shape hoje; perfil e outras depois) num balde PRIVADO.
--
-- Organização: {user_id}/fotos/{id}.webp (foto inteira, até 1080 px) e
-- {user_id}/miniaturas/{id}.webp (~300 px, para listas e grades). O app lê por
-- URL assinada de 1 hora; nada aqui tem URL pública.
--
-- A linha da foto (fotos_shape) continua sincronizando sempre: assim os outros
-- aparelhos sabem que a foto existe e mostram "Foto guardada em outro
-- aparelho" quando a imagem não foi para a nuvem.

alter table public.fotos_shape
  add column if not exists hash text,
  add column if not exists na_nuvem boolean not null default false;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('fotos', 'fotos', false, 2097152, array['image/webp', 'image/jpeg'])
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Cada conta só lê, envia, troca e apaga dentro da própria pasta {user_id}/.
drop policy if exists "fotos: dono lê" on storage.objects;
drop policy if exists "fotos: dono envia" on storage.objects;
drop policy if exists "fotos: dono troca" on storage.objects;
drop policy if exists "fotos: dono apaga" on storage.objects;

create policy "fotos: dono lê" on storage.objects
  for select to authenticated
  using (bucket_id = 'fotos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "fotos: dono envia" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'fotos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "fotos: dono troca" on storage.objects
  for update to authenticated
  using (bucket_id = 'fotos' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'fotos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "fotos: dono apaga" on storage.objects
  for delete to authenticated
  using (bucket_id = 'fotos' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- O balde antigo "shape" (fotos em {user_id}/{arquivo}.jpg) ficou vazio e sai de
-- uso: sem políticas, ninguém lê nem grava nele pelo app.
drop policy if exists "shape: dono lê" on storage.objects;
drop policy if exists "shape: dono envia" on storage.objects;
drop policy if exists "shape: dono troca" on storage.objects;
drop policy if exists "shape: dono apaga" on storage.objects;
