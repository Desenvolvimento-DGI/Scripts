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
FATORDISTRIBUICAO=1
FONTEDADOS='L0 - ACESSO DIRETO'

LISTASATELITES=( 12 14 15 16 17 18 19 )

for INDICEATUAL in `seq 0 6`
do

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
			
			


	# Dados referente ao satéte
	SATELITE="NOAA${LISTASATELITES[${INDICEATUAL}]}"
	NOMESATELITE="NOAA-${LISTASATELITES[${INDICEATUAL}]}"

	FILTROSATELITE="NOAA_*"
	FILTROEXTENSAO=""
	ORIGEM="/Level-0/NOAA${LISTASATELITES[${INDICEATUAL}]}"

	cd ${ORIGEM}
	TOTALCENAS1="`find ${ORIGEM}/${FILTROPERIODO}  -name "${FILTROSATELITE}"  -print | wc -l`"
		
	FILTROSATELITE="S*"
	TOTALCENAS2="`find ${ORIGEM}/${FILTROPERIODO}  -name "${FILTROSATELITE}"  -print | wc -l`"
	
	TOTALCENAS=$(( $TOTALCENAS1 + $TOTALCENAS2 ))	
	TOTALGERAL=$(( ${TOTALCENAS} * ${FATORDISTRIBUICAO} ))
	echo "${NOMESATELITE} : ${TOTALCENAS}  -  ${FATORDISTRIBUICAO}  -  ${TOTALGERAL}"
	
	echo "${CAMPOANO};${FONTEDADOS};${NOMESATELITE};${TOTALCENAS};${FATORDISTRIBUICAO};${TOTALGERAL}"  >>  ${ARQUIVOSAIDA}
	
done
	

cd ${DIRATUAL}

