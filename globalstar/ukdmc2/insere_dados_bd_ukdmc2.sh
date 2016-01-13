#!/bin/bash

# Parametros enviados para que se possa obter dados sobre o arquivo e
# inserir um registro referente ao mesmo no Banco de dados

echo -n "Inserindo dados no banco de dados ."


PARORIGEM="${1}"
PARANOMES="${2}"
PARPERIODO="${3}"
PARCOORDENADA="${4}"
PARARQUIVOTIFF="${5}"
PARARQUIVOZIP="${6}"
PARARQUIVOTIFFORIGINAL="${7}"

DIRATUAL=$(pwd)

USUARIO='gerente'
PASSWORD='gerente.200408'
HOSTDB='envisat.dgi.inpe.br'
PORTA='3333'

CMDGDALINFO="gdalinfo -proj4 "
CMDMYSQL="/usr/bin/mysql --user=${USUARIO} --password=${PASSWORD} -h ${HOSTDB} -P ${PORTA} "

ARQUIVOSQL="/home/cdsr/ukdmc2/INSERTUKDMC2.sql"
ARQUIVOSCENEUKDMC2="/home/cdsr/ukdmc2/INSERTSCENEUKDMC2.sql"
ARQUIVOUPDATESCENE="/home/cdsr/ukdmc2/UPDATESCENE.sql"


echo "" > ${ARQUIVOSQL}
echo "" > ${ARQUIVOSCENEUKDMC2}



# Diretós organizados por ano e mes
cd ${PARORIGEM}
cd ${PARANOMES}
cd ${PARPERIODO}
cd ${PARCOORDENADA}



SATELITE="UKDMC2"
SENSOR="SLIM"
	
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
		
NOMEARQUIVO="${PARARQUIVOTIFF}"
ARQUIVOTIF="${PARARQUIVOTIFF}"

echo -n "."



PERIODOATUAL="${PARPERIODO}"		

PERIODOIMAGEM="`echo ${PERIODOATUAL} | cut -f 3 -d '_'`"
	
ANO="`echo ${PERIODOIMAGEM} | cut -c 1-4`"
MES="`echo ${PERIODOIMAGEM} | cut -c 5-6`"
DIA="`echo ${PERIODOIMAGEM} | cut -c 7-8`"
	


COORDENADAATUAl="`echo ${PARCOORDENADA} | cut -f 1 -d '/'`"
LONGITUDE="`echo ${COORDENADAATUAl} | cut -f 1 -d _`"
LATITUDE="`echo ${COORDENADAATUAl} | cut -f 2 -d _`"


HRA="`echo ${PARARQUIVOTIFFORIGINAL} | cut -c 41-42`"
MIN="`echo ${PARARQUIVOTIFFORIGINAL} | cut -c 43-44`"
SEG="`echo ${PARARQUIVOTIFFORIGINAL} | cut -c 45-46`"


SCENEID="${SATELITE}${SENSOR}${ANO}${MES}${DIA}${LONGITUDE}${LATITUDE}"
DATA="${ANO}-${MES}-${DIA}"
INGESTDATE="${DATA} ${HRA}:${MIN}:${SEG}"


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
		
echo -n "."

			
SQLTABELA="INSERT INTO catalogo.Scene "
		
SQLCAMPOS="( SceneId,	Satellite, Sensor, Date, Orbit, CenterLatitude, CenterLongitude," 
SQLCAMPOS="${SQLCAMPOS} TL_Latitude, TL_Longitude, BR_Latitude, BR_Longitude, TR_Latitude, TR_Longitude, BL_Latitude, BL_Longitude," 
SQLCAMPOS="${SQLCAMPOS} CloudCoverQ1, CloudCoverQ2, CloudCoverQ3, CloudCoverQ4, CloudCoverMethod, IngestDate, " 
SQLCAMPOS="${SQLCAMPOS} Deleted ) "
		
SQLVALORES="VALUES ( " 
SQLVALORES="${SQLVALORES} '${SCENEID}', '${SATELITE}', '${SENSOR}', '${DATA}', ${ORBIT}, ${CENTERLAT}, ${CENTERLON}, " 
SQLVALORES="${SQLVALORES} ${TLLAT}, ${TLLON}, ${BRLAT}, ${BRLON}, ${TRLAT}, ${TRLON}, ${BLLAT}, ${BLLON}, " 
SQLVALORES="${SQLVALORES} ${CLOUDCOVERQ1}, ${CLOUDCOVERQ2}, ${CLOUDCOVERQ3}, ${CLOUDCOVERQ4}, '${CLOUDCOVERMETHOD}', '${INGESTDATE}', " 
SQLVALORES="${SQLVALORES} ${DELETED} );"
		
SQLINSERT="${SQLTABELA} ${SQLCAMPOS} ${SQLVALORES}"
		
echo "${SQLINSERT}" >> ${ARQUIVOSQL}
echo "" >> ${ARQUIVOSQL}
		
CONTADOR=$(($CONTADOR+1))
		
				
DRD="${PARARQUIVOZIP}"
GRALHA="${DRD}"
		
		
		
SQLINSERTUKDMC2SCENE="INSERT INTO catalogo.UKDMCScene "
SQLINSERTUKDMC2SCENE="${SQLINSERTUKDMC2SCENE} ( SceneId,	Gralha, DRD ) " 
SQLINSERTUKDMC2SCENE="${SQLINSERTUKDMC2SCENE} VALUES " 
SQLINSERTUKDMC2SCENE="${SQLINSERTUKDMC2SCENE} ( '${SCENEID}', '${GRALHA}', '${DRD}' ) ;" 

echo "${SQLINSERTUKDMC2SCENE}" >> ${ARQUIVOSCENEUKDMC2}
echo "" >> ${ARQUIVOSCENEUKDMC2}



SQLUPDATESCENE="UPDATE catalogo.Scene SET IngestDate = '${INGESTDATE}' WHERE SceneId = '${SCENEID}'"
echo "${SQLUPDATESCENE}" > ${ARQUIVOUPDATESCENE}


echo -n "."


${CMDMYSQL} < ${ARQUIVOSQL}
${CMDMYSQL} < ${ARQUIVOUPDATESCENE}
${CMDMYSQL} < ${ARQUIVOSCENEUKDMC2}

echo "."
echo "SCENEID  ${SCENEID}  :: SATELITE: ${SATELITE} - SENSOR: ${SENSOR}   Inserido no Banco de Dados do Catalogo."
	
cd ${DIRATUAL}


