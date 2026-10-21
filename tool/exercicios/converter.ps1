# Converte os GIFs de Exercicios/ em WebP animado leve e monta a lista do app.
#
# Uso (na pasta do projeto):  powershell -File tool/exercicios/converter.ps1
#   - Entrada: Exercicios/<qualquer coisa>/<Grupo (N)>/<Nome do exercício>.gif
#   - Saída:   build/exercicios_webp/<id>.webp  (360 px, 12 quadros/s, qualidade 55,
#              WebP animado com quadros diferenciais: libwebp_anim guarda só o que muda
#              e junta quadros repetidos; 21/10/2026: 132 MB -> ~45 MB, mesma imagem)
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
foreach ($g in $arquivos) {
    # Nomes vindos do Mac usam acentos "decompostos": normaliza para a forma comum.
    $nome = $g.BaseName.Normalize([Text.NormalizationForm]::FormC).Trim() -replace '\s+', ' '
    $grupo = ($g.Directory.Name.Normalize([Text.NormalizationForm]::FormC) -replace '\s*\(\d+\)\s*$', '').Trim()
    $id = Get-Id $nome
    if ($usados.ContainsKey($id)) { $id = "$id-$(Get-Id $grupo)" }
    $usados[$id] = $true
    $itens.Add([ordered]@{ id = $id; n = $nome; g = $grupo; a = "$id.webp"; kb = 0; gif = $g.FullName })
}

# O libwebp_anim é lento (compara quadro a quadro): vários FFmpeg ao mesmo tempo.
# Cada um grava em .parcial e só renomeia no fim, para uma interrupção não
# deixar arquivo pela metade (os prontos são pulados na próxima vez).
$pendentes = @($itens | Where-Object { -not (Test-Path (Join-Path $saida $_['a'])) })
$simultaneos = [Math]::Max(1, [Environment]::ProcessorCount - 1)
Write-Output "$($pendentes.Count) para converter ($simultaneos ao mesmo tempo)"
$rodando = New-Object System.Collections.Generic.List[object]
$feitos = 0
function Concluir($p) {
    $p.Processo.WaitForExit()
    if ($p.Processo.ExitCode -eq 0) { Move-Item -Force $p.Parcial $p.Destino }
    else { Write-Output "FALHOU: $($p.Gif)"; Remove-Item -Force $p.Parcial -ErrorAction SilentlyContinue }
    $script:feitos++
    if ($script:feitos % 25 -eq 0) { Write-Output "$script:feitos de $($pendentes.Count)" }
}
foreach ($i in $pendentes) {
    while ($rodando.Count -ge $simultaneos) {
        $pronto = $rodando | Where-Object { $_.Processo.HasExited } | Select-Object -First 1
        if ($pronto) { Concluir $pronto; [void]$rodando.Remove($pronto) } else { Start-Sleep -Milliseconds 200 }
    }
    $destino = Join-Path $saida $i['a']
    $parcial = "$destino.parcial"
    $argumentos = @('-hide_banner', '-loglevel', 'error', '-y', '-i', "`"$($i['gif'])`"",
        '-vf', "`"fps=12,scale='min(360,iw)':-2:flags=lanczos`"",
        '-c:v', 'libwebp_anim', '-lossless', '0', '-quality', '55', '-compression_level', '6',
        '-loop', '0', '-an', '-f', 'webp', "`"$parcial`"")
    $processo = Start-Process -FilePath $ffmpeg -ArgumentList $argumentos -NoNewWindow -PassThru
    $null = $processo.Handle  # sem isso o ExitCode volta vazio depois que o processo termina
    $rodando.Add([pscustomobject]@{ Processo = $processo; Parcial = $parcial; Destino = $destino; Gif = $i['gif'] })
}
foreach ($p in $rodando.ToArray()) { Concluir $p }

foreach ($i in $itens.ToArray()) {
    $destino = Join-Path $saida $i['a']
    if (-not (Test-Path $destino)) { [void]$itens.Remove($i); continue }
    $i['kb'] = [math]::Round((Get-Item $destino).Length / 1KB)
    $i.Remove('gif')
}

$json = [ordered]@{ exercicios = $itens } | ConvertTo-Json -Depth 4 -Compress
[IO.File]::WriteAllText((Join-Path $raiz 'assets\exercicios.json'), $json, (New-Object Text.UTF8Encoding $false))
$total = ($itens | ForEach-Object { $_['kb'] } | Measure-Object -Sum).Sum
Write-Output ("PRONTO: {0} exercícios, {1:N1} MB em WebP" -f $itens.Count, ($total / 1024))
