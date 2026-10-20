# Compila o Aurora para a web (PWA para iPhone/Android pelo navegador).
#   powershell -File tool\release\web.ps1 [-Publicar] [-SemWasm] [-BaseHref /aurora/]
# Sai em build\web, pronto para subir num servidor HTTPS (o Service Worker exige HTTPS).
# Depois do build, preenche web/sw.js com a versão e a lista de arquivos a guardar para offline.

param([switch]$Publicar, [switch]$SemWasm, [string]$BaseHref = '/')

$ErrorActionPreference = 'Stop'
Set-Location (Resolve-Path "$PSScriptRoot\..\..")

# --no-web-resources-cdn: o CanvasKit vai junto (sem ele o app não abre offline, porque viria do gstatic).
# WebAssembly (skwasm, mais rápido por quadro; iOS 18.2+, Chrome, Firefox): o carregador do Flutter escolhe
# sozinho e cai no JavaScript (CanvasKit) onde não houver suporte. -SemWasm volta a só JavaScript.
$opcoes = @('build', 'web', '--release', '--base-href', $BaseHref, '--no-web-resources-cdn')
if (-not $SemWasm) { $opcoes += '--wasm' }
flutter @opcoes
if ($LASTEXITCODE -ne 0) { throw 'flutter build web falhou.' }

$saida = Resolve-Path 'build\web'
$versao = (Select-String -Path pubspec.yaml -Pattern '^version:\s*(\S+)').Matches[0].Groups[1].Value

# Tudo menos: mapas e símbolos, o próprio sw.js, o service worker do Flutter (não usado), arquivos de
# configuração do Cloudflare (_headers, não são servidos), ocultos e as variantes do CanvasKit que o
# Safari não usa (chromium, wimp, webparagraph, skwasm_heavy; o SW guarda se algum navegador pedir).
$arquivos = Get-ChildItem $saida -Recurse -File |
  ForEach-Object { $_.FullName.Substring($saida.Path.Length + 1).Replace('\', '/') } |
  Where-Object {
    $_ -notmatch '\.(map|symbols)$' -and $_ -notmatch '(^|/)[._]' -and
    $_ -notin @('sw.js', 'flutter_service_worker.js') -and
    ($_ -notlike 'canvaskit/*' -or
      $_ -in @('canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm', 'canvaskit/skwasm.js', 'canvaskit/skwasm.wasm'))
  } |
  Sort-Object

# A versão do cache muda junto com qualquer arquivo (hash do conteúdo de todos).
$sha = [Security.Cryptography.SHA256]::Create()
$todos = New-Object IO.MemoryStream
foreach ($a in $arquivos) {
  $b = [IO.File]::ReadAllBytes((Join-Path $saida $a)); $todos.Write($b, 0, $b.Length)
}
$hash = -join ($sha.ComputeHash($todos.ToArray())[0..5] | ForEach-Object { $_.ToString('x2') })

$lista = @('./') + $arquivos | ForEach-Object { '"' + $_ + '"' }
$sw = [IO.File]::ReadAllText("$saida\sw.js")
$sw = $sw.Replace("const VERSAO = 'dev';", "const VERSAO = '$versao-$hash';")
$sw = [regex]::Replace($sw, '/\*ARQUIVOS\*/\[\]/\*FIM\*/', '[' + ($lista -join ',') + ']')
[IO.File]::WriteAllText("$saida\sw.js", $sw, (New-Object Text.UTF8Encoding $false))

Write-Host "Web pronta em build\web (versão $versao-$hash, $($arquivos.Count) arquivos no cache offline)."

# -Publicar: envia ao Cloudflare Pages (projeto "aurora"; o login fica no wrangler, feito uma vez com
# `npx wrangler login`). Sem a opção, só compila.
if ($Publicar) {
  # Arquivos que o Cloudflare não precisa servir (símbolos de depuração).
  Get-ChildItem $saida -Recurse -File -Include *.symbols, *.map, .last_build_id | Remove-Item -Force
  npx --yes wrangler@4.151.2 pages deploy $saida --project-name aurora --branch main --commit-dirty=true
  if ($LASTEXITCODE -ne 0) { throw 'Envio ao Cloudflare Pages falhou.' }
}
