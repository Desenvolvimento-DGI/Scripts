#!/bin/bash -x

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


HORANAOFMTD="`echo ${PERIODO} | cut -f 2 -d '.'`"

HRA="`echo ${HORANAOFMTD} | cut -f 1 -d '_'`"
MIN="`echo ${HORANAOFMTD} | cut -f 2 -d '_'`"
SEG="`echo ${HORANAOFMTD} | cut -f 3 -d '_'`"


HORAPERIODO="${HRA}:${MIN}:${SEG}"
DATAPERIODO="${ANO}-${MES}-${DIA}"



ANOMES="${ANO}_${MES}"

ORIGEML2="/L2_CBERS2/"

ORIGEM="${ORIGEML2}${ANOMES}/${PERIODO}/"
DESTINO="/QUICKLOOK/CBERS2/${SENSOR}/"

CMDGZIP='/usr/bin/gzip ' 
CMDMYSQL='/usr/bin/mysql --login-path=catalogo-gerente '
CMDGDALINFO="${PATHGDAL}gdalinfo -proj4 "


ARQUIVOSQL="/home/cdsr/cbers2/INSERT_${SATELITE}_${SENSOR}_${PARANO}${PARMES}${PARDIA}.sql"
ARQUIVOSCENECBERS2="/home/cdsr/cbers2/INSERTSCENE_${SATELITE}_${SENSOR}_${PARANO}${PARMES}${PARDIA}.sql"

CMDGZIP='/usr/bin/gzip ' 
PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/cbers2/'



# Valores padronizados

CATALOGO="3"
	
IDSATELITE="CB2"	
MISSAO="2"
ORBITA=""
PONTO=""
IDRUNMODE="NULL"
ORBIT="0"
		
CLOUDCOVERQ1="0"
CLOUDCOVERQ2="0"
CLOUDCOVERQ3="0"
CLOUDCOVERQ4="0"
CLOUDCOVERMETHOD="M"
		
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

QUADRANTE="NULL"
CONTROLADOCQ="S"

# 





cd ${ORIGEM}



# Obtem listagem das coordenadas
COORDENADAS="`\ls -1`"

for COORDATUAL in ${COORDENADAS}
do

	echo "" > ${ARQUIVOSQL}
	echo "" > ${ARQUIVOSCENECBERS2}
	

	cd ${ORIGEM}${COORDATUAL}	
	
	DIRDATUM="`\ls -1`"
	cd ${ORIGEM}${COORDATUAL}/${DIRDATUM}

	
	if [ -e "${ORIGEM}${COORDATUAL}/${DIRDATUM}/processado.lock" ]
	then				
		echo "Áea ${ORIGEM}${COORDATUAL}/${DIRDATUM} járocessada."
		echo ""
		continue
	fi
		
	NOMEARQUIVO="`\ls -1 *_GEO.tif`"
					
	# Caso nao exista o arquivo referente a imagem
	if [ "${NOMEARQUIVO}" == "" ]
	then	
		echo "Nãexiste imagem composta. Necessario executar o processo para"
		echo "gerar a imagem composta antes deste processo."
		continue		
	fi	
	
	ARQUIVOXML="`\ls -1 *.xml | sort | head -1`"
	# Caso nao exista nenhum arquivo XML referente a imagem
	if [ "${ARQUIVOXML}" == "" ]
	then	
		echo "Nãexiste arquivo XML para obter dados"
		continue		
	fi	
	
	
	CAMINHOAQRXML="${ORIGEM}${COORDATUAL}/${DIRDATUM}/${ARQUIVOXML}"
	
	
						
	ORBITA="`echo ${COORDATUAL} | cut -f 1 -d _`"
	PONTO="`echo ${COORDATUAL} | cut -f 2 -d _`"		
	SCENEID="${IDSATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}T${HRA}${MIN}${SEG}"
				
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

	
	DRD="${SATELITE}_${MISSAO}_${SENSOR}_${ANO}${MES}${DIA}_${ORBITA}_${PONTO}_${HRA}${MIN}${SEG}"
	GRALHA="${DRD}"	
	
	
	IOGRAUS="`cat ${CAMINHOAQRXML} | sed -n -e '/<orientationAngle>/,/<\/orientationAngle>/p' |  grep -i '<degree>'  | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
	IOMIN="`cat ${CAMINHOAQRXML} | sed -n -e '/<orientationAngle>/,/<\/orientationAngle>/p' |  grep -i '<minute>'  | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
	IOSEG="`cat ${CAMINHOAQRXML} | sed -n -e '/<orientationAngle>/,/<\/orientationAngle>/p' |  grep -i '<second>'  | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
	IOMILISEG="`cat ${CAMINHOAQRXML} | sed -n -e '/<orientationAngle>/,/<\/orientationAngle>/p' |  grep -i '<millisecond>'  | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
	
	
	NUMIOMIN=$((IOMIN * 100 / 60))
	NUMIOSEG=$((IOSEG * 100 / 60))
	NUMIOMILISEG=$((IOMILISEG * 1))

	TXTIOMIN="${NUMIOMIN}"
	TXTIOSEG="${NUMIOSEG}"
	TXTMILISEG="`echo ${IOMILISEG} | cut -c 1-1`"

	
	
	if [ ${NUMIOMIN} -lt 10 ]
	then
			TXTIOMIN="0${NUMIOMIN}"
	fi
	
	if [ ${NUMIOSEG} -lt 10 ]
	then
			TXTIOSEG="0${NUMIOSEG}"
	fi
	
	if [ ${NUMIOMILISEG} -lt 100 ]
	then
			TXTMILISEG="0${NUMIOMILISEG}"
	fi
	
	IMAGEORIENTATION="${IOGRAUS}.${TXTIOMIN}${TXTIOSEG}${TXTMILISEG}"
	
	
	
	ORBITNO="`cat  ${CAMINHOAQRXML} | grep -i '<revolutionNumber>' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
	

	OFFNADIRANGLE="`cat ${CAMINHOAQRXML} | grep -i '<offNadirAngle>' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"	
	SUNAZIMUTH="`cat ${CAMINHOAQRXML} | sed -n -e '/<sunPosition>/,/<\/sunPosition>/p' |  grep -i 'sunAzimuth'  | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
	SUNELEVATION="`cat ${CAMINHOAQRXML} | sed -n -e '/<sunPosition>/,/<\/sunPosition>/p' |  grep -i 'elevation'  | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
	
	CENTERTIMERECEPTION="`cat ${CAMINHOAQRXML} | sed -n -e '/<reception>/,/<\/reception>/p' |  grep -i '<center>'  | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
	CENTERTIME="`echo ${CENTERTIMERECEPTION} | cut -f 2 -d 'T' | cut -f 1 -d '.'`"
	
	INGESTDATE="${DATAPERIODO} ${CENTERTIME}"	
	
	# Latitudes e longitudes dos véices da Imagem
	IMAGEULLAT="`cat  ${CAMINHOAQRXML} | sed -n -e '/<image>/,/<\/image>/p' |  sed -n -e '/<imageData>/,/<\/imageData>/p' |   sed -n -e '/<UL>/,/<\/UL>/p' |   grep -i 'latitude' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"	
	IMAGEULLON="`cat  ${CAMINHOAQRXML} | sed -n -e '/<image>/,/<\/image>/p' |  sed -n -e '/<imageData>/,/<\/imageData>/p' |   sed -n -e '/<UL>/,/<\/UL>/p' |   grep -i 'longitude' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"	

	
	IMAGEURLAT="`cat  ${CAMINHOAQRXML} | sed -n -e '/<image>/,/<\/image>/p' |  sed -n -e '/<imageData>/,/<\/imageData>/p' |   sed -n -e '/<UR>/,/<\/UR>/p' |   grep -i 'latitude' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"	
	IMAGEURLON="`cat  ${CAMINHOAQRXML} | sed -n -e '/<image>/,/<\/image>/p' |  sed -n -e '/<imageData>/,/<\/imageData>/p' |   sed -n -e '/<UR>/,/<\/UR>/p' |   grep -i 'longitude' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"	
	
	
	
	IMAGELLLAT="`cat  ${CAMINHOAQRXML} | sed -n -e '/<image>/,/<\/image>/p' |  sed -n -e '/<imageData>/,/<\/imageData>/p' |   sed -n -e '/<LL>/,/<\/LL>/p' |   grep -i 'latitude' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"		
	IMAGELLLON="`cat  ${CAMINHOAQRXML} | sed -n -e '/<image>/,/<\/image>/p' |  sed -n -e '/<imageData>/,/<\/imageData>/p' |   sed -n -e '/<LL>/,/<\/LL>/p' |   grep -i 'longitude' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"	

	
	IMAGELRLAT="`cat  ${CAMINHOAQRXML} | sed -n -e '/<image>/,/<\/image>/p' |  sed -n -e '/<imageData>/,/<\/imageData>/p' |   sed -n -e '/<LR>/,/<\/LR>/p' |   grep -i 'latitude' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
	IMAGELRLON="`cat  ${CAMINHOAQRXML} | sed -n -e '/<image>/,/<\/image>/p' |  sed -n -e '/<imageData>/,/<\/imageData>/p' |   sed -n -e '/<LR>/,/<\/LR>/p' |   grep -i 'longitude' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"



	
	SQLTABELA="INSERT INTO catalogo.Scene "
	
	SQLCAMPOS="( SceneId,	Satellite, Sensor, Date, Path, Row, Orbit, CenterLatitude, CenterLongitude," 
	SQLCAMPOS="${SQLCAMPOS} TL_Latitude, TL_Longitude, BR_Latitude, BR_Longitude, TR_Latitude, TR_Longitude, BL_Latitude, BL_Longitude, ImageOrientation, " 
	SQLCAMPOS="${SQLCAMPOS} CloudCoverQ1, CloudCoverQ2, CloudCoverQ3, CloudCoverQ4, CloudCoverMethod, IngestDate, " 
	SQLCAMPOS="${SQLCAMPOS} Image_UL_Lat, Image_UL_Lon, Image_UR_Lat, Image_UR_Lon, Image_LL_Lat, Image_LL_Lon, Image_LR_Lat, Image_LR_Lon, " 
	SQLCAMPOS="${SQLCAMPOS} Deleted, Catalogo, ControladoCQ ) "
		
	SQLVALORES="VALUES ( " 
	SQLVALORES="${SQLVALORES} '${SCENEID}', '${IDSATELITE}', '${SENSOR}', '${DATAPERIODO}', '${ORBITA}', '${PONTO}', ${ORBITNO}, ${CENTERLAT}, ${CENTERLON}, " 
	SQLVALORES="${SQLVALORES} ${TLLAT}, ${TLLON}, ${BRLAT}, ${BRLON}, ${TRLAT}, ${TRLON}, ${BLLAT}, ${BLLON}, ${IMAGEORIENTATION}, " 
	SQLVALORES="${SQLVALORES} ${CLOUDCOVERQ1}, ${CLOUDCOVERQ2}, ${CLOUDCOVERQ3}, ${CLOUDCOVERQ4}, '${CLOUDCOVERMETHOD}', '${INGESTDATE}', " 
	SQLVALORES="${SQLVALORES} ${IMAGEULLAT}, ${IMAGEULLON}, ${IMAGEURLAT}, ${IMAGEURLON}, ${IMAGELLLAT}, ${IMAGELLLON}, ${IMAGELRLAT}, ${IMAGELRLON}, "
	SQLVALORES="${SQLVALORES} ${DELETED}, ${CATALOGO}, '${CONTROLADOCQ}' );"
			
	SQLINSERT="${SQLTABELA} ${SQLCAMPOS} ${SQLVALORES}"
			
	echo "${SQLINSERT}" >> ${ARQUIVOSQL}
	echo "" >> ${ARQUIVOSQL}
			
						
						
						
	DRD="CBERS_${MISSAO}_${SENSOR}_${ANO}${MES}${DIA}_${ORBITA}_${PONTO}_${HRA}${MIN}${SEG}"
	GRALHA="${DRD}"
											
						
	SQLINSERTCBERS2SCENE="INSERT INTO catalogo.CbersScene "
	SQLINSERTCBERS2SCENE="${SQLINSERTCBERS2SCENE} ( SceneId, Gralha, DRD, SunAzimuth, SunElevation, OffNadirAngle ) " 
	SQLINSERTCBERS2SCENE="${SQLINSERTCBERS2SCENE} VALUES " 
	SQLINSERTCBERS2SCENE="${SQLINSERTCBERS2SCENE} ( '${SCENEID}', '${GRALHA}', '${DRD}', ${SUNAZIMUTH}, ${SUNELEVATION}, ${OFFNADIRANGLE} ) ;" 

	echo "${SQLINSERTCBERS2SCENE}" >> ${ARQUIVOSCENECBERS2}
	echo "" >> ${ARQUIVOSCENECBERS2}


	${CMDMYSQL} < ${ARQUIVOSQL}
	${CMDMYSQL} < ${ARQUIVOSCENECBERS2}

	
	CONTADOR=$(($CONTADOR+1))	

	
	touch ${ORIGEM}${COORDATUAL}/${DIRDATUM}/processado.lock
	
	echo ""
	echo "Imagem processada."

done

cd ${DIRATUAL}


