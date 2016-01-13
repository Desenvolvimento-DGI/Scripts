#!/bin/bash 

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH



DIRATUAL=$(pwd)
SATELITE="RES2"
SENSOR="LIS3"

ORIGEML4="/L4_RESOURCESAT2/"

NUMPPID="$$"
DESTINO="/QUICKLOOK/RESOURCESAT2/${SENSOR}/"
DESTINOQL="${DESTINO}"

CMDGZIP='/usr/bin/gzip ' 

LARGURAMAXIMA=132
ALTURAMAXIMA=160

PERCENTUALMINIMO=1
PERCENTUALMAXIMO=300

CMDGZIP='/usr/bin/gzip ' 
PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/res2/'
CMDGDALINFO="${PATHGDAL}gdalinfo -proj4 "



CMDMYSQL='/usr/bin/mysql --login-path=catalogo-gerente '
ARQUIVOSQL="/home/cdsr/res2/UPDATERES2LISS3_${NUMPPID}.sql"
ARQUIVOSCENERES2="/home/cdsr/res2/UPDATESCENERES2LISS3_${NUMPPID}.sql"


QLORIGEM="/QUICKLOOK/RESOURCESAT2/LIS3/"

cd ${HOMESCRIPT}
 

cd ${ORIGEML4}


LISTAANOMES="`\ls -1r | grep ^2015_06 | grep _`"
for AMATUAL in ${LISTAANOMES}
do

	cd ${ORIGEML4}${AMATUAL}

	LISTAPERIODOS="`\ls -1r | grep ^RES2_LISS3_20150616`"
	for PERIODO in ${LISTAPERIODOS}
	do
		
		ORIGEM="${ORIGEML4}${AMATUAL}/${PERIODO}/"
		cd ${ORIGEM}
		
		COORDENADAS="`\ls -1r | grep _`"
		
		for COORDATUAL in ${COORDENADAS}
		do
		
			clear
			echo "" > ${ARQUIVOSQL}
			cd ${ORIGEM}${COORDATUAL}

			ORBITA="`echo ${COORDATUAL} | cut -f 1 -d _`"
			PONTO="`echo ${COORDATUAL} | cut -f 2 -d _`"
			
			ANO="`echo ${AMATUAL} | cut -f 1 -d _`"
			MES="`echo ${AMATUAL} | cut -f 2 -d _`"
			
			DIA="`echo ${PERIODO} | cut -f 3 -d _ | cut -c 7-8`"
			
			echo "SATELITE     =  RESOURCESAT-2 (RES2)"
			echo "SENSOR       =  LISS-3"
			echo "AREA ATUAL   =  ${ORIGEM}${COORDATUAL}"
			echo "ANO/MES/DIA  =  ${ANO}/${MES}/${DIA}"
			echo "ORBITA/PONTO =  ${ORBITA}/${PONTO}"
			echo ""
			echo ""
			
			
			
			
			SCENEID="${SATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}"
			QLPADRAO="QL_${SCENEID}"
			

			echo "Descompactando bandas..."

			${CMDGZIP} -d -v -S .zip *_BAND5*.tif.zip
			${CMDGZIP} -d -v -S .zip *_BAND4*.tif.zip
			${CMDGZIP} -d -v -S .zip *_BAND3*.tif.zip
						

			IMG1="*_BAND5*.tif"
			IMG2="*_BAND4*.tif"
			IMG3="*_BAND3*.tif"
						
			NOMEPADRAO="`echo ${IMG1} | cut -f 1 -d _`"
			TIFFSAIDA="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_FULL.tif"
			TIFFSAIDA8BITS="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_FULL_8BITS.tif"
			
			QLSAIDAMIN="${DESTINOQL}${QLPADRAO}_MIN.png"
			QLSAIDAPEQ="${DESTINOQL}${QLPADRAO}_PEQ.png"
			QLSAIDAMED="${DESTINOQL}${QLPADRAO}_MED.png"
			QLSAIDAGRD="${DESTINOQL}${QLPADRAO}_GRD.png"
			QLSAIDAGGT="${DESTINOQL}${QLPADRAO}_GGT.png"

			TMPQLSAIDAMIN="${DESTINOQL}${QLPADRAO}_MIN_TMP.png"
			TMPQLSAIDAPEQ="${DESTINOQL}${QLPADRAO}_PEQ_TMP.png"
			TMPQLSAIDAMED="${DESTINOQL}${QLPADRAO}_MED_TMP.png"
			TMPQLSAIDAGRD="${DESTINOQL}${QLPADRAO}_GRD_TMP.png"

			
			PERCENTUAL_GRD='20%' 
			PERCENTUAL_MED='30%'  
			PERCENTUAL_PEQ='20%'
			
			BANDAGEO1="${ORIGEM}${COORDATUAL}/BANDA_5_GEO.tif"
			BANDAGEO2="${ORIGEM}${COORDATUAL}/BANDA_4_GEO.tif"
			BANDAGEO3="${ORIGEM}${COORDATUAL}/BANDA_3_GEO.tif"
			
			BANDAGEOPC1="${ORIGEM}${COORDATUAL}/BANDA_5_GEO_PC.tif"
			BANDAGEOPC2="${ORIGEM}${COORDATUAL}/BANDA_4_GEO_PC.tif"
			BANDAGEOPC3="${ORIGEM}${COORDATUAL}/BANDA_3_GEO_PC.tif"
			
			
			
			echo ""
			echo "Removendo arquivos temporáos..."
			
			rm -fv ${TIFFSAIDA} ${TIFFSAIDA8BITS}
			rm -fv ${BANDAGEO1} ${BANDAGEO2} ${BANDAGEO3} 
			rm -fv ${BANDAGEOPC1} ${BANDAGEOPC2} ${BANDAGEOPC3} 
			rm -fv ${TMPQLSAIDAMIN} ${TMPQLSAIDAPEQ} ${TMPQLSAIDAMED} ${TMPQLSAIDAGRD}		
			rm -fv ${QLSAIDAMIN} ${QLSAIDAPEQ} ${QLSAIDAMED} ${QLSAIDAGRD} ${QLSAIDAGGT}
				

			echo ""
			echo "Processando imagem :: Convertendo sistemas de coordenadas para WGS84 (EPSG 4326) ..."
			
			
			${PATHGDAL}gdalwarp -t_srs EPSG:4326 -multi -of GTiff -r near -order 1 ${IMG1}  ${BANDAGEO1}
			${PATHGDAL}gdalwarp -t_srs EPSG:4326 -multi -of GTiff -r near -order 1 ${IMG2}  ${BANDAGEO2}
			${PATHGDAL}gdalwarp -t_srs EPSG:4326 -multi -of GTiff -r near -order 1 ${IMG3}  ${BANDAGEO3}
			

			echo ""
			echo "Processando imagem :: Redimensionando imagens ..."
			
			${PATHGDAL}gdal_translate -of GTIFF -outsize ${PERCENTUAL_GRD} ${PERCENTUAL_GRD}  ${BANDAGEO1} ${BANDAGEOPC1}
			${PATHGDAL}gdal_translate -of GTIFF -outsize ${PERCENTUAL_GRD} ${PERCENTUAL_GRD}  ${BANDAGEO2} ${BANDAGEOPC2}
			${PATHGDAL}gdal_translate -of GTIFF -outsize ${PERCENTUAL_GRD} ${PERCENTUAL_GRD}  ${BANDAGEO3} ${BANDAGEOPC3}
			
						
			echo ""
			echo "Processando imagem :: Gerando composicao ..."
			
			${PATHGDAL}gdal_merge.py -o ${TIFFSAIDA}  -of GTIFF -separate ${BANDAGEOPC1} ${BANDAGEOPC2} ${BANDAGEOPC3}

			
			
			echo ""
			echo "Processando imagem :: Convertendo imagem para 8 bits ..."
			
			${PATHGDAL}gdal_translate -of GTIFF -ot Byte -scale ${TIFFSAIDA} ${TIFFSAIDA8BITS}
			
			
			

			echo ""
			echo "Processando imagem :: Gerando quicklooks ..."
			
			RESOLUCAO="`${PATHGDAL}gdalinfo  ${BANDAGEO1} | grep -i 'Size is' | cut -c 9-22 `"
			LARGURA=$(echo ${RESOLUCAO} | cut -f 1 -d ',')
			ALTURA=$(echo ${RESOLUCAO} | cut -f 2 -d ',')
			
			
			
			# Quicklook com resolucao enorme de pixels 
			rm -f ${QLSAIDAGRD} ${QLSAIDAGGT}
			${PATHGDAL}gdal_translate -of PNG -a_nodata 0 ${TIFFSAIDA8BITS} ${QLSAIDAGGT}
			
			
			
			# Quicklook com resolucao grande de pixels 
			rm -f ${QLSAIDAGRD} ${TMPQLSAIDAGRD}
			${PATHGDAL}gdal_translate -of PNG -outsize 60% 60% ${QLSAIDAGGT} ${TMPQLSAIDAGRD}
			
			# Quicklook com resolucao media de pixels 
			rm -f ${QLSAIDAMED} ${TMPQLSAIDAMED}
			${PATHGDAL}gdal_translate -of PNG -outsize ${PERCENTUAL_MED} ${PERCENTUAL_MED}  ${QLSAIDAGGT} ${TMPQLSAIDAMED}
						
			
			# Quicklook com resolucao pequena de pixels 
			rm -f ${QLSAIDAPEQ} ${TMPQLSAIDAPEQ}
			${PATHGDAL}gdal_translate -of PNG -outsize ${PERCENTUAL_PEQ} ${PERCENTUAL_PEQ}  ${QLSAIDAGGT} ${TMPQLSAIDAPEQ}
			
			
			
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
			
			
			# Quicklook com resolucao minima de pixels 
			rm -f ${QLSAIDAMIN} ${TMPQLSAIDAMIN}
			${PATHGDAL}gdal_translate -of PNG -outsize ${LARGURAQL} ${ALTURAQL} ${QLSAIDAGGT} ${TMPQLSAIDAMIN}

							

			echo ""
			echo "Melhorando brilho e contraste das cores..."
			
			convert -brightness-contrast 10x25  ${TMPQLSAIDAMIN} ${QLSAIDAMIN}
			convert -brightness-contrast 10x25  ${TMPQLSAIDAPEQ} ${QLSAIDAPEQ}
			convert -brightness-contrast 10x25  ${TMPQLSAIDAMED} ${QLSAIDAMED}
			convert -brightness-contrast 10x25  ${TMPQLSAIDAGRD} ${QLSAIDAGRD}
			
			
			echo ""
			echo "Copiando quicklooks de tamanhos minico e maximo..."
			
			cp -fv ${QLSAIDAMIN} ${ORIGEM}${COORDATUAL}
			cp -fv ${QLSAIDAGRD} ${ORIGEM}${COORDATUAL}
			
			
			
			echo ""
			echo "Atualizando o registro da imagem..."
			
			CENTERLATLON="`${CMDGDALINFO} ${BANDAGEO1} | grep -i 'Center' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
			TLLATLON="`${CMDGDALINFO} ${BANDAGEO1} | grep -i 'Upper Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"
			TRLATLON="`${CMDGDALINFO} ${BANDAGEO1} | grep -i 'Upper Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
			BRLATLON="`${CMDGDALINFO} ${BANDAGEO1} | grep -i 'Lower Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
			BLLATLON="`${CMDGDALINFO} ${BANDAGEO1} | grep -i 'Lower Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"

			CENTERLON="`echo ${CENTERLATLON} | cut -f 1 -d ','`"
			CENTERLAT="`echo ${CENTERLATLON} | cut -f 2 -d ','`"

			TLLON="`echo ${TLLATLON} | cut -f 1 -d ','`"
			TLLAT="`echo ${TLLATLON} | cut -f 2 -d ','`"

			TRLON="`echo ${TRLATLON} | cut -f 1 -d ','`"		
			TRLAT="`echo ${TRLATLON} | cut -f 2 -d ','`"

			BLLON="`echo ${BLLATLON} | cut -f 1 -d ','`"
			BLLAT="`echo ${BLLATLON} | cut -f 2 -d ','`"

			BRLON="`echo ${BRLATLON} | cut -f 1 -d ','`"
			BRLAT="`echo ${BRLATLON} | cut -f 2 -d ','`"

					
								
								
			SQLTABELA="UPDATE catalogo.Scene "
					
			SQLCAMPOS="SET Area_UL_Lat = ${TLLAT}, Area_UL_Lon = ${TLLON}, Area_UR_Lat = ${TRLAT}, Area_UR_Lon = ${TRLON}, "
			SQLCAMPOS="${SQLCAMPOS} Area_LR_Lat = ${BRLAT}, Area_LR_Lon = ${BRLON}, Area_LL_Lat = ${BLLAT}, Area_LL_Lon = ${BLLON}, " 			
			SQLCAMPOS="${SQLCAMPOS} CenterLatitude = ${CENTERLAT}, CenterLongitude = ${CENTERLON} " 			
					
			SQLWHERE=" WHERE SceneId = '${SCENEID}' ; " 
					
			SQLUPDATE="${SQLTABELA} ${SQLCAMPOS} ${SQLWHERE}"
					
			echo "${SQLUPDATE}" >> ${ARQUIVOSQL}
			echo "" >> ${ARQUIVOSQL}
					
			cat ${ARQUIVOSQL}
			${CMDMYSQL} < ${ARQUIVOSQL}
			

			
			echo ""
			echo "Removendo arquivos temporarios..."			

			rm -fv ${TIFFSAIDA} ${QLSAIDAGGT} ${TIFFSAIDA8BITS}
			rm -fv ${BANDAGEO1} ${BANDAGEO2} ${BANDAGEO3} 
			rm -fv ${BANDAGEOPC1} ${BANDAGEOPC2} ${BANDAGEOPC3} 
			rm -fv ${TMPQLSAIDAMIN} ${TMPQLSAIDAPEQ} ${TMPQLSAIDAMED} ${TMPQLSAIDAGRD}		
			
			

			
			echo ""
			echo "Compactando bandas..."

			${CMDGZIP} -v -S .zip *_BAND5*.tif
			${CMDGZIP} -v -S .zip *_BAND4*.tif
			${CMDGZIP} -v -S .zip *_BAND3*.tif
			${CMDGZIP} -f -S .zip *_BAND2*.tif
						
								
		done
	done
	
done	

cd ${DIRATUAL}



