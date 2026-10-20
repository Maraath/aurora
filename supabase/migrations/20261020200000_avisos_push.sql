-- Avisos na web (PWA no iPhone): o navegador não agenda notificação local, então
-- o servidor manda por Web Push na hora certa.
--
-- 1. push_inscricoes: cada aparelho (navegador) que aceitou os avisos. O endpoint
--    é do serviço de push do sistema (Apple, Google, Mozilla); p256dh e auth
--    cifram o conteúdo para aquele aparelho.
-- 2. avisos_push: a agenda dos próximos 14 dias que o app calcula (planejarAvisos,
--    a mesma do Android) e troca inteira a cada mudança (substituir_avisos).
-- 3. pg_cron, a cada minuto: se há aviso vencido, chama a Edge Function
--    avisos-push, que pega os vencidos (pegar_avisos_vencidos) e envia.

create table if not exists public.push_inscricoes (
  endpoint text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  p256dh text not null,
  auth text not null,
  aparelho text,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index if not exists push_inscricoes_user_id on public.push_inscricoes (user_id);

alter table public.push_inscricoes enable row level security;
drop policy if exists "push_inscricoes: dono lê" on public.push_inscricoes;
drop policy if exists "push_inscricoes: dono apaga" on public.push_inscricoes;
create policy "push_inscricoes: dono lê" on public.push_inscricoes
  for select to authenticated using (user_id = (select auth.uid()));
create policy "push_inscricoes: dono apaga" on public.push_inscricoes
  for delete to authenticated using (user_id = (select auth.uid()));

create table if not exists public.avisos_push (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  quando timestamptz not null,
  titulo text not null,
  corpo text not null default '',
  -- Aviso de teste (Conta › Avisos): a troca da agenda não apaga.
  teste boolean not null default false,
  enviado_em timestamptz
);
create index if not exists avisos_push_pendentes on public.avisos_push (quando) where enviado_em is null;
create index if not exists avisos_push_user_id on public.avisos_push (user_id);

alter table public.avisos_push enable row level security;
drop policy if exists "avisos_push: dono lê" on public.avisos_push;
create policy "avisos_push: dono lê" on public.avisos_push
  for select to authenticated using (user_id = (select auth.uid()));

-- O aparelho passa a avisar a conta logada. Se outra conta já tinha esse
-- aparelho (troca de conta no mesmo iPhone), ele muda de dono.
-- (Parâmetros com nomes próprios: um chamado "auth" taparia o auth.uid().)
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
  insert into public.push_inscricoes as i (endpoint, user_id, p256dh, auth, aparelho)
  values (endpoint_push, uid, chave_p256dh, chave_auth, left(nome_aparelho, 120))
  on conflict (endpoint) do update
    set user_id = uid,
        p256dh = excluded.p256dh,
        auth = excluded.auth,
        aparelho = excluded.aparelho,
        atualizado_em = now();
end;
$$;

-- Troca a agenda da conta pela lista nova (só avisos futuros, no máximo 100).
-- avisos: [{"quando": "2026-10-21T12:00:00Z", "titulo": "...", "corpo": "..."}]
create or replace function public.substituir_avisos(avisos jsonb)
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
  delete from public.avisos_push where user_id = uid and enviado_em is null and not teste;
  insert into public.avisos_push (user_id, quando, titulo, corpo)
  select uid, (a ->> 'quando')::timestamptz, left(coalesce(a ->> 'titulo', 'Aurora'), 200),
         left(coalesce(a ->> 'corpo', ''), 300)
  from jsonb_array_elements(coalesce(avisos, '[]'::jsonb)) as a
  where (a ->> 'quando')::timestamptz > now()
  limit 100;
end;
$$;

-- Aviso de teste daqui a alguns segundos (chega no próximo minuto do pg_cron).
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
  insert into public.avisos_push (user_id, quando, titulo, corpo, teste)
  values (uid, now(), 'Aurora', 'Os avisos estão funcionando neste aparelho.', true);
end;
$$;

-- Usada só pela Edge Function (service_role): marca como enviados os avisos
-- vencidos e devolve os que ainda valem (até 30 min de atraso; os mais velhos,
-- de quando o servidor ficou parado, são descartados). Apaga enviados de mais
-- de 2 dias. "skip locked": duas chamadas juntas nunca mandam o mesmo aviso.
create or replace function public.pegar_avisos_vencidos()
returns table (id bigint, user_id uuid, titulo text, corpo text)
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.avisos_push as a where a.enviado_em < now() - interval '2 days';
  return query
  with vencidos as (
    select a.id from public.avisos_push as a
    where a.enviado_em is null and a.quando <= now()
    order by a.quando
    limit 500
    for update skip locked
  ),
  marcados as (
    update public.avisos_push as a set enviado_em = now()
    from vencidos as v
    where a.id = v.id
    returning a.id, a.user_id, a.titulo, a.corpo, a.quando
  )
  select m.id, m.user_id, m.titulo, m.corpo from marcados as m
  where m.quando > now() - interval '30 minutes';
end;
$$;

revoke all on function public.registrar_push(text, text, text, text) from public, anon;
revoke all on function public.substituir_avisos(jsonb) from public, anon;
revoke all on function public.aviso_de_teste() from public, anon;
revoke all on function public.pegar_avisos_vencidos() from public, anon, authenticated;
grant execute on function public.registrar_push(text, text, text, text) to authenticated;
grant execute on function public.substituir_avisos(jsonb) to authenticated;
grant execute on function public.aviso_de_teste() to authenticated;
grant execute on function public.pegar_avisos_vencidos() to service_role;

-- A cada minuto: só chama a função se houver aviso vencido (sem gastar
-- invocações à toa). A função não exige login: ela só envia o que já venceu.
create extension if not exists pg_cron;
create extension if not exists pg_net with schema extensions;

select cron.unschedule(jobid) from cron.job where jobname = 'avisos-push';
select cron.schedule(
  'avisos-push',
  '* * * * *',
  $cron$
  select net.http_post(
    url := 'https://fhmhmdzbujqhkdsfnbtx.supabase.co/functions/v1/avisos-push',
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := '{}'::jsonb
  )
  where exists (
    select 1 from public.avisos_push where enviado_em is null and quando <= now()
  );
  $cron$
);
