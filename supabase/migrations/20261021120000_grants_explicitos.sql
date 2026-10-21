-- Permissões explícitas da Data API (PostgREST/supabase-js) nas tabelas existentes.
--
-- Até 30/10/2026 o Supabase dava esses privilégios sozinho a toda tabela nova do
-- schema public (default privileges). Depois disso, um projeto novo, uma branch
-- ou um `supabase db reset` criaria as tabelas das migrations anteriores SEM
-- acesso pela API ("permission denied"). Esta migration reproduz exatamente o que
-- a produção tem hoje, sem restringir nada: as 3 roles com todos os privilégios
-- (quem protege os dados é o RLS, ligado em todas). GRANT repetido não dá erro,
-- então ela pode rodar de novo.

grant usage on schema public to anon, authenticated, service_role;

grant select, insert, update, delete, truncate, references, trigger on table
  public.alimentos,
  public.alvos_dieta,
  public.automacoes,
  public.avisos_push,
  public.conclusoes_tarefa,
  public.contas_financeiras,
  public.exercicios,
  public.fotos_shape,
  public.habitos,
  public.itens_treino,
  public.lembretes,
  public.medidas,
  public.mensagens_assistente,
  public.metas,
  public.pagamentos_transacao,
  public.projetos,
  public.push_inscricoes,
  public.registros_alimentacao,
  public.registros_habito,
  public.series_feitas,
  public.sessoes_treino,
  public.tarefas,
  public.transacoes,
  public.treinos,
  public.uso_ia
to anon, authenticated, service_role;

-- avisos_push.id é identity.
grant usage, select, update on sequence public.avisos_push_id_seq to anon, authenticated, service_role;

-- Função do gatilho de sincronização (as das RPCs de avisos já têm GRANT na
-- migration 20261020200000_avisos_push.sql).
grant execute on function public.marcar_servidor_em() to anon, authenticated, service_role;
