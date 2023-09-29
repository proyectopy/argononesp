En primer lugar debo recordar a todos los usuarios que el trabajo no es mio. Solamente traduje los textos de los instaladores y de este README.md
Agradecimientos por el trabajo realizado a [DarkElvenAngel](https://gitlab.com/DarkElvenAngel) podeis clonar el repositorio original usando cualquiera de los metodos siguientes:

### Clonado con SSH 

```bash

git@gitlab.com:DarkElvenAngel/argononed.git

```

### Clonado con HTTPS

```bash

https://gitlab.com/DarkElvenAngel/argononed.git

```
### Descargando en multiples formatos desde  [GITLAB](https://gitlab.com/DarkElvenAngel) o usa estos enlaces:


[DESCARGAR EN FORMATO ZIP](https://gitlab.com/DarkElvenAngel/argononed/-/archive/master/argononed-master.zip)

[DESCARGAR EN FORMATO TAR](https://gitlab.com/DarkElvenAngel/argononed/-/archive/master/argononed-master.tar)

[DESCARGAR EN FORMATO TAR.GZ](https://gitlab.com/DarkElvenAngel/argononed/-/archive/master/argononed-master.tar.gz)

[DESCARGAR EN FORMATO TAR.BZ2](https://gitlab.com/DarkElvenAngel/argononed/-/archive/master/argononed-master.tar.bz2)

Si usas este repositorio con el idioma español, e he permitido añadirle un archivo que configura el ventilador al 33% al alcanzar la temperatura de 40ºC al 66% si supera los 50ºC y al 99% si pasa de los 60º. Así como la hysteresis en su valor 3 de un máximo de 10

## CONTENIDO EXTRA

Una vez hecha la instalacion como se detalla en el texto original traducido en la seccion [Cómo instalar](#comoinstalar), Si decidiste cloar o sescargar el repositorio original, Puedes descargar este script introduciendo en la terminal las siguientes instrucciones:

```bash

clear
cd argononed 
sudo wget https://raw.githubusercontent.com/proyectopy/argononesp/main/argonone.sh &>/dev/null
sudo chmod +x argonone.sh
./argonone.sh

```
Si decidiste usar este repositorio en español, el script se ha descargado ya ejecutalo con las siguientes instrucciones desde la terminal:

```bash

clear
cd argononed 
sudo chmod +x argonone.sh
./argonone.sh

```


# <a id="arriba"></a> Argon One Daemon

Un daemon que mejora el script original creado por el fabricante para las carcasas Argon One Raspberry Pi y el Argon Artik Fan Hat.

## Configuración

Toda la configuración se realiza en **/boot/config.txt**, busque esta línea ```dtoverlay=argonone``` Los parámetros son simples.

* **fantemp[0-2]** - Establece las temperaturas a las que girará el ventilador
* **fanspeed[0-2]** - Establece la velocidad a la que girará el ventilador
* **histéresis** - Establece la histéresis

Los valores predeterminados son los mismos que los del OEM. A 55 ℃, el ventilador arrancará al 10 %, a 60 ℃ la velocidad aumentará al 55 % y finalmente, después de 65 ℃, el ventilador girará al 100 %. La histéresis predeterminada es 3 ℃

### Ejemplo de configuración.txt

En este ejemplo, la histéresis se establecerá en 5 y el ventilador arrancará a 50 ℃

```texto
dtoverlay=argonona,histéresis=5
dtparam=fantemp0=50
```
## ¿Por qué hacer esto?

En pocas palabras, no me gustó el software OEM. Funciona seguro, pero usa Python y necesita instalar un montón de dependencias. Esto hace que su huella en su sistema sea mucho mayor de lo necesario. Mi daemon se ejecuta con requisitos mínimos, todos ellos están incluidos en este repositorio.

## Soporte del sistema operativo

El instalador ahora requiere que ejecute ```./configure``` antes de ejecutar make. Esto configurará el instalador para que pueda instalarse en varios sistemas operativos. La lista actual de sistemas operativos compatibles es

* Sistema operativo Raspberry Pi de 32 bits o 64 bits
*RetroPi
* Gentoo
* Manjaro-brazo
* Arch Linux arm (SÓLO instalación ARMv7) [aarch64/AUR](OS/archarm/README.md)
*Ubuntu
* OSMC
* Twister OS
* DietPI
* Sistema operativo pop
*Kali Linux
* AlmaLinux Gracias a @ArclightMat
* Linux vacío
*Lákka*\**
* LibreElec *\**
* [OpenWRT](OS/openwrt/README.md) **EXPERIMENTAL** *\**
* [Alpine Linux](OS/alpine/README.md) **VER ENLACE**
*openuse Gracias a @fridrich
*openuse-microos **EXPERIMENTAL**
* piCore Gracias a @irkode **0.4.x SÓLO ver nota** *\***
* [NixOS](OS/nixos/README.md) **ESPECIAL** _(Consulte el enlace de este sistema operativo)_ Gracias a @ykis-0-0 por todo el arduo trabajo requerido para este

Si su sistema operativo no está en esta lista, significa que el instalador no está configurado para su sistema operativo y *puede* o *no* poder instalarse en su sistema. La compatibilidad con su sistema operativo puede estar disponible en [rama 0.4.x] (https://gitlab.com/DarkElvenAngel/argononed/-/tree/0.4.x)

*\** *El soporte para este sistema operativo se realiza con el sistema de paquetes autoextraíbles. VEA ABAJO*

*\*** *El soporte para este sistema operativo es solo con la rama más nueva 0.4.x, debes cambiar de rama manualmente*


## <a id="comoinstalar"></a>Cómo instalar 

En primer lugar, debe tener una configuración del entorno de compilación, que incluya el siguiente `gcc dtc git bash linux-headers make`
*NOTA: Los nombres de los paquetes serán diferentes dependiendo de su sistema operativo, por lo que solo he dado sus nombres binarios. Consulte su distribución para saber lo que necesita instalar.*
  
Intenté hacer que el instalador fuese lo más simple posible. Después de clonar este repositorio, simplemente ejecute ```./install``` Es posible que deba reiniciar para obtener una funcionalidad completa.

[Volver arriba](#arriba)

## ¿Por qué debes cambiar el script?

En pocas palabras, no me gustó el software OEM. Funciona seguro, pero usa Python y necesita instalar un montón de dependencias. Esto hace que su huella en su sistema sea mucho mayor de lo necesario. Mi daemon se ejecuta con requisitos mínimos, todos ellos están incluidos en este repositorio.

## Soporte del sistema operativo

El instalador ahora requiere que ejecute ```./configure``` antes de ejecutar make. Esto configurará el instalador para que pueda instalarse en varios sistemas operativos. La lista actual de sistemas operativos compatibles es

* Sistema operativo Raspberry Pi de 32 bits o 64 bits
*RetroPi
* Gentoo
* Manjaro-brazo
* Arch Linux arm (SÓLO instalación ARMv7) [aarch64/AUR](OS/archarm/README.md)
*Ubuntu
* OSMC
* Twister OS
* DietPI
* Sistema operativo pop
*Kali Linux
* AlmaLinux Gracias a @ArclightMat
* Linux vacío
*Lákka*\**
* LibreElec *\**
* [OpenWRT](OS/openwrt/README.md) **EXPERIMENTAL** *\**
* [Alpine Linux](OS/alpine/README.md) **VER ENLACE**
*openuse Gracias a @fridrich
*openuse-microos **EXPERIMENTAL**
* piCore Gracias a @irkode **0.4.x SÓLO ver nota** *\***
* [NixOS](OS/nixos/README.md) **ESPECIAL** _(Consulte el enlace de este sistema operativo)_ Gracias a @ykis-0-0 por todo el arduo trabajo requerido para este

Si su sistema operativo no está en esta lista, significa que el instalador no está configurado para su sistema operativo y *puede* o *no* poder instalarse en su sistema. La compatibilidad con su sistema operativo puede estar disponible en [rama 0.4.x] (https://gitlab.com/DarkElvenAngel/argononed/-/tree/0.4.x)

*\** *El soporte para este sistema operativo se realiza con el sistema de paquetes autoextraíbles. VEA ABAJO*

*\*** *El soporte para este sistema operativo es solo con la rama más nueva 0.4.x, debes cambiar de rama manualmente*

## Opciones de registro

La compilación predeterminada generará registros muy detallados si desea menos registros y luego agregue
```hacer LOGLEVEL=[0-6]```
Los niveles de registro van en este orden: GRAVE, CRÍTICO, ERROR, ADVERTENCIA, INFORMACIÓN, DEPURACIÓN. Un valor de 0 deshabilita el registro.

## Opciones de compilación avanzadas

 Las opciones de compilación avanzadas se utilizan con `configure` o `package.sh`

 **USE_SYSFS_TEMP** Si su sistema no tiene `/dev/vcio`, necesitará usar el conjunto de sensores de temperatura sysfs. Establezca la ruta para su sistema operativo, no todos los sistemas la almacenan en el mismo lugar. ejemplo `USE_SYSFS_TEMP=/sys/class/hwmon/hwmon1/temp1_input`

 **DISABLE_POWERBUTTON** si no tienes `/dev/gpiochip0` o no quieres usar el botón de encendido, usa esta bandera. Recuerde que Forzar apagado >= 5 segundos de pulsación larga seguirá funcionando.

 **RUN_IN_FOREGROUND** si necesita que el daemon se ejecute siempre en primer plano, esta bandera omitirá la bifurcación al fondo y hará que el daemon inicie sesión en la consola.

## Actualizando a la última versión

Para actualizar a la última versión, el método actual es extraer las actualizaciones de gitlab y ejecutar el siguiente comando

```text
./instalar
```
## La herramienta CLI de Argon One

Esta es la nueva herramienta de línea de comando que le permite cambiar la configuración sobre la marcha. Se comunica con la memoria compartida del daemon, por lo que el daemon debe estar ejecutándose para que esta herramienta sea útil. También introdujo nuevos modos para el daemon, como Cool Down y control manual del ventilador.

### Modo de enfriamiento

En el modo de enfriamiento, el ventilador tiene una temperatura establecida que desea alcanzar antes de volver al control automático. Todo esto está configurado de la siguiente manera ```argonone-cli --cooldown <TEMP> [--fan <SPEED>]```
***NOTA***: *La velocidad es opcional y el valor predeterminado es 10%. También es importante tener en cuenta que si la temperatura continúa subiendo, se ignoran los horarios establecidos para el ventilador.*

### Modo manual

Como su nombre lo indica, usted tiene el control sobre el ventilador, los horarios se ignoran. Para acceder a esto de la siguiente manera ```argonone-cli --manual [--fan <SPEED>]```
***NOTA***: *La velocidad del ventilador es opcional y, si no se configura, la velocidad del ventilador se deja sola.*

### Modo automático

Este es el modo predeterminado, el daemon siempre se inicia en este modo y seguirá los horarios en la configuración. Si desea cambiar a automático lo hace de la siguiente manera ```argonone-cli --auto```

### Modo apagado

Sí, un interruptor de apagado, tal vez quieras hacer algo y necesites asegurarte de que el ventilador no se encienda y lo estropee. Puede apagar el ventilador de la siguiente manera ```argonone-cli --off```
***NOTA***: *Cuando el ventilador está apagado, nada más que cambiar a un modo diferente lo volverá a encender*

## Configuración de puntos de ajuste

Si desea ajustar el momento en que se enciende el ventilador, tal vez no permanezca encendido el tiempo suficiente. Puede cambiar todos los puntos de configuración en los horarios desde la línea de comando **sin** reiniciar. los valores son ventilador[0-2] temp[0-2] e histéresis. Es importante que al cambiar estos valores recuerde que el demonio rechazará los valores incorrectos y/o los cambiará por otra cosa. También es importante confirmar los cambios que realice, de lo contrario no harán nada. Las reglas de valor son simples, cada etapa debe ser mayor que la anterior y hay valores mínimos y máximos.
Para la temperatura, el valor mínimo es 30°, el máximo actualmente no está definido.
Para el ventilador la velocidad mínima es del 10% y la máxima es del 100%.
Para histéresis el mínimo es 0° y el máximo es 10°

Puede establecer sus valores como en este ejemplo.
```argonone-cli --fan0 25 --temp0 50 --histéresis 10 --commit```
**O**

```text
argonona-cli --fan0 25
argonona-cli --temp0 50
argonona-cli --histéresis 10
argonone-cli --commit
```

No es necesario realizar los cambios de una sola vez, pero **DEBE** confirmarlos para que surtan efecto.

## Sistema de paquetes

Este no es un sistema de paquetes tradicional para soporte de sistema operativo convencional; está destinado a crear un instalador para un sistema operativo que de otro modo no podría compilar el proyecto localmente.

Para generar un paquete es necesario seguir este procedimiento.

```text
make mrproper
TARGET_DISTRO=<NOMBRE DE LA DISTRO> ./paquete.sh
```

Si tiene éxito, el paquete estará en el directorio de compilación.

### Captura de pantalla del empaquetador

```text


    ___                                                __
   /   |  _________ _____  ____  ____  ____  ___  ____/ /
  / /| | / ___/ __ `/ __ \/ __ \/ __ \/ __ \/ _ \/ __  /
 / ___ |/ /  / /_/ / /_/ / / / / /_/ / / / /  __/ /_/ /
/_/  |_/_/   \__, /\____/_/ /_/\____/_/ /_/\___/\__,_/
            /____/
                                            EMPAQUETADOR
_________________________________________________________
CONFIGURACION DEL DAEMON DE LA CARCASA ARGON ONE ...
Verificacion del SO [debian] : OK
COMPROBACION DEL SISTEMA
gcc : CORRECTO
dtc : CORRECTO
make : CORRECTO
Comprobacion del bus I2C : NO ACTIVADO
COMPROBACIONES DEL SISTEMA OPCIONALES
aurocompletado-bash : CORRECTO
logrotate : INSTALADO
Comprobación de dependencias : Exitosa
INFO:  Preparando el entorno ... OK
INFO:  Creando los archivos ... OK
INFO:  Comprobando los archivos ... OK
INFO:  Creando el instalador ... OK
INFO:  Empaquetando archivos ... OK
INFO:  Verificando el paquete ... OK
INFO:  Paquete build/debian.pkg.sh finalizado 
```

### Solución para el empaquetador Docker

Tengo una solución acoplable para crear paquetes; lea sobre ella [aquí](docker/README.md).

## Argon Artik Hat

Si tienes un Argon Artik Hat y ves este mensaje de error:

`Error al cargar la superposición HAT`

`dterror: no es una FDT válida - err - 9`

Consulte mi [solución de firmware](firmware/README.md).