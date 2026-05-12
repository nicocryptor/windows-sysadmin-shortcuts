# Atajos de PSReadLine

PSReadLine es el modulo que maneja la edicion de linea en PowerShell.
Viene incluido en PowerShell 5.1+ y en PowerShell 7. Estos atajos asumen
`EditMode = Windows`, que es el default.

## Edicion de linea

| Atajo | Que hace |
|---|---|
| `Ctrl + A` | Inicio de linea |
| `Ctrl + E` | Fin de linea |
| `Ctrl + Flecha izq/der` | Mover por palabra |
| `Ctrl + Backspace` | Borrar palabra hacia atras |
| `Ctrl + Delete` | Borrar palabra hacia adelante |
| `Ctrl + U` | Borrar desde el cursor hasta el inicio |
| `Ctrl + K` | Borrar desde el cursor hasta el final |
| `Ctrl + Y` | Yank (pegar lo ultimo borrado) |

## Historial

| Atajo | Que hace |
|---|---|
| `Flecha arriba / abajo` | Navegar historial |
| `Ctrl + R` | Busqueda inversa interactiva en el historial |
| `Ctrl + S` | Busqueda hacia adelante en el historial |
| `F7` | Lista en ventana con todo el historial |
| `F8` | Buscar en historial lo que coincida con lo escrito |
| `Alt + .` | Insertar el ultimo argumento del comando anterior. Igual que bash. |

## Autocompletado

| Atajo | Que hace |
|---|---|
| `Tab` | Completar |
| `Shift + Tab` | Completar para atras (siguiente sugerencia) |
| `Ctrl + Espacio` | Menu de completado en grilla |

## Prediccion (PSReadLine 2.1+)

Si tenes activado `Set-PSReadLineOption -PredictionSource HistoryAndPlugin`,
te muestra una sugerencia en gris al escribir.

| Atajo | Que hace |
|---|---|
| `Flecha derecha` | Aceptar la prediccion entera |
| `Ctrl + Flecha derecha` | Aceptar la prediccion palabra por palabra |
| `F2` | Cambiar entre vista en linea y vista lista |

## Configuracion recomendada

Esto va en tu `$PROFILE`. El perfil del repo ya lo hace, pero por si lo queres copiar suelto:

```powershell
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 4096
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView

Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
```

`HistorySearchBackward` hace que si escribis `Get-` y apretas flecha arriba,
solo recorre los comandos que empiezan con `Get-`. Una vez que lo probas, no vas para atras.
