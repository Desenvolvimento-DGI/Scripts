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
	ORIGEM="/Level-0/NOAA${LISTASATELITES[${INDICEATUAL}]}"

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

		TOTALCENAS="`find ${ORIGEM}/${MESANOATUAL}  -name ${FILTROSATELITE}  -print | wc -l`"
		TOTALGERAL=$(( ${TOTALCENAS} * ${FATORDISTRIBUICAO} ))
		echo "${ANOATUAl}/${MESATUAl} - ${NOMESATELITE} : ${TOTALCENAS}  -  ${FATORDISTRIBUICAO}  -  ${TOTALGERAL}"	
		echo "${ANOATUAl};${MESATUAl};${FONTEDADOS};${NOMESATELITE};${TOTALCENAS};${FATORDISTRIBUICAO};${TOTALGERAL}"  >>  ${ARQUIVOSAIDA}	
	done
	
	
done
	

cd ${DIRATUAL}

