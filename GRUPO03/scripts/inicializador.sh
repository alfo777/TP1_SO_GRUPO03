#!/bin/bash


#													.:FUNCIONES:.



#Esta funcion devuelve:
# +) -1 si el sistema no fue instalado
# +)  0 si el sistema se instalo pero se necesita reparar.
# +)  1 si el sistema esta instalado completamente
# +)  2 si el instalador no est aen inst

function instalado
{
	loguearINFO "Comprobando que el estado del sistema no es el estado inicial(sin instalar)" "instalado"

	cd ..

	if [ -f "$GRUPO//scripts/proceso.sh" ] && [ -f "$GRUPO/inst/instalador.sh" ] &&
       [ -f "$GRUPO/scripts/inicializador.sh" ] && [ -f "$GRUPO/tablas_cpr/Tabla_comercio.csv" ] &&
       [ -f "$GRUPO/tablas_cpr/Tabla_provincias.csv" ] && [ -f "$GRUPO/tablas_cpr/Tabla_respuesta_gateway.csv" ] &&
       [ -d "$GRUPO/docs" ] && [ -d "$GRUPO/pruebas" ]
	then
		loguearINFO "El estado del sistema es el estado inicial, el sistema no esta instalado" "instalado"
		return -1
	fi

	cd "inst"

	local op=1

	loguearINFO "Comprobado que el sistema no esta en su estado inicial se busca el archivo de configuracion" "instalado"

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
			op=0
		fi

		if [ ! -f "$DIRBIN/start.sh" ]
		then
			loguearALE "No se encontro el script start.sh en el directorio de ejecutables" "instalado"
			echo -e "\n\tNo se encontro el script start.sh en el directorio de ejecutables."
			op=0
		fi

		if [ ! -f "$DIRBIN/stop.sh" ]
		then
			loguearALE "No se encontro el script stop.sh en el directorio de ejecutables" "instalado"
			echo -e "\n\tNo se encontro el script stop.sh en el directorio de ejecutables."
			op=0
		fi

		if [ ! -f "$DIRBIN/proceso.sh" ]
		then
			loguearALE "No se encontro el script proceso en el directorio de ejecutables" "instalado"
			echo -e "\n\tNo se encontro el script proceso en el directorio de ejecutables."
			op=0
		fi

		if [ ! -d "$DIRTAB" ]
		then
			loguearALE "No se encontro el directorio de tablas" "instalado"
			echo -e  "\n\tNo se encontro el directorio de tablas."
			op=0
		fi

		if [ ! -f "$DIRTAB/Tabla_provincias.csv" ]
		then
			loguearALE "No se encontro la tabla de provincias" "instalado"
			echo -e "\n\tNo se encontro la tabla de provincias."
			op=0
		fi

		if [ ! -f "$DIRTAB/Tabla_comercio.csv" ]
		then
			loguearALE "No se encontro la tabla de comercios" "instalado"
			echo -e "\n\tNo se encontro la tabla de comercios."
			op=0
		fi

		if [ ! -f "$DIRTAB/Tabla_respuesta_gateway.csv" ]
		then
			loguearALE "No se encontro la tabla de respuestas de gateway" "instalado"
			echo -e "\n\tNo se encontro la tabla de respuestas de gateway."
			op=0
		fi

		#Ahora verifico si el resto de los directorios existen

		if [ ! -d "$DIRNOV" ]
		then
			loguearALE "No se encontro el directorio para los archivos de novedades" "instalado"
			echo -e "\n\tNo se encontro el directorio para los archivos de novedades."
			op=0
		fi

		if [ ! -d "$DIROK" ]
		then
			loguearALE "No se encontro el directorio para los archivos de novedades aceptados" "instalado"
			echo -e "\n\tNo se encontro el directorio para los archivos de novedades aceptados."
			op=0
		fi

		if [ ! -d "$DIRNOK" ]
		then
			loguearALE "No se encontro el directorio para los archivos de novedades rechazados" "instalado"
			echo -e "\n\tNo se encontro el directorio para los archivos de novedades rechazados."
			op=0
		fi

		if [ ! -d "$DIRPROC" ]
		then
			loguearALE "No se encontro el directorio para los archivos de procesados" "instalado"
			echo -e "\n\tNo se encontro el directorio para los archivos de procesados."
			op=0
		fi

		if [ ! -d "$DIRSAL" ]
		then
			loguearALE "No se encontro el directorio para los archivos de salida" "instalado"
			echo -e "\n\tNo se encontro el directorio para los archivos de salida."
			op=0
		fi


		if [ ! -f "$DIRINST/instalador.sh" ]
		then
			loguearALE "No se encontro el script instalador" "instalado"
			echo -e "\n\tNo se encontro el script instalador."
			op=2
		fi

	else
		loguearALE "No se encontro el archivo de configuracion" "instalado"
		echo -e "\n\tNo se encontro el archivo de configuracion."
		op=-1
	fi

	cd "$DIRBIN"
	return $op
}

#Esta funcion verifica si todas las tablas tienen permiso de lectura y todos los scripts de lectura y escritura, si alguno de 
# estos no tienen sus permisos designados entonces se los corrigen.
function verificar_permisos
{
	#Verifico el permiso de las tablas, si es solo de lectura se informa y se lo cambia a dicho permiso
	loguearINFO "Se verifican los permisos" "verificar_permisos"
	echo -e "\nSe verifican los permisos: "

	cd "$DIRTAB"

	permiso=`ls -l "Tabla_comercio.csv" | cut -d " " -f 1`

	if [[ $permiso != "-r--r--r--" ]]
	then
		loguearALE "La tabla de comercios no tiene los permisos correctos, se la corregira" "verificar_permisos"
		echo -e "\n\tLa tabla de comercios no tiene los permisos correctos, se la corregira."
		chmod 444  "Tabla_comercio.csv"
	fi

	permiso=`ls -l "Tabla_provincias.csv" | cut -d " " -f 1`

	if [[ $permiso != "-r--r--r--" ]]
	then
		loguearALE "La tabla de provincias no tiene los permisos correctos, se la corregira" "verificar_permisos"
		echo -e "\n\tLa tabla de provincias no tiene los permisos correctos, se la corregira."
		chmod 444 "Tabla_provincias.csv"
	fi

	permiso=`ls -l "Tabla_respuesta_gateway.csv" | cut -d " " -f 1`

	if [[ $permiso != "-r--r--r--" ]]
	then
		loguearALE "La tabla de respuestas de gateway no tiene los permisos correctos, se la corregira" "verificar_permisos"
		echo -e "\n\tLa tabla de respuestas de gateway no tiene los permisos correctos, se la corregira."
		chmod 444 "Tabla_respuesta_gateway.csv"
	fi

	cd "$DIRINST"

	permiso=`ls -l "instalador.sh" | cut -d " " -f 1`

	if [[ $permiso != "-r-xr-xr-x" ]]
	then
		loguearALE "El instalador no tiene los permisos correctos, se lo corregira" "verificar_permisos"
		echo -e "\n\tEl instalador no tiene los permisos correctos, se lo corregira."
		chmod 555 "instalador.sh"
	fi

	permiso=`ls -l "instalador.log" | cut -d " " -f 1`

	if [[ $permiso != "-r--r--r--" ]]
	then
		loguearALE "El log de instalacion no tiene los permisos correctos, se lo corregira" "verificar_permisos"
		echo -e "\n\tEl log de instalacion no tiene los permisos correctos, se lo corregira."
		chmod 444 "instalador.log"
	fi

	permiso=`ls -l "instalador.conf" | cut -d " " -f 1`

	if [[ $permiso != "-r--r--r--" ]]
	then
		loguearALE "Archivo de configuracion no tiene los permisos correctos, se lo corregira" "verificar_permisos"
		echo -e "\n\tArchivo de configuracion no tiene los permisos correctos, se lo corregira."
		chmod 555 "instalador.log"
	fi

	cd "$DIRBIN"

	permiso=`ls -l "proceso.sh" | cut -d " " -f 1`

	if [[ $permiso != "-r-xr-xr-x" ]]
	then
		loguearALE "El proceso no tiene los permisos correctos, se lo corregira" "verificar_permisos"
		echo -e "\n\tEl proceso no tiene los permisos correctos, se lo corregira."
		chmod 555 "proceso.sh"
	fi

	permiso=`ls -l "inicializador.sh" | cut -d " " -f 1`

	if [[ $permiso != "-r-xr-xr-x" ]]
	then
		loguearALE "El inicializador no tiene los permisos correctos, se lo corregira" "verificar_permisos"
		echo -e "\n\tEl inicializador no tiene los permisos correctos, se lo corregira."
		chmod 555 "inicializador.sh"
	fi

	permiso=`ls -l "stop.sh" | cut -d " " -f 1`

	if [[ $permiso != "-r-xr-xr-x" ]]
	then
		loguearALE "La funcion stop no tiene los permisos correctos, se lo corregira" "verificar_permisos"
		echo -e "\n\tLa funcion stop no tiene los permisos correctos, se lo corregira."
		chmod 555 "stop.sh"
	fi

	permiso=`ls -l "start.sh" | cut -d " " -f 1`

	if [[ $permiso != "-r-xr-xr-x" ]]
	then
		loguearALE "La funcion start no tiene los permisos correctos, se lo corregira" "verificar_permisos"
		echo -e "\n\tLa funcion start no tiene los permisos correctos, se lo corregira."
		chmod 555 "start.sh"
	fi

	loguearINFO "Verificacion de permisos terminada" "verificar_permisos"
	echo -e "\nVerificacion de permisos terminada."

	cd "$DIRBIN"

	return 0
}

# Esta funcion devuelve 1 si el sistema ya fue inicializado y 0 si no lo fue.
function inicializado
{

	if [[ "$HAYAMBIENTE" != "" ]]
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

		if [[ "$respuesta" == "SI" ]]
		then
			return 1
		elif [[ "$respuesta" == "NO" ]]
		then
			return 0
		fi
	done
}

#Esta funcion loguea mensajes de tipo ERROR, recibe dos parametros que son el mensaje y a la que pertenece el mensaje
function loguearERROR()
{
	local fecha=`date +%Y-%m-%d"  "%T`
	local linea="[ "$fecha" ]-ERR-"$1"-"$2

	echo $linea >> $dir_log
	return 0
}
#Esta funcion loguea mensajes de tipo INFO, recibe dos parametros que son el mensaje y a la que pertenece el mensaje
function loguearINFO()
{
	local fecha=`date +%Y-%m-%d"  "%T`
	local linea="[ "$fecha" ]-INF-"$1"-"$2
	echo $linea >> $dir_log
	return 0
}
#Esta funcion loguea mensajes de tipo ALERTA, recibe dos parametros que son el mensaje y a la que pertenece el mensaje
function loguearALE()
{
	local fecha=`date +%Y-%m-%d"  "%T`
	local linea="[ "$fecha" ]-INF-"$1"-"$2

	echo $linea >> $dir_log
	return 0
}



#											.:INICIALIZADOR:.


#PRIMERO SE VE CUANTOS PARAMETROS RECIBIO EL SCRIPT, NO DEBERIA RECIBIR NINGUNO

dir_log="inicializador.log"
if [ -d "$DIRPROC" ]
then
	dir_log="$DIRPROC/inicializador.log"
fi


loguearINFO "COMIENZA INICIALIZADOR" "inicializador"

if [ $# -ne 0 ]
then
	#EL SCRITP RECIBIO PARAMETROS, SE VA A CERRAR
	loguearERROR "Error: El inicializador no puede recibir parametros, este proceso se cerrara" "inicializador"
	echo "Error: El inicializador no puede recibir parametros, este proceso se cerrara."

else
	#PRIMERO SE COMPRUEBA QUE EL SISTEMA ESTA INSTALADO
	loguearINFO "Verificando instalacion" "inicializador"
	echo -e "Verificando instalacion:"

	instalado

	op=$?

	if [ -d "$DIRPROC" ] && [ ! -f "$DIRPROC/inicializador.log" ]
	then
		dir_log="$DIRPROC/inicializador.log"
		cat "inicializador.log" >> "$DIRPROC/inicializador.log"
		rm "inicializador.log"
	fi
	
	#SI EL INICIALIZADOR VE QUE ESTADO DE DIRECTORIOS DEL DIRECTORIO GRUPO ES EL ESTADO INICIAL, O NO ENCUENTRA EL ARCHIVO DE CONFIGURACION
	# EL SISTEMA SE CONSIDERA NO INSTALADO, SI EL PRIMER CASO ES VERDADERO SE DEBERA INSTALAT EL SISTEMA,
	# SI EL SEGUNDO LO ES VER EN EL INSTALADOR COMO SE PUEDE RECUPERAR O CREAR EL ARCHIVO DE CONFIGURACION
	if [ $op -eq -1 ]
	then
		loguearALE "El sistema no esta instalado" "inicializador"
		echo -e "\tEl sistema no esta instalado."
		export HAYAMBIENTE=""
	#LA INSTALACION SE EFECTUO; PERO EL SISTEMA SE TIENE QUE REPARAR, SE LE DICE AL USUARIO COMO REPARAR EL SISTEMA Y SE CIERRA EL INICIALIZADOR
	elif [ $op -eq 0 ]
		then
			loguearALE "El sistema esta instalado, pero la instalacion esta rota. Se cierra el inicializador y se indica al usuario que hacer para reparar el sistema" "inicializador"
			echo -e "\nInstalacion incompleta, el sistema tiene que ser reparado. Por favor ir a la carpeta inst y ejecutar por linea de comando:"
			echo -e "\n\t./instalador.sh -r"
			export HAYAMBIENTE=""
	#EL INSTALADOR NO SE ENCUENTRA, ESTE ESCENARIO TIENE QUE SER REPARADO MANUALMENTE POR EL USUARIO YENDO A BUSCAR EL INSTALADOR DEL BACKUP
	elif [ $op -eq 2 ]
		then
			loguearALE "Instalacion incompleta. No pudo encontrarse el script instalador en el directorio inst. Por favor recuperarlo en ese directorio, de lo contrario el sistema no podra ser reparado" "inicializador"
			echo -e "\nInstalacion incompleta. No pudo encontrarse el script instalador en el directorio inst. Por favor recuperarlo en ese directorio, de lo contrario el sistema no podra ser reparado."
			export HAYAMBIENTE=""
	#EL SISTEMA ESTA INSTALADO CORRECTAMENTE
	elif [ $op -eq 1 ]
		then
			loguearINFO "El sistema esta instalado" "inicializador"
			loguearINFO "Verificando inicializacion" "inicializador"
			echo -e "\nEl sistema esta instalado."

			echo -e "\nVerificando inicializacion:"

			#AHORA SE VERIFICA SI EL SISTEMA YA SE INICIALIZO
			inicializado 


			#EL SISTEMA YA ESTA INICIALIZADO
			if [ $? -eq 1 ]
			then
				loguearINFO "El sistema ya se inicializo" "inicializador"
				echo "El sistema ya se inicializo."

			#EL SISTEMA NO SE INICIALIZO, SE LANZA LA INICIALIZACION
			else
				loguearINFO "El sistema no esta inicializado, se procedera con la inicializacion" "inicializador"

				echo "El sistema no esta inicializado, se procedera con la inicializacion"

				loguearINFO "INICIALIZACION" "inicializador"
				echo -e "\t\t\tINICIALIZACION"

				#PRIMERO SE VERIFICAN LOS PERMISOS

				verificar_permisos

				#LUEGO SE CREA LA VARIABLE HAYAMBIENTE, ESTA INDICA QUE EL AMBIENTE SE LEVANTO.

				export HAYAMBIENTE=true


				loguearINFO "El ambiente para lanzar el proceso ya fue levantado. inicializacion exitosa" "inicializador"
				loguearINFO "El proceso puede ser lanzado desde el inicializador o puede lanzarse ejecutando el scritp" "inicializador"
				loguearINFO "Se le da la opcion al usuario de lanzar el proceso desde el inicializador o no" "inicializador"

				echo "El ambiente para lanzar el proceso ya fue levantado. inicializacion exitosa."
				echo -e "\nEl proceso puede ser lanzado desde el inicializador o puede lanzarse ejecutando el scritp "start.sh"."

				#POR ULTIMO SE LE DA AL USUARIO LA POSIBILIDAD DE LANZAR EL PROCESO DESDE EL INICIALIZADOR SI LO DESEA.
				echo -ne "\n¿Desea lanzar el proceso ahora? SI-NO: "

				ingresarSiNo

				if [ $? -eq 1 ]
				then
					loguearINFO "El usuario eligio: SI. Se llamara a start.sh para que lanzar al proceso" "inicializador"
					#SI ACEPTA SE LLAMA A START PARA QUE LANZE EL PROCESO Y SE CIERRA EL INICIALIZADOR
					. ./start.sh
				else
					#SI RECHAZA ENTONCES SE TERMINA EL INICIALIZADOR EXITOSAMENTE
					loguearINFO "El usuario eligio: NO. Se indica como llamar a start.sh para arrancar el proceso y se cierra el inicializador" "inicializador"
					echo "El inicializador se cerrara."
					echo -e "\nPuede lanzar el proceso manualmente asi:"
					echo -e "\n\t. ./start.sh\n"

			fi
		fi
	fi

fi
loguearINFO "FIN INICIALIZADOR" "inicializador"
echo -e "\n" >> $dir_log