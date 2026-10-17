# Publica uma versão do Aurora para Android (APK assinado).
#
#   1. Suba a versão no pubspec.yaml (ex.: version: 1.0.2+3). O número depois
#      do "+" é o versionCode: tem de crescer a cada publicação.
#   2. Na raiz do projeto:  powershell -File tool\release\android.ps1 -Notas "O que mudou"
#
# Precisa da chave de lançamento (C:\src\chaves\aurora-lancamento.jks) e da
# senha em android\key.properties. Sem elas o APK sairia com a chave de debug
# e não atualizaria o app instalado, por isso o script para.
# O APK e o android/versao.json vão para o balde "atualizacoes" do Supabase.
# Use -SemEnviar para só gerar o APK (build\instalador).

param(
  [string]$Notas = '',
  [switch]$SemEnviar
)

$ErrorActionPreference = 'Stop'
Set-Location (Resolve-Path "$PSScriptRoot\..\..")

if (-not (Test-Path android\key.properties)) { throw 'Falta android\key.properties (chave de lançamento).' }

$linha = Select-String -Path pubspec.yaml -Pattern '^version:\s*(\d+\.\d+\.\d+)\+(\d+)' | Select-Object -First 1
if (-not $linha) { throw 'Não achei "version: x.y.z+n" no pubspec.yaml.' }
$versao = $linha.Matches[0].Groups[1].Value
$build = [int]$linha.Matches[0].Groups[2].Value
Write-Host "Aurora $versao (build $build)"

# Mesmas variáveis do CLAUDE.md: sem elas o Gradle falha neste PC.
$u = [Environment]::GetEnvironmentVariables('User')
$env:GRADLE_USER_HOME = $u.GRADLE_USER_HOME
$env:JAVA_TOOL_OPTIONS = $u.JAVA_TOOL_OPTIONS

# Um APK por arquitetura: o universal passa dos 50 MB que o Storage gratuito
# aceita por arquivo. O app baixa o da arquitetura do aparelho.
flutter build apk --release --split-per-abi
if ($LASTEXITCODE -ne 0) { throw 'flutter build falhou.' }

$bt = Get-ChildItem C:\Android\Sdk\build-tools | Sort-Object Name | Select-Object -Last 1
New-Item -ItemType Directory -Force build\instalador | Out-Null
$abis = [ordered]@{}
foreach ($abi in 'arm64-v8a', 'armeabi-v7a', 'x86_64') {
  $origem = "build\app\outputs\flutter-apk\app-$abi-release.apk"
  # Confere que saiu com a chave de lançamento, não a de debug.
  $certificado = & "$($bt.FullName)\apksigner.bat" verify --print-certs $origem | Out-String
  if ($certificado -notmatch 'CN=Maraath') { throw "O APK $abi não saiu com a chave de lançamento:`n$certificado" }
  $nome = "Aurora-$versao-$abi.apk"
  Copy-Item $origem "build\instalador\$nome" -Force
  $abis[$abi] = [ordered]@{ instalador = $nome; sha256 = (Get-FileHash "build\instalador\$nome" -Algorithm SHA256).Hash.ToLower() }
  Write-Host "APK: build\instalador\$nome ($([math]::Round((Get-Item "build\instalador\$nome").Length / 1MB, 1)) MB)"
}
$json = [ordered]@{ versao = $versao; build = $build; notas = $Notas; abis = $abis } | ConvertTo-Json -Depth 4
[IO.File]::WriteAllText("$PWD\build\instalador\versao-android.json", $json, (New-Object Text.UTF8Encoding $false))

if ($SemEnviar) { return }

# Os APKs vão antes do versao.json. Aurora.apk (arm64, o de quase todo
# celular) é o link fixo para instalar pela 1ª vez.
. "$PSScriptRoot\comum.ps1"
foreach ($a in $abis.Values) { Enviar "build\instalador\$($a.instalador)" "android/$($a.instalador)" }
Substituir "build\instalador\$($abis['arm64-v8a'].instalador)" 'baixar/Aurora.apk'
Substituir build\instalador\versao-android.json 'android/versao.json'
Write-Host "Publicado: Aurora $versao para Android"
Write-Host "Link fixo para baixar: $UrlBalde/baixar/Aurora.apk"