-- Sincronização: a edição mais recente vence.
--
-- Um aparelho pode enviar uma versão antiga de uma linha (editou offline antes
-- de outro aparelho editar a mesma coisa). Se o atualizado_em que chega é
-- MAIS ANTIGO que o guardado, a gravação é ignorada (a linha fica como está e
-- o aparelho recebe a versão nova na próxima vez que baixar).
--
-- servidor_em passa a usar clock_timestamp(): cada linha ganha o seu instante,
-- mesmo dentro de um mesmo envio em lote (now() seria igual para todas).

create or replace function public.marcar_servidor_em()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'UPDATE' and new.atualizado_em < old.atualizado_em then
    return old;
  end if;
  new.servidor_em := clock_timestamp();
  return new;
end;
$$;
