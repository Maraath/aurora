# Envio ao balde "atualizacoes" do Supabase, usado por windows.ps1 e android.ps1.
# O CLI do Storage só aceita caminho RELATIVO à raiz do projeto.

$UrlBalde = 'https://fhmhmdzbujqhkdsfnbtx.supabase.co/storage/v1/object/public/atualizacoes'

# O CLI adivinha o tipo pelo conteúdo e marca o APK (um zip por dentro) como
# application/zip: o celular baixa "Aurora.zip" e não instala. Por isso o
# tipo vai explícito para o que tem extensão conhecida.
function TipoDe([string]$remoto) {
  switch ([IO.Path]::GetExtension($remoto).ToLower()) {
    '.apk'  { return 'application/vnd.android.package-archive' }
    '.exe'  { return 'application/vnd.microsoft.portable-executable' }
    '.json' { return 'application/json' }
    default { return 'auto-detect' }
  }
}

# Arquivo novo, com nome da versão (nunca muda depois de publicado).
function Enviar([string]$local, [string]$remoto) {
  npx --yes supabase --experimental storage cp $local "ss:///atualizacoes/$remoto" --linked --content-type (TipoDe $remoto)
  if ($LASTEXITCODE -ne 0) { throw "Envio de $remoto falhou." }
}

# Arquivo de nome fixo que troca a cada versão (versao.json e links fixos de
# download): apaga o antigo e envia com cache curto, para valer em 1 minuto.
function Substituir([string]$local, [string]$remoto) {
  $ErrorActionPreference = 'Continue'  # na primeira publicação ainda não existe
  npx --yes supabase --experimental storage rm "ss:///atualizacoes/$remoto" --linked --yes 2>&1 | Out-Null
  $ErrorActionPreference = 'Stop'
  npx --yes supabase --experimental storage cp $local "ss:///atualizacoes/$remoto" --linked --cache-control 'max-age=60' --content-type (TipoDe $remoto)
  if ($LASTEXITCODE -ne 0) { throw "Envio de $remoto falhou." }
}
