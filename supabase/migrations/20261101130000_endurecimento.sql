-- Ajustes de segurança da auditoria de 01/11/2026.

-- 1. Limpeza do uso da IA: o revoke antigo esqueceu "public" (qualquer um podia
--    chamar) e nada a executava. Agora só o servidor chama, todo dia.
alter function public.limpar_uso_ia_antigo() set search_path = '';
revoke all on function public.limpar_uso_ia_antigo() from public, anon, authenticated;

select cron.unschedule(jobid) from cron.job where jobname = 'limpar-uso-ia';
select cron.schedule('limpar-uso-ia', '17 6 * * *', 'select public.limpar_uso_ia_antigo();');

-- 2. Tabela, sequência ou função nova no public nasce fechada: quem precisa
--    recebe o GRANT na própria migração (RLS esquecido não vira dado exposto).
alter default privileges for role postgres in schema public revoke all on tables from anon, authenticated;
alter default privileges for role postgres in schema public revoke all on sequences from anon, authenticated;
alter default privileges for role postgres in schema public revoke all on functions from public, anon, authenticated;

-- 3. Avisos: o servidor só fala com os serviços de push oficiais (senão uma conta
--    faria ele mandar pedidos a qualquer site), até 10 aparelhos por conta. Um
--    aparelho só muda de dono se quem pede tem a chave dele (troca de conta no
--    mesmo navegador): saber o endereço não basta.
create or replace function public.registrar_push(endpoint_push text, chave_p256dh text, chave_auth text, nome_aparelho text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Entre na conta para receber avisos.';
  end if;
  if length(endpoint_push) > 1000 or length(chave_p256dh) > 200 or length(chave_auth) > 100 or endpoint_push !~
     '^https://(fcm\.googleapis\.com|([a-z0-9-]+\.)*push\.apple\.com|([a-z0-9-]+\.)*push\.services\.mozilla\.com|([a-z0-9-]+\.)*notify\.windows\.com)/' then
    raise exception 'Serviço de avisos não reconhecido.';
  end if;
  insert into public.push_inscricoes as i (endpoint, user_id, p256dh, auth, aparelho)
  values (endpoint_push, uid, chave_p256dh, chave_auth, left(nome_aparelho, 120))
  on conflict (endpoint) do update
    set user_id = uid,
        p256dh = excluded.p256dh,
        auth = excluded.auth,
        aparelho = excluded.aparelho,
        atualizado_em = now()
    where i.user_id = uid or i.auth = chave_auth;
  delete from public.push_inscricoes as i
  where i.user_id = uid and i.endpoint in (
    select v.endpoint from public.push_inscricoes as v
    where v.user_id = uid
    order by v.atualizado_em desc
    offset 10
  );
end;
$$;

-- Aviso de teste: no máximo 3 na fila por conta.
create or replace function public.aviso_de_teste()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Entre na conta para receber avisos.';
  end if;
  if (select count(*) from public.avisos_push as a where a.user_id = uid and a.teste and a.enviado_em is null) >= 3 then
    return;
  end if;
  insert into public.avisos_push (user_id, quando, titulo, corpo, teste)
  values (uid, now(), 'Aurora', 'Os avisos estão funcionando neste aparelho.', true);
end;
$$;

-- 4. Cota de arquivos por conta (fotos + áudios): 300 MB. O cadastro é aberto e o
--    armazenamento gratuito do projeto inteiro é de 1 GB. Trocar um arquivo que já
--    existe também passa por aqui. Em schema próprio: a API não enxerga "privado".
create schema if not exists privado;
revoke all on schema privado from public;
grant usage on schema privado to authenticated;

create or replace function privado.cabe_na_cota()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(sum((o.metadata ->> 'size')::bigint), 0) < 300 * 1024 * 1024
  from storage.objects as o
  where o.bucket_id in ('fotos', 'audios')
    and (storage.foldername(o.name))[1] = (select auth.uid())::text;
$$;

revoke all on function privado.cabe_na_cota() from public, anon;
grant execute on function privado.cabe_na_cota() to authenticated;

drop policy if exists "fotos: dono envia" on storage.objects;
create policy "fotos: dono envia" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'fotos' and (storage.foldername(name))[1] = (select auth.uid())::text and privado.cabe_na_cota()
  );

drop policy if exists "audios: dono envia" on storage.objects;
create policy "audios: dono envia" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'audios' and (storage.foldername(name))[1] = (select auth.uid())::text and privado.cabe_na_cota()
  );
