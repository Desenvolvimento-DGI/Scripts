#!/bin/bash

# Grar os Quick Look para as imagens do satelite RAPIDEYE
# -------------------------------------------------------

DIRATUAL=$(pwd)
ORIGEM='/home/cdsr/rapideye/browse/'
DESTINO='/QUICKLOOK/'
CONTADOR=0

SATELITE='RE1'
SENSOR='REIS'

CMDGDALINFO="gdalinfo -proj4 "
CMDQL="gdal_translate -of PNG -co "WORLDFILE=YES" -outsize "

ARQQLMIN="_MIN.png"
ARQQLPEQ="_PEQ.png"
ARQQLMED="_MED.png"


ARQLOGS="/home/cdsr/rapideye/quicklook.log"


echo ""  > ${ARQLOGS}
echo "" >> ${ARQLOGS}

AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} GERA QUICKLOOK RAPIDEYE :: INICIO" >> ${ARQLOGS}


# Diretós organizados regiao
cd ${ORIGEM}
pwd

LISTAREGIOES="`\ls -1F ${ORIGEM} | grep '/' | sort`"

echo "${LISTAREGIOES}"

for REGIAOATUAl in ${LISTAREGIOES}
do

	echo ""
	echo "REGIAOATUAl  =  ${REGIAOATUAl}"
	pwd


	AGORA=`date +"%Y/%m/%d %H:%M:%S"`
	echo "${AGORA} ${REGIAOATUAl} - INICIO" >> ${ARQLOGS}

	
	cd "./${REGIAOATUAl}"
	pwd
	
	echo ""
	LISTAARQUIVOS="`\ls -1F *_browse.tif`"
	# echo "${LISTAARQUIVOS}"
	
	
	
	for ARQUIVOATUAl in ${LISTAARQUIVOS}
	do
	
		echo "ARQUIVOATUAl ==>  ${ARQUIVOATUAl}"		
		

		AGORA=`date +"%Y/%m/%d %H:%M:%S"`
		echo "${AGORA} ${REGIAOATUAl} - ${ARQUIVOATUAl} - OK" >> ${ARQLOGS}
		
		ORBITA="`echo ${ARQUIVOATUAl} | cut -c 3-5`"
		PONTO="`echo ${ARQUIVOATUAl} | cut -c 6-7`"
		DATAFIM="`echo ${ARQUIVOATUAl} | cut -c 47-52`"	
		INDEFINIDO="`echo ${ARQUIVOATUAl} | cut -c 38-45`"		
		
		SATELITE="`echo ${ARQUIVOATUAl} | cut -c 27-29`"		
		ANO="`echo ${ARQUIVOATUAl} | cut -c 9-12`"
		MES="`echo ${ARQUIVOATUAl} | cut -c 14-15`"
		DIA="`echo ${ARQUIVOATUAl} | cut -c 17-18`"
		HRA="`echo ${ARQUIVOATUAl} | cut -c 20-21`"
		MIN="`echo ${ARQUIVOATUAl} | cut -c 22-23`"
		SEG="`echo ${ARQUIVOATUAl} | cut -c 24-25`"
		
		NOMEQLPADRAO="QL_${SATELITE}${SENSOR}${ANO}${MES}${DIA}T${HRA}${MIN}${SEG}P${ORBITA}R${PONTO}T${DATAFIM}"
				
				
		echo ""
		echo "${ARQUIVOATUAl}"
		echo "${NOMEQLPADRAO}"
		
		RESOLUCAO="`gdalinfo -proj4 ./${ARQUIVOATUAl} | grep -i 'Size is' | cut -c 9- `"
		LARGURA=$(echo ${RESOLUCAO} | cut -f 1 -d ',')
		ALTURA=$(echo ${RESOLUCAO} | cut -f 2 -d ',')
		
		# Quicklook com resoluç minima de pixels (3% da resolucao original)
		LARGURAQL=$(($LARGURA / 100 * 30))
		ALTURAQL=$(($ALTURA / 100 * 30))
		ARQFINAL="${NOMEQLPADRAO}${ARQQLMIN}"		
		
		if [ ! -e "${DESTINO}${ARQFINAL}" ]
		then		
			${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQUIVOATUAl}"  "${DESTINO}${SATELITE}/${SENSOR}/${ARQFINAL}"
		fi

				
		# Quicklook com resoluç pequena de pixels (5% da resolucao original)
		LARGURAQL=$(($LARGURA / 100 * 50))
		ALTURAQL=$(($ALTURA / 100 * 50))		
		ARQFINAL="${NOMEQLPADRAO}${ARQQLPEQ}"
		
		if [ ! -e "${DESTINO}${ARQFINAL}" ]
		then		
			${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQUIVOATUAl}"  "${DESTINO}${SATELITE}/${SENSOR}/${ARQFINAL}"
		fi

		
		
		# Quicklook com resoluç media de pixels (10% da resolucao original)
		LARGURAQL=$LARGURA
		ALTURAQL=$ALTURA		
		ARQFINAL="${NOMEQLPADRAO}${ARQQLMED}"
		
		if [ ! -e "${DESTINO}${ARQFINAL}" ]
		then		
			${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQUIVOATUAl}"  "${DESTINO}${SATELITE}/${SENSOR}/${ARQFINAL}"
		fi


		
		CONTADOR=$(($CONTADOR+1))
		
		echo ""
	
	done
	
	
	cd ${ORIGEM}
	
	echo ""
	echo ""
	
	AGORA=`date +"%Y/%m/%d %H:%M:%S"`
	echo "${AGORA} ${AMATUAl} - TERMINO" >> ${ARQLOGS}
	

done

chmod 777 ${DESTINO}RE1/QL_*
chmod 777 ${DESTINO}RE2/QL_*
chmod 777 ${DESTINO}RE3/QL_*
chmod 777 ${DESTINO}RE4/QL_*
chmod 777 ${DESTINO}RE5/QL_*
		


AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} GERA QUICKLOOK RAPIDEYE :: TERMINO" >> ${ARQLOGS}
echo "" >> ${ARQLOGS}

cd ${DIRATUAL}


echo ""
echo "TOTAL DE REGISTROS IDENTIFICADOS = $CONTADOR"
echo ""




