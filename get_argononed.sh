#!/bin/bash
# Auto installer for argononed this will grab the latest version
function version { echo "$@" | awk -F. '{ printf("%03d%03d%03d\n", $1,$2,$3); }'; }

echo -e "\e[H\e[J" 
echo -e "\e[37;1m    ___                                                __\e[0m"
echo -e "\e[37;1m   /   |  _________ _____  ____  ____  ____  ___  ____/ /\e[0m"
echo -e "\e[37;1m  / /| | / ___/ __ \`/ __ \/ __ \/ __ \/ __ \/ _ \/ __  / \e[0m"
echo -e "\e[37;1m / ___ |/ /  / /_/ / /_/ / / / / /_/ / / / /  __/ /_/ /  \e[0m"
echo -e "\e[37;1m/_/  |_/_/   \__, /\____/_/ /_/\____/_/ /_/\___/\__,_/   \e[0m"
echo -e "\e[37;1m            /____/                                       \e[0m"
echo -ne "\n\e[37;1m Auto Installer\n\e[0m"
echo "_________________________________________________________"
echo -e 
if [ "$EUID" -ne 0 ]
then
    echo -e "\e[37;1mEstás ejecutando sin permisos de root\e[0m"
    echo "Si alguna tarea requiere acceso de root, se utilizará sudo."
    read -e -p "¿Estas de acuerdo [s/N]?" choice
    [[ "$choice" == [Ss]* ]] || exit 1
fi
command -v git &> /dev/null && GIT=1 || GIT=0
if [ $GIT -eq 0 ]
then 
    command -v apt &> /dev/null && APT=1 || APT=0
    [[ APT -eq 0 ]] && { echo "Primero debes instalar Git"; exit 1; }
    echo -e "\e[37;1mgit\e[0m ya que no lo hemos encontrado en tu sistema."
    read -e -p "¿Quieres instalar Git [s/N]?" choice
    if [[ "$choice" == [Ss]* ]]
    then 
        echo -n "Instalando Git ... "
        if [ "$EUID" -ne 0 ]
            then sudo apt install git -y &>/dev/null && echo "¡TODO CORRECTO!" || { echo "¡ALGO NO FUE BIEN!"; exit 1; }
            else apt install git -y &>/dev/null && echo "¡TODO CORRECTO!" || { echo "¡ALGO NO FUE BIEN!"; exit 1; }
        fi
    else
        echo "ERROR:  No se pudo completar la instalacion"
        exit 1
    fi
fi
echo -e "\e[1m>>> Comprobando las versiones disponibles \e[0m"
CURRENT_PATH=${PWD##*/}
FOUND=0
if [ "$CURRENT_PATH" == "argononed" ]
then
    if [ -f "version" ]
    then
        CURRENT_VERSION=$(head -n1 version)
    else
        CURRENT_VERSION="0.1.5"
    fi
    FOUND=1
else
    CURRENT_VERSION="0.0.0"
    if [ -d "argononed" ]
    then
        if [ -f "argononed/version" ]
        then
            CURRENT_VERSION=$(head -n1 argononed/version)
            FOUND=2
        else
            CURRENT_VERSION="0.1.5"
            FOUND=2
        fi
    fi
fi
UPDATE=0
MASTERBRANCH_VERSION=$(curl -s https://gitlab.com/DarkElvenAngel/argononed/-/raw/master/version)
LATESTBRANCH_VERSION=$(curl -s https://gitlab.com/DarkElvenAngel/argononed/-/raw/0.3.x/version)
if [ "$CURRENT_VERSION" == "0.0.0" ]
then
    echo "Version instalada     [ NONE ]" 
else
    echo "Version instalada     [ $CURRENT_VERSION ]" 
fi
echo "Ultima version estable [ $MASTERBRANCH_VERSION ]"
echo "Ultima version Branch [ $LATESTBRANCH_VERSION ]"
if [ "$(version "$CURRENT_VERSION")" -lt "$(version "$MASTERBRANCH_VERSION")" ]
then
    echo -e "\e[37;1mHay una nueva version para instalar!\e[0m"
    UPDATE=1
else
    echo -e "\e[37;1mNo necesitas actualizar\e[0m."
fi
if [ "$(version "$CURRENT_VERSION")" -lt "$(version "$LATESTBRANCH_VERSION")" ]
then
    echo -e "\e[37;1mUna nueva version de prueba disponible!\e[0m"
    let "UPDATE|=2"
else
    echo -e "\e[37;1mNo hay nuevas versiones de prueba disponibles\e[0m"
fi
if [[ $FOUND -ne 0 && $UPDATE -eq 0 ]]
then
    exit 0
fi
echo -e "\e[1m>>> Obteniendo archivos \e[0m"
case $FOUND in
    0) 
        git clone  https://gitlab.com/DarkElvenAngel/argononed.git || exit $?
        cd argononed
        ;;
    2)
        cd argononed
        ;&
    1)
        git pull &> /dev/null
        git checkout master &> /dev/null
        ;;
    *)
        echo "Algo ha salido mal!"
        exit 2;
esac
if [ $(($UPDATE & 1)) -ne 0 ]
then 
    CHOICE="1"
    echo "1 ] Intalar version estable"
fi
if [ $(($UPDATE & 2)) -ne 0 ]
then
    echo "2 ] Instalar version de prueba"
    CHOICE="${CHOICE}2"
fi
echo "0 ] Salir sin instalar"
echo $CHOICE
while true; do
    read -e -p "> " choice
    case $choice in 
        "1" ) 
            if [[ $CHOICE == *"$choice"* ]]
            then
                break
            else
                echo "Error en la opcion elegida" 
            fi
            ;;
        "2" ) 
            if [[ $CHOICE == *"$choice"* ]]
            then
                git checkout 0.3.x &> /dev/null
                break
            else
                echo "Elección no válida" 
            fi
            ;;
        "0" )
            exit 0
            ;;
        * ) echo "Elección no válida" ;; 
    esac
done
echo -e "\e[1m>>> Restablecer compilación mrproper...\e[0m"
make mrproper || { echo -e "\e[31;1m>>> make ERROR...\e[0m"; exit 1; }
echo -e "\e[1m>>> Ejecutando configuración previa a la compilación...\e[0m"
./configure $@
if [ $? -ne 0 ]
then
    echo -e "\e[31;1m>>> ERROR de configuración...\e[0m"
    exit 1;
fi
echo -e "\e[1m>>> Compilando...\e[0m"
make all $@
if [ $? -ne 0 ]
then
    echo -e "\e[31;1m>>> ERROR al compilar...\e[0m"
    exit 1;
fi
echo -e "\e[1m>>> Instalando...\e[0m"
if [ "$EUID" -ne 0 ]
    then sudo make install || exit $?
    else make install || exit $?
fi
echo -e "\e[1m>>>  Todo completado\e[0m"

exit 0;

