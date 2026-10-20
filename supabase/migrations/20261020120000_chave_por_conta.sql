-- Chave primária por conta: (user_id, id) no lugar de só (id).
--
-- Alguns registros têm id calculado a partir de uma chave natural (idNatural no
-- app): automações prontas pelo modelo, alvos da dieta pelo tipo de dia, alimentos
-- da TACO pelo código, medidas e fotos do Shape pelo dia. O mesmo cálculo dá o
-- MESMO id em qualquer conta. Com a chave só no id, a linha de uma conta nova
-- batia na de outra pessoa e o upsert caía na RLS ("new row violates row-level
-- security policy (USING expression)"). Agora cada conta tem o seu espaço de ids.
-- A RLS não muda; nenhuma linha é apagada (ids já eram únicos, então também são
-- únicos por conta). O app passa a enviar com on_conflict=user_id,id.

do $$
declare
  t text;
  restricao text;
begin
  foreach t in array array[
    'metas', 'projetos', 'tarefas', 'habitos', 'conclusoes_tarefa', 'registros_habito',
    'contas_financeiras', 'transacoes', 'pagamentos_transacao', 'lembretes',
    'exercicios', 'treinos', 'itens_treino', 'sessoes_treino', 'series_feitas',
    'medidas', 'fotos_shape', 'alimentos', 'alvos_dieta', 'registros_alimentacao',
    'mensagens_assistente', 'automacoes'
  ]
  loop
    select c.conname into restricao
      from pg_constraint c
     where c.conrelid = format('public.%I', t)::regclass and c.contype = 'p';
    -- Já está na chave nova? (rodar de novo não faz nada)
    if restricao is not null and (
      select array_agg(a.attname::text order by a.attname)
        from pg_constraint c
        join pg_attribute a on a.attrelid = c.conrelid and a.attnum = any (c.conkey)
       where c.conname = restricao and c.conrelid = format('public.%I', t)::regclass
    ) = array['id', 'user_id'] then
      continue;
    end if;
    if restricao is not null then
      execute format('alter table public.%I drop constraint %I', t, restricao);
    end if;
    execute format('alter table public.%I add primary key (user_id, id)', t);
  end loop;
end;
$$;
