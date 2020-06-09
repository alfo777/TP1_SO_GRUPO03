#!/bin/bash

#										.:FUNCIONES:.

#Esta funcion nos dice si el directorio de arribos (nov por defecto) esta vacio o no. Devuelve 0 si esta vacio y 1 si no lo esta.
function directorio_novedades_vacio
{
	cd $DIRNOV

	local cant=`ls -1 | grep '.' | wc -w`

	if [ $cant -eq 0 ]
	then
		return 0
	else
		return 1
	fi
}

#Esta funcion toma todos los archivos que estan en novedades y verifica si son aceptados o rechazados, a los rechazados
# los manda a nok y a los aceptados a ok.

function procesar_novedades
{

	cd $DIRNOV

	local novedades=( $( ls -1 ) )
	local nombre_valido
	local contenido_valido
	local sin_duplicados

	for archivo_novedad_i in ${novedades[@]}
	do
		validar_nombre $archivo_novedad_i

		nombre_valido=$?

		validar_contenido $archivo_novedad_i

		contenido_valido=$?

		no_hay_duplicados $archivo_novedad_i

		sin_duplicados=$?

		if [ $nombre_valido -eq 1  ] && [ $contenido_valido -eq 1 ] && [ $sin_duplicados -eq 1 ]
		then
			mv $DIRNOV"/"$archivo_novedad_i $DIROK
		else
			mv $DIRNOV"/"$archivo_novedad_i $DIRNOK
		fi
	done

	return 0
}

function no_hay_duplicados(){

	local procesados=($(ls -1 $DIRPROC))
	for archivo_procesado_i in ${procesados[*]}
	do
		if [[ $procesados == $archivo_procesado_i ]]
		then
			return 0
		fi
	done

	return 1

}


#devuelve 1 si el archivo no esta vacio y 0 si lo esta.

function validar_contenido()
{
	local valido=`cat $1 | grep '.' | wc -w`

	if [ $valido -ne 0 ]
	then
		return 1
	else
		return 0
	fi
}

#Esta funcion devuelve 1 si el nombre del archivo es valido y 0 si no lo es.

function validar_nombre ()
{
	local fecha_valida
	local cod_estado_valido
	local cod_comercio_valido

	validar_fecha $1

	fecha_valida=$?

	validar_codigo_estado $1

	cod_estado_valido=$?

	validar_codigo_comercio $1

	cod_comercio_valido=$?

	if [ $fecha_valida -eq 1 ] && [ $cod_estado_valido -eq 1 ] && [ $cod_comercio_valido -eq 1 ]
	then
		return 1
	else
		return 0
	fi
}

#Esta funcion devuelve 1 si la fecha del archivo es valida y 0 si no lo es.

function validar_fecha ()
{
	local fecha=`echo $1 | sed 's=^\(.*\)-\(.*\)-\(.*\).\(csv\)$=\1='`

	local valida=`echo $fecha | grep '^020[1-9]$\|^02[1-2][0-9]$' | #febrero
		grep '^0[469]0[1-9]$\|^0[469][1-2][0-9]$\|^0[469]30$\|^110[1-9]$\|^11[1-2][0-9]$\|^1130$' | #abril, junio, septiembre, noviembre
		grep '^0[13578]0[1-9]$\|0[13578][1-2][0-9]$\|^0[13578]3[0-1]$\|^1[02]0[1-9]$\|^1[02][1-2][0-9]$\|^1[02]3[0-1]$' | wc -w` # el resto

	if [ $valida -eq 1 ]
	then
		return 1
	else
		return 0
	fi
}


#Esta funcion devuelve 1 si el codigo de estado del archivo es valido y 0 si no lo es.

function validar_codigo_estado()
{
	local cod_estado=`echo $1 | sed 's=^\(.*\)-\(.*\)-\(.*\).\(csv\)$=\2='`
	local provincias=( $(cat $DIRTAB/"Tabla_provincias.csv") )
	local codigo

	for provincias_i in ${provincias[@]}
	do
		codigo=`echo $provincias_i | cut -d "," -f 2`

		if [[ $cod_estado == $codigo ]]
		then
			return 1
		fi
	done

	return 0
}

#Esta funcion devuelve 1 si el cadigo de comercio del archivo es valido y 0 si no lo es.

function validar_codigo_comercio()
{
	local cod_comercio=`echo $1 | sed 's=^\(.*\)-\(.*\)-\(.*\).\(csv\)$=\3='`
	local comercios=( $(cat $DIRTAB/"Tabla_comercio.csv") )
	local codigo
	local estado_comercio

	echo ${comercio[@]}

	for comercio_i in ${comercios[@]}
	do
		codigo=`echo $comercio_i | cut -d "," -f 1`
		estado_comercio=`echo $comercio_i | cut -d "," -f 2`

		if [[ $cod_comercio == $codigo ]] && [[ $estado_comercio == "HABILITADO" ]]
		then
			return 1
		fi
	done

	return 0
}


#										.:proceso:.

if [[ $HAYAMBIENTE == "" ]]
then
	echo "No hay ambiente para ejecutar el proceso. Por favor ejecute el inicializador para levantar el ambiente."
	echo "Para ejecutar el ambiente vaya al directorio de ejecutables y ejecute:"
	echo -e ". ./inicializar.sh"
	exit 0
fi

iteracion=1

while [ $iteracion -ne 10001 ]
do
	directorio_novedades_vacio

	if [ $? -eq 0 ]
	then
		sleep 1m
		let "iteracion=$iteracion+1"
		continue
	fi

	procesar_novedades



	validar_nombre


	let "iteracion=$iteracion+1"
	sleep 10s #cambiar a 1min al final
done