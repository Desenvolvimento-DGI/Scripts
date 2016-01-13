#!/bin/bash

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH


DIRATUAL=$(pwd)
ORIGEM='/L4_RESOURCESAT2/'
CONTADOR=0
 
PARPERIODO="${1}"
SATELITE="${2}"
SENSOR="${3}"

PARANO="${4}"
PARMES="${5}"
PARDIA="${6}"

PARORBITA="${7}"

FILTROANOMES="${PARANO}_${PARMES}"

PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/res2/'

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

ARQLOGS="/home/cdsr/res2/logs/res2liss3_${PARANO}${PARMES}${PARDIA}.log"

CMDMYSQL='/usr/bin/mysql --login-path=catalogo-gerente '

ARQUIVOSQLDELETE="/home/cdsr/res2/DELETELISS3_${PARANO}${PARMES}${PARDIA}.sql"
ARQUIVOSQL="/home/cdsr/res2/INSERTRES2LISS3_${PARANO}${PARMES}${PARDIA}.sql"
ARQUIVOSCENERES2="/home/cdsr/res2/INSERTSCENERES2LISS3_${PARANO}${PARMES}${PARDIA}.sql"

QLORIGEM="/QUICKLOOK/RESOURCESAT2/LIS3/"
CMDPHP="/usr/local/web/php-5.6.1/bin/php "
AREASCRIPTS="/home/cdsr/res2/"

# Programas PHP para gerar os registros com campo Blob referente
# àmagem no banco de dados
# -----------------------------------------------------------
GERABLOBTHUMB="${AREASCRIPTS}gera_blob_res2_thumb.php "
GERABLOBBROWSE="${AREASCRIPTS}gera_blob_res2_browse.php "



##

CATALOGO="2"

IDSATELITE="RES"	
MISSAO="2"
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
echo "" > ${ARQUIVOSCENERES2}





echo ""  > ${ARQLOGS}
echo "" >> ${ARQLOGS}

AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} GERA DADOS RES2 :: INICIO" >> ${ARQLOGS}


# Diretórganizados por ano e mes
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
		
		LISTACOORDENADAS="`\ls -1F | grep -i ${PARORBITA}_`"
		# echo "${LISTAPERIODOS}"
		
		for COORDENADAATUAl in ${LISTACOORDENADAS}
		do
		
		
			echo "" > ${ARQUIVOSQL}
			echo "" > ${ARQUIVOSCENERES2}
			
		
			echo "COORDENADAATUAL ==>  ${COORDENADAATUAl}"
			cd "${ORIGEM}${AMATUAl}${PERIODOATUAl}${COORDENADAATUAl}"
			pwd
		
			NOMEARQUIVO="`\ls -1 *_GEO_8BITS.tif`"
				

			# Caso nao exista o arquivo referente a imagem
			if [ "${NOMEARQUIVO}" == "" ]
			then	

				AGORA=`date +"%Y/%m/%d %H:%M:%S"`
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- SEM ARQUIVO NA AREA" >> ${ARQLOGS}
			
				cd ..
				continue		
			fi

			
			
			if [ -e "${ORIGEM}${AMATUAl}${PERIODOATUAl}${COORDENADAATUAl}processado.lock" ]
			then				
				echo ""
				echo "Arquivo jácessado"
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO ${NOMEARQUIVO} JÁROCESSADO" >> ${ARQLOGS}
				echo ""
	
				cd ..
				continue
			fi
			
				
		
			echo ""
		
			
			AGORA=`date +"%Y/%m/%d %H:%M:%S"`
			echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${ARQUIVOTIF} - OK" >> ${ARQLOGS}
		
			PERIODOIMAGEM="`echo ${PERIODOATUAl} | cut -f 3 -d _`"
			
			ANO="`echo ${PERIODOIMAGEM} | cut -c 1-4`"
			MES="`echo ${PERIODOIMAGEM} | cut -c 5-6`"
			DIA="`echo ${PERIODOIMAGEM} | cut -c 7-8`"
			DATA="${ANO}-${MES}-${DIA}"
			#INGESTDATE="${DATA}"
			
			COORDENADAATUAl="`echo ${COORDENADAATUAl} | cut -f 1 -d '/'`"
			ORBITA="`echo ${COORDENADAATUAl} | cut -f 1 -d _`"
			PONTO="`echo ${COORDENADAATUAl} | cut -f 2 -d _`"

			
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

			
			
			IMAGEORIENTATION="`cat *_META.txt | grep -i '^IncidenceAngle=' | cut -f 2 -d '='`"
			ORBITNO="`cat *_META.txt | grep -i '^DumpingOrbitNo=' | cut -f 2 -d '='`"
			DATETIME="`cat *_META.txt | grep -i '^SceneCenterTime'`"
			TIME="`echo ${DATETIME} | cut -c 30-37`"	
			INGESTDATE="${DATA} ${TIME}"
			

			#OFFNADIRANGLE="`cat *_META.txt | grep -i '^IncidenceAngle=' | cut -f 2 -d '='`"	
			SUNAZIMUTH="`cat *_META.txt | grep -i '^SunAzimuthAtCenter' | cut -f 2 -d '='`"	
			SUNELEVATION="`cat *_META.txt | grep -i '^SunElevationAtCenter' | cut -f 2 -d '='`"	
			
			
			# Latitudes e longitudes dos véices da Imagem
			IMAGEULLAT="`cat *_META.txt | grep -i '^ImageULLat=' | cut -f 2 -d '='`"	
			IMAGEULLON="`cat *_META.txt | grep -i '^ImageULLon=' | cut -f 2 -d '='`"	

			IMAGEURLAT="`cat *_META.txt | grep -i '^ImageURLat=' | cut -f 2 -d '='`"	
			IMAGEURLON="`cat *_META.txt | grep -i '^ImageURLon=' | cut -f 2 -d '='`"	
					
			IMAGELLLAT="`cat *_META.txt | grep -i '^ImageLLLat=' | cut -f 2 -d '='`"	
			IMAGELLLON="`cat *_META.txt | grep -i '^ImageLLLon=' | cut -f 2 -d '='`"	

			IMAGELRLAT="`cat *_META.txt | grep -i '^ImageLRLat=' | cut -f 2 -d '='`"	
			IMAGELRLON="`cat *_META.txt | grep -i '^ImageLRLon=' | cut -f 2 -d '='`"	
		

					#
			# Valor que indica a data e horário em que o registro foi criado
			# CRIADOEM=$(date +'%Y-%m-%d %H:%M:%S)
			# CRIADOEM=$(date +'%F %H:%M:%S)
			# CRIADOEM="`date +'%Y-%m-%d %H:%M:%S`"

			CRIADOEM="`date +'%F %H:%M:%S'`"

			
		
			echo ""
			echo "${PERIODOATUAl}"
			echo "${NOMEQLPADRAO}"
		
		
			# Deleta os registro em caso de necessidade de atualização de dados e controle do CQ
			#
			SQLDELETE="DELETE FROM catalogo.Scene WHERE SceneId = '${SCENEID}';"
			echo "${SQLDELETE}"  > ${ARQUIVOSQLDELETE}
			${CMDMYSQL} < ${ARQUIVOSQLDELETE}
			
			
			SQLDELETE="DELETE FROM catalogo.RES2Scene WHERE SceneId = '${SCENEID}';"
			echo "${SQLDELETE}"  > ${ARQUIVOSQLDELETE}
			${CMDMYSQL} < ${ARQUIVOSQLDELETE}

			
			
						
						
			SQLTABELA="INSERT INTO catalogo.Scene "
					
			SQLCAMPOS="( SceneId,	Satellite, Sensor, Date, Path, Row, Orbit, CenterLatitude, CenterLongitude," 
			SQLCAMPOS="${SQLCAMPOS} TL_Latitude, TL_Longitude, BR_Latitude, BR_Longitude, TR_Latitude, TR_Longitude, BL_Latitude, BL_Longitude," 
			SQLCAMPOS="${SQLCAMPOS} CloudCoverQ1, CloudCoverQ2, CloudCoverQ3, CloudCoverQ4, CloudCoverMethod, IngestDate, " 
			SQLCAMPOS="${SQLCAMPOS} Image_UL_Lat, Image_UL_Lon, Image_UR_Lat, Image_UR_Lon, Image_LL_Lat, Image_LL_Lon, Image_LR_Lat, Image_LR_Lon, "  
			SQLCAMPOS="${SQLCAMPOS} Area_UL_Lat, Area_UL_Lon, Area_UR_Lat, Area_UR_Lon, Area_LR_Lat, Area_LR_Lon, Area_LL_Lat, Area_LL_Lon, " 			
			SQLCAMPOS="${SQLCAMPOS} Deleted, Catalogo, CriadoEm ) "
					
			SQLVALORES="VALUES ( " 
			SQLVALORES="${SQLVALORES} '${SCENEID}', '${SATELITE}', '${SENSOR}', '${DATA}', '${ORBITA}', '${PONTO}', ${ORBITNO}, ${CENTERLAT}, ${CENTERLON}, " 
			SQLVALORES="${SQLVALORES} ${TLLAT}, ${TLLON}, ${BRLAT}, ${BRLON}, ${TRLAT}, ${TRLON}, ${BLLAT}, ${BLLON}, " 
			SQLVALORES="${SQLVALORES} ${CLOUDCOVERQ1}, ${CLOUDCOVERQ2}, ${CLOUDCOVERQ3}, ${CLOUDCOVERQ4}, '${CLOUDCOVERMETHOD}', '${INGESTDATE}', " 
			SQLVALORES="${SQLVALORES} ${IMAGEULLAT}, ${IMAGEULLON}, ${IMAGEURLAT}, ${IMAGEURLON}, ${IMAGELLLAT}, ${IMAGELLLON}, ${IMAGELRLAT}, ${IMAGELRLON}, " 
			SQLVALORES="${SQLVALORES} ${TLLAT}, ${TLLON}, ${TRLAT}, ${TRLON}, ${BRLAT}, ${BRLON}, ${BLLAT}, ${BLLON}, " 
			SQLVALORES="${SQLVALORES} ${DELETED}, ${CATALOGO}, '${CRIADOEM}' );"
					
			SQLINSERT="${SQLTABELA} ${SQLCAMPOS} ${SQLVALORES}"
					
			echo "${SQLINSERT}" >> ${ARQUIVOSQL}
			echo "" >> ${ARQUIVOSQL}
					
					
					
					
					
			DRD="${SATELITE}_${MISSAO}_${SENSOR}_${ANO}${MES}${DIA}_${ORBITA}_${PONTO}"
			GRALHA="${DRD}"
					
			SQLINSERTRES2SCENE="INSERT INTO catalogo.RES2Scene "
			SQLINSERTRES2SCENE="${SQLINSERTRES2SCENE} ( SceneId, Gralha, DRD, SunAzimuth, SunElevation ) " 
			SQLINSERTRES2SCENE="${SQLINSERTRES2SCENE} VALUES " 
			SQLINSERTRES2SCENE="${SQLINSERTRES2SCENE} ( '${SCENEID}', '${GRALHA}', '${DRD}', ${SUNAZIMUTH}, ${SUNELEVATION} ) ;" 

			echo "${SQLINSERTRES2SCENE}" >> ${ARQUIVOSCENERES2}
			echo "" >> ${ARQUIVOSCENERES2}


			${CMDMYSQL} < ${ARQUIVOSQL}
			${CMDMYSQL} < ${ARQUIVOSCENERES2}

			QLTHUMB="${QLORIGEM}QL_${SCENEID}_MIN.png"
			QLBROWSE="${QLORIGEM}QL_${SCENEID}_GRD.png"
			
			${CMDPHP} ${GERABLOBTHUMB} ${SCENEID} ${QLTHUMB}
			${CMDPHP} ${GERABLOBBROWSE} ${SCENEID} ${QLBROWSE}
		
			CONTADOR=$(($CONTADOR+1))		
		    
			touch ./processado.lock
				
			rm -fv ${NOMEARQUIVO}
			cd ..
			echo ""
			echo "IMAGEM PROCESSADA COM SUCESSO."
			echo ""
	
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
${CMDREMOVER} ${ARQUIVOSCENERES2}

AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} GERA DADOS RES2 :: TERMINO" >> ${ARQLOGS}
echo "" >> ${ARQLOGS}

cd ${DIRATUAL}


echo ""
echo "TOTAL DE REGISTROS IDENTIFICADOS = $CONTADOR"
echo ""


