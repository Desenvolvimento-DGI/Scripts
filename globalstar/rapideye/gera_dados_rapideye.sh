#!/bin/bash

DIRATUAL=$(pwd)
ORIGEM='/home/cdsr/rapideye/browse/'
ARQUIVOSGERADOS='/home/cdsr/rapideye/arquivosgerados.txt'
CONTADORFASE=0
FASES=1
CONTADOR=0

CMDGDALINFO="gdalinfo -proj4 "
ARQUIVOSQL="/home/cdsr/rapideye/INSERTRAPIDEYE"
SATELITE='RE1'
SENSOR='REIS'


# Diretós organizados por ano e mes
cd ${ORIGEM}


echo "" > "${ARQUIVOSQL}${FASES}.sql"
echo "" > $ARQUIVOSGERADOS


LISTAREGIOES="`\ls -1F ${ORIGEM} | grep '/' | sort`"

echo "${LISTAREGIOES}"

for REGIAOATUAl in ${LISTAREGIOES}
do


	cd "./${REGIAOATUAl}"	
	echo ""
	
	LISTAARQUIVOS="`\ls -1F *_browse.tif`"
	# echo "${LISTAARQUIVOS}"
	
	REGIAO=""
	
	if [ "${REGIAOATUAl}" == "sul/" ]
	then
		REGIAO="SUL"
	fi

	if [ "${REGIAOATUAl}" == "norte/" ]
	then
		REGIAO="NORTE"
	fi	

	if [ "${REGIAOATUAl}" == "nordeste/" ]
	then
		REGIAO="NORDESTE"
	fi

	if [ "${REGIAOATUAl}" == "sudeste/" ]
	then
		REGIAO="SUDESTE"
	fi

	if [ "${REGIAOATUAl}" == "centro-oeste/" ]
	then
		REGIAO="CENTRO-OESTE"
	fi
	
	
	
	
	
	
	for ARQUIVOATUAl in ${LISTAARQUIVOS}
	do
	
		#echo "ARQUIVOATUAl ==>  ${ARQUIVOATUAl}"		
		#echo ""				
					
					
		ORBITA="`echo ${ARQUIVOATUAl} | cut -c 3-5`"
		PONTO="`echo ${ARQUIVOATUAl} | cut -c 6-7`"
		DATAFIM="`echo ${ARQUIVOATUAl} | cut -c 47-52`"	
		INDEFINIDO="`echo ${ARQUIVOATUAl} | cut -c 38-45`"		
		
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
		
		
		SATELITE="`echo ${ARQUIVOATUAl} | cut -c 27-29`"		
		FUSO="`echo ${ARQUIVOATUAl} | cut -c 1-2`"		
		
		ANO="`echo ${ARQUIVOATUAl} | cut -c 9-12`"
		MES="`echo ${ARQUIVOATUAl} | cut -c 14-15`"
		DIA="`echo ${ARQUIVOATUAl} | cut -c 17-18`"
		HRA="`echo ${ARQUIVOATUAl} | cut -c 20-21`"
		MIN="`echo ${ARQUIVOATUAl} | cut -c 22-23`"
		SEG="`echo ${ARQUIVOATUAl} | cut -c 24-25`"
		
		
		SCENEID="${SATELITE}${SENSOR}${ANO}${MES}${DIA}T${HRA}${MIN}${SEG}R${INDEFINIDO}"
		DATA="${ANO}-${MES}-${DIA}"
		INGESTDATE="${DATA} ${HRA}${MIN}${SEG}"
		
		RESOLUCAO="`${CMDGDALINFO} ./${ARQUIVOATUAl} | grep -i 'Size is' | cut -c 9- `"
		LARGURA=$(echo ${RESOLUCAO} | cut -f 1 -d ',')
		ALTURA=$(echo ${RESOLUCAO} | cut -f 2 -d ',')
		
		
		
		
		CENTERLATLON="`${CMDGDALINFO} ./${ARQUIVOATUAl} | grep -i 'Center' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
		TLLATLON="`${CMDGDALINFO} ./${ARQUIVOATUAl} | grep -i 'Upper Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"
		TRLATLON="`${CMDGDALINFO} ./${ARQUIVOATUAl} | grep -i 'Upper Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
		BRLATLON="`${CMDGDALINFO} ./${ARQUIVOATUAl} | grep -i 'Lower Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
		BLLATLON="`${CMDGDALINFO} ./${ARQUIVOATUAl} | grep -i 'Lower Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"

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
		#if [ ${HRA} -le 6 ]
		#then
			#DELETED="1"		
		#fi
		
		
			
		echo "Gerando SCENEID  ${SCENEID}  :: SATELITE: ${SATELITE} - SENSOR: ${SENSOR}"
			
		
		SQLTABELA="INSERT INTO Scene "		
		SQLCAMPOS="( SceneId,	Satellite, Sensor, Date, Orbit, CenterLatitude, CenterLongitude," 
		SQLCAMPOS="${SQLCAMPOS} TL_Latitude, TL_Longitude, BR_Latitude, BR_Longitude, TR_Latitude, TR_Longitude, BL_Latitude, BL_Longitude," 
		SQLCAMPOS="${SQLCAMPOS} CloudCoverQ1, CloudCoverQ2, CloudCoverQ3, CloudCoverQ4, CloudCoverMethod, Regiao, Fuso," 
		SQLCAMPOS="${SQLCAMPOS} Deleted ) "		

		SQLVALORES="( '${SCENEID}', '${SATELITE}', '${SENSOR}', '${DATA}', ${ORBIT}, ${CENTERLAT}, ${CENTERLON}, " 
		SQLVALORES="${SQLVALORES} ${TLLAT}, ${TLLON}, ${BRLAT}, ${BRLON}, ${TRLAT}, ${TRLON}, ${BLLAT}, ${BLLON}, " 
		SQLVALORES="${SQLVALORES} ${CLOUDCOVERQ1}, ${CLOUDCOVERQ2}, ${CLOUDCOVERQ3}, ${CLOUDCOVERQ4}, '${CLOUDCOVERMETHOD}', '${REGIAO}', ${FUSO}, " 
		SQLVALORES="${SQLVALORES} ${DELETED} ) "
		
		echo "${SQLTABELA}" >> "${ARQUIVOSQL}${FASES}.sql"
		echo "${SQLCAMPOS}" >> "${ARQUIVOSQL}${FASES}.sql"
		echo " VALUES " >> "${ARQUIVOSQL}${FASES}.sql"			
		echo "${SQLVALORES} ;" >> "${ARQUIVOSQL}${FASES}.sql"
				
		CONTADOR=$(($CONTADOR+1))
		CONTADORFASES=$(($CONTADORFASES+1))
		
		if [ ${CONTADORFASES} -ge 2000 ]
		then
			CONTADORFASES=0
			FASES=$(($FASES+1))
		fi
		
		
		#echo "${SCENEID};${REGIAOATUAl}" >> ${ARQUIVOSGERADOS}
		
	
	done	
	
	cd ${ORIGEM}
		

done



cd ${DIRATUAL}


echo ""
echo "TOTAL DE REGISTROS IDENTIFICADOS = $CONTADOR"
echo ""


