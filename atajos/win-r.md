# Comandos del Win+R

El cuadro Ejecutar es lo mas rapido que tenes. Memorizar 10 o 15 comandos te ahorra una hora por dia.

## Panel de control y configuracion

| Comando | Que abre |
|---|---|
| `control` | Panel de control clasico |
| `sysdm.cpl` | Propiedades del sistema (nombre de equipo, dominio, env vars) |
| `appwiz.cpl` | Programas y caracteristicas |
| `ncpa.cpl` | Conexiones de red |
| `firewall.cpl` | Firewall basico (la version vieja) |
| `powercfg.cpl` | Opciones de energia |
| `mmsys.cpl` | Sonido |
| `timedate.cpl` | Fecha, hora y zona horaria |
| `inetcpl.cpl` | Opciones de internet (proxy, certificados) |
| `desk.cpl` | Configuracion de pantalla |
| `joy.cpl` | Dispositivos de juego |

## Red y conectividad

| Comando | Que hace |
|---|---|
| `cmd` | Consola clasica |
| `cmd /c ipconfig /all & pause` | Ipconfig y mantiene la ventana abierta |
| `mstsc` | Remote Desktop Connection |
| `mstsc /admin` | RDP en consola del servidor (sesion 0) |
| `mstsc /v:host:puerto` | RDP directo a un host con puerto custom |
| `\\servidor` | Browseo del servidor por SMB |
| `\\servidor\c$` | Acceso administrativo a C$ |

## Diagnostico

| Comando | Que abre |
|---|---|
| `msinfo32` | Informacion del sistema completa |
| `dxdiag` | Diagnostico de DirectX |
| `resmon` | Monitor de recursos |
| `perfmon /res` | Igual que resmon |
| `msconfig` | Configuracion del sistema, arranque |
| `cleanmgr` | Liberador de espacio en disco |
| `dfrgui` | Desfragmentar (o trim en SSD) |
| `mdsched.exe` | Diagnostico de memoria de Windows |

## Acceso rapido a carpetas

| Comando | Donde te lleva |
|---|---|
| `shell:startup` | Carpeta de inicio del usuario actual |
| `shell:common startup` | Carpeta de inicio comun a todos los usuarios |
| `shell:sendto` | Menu "Enviar a" |
| `shell:recent` | Documentos recientes |
| `shell:appsfolder` | Todas las apps instaladas (UWP incluidas) |
| `%temp%` | Temp del usuario |
| `%appdata%` | Roaming AppData |
| `%localappdata%` | Local AppData |
| `%programdata%` | ProgramData |

## PowerShell y terminales

| Comando | Que hace |
|---|---|
| `powershell` | PowerShell 5.1 |
| `pwsh` | PowerShell 7+ (si esta instalado) |
| `powershell -NoProfile -ExecutionPolicy Bypass` | Util para correr scripts cuando el profile es ruidoso |
| `wt` | Windows Terminal |
| `wt -p "PowerShell"` | Windows Terminal con perfil especifico |

## Tips

- Si haces `Ctrl+Shift+Enter` despues de escribir cualquier comando, intenta correrlo como admin.
- El historial del Win+R se guarda por usuario. Si lo limpiaste, podes recuperar los mas usados como sub-comando del Start menu.
