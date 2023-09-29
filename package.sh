#!/bin/bash
# MIT License

# Copyright (c) 2020 DarkElvenAngel

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# VERSION 0.2

echo -e "\e[H\e[J" 
echo -e "\e[37;1m    ___                                                __\e[0m"
echo -e "\e[37;1m   /   |  _________ _____  ____  ____  ____  ___  ____/ /\e[0m"
echo -e "\e[37;1m  / /| | / ___/ __ \`/ __ \/ __ \/ __ \/ __ \/ _ \/ __  / \e[0m"
echo -e "\e[37;1m / ___ |/ /  / /_/ / /_/ / / / / /_/ / / / /  __/ /_/ /  \e[0m"
echo -e "\e[37;1m/_/  |_/_/   \__, /\____/_/ /_/\____/_/ /_/\___/\__,_/   \e[0m"
echo -e "\e[37;1m            /____/                                       \e[0m"
echo -e "\e[37;1m                                            EMPAQUETADOR \e[0m"
echo "_________________________________________________________"
[[ -n $TARGET_DISTRO ]] && { ./configure || exit 1; }
[[ -f makefile.conf ]] || { echo -e "\e[31mERROR\e[0m:  Ejecuta \e[1mTARGET_DISTRO=<NAME> ./package.sh\e[0m first"; exit 1; }
source makefile.conf
[[ -a OS/${DISTRO}/pkg_list ]] || { echo "ERROR:  \"${DISTRO}\" no tiene un archivo de lista de paquetes, no puede generar el paquete"; exit 1;}
OUT_FILENAME="build/${DISTRO}.pkg.sh"



echo -ne "\e[37;1mINFO:\e[0m  Preparando el entorno ... "
make clean &> /dev/null && echo -e "\e[32mOK\e[0m" || { echo -e "\e[31mERR\e[0m\n\tAlgo no fue bien con \"make clean\" "; exit 1;}
rm ${OUT_FILENAME} &> /dev/null
echo -ne "\e[37;1mINFO:\e[0m  Creando los archivos ... "
make &> /dev/null && echo -e "\e[32mOK\e[0m" || { echo -e "\e[31mERR\e[0m\n\tAlgo no fue bien con \"make\""; exit 1;}
echo -ne "\e[37;1mINFO:\e[0m  Comprobando los archivos ... "
while read line; do
# reading each line
[[ -f $line ]] || { echo -e "\e[31mERR\nERROR\e[0m:  \e[1m${line}\e[0m Archivo no encontrado!"; exit 1; }
done < OS/${DISTRO}/pkg_list
echo -e "\e[32mOK\e[0m"

echo -ne "\e[37;1mINFO:\e[0m  Creando el instalador ... "
cat > ${OUT_FILENAME} <<SCRIPT_TOP
#!/bin/sh
echo "INFO: Instalador autoextraíble ArgonOne Daemon"
DATA_START=\$((\`grep -an "^DATA_CONTENT$" \$0 | cut -d: -f1\` + 1))

F_EXTRACT()
{
	echo -n "INFO:  Extrayendo archivos ... "
	tail -n+\${DATA_START} \$0 | tar zxf - 2>/dev/null && echo "OK" || { echo "ERR"; exit 1; }
}
echo -n "INFO:  Comprrobando instalador ... "
#INSTALLER

type F_INSTALL &>/dev/null && echo "OK" || { echo -e "ERR\nERROR:  INSTALADOR NO ENCONTRADO"; exit 1;}
echo "INFO:  Iniciando instalador"
F_INSTALL
exit 0
DATA_CONTENT
SCRIPT_TOP
[[ -f OS/${DISTRO}/pkg_install.sh ]] || { echo -e "\e[31mERR\nERROR\e[0m:  \e[1mOS/${DISTRO}/pkg_install.sh\e[0m NO SE HA ENCONTRADO"; exit 1;}
sed -i -e "/#INSTALLER/r OS/${DISTRO}/pkg_install.sh" -e '/#INSTALLER/d' ${OUT_FILENAME}
echo -e "\e[32mOK\e[0m"
# tar -cvf allfiles.tar -T OS/${DISTRO}/pkg_list
echo -ne "\e[37;1mINFO:\e[0m  Empaquetando archivos ... "
tar -T OS/${DISTRO}/pkg_list -czf - >> ${OUT_FILENAME} && echo -e "\e[32mOK\e[0m"

chmod +x ${OUT_FILENAME}

echo -ne "\e[37;1mINFO:\e[0m  Verificando el paquete ... "

while read line; do
# reading each line
tail -n+$((`grep -an "^DATA_CONTENT$" ${OUT_FILENAME} | cut -d: -f1` + 1)) ${OUT_FILENAME} | tar tzv $line &> /dev/null || { echo -e "\e[31mERR\nERROR\e[0m:  \e[1m${line}\e[0m Archivo no encontrado!"; exit 1; }
done < OS/${DISTRO}/pkg_list
echo -e "\e[32mOK\e[0m"

echo -e "\e[37;1mINFO\e[0m:  Paquete \e[1m${OUT_FILENAME}\e[0m finalizado "

exit 0