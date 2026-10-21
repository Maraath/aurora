# Backup do banco do Supabase (projeto fhmhmdzbujqhkdsfnbtx) para este PC.
#
#   powershell -File tool\backup\backup.ps1
#
# Gera C:\src\backups\aurora\aurora-AAAA-MM-DD_HHmm.zip com:
#   esquema.sql  tabelas, funções, políticas e GRANTs (schemas do projeto)
#   dados.sql    linhas de public (dados dos usuários) e auth (contas). Os
#                arquivos dos baldes não: os instaladores saem do código e os
#                GIFs da pasta Exercicios/ (as tabelas internas do storage
#                barram a restauração e se refazem ao reenviar os arquivos)
#   papeis.sql   roles do banco
# Fica fora do Git e da pasta do perfil (o nome do usuário tem espaço). Os dados
# são pessoais (finanças, contas): não copiar para lugar público. Mantém os 8
# mais recentes. O `supabase db dump` roda o pg_dump no Docker: o script abre o
# Docker Desktop se estiver fechado e fecha de novo no fim.
# Agendado toda semana por tool\backup\agendar.ps1. Restaurar: ver restaurar.md.

param([int]$Manter = 8)

$ErrorActionPreference = 'Stop'
Set-Location (Resolve-Path "$PSScriptRoot\..\..")
$destino = 'C:\src\backups\aurora'
New-Item -ItemType Directory -Force $destino | Out-Null
$log = Join-Path $destino 'backup.log'
function Anotar([string]$texto) {
  $linha = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"
  Write-Host $linha
  Add-Content -Path $log -Value $linha -Encoding UTF8
}

# A tarefa agendada não herda o PATH novo do Docker.
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')

function DockerPronto {
  $ErrorActionPreference = 'Continue'
  docker info 2>&1 | Out-Null
  return $LASTEXITCODE -eq 0
}

$abriDocker = $false
$pasta = $null
try {
  if (-not (DockerPronto)) {
    Anotar 'Abrindo o Docker Desktop...'
    $ErrorActionPreference = 'Continue'
    docker desktop start 2>&1 | Out-Null
    $ErrorActionPreference = 'Stop'
    $abriDocker = $true
    $limite = (Get-Date).AddMinutes(4)
    while (-not (DockerPronto)) {
      if ((Get-Date) -gt $limite) { throw 'O Docker não ficou pronto em 4 minutos.' }
      Start-Sleep -Seconds 5
    }
  }

  $nome = "aurora-$(Get-Date -Format 'yyyy-MM-dd_HHmm')"
  $pasta = Join-Path $env:TEMP $nome
  New-Item -ItemType Directory -Force $pasta | Out-Null

  $partes = @(
    @{ arquivo = 'esquema.sql'; args = @() },
    @{ arquivo = 'dados.sql'; args = @('--data-only', '--use-copy', '--schema', 'public,auth') },
    @{ arquivo = 'papeis.sql'; args = @('--role-only') }
  )
  foreach ($p in $partes) {
    $arquivo = Join-Path $pasta $p.arquivo
    # O CLI escreve o andamento no stderr; no PowerShell 5.1 isso viraria erro.
    $ErrorActionPreference = 'Continue'
    $saida = npx --yes supabase db dump --linked @($p.args) --file $arquivo 2>&1 | Out-String
    $ErrorActionPreference = 'Stop'
    if ($LASTEXITCODE -ne 0) { Anotar ($saida.Trim() -split "`n" | Select-Object -Last 3) }
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $arquivo) -or (Get-Item $arquivo).Length -eq 0) {
      throw "Falhou o $($p.arquivo)."
    }
  }

  $zip = Join-Path $destino "$nome.zip"
  Compress-Archive -Path "$pasta\*" -DestinationPath $zip -Force
  Anotar "Backup pronto: $zip ($([math]::Round((Get-Item $zip).Length / 1MB, 2)) MB)"

  Get-ChildItem $destino -Filter 'aurora-*.zip' | Sort-Object Name -Descending |
    Select-Object -Skip $Manter | ForEach-Object { Remove-Item $_.FullName; Anotar "Apagado o antigo $($_.Name)" }
} catch {
  Anotar "ERRO: $($_.Exception.Message)"
  exit 1
} finally {
  if ($pasta -and (Test-Path $pasta)) { Remove-Item -Recurse -Force $pasta }
  $ErrorActionPreference = 'Continue'
  if ($abriDocker) { docker desktop stop 2>&1 | Out-Null }
}
