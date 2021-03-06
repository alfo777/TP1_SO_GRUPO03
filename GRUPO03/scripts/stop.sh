#!/bin/bash

#												.:FUNIONES:.

#Esta funcion loguea mensajes de tipo INFO, recibe dos parametros que son el mensaje y a la que pertenece el mensaje
function loguearINFO()
{
	local fecha=`date +%Y-%m-%d"  "%T`
	local linea="[ "$fecha" ]-INF-"$1"-"$2
	echo -e $linea"\n" >> "$dir_log"
	return 0
}


#											.:STOP:.

#Este script se engarga de hacerle un kill al proceso si este esta corriendo
dir_log="$DIRPROC/proceso.log"

if [ $# -ne 0 ]
then
	echo "Error: El stop no recibe parametros."
else

	if [[ $HAYAMBIENTE == "" ]] 
	then
		echo "El ambiente del sistema no ha sido lanzado todavia, el proceso no puede lanzarse."
	else
		id=`ps -C proceso.sh | grep 'proceso.sh$'`

		PROCESOID=`echo $id | cut -d " " -f 1 `

		if [[ $PROCESOID != "" ]]
		then
			kill $PROCESOID
			echo "El proceso con id "$PROCESOID" fue terminado."

			loguearINFO "El proceso con id "$PROCESOID" fue detenido con el comando stop." "stop"

			PROCESOID=""

		else
			loguearINFO "No hay proceso corriendo." "stop"
			echo "No hay proceso corriendo."
		fi
	fi
fi

echo -e "\n" >> "$dir_log"
