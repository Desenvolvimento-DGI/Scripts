#!/bin/bash

DIRATUAL=$(pwd)
ORIGEM="/L2_NPP/"

CMDGDALINFO="gdalinfo -proj4 "
ARQUIVOSQL="/home/cdsr/npp/INSERTNPP.sql"
SATELITE="NPP"
SENSOR="VIIRS"


ARQUIVOMODISSCENENPP="/home/cdsr/npp/INSERTNPPSCENE.sql"

# Diretós organizados por ano e mes
cd ${ORIGEM}


echo "" > ${ARQUIVOSQL}
echo "" > ${ARQUIVOMODISSCENENPP}


LISTAANOMES="`ls -1F ${ORIGEM} | grep '/' | sort`"

for AMATUAl in ${LISTAANOMES}
do

	cd "./${AMATUAl}"	
	LISTAPERIODOS="`ls -1F`"
		
	for PERIODOATUAl in ${LISTAPERIODOS}
	do
			
		cd "./${PERIODOATUAl}"
			
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
		DELETED="99"
		
		EXPORTDATE="NULL"
		DATASET="NULL"
		
		ARQUIVOSH5="`ls -1 *.h5 | cut -c 12- | sort | uniq`"
		ARQUIVOTIF="`ls -1 NPP_TCOLOR_SDR.*.tif`"
		
		if [ "${ARQUIVOTIF}" == "" ]
		then
			ARQUIVOTIF="`ls -1 NPP_M12BT_SDR.*.tif`"
		fi
		
		# Caso nao exista o arquivo alternativo, sera necessario analisar o proximo
		# periodo
		if [ "${ARQUIVOTIF}" == "" ]
		then
			cd ..
			continue		
		fi

		TAMARQUIVO="`ls -o ${ARQUIVOTIF} | awk '{print $4}' `"
		if [ "${TAMARQUIVO}" == "0" ]
		then
			cd ..
			continue		
		fi

		
		
		ANO="`echo ${ARQUIVOSH5} | cut -c 1-4`"
		MES="`echo ${ARQUIVOSH5} | cut -c 5-6`"
		DIA="`echo ${ARQUIVOSH5} | cut -c 7-8`"
		HRA="`echo ${ARQUIVOSH5} | cut -c 11-12`"
		MIN="`echo ${ARQUIVOSH5} | cut -c 13-14`"
		SEG="`echo ${ARQUIVOSH5} | cut -c 15-16`"		
		
		SCENEID="NPPVIIRS${ANO}${MES}${DIA}T${HRA}${MIN}${SEG}"
		DATA="${ANO}-${MES}-${DIA}"
		INGESTDATE="${DATA} ${HRA}${MIN}${SEG}"
		
		RESOLUCAO="`${CMDGDALINFO} ./${ARQUIVOTIF} | grep -i 'Size is' | cut -c 9- `"
		LARGURA=$(echo ${RESOLUCAO} | cut -f 1 -d ',')
		ALTURA=$(echo ${RESOLUCAO} | cut -f 2 -d ',')
		
		CENTERLATLON="`${CMDGDALINFO} ./${ARQUIVOTIF} | grep -i 'Center' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
		TLLATLON="`${CMDGDALINFO} ./${ARQUIVOTIF} | grep -i 'Upper Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"
		TRLATLON="`${CMDGDALINFO} ./${ARQUIVOTIF} | grep -i 'Upper Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
		BRLATLON="`${CMDGDALINFO} ./${ARQUIVOTIF} | grep -i 'Lower Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
		BLLATLON="`${CMDGDALINFO} ./${ARQUIVOTIF} | grep -i 'Lower Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"

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
		
		# Verifica se a imagem nãéerada antes das 06, pois neste horáo a mesma se encontra 
		# Escura, e dessa forma sem possibilidade de uso
		if [ ${HRA} -le 6 ]
		then
			DELETED="1"		
		fi
		
		
			
		echo "Gerando SCENEID  ${SCENEID}  :: SATELITE: ${SATELITE} - SENSOR: ${SENSOR}"
			
		SQLTABELA="INSERT INTO Scene "
		
		SQLCAMPOS="( SceneId,	Satellite, Sensor, Date, Orbit, CenterLatitude, CenterLongitude," 
		SQLCAMPOS="${SQLCAMPOS} TL_Latitude, TL_Longitude, BR_Latitude, BR_Longitude, TR_Latitude, TR_Longitude, BL_Latitude, BL_Longitude," 
		SQLCAMPOS="${SQLCAMPOS} CloudCoverQ1, CloudCoverQ2, CloudCoverQ3, CloudCoverQ4, CloudCoverMethod," 
		SQLCAMPOS="${SQLCAMPOS} Deleted ) "
		
		SQLVALORES="VALUES ( " 
		SQLVALORES="${SQLVALORES} '${SCENEID}', '${SATELITE}', '${SENSOR}', '${DATA}', ${ORBIT}, ${CENTERLAT}, ${CENTERLON}, " 
		SQLVALORES="${SQLVALORES} ${TLLAT}, ${TLLON}, ${BRLAT}, ${BRLON}, ${TRLAT}, ${TRLON}, ${BLLAT}, ${BLLON}, " 
		SQLVALORES="${SQLVALORES} ${CLOUDCOVERQ1}, ${CLOUDCOVERQ2}, ${CLOUDCOVERQ3}, ${CLOUDCOVERQ4}, '${CLOUDCOVERMETHOD}', " 
		SQLVALORES="${SQLVALORES} ${DELETED} );"
		
		SQLINSERT="${SQLTABELA} ${SQLCAMPOS} ${SQLVALORES}"
		
		echo "${SQLINSERT}" >> ${ARQUIVOSQL}
		echo "" >> ${ARQUIVOSQL}
		
				
		
		DRD="NPP_1_VIIRS_${ANO}${MES}${DIA}_${HRA}${MIN}${SEG}"
		GRALHA="${DRD}"
		
		SQLINSERTNPPSCENE="INSERT INTO NppScene "
		SQLINSERTNPPSCENE="${SQLINSERTNPPSCENE} ( SceneId,	Gralha, DRD ) " 
		SQLINSERTNPPSCENE="${SQLINSERTNPPSCENE} VALUES " 
		SQLINSERTNPPSCENE="${SQLINSERTNPPSCENE} ( '${SCENEID}', '${GRALHA}', '${DRD}' ) ;" 

		echo "${SQLINSERTNPPSCENE}" >> ${ARQUIVOMODISSCENENPP}
		echo "" >> ${ARQUIVOMODISSCENENPP}

		
		
		
		cd ..
	
	done	
	
	cd ${ORIGEM}
		

done

cd ${DIRATUAL}


