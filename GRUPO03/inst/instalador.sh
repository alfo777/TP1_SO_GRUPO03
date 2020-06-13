#!/bin/bash

#                                          .:FUNCIONES:.

# Esta funcion devuelve 1 si el usuario ingresi "SI" y 0 si ingreso "NO"
function ingresarSiNo
{
	loguearINFO "Se espera la respuesta del usuario" "ingresarSiNo"
	while [ 1 ]	
	do
		read respuesta

		loguearINFO "La respuesta del usuario fue: "$respuesta "ingresarSiNo"

		if [[ $respuesta == "SI" ]]
		then
			return 1
		elif [[ $respuesta == "NO" ]]
		then
			return 0
		fi
	done
}


#Esta funcion se encarga de crear los directorios y mover las tablas y scripts a sus directorios correspondientes
function crear_directorio
{

	loguearINFO "Se crean los directorios del sistema" "crear_directorio"
	#Primero se crean los directorios:

	#BIN

	mkdir "$DIRBIN"

	#TAB

	mkdir "$DIRTAB"

	#NOV

	mkdir "$DIRNOV"

	#OK

	mkdir "$DIROK"

	#NOK

	mkdir "$DIRNOK"

	#PROC

	mkdir "$DIRPROC"

	#SAL

	mkdir "$DIRSAL"


	#Creo el directorio donde voy a guardar los backups de nuestro sistema

	mkdir "$GRUPO/BACKUPs"

	loguearINFO "Se crea el archivo de configuracion" "crear_directorio"
	#Creo el archivo de configuracion.

	echo "GRUPO-\"$GRUPO\"" > instalador.conf
	echo "DIRINST-\"$DIRINST\"" >> instalador.conf
	echo "DIRBIN-\"$DIRBIN\"" >> instalador.conf
	echo "DIRTAB-\"$DIRTAB\"" >> instalador.conf
	echo "DIRNOV-\"$DIRNOV\"" >> instalador.conf
	echo "DIROK-\"$DIROK\"" >> instalador.conf
	echo "DIRNOK-\"$DIRNOK\"" >> instalador.conf
	echo "DIRPROC-\"$DIRPROC\"" >> instalador.conf
	echo "DIRSAL-\"$DIRSAL\"" >> instalador.conf
	echo "HCIERRE-\"$HCIERRE\"" >> instalador.conf

	loguearINFO "Las tablas, los archivos y los scrpts se transportan a sus directorios correspondientes" "crear_directorio"

	#Ahora muevo cada archivo a donde le corresponde

	mv "instalador.conf" "$DIRINST/instalador.conf"

	cp "$GRUPO/scripts/stop.sh" "$DIRBIN/stop.sh"
	cp "$GRUPO/scripts/start.sh" "$DIRBIN/start.sh"
	cp "$GRUPO/scripts/proceso.sh" "$DIRBIN/proceso.sh"
	cp "$GRUPO/scripts/inicializador.sh" "$DIRBIN/inicializador.sh"


	chmod 555 "$DIRINST/instalador.sh"
	chmod 555 "$DIRBIN/proceso.sh"
	chmod 555 "$DIRBIN/inicializador.sh"
	chmod 555 "$DIRBIN/stop.sh"
	chmod 555 "$DIRBIN/start.sh"

	cp "$GRUPO/tablas_cpr/Tabla_comercio.csv" "$DIRTAB/Tabla_comercio.csv"
	cp "$GRUPO/tablas_cpr/Tabla_provincias.csv" "$DIRTAB/Tabla_provincias.csv"
	cp "$GRUPO/tablas_cpr/Tabla_respuesta_gateway.csv" "$DIRTAB/Tabla_respuesta_gateway.csv"

	chmod 444 "$DIRTAB/Tabla_comercio.csv"
	chmod 444 "$DIRTAB/Tabla_provincias.csv"
	chmod 444 "$DIRTAB/Tabla_respuesta_gateway.csv"
	chmod 444 "$DIRINST/instalador.conf"

	cp -r "scripts" "$GRUPO/BACKUPs"
	cp -r "tablas_cpr"  "$GRUPO/BACKUPs"
	cp -r "pruebas"  "$GRUPO/BACKUPs"
	cp -r "docs"  "$GRUPO/BACKUPs"
	cp -r "inst"  "$GRUPO/BACKUPs"

	rm -rf "scripts"
	rm -rf "tablas_cpr"
	rm -rf "docs"
	rm -rf "pruebas"

	return 0
}

#Esta funcion devuelve 1 si el sistema fue instalado exitosamente, sino devuelve 0.
function instalado {

	if [ -f "$GRUPO/scripts/proceso.sh" ] && [ -f "$GRUPO/scripts/inicializador.sh" ] &&
	   [ -f "$GRUPO/scripts/start.sh" ] && [ -f "$GRUPO/scripts/stop.sh" ] &&
	   [ -f "$GRUPO/inst/instalador.sh" ] && [ -f "$GRUPO/tablas_cpr/Tabla_respuesta_gateway.csv" ] &&
	   [ -f "$GRUPO/tablas_cpr/Tabla_comercio.csv" ] && [ -f "$GRUPO/tablas_cpr/Tabla_provincias.csv" ] &&
	   [ -d "$GRUPO/docs" ] && [ -d "$GRUPO/pruebas" ]
	then
		return 0
	else
		return 1
	fi
}

function validar_hora {

	local hora_valida=0
	local h_cierre
	local hora_cierre_hh
	local hora_cierre_mm
	local hora_cierre_ss
	local hora_cierre_aux

	loguearINFO "Ingrese la nueva hora de cierre, formato HHMMSS: " "validar_hora"

	echo -n "Ingrese la nueva hora de cierre, formato HHMMSS: "

	read h_cierre

	loguearINFO "El usuario ingreso: "$hora_cierre "validar_hora"

	hora_cierre=`echo $h_cierre | sed 's/^0*//'`


	while [ $hora_valida == 0 ]
	do
		if [ $h_cierre -ge 0 ] && [ ${#hora_cierre} -eq 6 ]
		then
		let "hora_cierre_hh=$hora_cierre / 10000"
		let "hora_cierre_aux=$hora_cierre % 10000"

		if [ $hora_cierre_hh -lt 24 ]
		then
			let "hora_cierre_mm=$hora_cierre_aux/100"
			let "hora_cierre_ss=$hora_cierre_aux%100"
			if [ $hora_cierre_mm -lt 60 ] && [ $hora_cierre_ss -lt 60 ]
			then
				hora_valida=1
			fi
		fi
	fi
	if [ $hora_valida -eq 0 ]
	then
		echo -n "La hora ingresada no es valida, por favor ingrese otra: "
		read h_cierre
		loguearINFO "La hora ingresada no es valida, por favor ingrese otra: " "validar_hora"
		loguearINFO "El usuario ingreso: "$hora_cierre "validar_hora"

		hora_cierre=`echo $h_cierre | sed 's/^0*//'`
	fi
	done

	HCIERRE=$h_cierre

	return 0

}

function validar_nombre
{
	local respuesta=""
	local listo=false	

	loguearINFO "¿Desea cambiar el nombre de este directorio? SI-NO: " "validar_nombre"

	echo -n "¿Desea cambiar el nombre de este directorio? SI-NO: "

	ingresarSiNo

	if [[ $? == 1 ]]
	then

		echo -ne "\nIngrese el nombre nuevo del directorio: "
		read DIRAUX

		loguearINFO "Ingrese el nombre nuevo del directorio: " "validar_nombre"
		loguearINFO "El usuario ingreso: $DIRAUX" "validar_nombre"

	elif [[ $? == 0 ]]
	then
		listo=true
	fi

	while [ $listo == false ]
	do
		listo=true
		for dir in "${directorios_vec[@]}"
		do
			if [ "$dir" == "$DIRAUX" ]
			then
				echo -ne "El nombre ingresado ya existe, no pueden haber directorios con nombre duplicado. Por favor ingrese otro nombre: "
				read DIRAUX
				listo=false
				loguearINFO "El nombre ingresado ya existe, no pueden haber directorios con nombre duplicado. Por favor ingrese otro nombre: " "validar_nombre"
				loguearINFO "El usuario ingreso: $DIRAUX" "validar_nombre"
			fi
		done

		for dir in "${vec_aux[@]}"
		do
			if [ "$dir" == "$DIRAUX" ]
			then
				echo -ne "El nombre ingresado corresponde al nombre por defecto de otro directorio. Por favor ingrese otro nombre: "
				read DIRAUX
				listo=false
				loguearINFO "El nombre ingresado corresponde al nombre por defecto de otro directorio. Por favor ingrese otro nombre:" "validar_nombre"
				loguearINFO "El usuario ingreso: $DIRAUX" "validar_nombre"
			fi
		done
	done

	return 0

}

function preparar_reinstalacion
{
	cd $GRUPO

	loguearINFO "El sistema se prepara para la reistacion" "preparar_reinstalacion"

	if [ -f "$GRUPO/BACKUPs/scripts/proceso.sh" ] && [ -f "$GRUPO/BACKUPs/inst/instalador.sh" ] &&
       [ -f "$GRUPO/BACKUPs/scripts/inicializador.sh" ] && [ -f "$GRUPO/BACKUPs/tablas_cpr/Tabla_comercio.csv" ] &&
       [ -f "$GRUPO/BACKUPs/tablas_cpr/Tabla_provincias.csv" ] && [ -f "$GRUPO/BACKUPs/tablas_cpr/Tabla_respuesta_gateway.csv" ] &&
       [ -d "$GRUPO/BACKUPs/docs" ] && [ -d "$GRUPO/BACKUPs/pruebas" ]
	then

		loguearINFO "Se remueven todos los directorios y se recupera el BACKUP" "preparar_reinstalacion"
		
		local directorios=($(ls -1 "$GRUPO"))

		for dir in "${directorios[@]}"
		do
			if [[ "$dir" != "BACKUPs" ]]
			then
				rm -rf "$dir"
			fi
		done

		mv "$PWD/BACKUPs/scripts" "$PWD"
		mv "$PWD/BACKUPs/tablas_cpr" "$PWD"
		mv "$PWD/BACKUPs/docs" "$PWD"
		mv "$PWD/BACKUPs/inst" "$PWD"
		mv "$PWD/BACKUPs/pruebas" "$PWD"
		rm -rf "$GRUPO/BACKUPs"

	else
		echo "Algunos de los archivos necesarios para reinstalar el sistema no se pueden encontrar, en este tipo de situacion ya no se puede hacer nada."
		echo "Por favor seguir los pasos en el archivo README para descargar el sistema e instalarlo devuelta."

		loguearINFO "Algunos de los archivos necesarios para reinstalar el sistema no se pueden encontrar, en este tipo de situacion ya no se puede hacer nada" "preparar_reinstalacion"
		loguearINFO "Por favor seguir los pasos en el archivo README para descargar el sistema e instalarlo devuelta" "preparar_reinstalacion"
		return 1
	fi
	return 0
}

function restaurar
{
	#Para restaurar primero se va a leer del archivo de configuracion y se van a traer todas las variables de ambiente que estan escritas en el.

	cd "$DIRINST"

	loguearINFO "Se comprueba si el instalador.conf existe" "restaurar"

	if [ -f "$DIRINST/instalador.conf" ] || [ -f "$GRUPO/BACKUPs/inst/instalador.conf" ]
	then
		if [ -f "$DIRINST/instalador.conf" ]
		then
			sed 's/-/=/g' "$DIRINST/instalador.conf" >> instalador_aux.conf
		else
			sed 's/-/=/g' "$GRUPO/BACKUPs/inst/instalador.conf" >> instalador_aux.conf
		fi

		source instalador_aux.conf

		rm instalador_aux.conf

		loguearINFO "Se comprueba las tablas, los directorios y los scripts existen" "restaurar"

		# Si estamos en alguno de los directorios que no es GRUPO03, entonces pasamos a ese directorio. En caso de haber movido instalador.sh y instalador.conf a otro directorio
		if [ "$PWD" != "$GRUPO" ]
		then
			cd "$GRUPO"
		fi
	
		#CASO: no hay directorio inst:
		if [ ! -d "$DIRINST" ]
		then
			loguearINFO "El directorio que guarda los archivos y los scripts de instalacion no existe ( inst por defecto), se creara uno nuevo" "restaurar"
			echo "El directorio que guarda los archivos y los scripts de instalacion no existe ( inst por defecto), se creara uno nuevo."
			mkdir "$DIRINST"
		fi	

		#CASO: no hay directorio bin:
		if [ ! -d "$DIRBIN" ]
		then
			loguearINFO "El directorio que guarda los ejecutables y los scripts no existe ( bin por defecto), se creara uno nuevo" "restaurar"
			echo "El directorio que guarda los ejecutables y los scripts no existe ( bin por defecto), se creara uno nuevo."
			mkdir "$DIRBIN"
		fi
	
		#CASO: no hay directorio tab:
		if [ ! -d "$DIRTAB" ]
		then
			loguearINFO "El directorio que guarda las tablas no existe ( tab por defecto), se creara uno nuevo" "restaurar"
			echo "El directorio que guarda las tablas no existe ( tab por defecto), se creara uno nuevo."
			mkdir "$DIRTAB"
		fi
	
		#CASO: no hay directorio nov:
		if [ ! -d "$DIRNOV" ]
		then
			loguearINFO "El directorio que guarda los archivos de novedades no existe ( nov por defecto), se creara uno nuevo" "restaurar"
			echo "El directorio que guarda los archivos de novedades no existe ( nov por defecto), se creara uno nuevo."
			mkdir "$DIRNOV"
		fi
	
		#CASO: no hay directorio ok:
		if [ ! -d "$DIROK" ]
		then
			loguearINFO "El directorio que guarda los archivos de novedades aceptados no existe ( ok por defecto), se creara uno nuevo" "restaurar"
			echo "El directorio que guarda los archivos de novedades aceptados no existe ( ok por defecto), se creara uno nuevo."
			mkdir "$DIROK"

		fi
	
		#CASO: no hay directorio nok
		if [ ! -d "$DIRNOK" ]
		then
			loguearINFO "El directorio que guarda los archivos de novedades rechazados no existe( nok por defecto), se creara uno nuevo" "restaurar"
			echo "El directorio que guarda los archivos de novedades rechazados no existe( nok por defecto), se creara uno nuevo."
			mkdir "$DIRNOK"
		fi
	
		#CASO: no hay directorio proc
		if [ ! -d "$DIRPROC" ]
		then
			loguearINFO "El directorio que guarda los archivos que han sido procesados no existe( proc por defecto), se creara uno nuevo" "restaurar"
			echo "El directorio que guarda los archivos que han sido procesados no existe( proc por defecto), se creara uno nuevo."
			mkdir "$DIRPROC"
		fi

		#CASO: no hay directorio sal
		if [ ! -d "$DIRSAL" ]
		then
			loguearINFO "El directorio que guarda los archivos que son generados por el sistema mientras se ejecuta el proceso( sal por defecto), se creara uno nuevo" "restaurar"
			echo "El directorio que guarda los archivos que son generados por el sistema mientras se ejecuta el proceso( sal por defecto), se creara uno nuevo."
			mkdir "$DIRSAL"
		fi

		# Ahora me aseguro que todos los archivos y scritps esten en sus directorios correspondientes


		#PROCESO

		cd "$DIRBIN"

		if [ ! -f "proceso.sh" ]
		then

			loguearINFO "El proceso no se encuentra en la carpeta bin, se lo va a tratar de recuperar" "restaurar"
			echo "El proceso no se encuentra en la carpeta bin, se lo va a tratar de recuperar."

			if [ -f "$GRUPO/BACKUPs/scripts/proceso.sh" ]
			then
				cp "$GRUPO/BACKUPs/scripts/proceso.sh" "$DIRBIN"

				chmod 555 "$DIRBIN/proceso.sh"

				loguearINFO "El proceso fue recuperado exitosamente" "restaurar"
				echo " El proceso fue recuperado exitosamente."
			else
				loguearINFO "El proceso no pudo ser recuperado, el sistema no se puede reparar" "restaurar"
				echo "El proceso no pudo ser recuperado, el sistema no se puede reparar."

				return 1
			fi
		fi

		#INICIALIZADOR

		if [ ! -f "inicializador.sh" ]
		then
			loguearINFO "El inicializador no se encuentra en la carpeta bin, se lo va a tratar de recuperar" "restaurar"
			echo "El inicializador no se encuentra en la carpeta bin, se lo va a tratar de recuperar."

			if [ -f "$GRUPO/BACKUPs/scripts/inicializador.sh" ]
			then
				cp "$GRUPO/BACKUPs/scripts/inicializador.sh" "$DIRBIN"

				chmod 555 "$DIRBIN/inicializador.sh"

				loguearINFO "El inicializador fue recuperado exitosamente" "restaurar"
				echo " El inicializador fue recuperado exitosamente."
			else
				loguearINFO "El inicializador no pudo ser recuperado, el sistema no se puede reparar" "restaurar"
				echo "El inicializador no pudo ser recuperado, el sistema no se puede reparar."

				return 1
			fi
		fi

		#STOP

		if [ ! -f "stop.sh" ]
		then
			loguearINFO "El script stop no se encuentra en la carpeta del ejecutables, se lo va a tratar de recuperar" "restaurar"
			echo "El script stop no se encuentra en la carpeta del ejecutables, se lo va a tratar de recuperar."

			if [ -f "$GRUPO/BACKUPs/scripts/stop.sh" ]
			then
				cp "$GRUPO/BACKUPs/scripts/stop.sh" "$DIRBIN"

				chmod 555 "$DIRBIN/stop.sh"
				
				loguearINFO "El script stop fue recuperado exitosamente" "restaurar"
				echo " El script stop fue recuperado exitosamente."
			else
				loguearINFO "El script stop no pudo ser recuperado, el sistema no se puede reparar" "restaurar"
				echo "El script stop no pudo ser recuperado, el sistema no se puede reparar."

				return 1
			fi
		fi

		#START

		if [ ! -f "start.sh" ]
		then
			loguearINFO "El script start no se encuentra en la carpeta del ejecutables, se lo va a tratar de recuperar" "restaurar"
			echo "El script stop no se encuentra en la carpeta del ejecutables, se lo va a tratar de recuperar."

			if [ -f "$GRUPO/BACKUPs/scripts/start.sh" ]
			then
				cp "$GRUPO/BACKUPs/scripts/start.sh" "$DIRBIN"

				chmod 555 "$DIRBIN/start.sh"
				
				loguearINFO "El script start fue recuperado exitosamente" "restaurar"
				echo " El script start fue recuperado exitosamente."
			else
				loguearINFO "El scritp start no pudo ser recuperado, el sistema no se puede reparar" "restaurar"
				echo "El script start no pudo ser recuperado, el sistema no se puede reparar."

				return 1
			fi
		fi


		cd "$DIRINST"

		#ARCHIVO DE CONFIGURACION

		if [ ! -f "instalador.conf" ]
		then
			loguearINFO "El archivo de configuracion no se encuantra en el directorio inst,se lo va a tratar de recuperar" "restaurar"
			echo "El archivo de configuracion no se encuentra en la carpeta inst, se lo va a tratar de recuperar."

			if [ -f "$GRUPO/BACKUPs/inst/instalador.conf" ]
			then
				cp "$GRUPO/BACKUPs/inst/instalador.conf" "$DIRINST"

				chmod 444 "$DIRINST/instalador.conf"
				
				loguearINFO "El archivo de configuracion fue recuperado exitosamente" "restaurar"
				echo " El archivo de configuracion fue recuperado exitosamente."
			else
				loguearINFO "El archivo de configuracion no pudo ser recuperado, el sistema no se puede reparar y se tiene que volver a instalar" "restaurar"
				echo "El archivo de configuracion no pudo ser recuperado, el sistema no se puede reparar y se tiene que volver a instalar."

				return 2
			fi
		fi

		

		cd "$DIRTAB"

		#TABLA DE COMERCIO

		if [ ! -f "Tabla_comercio.csv" ]
		then
			loguearINFO "La tabla de comercios no se encuentra en la carpeta tab, se la va a tratar de recuperar" "restaurar"
			echo "La tabla de comercios no se encuentra en la carpeta tab, se la va a tratar de recuperar."

			if [ -f "$GRUPO/BACKUPs/tablas_cpr/Tabla_comercio.csv" ]
			then
				cp "$GRUPO/BACKUPs/tablas_cpr/Tabla_comercio.csv" "$DIRTAB"

				chmod 444 "$DIRTAB/Tabla_comercio.csv"

				loguearINFO "La tabla de comercios fue recuperada exitosamente" "restaurar"
				echo " La tabla de comercios fue recuperada exitosamente."
			else
				loguearINFO "La tabla de comercios no pudo ser recuperada, el sistema no se puede recuperar" "restaurar"
				echo "La tabla de comercios no pudo ser recuperada, el sistema no se puede recuperar."

				return 1
			fi
		fi

		#TABLA DE PROVINCIAS

		if [ ! -f "Tabla_provincias.csv" ]
		then
			loguearINFO "La tabla de provincias no se encuentra en la carpeta tab, se la va a tratar de recuperar" "restaurar"
			echo "La tabla de provincias no se encuentra en la carpeta tab, se la va a tratar de recuperar."

			if [ -f "$GRUPO/BACKUPs/tablas_cpr/Tabla_provincias.csv" ]
			then
				cp "$GRUPO/BACKUPs/tablas_cpr/Tabla_provincias.csv" "$DIRTAB"

				chmod 444 "$DIRTAB/Tabla_provincias.csv"

				loguearINFO "La tabla de provincias fue recuperada exitosamente" "restaurar"
				echo " La tabla de provincias fue recuperada exitosamente."
			else

				loguearINFO "La tabla de provincias no pudo ser recuperada, el sistema no se puede reparar" "restaurar"
				echo "La tabla de provincias no pudo ser recuperada, el sistema no se puede reparar."

				return 1
			fi
		fi

		#TABLA DE RESPUESTAS DE GATEWAY

		if [ ! -f "Tabla_respuesta_gateway.csv" ]
		then

			loguearINFO "La tabla de respuesta de gateway no se encuentra en la carpeta tab, se la va a tratar de recuperar" "restaurar"
			echo "La tabla de respuesta de gateway no se encuentra en la carpeta tab, se la va a tratar de recuperar."

			if [ -f "$GRUPO/BACKUPs/tablas_cpr/Tabla_respuesta_gateway.csv" ]
			then
				cp "$GRUPO/BACKUPs/tablas_cpr/Tabla_respuesta_gateway.csv" "$DIRTAB"

				chmod 444 "$DIRTAB/Tabla_respuesta_gateway.csv"

				loguearINFO "La tabla de respuesta de gateway fue recuperada exitosamente" "restaurar"
				echo " La tabla de respuesta de gateway fue recuperada exitosamente."
			else

				loguearINFO "La tabla de respuesta de gateway no pudo ser recuperada, el sistema no se puede reparar" "restaurar"
				echo "La tabla de respuesta de gateway no pudo ser recuperada, el sistema no se puede reparar."

				return 1
			fi
		fi

	else
		loguearINFO "El archivo de configuracion no se encuentra. Se procedera a reistalar el sistema" "restaurar"
		echo "El archivo de configuracion no se encuentra. Se procedera a reistalar el sistema."
		return 2
	fi

return 0
}


function mostrar_directorio
{
	loguearINFO "Se muestran en pantalla es estado final del sistema:"
	echo -e "\n\tTP SO7508 1º Cuatrimestre 2020. Copyright © Grupo 03"
	echo -e "\tDirectorio padre:                   $GRUPO"
	echo -e "\tDirectorio de instalador            $DIRINST"
	echo -e "\tScript instalador:                  $DIRINST/instalador.sh"
	echo -e "\tLog de la instalación:              $DIRINST/instalador.log"
	echo -e "\tConfiguración de la instalación:    $DIRINST/instalador.conf"
	echo -e "\tDirectorio de ejecutables:          $DIRBIN"
	echo -e "\tScript proceso:                     $DIRBIN/proceso.sh"
	echo -e "\tScript inicializador:               $DIRBIN/inicializador.sh"
	echo -e "\tScript stop:                        $DIRBIN/stop.sh"
	echo -e "\tScript start:                       $DIRBIN/start.sh"
	echo -e "\tDirectorio de tablas:               $DIRTAB"
	echo -e "\tTabla de Comercios:                 $DIRTAB/Tabla_comercio.csv"
	echo -e "\tTabla de provincias:                $DIRTAB/Tabla_provincias.csv"
	echo -e "\tTabla de respuestas gateway:        $DIRTAB/Tabla_respuesta_gateway.csv"
	echo -e "\tDirectorio de novedades:            $DIRNOV"
	echo -e "\tDirectorio de aceptados:            $DIROK"
	echo -e "\tDirectorio de rechazados:           $DIRNOK"
	echo -e "\tDirectorio de procesados:           $DIRPROC"
	echo -e "\tDirectorio de salidas:              $DIRSAL"
	echo -e "\tDirectorio de copias de seguridad:  $GRUPO/BACKUPs"
	echo -e "\tHora de Cierre:                     $HCIERRE"

	echo -e "\n\tTP SO7508 1º Cuatrimestre 2020. Copyright © Grupo 03" >> $dir_log
	echo -e "\tDirectorio padre:                   $GRUPO" >> $dir_log
	echo -e "\tDirectorio de instalador            $DIRINST" >> $dir_log
	echo -e "\tScript instalador:                  $DIRINST/instalador.sh" >> $dir_log
	echo -e "\tLog de la instalación:              $DIRINST/instalador.log" >> $dir_log
	echo -e "\tConfiguración de la instalación:    $DIRINST/instalador.conf" >> $dir_log
	echo -e "\tDirectorio de ejecutables:          $DIRBIN" >> $dir_log
	echo -e "\tScript proceso:                     $DIRBIN/proceso.sh" >> $dir_log
	echo -e "\tScript inicializador:               $DIRBIN/inicializador.sh" >> $dir_log
	echo -e "\tScript stop:               		   ""$DIRBIN/stop.sh" >> $dir_log
	echo -e "\tScript start:               		   ""$DIRBIN/start.sh" >> $dir_log
	echo -e "\tDirectorio de tablas:               $DIRTAB" >> $dir_log
	echo -e "\tTabla de Comercios:                 $DIRTAB/Tabla_comercio.csv" >> $dir_log
	echo -e "\tTabla de provincias:                $DIRTAB/Tabla_provincias.csv" >> $dir_log
	echo -e "\tTabla de respuestas gateway:        $DIRTAB/Tabla_respuesta_gateway.csv" >> $dir_log
	echo -e "\tDirectorio de novedades:            $DIRNOV" >> $dir_log
	echo -e "\tDirectorio de aceptados:            $DIROK" >> $dir_log
	echo -e "\tDirectorio de rechazados:           $DIRNOK" >> $dir_log
	echo -e "\tDirectorio de procesados:           $DIRPROC" >> $dir_log
	echo -e "\tDirectorio de salidas:              $DIRSAL" >> $dir_log
	echo -e "\tDirectorio de copias de seguridad:  $GRUPO/BACKUPs" >> $dir_log
	echo -e "\tHora de Cierre:                     $HCIERRE" >> $dir_log

	return 0
}

function instalar
{

	GRUPO=$PWD

	directorios_vec=( "inst" "bin" "tab" "nov" "ok" "nok" "proc" "sal")
	HCIERRE=180000
	instalacion_terminada="nok"

	while [[ $instalacion_terminada != "ok" ]]
	do

		clear
		echo -e "\n\t\t\t\tINSTALACION\n"
		echo -e "Se procedera con la instalacion del ambiente para poder correr nuestro proceso."
		echo -e "Primero se necesita configurar el nombre de los directorios con los que se va a trabajar."

		loguearINFO "COMIENZA INSTALACION" "Instalar"
		loguearINFO "Se procedera con la instalacion del ambiente para poder correr nuestro proceso" "Instalar"
		loguearINFO "Primero se necesita configurar el nombre de los directorios con los que se va a trabajar" "instalar"

		#Creamos las variables de ambiente que se van a usar en nuestro proceso y les asigno su valor por defecto:

		DIRINST="${directorios_vec[0]}"
		DIRBIN="${directorios_vec[1]}"
		DIRTAB="${directorios_vec[2]}"
		DIRNOV="${directorios_vec[3]}"
		DIROK="${directorios_vec[4]}"
		DIRNOK="${directorios_vec[5]}"
		DIRPROC="${directorios_vec[6]}"
		DIRSAL="${directorios_vec[7]}"

		DIRAUX="" #Esta variable solo sirve para guardar el valor de alguno de los directorios hasta que se la tenga que usar

		#Este vector guarda el nombre de los directorios que ya fueron configurados, cantidad guarda la cantidad de valores del vector
		directorios_vec=("$DIRINST")
		cantidad=1



		echo -e "\nPrimer Directorio:"
		echo -e "\tNombre por defecto: $DIRBIN"
		echo -e "\tFuncion: guardar archivos ejecutables"

		loguearINFO "Primer Directorio:" "Instalar"
		loguearINFO "Nombre por defecto: $DIRBIN" "Instalar"
		loguearINFO "Funcion: guardar archivos ejecutables" "Instalar"

		vec_aux=("$DIRTAB" "$DIRNOV" "$DIROK" "$DIRNOK" "$DIRPROC" "$DIRSAL" "BACKUPs" "scripts" "tablas_cpr" "docs" "pruebas")

		DIRAUX="$DIRBIN"

		validar_nombre

		directorios_vec[$cantidad]="$DIRAUX"
		let cantidad++

		echo -e "\nSegundo Directorio:"
		echo -e "\tNombre por defecto: $DIRTAB"
		echo -e "\tFuncion: guardar las tablas de nuetro sistema"

		loguearINFO "Segundo Directorio:" "Instalar"
		loguearINFO "Nombre por defecto: $DIRTAB" "Instalar"
		loguearINFO "Funcion: guardar las tablas de nuetro sistema" "Instalar"

		vec_aux=("$DIRBIN" "$DIRNOV" "$DIROK" "$DINOK" "$DIRPROC" "$DIRSAL" "BACKUPs" "scripts" "tablas_cpr" "docs" "pruebas")

		DIRAUX="$DIRTAB"
	
		validar_nombre 

		directorios_vec[$cantidad]="$DIRAUX"
		let cantidad++

		echo -e "\nTercer Directorio:"
		echo -e "\tNombre por defecto: $DIRNOV"
		echo -e "\tFuncion: guardar archivos de novedades"

		loguearINFO "Tercer Directorio:" "Instalar"
		loguearINFO "Nombre por defecto: $DIRNOV" "Instalar"
		loguearINFO "Funcion: guardar archivos de novedades" "Instalar"

		vec_aux=("$DIRBIN" "$DIRTAB" "$DIROK" "$DIRNOK" "$DIRPROC" "$DIRSAL" "BACKUPs" "scripts" "tablas_cpr" "docs" "pruebas")

		DIRAUX="$DIRNOV"
	
		validar_nombre

		directorios_vec[$cantidad]="$DIRAUX"
		let cantidad++

		echo -e  "\nCuarto Directorio:"
		echo -e "\tNombre por defecto: $DIROK"
		echo -e "\tFuncion: guardar archivos de novedades que fueron aceptados"

		loguearINFO "Cuarto Directorio:" "Instalar"
		loguearINFO "Nombre por defecto: $DIROK" "Instalar"
		loguearINFO "Funcion: guardar archivos de novedades que fueron aceptados" "Instalar"

		vec_aux=("$DIRBIN" "$DIRTAB" "$DIRNOV" "$DIRNOK" "$DIRPROC" "$DIRSAL" "BACKUPs" "scripts" "tablas_cpr" "docs" "pruebas")

		DIRAUX="$DIROK"
	

		validar_nombre

		directorios_vec[$cantidad]="$DIRAUX"
		let cantidad++

		echo -e "\nQuinto Directorio:"
		echo -e "\tNombre por defecto: $DIRNOK"
		echo -e "\tFuncion: guardar archivos de novedades que fueron rechazados"

		loguearINFO "Quinto Directorio:" "Instalar"
		loguearINFO "Nombre por defecto: $DIRNOK" "Instalar"
		loguearINFO "Funcion: guardar archivos de novedades que fueron rechazados" "Instalar"

		vec_aux=("$DIRBIN" "$DIRTAB" "$DIRNOV" "$DIROK" "$DIRPROC" "$DIRSAL" "BACKUPs" "scripts" "tablas_cpr" "docs" "pruebas")


		DIRAUX="$DIRNOK"
	
		validar_nombre

		directorios_vec[$cantidad]="$DIRAUX"
		let cantidad++

		echo -e "\nSexto Directorio:"
		echo -e "\tNombre por defecto: $DIRPROC"
		echo -e "\tFuncion: guardar archivos que han sido procesados"

		loguearINFO "Sexto Directorio:" "Instalar"
		loguearINFO "Nombre por defecto: $DIRPROC" "Instalar"
		loguearINFO "Funcion: guardar archivos que han sido procesados" "Instalar"

		vec_aux=("$DIRBIN" "$DIRTAB" "$DIRNOV" "$DIROK" "$DIRNOK" "$DIRSAL" "BACKUPs" "scripts" "tablas_cpr" "docs" "pruebas")

		DIRAUX="$DIRPROC"

		validar_nombre

		directorios_vec[$cantidad]="$DIRAUX"
		let cantidad++

		echo -e "\nSeptimo Directorio:"
		echo -e "\tNombre por defecto: $DIRSAL"
		echo -e "\tFuncion: guardar archivos que genera el sistema durante el procesamiento"

		loguearINFO "Septimo Directorio:" "Instalar"
		loguearINFO "Nombre por defecto: $DIRSAL" "Instalar"
		loguearINFO "Funcion: guardar archivos que genera el sistema durante el procesamiento" "Instalar"

		vec_aux=("$DIRBIN" "$DIRTAB" "$DIRNOV" "$DIROK" "$DIRNOK" "$DIRPROC" "BACKUPs" "scripts" "tablas_cpr" "docs" "pruebas")


		DIRAUX="$DIRSAL"

		validar_nombre

		directorios_vec[$cantidad]="$DIRAUX"
		let cantidad++

		echo -ne "\nLa hora de cierre es $HCIERRE, ¿desea cambiarla? SI-NO: "

		loguearINFO "La hora de cierre es $HCIERRE, ¿desea cambiarla? SI-NO: " "Instalar"

		ingresarSiNo

		if [ $? == 1 ]
		then
			validar_hora
		fi

		DIRINST=$GRUPO/${directorios_vec[0]}
		DIRBIN=$GRUPO/${directorios_vec[1]}
		DIRTAB=$GRUPO/${directorios_vec[2]}
		DIRNOV=$GRUPO/${directorios_vec[3]}
		DIROK=$GRUPO/${directorios_vec[4]}
		DIRNOK=$GRUPO/${directorios_vec[5]}
		DIRPROC=$GRUPO/${directorios_vec[6]}
		DIRSAL=$GRUPO/${directorios_vec[7]}

		clear

		echo " Con los datos ingresador el directorio resultante tiene la siguiente forma:"

		mostrar_directorio

		loguearINFO "Estado de la instalación: LISTA" "instalar"
		loguearINFO "¿Confirma la instalación? (SI-NO): " "instalar"

		echo "Estado de la instalación: LISTA"
		echo -n "¿Confirma la instalación? (SI-NO): "

		ingresarSiNo

		if [ $? == 1 ]
		then
			loguearINFO "El usuario ingreso SI, se instalara el sistema" "instalar"
			crear_directorio
			instalacion_terminada="ok"
		else
			loguearINFO "El usuario ingreso NO, el usuario volvera a la configuracion del sistema hasta que este satisfecho con el resultado" "instalar"
		fi

	done

	cd "$GRUPO"

	loguearINFO "INSTALACION TERMINADA" "instalar"
	echo -e "\n\t\t\t\tINSTALACION TERMINADA"
	
	return 0
}

#Esta funcion devuelve 0 si el sistema se necesita reparar, y 1 si no lo necesita
function necesita_reparar
{
	local cont=0

	loguearINFO "Se comprueba si el sistema necesita reparacion" "necesita_reparar"

	if [ ! -f "instalador.conf" ]
	then
		return 0
	else
		sed 's/-/=/g' instalador.conf >> instalador_aux.conf
		source instalador_aux.conf
		rm instalador_aux.conf

		let "cont=$cont+1"

		cd ..

		if [ -f "$DIRBIN/proceso.sh" ]
		then
			let "cont=$cont+1"
		fi

		if [ -f "$DIRBIN/inicializador.sh" ]
		then
			let "cont=$cont+1"
		fi

		if [ -f "$DIRBIN/stop.sh" ]
		then
			let "cont=$cont+1"
		fi

		if [ -f "$DIRBIN/start.sh" ]
		then
			let "cont=$cont+1"
		fi

		if [ -f "$DIRINST/instalador.sh" ]
		then
			let "cont=$cont+1"
		fi

		if [ -f "$DIRTAB/Tabla_comercio.csv" ]
		then
			let "cont=$cont+1"
		fi

		if [ -f "$DIRTAB/Tabla_provincias.csv" ]
		then
			let "cont=$cont+1"
		fi

		if [ -f "$DIRTAB/Tabla_respuesta_gateway.csv" ]
		then
			let "cont=$cont+1"
		fi

		if [ -d "$DIRNOV" ]
		then
			let "cont=$cont+1"
		fi

		if [ -d "$DIRPROC" ]
		then
			let "cont=$cont+1"
		fi

		if [ -d "$DIROK" ]
		then
			let "cont=$cont+1"
		fi

		if [ -d "$DIRNOK" ]
		then
			let "cont=$cont+1"
		fi

		if [ -d "$DIRSAL" ]
		then
			let "cont=$cont+1"
		fi
	fi

	#Se compara con 14 porque los elementos que se crean luego de la instalacion son 14, exceptuando tab, inst y bin, para estos
	# solo se toma en cuenta los elementos que esos directorios guardan adentro
	if [ $cont -eq 14 ]
	then
		return 1

	elif [ $cont -lt 14 ]
	then
		return 0
	fi

}

function loguearERROR()
{
	local fecha=`date +%Y-%m-%d"  "%T`
	local linea="[ "$fecha" ]-ERR-"$1"-"$2

	echo $linea >> $dir_log
	return 0
}

function loguearINFO()
{
	local fecha=`date +%Y-%m-%d"  "%T`
	local linea="[ "$fecha" ]-INF-"$1"-"$2
	echo $linea >> $dir_log
	return 0
}

function loguearALE()
{
	local fecha=`date +%Y-%m-%d"  "%T`
	local linea="[ "$fecha" ]-INF-"$1"-"$2

	echo $linea >> $dir_log
	return 0
}



#											.:INSTALADOR:.

if [ -f "instalador.log" ]
then
	chmod 666 "instalador.log"
fi



dir_log=$PWD"/instalador.log"

loguearINFO "Empieza Instalador" "instalador"

DIRINST=$PWD

cd ..

GRUPO=$PWD


#Si el instalador recibio un "-r" entonces efectua la reparacion
if [[ $1 == "-r" ]] && [ $# -eq 1 ] 
then

	loguearINFO "Se recibio como parametro '-r'" "instalador"

	loguearINFO "Verificamos si el sistema ya se instalo" "instalador"

	instalado

	if [ $? -eq 0 ]
	then
		loguearINFO "El sistema aun no ha sido instalado. El proceso instalador se cerrara." "instalador"

		loguearINFO "FIN DEL SCRIPT" "instalador"

		echo -e "\n\n" >> $dir_log

		chmod 444 "$DIRINST/instalador.log"

		echo "El sistema aun no ha sido instalado."
		exit 0
	fi

	loguearINFO "Restauramos el sistema" "instalador"	

	restaurar

	op=$?

	#Si restaurador devuelve 0 entonces el sistema se reparo con exito.
	if [ $op -eq 0 ]
	then
		loguearINFO "El sistema fue restaurado con exito." "instalador"
		echo "El sistema fue restaurado con exito."

	#Si restaurador devuelve 1 entonces el sistema no se puede reparar.
	elif [ $op -eq 1 ]
	then
		loguearINFO "El sistema no puede repararse. Se requerira que el usuario se descargue un paquete nuevo e instale el sistema con el" "instalador"
		loguearINFO "Seguir pasos del README." "instalador"

		echo "El sistema no puede repararse. Se requerira que el usuario se descargue un paquete nuevo e instale el sistema con el."
		echo "Seguir pasos del README."

	#Si restaurador devuelve 1 entonces el sistema se tiene que reinstalar.
	elif [ $op -eq 2 ]
	then

		loguearINFO "El sistema se tiene que reistalar. Ingrese cualquier tecla para proceder con la instalacion" "instalador"

		echo "El sistema se tiene que reistalar. Ingrese cualquier tecla para proceder con la instalacion."

		preparar_reinstalacion

		cd "$GRUPO"

		read -n 1

		loguearINFO "El sistema se reinstalara" "Instalador" 

		instalar
	fi
		

#Si el instalador no recibio parametros entonces el script se ejecuta con normalidad
elif [ $# -eq 0 ]
then

	loguearINFO "El instalador no recibio ningun parametro" "instalador"

	loguearINFO "Se verifica si el sistema ya se instalo" "instalador"

	#Primero vemos si el sistema ya fue instalado, si lo fue y fue una instalacion exitosa entonces el instalador se cierra y se muestra como quedo la instalacion.
	instalado

	if [ $? -eq 1 ]
	then
		cd "$DIRINST"

		necesita_reparar
		op=$?

		if [ $op -eq 0 ]
		then
			loguearINFO "El sistema ya fue instalado pero se lo necesita reparar, se le indica al usuario como hacerlo" "instalador"
			loguearINFO "FIN DEL SCRIPT" "instalador"
			echo -e "\n\n" >> $dir_log

			chmod 444 "$DIRINST/instalador.log"

			echo "El sistema ya fue instalado pero necesita ser reparado. Ejecutar el instalador devuelta con el siguiente comando:"
			echo -e "\n\t ./instalador.sh -r\n\n"
			exit 0
		fi
		loguearINFO "El sistema ya fue instalado exitosamente. El directorio resultado tiene esta forma: " "instalador"
		echo "El sistema ya fue instalado exitosamente. El directorio resultado tiene esta forma: "
		sed 's/-/=/g' "$DIRINST/instalador.conf" >> "instalador_aux.conf"
		source instalador_aux.conf
		rm instalador_aux.conf
		mostrar_directorio

		loguearINFO "FIN DEL SCRIPT" "instalador"

		echo -e "\n\n" >> $dir_log

		chmod 444 "$DIRINST/instalador.log"

		exit 0
	fi


	loguearINFO "El sistema puede empezar a instalarse" "instalador"
	instalar
	cd ..

else
	loguearERROR "Parametros ingresados invalidos, el instalador se cerrara" "instalador"
	echo "Parametros ingresados invalidos. El instalador se cerrara."
	loguearINFO "FIN DEL SCRIPT" "instalador" "instalador"
	echo -e "\n\n" >> $dir_log
	chmod 444 "$DIRINST/instalador.log"
	exit 1
fi

loguearINFO "FIN DEL SCRIPT" "instalador" "instalador"
echo -e "\n\n" >> $dir_log
chmod 444 "$DIRINST/instalador.log"