#!/bin/bash 

PARPERIODO="${1}"
PARSATELITE="L8"
PARSENSOR="OLI"
DIRSCRIPTS='/home/cdsr/l8/'

SATELITE="`echo ${PARPERIODO} | cut -c 1-3`"
ORBITA="`echo ${PARPERIODO} | cut -c 4-6`"
ANO="`echo ${PARPERIODO} | cut -c 13-16`"
DIAJULIANO="`echo ${PARPERIODO} | cut -c 17-19`"

ORIGEM='/L1_LANDSAT8/L1T/'

DIAJULIANO="`echo ${PARPERIODO} | cut -c 17-19`"


# Obter dia e mes de uma determinada data gregoriana

DATAGREGORIANAATUAL=""
MES=""
PARDIA=""
for MESATUAl in `seq 1 12`
do
	for DIAATUAL in `seq 1 31`
	do
		DATAGREGORIANAATUAL="${MESATUAl}/${DIAATUAL}/${ANO}"
		DATAJULIANOATUAL="`date +"%j" -d ${DATAGREGORIANAATUAL}`"
		
		if [ $? -eq 0 ] && [ "${DATAJULIANOATUAL}" == "${DIAJULIANO}" ]
		then
			echo "ENCONTROU A DATA CORRETA ::  ${DATAJULIANOATUAL}  =   ${DIAJULIANO}"
			echo ""
			MES=${MESATUAl}
			PARDIA=${DIAATUAL}
			break
		fi		
	done
	if [ "${DATAJULIANOATUAL}" == "${DIAJULIANO}" ]
	then
		break
	fi
done


# Acerta o valor do mes caso seja menor que 10 preenchendo com zero a esquerda
MES=$(( MES + 100 ))
MES="`echo ${MES} | cut -c 2-3`"

PARDIA=$(( PARDIA + 100 ))
PARDIA="`echo ${PARDIA} | cut -c 2-3`"
ANO="`echo ${PARPERIODO} | cut -c 13-16`"
DIRANOMES="${ANO}_${MES}"


# Executa, respectivamente, os scripts responsáis por gerar o quicklook e os registros no banco de dados

${DIRSCRIPTS}gera_quicklook_l8_l1t.sh    ${PARPERIODO}  ${PARSATELITE}  ${PARSENSOR}  ${ANO}  ${MES}  ${ORBITA} ${PARDIA}
${DIRSCRIPTS}regera_quicklook_l8_l1t.sh  ${PARPERIODO}  ${PARSATELITE}  ${PARSENSOR}  ${ANO}  ${MES}  ${ORBITA} ${PARDIA}
	


