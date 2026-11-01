-- Rotina de expurgo de uso_ia antigo.
--
-- A tabela uso_ia só precisa do dia atual para controlar o limite de 60 pedidos.
-- Registros com mais de 30 dias são descartados para economizar espaço no Postgres.

-- Remove registros antigos de uso da IA (mais de 30 dias)
delete from public.uso_ia
where dia < ((now() at time zone 'America/Sao_Paulo')::date - interval '30 days');

-- Função utilitária para expurgos periódicos futuros (chamável por Edge Function ou cron)
create or replace function public.limpar_uso_ia_antigo()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  removidos integer;
begin
  delete from public.uso_ia
  where dia < ((now() at time zone 'America/Sao_Paulo')::date - interval '30 days');
  get diagnostics removidos = row_count;
  return removidos;
end;
$$;

revoke all on function public.limpar_uso_ia_antigo() from anon, authenticated;
grant execute on function public.limpar_uso_ia_antigo() to service_role;
