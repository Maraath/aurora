-- Atualizações do app: instaladores e o versao.json de cada plataforma
-- (ex.: windows/versao.json, windows/Aurora-1.0.1-setup.exe).
-- Balde público: o app lê sem login; só o CLI (chave de serviço) grava.

insert into storage.buckets (id, name, public, file_size_limit)
values ('atualizacoes', 'atualizacoes', true, 209715200)
on conflict (id) do nothing;
