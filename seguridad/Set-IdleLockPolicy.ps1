<#
.SYNOPSIS
Configura el tiempo de bloqueo automatico por inactividad.

.DESCRIPTION
Escribe a las claves de registro del salvapantallas para forzar bloqueo
despues de N segundos de inactividad. Devuelve los valores anteriores
por si hace falta revertir.

En entornos de dominio esto puede ser pisado por GPO. Chequear con
`gpresult /h reporte.html`.

.PARAMETER IdleSeconds
Segundos de inactividad antes del bloqueo. Minimo 60.

.PARAMETER Scope
'User' aplica solo al usuario actual (HKCU). 'Machine' aplica a todos
los usuarios via HKLM y requiere admin.

.PARAMETER Revert
Vuelve los valores al estado anterior si previamente se corrio el script.

.EXAMPLE
.\Set-IdleLockPolicy.ps1 -IdleSeconds 300 -Scope User

.EXAMPLE
.\Set-IdleLockPolicy.ps1 -IdleSeconds 600 -Scope Machine
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateRange(60, 7200)]
    [int]$IdleSeconds,

    [ValidateSet('User', 'Machine')]
    [string]$Scope = 'User',

    [switch]$Revert
)

$paths = @{
    User    = 'HKCU:\Control Panel\Desktop'
    Machine = 'HKLM:\Software\Policies\Microsoft\Windows\Control Panel\Desktop'
}
$path = $paths[$Scope]
$backupPath = Join-Path $env:LOCALAPPDATA "idlelock-backup-$Scope.json"

if ($Revert) {
    if (-not (Test-Path $backupPath)) {
        Write-Error "No hay backup en $backupPath para revertir."
        exit 1
    }
    $backup = Get-Content $backupPath -Raw | ConvertFrom-Json
    foreach ($prop in $backup.PSObject.Properties) {
        Set-ItemProperty -Path $path -Name $prop.Name -Value $prop.Value
    }
    Write-Host "Valores revertidos desde $backupPath" -ForegroundColor Green
    return
}

if ($Scope -eq 'Machine' -and -not (Test-Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

$keys = 'ScreenSaveActive', 'ScreenSaverIsSecure', 'ScreenSaveTimeOut'
$current = @{}
foreach ($k in $keys) {
    $current[$k] = (Get-ItemProperty -Path $path -Name $k -ErrorAction SilentlyContinue).$k
}
$current | ConvertTo-Json | Set-Content -Path $backupPath -Encoding UTF8

Set-ItemProperty -Path $path -Name ScreenSaveActive    -Value '1'
Set-ItemProperty -Path $path -Name ScreenSaverIsSecure -Value '1'
Set-ItemProperty -Path $path -Name ScreenSaveTimeOut   -Value $IdleSeconds.ToString()

Write-Host "Bloqueo por inactividad configurado a $IdleSeconds segundos en $Scope." -ForegroundColor Green
Write-Host "Backup guardado en $backupPath" -ForegroundColor DarkGray
Write-Host "Aviso: si estas en dominio, la GPO puede pisar este valor." -ForegroundColor Yellow
