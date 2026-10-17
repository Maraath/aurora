# Converte os GIFs de Exercicios/ em WebP animado leve e monta a lista do app.
#
# Uso (na pasta do projeto):  powershell -File tool/exercicios/converter.ps1
#   - Entrada: Exercicios/<qualquer coisa>/<Grupo (N)>/<Nome do exercício>.gif
#   - Saída:   build/exercicios_webp/<id>.webp  (360 px, 12 quadros/s, qualidade 55)
#              assets/exercicios.json            (id, nome, grupo, arquivo, tamanho)
# Arquivos já convertidos são pulados (dá para interromper e continuar).
# Precisa do FFmpeg (winget install Gyan.FFmpeg).
#
# Depois, enviar para o balde público "exercicios" do Supabase (CLI já logado;
# caminho RELATIVO, o CLI confunde "D:\" com endereço):
#   npx --yes supabase --experimental storage cp -r build/exercicios_webp ss:///exercicios --content-type image/webp -j 8
# (cria a pasta "exercicios_webp/" no balde: é o caminho que o app usa, ver
#  pastaAnimacoes em lib/data/biblioteca_exercicios.dart)

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$origem = Join-Path $raiz 'Exercicios'
$saida = Join-Path $raiz 'build\exercicios_webp'
$ffmpeg = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\ffmpeg.exe'
New-Item -ItemType Directory -Force $saida | Out-Null

# "Rosca Bíceps (2)" -> "rosca-biceps-2" (sem acento, só a-z, 0-9 e hífen).
function Get-Id([string]$texto) {
    $d = $texto.Normalize([Text.NormalizationForm]::FormD)
    $sem = -join ($d.ToCharArray() | Where-Object {
            [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne 'NonSpacingMark' })
    $s = ($sem.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
    return $s
}

$itens = New-Object System.Collections.Generic.List[object]
$usados = @{}
$arquivos = Get-ChildItem $origem -Recurse -File -Filter *.gif | Sort-Object FullName
$n = 0
foreach ($g in $arquivos) {
    $n++
    # Nomes vindos do Mac usam acentos "decompostos": normaliza para a forma comum.
    $nome = $g.BaseName.Normalize([Text.NormalizationForm]::FormC).Trim() -replace '\s+', ' '
    $grupo = ($g.Directory.Name.Normalize([Text.NormalizationForm]::FormC) -replace '\s*\(\d+\)\s*$', '').Trim()
    $id = Get-Id $nome
    if ($usados.ContainsKey($id)) { $id = "$id-$(Get-Id $grupo)" }
    $usados[$id] = $true

    $destino = Join-Path $saida "$id.webp"
    if (-not (Test-Path $destino)) {
        & $ffmpeg -hide_banner -loglevel error -y -i $g.FullName `
            -vf "fps=12,scale='min(360,iw)':-2:flags=lanczos" `
            -c:v libwebp -lossless 0 -q:v 55 -compression_level 6 -loop 0 -an $destino
        if ($LASTEXITCODE -ne 0) { Write-Output "FALHOU: $($g.FullName)"; continue }
    }
    $kb = [math]::Round((Get-Item $destino).Length / 1KB)
    $itens.Add([ordered]@{ id = $id; n = $nome; g = $grupo; a = "$id.webp"; kb = $kb })
    if ($n % 25 -eq 0) { Write-Output "$n de $($arquivos.Count)" }
}

$json = [ordered]@{ exercicios = $itens } | ConvertTo-Json -Depth 4 -Compress
[IO.File]::WriteAllText((Join-Path $raiz 'assets\exercicios.json'), $json, (New-Object Text.UTF8Encoding $false))
$total = ($itens | ForEach-Object { $_['kb'] } | Measure-Object -Sum).Sum
Write-Output ("PRONTO: {0} exercícios, {1:N1} MB em WebP" -f $itens.Count, ($total / 1024))
