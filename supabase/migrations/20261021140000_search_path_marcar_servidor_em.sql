-- Aviso do Supabase (lint 0011, function_search_path_mutable): a função do
-- gatilho de sincronização não fixava o search_path. Ela só usa
-- clock_timestamp(), do pg_catalog, que vale mesmo com search_path vazio.
-- Pode rodar de novo. Para voltar: alter function ... reset search_path.

alter function public.marcar_servidor_em() set search_path = '';
