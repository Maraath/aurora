# Restaurar um backup do banco

Os backups ficam em `C:\src\backups\aurora\aurora-AAAA-MM-DD_HHmm.zip` (gerados por `backup.ps1`, toda semana pela
tarefa "Aurora - backup semanal"; o histórico fica em `backup.log` na mesma pasta).

Restaurar é para quando o banco do servidor se perdeu ou foi estragado. Sempre testar primeiro no banco local.

1. Descompactar o zip numa pasta temporária (fora do Git).
2. Testar no banco local (Docker Desktop aberto):
   `npx --yes supabase start`, depois carregar na ordem papéis, esquema e dados com o psql do contêiner:
   `docker exec -i supabase_db_Aurora psql -U postgres -v ON_ERROR_STOP=1 < dados.sql`
   (no banco local o esquema já vem das migrations; pule o `esquema.sql` e o `papeis.sql`).
3. Num projeto novo do Supabase: aplicar as migrations (`supabase db push`) e então só o `dados.sql`, com a URL de
   conexão do projeto (`psql "<url>" -v ON_ERROR_STOP=1 -f dados.sql`). A senha do banco quem tem é o dono.
4. Os arquivos dos baldes não estão no backup: os instaladores saem de `tool/release`, e os GIFs de
   `tool/exercicios/converter.ps1`, e reenviá-los refaz a lista do storage. As fotos do Shape ficam nos aparelhos
   (no modo "Sincronizar", reenviar pelo app).
5. Testado em 21/10/2026: `db reset` local + `dados.sql` devolveu as 4 contas e todas as linhas.
