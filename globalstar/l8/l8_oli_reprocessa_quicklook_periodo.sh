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
PARPERIODO="${3}"

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
 LISTAANOMES="`\ls -1r | grep ${ANO}_${MES} `"
 
 for ANOMES in ${LISTAANOMES}
 do
 
	cd ${ORIGEML1}${ANOMES}
	LISTAPERIODOS="`\ls -1 | grep -i ${PARPERIODO} `"
	
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

				ORBITA="`echo ${COORDATUAL} | cut -c 4-6`"
				PONTO="`echo ${COORDATUAL} | cut -c 7-9`"

				DATA="`cat *_MTL.txt | grep DATE_ACQUIRED | cut -f 2 -d  = | cut -c 2-`"

				ANO="`echo ${DATA} | cut -f 1 -d '-'`"
				MES="`echo ${DATA} | cut -f 2 -d '-'`"
				DIA="`echo ${DATA} | cut -f 3 -d '-'`"


				SCENEID="${SATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}"
				QLPADRAO="QL_${SCENEID}"

				
				echo ""
				echo "Descompactando arquivos referentes as bandas 6, 5 e 4 ..."

				
				${CMDGZIP} -f -d -v -S .zip *_B6.TIF.zip
				${CMDGZIP} -f -d -v -S .zip *_B5.TIF.zip
				${CMDGZIP} -f -d -v -S .zip *_B4.TIF.zip

				IMG1="`\ls -1 L*_B6.TIF`"
				IMG2="`\ls -1 L*_B5.TIF`"
				IMG3="`\ls -1 L*_B4.TIF`"

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
				echo "Removendo arquivos temporarios ..."

				rm -fv ${TIFFSAIDA} ${TIFFCORRIGIDO} ${PNGTRANSPARENTEBC}
				rm -fv ${PNGTRANSPARENTE} ${PNGMODELO} ${B1GEO} ${B2GEO} ${B3GEO}
								

				echo ""
				
				
				echo ""
				echo "Convertendo sistemas de coordenadas para WGS84 (EPSG 4326) ..."
				${PATHGDAL}gdalwarp -of GTIFF -t_srs EPSG:4326 ${IMG1} ${B1GEO}
				${PATHGDAL}gdalwarp -of GTIFF -t_srs EPSG:4326 ${IMG2} ${B2GEO}
				${PATHGDAL}gdalwarp -of GTIFF -t_srs EPSG:4326 ${IMG3} ${B3GEO}
				
				

				echo ""
				echo "Gerando imagem composta com as bandas 6, 5 e 4 ..."				
				convert -combine  ${B1GEO} ${B2GEO} ${B3GEO}  ${TIFFSAIDA}
						
				
				echo ""
				echo "Aplicando efeito linear para correç de cores da imagem ..."
				convert -auto-level ${TIFFSAIDA}  ${TIFFCORRIGIDO}
				
				
				echo ""
				echo "Convertendo imagem para o formato PNG e com transparencia ..."
				${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -b 1 -b 2 -b 3  ${TIFFCORRIGIDO} ${PNGTRANSPARENTE}
					

					
				echo ""
				echo "Aplicando efeito de brilho e contraste para ajuste de cores da imagem ..."
				convert -brightness-contrast 25x15 ${PNGTRANSPARENTE}  ${PNGTRANSPARENTEBC}
					
					
				echo ""
				echo "Gerando imagem temporáa com dimensãs de 40% da imagem composta ..."
				${PATHGDAL}gdal_translate -of GTIFF -outsize 40% 40%  ${PNGTRANSPARENTEBC}  ${PNGMODELO}
				

				

				
				RESOLUCAO="`${PATHGDAL}gdalinfo  ${B1GEO} | grep -i 'Size is' | cut -c 9-22 `"
				LARGURA=$(echo ${RESOLUCAO} | cut -f 1 -d ',')
				ALTURA=$(echo ${RESOLUCAO} | cut -f 2 -d ',')

				

				echo ""
				echo "Gerando os quicklooks ..."

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

				echo ""

				${PATHGDAL}gdal_translate -of PNG -outsize ${LARGURAQL} ${ALTURAQL} ${PNGMODELO} ${QLSAIDAMIN}

				# Quicklook com resoluçequena de pixels 
				${PATHGDAL}gdal_translate -of PNG -outsize 8% 8% ${PNGMODELO} ${QLSAIDAPEQ}

				# Quicklook com resoluçedia de pixels 
				${PATHGDAL}gdal_translate -of PNG -outsize 15% 15% ${PNGMODELO} ${QLSAIDAMED}

				# Quicklook com resoluçrande de pixels 
				${PATHGDAL}gdal_translate -of PNG -outsize 30% 30% ${PNGMODELO} ${QLSAIDAGRD}



				echo ""
				echo "Copiando quicklooks gerados para a áa container de todoas os quicklooks ..."

				cp -fv ${QLSAIDAMIN} ${ORIGEM}${COORDATUAL}
				cp -fv ${QLSAIDAGRD} ${ORIGEM}${COORDATUAL}

				
				echo ""
				echo "Removendo arquivos temporarios ..."
				
				rm -fv "${QLSAIDAMIN}*.xml"
				rm -fv "${QLSAIDAPEQ}*.xml"
				rm -fv "${QLSAIDAMED}*.xml"
				rm -fv "${QLSAIDAGRD}*.xml"
				
				rm -fv *.aux.xml
				rm -fv ${TIFFSAIDA} ${TIFFCORRIGIDO} ${PNGTRANSPARENTEBC}
				rm -fv ${PNGTRANSPARENTE} ${PNGMODELO} ${B1GEO} ${B2GEO} ${B3GEO}
							

							
				echo ""
				echo "Compactando as bandas 6, 5 e 4 em formato ZIP ..."

				${CMDGZIP} -f -v -S .zip *_B4*.TIF
				${CMDGZIP} -f -v -S .zip *_B5*.TIF
				${CMDGZIP} -f -v -S .zip *_B6*.TIF


				
		done
	done
	
done	


cd ${DIRATUAL}
		

