<#
.SYNOPSIS
Bloquea la estacion local y, opcionalmente, fuerza el logoff de sesiones
del usuario actual en otros equipos.

.DESCRIPTION
Pensado para el escenario "me voy de la oficina y quiero asegurarme que
no quede una sesion mia abierta en un servidor". Usa PowerShell Remoting
para los equipos remotos, requiere WinRM habilitado del lado de cada uno.

.PARAMETER RemoteHosts
Lista de hosts donde forzar logoff de sesiones del usuario actual.

.PARAMETER Credential
Credencial para conectar a los remotos. Si no se pasa usa la del usuario actual.

.EXAMPLE
.\Lock-WorkstationForce.ps1

.EXAMPLE
.\Lock-WorkstationForce.ps1 -RemoteHosts srv-app01, srv-db02
#>
[CmdletBinding()]
param(
    [string[]]$RemoteHosts = @(),
    [System.Management.Automation.PSCredential]$Credential
)

$me = "$env:USERDOMAIN\$env:USERNAME"

# Logoff remoto primero, despues bloqueo local. Asi si algo falla remoto, todavia veo el output.
foreach ($host in $RemoteHosts) {
    Write-Host "Conectando a $host..." -ForegroundColor Cyan
    try {
        $params = @{ ComputerName = $host; ErrorAction = 'Stop' }
        if ($Credential) { $params.Credential = $Credential }

        Invoke-Command @params -ScriptBlock {
            param($user)
            $sessions = (quser 2>$null) -replace '\s{2,}', ',' | ConvertFrom-Csv -Header 'Usuario','SessionName','ID','Estado','IdleTime','LogonTime'
            $mine = $sessions | Where-Object { $_.Usuario -match $user.Split('\')[1] }
            foreach ($s in $mine) {
                logoff $s.ID
                Write-Output "  logoff de sesion ID $($s.ID) en $env:COMPUTERNAME"
            }
        } -ArgumentList $me
    } catch {
        Write-Warning "  no se pudo conectar a $host : $($_.Exception.Message)"
    }
}

# Bloqueo local via P/Invoke
$sig = '[DllImport("user32.dll", SetLastError=true)] public static extern bool LockWorkStation();'
$type = Add-Type -MemberDefinition $sig -Name LockWS -Namespace Win32 -PassThru
[void]$type::LockWorkStation()
Write-Host "Estacion local bloqueada." -ForegroundColor Green
