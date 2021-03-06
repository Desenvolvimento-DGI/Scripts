#!/bin/bash

DIRATUAL=$(pwd)
ORIGEM='/L4_RESOURCESAT2/'
TOTAL_IMAGENS=0

PARPERIODO="${1}"
SATELITE="${2}"
SENSOR="${3}"

PARANO="${4}"
PARMES="${5}"
PARDIA="${6}"

DATA="${PARDIA}/${PARMES}/${PARANO}"
  
PARORBITA="${7}"
NOMESENSOR="AWIFS"

FILTROANOMES="${PARANO}_${PARMES}"

CMDREMOVER='rm -fv '
CMDREMOVERARQS=""
CMDEMAIL='/usr/bin/mail '
EMAILCQ='cq-dgi@dgi.inpe.br,jose.renato@dgi.inpe.br,ivan@dgi.inpe.br,madalena@dgi.inpe.br,regina@dgi.inpe.br'


 
ARQEMAILCQ="/home/cdsr/res2/AWIFS_MSG_CQ_${PARANO}${PARMES}${PARDIA}_${PARORBITA}.log"
ARQEMAILPONTOS="/home/cdsr/res2/AWIFS_ARQUIVOS_CQ_${PARANO}${PARMES}${PARDIA}_${PARORBITA}.log"


cd ${ORIGEM}${FILTROANOMES}/${PARPERIODO}
LISTAPONTOS="`find . -name "QL_*_GRD.png" -print | grep ${PARORBITA}_ | sort`"

PONTOANTERIOR="X"

echo "" > ${ARQEMAILPONTOS}
for PONTOATUAL in ${LISTAPONTOS}
do

	PONTO="`echo ${PONTOATUAL} | cut -c 7-9`"
	QUADRANTE="`echo ${PONTOATUAL} | cut -f 3 -d '/'`" 
	SCENEID="`echo ${PONTOATUAL} | cut -f 3 -d '_'`"

	if [ "${PONTOANTERIOR}" != "${PONTO}" ]
	then
		echo "" >> ${ARQEMAILPONTOS}
	fi

	
	echo "ORBITA/BASE: ${PARORBITA}  PONTO: ${PONTO}  QUADRANTE: ${QUADRANTE}  -  SCENEID: ${SCENEID} " >> ${ARQEMAILPONTOS}	
	TOTAL_IMAGENS=$(($TOTAL_IMAGENS+1))			
		
	PONTOANTERIOR="${PONTO}"
done

echo "" >> ${ARQEMAILPONTOS}

ASSUNTOEMAIL="RESOURCESAT-2 - ${NOMESENSOR} : CONTROLAR IMAGENS DO DIA ${DATA} ORBITA/BASE : ${PARORBITA} ($TOTAL_IMAGENS)"

echo "CONTROLE DE QUALIDADE" >> ${ARQEMAILCQ}
echo "" >> ${ARQEMAILCQ}
echo "SATELITE: RESOURCESAT-2" >> ${ARQEMAILCQ}
echo "SENSOR  : ${NOMESENSOR}" >> ${ARQEMAILCQ}
echo "DATA    : ${DATA}" >> ${ARQEMAILCQ}
echo "ORBITA  : ${PARORBITA}" >> ${ARQEMAILCQ}
echo "TOTAL DE IMAGENS A CONTROLAR: ${TOTAL_IMAGENS}" >> ${ARQEMAILCQ}
echo "" >> ${ARQEMAILCQ}

cat ${ARQEMAILPONTOS} >> ${ARQEMAILCQ}

${CMDEMAIL} -s "${ASSUNTOEMAIL}" ${EMAILCQ} < ${ARQEMAILCQ}

${CMDREMOVER}  ${ARQEMAILPONTOS}
${CMDREMOVER}  ${ARQEMAILCQ}

cd "${DIRATUAL}"






