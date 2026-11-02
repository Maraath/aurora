-- Limites da IA contados numa operação só.
--
-- Antes a Edge Function lia o contador e gravava "lido + 1": pedidos ao mesmo
-- tempo contavam como um. E as voltas de ferramenta e os áudios não contavam
-- nada, então um script podia usar a IA sem limite. Agora cada tipo tem a sua
-- coluna e consumir_uso_ia soma e confere de uma vez (a linha fica travada até
-- o fim): acima do limite devolve nulo e não soma.

alter table public.uso_ia
  add column if not exists voltas integer not null default 0,
  add column if not exists audios integer not null default 0;

create or replace function public.consumir_uso_ia(conta uuid, dia_uso date, tipo_uso text, limite integer)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  total integer;
begin
  if tipo_uso not in ('pedido', 'volta', 'audio') then
    raise exception 'Tipo de uso inválido: %', tipo_uso;
  end if;
  if limite < 1 then
    return null;
  end if;
  insert into public.uso_ia as u (user_id, dia, pedidos, voltas, audios)
  values (conta, dia_uso, (tipo_uso = 'pedido')::integer, (tipo_uso = 'volta')::integer, (tipo_uso = 'audio')::integer)
  on conflict (user_id, dia) do update
    set pedidos = u.pedidos + (tipo_uso = 'pedido')::integer,
        voltas = u.voltas + (tipo_uso = 'volta')::integer,
        audios = u.audios + (tipo_uso = 'audio')::integer
    where case tipo_uso when 'pedido' then u.pedidos when 'volta' then u.voltas else u.audios end < limite
  returning case tipo_uso when 'pedido' then u.pedidos when 'volta' then u.voltas else u.audios end into total;
  return total;
end;
$$;

-- "public" junto: sem ele, qualquer um executa (toda função nasce aberta a public).
revoke all on function public.consumir_uso_ia(uuid, date, text, integer) from public, anon, authenticated;
grant execute on function public.consumir_uso_ia(uuid, date, text, integer) to service_role;
