#!/bin/bash

#												.:FUNIONES:.

#Esta funcion loguea mensajes de tipo ERROR, recibe dos parametros que son el mensaje y a la que pertenece el mensaje
function loguearERROR()
{	
	if [ -d "$DIRPROC" ] && [ ! -f "$DIRPROC/inicializador.log" ]
	then
		dir_log="$DIRPROC/inicializador.log"
		cat "$dir_actual/inicializador.log" >> "$dir_log"
		rm "$dir_actual/inicializador.log"
	elif [ ! -d "$DIRPROC" ]
	then
		dir_log="$dir_actual/inicializador.log"

	elif [ -f "$DIRPROC/inicializador.log" ]
	then
		dir_log="$DIRPROC/inicializador.log"

		if [ -f "$dir_actual/inicializador.log" ]
		then
			rm "$dir_actual/inicializador.log"
		fi
	fi
	local fecha=`date +%Y-%m-%d"  "%T`
	local linea="[ "$fecha" ]-ERR-"$1"-"$2

	echo -e $linea"\n" >> "$dir_log"
	return 0
}
#Esta funcion loguea mensajes de tipo INFO, recibe dos parametros que son el mensaje y a la que pertenece el mensaje
function loguearINFO()
{
	if [ -d "$DIRPROC" ] && [ ! -f "$DIRPROC/inicializador.log" ]
	then
		dir_log="$DIRPROC/inicializador.log"
		cat "$dir_actual/inicializador.log" >> "$dir_log"
		rm "$dir_actual/inicializador.log"
	elif [ ! -d "$DIRPROC" ]
	then
		dir_log="$dir_actual/inicializador.log"

	elif [ -f "$DIRPROC/inicializador.log" ]
	then

		dir_log="$DIRPROC/inicializador.log"

		if [ -f "$dir_actual/inicializador.log" ]
		then
			rm "$dir_actual/inicializador.log"
		fi
	fi
	local fecha=`date +%Y-%m-%d"  "%T`
	local linea="[ "$fecha" ]-INF-"$1"-"$2
	echo -e $linea"\n" >> "$dir_log"
	return 0
}
#Esta funcion loguea mensajes de tipo ALERTA, recibe dos parametros que son el mensaje y a la que pertenece el mensaje
function loguearALE()
{
	if [ -d "$DIRPROC" ] && [ ! -f "$DIRPROC/inicializador.log" ]
	then
		dir_log="$DIRPROC/inicializador.log"
		cat "$dir_actual/inicializador.log" >> "$dir_log"
		rm "$dir_actual/inicializador.log"
	elif [ ! -d "$DIRPROC" ]
	then
		dir_log="$dir_actual/inicializador.log"

	elif [ -f "$DIRPROC/inicializador.log" ]
	then

		dir_log="$DIRPROC/inicializador.log"

		if [ -f "$dir_actual/inicializador.log" ]
		then
			rm "$dir_actual/inicializador.log"
		fi
	fi
	local fecha=`date +%Y-%m-%d"  "%T`
	local linea="[ "$fecha" ]-INF-"$1"-"$2

	echo -e $linea"\n" >> "$dir_log"
	return 0
}


#Esta funcion devuelve:
# +) -1 si el sistema no fue instalado
# +)  0 si el sistema se instalo pero se necesita reparar.
# +)  1 si el sistema esta instalado completamente
# +)  2 si el instalador no est aen inst

function instalado
{
	loguearINFO "Comprobando si el sistema esta roto" "instalado"

	cd ..

	op=1

	if [ ! -d "$GRUPO/inst" ]
	then
		loguearALE "No se encontro el directorio de instalacion" "instalado"
		echo -e "\n\tNo se encontro el directorio de instalacion."
		HAYAMBIENTE=""
		op=0
	fi

	cd "$GRUPO/inst"

	#Primero verifico si el archivo de configuracion esta, sino el sistema se tiene que reparar
	if [ -f "instalador.conf" ]
	then
		sed 's/-/=/g' instalador.conf >> instalador_aux.conf
		source instalador_aux.conf
		rm instalador_aux.conf

		#Ahora verifico si existen el proceso, el instalador, el inicializador y las tablas

		
		loguearINFO "Hay archivo de configuracion, el sistema se lo considera como instalado. Se comprueba si la instalacion esta rota o no" "instalado"


		if [ ! -d "$DIRBIN" ]
		then
			loguearALE "No se encontro el directorio para los archivos ejecutables" "instalado"
			echo -e "\n\tNo se encontro el directorio para los archivos ejecutables."
			HAYAMBIENTE=""
			op=0
		fi

		if [ ! -f "$DIRBIN/start.sh" ]
		then
			loguearALE "No se encontro el script start.sh en el directorio de ejecutables" "instalado"
			echo -e "\n\tNo se encontro el script start.sh en el directorio de ejecutables."
			HAYAMBIENTE=""
			op=0
		fi

		if [ ! -f "$DIRBIN/stop.sh" ]
		then
			loguearALE "No se encontro el script stop.sh en el directorio de ejecutables" "instalado"
			echo -e "\n\tNo se encontro el script stop.sh en el directorio de ejecutables."
			HAYAMBIENTE=""
			op=0
		fi

		if [ ! -f "$DIRBIN/proceso.sh" ]
		then
			loguearALE "No se encontro el script proceso en el directorio de ejecutables" "instalado"
			echo -e "\n\tNo se encontro el script proceso en el directorio de ejecutables."
			HAYAMBIENTE=""
			op=0
		fi

		if [ ! -d "$DIRTAB" ]
		then
			loguearALE "No se encontro el directorio de tablas" "instalado"
			echo -e  "\n\tNo se encontro el directorio de tablas."
			HAYAMBIENTE=""
			op=0
		fi

		if [ ! -f "$DIRTAB/Tabla_provincias.csv" ]
		then
			loguearALE "No se encontro la tabla de provincias" "instalado"
			echo -e "\n\tNo se encontro la tabla de provincias."
			HAYAMBIENTE=""
			op=0
		fi

		if [ ! -f "$DIRTAB/Tabla_comercio.csv" ]
		then
			loguearALE "No se encontro la tabla de comercios" "instalado"
			echo -e "\n\tNo se encontro la tabla de comercios."
			HAYAMBIENTE=""
			op=0
		fi

		if [ ! -f "$DIRTAB/Tabla_respuesta_gateway.csv" ]
		then
			loguearALE "No se encontro la tabla de respuestas de gateway" "instalado"
			echo -e "\n\tNo se encontro la tabla de respuestas de gateway."
			HAYAMBIENTE=""
			op=0
		fi

		#Ahora verifico si el resto de los directorios existen

		if [ ! -d "$DIRNOV" ]
		then
			loguearALE "No se encontro el directorio para los archivos de novedades" "instalado"
			echo -e "\n\tNo se encontro el directorio para los archivos de novedades."
			HAYAMBIENTE=""
			op=0
		fi

		if [ ! -d "$DIROK" ]
		then
			loguearALE "No se encontro el directorio para los archivos de novedades aceptados" "instalado"
			echo -e "\n\tNo se encontro el directorio para los archivos de novedades aceptados."
			HAYAMBIENTE=""
			op=0
		fi

		if [ ! -d "$DIRNOK" ]
		then
			loguearALE "No se encontro el directorio para los archivos de novedades rechazados" "instalado"
			echo -e "\n\tNo se encontro el directorio para los archivos de novedades rechazados."
			HAYAMBIENTE=""
			op=0
		fi

		if [ ! -d "$DIRPROC" ]
		then
			loguearALE "No se encontro el directorio para los archivos de procesados" "instalado"
			echo -e "\n\tNo se encontro el directorio para los archivos de procesados."
			HAYAMBIENTE=""
			op=0
		fi

		if [ ! -d "$DIRSAL" ]
		then
			loguearALE "No se encontro el directorio para los archivos de salida" "instalado"
			echo -e "\n\tNo se encontro el directorio para los archivos de salida."
			HAYAMBIENTE=""
			op=0
		fi


		if [ ! -f "$DIRINST/instalador.sh" ]
		then
			loguearALE "No se encontro el script instalador" "instalado"
			echo -e "\n\tNo se encontro el script instalador."
			HAYAMBIENTE=""
			op=0
		fi

	else
		loguearALE "No se encontro el archivo de configuracion" "instalado"
		echo -e "\n\tNo se encontro el archivo de configuracion."
		HAYAMBIENTE=""
		op=0
	fi

	cd "$dir_actual"

	return $op
}

#											.:START:.

dir_actual=$PWD

cd ..

GRUPO=$PWD

cd "$dir_actual"

#Este script se encarga de iniciar manualmente al proceso
if [ $# -ne 0 ]
then
	loguearERROR "Error: Este proceso no recive parametros" "start"
	echo "Error: Este proceso no recive parametros."
else


	loguearINFO "Verificando si el ambiente esta levantado o no" "start"
	echo -e "\nVerificando si el ambiente esta levantado o no:"

	instalado

	opcion=$?

	if [ $opcion -eq 0 ]
	then
		loguearALE "Instalacion rota, se cierra start y se indica al usuario como reparar al sistema" "start"
		echo -e "\nLa instalacion esta rota, repararla ejecutandoel instalador en el directorio inst:"
		echo -e "\n\t./instalador.sh -r"

	elif [[ $HAYAMBIENTE == "" ]] && [ $opcion -eq 1 ]
	then
		loguearALE "El ambiente del sistema no ha sido lanzado todavia, el proceso no puede lanzarse" "start"
		echo -e "\nEl ambiente del sistema no ha sido lanzado todavia, el proceso no puede lanzarse."
	else

		PROCESOID=`ps -C proceso.sh | grep 'proceso.sh$'`

		id=`echo $PROCESOID | cut -d " " -f 1 `

		PROCESOID=$id

		if [[ $PROCESOID != "" ]]
		then
			loguearALE "Ya existe un proceso en ejecucion, no puede lanzarse otro" "start"
			echo "Ya existe un proceso en ejecucion, no puede lanzarse otro."
		else
			echo "Lanzando proceso"

			if [ ! -f "$DIRBIN/proceso.sh" ]
			then
				loguearALE "No se encuantra el proceso, reparar instalacion y lanzar al inicializador devuelta" "start"
				echo "No hay proceso en el directorio, se tiene que reparar la instalacion con:"
				echo -e "\n\t./instalador.sh -r"
				HAYAMBIENTE=""
			fi

			export HAYSTART=true

			./proceso.sh & 

			
			PROCESOID=`ps | grep 'proceso.sh$'`

			id=`echo $PROCESOID | cut -d " " -f 1 `

			PROCESOID=$id

			echo "Se lanzo el proceso con id: "$PROCESOID
			echo "Hora de cierre: "$HCIERRE

			echo "Para detener el proceso se tiene que esperar a que haga las iteraciones definidas, o bien puede hacerlo con el comando stop asi:"
			echo -e "\n\t. ./stop.sh"

			loguearINFO "Se lanzo el proceso con id: "$PROCESOID "start"
			loguearINFO "Hora de cierre:"$HCIERRE "start"

			export HAYSTART=""

		fi
	fi
fi

echo -e "\n" >> "$dir_log"