#!/bin/bash 

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH



DIRATUAL=$(pwd)
SATELITE="RES2"
SENSOR="LIS3"
 
ANO="${1}"
MES="${2}"

ANOMES="${ANO}_${MES}"
ORIGEML4="/L4_RESOURCESAT2/"
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
 


LISTAPERIODOS="`\ls -1 | grep -i RES2_LISS3_`"
for PERIODOATUAL in ${LISTAPERIODOS}
do

	ORIGEM="${ORIGEML4}${ANOMES}/${PERIODOATUAL}/"
	cd ${ORIGEM}
		
	# Obte do dia referente ao periodo atual
	DIA="`echo ${PERIODOATUAL} | cut -f 3 -d _ | cut -c 7-8`"


	COORDENADAS="`\ls -1 | grep _`"

	for COORDATUAL in ${COORDENADAS}
	do

		clear
		
		cd ${ORIGEM}${COORDATUAL}	
		pwd
		

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
		
		B1GEO="`echo ${IMG1} | cut -f 1 -d .`_GEO.TIF"
		B2GEO="`echo ${IMG2} | cut -f 1 -d .`_GEO.TIF"
		B3GEO="`echo ${IMG3} | cut -f 1 -d .`_GEO.TIF"
		

		TIFFSAIDA="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_FULL.tif"	
		TIFFCORRIGIDO="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_CORRIGIDO.tif"
					
		PNGTRANSPARENTE="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_CORRIGIDO_TRANSPARENTE.png"                        
		PNGTRANSPARENTEBC="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}CORRIGIDO_TRANSPARENTE_BC.png"
		PNGMODELO="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_MODELO.png"
		
		QLSAIDAMIN="${DESTINO}${QLPADRAO}_MIN.png"
		QLSAIDAPEQ="${DESTINO}${QLPADRAO}_PEQ.png"
		QLSAIDAMED="${DESTINO}${QLPADRAO}_MED.png"
		QLSAIDAGRD="${DESTINO}${QLPADRAO}_GRD.png"


		echo ""
		echo ""
			
			
		rm -fv ${TIFFSAIDA} ${TIFFCORRIGIDO} ${PNGTRANSPARENTE} ${PNGTRANSPARENTEBC} ${PNGMODELO} 
		rm -fv ${B1GEO} ${B2GEO} ${B3GEO}
		
			
		${CMDGZIP} -d -v -S .zip *_BAND5*.tif.zip
		${CMDGZIP} -d -v -S .zip *_BAND4*.tif.zip
		${CMDGZIP} -d -v -S .zip *_BAND3*.tif.zip
		
		echo ""
		echo ""
		
		echo "Convertendo sistemas de coordenadas para WGS84 (EPSG 4326) ..."
		${PATHGDAL}gdalwarp -of GTIFF -t_srs EPSG:4326 ${IMG1} ${B1GEO}
		${PATHGDAL}gdalwarp -of GTIFF -t_srs EPSG:4326 ${IMG2} ${B2GEO}
		${PATHGDAL}gdalwarp -of GTIFF -t_srs EPSG:4326 ${IMG3} ${B3GEO}
		
		

		echo ""
		echo "Gerando imagem composta com as bandas 6, 5 e 4 ..."				
		convert -verbose -combine  ${B1GEO} ${B2GEO} ${B3GEO}  ${TIFFSAIDA}
				
		
		echo ""
		echo "Aplicando efeito linear para correção de cores da imagem ..."
		convert -verbose -auto-level ${TIFFSAIDA}  ${TIFFCORRIGIDO}
		
		
		echo ""
		echo "Convertendo imagem para o formato PNG e com transparencia ..."
		${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -b 1 -b 2 -b 3  ${TIFFCORRIGIDO} ${PNGTRANSPARENTE}
			

			
		echo ""
		echo "Aplicando efeito de brilho e contraste para ajuste de cores da imagem ..."
		convert -verbose -brightness-contrast 25x15 ${PNGTRANSPARENTE}  ${PNGTRANSPARENTEBC}
			
			
		echo ""
		echo "Gerando imagem temporária com dimensãoes de 40% da imagem composta ..."
		${PATHGDAL}gdal_translate -of GTIFF -outsize 20% 20%  ${PNGTRANSPARENTEBC}  ${PNGMODELO}
		


		if [ -f "${QLSAIDAMIN}" ]
		then
				rm -fv "${QLSAIDAMIN}*"
		fi

		if [ -f "${QLSAIDAPEQ}" ]
		then
				rm -fv "${QLSAIDAPEQ}*"
		fi

		if [ -f "${QLSAIDAMED}" ]
		then
				rm -fv "${QLSAIDAMED}*" 
		fi

		if [ -f "${QLSAIDAGRD}" ]
		then
				rm -fv "${QLSAIDAGRD}*"
		fi


					

		RESOLUCAO="`${PATHGDAL}gdalinfo  ${IMG1} | grep -i 'Size is' | cut -c 9-22 `"
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
		
		${PATHGDAL}gdal_translate -of PNG -outsize ${LARGURAQL} ${ALTURAQL} ${PNGMODELO} ${QLSAIDAMIN}	
		
		# Quicklook com resoluçequena de pixels 
		${PATHGDAL}gdal_translate -of PNG -outsize 15% 15% ${PNGMODELO} ${QLSAIDAPEQ}
		
		# Quicklook com resoluçedia de pixels 
		${PATHGDAL}gdal_translate -of PNG -outsize 25% 25% ${PNGMODELO} ${QLSAIDAMED}
		
		# Quicklook com resoluçrande de pixels 
		${PATHGDAL}gdal_translate -of PNG -outsize 50% 50% ${PNGMODELO} ${QLSAIDAGRD}
		
		
		
		cp -fv ${QLSAIDAMIN} ${ORIGEM}${COORDATUAL}
		cp -fv ${QLSAIDAGRD} ${ORIGEM}${COORDATUAL}
		

		${CMDGZIP} -v -S .zip *_BAND5*.tif
		${CMDGZIP} -v -S .zip *_BAND4*.tif
		${CMDGZIP} -v -S .zip *_BAND3*.tif
		${CMDGZIP} -f -S .zip *_BAND2*.tif


		
		rm -fv ${TIFFSAIDA} ${TIFFCORRIGIDO} ${PNGTRANSPARENTE} ${PNGTRANSPARENTEBC} ${PNGMODELO} 
		rm -fv ${B1GEO} ${B2GEO} ${B3GEO}
		
		echo ""
		echo ""
		echo ""
							
	done
	# COORDENADA ATUAL
	
done
# PERIDO ATUAL	

cd ${DIRATUAL}



