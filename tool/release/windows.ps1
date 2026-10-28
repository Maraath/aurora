# Publica uma versão do Aurora para Windows.
#
#   1. Suba a versão no pubspec.yaml (ex.: version: 1.0.1+2). O número depois
#      do "+" (build) é o que o app compara: tem de crescer a cada publicação.
#   2. Na raiz do projeto:  powershell -File tool\release\windows.ps1 -Notas "O que mudou"
#
# O script compila, gera o instalador com o Inno Setup, calcula o SHA-256 e
# envia o instalador e o windows/versao.json para o balde "atualizacoes" do
# Supabase. Os apps instalados veem a versão nova na próxima vez que abrirem.
# Use -SemEnviar para só gerar o instalador (build\instalador).

param(
  [string]$Notas = '',
  [switch]$SemEnviar
)

$ErrorActionPreference = 'Stop'
Set-Location (Resolve-Path "$PSScriptRoot\..\..")

$linha = Select-String -Path pubspec.yaml -Pattern '^version:\s*(\d+\.\d+\.\d+)\+(\d+)' | Select-Object -First 1
if (-not $linha) { throw 'Não achei "version: x.y.z+n" no pubspec.yaml.' }
$versao = $linha.Matches[0].Groups[1].Value
$build = [int]$linha.Matches[0].Groups[2].Value
Write-Host "Aurora $versao (build $build)"

$iscc = @(
  "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) { throw 'Inno Setup 6 não encontrado (winget install JRSoftware.InnoSetup).' }

flutter build windows --release
if ($LASTEXITCODE -ne 0) { throw 'flutter build falhou.' }

& $iscc /Q "/DAppVersion=$versao" windows\instalador\aurora.iss
if ($LASTEXITCODE -ne 0) { throw 'Inno Setup falhou.' }

$nome = "Aurora-$versao-setup.exe"
$arquivo = "build\instalador\$nome"
$sha = (Get-FileHash $arquivo -Algorithm SHA256).Hash.ToLower()
. "$PSScriptRoot\comum.ps1"
$tag = "v$versao"
$json = [ordered]@{ versao = $versao; build = $build; notas = $Notas; instalador = $nome; sha256 = $sha
  url = (UrlNoGitHub $tag $nome) } | ConvertTo-Json
[IO.File]::WriteAllText("$PWD\build\instalador\versao.json", $json, (New-Object Text.UTF8Encoding $false))
Write-Host "Instalador: $arquivo ($([math]::Round((Get-Item $arquivo).Length / 1MB, 1)) MB)"

if ($SemEnviar) { return }

# O instalador vai antes do versao.json, para nenhum app ver a versão nova
# sem o arquivo no ar. Aurora-setup.exe é o link fixo para instalar pela 1ª vez.
PublicarVersao $versao $Notas @($arquivo)
TrocarNoGitHubBaixar $arquivo 'Aurora-setup.exe'
Enviar $arquivo "windows/$nome"
Substituir $arquivo 'baixar/Aurora-setup.exe'
Substituir build\instalador\versao.json 'windows/versao.json'
ApagarAntigos 'windows' @($nome)
Write-Host "Publicado: Aurora $versao"
Write-Host "Link fixo para baixar: $(UrlNoGitHub 'baixar' 'Aurora-setup.exe')"