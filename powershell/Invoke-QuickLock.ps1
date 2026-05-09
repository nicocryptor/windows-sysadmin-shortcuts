<#
.SYNOPSIS
Bloqueo de la estacion con opciones extra.

.DESCRIPTION
Llama directo a user32!LockWorkStation via P/Invoke. Mas rapido y robusto
que rundll32 porque permite encadenar acciones previas (limpiar clipboard,
cerrar RDP) y devolver bien el codigo de salida.

.PARAMETER ClearClipboard
Vacia el portapapeles antes de bloquear.

.PARAMETER CloseRDP
Cierra sesiones RDP disconnected del usuario actual antes de bloquear.
Requiere admin.

.EXAMPLE
.\Invoke-QuickLock.ps1

.EXAMPLE
.\Invoke-QuickLock.ps1 -ClearClipboard -CloseRDP
#>
[CmdletBinding()]
param(
    [switch]$ClearClipboard,
    [switch]$CloseRDP
)

if ($ClearClipboard) {
    try {
        Set-Clipboard -Value $null
        Write-Host "Clipboard vaciado." -ForegroundColor Cyan
    } catch {
        Write-Warning "No se pudo vaciar el clipboard: $($_.Exception.Message)"
    }
}

if ($CloseRDP) {
    $me = $env:USERNAME
    $disconnected = (qwinsta 2>$null) -split "`r?`n" |
        Where-Object { $_ -match $me -and $_ -match 'Disc' }
    foreach ($line in $disconnected) {
        $id = ($line.Trim() -split '\s+')[2]
        if ($id -match '^\d+$') {
            logoff $id 2>$null
            Write-Host "Sesion RDP $id cerrada." -ForegroundColor Cyan
        }
    }
}

$sig = '[DllImport("user32.dll", SetLastError=true)] public static extern bool LockWorkStation();'
$type = Add-Type -MemberDefinition $sig -Name QuickLock -Namespace Win32 -PassThru
$result = $type::LockWorkStation()

if (-not $result) {
    Write-Error "LockWorkStation devolvio false. Codigo: $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error())"
    exit 1
}
