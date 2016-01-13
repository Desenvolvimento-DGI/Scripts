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

# Dados referente ao satéte
SATELITE="METEOSAT"
NOMESATELITE="METEOSAT"

FILTROSATELITE='S*'
FILTROEXTENSAO=""
ORIGEM="/L0_METEOSAT"
FATORDISTRIBUICAO=1
FONTEDADOS='L0 - ACESSO DIRETO'

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

	TOTALCENAS="`find ${ORIGEM}/${MESANOATUAL}  -name "${FILTROSATELITE}"  -print | wc -l`"
	TOTALGERAL=$(( ${TOTALCENAS} * ${FATORDISTRIBUICAO} ))
	echo "${ANOATUAl}/${MESATUAl} - ${NOMESATELITE} : ${TOTALCENAS}  -  ${FATORDISTRIBUICAO}  -  ${TOTALGERAL}"
	echo "${ANOATUAl};${MESATUAl};${FONTEDADOS};${NOMESATELITE};${TOTALCENAS};${FATORDISTRIBUICAO};${TOTALGERAL}"  >>  ${ARQUIVOSAIDA}
done




cd ${DIRATUAL}

