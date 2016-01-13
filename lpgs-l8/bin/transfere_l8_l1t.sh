#!/bin/bash

PATH=/bin:/sbin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/bin
export PATH

PARPERIODO="${1}"


if [ $# -eq 0 ]
then
	echo ""
	echo "Nenhum parametro foi informado"
	echo "Necessáo informar  a passagem  quando executar este  script."
	echo "O parametro referente a passagem se trata do nome do diretorio"
	echo "onde as imagens foram geradas."
	echo ""
	exit
fi


HOMESCRIPT='/home/cdsr/bin/'
DIRATUAL=$(pwd)

ORIGEM='/dados/L1T_WORK/'
DESTINO='/L1_LANDSAT8/L1T/'


SATELITE="`echo ${PARPERIODO} | cut -c 1-3`"
ORBITA="`echo ${PARPERIODO} | cut -c 4-6`"
ANO="`echo ${PARPERIODO} | cut -c 13-16`"
DIAJULIANO="`echo ${PARPERIODO} | cut -c 17-19`"



# Obter dia e mes de uma determinada data gregoriana

DATAGREGORIANAATUAL=""
MES=""
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
			break
		fi		
	done
	if [ "${DATAJULIANOATUAL}" == "${DIAJULIANO}" ]
	then
		break
	fi
done

echo "ANO = ${ANO}"
echo "MESATUAL = ${MESATUAL}"
echo "MES = ${MES}"
echo "DIAATUAL = ${DIAATUAL}"
echo ""


# Diretorio referente ao ano e mêobtido com base no dia juliano
MES=$(( MES + 100 ))
MES="`echo ${MES} | cut -c 2-3`"
DIR_ANO_MES="${ANO}_${MES}"


NOMEARQPADRAO="${SATELITE}${ORBITA}"
AREAPERIODO="${ORIGEM}${DIR_ANO_MES}/${PARPERIODO}"

if [ ! -d "${AREAPERIODO}" ]
then
	echo ""
	echo "Passagem: [ ${PARPERIODO} ]"
	echo "O parametro referente a passagem nãexiste ou foi informado"
	echo "incorretamente. Favor verificar e executar novamente."
	echo ""
	exit
fi




if [ "${DATAGREGORIANAATUAL}" = "" ]
then
	echo ""
	echo "Erro com geracao da data no formato gregoriano"
	echo "provavelmente o parametro informado nãesta de correto, causado"
	echo "por digitacao incorreta da data juliana com um valor superior  a"
	echo "ou um valor invalido."
	echo ""
	exit
fi


MES="`echo ${DATAGREGORIANAATUAL} | cut -f 1 -d '/'`"
DIA="`echo ${DATAGREGORIANAATUAL} | cut -f 2 -d '/'`"

DIA=$((DIA + 100))
DIA="`echo ${DIA} | cut -c 2-3`"

MES=$((MES + 100))
MES="`echo ${MES} | cut -c 2-3`"

ANO_MES="${ANO}_${MES}"

cd ${AREAPERIODO}
pwd

DIRPONTOS="`\ls -1 | grep ^${NOMEARQPADRAO} | grep ${ANO}${DIAJULIANO} | sort `"

for DIRPONTOATUAL in ${DIRPONTOS}
do
	echo ""
	echo "AREAPERIODO    =  ${AREAPERIODO}"
	echo "DIRPONTOATUAL  =  ${DIRPONTOATUAL}"
	echo ""
	pwd
	
	cd "${AREAPERIODO}/${DIRPONTOATUAL}"
	pwd
	
	ARQUIVOGZ="`\ls -1 *.tar.gz`"
	
	if [ "${ARQUIVOGZ}" = "" ]
	then
		echo ""
		echo "Arquivo ${ARQUIVOGZ} nao encontrado na area:"
		echo "${AREAPERIODO}/${DIRPONTOATUAL}"
		echo ""
		continue
	fi
	
	mkdir -p ${DESTINO}${ANO_MES}
	mkdir -p ${DESTINO}${ANO_MES}/${PARPERIODO}
	mkdir -p ${DESTINO}${ANO_MES}/${PARPERIODO}/${DIRPONTOATUAL}
	
	mv -fv ${AREAPERIODO}/${DIRPONTOATUAL}/${ARQUIVOGZ}  ${DESTINO}${ANO_MES}/${PARPERIODO}/${DIRPONTOATUAL}
	cd ${DESTINO}${ANO_MES}/${PARPERIODO}/${DIRPONTOATUAL}
	tar -zxvf ./${ARQUIVOGZ}

	echo ""
	echo ""
	
	cd ${AREAPERIODO}
done

cd ${DIRATUAL}



