#!/bin/bash 
PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH
LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH
DIRATUAL=$(pwd)
SATELITE="L8"
SENSOR="OLI"
 
ANO="${1}"
MES="${2}"
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
NUMPID="$$"
DESTINOLOCAL="${HOMESCRIPT}${NUMPID}"
cd ${ORIGEML1}
LISTAANOMES="`\ls -1r | grep ${ANO}_${MES} `"
 
 
for ANOMES in ${LISTAANOMES}
do
 
	cd ${ORIGEML1}${ANOMES}
	LISTAPERIODOS="`\ls -1 | grep ^LO8 `"
	
	for PERIODO in ${LISTAPERIODOS}
	do
	
		ORIGEM="${ORIGEML1}${ANOMES}/${PERIODO}/"
		cd ${ORIGEM}
		
		
		COORDENADAS="`\ls -1 | grep -i ^LO8`"
		for COORDATUAL in ${COORDENADAS}
		do
		
				clear
				echo ""
				cd ${ORIGEM}${COORDATUAL}
				
				echo "PROCESSANDO  `pwd`"
				echo ""
				mkdir -p ${DESTINOLOCAL}
				
				
				ORBITA="`echo ${COORDATUAL} | cut -c 4-6`"
				PONTO="`echo ${COORDATUAL} | cut -c 7-9`"
				DATA="`cat *_MTL.txt | grep DATE_ACQUIRED | cut -f 2 -d  = | cut -c 2-`"
				ANO="`echo ${DATA} | cut -f 1 -d '-'`"
				MES="`echo ${DATA} | cut -f 2 -d '-'`"
				DIA="`echo ${DATA} | cut -f 3 -d '-'`"
				SCENEID="${SATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}"
				QLPADRAO="QL_${SCENEID}"
				WLDPADRAO="WF_${SCENEID}.wld"
				
				
				cp -fv *_B6.TIF.zip  ${DESTINOLOCAL}
				cd ${DESTINOLOCAL}
				
				
				${CMDGZIP} -f -d -v -S .zip *_B6.TIF.zip
				IMG1="`\ls -1 L*_B6.TIF`"
				NOMEPADRAO="`echo ${IMG1} | cut -f 1 -d _`"				
				TIFFSAIDAGEO="${DESTINOLOCAL}/${NOMEPADRAO}_GEO.tif"   
				
				PNGGRD="${DESTINOLOCAL}/${NOMEPADRAO}_GRD.png"
				ARQWLDNOVO="${DESTINO}${WLDPADRAO}"				
				
				echo ""
				echo "Convertendo sistemas de coordenadas para WGS84 (EPSG 4326) ..."
				${PATHGDAL}gdalwarp -of GTIFF -t_srs EPSG:4326 ${IMG1} ${TIFFSAIDAGEO}
						
				echo ""
				echo "Gerando arquivo WLD ..."
				${PATHGDAL}gdal_translate -of PNG -co WORLDFILE=YES -outsize 12% 12%  ${TIFFSAIDAGEO} ${PNGGRD}
				
				
				ARQWLDATUAL="`ls -1 *.wld`"
				
				cp -fv ${ARQWLDATUAL}  ${ARQWLDNOVO}
				
				cd ${HOMESCRIPT}
				rm -frv ${DESTINOLOCAL}
				
		done
	done
	
done	
cd ${DIRATUAL}
		

