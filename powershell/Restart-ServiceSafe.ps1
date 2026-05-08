<#
.SYNOPSIS
Reinicia un servicio respetando dependencias y con timeout.

.DESCRIPTION
Stop + Start con espera, retry y log al Event Log de Aplicacion
con fuente 'AdminScripts' y EventID 9001. Requiere admin.

.PARAMETER ServiceName
Nombre del servicio a reiniciar.

.PARAMETER TimeoutSeconds
Espera maxima por cada operacion (stop / start). Default 30.

.PARAMETER Retry
Reintentos si no levanta. Default 1.

.EXAMPLE
.\Restart-ServiceSafe.ps1 -ServiceName Spooler

.EXAMPLE
.\Restart-ServiceSafe.ps1 -ServiceName W32Time -TimeoutSeconds 60 -Retry 2
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ServiceName,

    [int]$TimeoutSeconds = 30,
    [int]$Retry = 1
)

# Aseguro que la fuente del event log exista, requiere admin
$source = 'AdminScripts'
if (-not [System.Diagnostics.EventLog]::SourceExists($source)) {
    try {
        New-EventLog -LogName Application -Source $source -ErrorAction Stop
    } catch {
        Write-Warning "No se pudo registrar la fuente $source. El log a Event Viewer no va a funcionar."
    }
}

function Write-AppLog {
    param([string]$Message, [System.Diagnostics.EventLogEntryType]$Type = 'Information')
    if ([System.Diagnostics.EventLog]::SourceExists($source)) {
        Write-EventLog -LogName Application -Source $source -EventId 9001 -EntryType $Type -Message $Message
    }
}

$attempt = 0
do {
    $attempt++
    Write-Host "[Intento $attempt] Reiniciando $ServiceName" -ForegroundColor Cyan

    $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if (-not $svc) {
        Write-Error "Servicio $ServiceName no existe."
        Write-AppLog "Servicio $ServiceName no existe." Error
        exit 2
    }

    try {
        Stop-Service -Name $ServiceName -Force -ErrorAction Stop
        $svc.WaitForStatus('Stopped', [TimeSpan]::FromSeconds($TimeoutSeconds))
    } catch {
        Write-Warning "Stop fallo: $($_.Exception.Message)"
    }

    try {
        Start-Service -Name $ServiceName -ErrorAction Stop
        $svc.WaitForStatus('Running', [TimeSpan]::FromSeconds($TimeoutSeconds))
    } catch {
        Write-Warning "Start fallo: $($_.Exception.Message)"
    }

    $svc.Refresh()
    if ($svc.Status -eq 'Running') {
        Write-Host "OK, $ServiceName Running" -ForegroundColor Green
        Write-AppLog "Servicio $ServiceName reiniciado correctamente en intento $attempt." Information
        exit 0
    }
} while ($attempt -le $Retry)

Write-Error "$ServiceName no levanto despues de $($Retry + 1) intentos."
Write-AppLog "Servicio $ServiceName no levanto despues de $($Retry + 1) intentos." Error
exit 1
