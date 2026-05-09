# seguridad

Scripts orientados a seguridad fisica del endpoint y manejo de sesiones. Bloqueo rapido, cierre de RDP, politica de inactividad.

Casi todo requiere admin local.

## Scripts

- `Lock-WorkstationForce.ps1` - bloquea la estacion local y opcionalmente cierra sesiones remotas del usuario actual. Util cuando dejas la oficina.
- `Close-RDPSessions.ps1` - lista y cierra sesiones RDP de un host. Soporta `-WhatIf` y `-Confirm`.
- `Set-IdleLockPolicy.ps1` - configura el tiempo de bloqueo automatico por inactividad. En dominio puede ser pisado por GPO.

## Notas

El logoff remoto requiere WinRM habilitado en los hosts destino y que tu usuario tenga permiso. En entornos de dominio normalmente alcanza con estar en Remote Management Users o ser admin local.
