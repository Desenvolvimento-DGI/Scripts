#!/bin/bash
PATH=/bin:/sbin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH
LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH
DIRATUAL=$(pwd)
ORIGEM='/L1_LANDSAT8/L1T/'
CONTADOR=0
 
PARPERIODO="${1}"
SATELITE="${2}"
SENSOR="${3}"
PARANO="${4}"
PARMES="${5}"
#PARDIA="${6}"
PARORBITA="${6}"
FILTROANOMES="${PARANO}_${PARMES}"
DIAJULIANO="`echo ${PARPERIODO} | cut -c 17-19`"
PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/l8/'
CMDGDALWARP='${PATHGDAL}gdalwarp -t_srs EPSG:4291 -multi -of GTiff -r near -order 1 '
CMDREMOVER='/usr/bin/rm -fv '
CMDGDALINFO="${PATHGDAL}gdalinfo -proj4 "
CMDZIP='/usr/bin/gzip -f -v -S .zip '
CMDQL="${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize "
CMDREMOVERARQS=""
ARQQLMIN="_MIN.png"
ARQQLPEQ="_PEQ.png"
ARQQLMED="_MED.png"
ARQQLGRD="_GRD.png"
ARQLOGS="/home/cdsr/l8/logs/l8_oli_${PARANO}${PARMES}${DIAJULIANO}.log"
CMDMYSQL='/usr/bin/mysql --login-path=catalogo-gerente '
ARQUIVOSQLDELETE="/home/cdsr/l8/DELETEL8OLI_${PARANO}${PARMES}${DIAJULIANO}.sql"
ARQUIVOSQL="/home/cdsr/l8/INSERTL8OLI_${PARANO}${PARMES}${DIAJULIANO}.sql"
ARQUIVOSCENEL8="/home/cdsr/l8/INSERTSCENEL8OLI_${PARANO}${PARMES}${DIAJULIANO}.sql"
QLORIGEM="/QUICKLOOK/LANDSAT8/OLI/"
CMDPHP="/usr/local/web/php-5.6.1/bin/php "
AREASCRIPTS="/home/cdsr/l8/"
# Programas PHP para gerar os registros com campo Blob referente
# àgem no banco de dados
# -----------------------------------------------------------
GERABLOBTHUMB="${AREASCRIPTS}gera_blob_l8_thumb.php "
GERABLOBBROWSE="${AREASCRIPTS}gera_blob_l8_browse.php "
##
CATALOGO="2"
IDSATELITE="L"	
MISSAO="8"
ORBITA=""
PONTO=""
IDRUNMODE="NULL"
ORBIT="0"
		
CLOUDCOVERQ1="0"
CLOUDCOVERQ2="0"
CLOUDCOVERQ3="0"
CLOUDCOVERQ4="0"
CLOUDCOVERMETHOD="A"
		
IMAGEORIENTATION="0"
	
CENTERTIME="0"
STARTTIME="0"
STOPTIME="0" 
		
SYNCLOSSES="NULL"	
NUMMISSSWATH="NULL"	
PERMISSSWATH="NULL"	
BITSLIPS="NULL"
		
GRADE="0"
DELETED="0"
		
EXPORTDATE="NULL"
DATASET="NULL"
##
echo "" > ${ARQUIVOSQL}
echo "" > ${ARQUIVOSCENEL8}
echo ""  > ${ARQLOGS}
echo "" >> ${ARQLOGS}
AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} GERA DADOS LANDSAT8 :: INICIO" >> ${ARQLOGS}
# Diretónizados por ano e mes
cd ${ORIGEM}
pwd
LISTAANOMES="`\ls -1F ${ORIGEM} | grep ${FILTROANOMES} `"
echo "${LISTAANOMES}"
for AMATUAl in ${LISTAANOMES}
do
	echo ""
	echo "AMATUAl  =  ${AMATUAl}"
	pwd
	AGORA=`date +"%Y/%m/%d %H:%M:%S"`
	echo "${AGORA} ${AMATUAl} - INICIO" >> ${ARQLOGS}
	
	cd "${ORIGEM}${AMATUAl}"
	pwd
	
	echo ""
	LISTAPERIODOS="`\ls -1F | grep ${PARPERIODO}`"
	# echo "${LISTAPERIODOS}"
	
	
	for PERIODOATUAl in ${LISTAPERIODOS}
	do
	
		echo "PERIODOATUAl ==>  ${PERIODOATUAl}"
		cd "${ORIGEM}${AMATUAl}${PERIODOATUAl}"
		pwd
				
 
		#
		# Coordenadas
		
		LISTACOORDENADAS="`\ls -1F | grep -i LO8${PARORBITA}`"
		# echo "${LISTAPERIODOS}"
		
		for COORDENADAATUAL in ${LISTACOORDENADAS}
		do
		
		
			echo "" > ${ARQUIVOSQL}
			echo "" > ${ARQUIVOSCENEL8}
			
		
			echo "COORDENADAATUAL ==>  ${COORDENADAATUAL}"
			cd "${ORIGEM}${AMATUAl}${PERIODOATUAl}${COORDENADAATUAL}"
			pwd
		
			NOMEARQUIVO="`\ls -1 *_WARP.TIF`"
				
			
				
			# Caso nao exista o arquivo referente a imagem
			if [ "${NOMEARQUIVO}" == "" ]
			then	
				AGORA=`date +"%Y/%m/%d %H:%M:%S"`
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAL}- SEM ARQUIVO NA AREA" >> ${ARQLOGS}
			
				cd ..
				continue		
			fi
			
			
			if [ -e "${ORIGEM}${AMATUAl}${PERIODOATUAl}${COORDENADAATUAL}processado.lock" ]
			then				
				echo ""
				echo "Arquivo ja processado"
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAL}- ARQUIVO ${NOMEARQUIVO} JA PROCESSADO" >> ${ARQLOGS}
				echo ""
	
				cd ..
				continue
			fi
			
				
		
			echo ""
		
			
			AGORA=`date +"%Y/%m/%d %H:%M:%S"`
			echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${ARQUIVOTIF} - OK" >> ${ARQLOGS}
		
			DATA="`cat *_MTL.txt | grep DATE_ACQUIRED | cut -f 2 -d  = | cut -c 2-`"
			
			ANO="`echo ${DATA} | cut -f 1 -d '-'`"
			MES="`echo ${DATA} | cut -f 2 -d '-'`"
			DIA="`echo ${DATA} | cut -f 3 -d '-'`"
			
			
			COORDENADAATUAL="`echo ${COORDENADAATUAL} | cut -f 1 -d '/'`"
			ORBITA="`echo ${COORDENADAATUAL} | cut -c 4-6`"
			PONTO="`echo ${COORDENADAATUAL} | cut -c 7-9`"
			
			SCENEID="${SATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}"
			NOMEQLPADRAO="QL_${SCENEID}"
		
					
			CENTERLATLON="`${CMDGDALINFO} ./${NOMEARQUIVO} | grep -i 'Center' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
			TLLATLON="`${CMDGDALINFO} ./${NOMEARQUIVO} | grep -i 'Upper Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"
			TRLATLON="`${CMDGDALINFO} ./${NOMEARQUIVO} | grep -i 'Upper Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
			BRLATLON="`${CMDGDALINFO} ./${NOMEARQUIVO} | grep -i 'Lower Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
			BLLATLON="`${CMDGDALINFO} ./${NOMEARQUIVO} | grep -i 'Lower Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"
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
			
			
			IMAGEORIENTATION=""
			ORBITNO="0"
			#DATETIME="`cat *_MTL.txt | grep 'SCENE_CENTER_TIME' | cut -f 2 -d = | cut -c 2-9`"
			TIME="`cat *_MTL.txt | grep 'SCENE_CENTER_TIME' | cut -f 2 -d = | cut -c 2-9`"
			INGESTDATE="${DATA} ${TIME}"
			
			#OFFNADIRANGLE="`cat *_MTL.txt | grep -i '^IncidenceAngle=' | cut -f 2 -d '='`"	
			SUNAZIMUTH="`cat *_MTL.txt | grep 'SUN_AZIMUTH' | cut -f 2 -d '=' | cut -c 2-`"	
			SUNELEVATION="`cat *_MTL.txt | grep 'SUN_ELEVATION' | cut -f 2 -d '=' | cut -c 2-`"	
			
			
			# Latitudes e longitudes dos vées da Imagem
			IMAGEULLAT="`cat *_MTL.txt | grep CORNER_UL_LAT_PRODUCT | cut -f 2 -d '='`"	
			IMAGEULLON="`cat *_MTL.txt | grep CORNER_UL_LON_PRODUCT | cut -f 2 -d '='`"	
			IMAGEURLAT="`cat *_MTL.txt | grep CORNER_UR_LAT_PRODUCT | cut -f 2 -d '='`"	
			IMAGEURLON="`cat *_MTL.txt | grep CORNER_UR_LON_PRODUCT | cut -f 2 -d '='`"	
					
			IMAGELLLAT="`cat *_MTL.txt | grep CORNER_LL_LAT_PRODUCT | cut -f 2 -d '='`"	
			IMAGELLLON="`cat *_MTL.txt | grep CORNER_LL_LON_PRODUCT | cut -f 2 -d '='`"	
			IMAGELRLAT="`cat *_MTL.txt | grep -i CORNER_LR_LAT_PRODUCT | cut -f 2 -d '='`"	
			IMAGELRLON="`cat *_MTL.txt | grep -i CORNER_LR_LON_PRODUCT | cut -f 2 -d '='`"	
		
			# Nota da imagem 
			IMAGECLOUDCOVER="`cat *_MTL.txt | grep 'CLOUD_COVER' | cut -f 2 -d '=' | cut -c 2-`"
			NUMIMAGECLOUDCOVER="`cat *_MTL.txt | grep 'CLOUD_COVER' | cut -f 2 -d '=' | cut -c 2- | wc -l`"
			if [ ${NUMIMAGECLOUDCOVER} -gt 1 ] || [ ${NUMIMAGECLOUDCOVER} -lt 1 ]
			then
				IMAGECLOUDCOVER=0
			fi
		
			# Nota relativo ao percentual de cobertura de nuvens da imagem toda	
			IMAGEQUALITY="`cat *_MTL.txt | grep 'IMAGE_QUALITY' | cut -f 2 -d '=' | cut -c 2-`"	
			NUMIMAGEQUALITY="`cat *_MTL.txt | grep 'IMAGE_QUALITY' | cut -f 2 -d '=' | cut -c 2- | wc -l`"
			if [ ${NUMIMAGEQUALITY} -gt 1 ] 
			then
			
				IMAGEQUALITY="`cat *_MTL.txt | grep 'IMAGE_QUALITY_OLI' | cut -f 2 -d '=' | cut -c 2-`"					
				NUMIMAGEQUALITY="`cat *_MTL.txt | grep 'IMAGE_QUALITY_OLI' | cut -f 2 -d '=' | cut -c 2- | wc -l`"

				if [ ${NUMIMAGEQUALITY} -lt 1 ] 
				then
					IMAGEQUALITY=9
				fi
								
			else
		
				if [ ${NUMIMAGEQUALITY} -lt 1 ] 
				then
					IMAGEQUALITY=9
				fi
			fi
		
		
		
		
			echo ""
			echo "${PERIODOATUAl}"
			echo "${COORDENADAATUAL}"
			echo "${NOMEQLPADRAO}"
		
			echo ""
			echo "Deleta registro se o mesmo ja existir"
		
			# Deleta os registro em caso de necessidade de atualizaç de dados e controle do CQ
			#
			SQLDELETE="DELETE FROM catalogo.Scene WHERE SceneId = '${SCENEID}';"
			echo ""
			echo "SQL"
			echo "${SQLDELETE}"
			echo ""	
			
			echo "${SQLDELETE}"  > ${ARQUIVOSQLDELETE}
			${CMDMYSQL} < ${ARQUIVOSQLDELETE}
			
			
			SQLDELETE="DELETE FROM catalogo.LandsatScene WHERE SceneId = '${SCENEID}';"
			echo "${SQLDELETE}"  > ${ARQUIVOSQLDELETE}
			echo ""
			echo "SQL"
			echo "${SQLDELETE}"
			echo ""	
			
			${CMDMYSQL} < ${ARQUIVOSQLDELETE}
			
			




			echo ""
			echo "Cria o registro referente a cena processada"

			
			#
			# Valor que indica a data e horáo em que o registro foi criado
			# CRIADOEM=$(date +'%Y-%m-%d %H:%M:%S)
			# CRIADOEM=$(date +'%F %H:%M:%S)
			# CRIADOEM="`date +'%Y-%m-%d %H:%M:%S`"
			CRIADOEM="`date +'%F %H:%M:%S'`"
			
			
			
			#
			# Criaç dos registros no banco de dados
						
			SQLTABELA="INSERT INTO catalogo.Scene "
					
			SQLCAMPOS="( SceneId,	Satellite, Sensor, Date, Path, Row, Orbit, CenterLatitude, CenterLongitude," 
			SQLCAMPOS="${SQLCAMPOS} TL_Latitude, TL_Longitude, BR_Latitude, BR_Longitude, TR_Latitude, TR_Longitude, BL_Latitude, BL_Longitude," 
			SQLCAMPOS="${SQLCAMPOS} CloudCoverQ1, CloudCoverQ2, CloudCoverQ3, CloudCoverQ4, CloudCoverMethod, IngestDate, " 
			SQLCAMPOS="${SQLCAMPOS} Image_UL_Lat, Image_UL_Lon, Image_UR_Lat, Image_UR_Lon, Image_LL_Lat, Image_LL_Lon, Image_LR_Lat, Image_LR_Lon, "  
			SQLCAMPOS="${SQLCAMPOS} Area_UL_Lat, Area_UL_Lon, Area_LR_Lat, Area_LR_Lon, Area_UR_Lat, Area_UR_Lon, Area_LL_Lat, Area_LL_Lon, "  
			SQLCAMPOS="${SQLCAMPOS} Deleted, Catalogo, "
			SQLCAMPOS="${SQLCAMPOS} Image_CloudCover, Image_Quality, CriadoEm ) "
					
			SQLVALORES="VALUES ( " 
			SQLVALORES="${SQLVALORES} '${SCENEID}', '${SATELITE}', '${SENSOR}', '${DATA}', '${ORBITA}', '${PONTO}', ${ORBITNO}, ${CENTERLAT}, ${CENTERLON}, " 
			SQLVALORES="${SQLVALORES} ${TLLAT}, ${TLLON}, ${BRLAT}, ${BRLON}, ${TRLAT}, ${TRLON}, ${BLLAT}, ${BLLON}, " 
			SQLVALORES="${SQLVALORES} ${CLOUDCOVERQ1}, ${CLOUDCOVERQ2}, ${CLOUDCOVERQ3}, ${CLOUDCOVERQ4}, '${CLOUDCOVERMETHOD}', '${INGESTDATE}', " 
			SQLVALORES="${SQLVALORES} ${IMAGEULLAT}, ${IMAGEULLON}, ${IMAGEURLAT}, ${IMAGEURLON}, ${IMAGELLLAT}, ${IMAGELLLON}, ${IMAGELRLAT}, ${IMAGELRLON}, " 
			SQLVALORES="${SQLVALORES} ${TLLAT}, ${TLLON}, ${BRLAT}, ${BRLON}, ${TRLAT}, ${TRLON}, ${BLLAT}, ${BLLON}, " 
			SQLVALORES="${SQLVALORES} ${DELETED}, ${CATALOGO}, " 
			SQLVALORES="${SQLVALORES} ${IMAGECLOUDCOVER}, ${IMAGEQUALITY}, '${CRIADOEM}' );" 
					
			SQLINSERT="${SQLTABELA} ${SQLCAMPOS} ${SQLVALORES}"
			
			echo ""
			echo "SQL"
			echo "${SQLINSERT}"
			echo ""

			
			echo "${SQLINSERT}" >> ${ARQUIVOSQL}
			echo "" >> ${ARQUIVOSQL}
					
					
					
					


			echo ""
			echo "Cria registro em tabela auxiliar"

			
			DRD="${SATELITE}_${MISSAO}_${SENSOR}_${ANO}${MES}${DIA}_${ORBITA}_${PONTO}_${DIAJULIANO}_${PARPERIODO}_${COORDENADAATUAL}"
			GRALHA="${DRD}"
					
			SQLINSERTL8SCENE="INSERT INTO catalogo.LandsatScene "
			SQLINSERTL8SCENE="${SQLINSERTL8SCENE} ( SceneId, Gralha, DRD, SunAzimuth, SunElevation ) " 
			SQLINSERTL8SCENE="${SQLINSERTL8SCENE} VALUES " 
			SQLINSERTL8SCENE="${SQLINSERTL8SCENE} ( '${SCENEID}', '${GRALHA}', '${DRD}', ${SUNAZIMUTH}, ${SUNELEVATION} ) ;" 
			
			echo ""
			echo "SQL"
			echo "${SQLINSERTL8SCENE}"
			echo ""
			
			echo "${SQLINSERTL8SCENE}" >> ${ARQUIVOSCENEL8}
			echo "" >> ${ARQUIVOSCENEL8}
			${CMDMYSQL} < ${ARQUIVOSQL}
			${CMDMYSQL} < ${ARQUIVOSCENEL8}
			
			#QLTHUMB="${QLORIGEM}QL_${SCENEID}_MIN.png"
			#QLBROWSE="${QLORIGEM}QL_${SCENEID}_GRD.png"
			
			#${CMDPHP} ${GERABLOBTHUMB} ${SCENEID} ${QLTHUMB}
			#${CMDPHP} ${GERABLOBBROWSE} ${SCENEID} ${QLBROWSE}
		
			CONTADOR=$(($CONTADOR+1))		
		    
			touch ./processado.lock
			
			rm -fv ./${NOMEARQUIVO}
				
			cd ..
			echo ""
			echo "IMAGEM PROCESSADA COM SUCESSO."
			echo ""
			
			
			sleep .1
			
			exit
	
		done
		
		cd ..
	
	done
		
	cd ${ORIGEM}
	
	echo ""
	echo ""
	
	AGORA=`date +"%Y/%m/%d %H:%M:%S"`
	echo "${AGORA} ${AMATUAl} - TERMINO" >> ${ARQLOGS}
	
done
${CMDREMOVER} ${ARQUIVOSQLDELETE}
${CMDREMOVER} ${ARQUIVOSQL}
${CMDREMOVER} ${ARQUIVOSCENEL8}
AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} GERA DADOS LANDSAT8 :: TERMINO" >> ${ARQLOGS}
echo "" >> ${ARQLOGS}
cd ${DIRATUAL}
echo ""
echo "TOTAL DE REGISTROS IDENTIFICADOS = $CONTADOR"
echo ""

