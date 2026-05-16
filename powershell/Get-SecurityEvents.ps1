<#
.SYNOPSIS
Devuelve eventos del log Security filtrados por horas y por IDs.

.DESCRIPTION
Wrapper de Get-WinEvent con un FilterHashtable armado. Devuelve objetos,
no strings, asi se puede pipear a Format-Table, Export-Csv u Out-GridView.

Los EventIds default son los de autenticacion y administracion de cuentas
que mas reviso: logon (4624), logon fallido (4625), logoff (4634), elevacion
(4672), creacion de cuenta (4720), Kerberos TGT (4768) y TGS (4769), NTLM (4776).

.PARAMETER Hours
Cantidad de horas hacia atras. Default 24.

.PARAMETER EventIds
Lista de EventIds a filtrar. Si no se pasa, usa el default.

.PARAMETER ComputerName
Equipo a consultar. Default: localhost.

.PARAMETER MaxEvents
Tope de eventos devueltos. Default 1000.

.EXAMPLE
.\Get-SecurityEvents.ps1 -Hours 1 | Out-GridView

.EXAMPLE
.\Get-SecurityEvents.ps1 -Hours 168 -EventIds 4625 | Export-Csv .\out\failed.csv -NoTypeInformation
#>
[CmdletBinding()]
param(
    [int]$Hours = 24,
    [int[]]$EventIds = @(4624, 4625, 4634, 4672, 4720, 4768, 4769, 4776),
    [string]$ComputerName = $env:COMPUTERNAME,
    [int]$MaxEvents = 1000
)

$start = (Get-Date).AddHours(-$Hours)

$filter = @{
    LogName   = 'Security'
    StartTime = $start
    Id        = $EventIds
}

try {
    Get-WinEvent -FilterHashtable $filter -MaxEvents $MaxEvents -ComputerName $ComputerName -ErrorAction Stop |
        Select-Object TimeCreated, Id,
            @{N='Usuario'; E={ ($_.Properties[5].Value) }},
            @{N='Dominio'; E={ ($_.Properties[6].Value) }},
            @{N='IPOrigen'; E={ ($_.Properties[18].Value) }},
            @{N='Workstation'; E={ ($_.Properties[11].Value) }},
            Message
}
catch [System.Diagnostics.Eventing.Reader.EventLogNotFoundException] {
    Write-Error "No se encontro el log Security en $ComputerName."
}
catch {
    if ($_.Exception.Message -match 'No events were found') {
        Write-Host "Sin eventos en el rango pedido." -ForegroundColor Yellow
    } else {
        throw
    }
}
