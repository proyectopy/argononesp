#!/bin/bash

########################################################################
# Script: argonone.sh
# Descripcion: Ajustes para el ventilador
# Argumentoss: N/A
#Creacion/Actualizacion: SEPT2023/SEPT2023
# Version: V1.1.1
# Author: Wildsouth
# Email: wildsout@gmail.com
########################################################################
########################################################################

########################################################################
# REVISADO (OK)
########################################################################
echo -e "\e[H\e[J" 
echo -e "\e[37;1m    ___                                                __\e[0m"
echo -e "\e[37;1m   /   |  _________ _____  ____  ____  ____  ___  ____/ /\e[0m"
echo -e "\e[37;1m  / /| | / ___/ __ \`/ __ \/ __ \/ __ \/ __ \/ _ \/ __  / \e[0m"
echo -e "\e[37;1m / ___ |/ /  / /_/ / /_/ / / / / /_/ / / / /  __/ /_/ /  \e[0m"
echo -e "\e[37;1m/_/  |_/_/   \__, /\____/_/ /_/\____/_/ /_/\___/\__,_/   \e[0m"
echo -e "\e[37;1m            /____/                                       \e[0m"
echo -e "\e[37;1m                                            CONFIGURADOR \e[0m"
echo "_________________________________________________________"

sudo argonone-cli --fan0 33
sudo argonone-cli --temp0 40
sudo argonone-cli --commit

sudo argonone-cli --fan1 66
sudo argonone-cli --temp1 50
sudo argonone-cli --commit

sudo argonone-cli --fan2 99
sudo argonone-cli --temp2 60
sudo argonone-cli --hysteresis 3
sudo argonone-cli --commit

sleep 5

clear

sudo argonone-cli --decode

exit 10



