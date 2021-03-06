#!/bin/bash 

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH



DIRATUAL=$(pwd)
PERIODO="LO82280570842015153CUB00"
SATELITE="L8"
SENSOR="OLI"
 
ANO="2015"
MES="06"
DIA="18"

PARORBITA="228"



ORIGEML1="/L1_LANDSAT8/L1T/"
DESTINO="/QUICKLOOK/LANDSAT8/${SENSOR}/"

CMDGZIP='/usr/bin/gzip ' 

LARGURAMAXIMA=132
ALTURAMAXIMA=160

PERCENTUALMINIMO=1
PERCENTUALMAXIMO=300

CMDGZIP='/usr/bin/gzip ' 
PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/l8/'
cd ${HOMESCRIPT}
 

 
 cd ${ORIGEML1}
 LISTAANOMES="`\ls -1r | grep 2015_06 | grep _`"
 
 for ANOMES in ${LISTAANOMES}
 do
 
	cd ${ORIGEML1}${ANOMES}
	LISTAPERIODOS="`\ls -1 | grep ^L `"
	
	for PERIODO in ${LISTAPERIODOS}
	do
	
		ORIGEM="${ORIGEML1}${ANOMES}/${PERIODO}/"
		cd ${ORIGEM}
		
		
		COORDENADAS="`\ls -1 | grep -i ^L`"

		for COORDATUAL in ${COORDENADAS}
		do

				cd ${ORIGEM}${COORDATUAL}

				ORBITA="`echo ${COORDATUAL} | cut -c 4-6`"
				PONTO="`echo ${COORDATUAL} | cut -c 7-9`"

				DATA="`cat *_MTL.txt | grep DATE_ACQUIRED | cut -f 2 -d  = | cut -c 2-`"

				ANO="`echo ${DATA} | cut -f 1 -d '-'`"
				MES="`echo ${DATA} | cut -f 2 -d '-'`"
				DIA="`echo ${DATA} | cut -f 3 -d '-'`"


				SCENEID="${SATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}"
				QLPADRAO="QL_${SCENEID}"

				${CMDGZIP} -f -d -v -S .zip *_B6.TIF.zip
				${CMDGZIP} -f -d -v -S .zip *_B5.TIF.zip
				${CMDGZIP} -f -d -v -S .zip *_B4.TIF.zip

				IMG1="`\ls -1 L*_B6.TIF`"
				IMG2="`\ls -1 L*_B5.TIF`"
				IMG3="`\ls -1 L*_B4.TIF`"

				NOMEPADRAO="`echo ${IMG1} | cut -f 1 -d _`"


				TIFFSAIDA="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_FULL.tif"
				TIFFSAIDA8BITS="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_8BITS.tif"   
				TIFFSAIDA8BITSGEO="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_8BITS_GEO.tif"   
				
				TIFFSAIDA8BITSPC="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_8BITS_PC.tif"                        
				TIFFSAIDA8BITSPCPNG="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_8BITS_PC.png"                        
				PNGMODELO="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_MODELO.png"
				

				QLSAIDAMIN="${DESTINO}${QLPADRAO}_MIN.png"
				QLSAIDAPEQ="${DESTINO}${QLPADRAO}_PEQ.png"
				QLSAIDAMED="${DESTINO}${QLPADRAO}_MED.png"
				QLSAIDAGRD="${DESTINO}${QLPADRAO}_GRD.png"

				echo ""
				echo ""


				rm -fv ${TIFFSAIDA8BITS}  ${TIFFSAIDA} ${TIFFSAIDA8BITSGEO}
				rm -fv ${TIFFSAIDA8BITSPC} ${TIFFSAIDA8BITSPCPNG} ${PNGMODELO} 
				



				${CMDGZIP} -f -d -v -S .zip *_B6.TIF.zip
				${CMDGZIP} -f -d -v -S .zip *_B5.TIF.zip
				${CMDGZIP} -f -d -v -S .zip *_B4.TIF.zip
				echo ""

				${PATHGDAL}gdal_merge.py -of GTIFF -o ${TIFFSAIDA} -separate ${IMG1} ${IMG2} ${IMG3}
						
				${PATHGDAL}gdal_translate -of GTIFF -ot Byte -scale ${TIFFSAIDA} ${TIFFSAIDA8BITS}
				
				${PATHGDAL}gdalwarp -of GTIFF -t_srs EPSG:4326 ${TIFFSAIDA8BITS} ${TIFFSAIDA8BITSGEO}
						
				${PATHGDAL}gdal_translate -of GTIFF -outsize 30% 30%  ${TIFFSAIDA8BITSGEO}   ${TIFFSAIDA8BITSPC}
						
				${PATHGDAL}gdal_translate -of PNG  ${TIFFSAIDA8BITSPC}  ${TIFFSAIDA8BITSPCPNG}
						
				convert -brightness-contrast 10x40  ${TIFFSAIDA8BITSPCPNG}   ${PNGMODELO}
						
						

						
				RESOLUCAO="`${PATHGDAL}gdalinfo  ${TIFFSAIDA8BITSGEO} | grep -i 'Size is' | cut -c 9-22 `"
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


				if [ -e "${QLSAIDAMIN}" ]
				then
						rm -fv "${QLSAIDAMIN}*"
				fi

				if [ -e "${QLSAIDAPEQ}" ]
				then
						rm -fv "${QLSAIDAPEQ}*"
				fi

				if [ -e "${QLSAIDAMED}" ]
				then
						rm -fv "${QLSAIDAMED}*" 
				fi

				if [ -e "${QLSAIDAGRD}" ]
				then
						rm -fv "${QLSAIDAGRD}*"
				fi

				echo ""

				${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize ${LARGURAQL} ${ALTURAQL} ${PNGMODELO} ${QLSAIDAMIN}

				# Quicklook com resoluçequena de pixels 
				${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize 10% 10% ${PNGMODELO} ${QLSAIDAPEQ}

				# Quicklook com resoluçedia de pixels 
				${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize 20% 20% ${PNGMODELO} ${QLSAIDAMED}

				# Quicklook com resoluçrande de pixels 
				${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize 30% 30% ${PNGMODELO} ${QLSAIDAGRD}


				rm -fv "${QLSAIDAMIN}*.xml"
				rm -fv "${QLSAIDAPEQ}*.xml"
				rm -fv "${QLSAIDAMED}*.xml"
				rm -fv "${QLSAIDAGRD}*.xml"



				cp -fv ${QLSAIDAMIN} ${ORIGEM}${COORDATUAL}
				cp -fv ${QLSAIDAGRD} ${ORIGEM}${COORDATUAL}

				


				${CMDGZIP} -f -v -S .zip *_B4*.TIF
				${CMDGZIP} -f -v -S .zip *_B5*.TIF
				${CMDGZIP} -f -v -S .zip *_B6*.TIF


				
				rm -fv ${TIFFSAIDA8BITS}  ${TIFFSAIDA} ${TIFFSAIDA8BITSGEO}
				rm -fv ${TIFFSAIDA8BITSPC} ${TIFFSAIDA8BITSPCPNG} ${PNGMODELO} 
				

				echo ""
				echo ""
				echo ""

		done
	done
	
done	


cd ${DIRATUAL}
		
