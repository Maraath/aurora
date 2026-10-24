-- Anotações: pastas, notas (texto e caixinhas) e anexos (foto ou áudio).
--
-- As três tabelas sincronizam como as outras (colunas comuns, chave por conta,
-- gatilho servidor_em e as 3 políticas). O ARQUIVO de cada anexo só vai para a
-- nuvem se a pessoa quiser (na_nuvem): fotos no balde privado "fotos" (o mesmo
-- do Shape) e áudios no balde privado novo "audios", na pasta da própria conta:
--   {user_id}/audios/{id}.{m4a|flac|wav}

create table if not exists public.pastas_notas (
  id text not null,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  apagado_em timestamptz,
  servidor_em timestamptz not null default now(),
  nome text not null,
  ordem integer not null default 0,
  primary key (user_id, id)
);

create table if not exists public.notas (
  id text not null,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  apagado_em timestamptz,
  servidor_em timestamptz not null default now(),
  pasta_id text,
  tipo text not null default 'texto',
  titulo text not null default '',
  texto text not null default '',
  itens text,
  fixada boolean not null default false,
  primary key (user_id, id)
);

create table if not exists public.anexos_nota (
  id text not null,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  apagado_em timestamptz,
  servidor_em timestamptz not null default now(),
  nota_id text not null,
  tipo text not null,
  hash text,
  na_nuvem boolean not null default false,
  formato text,
  duracao_ms integer,
  onda text,
  transcricao text,
  ordem integer not null default 0,
  primary key (user_id, id)
);

do $$
declare
  t text;
begin
  foreach t in array array['pastas_notas', 'notas', 'anexos_nota'] loop
    execute format('create index if not exists %I on public.%I (user_id, servidor_em)', t || '_sincronizacao', t);
    execute format('drop trigger if exists %I on public.%I', t || '_servidor_em', t);
    execute format('create trigger %I before insert or update on public.%I '
                   'for each row execute function public.marcar_servidor_em()', t || '_servidor_em', t);
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "dono lê" on public.%I', t);
    execute format('drop policy if exists "dono cria" on public.%I', t);
    execute format('drop policy if exists "dono altera" on public.%I', t);
    execute format('create policy "dono lê" on public.%I for select to authenticated '
                   'using (user_id = (select auth.uid()))', t);
    execute format('create policy "dono cria" on public.%I for insert to authenticated '
                   'with check (user_id = (select auth.uid()))', t);
    execute format('create policy "dono altera" on public.%I for update to authenticated '
                   'using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))', t);
  end loop;
end;
$$;

-- Acesso da Data API (obrigatório desde 30/10/2026), como em
-- 20261021130000_privilegios_minimos.sql: o app logado lê, cria e altera
-- (excluir é apagado_em, um UPDATE); as Edge Functions fazem tudo; anon, nada.
revoke all on table public.pastas_notas, public.notas, public.anexos_nota from anon, authenticated, service_role;
grant select, insert, update on table public.pastas_notas, public.notas, public.anexos_nota to authenticated;
grant select, insert, update, delete on table public.pastas_notas, public.notas, public.anexos_nota to service_role;

-- Balde privado dos áudios: sem URL pública; cada conta só mexe na própria pasta.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('audios', 'audios', false, 15728640,
        array['audio/mp4', 'audio/aac', 'audio/flac', 'audio/wav', 'audio/x-wav', 'audio/ogg', 'audio/webm'])
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "audios: dono lê" on storage.objects;
drop policy if exists "audios: dono envia" on storage.objects;
drop policy if exists "audios: dono troca" on storage.objects;
drop policy if exists "audios: dono apaga" on storage.objects;

create policy "audios: dono lê" on storage.objects
  for select to authenticated
  using (bucket_id = 'audios' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "audios: dono envia" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'audios' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "audios: dono troca" on storage.objects
  for update to authenticated
  using (bucket_id = 'audios' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'audios' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "audios: dono apaga" on storage.objects
  for delete to authenticated
  using (bucket_id = 'audios' and (storage.foldername(name))[1] = (select auth.uid())::text);
