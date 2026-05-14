# Tabla extendida de consolas MMC

La version corta esta en [atajos/consolas-mmc.md](../atajos/consolas-mmc.md).
Esto suma notas extra: en que ediciones de Windows existen, si requieren
RSAT, y para que sirve cada una con un poco mas de contexto.

## Disponibilidad

| Comando | Pro | Enterprise | Home | RSAT |
|---|---|---|---|---|
| `compmgmt.msc` | Si | Si | Si | No |
| `services.msc` | Si | Si | Si | No |
| `eventvwr.msc` | Si | Si | Si | No |
| `devmgmt.msc` | Si | Si | Si | No |
| `diskmgmt.msc` | Si | Si | Si | No |
| `taskschd.msc` | Si | Si | Si | No |
| `perfmon.msc` | Si | Si | Si | No |
| `wf.msc` | Si | Si | Si | No |
| `wmimgmt.msc` | Si | Si | Si | No |
| `gpedit.msc` | Si | Si | **No** | No |
| `secpol.msc` | Si | Si | **No** | No |
| `lusrmgr.msc` | Si | Si | **No** | No |
| `rsop.msc` | Si | Si | **No** | No |
| `certmgr.msc` | Si | Si | Si | No |
| `certlm.msc` | Si | Si | Si | No |
| `fsmgmt.msc` | Si | Si | Si | No |
| `printmanagement.msc` | Si | Si | **No** | No |
| `azman.msc` | Si | Si | No | No |
| `tpm.msc` | Si | Si | Si | No |
| `dsa.msc` | Si | Si | No | **Si** |
| `dssite.msc` | Si | Si | No | **Si** |
| `domain.msc` | Si | Si | No | **Si** |
| `gpmc.msc` | Si | Si | No | **Si** |
| `dnsmgmt.msc` | Si | Si | No | **Si** |
| `dhcpmgmt.msc` | Si | Si | No | **Si** |
| `adsiedit.msc` | Si | Si | No | **Si** |
| `comexp.msc` | Si | Si | Si | No |

## Detalle de las menos conocidas

### `adsiedit.msc`

Editor low-level de objetos de Active Directory. Lo abris cuando dsa.msc
no te muestra el atributo que necesitas. Cuidado, no hay undo.

### `rsop.msc`

Resultant Set of Policy. Muestra que politicas terminaron aplicadas a la
maquina. Util para entender porque algo no funciona como esperabas.

Para una version mas moderna y por consola usa `gpresult /h reporte.html`
y abri el HTML.

### `printmanagement.msc`

Administracion centralizada de impresoras, drivers y colas. En un print
server es la que usas todos los dias.

### `comexp.msc` (= `dcomcnfg`)

Component Services. Configurar permisos DCOM, transacciones distribuidas.
La toco solo si algo de COM remoto rompe.

### `azman.msc`

Authorization Manager. Roles y permisos para aplicaciones que usan ese
framework. Lo vi mas que nada en cosas viejas de Exchange y SharePoint.

### `tpm.msc`

Administracion del Trusted Platform Module. BitLocker depende de esto.
Si necesitas borrar el TPM (por ejemplo antes de devolver un equipo),
esta es la consola.

### `wbemtest`

No es una msc pero esta en la misma linea. Cliente WMI a mano para
probar queries y conexiones. Si Get-WmiObject o Get-CimInstance fallan,
arranco por aca.

## Tips

- Casi todas aceptan `/computer:NOMBRE` para conectarse a otra maquina,
  por ejemplo `services.msc /computer:srv-app01`.
- Si lanzas con `runas /user:DOMAIN\admin "mmc consolas.msc"` podes
  abrir la consola con otra credencial sin perder la sesion principal.
- Para abrir varias consolas en una sola ventana, abri `mmc.exe` vacio
  y agrega snap-ins con Ctrl+M. Despues guarda como .msc.
