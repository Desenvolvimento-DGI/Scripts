#!/bin/bash
 
# Parametro referente ao ano
PARANO="${1}"
ARQUIVOSAIDA="${2}"

TAMANHOANO=${#PARANO}

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
SATELITE="A1"
NOMESATELITE="AQUA"

FILTROSATELITE='AQUA*'
FILTROEXTENSAO=""
ORIGEM="/Level-0/AQUA/"
FATORDISTRIBUICAO=2
FONTEDADOS='L0 - ACESSO DIRETO'


cd ${ORIGEM}

TOTALCENAS="`find ${ORIGEM}/${FILTROPERIODO}  -name ${FILTROSATELITE}  -print | wc -l`"
TOTALGERAL=$(( ${TOTALCENAS} * ${FATORDISTRIBUICAO} ))
echo "${NOMESATELITE} : ${TOTALCENAS}  -  ${FATORDISTRIBUICAO}  -  ${TOTALGERAL}"
echo ""

echo "${CAMPOANO};${FONTEDADOS};${NOMESATELITE};${TOTALCENAS};${FATORDISTRIBUICAO};${TOTALGERAL}"  >>  ${ARQUIVOSAIDA}

cd ${DIRATUAL}

