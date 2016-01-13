#!/bin/bash 

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH


DIRATUAL=$(pwd)
ORIGEM="/L4_RESOURCESAT2/"
DESTINOTMP="/home/cdsr/resourcesat2_liss3/"
DESTINOQL="/QUICKLOOK/RESOURCESAT2/LIS3/"

CMDGZIP='/usr/bin/gzip ' 
PATHGDAL='/usr/local/gdal-1.11.1/bin/'



LARGURAMAXIMA=132
ALTURAMAXIMA=160

PERCENTUALMINIMO=1
PERCENTUALMAXIMO=300


cd  ${DESTINOTMP}
rm -fv *.tif *.xml			



cd ${ORIGEM}
DIRANOMES="`\ls -1 | grep _ | grep ^20`"

for DIRANOMESATUAL in ${DIRANOMES}
do

	cd ${ORIGEM}${DIRANOMESATUAL}	
	DIRPERIODOS="`\ls -1 | grep ^RES2_LISS3_ `"
	
	
	for DIRPERIODOATUAL in ${DIRPERIODOS}
	do	
		cd ${ORIGEM}${DIRANOMESATUAL}/${DIRPERIODOATUAL}
		DIRCOORDENADAS="`\ls -1 | grep _ `"
		
		for DIRCOORDENADAATUAL in ${DIRCOORDENADAS}
		do
			
			
			cd ${ORIGEM}${DIRANOMESATUAL}/${DIRPERIODOATUAL}/${DIRCOORDENADAATUAL}
			
			cp -fv *_BAND5*.zip ${DESTINOTMP}
			cp -fv *_BAND4*.zip ${DESTINOTMP}
			cp -fv *_BAND3*.zip ${DESTINOTMP}
		
		
			cd  ${DESTINOTMP}
			${CMDGZIP} -d -v -S .zip *.zip
			
			
			IMG1="`\ls -1 *_BAND5*.tif`"
			IMG1="`\ls -1 *_BAND4*.tif`"
			IMG1="`\ls -1 *_BAND3*.tif`"
			
			SCENEID="`\ls -1 *.png | cut -f 2 -d _ | sort | uniq`"
			QLPADRAO="QL_${SCENEID}"
			
			
			TIFFSAIDA="IMG_FULL.tif"
			TIFFSAIDAGEO8BITS="IMG_FULL_8BITS.tif"
			
			${PATHGDAL}gdal_merge.py -o ${TIFFSAIDA}  -of GTIFF -separate ${IMG1} ${IMG2} ${IMG3}
			${PATHGDAL}gdal_translate -ot Byte -scale -b 1 -b 2 -b 3 ${TIFFSAIDA} ${TIFFSAIDAGEO8BITS}
			
			QLSAIDAMIN="${DESTINOQL}${QLPADRAO}_MIN.png"
			QLSAIDAPEQ="${DESTINOQL}${QLPADRAO}_PEQ.png"
			QLSAIDAMED="${DESTINOQL}${QLPADRAO}_MED.png"
			QLSAIDAGRD="${DESTINOQL}${QLPADRAO}_GRD.png"


			# Apagar os quicklooks caso existam
			if [ -e "${QLSAIDAMIN}" ]
			then
				rm -fv ${QLSAIDAMIN}
			fi
			
			if [ -e "${QLSAIDAPEQ}" ]
			then
				rm -fv ${QLSAIDAPEQ}
			fi
			
			if [ -e "${QLSAIDAMED}" ]
			then
				rm -fv ${QLSAIDAMED}
			fi
			
			if [ -e "${QLSAIDAGRD}" ]
			then
				rm -fv ${QLSAIDAGRD}
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

			
			# Quicklook com resolucaopequena de pixels 
			${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -ot Byte -outsize 3% 3% ${TIFFSAIDAGEO8BITS} ${QLSAIDAPEQ}
			
			# Quicklook com resolucaomedia de pixels 
			${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -ot Byte -outsize 6% 6% ${TIFFSAIDAGEO8BITS} ${QLSAIDAMED}
			
			# Quicklook com resolucaogrande de pixels 
			${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -ot Byte -outsize 12% 12% ${TIFFSAIDAGEO8BITS} ${QLSAIDAGRD}
			
			
			
			cp -vf ${QLSAIDAMIN}  ${ORIGEM}${DIRANOMESATUAL}/${DIRPERIODOATUAL}/${DIRCOORDENADAATUAL}
			cp -vf ${QLSAIDAGRD}  ${ORIGEM}${DIRANOMESATUAL}/${DIRPERIODOATUAL}/${DIRCOORDENADAATUAL}
			
			rm -fv ${TIFFSAIDA} ${TIFFSAIDAGEO8BITS} 
		
			cd  ${DESTINOTMP}		
			#rm -fv *.tif *.xml
			
			echo ""
			echo ""
			
			exit			
		
		done
		exit
	
	done
	exit
done

cd ${DIRATUAL}

