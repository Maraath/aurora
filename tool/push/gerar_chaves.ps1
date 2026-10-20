# Gera as chaves VAPID dos avisos por Web Push (uma vez só; trocar = todo aparelho precisa ativar de novo).
#   powershell -File tool\push\gerar_chaves.ps1
# Grava C:\src\chaves\aurora-vapid.env (fora do Git, como a chave do Android) e mostra só a chave PÚBLICA,
# que vai em lib/core/avisos_push.dart. O dono cadastra os segredos na Edge Function com:
#   npx supabase secrets set --env-file C:\src\chaves\aurora-vapid.env --project-ref fhmhmdzbujqhkdsfnbtx

$ErrorActionPreference = 'Stop'
$arquivo = 'C:\src\chaves\aurora-vapid.env'
if (Test-Path $arquivo) { throw "$arquivo já existe. Apague antes de gerar chaves novas (os aparelhos terão de ativar de novo)." }

$chaves = (npx --yes web-push@3.6.7 generate-vapid-keys --json) | ConvertFrom-Json
New-Item -ItemType Directory -Force (Split-Path $arquivo) | Out-Null
[IO.File]::WriteAllText($arquivo,
  "VAPID_PUBLICO=$($chaves.publicKey)`nVAPID_PRIVADO=$($chaves.privateKey)`n",
  (New-Object Text.UTF8Encoding $false))
Write-Host "Chaves gravadas em $arquivo"
Write-Host "Chave pública (vai no app): $($chaves.publicKey)"
