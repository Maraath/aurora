-- Aurora: esquema inicial do servidor.
--
-- As tabelas espelham o banco local (Drift) com nomes em snake_case. Toda
-- linha tem dono (user_id) e as regras de RLS só deixam cada pessoa ver e
-- mudar o que é dela. Exclusões são marcadas em apagado_em (nunca DELETE),
-- para os outros aparelhos saberem.
--
-- servidor_em é o relógio do SERVIDOR na última gravação; a sincronização
-- baixa "o que mudou desde servidor_em X", sem depender do relógio do aparelho.
--
-- Sem chaves estrangeiras de propósito: as linhas podem chegar fora de ordem.

create table public.metas (
  nome text not null,
  valor_inicial double precision not null,
  valor_atual double precision not null,
  valor_alvo double precision not null,
  unidade text not null default '',
  data_alvo timestamptz,
  status text not null default 'ativa'
);

create table public.tarefas (
  titulo text not null,
  notas text,
  prazo timestamptz,
  prazo_tem_hora boolean not null default false,
  prioridade text not null default 'media',
  feita_em timestamptz,
  regra_repeticao text,
  meta_id text
);

create table public.habitos (
  nome text not null,
  tipo text not null default 'marcar',
  dias_semana integer not null default 127,
  horario text,
  alvo integer,
  unidade text,
  meta_id text
);

create table public.conclusoes_tarefa (
  tarefa_id text not null,
  dia text not null
);

create table public.registros_habito (
  habito_id text not null,
  dia text not null,
  feito boolean not null default true,
  valor integer
);

create table public.contas_financeiras (
  nome text not null,
  tipo text not null,
  saldo_inicial_centavos bigint not null default 0,
  dia_fechamento integer,
  dia_vencimento integer
);

create table public.transacoes (
  descricao text not null,
  valor_centavos bigint not null,
  tipo text not null,
  data timestamptz not null,
  vencimento timestamptz,
  pago_em timestamptz,
  categoria text,
  regra_repeticao text,
  parcela_numero integer,
  parcela_total integer,
  conta_id text,
  conta_destino_id text
);

create table public.pagamentos_transacao (
  transacao_id text not null,
  vencimento text not null,
  pago_em timestamptz not null,
  valor_centavos bigint not null
);

create table public.lembretes (
  texto text not null,
  quando timestamptz not null,
  regra_repeticao text,
  notificar_antes_min integer not null default 0,
  ativo boolean not null default true,
  item_tipo text,
  item_id text
);

create table public.exercicios (
  nome text not null,
  grupo text,
  midia text
);

create table public.treinos (
  nome text not null,
  foco text,
  dias_semana integer not null default 0,
  ordem integer not null default 0
);

create table public.itens_treino (
  treino_id text not null,
  exercicio_id text not null,
  ordem integer not null default 0,
  series integer not null default 3,
  repeticoes integer not null default 10,
  carga_inicial double precision
);

create table public.sessoes_treino (
  treino_id text,
  dia text not null,
  inicio timestamptz not null,
  fim timestamptz
);

create table public.series_feitas (
  sessao_id text not null,
  exercicio_id text not null,
  numero integer not null,
  repeticoes integer not null,
  carga_kg double precision not null
);

create table public.medidas (
  dia text not null,
  tipo text not null,
  valor double precision not null,
  unidade text not null
);

create table public.mensagens_assistente (
  papel text not null,
  texto text not null,
  na_fila boolean not null default false,
  item_tipo text,
  item_id text,
  desfeita boolean not null default false
);

-- Relógio do servidor em toda gravação.
create or replace function public.marcar_servidor_em()
returns trigger
language plpgsql
as $$
begin
  new.servidor_em := now();
  return new;
end;
$$;

-- Colunas comuns, índice de sincronização, gatilho e RLS em todas as tabelas.
do $$
declare
  t text;
begin
  foreach t in array array[
    'metas', 'tarefas', 'habitos', 'conclusoes_tarefa', 'registros_habito',
    'contas_financeiras', 'transacoes', 'pagamentos_transacao', 'lembretes',
    'exercicios', 'treinos', 'itens_treino', 'sessoes_treino', 'series_feitas',
    'medidas', 'mensagens_assistente'
  ]
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

-- Uso da IA por pessoa e dia, para o limite configurável na Edge Function.
create table public.uso_ia (
  user_id uuid not null references auth.users (id) on delete cascade,
  dia date not null default (now() at time zone 'America/Sao_Paulo')::date,
  pedidos integer not null default 0,
  primary key (user_id, dia)
);

alter table public.uso_ia enable row level security;

create policy "dono lê o próprio uso" on public.uso_ia
  for select to authenticated using (user_id = (select auth.uid()));
-- Só a Edge Function (com a chave de serviço) grava o uso.
