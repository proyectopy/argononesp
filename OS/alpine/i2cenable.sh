#! /bin/bash
[ $# -eq 0 ] && FILE=/boot/config.txt || FILE=$1
[ -w "$FILE" ] || { echo "ERROR no se puede escribir ${FILE} imposible continuar"; exit 1; }
SYSMODEL=$( awk '{ print $0 }' /proc/device-tree/model | sed 's|Raspberry Pi||;s|Rev.*||;s|Model||;s|Zero|0|;s|Plus|+|;s|B| |;s|A| |;s| ||g' )

echo -n "Buscar config.txt para i2c_arm ... "
grep -i '^dtparam=i2c_arm=on' $FILE 1> /dev/null && { echo "ENCONTRADO"; exit 0; } || echo "NO ENCONTRADO"
echo -n "Insertar i2c_arm en ${FILE} ... "
if [[ `grep -i "^\[pi${SYSMODEL}\]" $FILE` ]]
then
    sed  -i "/^\[pi${SYSMODEL}\]/a dtparam=i2c_arm=on" $FILE && echo "CORRECTO";
else
    echo "dtparam=i2c_arm=on" >> $FILE && echo "CORRECTO";
fi
echo -n "Buscar /etc/modules for i2c-dev ... "
grep -i '^i2c-dev' /etc/modules 1> /dev/null && { echo "ENCONTRADO"; exit 0; } || echo "NO ENCONTRADO"
echo -n "Insertar i2c-dev en /etc/modules "
echo "i2c-dev" >> /etc/modules && echo "CORRECTO";
exit 0