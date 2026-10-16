-- Plano alimentar: alimentos, alvos por tipo de dia e o que foi comido.

create table public.alimentos (
  nome text not null,
  kcal double precision not null,
  proteina double precision not null default 0,
  carboidrato double precision not null default 0,
  gordura double precision not null default 0,
  porcao_nome text,
  porcao_gramas double precision,
  origem text not null default 'pessoal'
);

create table public.alvos_dieta (
  tipo_dia text not null,
  kcal double precision not null,
  proteina double precision not null default 0,
  carboidrato double precision not null default 0,
  gordura double precision not null default 0
);

create table public.registros_alimentacao (
  dia text not null,
  refeicao text not null,
  alimento_id text,
  nome text not null,
  gramas double precision not null,
  kcal double precision not null,
  proteina double precision not null default 0,
  carboidrato double precision not null default 0,
  gordura double precision not null default 0
);

do $$
declare
  t text;
begin
  foreach t in array array['alimentos', 'alvos_dieta', 'registros_alimentacao']
  loop
    execute format($f$
      alter table public.%1$I
        add column id text primary key,
        add column user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
        add column criado_em timestamptz not null default now(),
        add column atualizado_em timestamptz not null default now(),
        add column apagado_em timestamptz,
        add column servidor_em timestamptz not null default now();

      create index %1$s_sincronizacao on public.%1$I (user_id, servidor_em);

      create trigger %1$s_servidor_em
        before insert or update on public.%1$I
        for each row execute function public.marcar_servidor_em();

      alter table public.%1$I enable row level security;

      create policy "dono lê" on public.%1$I
        for select to authenticated using (user_id = (select auth.uid()));
      create policy "dono cria" on public.%1$I
        for insert to authenticated with check (user_id = (select auth.uid()));
      create policy "dono altera" on public.%1$I
        for update to authenticated
        using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
    $f$, t);
  end loop;
end;
$$;
