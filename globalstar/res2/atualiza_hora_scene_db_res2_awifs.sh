#!/bin/bash

ORIGEM='/L4_RESOURCESAT2/'


cd ${ORIGEM}
ANOMESDIRS="`ls -1 | grep -i 201 | sort`"

for ANOMESATUAL in ${ANOMESDIRS}
do

	cd  ${ORIGEM}${ANOMESATUAL}
	PERIODODIRS="`ls -1 | grep '^RES2_AWIF' | sort`"
	
	for PERIODOATUAL in ${PERIODODIRS}
	do
	
	
		cd  ${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}
		ORBITAPONTODIRS="`ls -1 | grep _ | sort`"
	
		for ORBITAPONTOATUAL in ${ORBITAPONTODIRS}
		do

			cd  ${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}/${ORBITAPONTOATUAL}		
			QUADRANTES="`ls -1 | sort`"
			
			for QUADRANTEATUAL in ${QUADRANTES}
			do
			
				if [ -e "${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}/${ORBITAPONTOATUAL}/${QUADRANTEATUAL}" ]
				then
				
					cd  ${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}/${ORBITAPONTOATUAL}/${QUADRANTEATUAL}
					
					IMAGEORIENTATION="`cat *_META.txt | grep -i '^IncidenceAngle=' | cut -f 2 -d '='`"
					ORBITNO="`cat *_META.txt | grep -i '^DumpingOrbitNo=' | cut -f 2 -d '='`"
					DATETIME="`cat *_META.txt | grep -i '^SceneCenterTime'`"
					
					#OFFNADIRANGLE="`cat *_META.txt | grep -i '^IncidenceAngle=' | cut -f 2 -d '='`"	
					SUNAZIMUTH="`cat *_META.txt | grep -i '^SunAzimuthAtCenter' | cut -f 2 -d '='`"	
					SUNELEVATION="`cat *_META.txt | grep -i '^SunElevationAtCenter' | cut -f 2 -d '='`"	
					
					
					# Latitudes e longitudes dos véices do Produto
					#PRODULLAT="`cat *_META.txt | grep -i '^ProdULLat=' | cut -f 2 -d '='`"	
					#PRODULLON="`cat *_META.txt | grep -i '^ProdULLon=' | cut -f 2 -d '='`"	

					#PRODURLAT="`cat *_META.txt | grep -i '^ProdURLat=' | cut -f 2 -d '='`"	
					#PRODURLON="`cat *_META.txt | grep -i '^ProdURLon=' | cut -f 2 -d '='`"	
					
					#PRODLLLAT="`cat *_META.txt | grep -i '^ProdLLLat=' | cut -f 2 -d '='`"	
					#PRODLLLON="`cat *_META.txt | grep -i '^ProdLLLon=' | cut -f 2 -d '='`"	

					#PRODLRLAT="`cat *_META.txt | grep -i '^ProdLRLat=' | cut -f 2 -d '='`"	
					#PRODLRLON="`cat *_META.txt | grep -i '^ProdLRLon=' | cut -f 2 -d '='`"	



					# Latitudes e longitudes dos véices da Imagem
					IMAGEULLAT="`cat *_META.txt | grep -i '^ImageULLat=' | cut -f 2 -d '='`"	
					IMAGEULLON="`cat *_META.txt | grep -i '^ImageULLon=' | cut -f 2 -d '='`"	

					IMAGEURLAT="`cat *_META.txt | grep -i '^ImageURLat=' | cut -f 2 -d '='`"	
					IMAGEURLON="`cat *_META.txt | grep -i '^ImageURLon=' | cut -f 2 -d '='`"	
					
					IMAGELLLAT="`cat *_META.txt | grep -i '^ImageLLLat=' | cut -f 2 -d '='`"	
					IMAGELLLON="`cat *_META.txt | grep -i '^ImageLLLon=' | cut -f 2 -d '='`"	

					IMAGELRLAT="`cat *_META.txt | grep -i '^ImageLRLat=' | cut -f 2 -d '='`"	
					IMAGELRLON="`cat *_META.txt | grep -i '^ImageLRLon=' | cut -f 2 -d '='`"	

					
					
					TIME="`echo ${DATETIME} | cut -c 30-37`"					
					SCENEID="`\ls -1 QL_RES2*.png | cut -f 2 -d _ | sort | uniq`"
					
					CMDMYSQL='/usr/bin/mysql --login-path=catalogo-gerente '
					ARQUIVOSQL="/home/cdsr/res2/UPDATE_RES2AWIFS_${SCENEID}.sql"

					CENTERTIME=""
					STARTTIME=""
					STOPTIME="" 
					
					DATAPERIODO="`echo ${PERIODOATUAL} | cut -f 3 -d _`"
					
					ANO="`echo ${DATAPERIODO} | cut -c1-4`"
					MES="`echo ${DATAPERIODO} | cut -c5-6`"
					DIA="`echo ${DATAPERIODO} | cut -c7-8`"
					
					DATAINGEST="${ANO}-${MES}-${DIA} ${TIME}"
					
					# Tabela Scene
					STRSQLUPDATE="UPDATE catalogo.Scene "
					STRSQLUPDATE="${STRSQLUPDATE} SET IngestDate = '${DATAINGEST}', "
					STRSQLUPDATE="${STRSQLUPDATE} ImageOrientation = ${IMAGEORIENTATION}, "
					STRSQLUPDATE="${STRSQLUPDATE} Orbit = ${ORBITNO} , "
					
					#STRSQLUPDATE="${STRSQLUPDATE} Prod_UL_Lat = ${PRODULLAT},  Prod_UL_Lon = ${PRODULLON}, "
					#STRSQLUPDATE="${STRSQLUPDATE} Prod_UR_Lat = ${PRODURLAT},  Prod_UR_Lon = ${PRODURLON}, "					
					#STRSQLUPDATE="${STRSQLUPDATE} Prod_LL_Lat = ${PRODLLLAT},  Prod_LL_Lon = ${PRODLLLON}, "
					#STRSQLUPDATE="${STRSQLUPDATE} Prod_LR_Lat = ${PRODLRLAT},  Prod_LR_Lon = ${PRODLRLON}, "

					STRSQLUPDATE="${STRSQLUPDATE} Image_UL_Lat = ${IMAGEULLAT},  Image_UL_Lon = ${IMAGEULLON}, "
					STRSQLUPDATE="${STRSQLUPDATE} Image_UR_Lat = ${IMAGEURLAT},  Image_UR_Lon = ${IMAGEURLON}, "					
					STRSQLUPDATE="${STRSQLUPDATE} Image_LL_Lat = ${IMAGELLLAT},  Image_LL_Lon = ${IMAGELLLON}, "
					STRSQLUPDATE="${STRSQLUPDATE} Image_LR_Lat = ${IMAGELRLAT},  Image_LR_Lon = ${IMAGELRLON} "					
					
					STRSQLUPDATE="${STRSQLUPDATE} WHERE SceneId = '${SCENEID}' ;"
					
					echo "${STRSQLUPDATE}" > ${ARQUIVOSQL}					
					${CMDMYSQL} < ${ARQUIVOSQL}
					

					# Tabela RES2Scene
					STRSQLUPDATE="UPDATE catalogo.RES2Scene "
					STRSQLUPDATE="${STRSQLUPDATE} SET SunAzimuth = '${SUNAZIMUTH}', "
					STRSQLUPDATE="${STRSQLUPDATE} SunElevation = ${SUNELEVATION} "
					STRSQLUPDATE="${STRSQLUPDATE} WHERE SceneId = '${SCENEID}' ;"
					
					echo "${STRSQLUPDATE}" > ${ARQUIVOSQL}					
					${CMDMYSQL} < ${ARQUIVOSQL}
					
					
					rm -f ${ARQUIVOSQL}
					echo "ANO_MES: ${ANOMESATUAL}   SATELITE_SENSOR_DATA: ${PERIODOATUAL}   ORBITA_PONTO: ${ORBITAPONTOATUAL}   QUADRANTE: ${QUADRANTEATUAL}   DATA_HORA: ${DATAINGEST}"
				
				fi				
			
			done
			# Quadrante atual

			
			echo ""
			
		done
		# Orbita_ponto atual
		
		echo ""
	
	done
	# Periodo atual
	
	echo ""
	echo ""
	
done
# Ano_mes atual




