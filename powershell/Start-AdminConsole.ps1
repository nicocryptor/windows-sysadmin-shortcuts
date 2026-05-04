<#
.SYNOPSIS
Abre una nueva consola elevada con modulos de administracion precargados.

.DESCRIPTION
Lanza Windows Terminal (o pwsh/powershell si no esta wt) en una ventana nueva,
elevada, con titulo identificable y los modulos pedidos importados.
Si ya esta corriendo elevada, importa modulos en la sesion actual.

.PARAMETER NoProfile
No carga el perfil propio en la nueva sesion.

.PARAMETER Modules
Lista de modulos extra a importar ademas de los default (ActiveDirectory,
GroupPolicy, ServerManager). Si alguno no esta instalado lo saltea con warning.

.PARAMETER WorkingDirectory
Directorio inicial de la nueva sesion. Default: la cwd actual.

.EXAMPLE
.\Start-AdminConsole.ps1

.EXAMPLE
.\Start-AdminConsole.ps1 -Modules DnsServer, DHCPServer -WorkingDirectory C:\Scripts
#>
[CmdletBinding()]
param(
    [switch]$NoProfile,
    [string[]]$Modules = @(),
    [string]$WorkingDirectory = (Get-Location).Path
)

$defaultModules = @('ActiveDirectory', 'GroupPolicy', 'ServerManager')
$allModules     = ($defaultModules + $Modules) | Select-Object -Unique

$isElevated = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isElevated) {
    Write-Host "Ya estas elevado. Importando modulos en la sesion actual." -ForegroundColor Yellow
    foreach ($m in $allModules) {
        if (Get-Module -ListAvailable -Name $m) {
            Import-Module $m -ErrorAction SilentlyContinue
            Write-Host "  + $m" -ForegroundColor Green
        } else {
            Write-Warning "  - $m no disponible"
        }
    }
    $host.UI.RawUI.WindowTitle = "ADMIN - $WorkingDirectory"
    return
}

# Armo el comando que va a correr la consola elevada nueva
$importLines = $allModules | ForEach-Object {
    "if (Get-Module -ListAvailable -Name '$_') { Import-Module '$_' -ErrorAction SilentlyContinue }"
}
$setTitle = '$host.UI.RawUI.WindowTitle = "ADMIN - " + (Get-Location).Path'
$cmdBody  = ($importLines + $setTitle) -join '; '

$exe  = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }
$args = @()
if ($NoProfile) { $args += '-NoProfile' }
$args += '-NoExit'
$args += '-Command'
$args += $cmdBody

Start-Process -FilePath $exe -ArgumentList $args -Verb RunAs -WorkingDirectory $WorkingDirectory
