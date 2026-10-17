# Desenha tool\paginas\confirmado.html como PNG e envia ao balde público
# "atualizacoes" (paginas/confirmado.png). É para lá que o link de confirmação
# do cadastro leva (emailRedirectTo em lib/ui/conta/conta_page.dart).
#   powershell -File tool\paginas\gerar.ps1          (gera e envia)
#   powershell -File tool\paginas\gerar.ps1 -SemEnviar

param([switch]$SemEnviar)

$ErrorActionPreference = 'Stop'
Set-Location (Resolve-Path "$PSScriptRoot\..\..")

$edge = @(
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $edge) { throw 'Microsoft Edge não encontrado.' }

$tmp = Join-Path $env:TEMP 'aurora-paginas'
New-Item -ItemType Directory -Force $tmp | Out-Null
Copy-Item tool\paginas\confirmado.html "$tmp\confirmado.html" -Force
Copy-Item assets\icone\aurora.png "$tmp\logo.png" -Force
$png = "$tmp\confirmado.png"
Remove-Item $png -ErrorAction SilentlyContinue

$ErrorActionPreference = 'Continue'  # o Edge escreve avisos no stderr
& $edge --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 `
  --virtual-time-budget=4000 --user-data-dir="$tmp\perfil" --window-size="1200,800" `
  --screenshot="$png" "file:///$($tmp.Replace('\','/'))/confirmado.html" 2>&1 | Out-Null
$ErrorActionPreference = 'Stop'
for ($i = 0; $i -lt 50 -and -not (Test-Path $png); $i++) { Start-Sleep -Milliseconds 200 }
if (-not (Test-Path $png)) { throw 'O Edge não gerou a imagem.' }

New-Item -ItemType Directory -Force build\paginas | Out-Null
Copy-Item $png build\paginas\confirmado.png -Force
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
Write-Host 'Imagem: build\paginas\confirmado.png'
if ($SemEnviar) { return }

. "$PSScriptRoot\..\release\comum.ps1"
Substituir build\paginas\confirmado.png 'paginas/confirmado.png'
Write-Host "Publicada: $UrlBalde/paginas/confirmado.png"
