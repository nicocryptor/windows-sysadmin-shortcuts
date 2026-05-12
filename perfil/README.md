# perfil

El profile de PowerShell que tengo cargado. Agrega:

- Prompt con marca `[ADMIN]` en rojo cuando la sesion esta elevada
- Aliases utiles: `ll`, `which`, `touch`
- Funciones: `Get-PublicIP`, `Get-ListeningPorts`, `Get-LastLogons`
- Config de PSReadLine con prediccion por historial y busqueda con flechas
- Variable global `$AdminScripts` apuntando a la raiz del repo

## Como instalarlo

Hay dos opciones.

**Opcion 1: pegarlo entero al profile del usuario**

```powershell
notepad $PROFILE
```

Si el archivo no existe lo crea. Pega el contenido de `Microsoft.PowerShell_profile.ps1`. Cierra y reabri PowerShell.

**Opcion 2: sourcearlo desde tu profile**

Esta es la que uso yo. En `$PROFILE` agregas una linea:

```powershell
. 'C:\ruta\al\repo\perfil\Microsoft.PowerShell_profile.ps1'
```

Asi cuando actualizas el repo, tu profile siempre tiene la ultima version sin copiar y pegar.

## Notas

- En PowerShell 5.1 `PredictionSource` con valor `HistoryAndPlugin` puede no estar disponible. El script lo intenta y si falla sigue sin error.
- Los modulos `ActiveDirectory` y `GroupPolicy` se importan solo si estan instalados (RSAT). En una workstation sin RSAT no rompe.
- El prompt mide la longitud del path para no pasar de 50 caracteres. Si te molesta ajustalo en la funcion `prompt`.
