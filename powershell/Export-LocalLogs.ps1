<#
.SYNOPSIS
Exporta logs locales en evtx y/o csv con timestamp en el nombre.

.DESCRIPTION
Snapshot rapido de logs antes de cerrar una investigacion o reiniciar
un equipo. Default exporta Security, System y Application.

.PARAMETER LogNames
Lista de logs a exportar. Default: Security, System, Application.

.PARAMETER OutputPath
Carpeta de salida. Si no existe la crea. Default: .\out

.PARAMETER Format
evtx, csv o both. Default both.

.PARAMETER Hour
Si se pasa, solo exporta eventos de las ultimas N horas.

.EXAMPLE
.\Export-LocalLogs.ps1 -Hour 48

.EXAMPLE
.\Export-LocalLogs.ps1 -LogNames Security -Format evtx -OutputPath D:\evidencia
#>
[CmdletBinding()]
param(
    [string[]]$LogNames = @('Security', 'System', 'Application'),
    [string]$OutputPath = (Join-Path (Get-Location) 'out'),
    [ValidateSet('evtx', 'csv', 'both')]
    [string]$Format = 'both',
    [int]$Hour = 0
)

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

foreach ($log in $LogNames) {
    $baseName = "$log-$stamp"

    if ($Format -in 'evtx', 'both') {
        $evtxFile = Join-Path $OutputPath "$baseName.evtx"
        $query    = if ($Hour -gt 0) {
            $ms = [int]([TimeSpan]::FromHours($Hour).TotalMilliseconds)
            "*[System[TimeCreated[timediff(@SystemTime) <= $ms]]]"
        } else { '*' }

        # wevtutil es mas confiable que Get-WinEvent para exportar evtx
        $cmd = "wevtutil export-log `"$log`" `"$evtxFile`" /q:`"$query`" /ow:true"
        cmd /c $cmd 2>&1 | Out-Null
        if (Test-Path $evtxFile) {
            Write-Host "  evtx -> $evtxFile" -ForegroundColor Green
        } else {
            Write-Warning "  No se pudo exportar $log a evtx"
        }
    }

    if ($Format -in 'csv', 'both') {
        $csvFile = Join-Path $OutputPath "$baseName.csv"
        $filter  = @{ LogName = $log }
        if ($Hour -gt 0) { $filter.StartTime = (Get-Date).AddHours(-$Hour) }

        try {
            Get-WinEvent -FilterHashtable $filter -ErrorAction Stop |
                Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, Message |
                Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
            Write-Host "  csv  -> $csvFile" -ForegroundColor Green
        } catch {
            if ($_.Exception.Message -match 'No events were found') {
                Write-Host "  csv  -> sin eventos en $log" -ForegroundColor Yellow
            } else {
                Write-Warning "  Error exportando $log a csv: $($_.Exception.Message)"
            }
        }
    }
}
