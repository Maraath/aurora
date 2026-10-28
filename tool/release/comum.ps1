# Envio ao balde "atualizacoes" do Supabase, usado por windows.ps1 e android.ps1.
# O CLI do Storage só aceita caminho RELATIVO à raiz do projeto.

$UrlBalde = 'https://fhmhmdzbujqhkdsfnbtx.supabase.co/storage/v1/object/public/atualizacoes'

# Instaladores também no GitHub Releases, num repositório PÚBLICO só deles (é de
# lá que o app baixa as atualizações; o código, em $RepoCodigo, ganha uma cópia
# para quem visita o projeto: PublicarNoCodigo). Desde a 1.10.1 o app
# baixa pelo "url" do versao.json; as versões antigas ainda baixam do balde, por
# isso o balde segue recebendo os instaladores (etapa 1). Etapa 2, quando todos
# estiverem na 1.10.1 ou depois: parar de mandar os instaladores ao balde.
$RepoInstaladores = 'Maraath/aurora-instaladores'
$RepoCodigo = 'Maraath/aurora'

function UrlNoGitHub([string]$tag, [string]$nome) {
  return "https://github.com/$RepoInstaladores/releases/download/$tag/$nome"
}

# gh escreve o andamento no stderr; no PowerShell 5.1 isso viraria erro.
function ChamarGitHub {
  $ErrorActionPreference = 'Continue'
  $saida = gh.exe @args 2>&1 | Out-String
  $codigo = $LASTEXITCODE
  $ErrorActionPreference = 'Stop'
  return [pscustomobject]@{ Ok = ($codigo -eq 0); Saida = $saida.Trim() }
}

# Cria a release (tag no repositório de instaladores) ou troca os arquivos dela.
function PublicarNoGitHub([string]$tag, [string]$titulo, [string]$notas, [string[]]$arquivos) {
  if ((ChamarGitHub release view $tag --repo $RepoInstaladores).Ok) {
    $r = ChamarGitHub release upload $tag @arquivos --repo $RepoInstaladores --clobber
  } else {
    if (-not $notas) { $notas = $titulo }
    # Notas por arquivo UTF-8: pela linha de comando o PowerShell 5.1 estraga os acentos.
    $arquivoNotas = Join-Path $env:TEMP "notas-$tag.txt"
    [IO.File]::WriteAllText($arquivoNotas, $notas, (New-Object Text.UTF8Encoding $false))
    $r = ChamarGitHub release create $tag @arquivos --repo $RepoInstaladores --title $titulo --notes-file $arquivoNotas --latest=false
    Remove-Item $arquivoNotas
  }
  if (-not $r.Ok) { throw "GitHub ($tag) falhou: $($r.Saida)" }
}

# Link fixo para instalar pela 1ª vez: release "baixar" com Aurora-setup.exe e
# Aurora.apk, trocados a cada versão.
function TrocarNoGitHubBaixar([string]$local, [string]$nomeFixo) {
  $pasta = Join-Path (Split-Path $local) 'baixar'
  New-Item -ItemType Directory -Force $pasta | Out-Null
  $copia = Join-Path $pasta $nomeFixo
  Copy-Item $local $copia -Force
  PublicarNoGitHub 'baixar' 'Baixar o Aurora' 'Sempre a versão mais nova. Windows: Aurora-setup.exe. Android: Aurora.apk.' @($copia)
  # O selo "Latest" do GitHub fica sempre nesta (só uma release pode ter): quem
  # abre a página vê os links de download, e as versões por plataforma ficam
  # como histórico (elas são criadas com --latest=false).
  $r = ChamarGitHub release edit 'baixar' --repo $RepoInstaladores --latest
  if (-not $r.Ok) { Write-Warning "Não marquei a release baixar como Latest: $($r.Saida)" }
}

# Release "v<versão>" no repositório do código (público), presa ao commit de
# agora: Windows e Android caem na mesma release, quem publicar primeiro cria.
# Fica como "Latest" para a página do projeto mostrar o download.
function PublicarNoCodigo([string]$versao, [string]$notas, [string[]]$arquivos) {
  $tag = "v$versao"
  if ((ChamarGitHub release view $tag --repo $RepoCodigo).Ok) {
    $r = ChamarGitHub release upload $tag @arquivos --repo $RepoCodigo --clobber
  } else {
    if (-not $notas) { $notas = "Aurora $versao" }
    $notas += @"


**Como instalar**
- **Windows:** ``Aurora-$versao-setup.exe``. O app se atualiza sozinho depois.
- **Android:** ``Aurora-$versao-arm64-v8a.apk`` serve para quase todos os celulares (os outros são para aparelhos antigos de 32 bits e emuladores x86_64). Permita "instalar apps desconhecidos" quando o Android pedir.
- **iPhone / navegador:** https://aurora-ar2.pages.dev (no Safari, "Adicionar à Tela de Início").

O app funciona offline sem conta; a conta só é necessária para sincronizar e usar a assistente com IA.
"@
    $arquivoNotas = Join-Path $env:TEMP "notas-codigo-$tag.txt"
    [IO.File]::WriteAllText($arquivoNotas, $notas, (New-Object Text.UTF8Encoding $false))
    $commit = (git rev-parse HEAD).Trim()
    $r = ChamarGitHub release create $tag @arquivos --repo $RepoCodigo --target $commit --title "Aurora $versao" --notes-file $arquivoNotas --latest
    Remove-Item $arquivoNotas
  }
  # Não para a publicação: o app já está no ar pelo repositório de instaladores.
  if (-not $r.Ok) { Write-Warning "Release no repositório do código ($tag) falhou (o commit já foi enviado ao GitHub?): $($r.Saida)" }
}

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

# Apaga da pasta os instaladores de versões antigas (o balde gratuito tem 1 GB
# e cada versão do Android ocupa ~80 MB). Chamar só depois do versao.json novo
# no ar: daí nenhum app aponta mais para os antigos. Fica o versao.json e os
# arquivos em $manter.
function ApagarAntigos([string]$pasta, [string[]]$manter) {
  $lista = npx --yes supabase --experimental storage ls "ss:///atualizacoes/$pasta/" --linked | Out-String
  if ($LASTEXITCODE -ne 0) { Write-Warning "Não listei $pasta/; nada foi apagado."; return }
  # O CLI imprime um nome por linha, sem aspas ("Aurora-1.2.3-setup.exe").
  $nomes = ($lista -split "`r?`n") | ForEach-Object { $_.Trim() } |
    Where-Object { $_ -match '^Aurora-.+\.(apk|exe)$' }
  $antigos = @($nomes | Where-Object { $manter -notcontains $_ })
  if (-not $antigos) { return }
  Write-Host "Apagando versões antigas de ${pasta}/: $($antigos -join ', ')"
  npx --yes supabase --experimental storage rm ($antigos | ForEach-Object { "ss:///atualizacoes/$pasta/$_" }) --linked --yes
  if ($LASTEXITCODE -ne 0) { Write-Warning "Não apaguei as versões antigas de $pasta/ (a publicação valeu)." }
}
