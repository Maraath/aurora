-- "Me despertar" no lembrete: no Android toca como despertador (tela cheia,
-- som de alarme que repete). Sincroniza para valer em todos os aparelhos.
-- Apps antigos não mandam a coluna e o valor guardado fica como está.
alter table public.lembretes add column if not exists despertar boolean not null default false;
