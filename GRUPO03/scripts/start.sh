#!/bin/bash

if [ $# -ne 0 ]
then
	echo "Error: Este proceso no recive parametros."
else

	if [[ $HAYAMBIENTE == "" ]] 
	then
		echo "El ambiente del sistema no ha sido lanzado todavia, el proceso no puede lanzarse."
	else

		if [[ $PROCESOID != "" ]]
		then
			echo "Ya existe un proceso en ejecucion."
		else
			echo "Lanzando proceso"

			export GRUPO
			export DIRINST
			export DIRBIN
			export DIRTAB
			export DIRNOV
			export DIROK
			export DIRNOK
			export DIRPROC
			export DIRSAL
			export HCIERRE

			./proceso.sh &
			
			PROCESOID=`ps | grep 'proceso.sh$' | cut -d  " " -f 1`

			echo "Se lanzo el proceso con id: "$PROCESOID

		fi
	fi
fi
