#!/bin/bash


#													.:FUNCIONES:.



#Esta funcion devuelve 1 si el sistema fue instalado con exito y 0 si no lo fue. Si devuelve 2 significa que el script instalador no esta.
function instalado
{
	cd ..
	cd "inst"

	local op=1

	#Primero verifico si el archivo de configuracion esta, sino el sistema se tiene que reparar
	if [ -f "instalador.conf" ]
	then
		sed 's/-/=/g' instalador.conf >> instalador_aux.conf
		source instalador_aux.conf
		rm instalador_aux.conf

		#Ahora verifico si existen el proceso, el instalador, el inicializador y las tablas


		if [ ! -d $DIRBIN ]
		then
			echo -e "\n\tNo se encontro el directorio para los archivos ejecutables."
			return 0
		fi

		if [ ! -f $DIRBIN"/proceso.sh" ]
		then
			echo -e "\n\tNo se encontro el script proceso."
			op=0
		fi

		if [ ! -d $DIRTAB ]
		then
			echo -e  "\n\tNo se encontro el directorio de tablas."
			op=0
		fi

		if [ ! -f $DIRTAB"/Tabla_provincias.csv" ]
		then
			echo -e "\n\tNo se encontro la tabla de provincias."
			op=0
		fi

		if [ ! -f $DIRTAB"/Tabla_comercio.csv" ]
		then
			echo -e "\n\tNo se encontro la tabla de comercios."
			op=0
		fi

		if [ ! -f $DIRTAB"/Tabla_respuesta_gateway.csv" ]
		then
			echo -e "\n\tNo se encontro la tabla de comercios."
			op=0
		fi

		#Ahora verifico si el resto de los directorios existen

		if [ ! -d $DIRNOV ]
		then
			echo -e "\n\tNo se encontro el directorio para los archivos de novedades."
			op=0
		fi

		if [ ! -d $DIROK ]
		then
			echo -e "\n\tNo se encontro el directorio para los archivos de novedades aceptados."
			op=0
		fi

		if [ ! -d $DIRNOK ]
		then
			echo -e "\n\tNo se encontro el directorio para los archivos de novedades rechazados."
			op=0
		fi

		if [ ! -d $DIRPROC ]
		then
			echo -e "\n\tNo se encontro el directorio para los archivos de procesados."
			op=0
		fi

		if [ ! -d $DIRSAL ]
		then
			echo -e "\n\tNo se encontro el directorio para los archivos de salida."
			op=0
		fi


		if [ ! -f $DIRINST"/instalador.sh" ]
		then
			echo -e "\n\tNo se encontro el script instalador."
			op=2
		fi

	else
		echo -e "\n\tNo se encontro el archivo de configuracion."
	fi

	cd $DIRBIN
	return $op
}


function verificar_permisos
{
	#Verifico el permiso de las tablas, si es solo de lectura se informa y se lo cambia a dicho permiso

	echo -e "\nSe verifican los permisos: "

	cd $DIRTAB

	permiso=`ls -l "Tabla_comercio.csv" | cut -d " " -f 1`

	if [[ $permiso != "-r--r--r--" ]]
	then
		echo -e "\n\tLa tabla de comercios no tiene los permisos correctos, se la corregira."
		umask u=r,g=r,o=r  "Tabla_comercio.csv"
	fi

	permiso=`ls -l "Tabla_provincias.csv" | cut -d " " -f 1`

	if [[ $permiso != "-r--r--r--" ]]
	then
		echo -e "\n\tLa tabla de provincias no tiene los permisos correctos, se la corregira."
		umask u=r,g=r,o=r "Tabla_provincias.csv"
	fi

	permiso=`ls -l "Tabla_respuesta_gateway.csv" | cut -d " " -f 1`

	if [[ $permiso != "-r--r--r--" ]]
	then
		echo -e "\n\tLa tabla de provincias no tiene los permisos correctos, se la corregira."
		umask u=r,g=r,o=r "Tabla_respuesta_gateway.csv"
	fi

	#TODO: falta agregar permisos para los scripts


	echo -e "\nVerificacion de permisos terminada."

	cd $DIRBIN

	return 0
}

# Esta funcion devuelve 1 si el sistema ya fue inicializado y 0 si no lo fue.
function inicializado
{
	if [[ $HAYAMBIENTE != "" ]]
	then 
		return 1
	fi
	return 0
}

# Esta funcion devuelve 1 si el usuario ingresi "SI" y 0 si ingreso "NO"
function ingresarSiNo
{
	while [ 1 ]	
	do
		read respuesta

		if [[ $respuesta == "SI" ]]
		then
			return 1
		elif [[ $respuesta == "NO" ]]
		then
			return 0
		fi
	done
}



#											.:INICIALIZADOR:.


# Primero se verifica si el sistema esta bien instalado. De no ser asi se explica cuales son los archivos y directorios que faltan y como hacer para repararlo (si esto es posible). 


if [ $# -ne 0 ]
then
	echo "El inicializador no puede recibir parametros, este proceso se cerrara."
else

	inicializado

	if [ $? -eq 1 ]
	then
		echo "El sistema ya se inicializo."

	else

		echo -e "\t\t\tINICIALIZACION"

		echo -e "\nVerificando instalacion:"

		instalado

		op=$?

		if [ $op -eq 0 ]
		then
			echo -e "\nInstalacion incompleta, el sistema tiene que ser reparado. Por favor ir a la carpeta inst y ejecutar por linea de comando:"
			echo -e "\n\t./instalador.sh -r"
		elif [ $op -eq 2 ]
		then
			echo -e "\nInstalacion incompleta. No pudo encontrarse el script instalador en el directorio inst. Por favor recuperarlo en ese directorio, de lo contrario el sistema no podra ser reparado."
		elif [ $op -eq 1 ]
		then
			echo -e "\nEl sistema esta instalado."

			verificar_permisos

			export HAYAMBIENTE=true
	
			echo "El ambiente para lanzar el proceso ya fue levantado. inicializacion exitosa."
			echo -e "\nEl proceso puede ser lanzado desde el inicializador o puede lanzarse ejecutando el scritp "start.sh"."

			echo -ne "\n¿Desea lanzar el proceso ahora? SI-NO: "

			ingresarSiNo

			if [ $? -eq 1 ]
			then
				. ./start.sh
			else
				echo "El inicializador se cerrara."
				echo -e "\nPuede lanzar el proceso manualmente asi:"
				echo -e "\n\t./start.sh\n"

			fi
		fi
	fi
fi