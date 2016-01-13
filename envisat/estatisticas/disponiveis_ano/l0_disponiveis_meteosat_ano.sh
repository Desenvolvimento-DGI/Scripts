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

TOTALCENAS="`find ${ORIGEM}/${FILTROPERIODO}  -name ${FILTROSATELITE}  -print | wc -l`"
TOTALGERAL=$(( ${TOTALCENAS} * ${FATORDISTRIBUICAO} ))
echo "${NOMESATELITE} : ${TOTALCENAS}  -  ${FATORDISTRIBUICAO}  -  ${TOTALGERAL}"

echo "${CAMPOANO};${FONTEDADOS};${NOMESATELITE};${TOTALCENAS}"  >>  ${ARQUIVOSAIDA}

cd ${DIRATUAL}

