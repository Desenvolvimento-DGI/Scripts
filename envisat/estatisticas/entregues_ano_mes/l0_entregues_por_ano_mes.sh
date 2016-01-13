#!/bin/bash

# Parametro referente ao ano
PARANO="${1}"
TEXTOPARANO=${PARANO}

ARQUIVOSAIDA="${2}"


TAMANHOANO="${#PARANO}"
# Verifica se o arquivo tem o tamanho padrã(26 para LISS3)
if [ ${TAMANHOANO} -ne 4 ]
then
	# Ano nao informado ou incorreto
	PARANO='*'
	TEXTOPARANO='Todos os anos'
fi
	
DIRATUAL="`pwd`"
AREASCRIPTS="/home/cdsr/estatisticas/"
DIRGRUPO="entregues_ano_mes/"


# Nome deste programa/script
NOMEPROGRAMA="`basename $0`"

echo ""
echo "SCRIPT   : ${NOMEPROGRAMA}"
echo "PERIODO  : ${PARANO}"
echo ""
echo "Gerando estatisticas para arquivos distribuidos diretamente ..."
echo ""


${AREASCRIPTS}${DIRGRUPO}l0_entregues_aqua_ano_mes.sh ${PARANO} ${ARQUIVOSAIDA}
${AREASCRIPTS}${DIRGRUPO}l0_entregues_terra_ano_mes.sh ${PARANO} ${ARQUIVOSAIDA}
${AREASCRIPTS}${DIRGRUPO}l0_entregues_snpp_ano_mes.sh ${PARANO} ${ARQUIVOSAIDA}
${AREASCRIPTS}${DIRGRUPO}l0_entregues_noaa_ano_mes.sh ${PARANO} ${ARQUIVOSAIDA}
${AREASCRIPTS}${DIRGRUPO}l0_entregues_goes12_ano_mes.sh ${PARANO} ${ARQUIVOSAIDA}
${AREASCRIPTS}${DIRGRUPO}l0_entregues_goes13_ano_mes.sh ${PARANO} ${ARQUIVOSAIDA}
${AREASCRIPTS}${DIRGRUPO}l0_entregues_metopb_ano_mes.sh ${PARANO} ${ARQUIVOSAIDA}
${AREASCRIPTS}${DIRGRUPO}l0_entregues_meteosat_ano_mes.sh ${PARANO} ${ARQUIVOSAIDA}

