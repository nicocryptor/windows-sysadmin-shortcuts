# Consolas MMC

Las que abro con `Win+R` cuando no quiero perder tiempo con la interfaz. Casi todas requieren elevacion para hacer cambios; varias permiten ver el estado sin admin.

## Sistema y administracion

| Comando | Para que sirve | Requiere admin |
|---|---|---|
| `compmgmt.msc` | Administracion de equipos, agrupa varias herramientas | Si para escribir |
| `services.msc` | Servicios de Windows | Si para start/stop |
| `taskschd.msc` | Programador de tareas | Si para tareas system |
| `eventvwr.msc` | Visor de eventos. El uso 20 veces al dia | No para leer |
| `perfmon.msc` | Monitor de rendimiento y data collector sets | Si |
| `devmgmt.msc` | Administrador de dispositivos | Si para cambios |
| `diskmgmt.msc` | Particionar y formatear discos | Si |
| `fsmgmt.msc` | Carpetas compartidas, sesiones, archivos abiertos | Si |
| `wmimgmt.msc` | Configuracion de WMI | Si |
| `printmanagement.msc` | Impresoras, drivers y colas | Si |

## Politicas y seguridad

| Comando | Para que sirve | Requiere admin |
|---|---|---|
| `secopl.msc` | Politicas de seguridad local | Si |
| `gpedit.msc` | Editor de politicas de grupo local. No esta en Home | Si |
| `rsop.msc` | Resultado aplicado de politicas en la maquina | Recomendado |
| `lusrmgr.msc` | Usuarios y grupos locales. No esta en Home | Si |
| `wf.msc` | Firewall avanzado con reglas in/out | Si |
| `certmgr.msc` | Certificados del usuario actual | No |
| `certlm.msc` | Certificados de la maquina local | Si |
| `azman.msc` | Authorization Manager | Si |
| `tpm.msc` | Administracion del TPM | Si |

## Active Directory (requieren RSAT)

| Comando | Para que sirve |
|---|---|
| `dsa.msc` | Usuarios y equipos de AD |
| `dssite.msc` | Sitios y servicios |
| `domain.msc` | Dominios y confianzas |
| `gpmc.msc` | Group Policy Management Console |
| `dnsmgmt.msc` | Servidor DNS |
| `dhcpmgmt.msc` | Servidor DHCP |

## Como abrir rapido

1. `Win+R`, escribir el nombre, Enter. Listo.
2. Si lo necesitas elevado, `Win+R`, escribir el nombre y apretar `Ctrl+Shift+Enter`. Salta el UAC y arranca como admin.
3. `Win+X` despliega un menu con varias de estas (Administracion de equipos, Visor de eventos, Administrador de dispositivos, Administrador de tareas).
