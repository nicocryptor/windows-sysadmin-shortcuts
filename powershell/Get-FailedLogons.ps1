<#
.SYNOPSIS
Logons fallidos (4625) agrupados por usuario, IP origen y workstation.

.DESCRIPTION
Para detectar intentos de fuerza bruta o credenciales rotas rapido.
Devuelve los grupos que superan un umbral minimo de intentos.

.PARAMETER Minutes
Ventana de tiempo hacia atras en minutos. Default 60.

.PARAMETER MinAttempts
Minimo de intentos para que aparezca en el resultado. Default 3.

.EXAMPLE
.\Get-FailedLogons.ps1 -Minutes 1440 -MinAttempts 5

.EXAMPLE
.\Get-FailedLogons.ps1 -Minutes 10 | Format-Table -AutoSize
#>
[CmdletBinding()]
param(
    [int]$Minutes = 60,
    [int]$MinAttempts = 3
)

$hours = [Math]::Max(1, [Math]::Ceiling($Minutes / 60))
$rawEvents = & "$PSScriptRoot\Get-SecurityEvents.ps1" -Hours $hours -EventIds 4625 -MaxEvents 5000

if (-not $rawEvents) { return }

$cutoff = (Get-Date).AddMinutes(-$Minutes)
$rawEvents = $rawEvents | Where-Object { $_.TimeCreated -ge $cutoff }

$rawEvents |
    Group-Object Usuario, IPOrigen, Workstation |
    Where-Object { $_.Count -ge $MinAttempts } |
    ForEach-Object {
        $sorted = $_.Group | Sort-Object TimeCreated
        [pscustomobject]@{
            Usuario      = $sorted[0].Usuario
            IPOrigen     = $sorted[0].IPOrigen
            Workstation  = $sorted[0].Workstation
            Intentos     = $_.Count
            PrimerIntento = $sorted[0].TimeCreated
            UltimoIntento = $sorted[-1].TimeCreated
        }
    } |
    Sort-Object Intentos -Descending
