#!/bin/bash
MODULES="i2c-dev i2c-bcm2708"
MODULE_FILE="/etc/modules-load.d/raspberrypi.conf"

if [[ -a $MODULE_FILE ]]; then
    for MODULE in $MODULES
    do
        echo -n "Check for module ${MODULE}  "
        if grep -q $MODULE "${MODULE_FILE}"; then
            echo "ENCONTRADO"
        else
            echo "${MODULE}" >> $MODULE_FILE 2>/dev/null && echo "ADDED" || { echo "ERROR:  Can't write to file ${MODULE_FILE}"; exit 1; }
        fi
    done
else
    echo "INFO:  ${MODULE_FILE} Not Found"
    for MODULE in $MODULES
    do
        echo "${MODULE}" >> $MODULE_FILE 2>/dev/null || { echo "ERROR:  Can't write to file ${MODULE_FILE}"; exit 1; }
    done
    echo "INFO:  ${MODULE_FILE} Created Successfully"
fi

exit 0