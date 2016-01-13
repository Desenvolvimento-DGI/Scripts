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

CMDGZIP='/usr/bin/gzip ' 

LARGURAMAXIMA=132
ALTURAMAXIMA=160

PERCENTUALMINIMO=1
PERCENTUALMAXIMO=300

CMDGZIP='/usr/bin/gzip ' 
PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/res2/'


cd ${HOMESCRIPT}
 

cd ${ORIGEM}

COORDENADAS="`\ls -1 | grep -i ${PARORBITA}`"

for COORDATUAL in ${COORDENADAS}
do

	cd ${ORIGEM}${COORDATUAL}

	ORBITA="`echo ${COORDATUAL} | cut -f 1 -d _`"
	PONTO="`echo ${COORDATUAL} | cut -f 2 -d _`"
	
	
	SCENEID="${SATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}"
	QLPADRAO="QL_${SCENEID}"
	
	${CMDGZIP} -d -v -S .zip *_BAND5*.tif.zip
	${CMDGZIP} -d -v -S .zip *_BAND4*.tif.zip
	${CMDGZIP} -d -v -S .zip *_BAND3*.tif.zip
				

	IMG1="*_BAND5*.tif"
	IMG2="*_BAND4*.tif"
	IMG3="*_BAND3*.tif"
				
	NOMEPADRAO="`echo ${IMG1} | cut -f 1 -d _`"

	TIFFSAIDA="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_FULL.tif"
	TIFFSAIDAGEO="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_GEO.tif"                        
	TIFFSAIDAGEO8BITS="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_GEO_8BITS.tif"
	
	QLSAIDAMIN="${DESTINO}${QLPADRAO}_MIN.png"
	QLSAIDAPEQ="${DESTINO}${QLPADRAO}_PEQ.png"
	QLSAIDAMED="${DESTINO}${QLPADRAO}_MED.png"
	QLSAIDAGRD="${DESTINO}${QLPADRAO}_GRD.png"


	echo ""
	echo ""
	
	
	
	if [ ! -e ${TIFFSAIDAGEO8BITS} ]
	then

		
		rm -fv ${TIFFSAIDA}
		
		${CMDGZIP} -d -v -S .zip *_BAND5*.tif.zip
		${CMDGZIP} -d -v -S .zip *_BAND4*.tif.zip
		${CMDGZIP} -d -v -S .zip *_BAND3*.tif.zip
		echo ""

		${PATHGDAL}gdal_merge.py -o ${TIFFSAIDA}  -of GTIFF -separate ${IMG1} ${IMG2} ${IMG3}
		${PATHGDAL}gdalwarp -t_srs EPSG:4326 -multi -of GTiff -r near -order 1 ${TIFFSAIDA}  ${TIFFSAIDAGEO}
		${PATHGDAL}gdal_translate -ot Byte -scale -b 1 -b 2 -b 3 ${TIFFSAIDAGEO} ${TIFFSAIDAGEO8BITS}
	
	fi	

	RESOLUCAO="`${PATHGDAL}gdalinfo  ${TIFFSAIDAGEO8BITS} | grep -i 'Size is' | cut -c 9-22 `"
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


	${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -ot Byte -outsize ${LARGURAQL} ${ALTURAQL} ${TIFFSAIDAGEO8BITS} ${QLSAIDAMIN}

	
	
	# Quicklook com resoluçequena de pixels 
	${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -ot Byte -outsize 3% 3% ${TIFFSAIDAGEO8BITS} ${QLSAIDAPEQ}
	
	# Quicklook com resoluçedia de pixels 
	${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -ot Byte -outsize 5% 5% ${TIFFSAIDAGEO8BITS} ${QLSAIDAMED}
	
	# Quicklook com resoluçrande de pixels 
	${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -ot Byte -outsize 10% 10% ${TIFFSAIDAGEO8BITS} ${QLSAIDAGRD}
	
	
	cp -fv ${QLSAIDAMIN} ${ORIGEM}${COORDATUAL}
	cp -fv ${QLSAIDAGRD} ${ORIGEM}${COORDATUAL}

	${CMDGZIP} -v -S .zip *_BAND5*.tif
	${CMDGZIP} -v -S .zip *_BAND4*.tif
	${CMDGZIP} -v -S .zip *_BAND3*.tif
	${CMDGZIP} -f -S .zip *_BAND2*.tif


	
	#rm -f ${TIFFSAIDA} ${TIFFSAIDAGEO}
	rm -f ${TIFFSAIDA} ${TIFFSAIDAGEO}
	
	echo ""
	echo ""
	echo ""
						
done

cd ${DIRATUAL}



