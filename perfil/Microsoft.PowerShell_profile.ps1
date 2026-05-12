# Profile que cargo en mi sesion. Funciona en PowerShell 5.1 y 7.

# ---- Variables ----
$Global:AdminScripts = Split-Path -Parent $PSScriptRoot

# ---- Prompt ----
# Si estoy elevado, marco [ADMIN] en rojo. Asi nunca me equivoco en que ventana estoy.
function prompt {
    $location  = (Get-Location).Path
    $shortLoc  = if ($location.Length -gt 50) { '...' + $location.Substring($location.Length - 47) } else { $location }
    $isAdmin   = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($isAdmin) {
        Write-Host '[ADMIN] ' -NoNewline -ForegroundColor Red
    }
    Write-Host $env:USERNAME -NoNewline -ForegroundColor Cyan
    Write-Host ' ' -NoNewline
    Write-Host $shortLoc -NoNewline -ForegroundColor DarkGray
    return "`nPS> "
}

# ---- Aliases ----
Set-Alias ll  Get-ChildItem
Set-Alias which Get-Command

function touch {
    param([Parameter(Mandatory)][string]$Path)
    if (Test-Path $Path) {
        (Get-Item $Path).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $Path | Out-Null
    }
}

# ---- Funciones rapidas ----
function Get-PublicIP {
    try {
        (Invoke-RestMethod -Uri 'https://api.ipify.org?format=json' -TimeoutSec 5).ip
    } catch {
        Write-Warning "No se pudo consultar IP publica: $($_.Exception.Message)"
    }
}

function Get-ListeningPorts {
    Get-NetTCPConnection -State Listen |
        Select-Object LocalAddress, LocalPort,
            @{N='Proceso'; E={ (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name }} |
        Sort-Object LocalPort -Unique
}

function Get-LastLogons {
    param([int]$Count = 10)
    Get-WinEvent -FilterHashtable @{ LogName='Security'; Id=4624 } -MaxEvents $Count |
        Select-Object TimeCreated,
            @{N='Usuario'; E={ $_.Properties[5].Value }},
            @{N='Tipo'; E={ $_.Properties[8].Value }}
}

# ---- PSReadLine ----
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
    Set-PSReadLineOption -MaximumHistoryCount 4096

    # Solo disponible en versiones recientes
    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin -ErrorAction Stop
        Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction Stop
    } catch { }

    # Buscar en el historial con flechas
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# ---- Modulos comunes ----
foreach ($mod in 'ActiveDirectory', 'GroupPolicy') {
    if (Get-Module -ListAvailable -Name $mod) {
        Import-Module $mod -ErrorAction SilentlyContinue
    }
}
