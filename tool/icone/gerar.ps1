# Gera os ícones do Aurora a partir de tool\icone\aurora.svg.
#   powershell -File tool\icone\gerar.ps1
# Desenha com o Edge sem janela (headless) e grava:
#   - assets\icone\aurora.png              logo dentro do app
#   - windows\runner\resources\app_icon.ico ícone do .exe e do instalador
#   - android\...\mipmap-*\ic_launcher.png  ícone clássico do Android
#   - android\...\mipmap-*\ic_launcher_fundo.png + mipmap-anydpi-v26 ícone adaptável

$ErrorActionPreference = 'Stop'
Set-Location (Resolve-Path "$PSScriptRoot\..\..")

$edge = @(
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $edge) { throw 'Microsoft Edge não encontrado.' }

$tmp = Join-Path $env:TEMP "aurora-icone"
New-Item -ItemType Directory -Force $tmp | Out-Null
$svg = [IO.File]::ReadAllText("$PWD\tool\icone\aurora.svg")

# Desenha o SVG num PNG de $tamanho px. $arredondado: cantos de 22% (squircle);
# $viewBox maior que 0 0 100 100 mostra mais céu em volta (Android adaptável).
function Desenhar([int]$tamanho, [string]$saida, [bool]$arredondado = $true, [string]$viewBox = '0 0 100 100') {
  $nome = "i$tamanho-$([guid]::NewGuid().ToString('N').Substring(0, 6))"
  [IO.File]::WriteAllText("$tmp\$nome.svg", $svg.Replace('{{VIEWBOX}}', $viewBox))
  $raio = if ($arredondado) { '22%' } else { '0' }
  [IO.File]::WriteAllText("$tmp\$nome.html",
    "<html><body style='margin:0;background:transparent;overflow:hidden'>" +
    "<img src='$nome.svg' style='display:block;width:${tamanho}px;height:${tamanho}px;border-radius:$raio'></body></html>")
  $png = "$tmp\$nome.png"
  $ErrorActionPreference = 'Continue'  # o Edge escreve avisos no stderr
  & $edge --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 `
    --default-background-color=00000000 --user-data-dir="$tmp\perfil" `
    --window-size="$tamanho,$tamanho" --screenshot="$png" "file:///$($tmp.Replace('\','/'))/$nome.html" 2>&1 | Out-Null
  $ErrorActionPreference = 'Stop'
  for ($i = 0; $i -lt 50 -and -not (Test-Path $png); $i++) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path $png)) { throw "O Edge não gerou $saida." }
  New-Item -ItemType Directory -Force (Split-Path $saida) | Out-Null
  Copy-Item $png $saida -Force
}

# ICO com as imagens em PNG dentro (aceito pelo Windows Vista em diante).
function GravarIco([string]$saida, [int[]]$tamanhos) {
  $imagens = foreach ($t in $tamanhos) {
    Desenhar $t "$tmp\ico-$t.png"
    , [IO.File]::ReadAllBytes("$tmp\ico-$t.png")
  }
  $ms = New-Object IO.MemoryStream
  $w = New-Object IO.BinaryWriter $ms
  $w.Write([uint16]0); $w.Write([uint16]1); $w.Write([uint16]$tamanhos.Count)
  $deslocamento = 6 + 16 * $tamanhos.Count
  for ($i = 0; $i -lt $tamanhos.Count; $i++) {
    $t = $tamanhos[$i]; $lado = if ($t -ge 256) { 0 } else { $t }
    $w.Write([byte]$lado); $w.Write([byte]$lado); $w.Write([byte]0); $w.Write([byte]0)
    $w.Write([uint16]1); $w.Write([uint16]32)
    $w.Write([uint32]$imagens[$i].Length); $w.Write([uint32]$deslocamento)
    $deslocamento += $imagens[$i].Length
  }
  foreach ($img in $imagens) { $w.Write($img) }
  $w.Flush()
  [IO.File]::WriteAllBytes("$PWD\$saida", $ms.ToArray())
}

Desenhar 256 'assets\icone\aurora.png'
GravarIco 'windows\runner\resources\app_icon.ico' @(16, 20, 24, 32, 40, 48, 64, 128, 256)

$res = 'android\app\src\main\res'
$densidades = [ordered]@{ mdpi = 1; hdpi = 1.5; xhdpi = 2; xxhdpi = 3; xxxhdpi = 4 }
foreach ($d in $densidades.Keys) {
  $f = $densidades[$d]
  Desenhar ([int](48 * $f)) "$res\mipmap-$d\ic_launcher.png"
  # Adaptável: 108 dp, dos quais o aparelho mostra os 72 do meio.
  Desenhar ([int](108 * $f)) "$res\mipmap-$d\ic_launcher_fundo.png" $false '-18 -18 136 136'
}
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
Write-Host 'Ícones gerados.'
