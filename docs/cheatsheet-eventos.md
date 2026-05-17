# Cheatsheet de Event IDs

Los Event IDs del log Security y System que mas miro al hacer respuesta a
incidentes. Esta lista cubre el 95% de los casos. Para una referencia
completa, ver Microsoft Learn ("Windows security audit events").

Severidad sugerida es subjetiva, depende del contexto. Lo que en una
workstation es ruido, en un DC puede ser una alerta.

## Autenticacion

| ID | Que paso | Severidad sugerida |
|---|---|---|
| 4624 | Logon exitoso | Info |
| 4625 | Logon fallido | Warning (alto si se repite) |
| 4634 | Logoff | Info |
| 4647 | Logoff iniciado por el usuario | Info |
| 4648 | Logon con credenciales explicitas (runas, scheduled task) | Info |
| 4672 | Privilegios especiales asignados al logon (admin) | Warning |
| 4768 | TGT solicitado (Kerberos auth en DC) | Info |
| 4769 | TGS solicitado (Kerberos service ticket) | Info |
| 4771 | Pre-auth Kerberos fallida | Warning |
| 4776 | Logon NTLM | Info (Warning si esperabas Kerberos) |

## Tipos de logon (sub-codigos del 4624)

| Tipo | Que es |
|---|---|
| 2 | Interactivo (consola) |
| 3 | Red (acceso a recurso compartido) |
| 4 | Batch (scheduled task) |
| 5 | Servicio |
| 7 | Desbloqueo |
| 8 | NetworkCleartext (passwd en texto plano por la red, mala señal) |
| 9 | NewCredentials (runas /netonly) |
| 10 | RemoteInteractive (RDP) |
| 11 | CachedInteractive (cred cacheada, sin DC) |

## Cuentas de usuario

| ID | Que paso | Severidad |
|---|---|---|
| 4720 | Cuenta creada | Warning |
| 4722 | Cuenta habilitada | Warning |
| 4723 | Cambio de contraseña por el propio usuario | Info |
| 4724 | Reset de contraseña por otro usuario (admin) | Warning |
| 4725 | Cuenta deshabilitada | Info |
| 4726 | Cuenta eliminada | Warning |
| 4738 | Cuenta modificada | Info |
| 4740 | Cuenta bloqueada por intentos fallidos | Warning |
| 4767 | Cuenta desbloqueada | Info |

## Grupos

| ID | Que paso |
|---|---|
| 4727 | Grupo global creado |
| 4728 | Miembro agregado a grupo global |
| 4729 | Miembro removido de grupo global |
| 4732 | Miembro agregado a grupo local |
| 4733 | Miembro removido de grupo local |
| 4756 | Miembro agregado a grupo universal |
| 4757 | Miembro removido de grupo universal |

Cuidado especial con 4728 si el grupo es Domain Admins o Enterprise Admins.

## Servicios y procesos

| ID | Log | Que paso |
|---|---|---|
| 7036 | System | Servicio cambio de estado (start/stop) |
| 7040 | System | Tipo de inicio del servicio cambio |
| 7045 | System | Servicio nuevo instalado |
| 4688 | Security | Proceso creado (si auditas process tracking) |
| 4689 | Security | Proceso terminado |

## Politica y auditoria

| ID | Severidad | Que paso |
|---|---|---|
| 4719 | Critical | Politica de auditoria del sistema cambio |
| 1102 | Critical | Log de seguridad borrado |
| 4670 | Warning | Permisos sobre un objeto fueron cambiados |
| 4907 | Warning | Auditoria sobre un objeto fue modificada |

Los 1102 y 4719 son los dos que mas me importan. Si aparecen sin
explicacion, alguien esta intentando borrar evidencia.

## Sistema

| ID | Log | Que paso |
|---|---|---|
| 6005 | System | Event log service inicio (boot) |
| 6006 | System | Event log service detenido (shutdown limpio) |
| 6008 | System | Apagado inesperado (boot anterior no fue limpio) |
| 6009 | System | Version de Windows y arquitectura |
| 6013 | System | Uptime al momento de booteo |
| 41 | System | Kernel-Power, reset sin shutdown limpio |
| 1074 | System | Shutdown/restart iniciado, incluye razon |

## Windows Defender

| ID | Que paso |
|---|---|
| 1116 | Malware detectado |
| 1117 | Accion tomada contra malware |
| 1118 | Falla al actuar contra malware |
| 5007 | Configuracion cambiada |

## Como filtrarlos rapido

Con `Get-WinEvent` y filter hashtable es lo mas rapido. Para 4625 de la ultima hora:

```powershell
Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4625
    StartTime = (Get-Date).AddHours(-1)
}
```

Para los borrados de log:

```powershell
Get-WinEvent -FilterHashtable @{ LogName='Security'; Id=1102 } -MaxEvents 10
```
