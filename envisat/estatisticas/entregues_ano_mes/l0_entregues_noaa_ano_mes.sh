#!/bin/bash

# Parametro referente ao ano
PARANO="${1}"
ARQUIVOSAIDA="${2}"

TAMANHOANO="${#PARANO}"

if [ ${TAMANHOANO} -ne 4  -o "${PARANO}" = "*" ]
then
	# Ano nao informado ou incorreto
	PARANO='*'
	FILTROPERIODO='*'
	CAMPOANO='TODOS'
else
	# Ano informado
	FILTROPERIODO="${PARANO}*"
	CAMPOANO="${PARANO}"
fi

	
	
	
DIRATUAL="`pwd`"
FATORDISTRIBUICAO=4
FONTEDADOS='L0 - ACESSO DIRETO'

LISTASATELITES=( 12 14 15 16 17 18 19)

for INDICEATUAL in `seq 0 6`
do

	# Dados referente ao satéte
	SATELITE="NOAA${LISTASATELITES[${INDICEATUAL}]}"
	NOMESATELITE="NOAA-${LISTASATELITES[${INDICEATUAL}]}"

	FILTROSATELITE="NOAA_*"
	FILTROEXTENSAO=""
	ORIGEM="/L0_NOAA${LISTASATELITES[${INDICEATUAL}]}"
	
	
	# Obtem o fator de distribuicao conforme o satelite e o ano
	#
	case ${LISTASATELITES[${INDICEATUAL}]} in
		12|14)			
			FATORDISTRIBUICAO=1
			;;			
		15)			
			FATORDISTRIBUICAO=4
			if [ ${PARANO} -eq 2012 ]
			then
				FATORDISTRIBUICAO=3
			fi			

			if [ ${PARANO} -le 2011 ]
			then
				FATORDISTRIBUICAO=1
			fi			
			;;
		16)			
			FATORDISTRIBUICAO=4
			if [ ${PARANO} -eq 2012 ]
			then
				FATORDISTRIBUICAO=3
			fi			
			
			if [ ${PARANO} -le 2011 ]
			then
				FATORDISTRIBUICAO=1
			fi						
			;;
		17)			
			FATORDISTRIBUICAO=1
			;;			
		18)			
			FATORDISTRIBUICAO=4
			if [ ${PARANO} -eq 2012 ]
			then
				FATORDISTRIBUICAO=3
			fi			

			if [ ${PARANO} -le 2011 ]
			then
				FATORDISTRIBUICAO=1
			fi			
			;;
		19)			
			FATORDISTRIBUICAO=4
			if [ ${PARANO} -eq 2012 ]
			then
				FATORDISTRIBUICAO=3
			fi			
			
			if [ ${PARANO} -le 2011 ]
			then
				FATORDISTRIBUICAO=1
			fi			
			;;
		*)
			FATORDISTRIBUICAO=1
			;;
	esac
			
			
	
	

	cd ${ORIGEM}
			

	if [ ${CAMPOANO} = "TODOS" ]
	then
		cd ${ORIGEM}
		LISTAANOMES="`\ls -1 | grep _ | sort`"
	else
		cd ${ORIGEM}
		LISTAANOMES="`\ls -1 | grep ${CAMPOANO} | sort`"
	fi
	

	
	for MESANOATUAL in ${LISTAANOMES}
	do
		ANOATUAl="`echo ${MESANOATUAL} | cut -f 1 -d _`"
		MESATUAl="`echo ${MESANOATUAL} | cut -f 2 -d _`"

		FILTROSATELITE="NOAA_*"		
		TOTALCENAS1="`find ${ORIGEM}/${MESANOATUAL}  -name "${FILTROSATELITE}"  -print | wc -l`"
			
		FILTROSATELITE="S*"
		TOTALCENAS2="`find ${ORIGEM}/${MESANOATUAL}  -name "${FILTROSATELITE}"  -print | wc -l`"
		
		TOTALCENAS=$(( $TOTALCENAS1 + $TOTALCENAS2 ))	
		TOTALGERAL=$(( ${TOTALCENAS} * ${FATORDISTRIBUICAO} ))		
				
		echo "${ANOATUAl}/${MESATUAl} - ${NOMESATELITE} : ${TOTALCENAS}  -  ${FATORDISTRIBUICAO}  -  ${TOTALGERAL}"	
		echo "${ANOATUAl};${MESATUAl};${FONTEDADOS};${NOMESATELITE};${TOTALCENAS};${FATORDISTRIBUICAO};${TOTALGERAL}"  >>  ${ARQUIVOSAIDA}	
	done
	
	
done
	

cd ${DIRATUAL}

