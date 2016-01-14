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

LISTASATELITES=( 12 13)

for INDICEATUAL in `seq 0 1`
do

	# Dados referente ao satéte
	SATELITE="GOES${LISTASATELITES[${INDICEATUAL}]}"
	NOMESATELITE="GOES-${LISTASATELITES[${INDICEATUAL}]}"

	FILTROEXTENSAO=""
	ORIGEM="/Level-0/GOES${LISTASATELITES[${INDICEATUAL}]}"


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
		
			
		FILTROSATELITE="S*"
		TOTALCENAS="`find ${ORIGEM}/${MESANOATUAL}/GVAR/LINUX  -name ${FILTROSATELITE}  -print | wc -l`"
		TOTALCENASGERAL=${TOTALCENAS}
		TOTALGERAL=${TOTALCENAS}

		
		FILTROSATELITE="GOES*"
		TOTALCENAS="`find ${ORIGEM}/${MESANOATUAL}/CP*  -name ${FILTROSATELITE}  -print | wc -l`"
		TOTALCENASGERAL=$(( ${TOTALCENASGERAL} + ${TOTALCENAS} ))
		
		TOTALGERAL=$(( ${TOTALCENASGERAL} * ${FATORDISTRIBUICAO} ))
				
		echo "${ANOATUAl}/${MESATUAl} - ${NOMESATELITE} : ${TOTALCENAS}"	
		echo "${ANOATUAl};${MESATUAl};${FONTEDADOS};${NOMESATELITE};${TOTALCENAS}"  >>  ${ARQUIVOSAIDA}			
		
	done
		
		
done
	

cd ${DIRATUAL}

