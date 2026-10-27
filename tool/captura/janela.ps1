param(
  [Parameter(Mandatory = $true)][string]$Saida,
  [int]$Largura = 1440,
  [int]$Altura = 920,
  [string]$Processo = 'aurora',
  [int]$Espera = 2000
)

# Captura a janela do app (Windows) num PNG, encaixando-a na área útil do monitor
# em que ela está. Usado para conferir as telas enquanto o app roda com
# `flutter run -d windows`; não faz parte do app.
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class JanelaCaptura {
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h, int x, int y, int w, int hh, bool repaint);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] public static extern IntPtr MonitorFromWindow(IntPtr h, uint flags);
  [DllImport("user32.dll")] public static extern bool GetMonitorInfo(IntPtr hMon, ref MONITORINFO mi);
  public struct RECT { public int Left, Top, Right, Bottom; }
  [StructLayout(LayoutKind.Sequential)]
  public struct MONITORINFO { public int cbSize; public RECT rcMonitor; public RECT rcWork; public uint dwFlags; }
}
"@
[JanelaCaptura]::SetProcessDPIAware() | Out-Null

$p = Get-Process -Name $Processo -ErrorAction SilentlyContinue |
  Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $p) { Write-Error "Janela do processo '$Processo' não encontrada."; exit 1 }
$h = $p.MainWindowHandle

$mi = New-Object JanelaCaptura+MONITORINFO
$mi.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($mi)
[JanelaCaptura]::GetMonitorInfo([JanelaCaptura]::MonitorFromWindow($h, 2), [ref]$mi) | Out-Null
$area = $mi.rcWork
$larguraUtil = $area.Right - $area.Left
$alturaUtil = $area.Bottom - $area.Top

$w = [Math]::Min($Largura, $larguraUtil - 24)
$ht = [Math]::Min($Altura, $alturaUtil - 24)
$xin = $area.Left + [int](($larguraUtil - $w) / 2)
$yin = $area.Top + [Math]::Max(8, [int](($alturaUtil - $ht) / 2))
[JanelaCaptura]::ShowWindow($h, 9) | Out-Null
[JanelaCaptura]::MoveWindow($h, $xin, $yin, $w, $ht, $true) | Out-Null
[JanelaCaptura]::SetForegroundWindow($h) | Out-Null
Start-Sleep -Milliseconds $Espera

$r = New-Object JanelaCaptura+RECT
[JanelaCaptura]::GetWindowRect($h, [ref]$r) | Out-Null
$rw = $r.Right - $r.Left
$rh = $r.Bottom - $r.Top
$bmp = New-Object System.Drawing.Bitmap($rw, $rh)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($r.Left, $r.Top, 0, 0, $bmp.Size)
$dir = Split-Path -Parent $Saida
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
$bmp.Save($Saida, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
"capturado ${rw}x${rh} em $Saida"
