-- Rotina: compromissos (dia e hora marcados, local, repetição e aviso antes).
--
-- Sincroniza como as outras tabelas (colunas comuns, chave por conta, gatilho
-- servidor_em e as 3 políticas). A repetição é uma REGRA (RRULE), como nos
-- lembretes: nunca uma linha por dia.

create table if not exists public.compromissos (
  id text not null,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  apagado_em timestamptz,
  servidor_em timestamptz not null default now(),
  titulo text not null,
  inicio timestamptz not null,
  fim timestamptz,
  dia_inteiro boolean not null default false,
  local text,
  regra_repeticao text,
  aviso_antes_min integer,
  despertar boolean not null default false,
  notas text,
  primary key (user_id, id)
);

create index if not exists compromissos_sincronizacao on public.compromissos (user_id, servidor_em);

drop trigger if exists compromissos_servidor_em on public.compromissos;
create trigger compromissos_servidor_em before insert or update on public.compromissos
  for each row execute function public.marcar_servidor_em();

alter table public.compromissos enable row level security;
drop policy if exists "dono lê" on public.compromissos;
drop policy if exists "dono cria" on public.compromissos;
drop policy if exists "dono altera" on public.compromissos;
create policy "dono lê" on public.compromissos for select to authenticated
  using (user_id = (select auth.uid()));
create policy "dono cria" on public.compromissos for insert to authenticated
  with check (user_id = (select auth.uid()));
create policy "dono altera" on public.compromissos for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- Acesso da Data API (obrigatório desde 30/10/2026), como em
-- 20261021130000_privilegios_minimos.sql: o app logado lê, cria e altera
-- (excluir é apagado_em, um UPDATE); as Edge Functions fazem tudo; anon, nada.
revoke all on table public.compromissos from anon, authenticated, service_role;
grant select, insert, update on table public.compromissos to authenticated;
grant select, insert, update, delete on table public.compromissos to service_role;
