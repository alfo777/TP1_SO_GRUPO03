#!/bin/bash

if [ $# -ne 0 ]
then
	echo "Error: Este proceso no recive parametros."
else

	if [[ $HAYAMBIENTE == "" ]] 
	then
		echo "El ambiente del sistema no ha sido lanzado todavia, el proceso no puede lanzarse."
	else

		PROCESOID=`ps | grep 'proceso.sh$'`

		id=`echo $PROCESOID | cut -d " " -f 1 `

		PROCESOID=$id

		if [[ $PROCESOID != "" ]]
		then
			echo "Ya existe un proceso en ejecucion."
		else
			echo "Lanzando proceso"

			export GRUPO
			readonly GRUPO
			export DIRINST
			readonly DIRINST
			export DIRBIN
			readonly DIRBIN
			export DIRTAB
			readonly DIRTAB
			export DIRNOV
			readonly DIRNOV
			export DIROK
			readonly DIROK
			export DIRNOK
			readonly DIRNOK
			export DIRPROC
			readonly DIRPROC
			export DIRSAL
			readonly DIRSAL
			export HCIERRE
			readonly HCIERRE

			if [ ! -f "proceso.sh" ]
			then
				echo "No hay proceso en el directorio, se tiene que reparar la instalacion con:"
				echo -e "./instalador.sh -r"
				HAYAMBIENTE=""
			fi

			export HAYSTART=true

			./proceso.sh &

			
			PROCESOID=`ps | grep 'proceso.sh$'`

			id=`echo $PROCESOID | cut -d " " -f 1 `

			PROCESOID=$id

			echo "Se lanzo el proceso con id: "$PROCESOID

			export HAYSTART=""

		fi
	fi
fi
