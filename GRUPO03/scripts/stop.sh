#!/bin/bash

if [ $# -ne 0 ]
then
	echo "Error: Este proceso no recive parametros."
else

	if [[ $HAYAMBIENTE == "" ]] 
	then
		echo "El ambiente del sistema no ha sido lanzado todavia, el proceso no puede lanzarse."
	else
		id=`ps | grep 'proceso.sh$'`

		PROCESOID=`echo $id | cut -d " " -f 1 `

		if [[ $PROCESOID != "" ]]
		then
			kill $PROCESOID
			echo "El proceso con id "$PROCESOID" fue terminado."
			PROCESOID=""
		else
			echo "No hay proceso corriendo."
		fi
	fi
fi
