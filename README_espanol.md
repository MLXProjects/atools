# Latools
Herramientas y dependencias de libaroma para compilación sencilla (usando un sistema de compilado similar al clásico)
## Cómo usar
Modificar el config.txt:  
- definir `LIBAROMA_SOURCE` como la ruta del repositorio de libaroma
- asignar `LIBAROMA_GCC` y `LIBAROMA_AR` con rutas al compilador que ya tienes (porque lo tienes, cierto?)
- modificar `LIBAROMA_PLATFORM`, `LIBAROMA_CPU`, etc. según lo necesites
- activa lo que quieras, el archivo config.txt incluído compila una versión mínima de libaroma :)  

Para compilar las dependencias de libaroma ejecuta `alibs.cmd`, ésto creará una carpeta de salida con las dependencias.  
Para compilar libaroma ejecuta `abuild.cmd`, si no compilaste las dependencias ésto lo hará por ti.  
Tambien puedes compilar código de cualquier carpeta ejecutando `atest.cmd <path/to/folder/containing/source>`, por ejemplo:  

`atest.cmd D:\projects\test (donde la carpeta test\ contiene archivos como asd.c)`  

Ésto creará un ejecutable en la carpeta de salida con el nombre de la carpeta que compilaste.  

## Uso avanzado
### Configuraciones específicas
Si quieres compilar para multiples plataformas, puedes crear varios archivos de configuración y especificar cuál usar al compilar.  
Para hacerlo, crea un archivo `config-<nombre>.txt` y usa su `<nombre>` como el primer parámetro en cualquier script de compilado.  
Por ejemplo, para usar el archivo `config-win.txt` incluído:

`abuild.cmd win`  

Ésto va a compilar libaroma y sus dependencias usando el archivo `config-win.txt` como configuración.

### Carpetas de salida
Por defecto, el sistema de compilado va a crear una carpeta llamada `out-<plataforma>` (por ejemplo, `out-linux`).  
Si definiste `LIBAROMA_CPU` en el archivo de configuración, la carpeta de salida será `out-<plataforma>_<cpu>` (por ejemplo, `out-linux_neon`).  
Si estás usando un archivo de configuración específico, su nombre se usará en lugar de la plataforma (por ejemplo, `out-win_ssse3`). Nótese que `LIBAROMA_CPU` se sigue usando en este caso.  
Por ahora no se puede definir una carpeta de salida personalizada, ya que no le encontré utilidad :P  

### Compilar dependencias específicas
alibs.cmd compila las dependencias necesarias por medio de leer la configuración y crear un archivo libadeps.a en la carpeta de salida.  
Puede que algún día necesites compilar una dependencia específica (por ejemplo, si actualizaste alguna), para hacerlo:  

`alibs.cmd <dependencias>` (por ejemplo, `alibs.cmd zlib`)

Donde `<dependencias>` corresponde a una lista de las dependencias que quieras compilar.  
También puedes pasar el nombre de una configuración como primer argumento:  

`alibs.cmd <nombre> <dependencias>` (por ejemplo, `alibs.cmd win zlib`)

Donde `<nombre>` es el nombre de la configuración que quieras usar.  
El sistema de compilación detectará que es un nombre de configuración y lo usará.  
Nótese que un archivo llamado `config-<nombre>.txt` tiene que existir.
