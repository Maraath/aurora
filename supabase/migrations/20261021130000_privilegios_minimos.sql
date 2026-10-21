-- Privilégios mínimos da Data API. Até aqui as 3 roles tinham tudo em todas as
-- tabelas e só o RLS protegia; agora cada role fica só com o que usa:
--   anon (sem login): nada. O app não lê nem grava sem conta.
--   authenticated (app com login): ler, gravar e atualizar nas tabelas
--     sincronizadas. Exclusão no app é `apagado_em` (um UPDATE), então DELETE não
--     faz falta. push_inscricoes: ler e apagar (desligar avisos); avisos_push e
--     uso_ia: só ler (quem grava são as funções security definer e as Edge Functions).
--   service_role (Edge Functions): ler, gravar, atualizar e apagar em tudo.
--   TRUNCATE, REFERENCES e TRIGGER: ninguém da API.
-- Pode rodar de novo (revoke e grant repetidos não dão erro). Para voltar ao
-- estado anterior, rodar de novo 20261021120000_grants_explicitos.sql.

revoke all on table
  public.alimentos, public.alvos_dieta, public.automacoes, public.avisos_push,
  public.conclusoes_tarefa, public.contas_financeiras, public.exercicios, public.fotos_shape,
  public.habitos, public.itens_treino, public.lembretes, public.medidas,
  public.mensagens_assistente, public.metas, public.pagamentos_transacao, public.projetos,
  public.push_inscricoes, public.registros_alimentacao, public.registros_habito,
  public.series_feitas, public.sessoes_treino, public.tarefas, public.transacoes,
  public.treinos, public.uso_ia
from anon, authenticated, service_role;

-- Tabelas sincronizadas (tabelasSincronizadas em lib/data/sincronizacao.dart).
grant select, insert, update on table
  public.metas, public.projetos, public.tarefas, public.habitos, public.conclusoes_tarefa,
  public.registros_habito, public.contas_financeiras, public.transacoes,
  public.pagamentos_transacao, public.lembretes, public.exercicios, public.treinos,
  public.itens_treino, public.sessoes_treino, public.series_feitas, public.medidas,
  public.fotos_shape, public.alimentos, public.alvos_dieta, public.registros_alimentacao,
  public.mensagens_assistente, public.automacoes
to authenticated;

grant select, delete on table public.push_inscricoes to authenticated;
grant select on table public.avisos_push, public.uso_ia to authenticated;

grant select, insert, update, delete on table
  public.alimentos, public.alvos_dieta, public.automacoes, public.avisos_push,
  public.conclusoes_tarefa, public.contas_financeiras, public.exercicios, public.fotos_shape,
  public.habitos, public.itens_treino, public.lembretes, public.medidas,
  public.mensagens_assistente, public.metas, public.pagamentos_transacao, public.projetos,
  public.push_inscricoes, public.registros_alimentacao, public.registros_habito,
  public.series_feitas, public.sessoes_treino, public.tarefas, public.transacoes,
  public.treinos, public.uso_ia
to service_role;

-- avisos_push só recebe linhas das funções security definer (rodam como dono).
revoke all on sequence public.avisos_push_id_seq from anon, authenticated, service_role;
grant usage, select on sequence public.avisos_push_id_seq to service_role;
