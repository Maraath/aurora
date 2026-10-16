-- Projetos: metas vistas no tempo. As etapas são as tarefas com projeto_id.

create table public.projetos (
  id text primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  apagado_em timestamptz,
  servidor_em timestamptz not null default now(),
  nome text not null,
  inicio timestamptz not null,
  fim timestamptz not null,
  meta_id text,
  status text not null default 'ativo'
);

create index projetos_sincronizacao on public.projetos (user_id, servidor_em);

create trigger projetos_servidor_em
  before insert or update on public.projetos
  for each row execute function public.marcar_servidor_em();

alter table public.projetos enable row level security;

create policy "dono lê" on public.projetos
  for select to authenticated using (user_id = (select auth.uid()));
create policy "dono cria" on public.projetos
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy "dono altera" on public.projetos
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

alter table public.tarefas add column projeto_id text;
