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

IDSATELITE="CB2"
ANOMES="${ANO}_${MES}"

ORIGEML2="/L2_CBERS2/"

ORIGEM="${ORIGEML2}${ANOMES}/${PERIODO}/"
DESTINO="/QUICKLOOK/CBERS2/${SENSOR}/"

CMDGZIP='/usr/bin/gzip ' 

LARGURAMAXIMA=132
ALTURAMAXIMA=160

PERCENTUALMINIMO=1
PERCENTUALMAXIMO=300

CMDGZIP='/usr/bin/gzip ' 
PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/cbers2/'


cd ${ORIGEM}

HORAPERIODO="`echo ${PERIODO} | cut -f 2 -d '.'`"

HRA="`echo ${HORAPERIODO} | cut -f 1 -d '_'`"
MIN="`echo ${HORAPERIODO} | cut -f 2 -d '_'`"
SEG="`echo ${HORAPERIODO} | cut -f 3 -d '_'`"

HORAPERIODO="${HRA}:${MIN}:${SEG}"
DATAPERIODO="${ANO}-${MES}-${DIA}"




# Obtem listagem das coordenadas
COORDENADAS="`\ls -1`"

for COORDATUAL in ${COORDENADAS}
do

	cd ${ORIGEM}${COORDATUAL}	
	
	DIRDATUM="`\ls -1`"
	cd ${ORIGEM}${COORDATUAL}/${DIRDATUM}

	
	if [ -e "${ORIGEM}${COORDATUAL}/${DIRDATUM}/processado.lock" ]
	then				
		echo "Áea ${ORIGEM}${COORDATUAL}/${DIRDATUM} járocessada."
		echo ""
		continue
	fi
				
						
	ORBITA="`echo ${COORDATUAL} | cut -f 1 -d _`"
	PONTO="`echo ${COORDATUAL} | cut -f 2 -d _`"
	
	
	SCENEID="${IDSATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}T${HRA}${MIN}${SEG}"
	QLPADRAO="QL_${SCENEID}"


	
	
	# Verifica se as bandas estãcompactadas ou nã
	# Realizar descompactaç caso estejam compactadas
	
	
	# Composiç necessparia para criar imagem true color para os sensores
	# CCD e IRM  (3,4,2)
	IMG1ZIP="`\ls -1 *CCD1*_BAND3*.tif.zip`"
	IMG2ZIP="`\ls -1 *CCD1*_BAND4*.tif.zip`"
	IMG3ZIP="`\ls -1 *CCD1*_BAND2*.tif.zip`"
	
		
	
	# Composiç necessparia para criar imagem true color para o sensor
	# WFI  (2,2,1)
	if [ "${SENSOR}" = "WFI" ]
	then
		IMG1ZIP="`\ls -1 *WFI*_BAND1*.tif.zip`"
		IMG2ZIP="`\ls -1 *WFI*_BAND2*.tif.zip`"
		IMG3ZIP="`\ls -1 *WFI*_BAND1*.tif.zip`"
	fi
	
	
	# Composiç necessparia para criar imagem true color para o sensor
	# IRM  (3,4,2)
	if [ "${SENSOR}" = "IRM" ]
	then
		IMG1ZIP="`\ls -1 *IRM*_BAND3*.tif.zip`"
		IMG2ZIP="`\ls -1 *IRM*_BAND4*.tif.zip`"
		IMG3ZIP="`\ls -1 *IRM*_BAND2*.tif.zip`"
	fi

	
	
	
	if [ "${IMG1ZIP}" != "" ]
	then
		${CMDGZIP} -d -v -S .zip "${IMG1ZIP}"
	fi
	
	if [ "${IMG2ZIP}" != "" ]
	then
		${CMDGZIP} -d -v -S .zip "${IMG2ZIP}"
	fi
	
	if [ "${IMG3ZIP}" != "" ]
	then
		${CMDGZIP} -d -v -S .zip "${IMG3ZIP}"
	fi
	
	
	
	
	
	
	# Bandas jáescompactadas
	
	# Composiç necessparia para criar imagem true color para os sensores
	# CCD e IRM  (3,4,2)
	IMG1="`\ls -1 *CCD1*_BAND3*.tif`"
	IMG2="`\ls -1 *CCD1*_BAND4*.tif`"
	IMG3="`\ls -1 *CCD1*_BAND2*.tif`"
	
		
	
	# Composiç necessparia para criar imagem true color para o sensor
	# WFI  (2,2,1)
	if [ "${SENSOR}" = "WFI" ]
	then
		IMG1="`\ls -1 *WFI*_BAND1*.tif`"
		IMG2="`\ls -1 *WFI*_BAND2*.tif`"
		IMG3="`\ls -1 *WFI*_BAND1*.tif`"
	fi
	
	# Composiç necessparia para criar imagem true color para o sensor
	# IRM  (3,4,2)
	if [ "${SENSOR}" = "IRM" ]
	then
		IMG1="`\ls -1 *IRM*_BAND3*.tif`"
		IMG2="`\ls -1 *IRM*_BAND4*.tif`"
		IMG3="`\ls -1 *IRM*_BAND2*.tif`"
	fi
	
	
	

	NOMEPADRAO="`echo ${IMG1} | cut -f 1-7 -d _`"

	TIFFSAIDA="${ORIGEM}${COORDATUAL}/${DIRDATUM}/${NOMEPADRAO}_FULL.tif"
	TIFFSAIDAGEO="${ORIGEM}${COORDATUAL}/${DIRDATUM}/${NOMEPADRAO}_GEO.tif"                        
	
	QLSAIDAMIN="${DESTINO}${QLPADRAO}_MIN.png"
	QLSAIDAPEQ="${DESTINO}${QLPADRAO}_PEQ.png"
	QLSAIDAMED="${DESTINO}${QLPADRAO}_MED.png"
	QLSAIDAGRD="${DESTINO}${QLPADRAO}_GRD.png"

	
	
	
	rm -fv ${TIFFSAIDAGEO} 
	
	
	
	
	if [ ! -e ${TIFFSAIDAGEO} ]
	then		
		rm -fv ${TIFFSAIDA}
		echo ""

		${PATHGDAL}gdal_merge.py -o ${TIFFSAIDA}  -of GTIFF -separate ${IMG1} ${IMG2} ${IMG3}
		${PATHGDAL}gdalwarp -t_srs EPSG:4291 -multi -of GTiff -r near -order 1 ${TIFFSAIDA}  ${TIFFSAIDAGEO}		
	fi	

	RESOLUCAO="`${PATHGDAL}gdalinfo  ${TIFFSAIDAGEO} | grep -i 'Size is' | cut -c 9-22 `"
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


	${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize ${LARGURAQL} ${ALTURAQL} ${TIFFSAIDAGEO} ${QLSAIDAMIN}

	
	
	# Quicklook com resoluç pequena de pixels 
	${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize 3% 3%   ${TIFFSAIDAGEO} ${QLSAIDAPEQ}
	
	# Quicklook com resoluç media de pixels 
	${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize 5% 5%   ${TIFFSAIDAGEO} ${QLSAIDAMED}
	
	# Quicklook com resoluç grande de pixels 
	${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize 10% 10% ${TIFFSAIDAGEO} ${QLSAIDAGRD}
	
	
	cp -fv ${QLSAIDAMIN} ${ORIGEM}${COORDATUAL}/${DIRDATUM}
	cp -fv ${QLSAIDAGRD} ${ORIGEM}${COORDATUAL}/${DIRDATUM}

	cd ${ORIGEM}${COORDATUAL}/${DIRDATUM}
	
	${CMDGZIP} -v -S .zip *_BAND5*.tif
	${CMDGZIP} -v -S .zip *_BAND4*.tif
	${CMDGZIP} -v -S .zip *_BAND3*.tif
	${CMDGZIP} -f -S .zip *_BAND2*.tif
	${CMDGZIP} -f -S .zip *_BAND1*.tif


	
	#rm -f ${TIFFSAIDA} ${TIFFSAIDAGEO}
	rm -fv ${TIFFSAIDA}
	rm -fv ${DESTINO}*.xml
	
	echo ""
	echo ""
	echo ""
						
done

cd ${DIRATUAL}



