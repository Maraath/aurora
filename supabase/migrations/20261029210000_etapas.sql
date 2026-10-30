-- Etapas de projetos: marcos internos a serem feitos no projeto,
-- separados de tarefas (não entram no Timeblocking diário nem têm duração).

create table if not exists public.etapas (
  id text not null,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  apagado_em timestamptz,
  servidor_em timestamptz not null default now(),
  objetivo_id text not null,
  titulo text not null,
  concluida boolean not null default false,
  ordem integer not null default 0,
  concluida_em timestamptz,
  primary key (user_id, id)
);

-- Migra tarefas que eram etapas para a tabela de etapas
insert into public.etapas (id, user_id, criado_em, atualizado_em, apagado_em, servidor_em,
  objetivo_id, titulo, concluida, ordem, concluida_em)
select id, user_id, criado_em, atualizado_em, apagado_em, servidor_em,
  objetivo_id, titulo, (feita_em is not null), 0, feita_em
from public.tarefas
where objetivo_id is not null and regra_repeticao is null
on conflict do nothing;

delete from public.conclusoes_tarefa
where tarefa_id in (select id from public.tarefas where objetivo_id is not null and regra_repeticao is null);

delete from public.tarefas
where objetivo_id is not null and regra_repeticao is null;

-- Índice, gatilho e políticas da tabela nova.
do $$
declare
  t text;
begin
  foreach t in array array['etapas'] loop
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

-- Acesso da Data API
revoke all on table public.etapas from anon, authenticated, service_role;
grant select, insert, update on table public.etapas to authenticated;
grant select, insert, update, delete on table public.etapas to service_role;
