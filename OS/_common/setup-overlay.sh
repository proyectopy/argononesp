#!/bin/bash
[ $# -eq 0 ] && FILE=/boot/config.txt || FILE=$1
[ -w "$FILE" ] || { echo "  ERROR no se puede escribir en ${FILE} no puedes continuarbuscar"; exit 1; }
SYSMODEL=$( awk '{ print $0 }' /proc/device-tree/model | sed 's|Raspberry Pi||;s|Rev.*||;s|Model||;s|Zero|0|;s|Plus|+|;s|B| |;s|A| |;s| ||g' )

echo -n "  buscar ${FILE} para overlay ... "
grep -i '^dtoverlay=argonone' $FILE 1> /dev/null && { echo "ENCONTRADO"; exit 0; } || echo "NOT FOUND"
cp $FILE $FILE.backup
echo -n "  insertar overlay en ${FILE} ... "
if [[ `grep -i "^\[pi${SYSMODEL}\]" $FILE` ]]
then
    sed -i "/^\[pi${SYSMODEL}\][^\n]*/I,\$!b;//{x;//p;g};//!H;\$!d;x;s//&\ndtoverlay=argonone/" $FILE && { echo "DONE"; } || { echo "Failed"; }
else
    echo -e "[pi${SYSMODEL}]\ndtoverlay=argonone" >> $FILE && { echo "CORRECTO"; } || { echo "Fallido"; }
fi
exit 0
