# Agenda o backup.ps1 toda semana (domingo, 20:00) no Agendador de Tarefas do
# Windows, para o usuário atual. Se o PC estiver desligado na hora, roda assim
# que ligar. Para tirar: Unregister-ScheduledTask -TaskName 'Aurora - backup semanal'
#
#   powershell -File tool\backup\agendar.ps1

$ErrorActionPreference = 'Stop'
$script = (Resolve-Path "$PSScriptRoot\backup.ps1").Path
$acao = New-ScheduledTaskAction -Execute 'powershell.exe' `
  -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script`""
$quando = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At '20:00'
$opcoes = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
  -ExecutionTimeLimit (New-TimeSpan -Minutes 30)
Register-ScheduledTask -TaskName 'Aurora - backup semanal' -Action $acao -Trigger $quando -Settings $opcoes `
  -Description 'Copia o banco do Supabase do Aurora para C:\src\backups\aurora (tool\backup\backup.ps1).' -Force |
  Select-Object TaskName, State
