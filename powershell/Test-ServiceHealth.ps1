<#
.SYNOPSIS
Estado de servicios con dependencias, uptime y cuenta bajo la que corren.

.DESCRIPTION
Util como chequeo previo a un cambio o despues de un reinicio.
Devuelve objetos. Exit code distinto de cero si alguno no esta Running
o tiene una dependencia caida.

.PARAMETER ServiceNames
Lista de servicios a chequear.

.PARAMETER IncludeDependencies
Tambien revisa el estado de servicios de los que dependen los pedidos.

.EXAMPLE
.\Test-ServiceHealth.ps1 -ServiceNames W32Time, MpsSvc, EventLog -IncludeDependencies
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string[]]$ServiceNames,

    [switch]$IncludeDependencies
)

$results = @()
$hasProblems = $false

foreach ($name in $ServiceNames) {
    $svc = Get-CimInstance -ClassName Win32_Service -Filter "Name='$name'"
    if (-not $svc) {
        Write-Warning "Servicio '$name' no encontrado."
        $hasProblems = $true
        continue
    }

    $proc = if ($svc.ProcessId -gt 0) {
        Get-CimInstance -ClassName Win32_Process -Filter "ProcessId=$($svc.ProcessId)"
    } else { $null }

    $deps = @()
    if ($IncludeDependencies) {
        $service = Get-Service -Name $name -ErrorAction SilentlyContinue
        if ($service) {
            $deps = $service.ServicesDependedOn | ForEach-Object {
                [pscustomobject]@{
                    Nombre = $_.Name
                    Estado = $_.Status
                }
            }
            if ($deps | Where-Object { $_.Estado -ne 'Running' }) {
                $hasProblems = $true
            }
        }
    }

    if ($svc.State -ne 'Running' -and $svc.StartMode -ne 'Disabled') {
        $hasProblems = $true
    }

    $results += [pscustomobject]@{
        Nombre        = $svc.Name
        Display       = $svc.DisplayName
        Estado        = $svc.State
        StartMode     = $svc.StartMode
        Cuenta        = $svc.StartName
        PID           = $svc.ProcessId
        IniciadoEn    = if ($proc) { $proc.CreationDate } else { $null }
        Dependencias  = $deps
    }
}

$results

if ($hasProblems) { exit 1 } else { exit 0 }
