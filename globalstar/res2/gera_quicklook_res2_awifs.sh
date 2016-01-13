#!/bin/bash

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH



DIRATUAL=$(pwd)
PERIODO="${1}"
SATELITE="${2}"
SENSOR="${3}"

ANO="${4}"
MES="${5}"
DIA="${6}"

PARORBITA="${7}"

ANOMES="${ANO}_${MES}"

ORIGEML4="/L4_RESOURCESAT2/"
ORIGEM="${ORIGEML4}${ANOMES}/${PERIODO}/"
DESTINO="/QUICKLOOK/RESOURCESAT2/${SENSOR}/"
AREATMP="/home/cdsr/res2/AWIF${ANO}${MES}${DIA}/"
 
LARGURAMAXIMA=132
ALTURAMAXIMA=160

PERCENTUALMINIMO=1
PERCENTUALMAXIMO=300
 
COPIA="S"

CMDGZIP='/usr/bin/gzip ' 
PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/res2/'


cd ${HOMESCRIPT}

mkdir -p ${AREATMP}

cd ${ORIGEM}

COORDENADAS="`\ls -1 | grep ${PARORBITA}`"

for COORDATUAL in ${COORDENADAS}
do

	echo ""
	echo ""
	
	cd ${ORIGEM}${COORDATUAL}

	ORBITA="`echo ${COORDATUAL} | cut -f 1 -d _`"
	PONTO="`echo ${COORDATUAL} | cut -f 2 -d _`"
	
	
	
	QUADRANTES="`\ls -1`"
	for QUADRANTEATUAL in ${QUADRANTES}
	do

		cd ${ORIGEM}${COORDATUAL}/${QUADRANTEATUAL}

		SCENEID="${SATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}${QUADRANTEATUAL}"
		QLPADRAO="QL_${SCENEID}"

		
		
		IMG1="`\ls -1 *_BAND5*.tif*`"
		IMG2="`\ls -1 *_BAND4*.tif*`"
		IMG3="`\ls -1 *_BAND3*.tif*`"
		

		
		# Verifica se esta faltando alguma banda
		if [ "${IMG1}" == "" ]
		then
			pwd
			echo "BANDA 5 INEXISTENTE. IMPOSSIVEL GERAR COMPOSICAO"
		fi

		if [ "${IMG2}" == "" ]
		then
			echo "BANDA 4 INEXISTENTE. IMPOSSIVEL GERAR COMPOSICAO"
		fi

		if [ "${IMG3}" == "" ]
		then
			echo "BANDA 3 INEXISTENTE. IMPOSSIVEL GERAR COMPOSICAO"
		fi

		
		# Pula a geracao desta imagem por nao possui todas as bandas
		if [ "${IMG1}" == "" -o "${IMG2}" == "" -o "${IMG3}" == "" ]
		then
			sleep 2
			continue		
		fi
		
		
		
		NOMEPADRAO="`echo ${IMG1} | cut -f 1 -d _`"
		
		
		TIFFSAIDA="${ORIGEM}${COORDATUAL}/${QUADRANTEATUAL}/${NOMEPADRAO}_FULL.tif"
		TIFFSAIDATMP="${AREATMP}${NOMEPADRAO}_FULL.tif"
								
		TIFFSAIDAGEO8BITS="${ORIGEM}${COORDATUAL}/${QUADRANTEATUAL}/${NOMEPADRAO}_GEO_8BITS.tif"
		TIFFSAIDAGEO8BITSTMP="${AREATMP}${NOMEPADRAO}_GEO_8BITS.tif"
		
		
		
		
		QLSAIDAMIN="${DESTINO}${QLPADRAO}_MIN.png"
		QLSAIDAPEQ="${DESTINO}${QLPADRAO}_PEQ.png"
		QLSAIDAMED="${DESTINO}${QLPADRAO}_MED.png"
		QLSAIDAGRD="${DESTINO}${QLPADRAO}_GRD.png"

		echo ""
		echo ""
		
		
		
		if [ ! -e ${TIFFSAIDAGEO8BITS} ]
		then
			COPIA="S"
		
			rm -fv ${TIFFSAIDATMP} ${TIFFSAIDAGEO8BITSTMP}
						
			
			${CMDGZIP} -d -v -S .zip *_BAND5*.tif.zip
			${CMDGZIP} -d -v -S .zip *_BAND4*.tif.zip
			${CMDGZIP} -d -v -S .zip *_BAND3*.tif.zip
			echo ""
		
			
			${PATHGDAL}gdal_merge.py -o ${TIFFSAIDATMP}  -of GTIFF -separate ${IMG1} ${IMG2} ${IMG3}

			echo ""
			echo ""
			
			${PATHGDAL}gdalwarp -t_srs EPSG:4326 -multi -of GTiff -r near -order 1 ${TIFFSAIDATMP}  ${TIFFSAIDAGEO8BITSTMP}
			echo ""
			echo ""
		
		else
		
			cp -fv ${TIFFSAIDAGEO8BITS} ${AREATMP}
			COPIA="N"
		
		fi
		


		RESOLUCAO="`${PATHGDAL}gdalinfo  ${TIFFSAIDAGEO8BITSTMP} | grep -i 'Size is' | cut -c 9-22 `"
		LARGURA=$(echo ${RESOLUCAO} | cut -f 1 -d ',')
		ALTURA=$(echo ${RESOLUCAO} | cut -f 2 -d ',')
								
		
		
		
		for PERCENTUALATUAl in `seq ${PERCENTUALMINIMO} ${PERCENTUALMAXIMO}`
		do
			LARGURAQL=$((${LARGURA} * ${PERCENTUALATUAl} * 10 / 10000))
			ALTURAQL=$((${ALTURA} * ${PERCENTUALATUAl} * 10 / 10000))
	
			if [ ${LARGURAQL} -lt  ${LARGURAMAXIMA} -a ${ALTURAQL} -lt  ${ALTURAMAXIMA} ]
			then
					continue
			else
					break
			fi

		done


		${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -ot Byte -scale -outsize ${LARGURAQL} ${ALTURAQL} ${TIFFSAIDAGEO8BITSTMP} ${QLSAIDAMIN}						
		echo ""
		
		
		
		# Quicklook com resoluçequena de pixels 
		${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -ot Byte -scale -outsize 3% 3% ${TIFFSAIDAGEO8BITSTMP} ${QLSAIDAPEQ}
		echo ""
		
		
		# Quicklook com resoluçedia de pixels 
		${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -ot Byte -scale -outsize 5% 5% ${TIFFSAIDAGEO8BITSTMP} ${QLSAIDAMED}
		echo ""
		
		
		# Quicklook com resoluçrande de pixels 
		${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -ot Byte -scale -outsize 10% 10% ${TIFFSAIDAGEO8BITSTMP} ${QLSAIDAGRD}
		
		echo ""						
		echo ""
		
		cp -fv ${QLSAIDAMIN}  ${ORIGEM}${COORDATUAL}/${QUADRANTEATUAL}
		cp -fv ${QLSAIDAGRD}  ${ORIGEM}${COORDATUAL}/${QUADRANTEATUAL}
		
		if [ "${COPIA}" = "S" ]
		then						
			cp -fv ${TIFFSAIDAGEO8BITSTMP} ${ORIGEM}${COORDATUAL}/${QUADRANTEATUAL}						
		fi
		
		echo ""
		echo ""

		${CMDGZIP} -f -v -S .zip *_BAND5*.tif
		${CMDGZIP} -f -v -S .zip *_BAND4*.tif
		${CMDGZIP} -f -v -S .zip *_BAND3*.tif
		${CMDGZIP} -f -v -S .zip *_BAND2*.tif

		echo ""
		echo ""
		

		
		
		rm -f ${TIFFSAIDATMP} ${TIFFSAIDAGEO8BITSTMP}
		
		echo ""
		echo ""
		echo ""
						
	done
						
done

cd ${DIRATUAL}
rm -frv ${AREATMP}


