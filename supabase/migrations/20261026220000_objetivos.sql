-- Objetivos: Metas e Projetos viram uma tabela só.
--
-- Um objetivo pode ser uma meta numérica (unidade preenchida, valor_inicial →
-- valor_alvo), um plano de etapas (tarefas com objetivo_id), ou os dois.
-- data_alvo é o prazo; inicio é o começo (para a linha do tempo). Como nas
-- outras tabelas, a chave é (user_id, id), as exclusões viajam por apagado_em e
-- cada linha leva o gatilho servidor_em, o índice de sincronização e as 3
-- políticas RLS. Os dados das tabelas antigas são copiados aqui (mesmos ids),
-- então os aparelhos com o app novo reencontram tudo na nuvem.

create table if not exists public.objetivos (
  id text not null,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  apagado_em timestamptz,
  servidor_em timestamptz not null default now(),
  nome text not null,
  descricao text,
  unidade text not null default '',
  valor_inicial double precision not null default 0,
  valor_atual double precision not null default 0,
  valor_alvo double precision not null default 0,
  data_alvo timestamptz,
  inicio timestamptz,
  status text not null default 'ativa',
  cor text,
  primary key (user_id, id)
);

-- Metas viram objetivos numéricos; projetos viram objetivos por etapas.
insert into public.objetivos (id, user_id, criado_em, atualizado_em, apagado_em, servidor_em,
  nome, descricao, unidade, valor_inicial, valor_atual, valor_alvo, data_alvo, inicio, status, cor)
select id, user_id, criado_em, atualizado_em, apagado_em, servidor_em,
  nome, null, unidade, valor_inicial, valor_atual, valor_alvo, data_alvo, null, status, null
from public.metas;

insert into public.objetivos (id, user_id, criado_em, atualizado_em, apagado_em, servidor_em,
  nome, descricao, unidade, valor_inicial, valor_atual, valor_alvo, data_alvo, inicio, status, cor)
select id, user_id, criado_em, atualizado_em, apagado_em, servidor_em,
  nome, null, '', 0, 0, 0, fim, inicio, case status when 'arquivado' then 'arquivada' else 'ativa' end, null
from public.projetos;

-- Campo único nas tarefas e hábitos (as etapas são tarefas ligadas).
alter table public.tarefas add column if not exists objetivo_id text;
alter table public.habitos add column if not exists objetivo_id text;

update public.tarefas set objetivo_id = coalesce(meta_id, projeto_id) where objetivo_id is null;
update public.habitos set objetivo_id = meta_id where objetivo_id is null;

alter table public.tarefas drop column if exists meta_id;
alter table public.tarefas drop column if exists projeto_id;
alter table public.habitos drop column if exists meta_id;

drop table if exists public.metas;
drop table if exists public.projetos;

-- Índice, gatilho e políticas da tabela nova.
do $$
declare
  t text;
begin
  foreach t in array array['objetivos'] loop
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

-- Acesso da Data API (obrigatório desde 30/10/2026), como nas outras tabelas:
-- o app logado lê, cria e altera (excluir é apagado_em, um UPDATE); as Edge
-- Functions fazem tudo; anon, nada.
revoke all on table public.objetivos from anon, authenticated, service_role;
grant select, insert, update on table public.objetivos to authenticated;
grant select, insert, update, delete on table public.objetivos to service_role;
