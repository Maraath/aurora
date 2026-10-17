-- Animações dos exercícios (WebP gerados por tool/exercicios/converter.ps1).
-- Balde público: qualquer um lê pela URL; só a chave de serviço (CLI) grava.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('exercicios', 'exercicios', true, 10485760, array['image/webp'])
on conflict (id) do nothing;
