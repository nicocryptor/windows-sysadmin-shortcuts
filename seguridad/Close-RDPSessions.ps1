<#
.SYNOPSIS
Lista sesiones RDP de un host y permite cerrarlas con confirmacion.

.DESCRIPTION
Parsea la salida de qwinsta a objetos. Soporta -WhatIf y -Confirm.
Requiere admin en el host destino.

.PARAMETER ComputerName
Host a consultar. Default localhost.

.PARAMETER Username
Filtra por usuario. Opcional.

.PARAMETER Force
Salta la confirmacion al cerrar sesiones.

.EXAMPLE
.\Close-RDPSessions.ps1 -ComputerName srv-app01 -WhatIf

.EXAMPLE
.\Close-RDPSessions.ps1 -Username juan.perez -Force
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
param(
    [string]$ComputerName = $env:COMPUTERNAME,
    [string]$Username,
    [switch]$Force
)

# qwinsta es el comando viejo pero el mas confiable para esto.
# Get-RDUserSession existe pero solo si hay RDS instalado.
$raw = qwinsta /server:$ComputerName 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "No se pudo consultar $ComputerName : $raw"
    exit 1
}

$sessions = @()
foreach ($line in ($raw | Select-Object -Skip 1)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    # parseo por posicion fija porque qwinsta no respeta delimitador
    $parts = $line.Trim() -split '\s+'
    if ($parts.Count -lt 3) { continue }

    # Si la primera columna empieza con >, es la sesion actual
    $isCurrent = $line.StartsWith('>')
    $clean = if ($isCurrent) { $parts[0].TrimStart('>') } else { $parts[0] }

    # Layout tipico: SESSIONNAME USERNAME ID STATE TYPE DEVICE
    # En sesiones sin usuario, la columna USERNAME esta vacia
    $sessions += [pscustomobject]@{
        SessionName = $clean
        Username    = if ($parts.Count -ge 5) { $parts[1] } else { '' }
        Id          = if ($parts.Count -ge 5) { $parts[2] } else { $parts[1] }
        Estado      = if ($parts.Count -ge 5) { $parts[3] } else { $parts[2] }
        Actual      = $isCurrent
    }
}

if ($Username) {
    $sessions = $sessions | Where-Object { $_.Username -like "*$Username*" }
}

if (-not $sessions) {
    Write-Host "Sin sesiones que coincidan." -ForegroundColor Yellow
    return
}

$sessions | Format-Table -AutoSize | Out-String | Write-Host

foreach ($s in $sessions) {
    if ($s.Estado -in 'Active', 'Disc', 'Disconnected') {
        $target = "$($s.Username) sesion $($s.Id) en $ComputerName"
        if ($Force -or $PSCmdlet.ShouldProcess($target, 'Cerrar sesion')) {
            logoff $s.Id /server:$ComputerName
            Write-Host "  cerrada: $target" -ForegroundColor Green
        }
    }
}
