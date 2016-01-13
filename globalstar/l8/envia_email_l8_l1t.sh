#!/bin/bash
 
DIRATUAL=$(pwd)
ORIGEM='/L1_LANDSAT8/L1T/'
TOTAL_IMAGENS=0

PARPERIODO="${1}"
SATELITE="${2}"
SENSOR="${3}"
PARANO="${4}"
PARMES="${5}"
PARORBITA="${6}"
PARDIA="${7}"

DATA="${PARDIA}/${PARMES}/${PARANO}"
DIAJULIANO="`echo ${PARPERIODO} | cut -c 17-19`"

NOMESENSOR="OLI"

FILTROANOMES="${PARANO}_${PARMES}"
 
CMDREMOVER='rm -fv '
CMDREMOVERARQS=""
CMDEMAIL='/usr/bin/mail '
EMAILCQ='cdsr@dgi.inpe.br,cq-dgi@dgi.inpe.br,jose.renato@dgi.inpe.br,madalena@dgi.inpe.br,operadores-dgi@dgi.inpe.br,marilia.moura@dgi.inpe.br,jose.azevedo@dgi.inpe.br'



 
ARQEMAILCQ="/home/cdsr/l8/OLI_MSG_CQ_${PARANO}${PARMES}${PARDIA}_${PARORBITA}.log"
ARQEMAILPONTOS="/home/cdsr/l8/OLI_ARQUIVOS_CQ_${PARANO}${PARMES}${PARDIA}_${PARORBITA}.log"


cd ${ORIGEM}${FILTROANOMES}/${PARPERIODO}
LISTAPONTOS="`find . -name "QL_*_GRD.png" -print | grep ${PARORBITA} | sort`"

echo "" > ${ARQEMAILPONTOS}
for PONTOATUAL in ${LISTAPONTOS}
do
	SCENEID="`echo ${PONTOATUAL} | cut -f 2 -d '_'`"
	PONTO="`echo ${SCENEID} | cut -c 9-11`"
	
	echo "ORBITA/BASE: ${PARORBITA}  PONTO: ${PONTO}  -  SCENEID: ${SCENEID} " >> ${ARQEMAILPONTOS}
	TOTAL_IMAGENS=$(($TOTAL_IMAGENS+1))		
done
echo "" >> ${ARQEMAILPONTOS}


if [ ${TOTAL_IMAGENS} -gt 0 ]
then

	ASSUNTOEMAIL="LANDSAT-8 - ${NOMESENSOR} : CONTROLAR IMAGENS DO DIA ${DATA} (${PARANO}${DIAJULIANO}) ORBITA/BASE : ${PARORBITA} (${TOTAL_IMAGENS})"


	echo "" > ${ARQEMAILCQ}
	echo "CONTROLE DE QUALIDADE" >> ${ARQEMAILCQ}
	echo "" >> ${ARQEMAILCQ}
	echo "SATELITE   : LANDSAT-8" >> ${ARQEMAILCQ}
	echo "SENSOR     : ${NOMESENSOR}" >> ${ARQEMAILCQ}
	echo "DATA       : ${DATA}" >> ${ARQEMAILCQ}
	echo "DIA JULIANO: ${PARANO}${DIAJULIANO}" >> ${ARQEMAILCQ}
	echo "ORBITA     : ${PARORBITA}" >> ${ARQEMAILCQ}

	echo "TOTAL DE IMAGENS A CONTROLAR: ${TOTAL_IMAGENS}" >> ${ARQEMAILCQ}
	echo "" >> ${ARQEMAILCQ}

	cat ${ARQEMAILPONTOS} >> ${ARQEMAILCQ}



	${CMDEMAIL} -s "${ASSUNTOEMAIL}" ${EMAILCQ} < ${ARQEMAILCQ}

fi

${CMDREMOVER}  ${ARQEMAILPONTOS}
${CMDREMOVER}  ${ARQEMAILCQ}

cd "${DIRATUAL}"

