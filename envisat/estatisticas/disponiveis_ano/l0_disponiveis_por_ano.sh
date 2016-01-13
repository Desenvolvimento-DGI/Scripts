#!/bin/bash

# Parametro referente ao ano
PARANO="${1}"
TEXTOPARANO=${PARANO}

ARQUIVOSAIDA="${2}"


TAMANHOANO="${#PARANO}"

if [ ${TAMANHOANO} -ne 4 ]
then
	# Ano nao informado ou incorreto
	PARANO='*'
	TEXTOPARANO='Todos os anos'
fi
	 
DIRATUAL="`pwd`"
AREASCRIPTS="/home/cdsr/estatisticas/"

 

# Nome deste programa/script
NOMEPROGRAMA="`basename $0`"

echo ""
echo "SCRIPT   : ${NOMEPROGRAMA}"
echo "PERIODO  : ${PARANO}"
echo ""
echo "Gerando estatisticas para arquivos disponiveis diretamente ..."
echo ""


${AREASCRIPTS}l0_disponiveis_aqua_ano.sh ${PARANO} ${ARQUIVOSAIDA}
${AREASCRIPTS}l0_disponiveis_terra_ano.sh ${PARANO} ${ARQUIVOSAIDA}
${AREASCRIPTS}l0_disponiveis_snpp_ano.sh ${PARANO} ${ARQUIVOSAIDA}
${AREASCRIPTS}l0_disponiveis_noaa_ano.sh ${PARANO} ${ARQUIVOSAIDA}
${AREASCRIPTS}l0_disponiveis_goes_ano.sh ${PARANO} ${ARQUIVOSAIDA}
${AREASCRIPTS}l0_disponiveis_metopb_ano.sh ${PARANO} ${ARQUIVOSAIDA}
${AREASCRIPTS}l0_disponiveis_meteosat_ano.sh ${PARANO} ${ARQUIVOSAIDA}

