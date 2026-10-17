-- Automações: rotinas agendadas do assistente (briefing, revisões semanais...).

create table public.automacoes (
  id text primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  apagado_em timestamptz,
  servidor_em timestamptz not null default now(),
  nome text not null,
  modelo text not null,
  dias_semana integer not null default 127,
  horario text not null,
  ativa boolean not null default false,
  pedido text,
  ultima_execucao text
);

create index automacoes_sincronizacao on public.automacoes (user_id, servidor_em);

create trigger automacoes_servidor_em
  before insert or update on public.automacoes
  for each row execute function public.marcar_servidor_em();

alter table public.automacoes enable row level security;

create policy "dono lê" on public.automacoes
  for select to authenticated using (user_id = (select auth.uid()));
create policy "dono cria" on public.automacoes
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy "dono altera" on public.automacoes
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
