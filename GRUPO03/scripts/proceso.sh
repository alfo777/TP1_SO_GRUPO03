#!/bin/bash

#										.:FUNCIONES:.

#Esta funcion nos dice si el directorio de arribos (nov por defecto) esta vacio o no. Devuelve 0 si esta vacio y 1 si no lo esta.
function directorio_novedades_vacio
{

	cd "$DIRNOV"

	loguearINFO "Se va al directorio de novedades, se lista su contenido y se verifica que dicha lista no este vacia" "directorio_novedades_vacio"

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

	loguearINFO "Se comienza a procesar las novedades" "procesar_novedades"

	cd "$DIRNOV"

	local novedades=( $( ls -1 ) )
	local aceptados=""
	local rechazados=""
	local nombre_valido
	local contenido_valido
	local sin_duplicados

	for archivo_novedad_i in ${novedades[@]}
	do
		loguearINFO "Se procesa el archivo de nombre: ""$archivo_novedad_i" "procesar_novedades"

		loguearINFO "Se comprueba si el nombre del archivo es valido o no" "procesar_novedades"

		validar_nombre "$archivo_novedad_i"

		nombre_valido=$?

		loguearINFO "Se comprueba si el archivo esta vacio o no y si es un archivo .txt" "procesar_novedades"

		validar_contenido_y_tipo_archivo "$archivo_novedad_i"

		contenido_valido=$?

		loguearINFO "Se comprueba si un archivo del mismo nombre ya fue procesado antes" "procesar_novedades"

		no_hay_duplicados "$archivo_novedad_i"

		sin_duplicados=$?

		if [ $nombre_valido -eq 1  ] && [ $contenido_valido -eq 1 ] && [ $sin_duplicados -eq 1 ]
		then
			loguearINFO "El archivo "$archivo_novedad_i" cumple todas las condiciones, sera aceptado" "procesar_novedades"

			mv "$archivo_novedad_i" "$DIROK"

			aceptados="$aceptados"" ""$archivo_novedad_i"
		else

			loguearINFO "El archivo "$archivo_novedad_i" no cumple algunas de las condiciones, sera rechazado" "procesar_novedades"

			mv "$archivo_novedad_i" "$DIRNOK"
			rechazados="$rechazados"" ""$archivo_novedad_i"
		fi
	done

	loguearINFO "ARCHIVOS QUE SE ACEPTARON: " $aceptados "procesar_novedades"
	loguearINFO "ARCHIVOS QUE SE RECHAZARON: " $rechazados "procesar_novedades"


	return 0
}



#Esta funcion verifica si el archivo ya esta en el directorio de procesados, de ser asi devuelve 0. Si no esta duplicado devuelve 1.
function no_hay_duplicados(){

	local procesados=($(ls -1 "$DIRPROC"))
	for archivo_procesado_i in ${procesados[@]}
	do
		if [[ $1 == $archivo_procesado_i ]]
		then
			loguearINFO "Se encontro un archivo duplicado de este archivo en el directorio de procesados" "no_hay_duplicados"
			return 0
		fi
	done

	loguearINFO "No se han encontrado archivos duplicados a este archivo en el directorio de procesados. Esta condicion no esta cumplida" "no_hay_duplicados"

	return 1

}


#Esta funcion ve si el archivo esta vacio y no, si esta vacio devuelve 0. Si no esta vacio 

function validar_contenido_y_tipo_archivo()
{
	loguearINFO "Primero se verifica que el archivo no este vacio" "validar_contenido_y_tipo_archivo" 

	local valido=`cat $1 | grep '.' | wc -w`

	if [ $valido -ne 0 ]
	then
		loguearINFO "El archivo no esta vacio, se verifica que tenga extension .txt" "validar_contenido_y_tipo_archivo" 
		valido=`echo $1 | grep '.*\.txt' | wc -w`

		if [ $valido -ne 0 ]
		then
			loguearINFO "El archivo es .txt y no esta vacio. Esta condicion esta cumplida" "validar_contenido_y_tipo_archivo" 
			return 1
		else
			loguearINFO "El archivo no esta vacio pero no tiene extension .txt, sera rechazado" "validar_contenido_y_tipo_archivo" 
			return 0
		fi
	else
		loguearINFO "El archivo esta vacio, sera rechazado" "validar_contenido_y_tipo_archivo"
		return 0
	fi
}

#Esta funcion devuelve 1 si el nombre del archivo es valido y 0 si no lo es.

function validar_nombre ()
{
	local fecha_valida
	local cod_estado_valido
	local cod_comercio_valido

	loguearINFO "Se comprueba si el nombre del archivo es valido o no" "validar_nombre"

	validar_fecha "$1"

	fecha_valida=$?

	validar_codigo_estado "$1"

	cod_estado_valido=$?

	validar_codigo_comercio "$1"

	cod_comercio_valido=$?

	if [ $fecha_valida -eq 1 ] && [ $cod_estado_valido -eq 1 ] && [ $cod_comercio_valido -eq 1 ]
	then
		loguearINFO "El archivo tiene un nombre valido. Esta condicion se cumple" "validar_nombre"
		return 1
	else
		loguearINFO "El archivo tiene un nombre invalido. Esta condicion no se cumple" "validar_nombre"
		return 0
	fi
}

#Esta funcion devuelve 1 si la fecha del archivo es valida y 0 si no lo es.

function validar_fecha ()
{
	loguearINFO "Se comprueba si la fecha que esta en el nombre del archivo es valida o no" "validar_fecha"

	local fecha=`echo $1 | sed 's=^\(.*\)-\(.*\)-\(.*\)\.\(txt\)=\1='`

	local valida=`echo $fecha | grep '^020[1-9]$\|^02[1-2][0-9]$\|^0[469]0[1-9]$\|^0[469][1-2][0-9]$\|^0[469]30$\|^110[1-9]$\|^11[1-2][0-9]$\|^1130$\|^0[13578]0[1-9]$\|0[13578][1-2][0-9]$\|^0[13578]3[0-1]$\|^1[02]0[1-9]$\|^1[02][1-2][0-9]$\|^1[02]3[0-1]$' | wc -w`

	if [ $valida -eq 1 ]
	then
		loguearINFO "La fecha "$fecha" es valida, esta condicion se cumple" "validar_fecha"
		return 1
	else
		loguearINFO "La fecha es invalida, esta condicion no se cumple" "validar_fecha"
		return 0
	fi
}


#Esta funcion devuelve 1 si el codigo de estado del archivo es valido y 0 si no lo es.

function validar_codigo_estado()
{
	loguearINFO "Se comprueba si el codigo de provincia que esta en el nombre es valido o no" "validar_codigo_estado"

	local cod_estado=`echo $1 | sed 's=^\(.*\)-\(.*\)-\(.*\)\.\(txt\)$=\2='`
	local codigo
	local linea_i

	IFS=$'\n'

	for linea_i in $(<"$DIRTAB/Tabla_provincias.csv")
	do
		codigo=`echo $linea_i | cut -d "," -f 2`

		if [[ $cod_estado == $codigo ]]
		then
			loguearINFO "La provincia de codigo "$cod_estado" fue encontrada, esta condicion se cumple" "validar_codigo_estado"
			return 1
		fi

	done

	loguearINFO "La provincia de codigo "$cod_estado" no fue encontrada, esta condicion no se cumple" "validar_codigo_estado"

	return 0
}

#Esta funcion devuelve 1 si el cadigo de comercio del archivo es valido y 0 si no lo es.

function validar_codigo_comercio()
{
	loguearINFO "Se comprueba si el codigo del comercio existe y esta habilitado" "validar_codigo_comercio"

	local cod_comercio=`echo $1 | sed 's=^\(.*\)-\(.*\)-\(.*\)\.\(txt\)=\3='`
	local codigo
	local estado_comercio
	local linea_i


	IFS=$'\n'

	for linea_i in $(<"$DIRTAB/Tabla_comercio.csv")
	do
		codigo=`echo $linea_i | cut -d "," -f 1`
		estado_comercio=`echo $linea_i | cut -d "," -f 2`

		if [[ $cod_comercio == $codigo ]] && [[ "$estado_comercio" == "HABILITADO" ]]
		then
			loguearINFO "El comercio con codigo "$cod_comercio" fue encontrado, esta condicion se cumple" "validar_codigo_comercio"
			return 1
		fi

	done

	loguearINFO "El comercio con codigo "$cod_comercio" no fue encontrado, esta condicion no se cumple" "validar_codigo_comercio"

	return 0
}

#Esta funcion procesa los archivos de novedades aceptados de acuerdo a lo pedido en el enunciado.
function procesar_aceptados
{

	loguearINFO  "Comienza el procesamiento de los archivos aceptados" "procesar_aceptados"

	cd "$DIROK"

	local aceptados=($(ls -1 $DIROK))
	local cant_registros

	for archivo_aceptado_i in ${aceptados[@]}
	do
		loguearINFO  "Se va a procesar el archivo de nombre: ""$archivo_aceptado_i" "procesar_aceptados"

		contar_registros "$archivo_aceptado_i"

		cant_registros=$?

		loguearINFO  "cantidad de registros a procesar: ""$cant_registros" "procesar_aceptados"

		procesar_registros "$archivo_aceptado_i"

		mv "$archivo_aceptado_i" "$DIRPROC"

	done

	return 0
}

#Esta funcion devuelve la cantidad de registros que tiene el archivo que se le envia.
function contar_registros()
{
	local cantidad=0
	local archivo=$1

	IFS=$'\n'

	for registro_i in $(<"$archivo")
	do
		let "cantidad=$cantidad+1"
	done

	return $cantidad

}

function procesar_registros()
{
	local registro
	local archivo_aceptado=$1
	local registro_valido
	local cant_validos=0
	local cant_invalidos=0

	IFS=$'\n'

	for registro_i in $(<"$archivo_aceptado")
	do
		loguearINFO "Primero se ve si el registro es valido o no" "procesar_registros"

		validar_registro "$registro_i" "$archivo_aceptado"

		registro_valido=$?

		if [ $registro_valido -eq 1 ]
		then
			let "cant_validos=$cant_validos+1"
			loguearINFO "Como el archivo es valido se creara el archivo de salida" "procesar_registros"
			crear_salida "$registro_i" "$archivo_aceptado"
		else
			let "cant_invalidos=$cant_invalidos+1"
		fi

	done

	loguearINFO "Cantidad de registros validos procesados: ""$cant_validos" "procesar_registros"
	loguearINFO "Cantidad de registros invalidos procesados: ""$cant_invalidos" "procesar_registros"

	return 0
}


#Esta funcion verifica si cada uno de los campos de los registros tiene el nombre correcto y posicion correcta
# Devuelve 1 si el registro es valido, 0 si no lo es. Tambien crea la entrada al archivo RejectedData en DIRNOK si el registro es invalido
function validar_registro(){

	local registro=$1
	local nombre_fuente=$2
	local formato_invalido
	local motivo_fc=""
	local motivo_fi=""
	local pos=1
	local motivo

	loguearINFO "SE PROCESARA EL REGRISTRO: "$1 "validar_registro"

	# Para campo se revisa si el campo existe, si es asi revisamos si el formato que tiene es valido o no.

	# Campo 1: idTransaction
	local hay_campo_1=`echo $registro | cut -d "," -f $pos | grep '"idTransaction"' | wc -w`

	if [ $hay_campo_1 -eq 0 ]
	then
		motivo_fc=$motivo_fc" idTransaction, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -eq 2 ]
		then
			hay_campo_1=0
			motivo_fi=$motivo_fi" idTransaction, "
		fi
		let "pos=$pos+1"
	fi

	

	# Campo 2: isO03_cProcessingCode
	local hay_campo_2=`echo $registro | cut -d "," -f $pos |grep '"isO03_cProcessingCode"' | wc -w`

	if [ $hay_campo_2 -eq 0 ]
	then
		motivo_fc=$motivo_fc" isO03_cProcessingCode, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -ne 2 ]
		then
			hay_campo_2=0
			motivo_fi=$motivo_fi" isO03_cProcessingCode, "
		fi
		let "pos=$pos+1"

	fi

	# Campo 3: isO04_nTransactionAmount
	local hay_campo_3=`echo $registro | cut -d "," -f $pos | grep '"isO04_nTransactionAmount"' | wc -w`

	if [ $hay_campo_3 -eq 0 ]
	then
		motivo_fc=$motivo_fc" isO04_nTransactionAmount, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -eq 2 ]
		then
			hay_campo_3=0
			motivo_fi=$motivo_fi" isO04_nTransactionAmount, "	
		fi
		let "pos=$pos+1"

	fi

	# Campo 4: isO11_cSystemTrace
	local hay_campo_4=`echo $registro | cut -d "," -f $pos | grep '"isO11_cSystemTrace"' | wc -w`

	if [ $hay_campo_4 -eq 0 ]
	then
		motivo_fc=$motivo" isO11_cSystemTrace, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -ne 2 ]
		then
			hay_campo_4=0
			motivo_fi=$motivo_fi" isO11_cSystemTrace, "
		fi
		let "pos=$pos+1"
	fi


	# Campo 5: isO12_cLocalTransactionTime
	local hay_campo_5=`echo $registro | cut -d "," -f $pos | grep '"isO12_cLocalTransactionTime"' | wc -w`

	if [ $hay_campo_5 -eq 0 ]
	then
		motivo_fc=$motivo_fc" isO12_cLocalTransactionTime, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -ne 2 ]
		then
			hay_campo_5=0
			motivo_fi=$motivo_fi" isO12_cLocalTransactionTime, "
		fi
		let "pos=$pos+1"

	fi

	# Campo 6: isO37_cRetrievalReferenceNumber
	local hay_campo_6=`echo $registro | cut -d "," -f $pos | grep '"isO37_cRetrievalReferenceNumber"' | wc -w`

	if [ $hay_campo_6 -eq 0 ]
	then
		motivo_fc=$motivo_fc" isO37_cRetrievalReferenceNumber, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -ne 2 ]
		then
			hay_campo_6=0
			motivo_fi=$motivo_fi" isO37_cRetrievalReferenceNumber, "
		fi
		let "pos=$pos+1"

	fi


	# Campo 7: isO38_cAuthorizationResponse
	local hay_campo_7=`echo $registro | cut -d "," -f $pos | grep '"isO38_cAuthorizationResponse"' | wc -w`

	if [ $hay_campo_7 -eq 0 ]
	then
		motivo_fc=$motivo_fc" isO38_cAuthorizationResponse, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -ne 2 ]
		then
			hay_campo_7=0
			motivo_fi=$motivo_fi" isO38_cAuthorizationResponse, "
		fi
		let "pos=$pos+1"

	fi



	# Campo 8: isO39_cResponseCode
	local hay_campo_8=`echo $registro | cut -d "," -f $pos |grep '"isO39_cResponseCode"' | wc -w`

	if [ $hay_campo_8 -eq 0 ]
	then
		motivo_fc=$motivo_fc" isO39_cResponseCode, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -ne 2 ]
		then
			hay_campo_8=0
			motivo_fi=$motivo_fi" isO39_cResponseCode, "	
		fi
		let "pos=$pos+1"

	fi

	# Campo 9: isO48_cAdditionalData_Installments
	local hay_campo_9=`echo $registro | cut -d "," -f $pos | grep 'isO48_cAdditionalData_Installments"' | wc -w`

	if [ $hay_campo_9 -eq 0 ]
	then
		motivo_fc=$motivo_fc" isO48_cAdditionalData_Installments, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -ne 2 ]
		then
			hay_campo_9=0
			motivo_fi=$motivo_fi" isO48_cAdditionalData_Installments, "	
		fi
		let "pos=$pos+1"

	fi

	# Campo 10: isO60_cReservedPrivate_HostResponse
	local hay_campo_10=`echo $registro | cut -d "," -f $pos | grep '"isO60_cReservedPrivate_HostResponse"' | wc -w`

	if [ $hay_campo_10 -eq 0 ]
	then
		motivo_fc=$motivo_fc" isO60_cReservedPrivate_HostResponse, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -ne 2 ]
		then
			hay_campo_10=0
			motivo_fi=$motivo_fi" isO60_cReservedPrivate_HostResponse, "	
		fi
		let "pos=$pos+1"

	fi

	# Campo 11: isO62_cTicketNumber
	local hay_campo_11=`echo $registro | cut -d "," -f $pos | grep '"isO62_cTicketNumber"' | wc -w`

	if [ $hay_campo_11 -eq 0 ]
	then
		motivo_fc=$motivo_fc" isO62_cTicketNumber, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -ne 2 ]
		then
			hay_campo_11=0
			motivo_fi=$motivo_fi" isO62_cTicketNumber, "	
		fi
		let "pos=$pos+1"

	fi

	# Campo 12: isO63_cReservedPrivate_BatchNumber
	local hay_campo_12=`echo $registro | cut -d "," -f $pos | grep '"isO63_cReservedPrivate_BatchNumber"' | wc -w`

	if [ $hay_campo_12 -eq 0 ]
	then
		motivo_fc=$motivo_fc" isO63_cReservedPrivate_BatchNumber, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -ne 2 ]
		then
			hay_campo_12=0
			motivo_fi=$motivo_fi" isO63_cReservedPrivate_BatchNumber, "	
		fi
		let "pos=$pos+1"

	fi

	# Campo 13: cGuid
	local hay_campo_13=`echo $registro | cut -d "," -f $pos | grep '"cGuid": ".*"' | wc -w`

	if [ $hay_campo_13 -eq 0 ]
	then
		motivo_fc=$motivo_fc" cGuid, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -ne 2 ]
		then
			hay_campo_13=0
			motivo_fi=$motivo_fi" cGuid, "	
		fi
		let "pos=$pos+1"

	fi

	# Campo 14: isO_MTI_cMessageType
	local hay_campo_14=`echo $registro | cut -d "," -f $pos  |grep '"isO_MTI_cMessageType"' | wc -w`

	if [ $hay_campo_14 -eq 0 ]
	then
		motivo_fc=$motivo_fc" isO_MTI_cMessageType, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -ne 2 ]
		then
			hay_campo_14=0
			motivo_fi=$motivo_fi" isO_MTI_cMessageType, "	
		fi
		let "pos=$pos+1"

	fi

	# Campo 15: isO_MTI_cMessageType_Response
	local hay_campo_15=`echo $registro | cut -d "," -f $pos | grep '"isO_MTI_cMessageType_Response"' | wc -w`

	if [ $hay_campo_15 -eq 0 ]
	then
		motivo_fc=$motivo_fc" isO_MTI_cMessageType_Response, "
	else
		formato_invalido=`echo $registro | cut -d "," -f $pos | grep '".*": ".*"' | wc -w`
		if [ $formato_invalido -ne 2 ]
		then
			hay_campo_15=0
			motivo_fi=$motivo_fi" isO_MTI_cMessageType_Response, "	
		fi
		let "pos=$pos+1"

	fi



	if [ $hay_campo_1 -ne 0 ] && [ $hay_campo_2 -ne 0 ] && [ $hay_campo_3 -ne 0 ] && [ $hay_campo_4 -ne 0 ] &&
	[ $hay_campo_5 -ne 0 ] && [ $hay_campo_6 -ne 0 ] && [ $hay_campo_7 -ne 0 ] && [ $hay_campo_8 -ne 0 ] &&
	[ $hay_campo_9 -ne 0 ] && [ $hay_campo_10 -ne 0 ] && [ $hay_campo_11 -ne 0 ] && [ $hay_campo_12 -ne 0 ] &&
	[ $hay_campo_13 -ne 0 ] && [ $hay_campo_14 -ne 0 ] && [ $hay_campo_15 -ne 0 ]
	then
		# Campo 15: isO_MTI_cMessageType_Response
		local hay_campo_16=`echo $registro | cut -d "," -f 16 | wc -w`

		if [ $hay_campo_16 -ne 0 ]
		then
			motivo="Este registro tiene mas de 15 campos, "
		else
			loguearINFO "El registro tiene todos sus campos, ademas estos mismos estan en el formato pedido. ES VALIDO" "validar_registro"
			return 1

		fi	
	fi

	if [[ $motivo_fc != "" ]]
	then
		motivo=$motivo"Faltan campos: "$motivo_fc
	fi
	if [[ $motivo_fi != "" ]]
	then
		motivo=$motivo"Formato incorrecto en: "$motivo_fi
	fi

	linea_datos_rechazados=$registro"-"$motivo"-"$nombre_fuente

	loguearINFO "El registro sera rechazado por los siguientes movitos: "$motivo "validar_registro"

	echo "$linea_datos_rechazados" >> "$DIRNOK/RejectedData"

	return 0
}

function crear_salida(){

	#A continuacion se crearan los 23 campos del archivo de salida.
	local nombre_archivo=$2
	local registro=$1
	local registro_salida
	local codigo_respuesta=`echo $registro | cut -d "," -f 8 | sed 's/\(.*": "\)\(.*\)"/\2/'`
	local monto_transaccion=`echo $registro | cut -d "," -f 3 | sed 's/\(.*"isO04_nTransactionAmount": \)\(.*\)/\2/' | sed 's/\s//'`
	local fecha=`echo $nombre_archivo | cut -d "-" -f 1| sed 's/\s//'`

	loguearINFO "Se creara cada uno de los campos del registro de salida" "crear_salida"

	#Campo 1: cOriginalFile(nombre del archivo origen)
	local campo_1=`echo $nombre_archivo | sed 's/\(.*\)\(.txt\)/ "cOriginalFile": "\1"/'`

	#Campo 2: isO05_cStateName(nombre de la provincia cuyo codigo esta en el nombre)
	
	local campo_2=$(crear_campo_2 $nombre_archivo)

	#Campo 3: isO06_cStateCode(Codigo de la provincia que esta en el nombre del archivo )
	local campo_3=`echo $nombre_archivo | sed 's/\(.*\)-\(.*\)-\(.*\)/"isO06_cStateCode": "\2"/'`

	#Campo 5: isO13_cLocalTransactionDate(fecha que aparece en el nombre del archivo)
	local campo_5=`echo $nombre_archivo | sed 's/\(.*\)-\(.*\)-\(.*\)/"isO13_cLocalTransactionDate": "\1"/'`

	#Campo 7: isO42_cMerchantCode(Codigo de comercio que esta en el nombre del archivo)
	local campo_7=`echo $nombre_archivo | sed 's/\(.*\)-\(.*\)-\(.*\).txt/"isO42_cMerchantCode": "\3"/'`

	#Campo 8: isO49_cTransactionCurrencyCode( tiene un valor fijo de 032 y representa la moneda argentina)
	local campo_8="\"isO49_cTransactionCurrencyCode\": \"032\""

	#Campo 4: isO07_cTransmissionDateTime(Concatenacion entre el campo 5,la fecha, y el campo "isO12_cLocalTransactionTime" del registro)

	local campo_4=`echo $registro | cut -d "," -f 5 | sed 's/"\(.*": \)"\(.*\)"/\2/' | sed 's/\s//' `

	campo_4="\"isO07_cTransmissionDateTime\": \""$fecha$campo_4"\""

	#Campo 6: isO15_cResponseCodeShortDescription( Es la descripcion corta de la tabla de respuestas gateway que corresponde al campo isO39_cResponseCode del registro)	

	local campo_6=$(crear_campo_6 $codigo_respuesta)

	#Campo 9: "isO04_cTransactionAmount"(es el valor del campo sO04_nTransactionAmoun pero pasado a caracteres y con extension de 0s a la derecha hasta tener 12 caracteres)

	local campo_9=$(crear_campo_9 $monto_transaccion)

	#Con la informacion que se tiene se puede crear el registro de salida:

	local registro_salida=$campo_1", "$campo_2", "$campo_3", "$campo_4", "$campo_5", "$campo_6", "$campo_7", "$campo_8", " 

	registro_salida=$registro_salida`echo $registro | cut -d "," -f 1`", "
	registro_salida=$registro_salida`echo $registro | cut -d "," -f 2`

	registro_salida=$registro_salida", "$campo_9","

	registro_salida=$registro_salida`echo "$registro" | cut -d "," -f 4-15`

	# Con esto el registro de salida ya esta termindado, Ahora se crea el nombre del archivo de salida:

	#Primero ajustamos la fecha segun la hora de cierre

	fecha=$(ajustar_fecha $fecha $registro)

	# Creamos el nombre del archivo de salida

	local archivo_salida=`echo "$nombre_archivo" | sed 's/\(.*-.*\)-\(.*\).txt/\2/'`"-$fecha"

	#El registro se envia al archivo de salida

	loguearINFO "ARCHIVO DE SALIDA: ""$registro_salida" "crear_salida"

	echo "$registro_salida" >> "$DIRSAL/$archivo_salida"

	loguearINFO "Resgistro de salida creado y guardado en el archivo de salida correspondiente" "crear_salida"

	return 0
}


#Esta funcion devuelve el valor del campo 2, que el el nombre de la provincia cuyo codigo esta en el nombre del archivo
function crear_campo_2(){

	local nombre_archivo=$1
	local codigo_estado=`echo $nombre_archivo | sed 's/\(.*\)-\(.*\)-\(.*\)/\2/'`
	local codigo_i
	local provincia_i
	local campo

	IFS=$'\n'

	for provincia_i in $(<"$DIRTAB/Tabla_provincias.csv")
	do
		codigo_i=`echo $provincia_i|cut -d "," -f 2`

		if [[ $codigo_i == $codigo_estado ]]
		then
			campo=`echo $provincia_i|cut -d "," -f 1 | sed 's/\(.*\)/"isO05_cStateName": "\1"/'`
			break
		fi
	done

	echo "$campo"
}

#Esta funcion devuelve el valor del campo 6, es la descripcion corta que se encuentra en la tabla de respuesta gateway segun el codigo de respuesta del registro
function crear_campo_6(){

	local codigo=$1
	local campo=""

	IFS=$'\n'

	for respuesta_i in $(<"$DIRTAB/Tabla_respuesta_gateway.csv")
	do
		codigo_respuesta_i=`echo $respuesta_i | cut -d "," -f 1`
		if [[ $codigo_respuesta_i == $codigo ]]
		then
			campo=`echo $respuesta_i | cut -d "," -f 2`
			campo="\"isO15_cResponseCodeShortDescription\": \"$campo\""
		fi

	done

	if [[ $campo == "" ]]
	then
		campo="\"isO15_cResponseCodeShortDescription\": \"DESCONOCIDO\""
	fi

	echo "$campo"

}

#Esta funcion devuelve el valor del campo 9, extiende el monto de la transaccion a una cadena de caracteres de tamaño 12 con 0s a la izquierda
function crear_campo_9(){

	local campo
	local monto=$1
	local cantidad_caracteres=${#monto}
	local cant_ceros
	local ceros=""
	local i=1

	let "cant_ceros=12-$cantidad_caracteres"

	while [  $i -le $cant_ceros ]
	do
		ceros=$ceros"0"
		let "i=$i+1"
	done

	monto="$ceros$monto"

	campo="\"sO04_cTransactionAmount\": \"$monto"\"

	echo "$campo"

}

function ajustar_fecha ()
{
	local fecha=`echo $1 | sed 's/0*//'`

	#Le saco los 0s a izquierda de ambas horas para pasarlos a numeros
	local hora_transaccion=`echo $2 | cut -d "," -f 5 | sed 's/\(.*": \)"\(.*\)"/\2/' | sed 's/0*//'`
	local hora_cierre=`echo $HCIERRE | sed 's/0*//'`

	loguearINFO "Se compara la hora de cierre con la hora de la transaccion" "ajustar_fecha"

	#Comparo ambas horas, si la hora de transaccion es menor entones se devuelve la hora tal cual se la ingreso.
	if [ $hora_transaccion -lt $hora_cierre ]
	then
		loguearINFO "La hora de transaccion es menor a la hora de cierre, el dia de la transaccion de deja tal cual esta" "ajustar_fecha"
		echo $1

	#Si no es asi entonces aumento en uno el valor del dia y compruevo si es una fecha valida
	else
		loguearINFO "La hora de la transaccion es mayor a la hora de cierre, se aumentara en uno el dia de la fecha de salida" "ajustar_fecha"
		let "fecha=$fecha+1"

		if [ ${#fecha} != 4  ]
		then
			aux="0$fecha"
		else
			aux=$fecha
		fi

		local valido=`echo $aux | grep '^020[1-9]$\|^02[1-2][0-9]$\|^0[469]0[1-9]$\|^0[469][1-2][0-9]$\|^0[469]30$\|^110[1-9]$\|^11[1-2][0-9]$\|^1130$\|^0[13578]0[1-9]$\|0[13578][1-2][0-9]$\|^0[13578]3[0-1]$\|^1[02]0[1-9]$\|^1[02][1-2][0-9]$\|^1[02]3[0-1]$' | wc -w`

		# Si es valida devuelvo el valor de fecha y le agrego un cero a la izquierda si es necesario
		if [ $valido -eq 1 ]
		then
			if [ $fecha -lt 1000 ]
			then
				echo "0$fecha"
			else
				echo "$fecha"
			fi

		else
			local diciembre=`echo $fecha | grep '12..'|wc -w`

			if [ $diciembre -eq 1 ]
			then
				echo "0101"
			else
				let "fecha=$fecha+100"
				local mes

				let "mes=$fecha/100"

				if [ $fecha -lt 1000 ]
				then
					echo "0"$mes"01"
				else
					echo "$mes""01"
				fi
			fi
		fi
	fi

}

#Esta funcion loguea mensajes de tipo ERROR, recibe dos parametros que son el mensaje y a la que pertenece el mensaje
function loguearERROR()
{	
	if [ -d "$DIRPROC" ] && [ ! -f "$DIRPROC/proceso.log" ]
	then
		dir_log="$DIRPROC/proceso.log"
		if [ -f "$dir_actual/proceso.log" ]
		then
			cat "$dir_actual/proceso.log" >> "$dir_log"
			rm "$dir_actual/proceso.log"
		fi
	elif [ ! -d "$DIRPROC" ]
	then
		dir_log="$dir_actual/proceso.log"

	elif [ -f "$DIRPROC/proceso.log" ]
	then
		dir_log="$DIRPROC/proceso.log"
		
		if [ -f "$dir_actual/proceso.log" ]
		then
			rm "$dir_actual/proceso.log"
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
	if [ -d "$DIRPROC" ] && [ ! -f "$DIRPROC/proceso.log" ]
	then
		dir_log="$DIRPROC/proceso.log"
		if [ -f "$dir_actual/proceso.log" ]
		then
			cat "$dir_actual/proceso.log" >> "$dir_log"
			rm "$dir_actual/proceso.log"
		fi
	elif [ ! -d "$DIRPROC" ]
	then
		dir_log="$dir_actual/proceso.log"

	elif [ -f "$DIRPROC/proceso.log" ]
	then
		dir_log="$DIRPROC/proceso.log"
		
		if [ -f "$dir_actual/proceso.log" ]
		then
			rm "$dir_actual/proceso.log"
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
	if [ -d "$DIRPROC" ] && [ ! -f "$DIRPROC/proceso.log" ]
	then
		dir_log="$DIRPROC/proceso.log"
		if [ -f "$dir_actual/proceso.log" ]
		then
			cat "$dir_actual/proceso.log" >> "$dir_log"
			rm "$dir_actual/proceso.log"
		fi
	elif [ ! -d "$DIRPROC" ]
	then
		dir_log="$dir_actual/proceso.log"

	elif [ -f "$DIRPROC/proceso.log" ]
	then
		dir_log="$DIRPROC/proceso.log"
		
		if [ -f "$dir_actual/proceso.log" ]
		then
			rm "$dir_actual/proceso.log"
		fi
	fi
	local fecha=`date +%Y-%m-%d"  "%T`
	local linea="[ "$fecha" ]-INF-"$1"-"$2

	echo -e $linea"\n" >> "$dir_log"
	return 0
}



#										.:proceso:.

dir_actual=$PWD

loguearINFO "EL PROCESO INICIA" "proceso"

loguearINFO "Primero se verifica que no se recibieron parametros" "proceso"


if [ $# != 0 ]
then
	loguearERROR "Este proceso no recibe parametros" "proceso"
	loguearINFO "FIN DEL PROCESO" "proceso"
	echo "Error: este proceso no recibe parametros"
	echo -e "\n" >> "$dir_log"
	exit 1
fi

loguearINFO "No se recibieron parametros" "proceso"
loguearINFO "Segundo se verifica que se lanzo con el comando start" "proceso"

if [[ $HAYSTART == "" ]]
then
	loguearERROR "Este proceso no se lanzo con el comando start,el proceso se va a cerrar" "proceso"
	loguearINFO "FIN DEL PROCESO" "proceso"
	echo "Error: solo el comando start puede arrancar al proceso"
	echo -e "\n" >> "$dir_log"
	exit 1
fi

loguearINFO "El proceso se lanzo con start" "proceso"

loguearINFO "Tercero se comprueba si el ambiente fue levantado" "proceso"




if [[ $HAYAMBIENTE == "" ]]
then
	loguearERROR "Error: No hay ambiente para ejecutar el proceso" "proceso"
	loguearINFO "El proceso se cerrara y se le indicara al usuario que tiene que hacer para levantar el ambiente" "proceso"
	loguearINFO "FIN DEL PROCESO" "proceso"	
	echo "No hay ambiente para ejecutar el proceso. Por favor ejecute el inicializador para levantar el ambiente."
	echo "Para ejecutar el ambiente vaya al directorio de ejecutables y ejecute:"
	echo -e "\n\t. ./inicializar.sh"
	echo -e "\n" >> $dir_log
	exit 1
fi

loguearINFO "Hay ambiente para ejecutar el proceso, el mismo fue lanzado por start, el proceso iniciara exitosamente" "proceso"

iteracion=1

while [ $iteracion -ne 10001 ]
do
	loguearINFO "CICLO: "$iteracion "proceso"

	loguearINFO "Primero se verifica si el directorio de novedades esta vacio" "proceso"

	#Primero vemos si el directorios de novedades esta vacio o no, si esta vacio entonces se termina el ciclo y el proceso duerme 1 minuto 
	directorio_novedades_vacio

	if [ $? -eq 0 ]
	then
		loguearINFO "El directorio del novedades esta vacio, el proceso dormira 1 minuto y empezara un nuevo ciclo" "proceso"		
		sleep 1m
		let "iteracion=$iteracion+1"
		continue
	fi

	loguearINFO "El directorio del novedades no esta vacio, los archivos que se encuentran alli seran procesados" "proceso"

	#se procesan los archivos de novedades
	procesar_novedades

	loguearINFO "Se termino de procesar a los archivo de novedades, los archivos que fueron aceptados seran procesados" "proceso"

	#Ahora que los archivos en novedades ya fueron aceptados y rechazados se procedera a crear los archivos de salida
	procesar_aceptados

	loguearINFO "Todos los archivos aceptados fueron procesados. El proceso dormira 1 minuto y empezara un nuevo ciclo" "proceso"
	loguearINFO "FIN CICLO: "$iteracion "proceso"

	let "iteracion=$iteracion+1"
	sleep 1m 
done

loguearINFO "El proceso alcanzo las 10000 iteraciones. Por esta razon se cerrara exitosamente" "proceso"

loguearINFO "FIN DEL PROCESO" "proceso"

echo -e "\n" >> $dir_log