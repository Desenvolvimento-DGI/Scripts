#!/bin/bash
# Parametros enviados para que se possa obter dados sobre o arquivo e
# inserir um registro referente ao mesmo no Banco de dados
echo -n "Inserindo dados no banco de dados ."
PARORIGEM="${1}"
PARANOMES="${2}"
PARPERIODO="${3}"
PARARQUIVO="${4}"
DIRATUAL=$(pwd)
USUARIO='gerente'
PASSWORD='gerente.200408'
HOSTDB='envisat.dgi.inpe.br'
PORTA='3333'
CMDGDALINFO='/usr/local/gdal-1.11.1/bin/gdalinfo -proj4 ' 
#CMDMYSQL="/usr/bin/mysql --user=${USUARIO} --password=${PASSWORD} -h ${HOSTDB} -P ${PORTA} "
CMDMYSQL='/usr/bin/mysql --login-path=catalogo-gerente '

ARQUIVOSQL="/home/cdsr/terra/INSERTTERRA.sql"
ARQUIVOSCENETERRA="/home/cdsr/terra/INSERTSCENETERRA.sql"
ARQUIVOSQLDELETE="/home/cdsr/terra/DELETETERRA.sql"


echo "" > ${ARQUIVOSQL}
echo "" > ${ARQUIVOSCENETERRA}
# Diretórganizados por ano e mes
cd ${PARORIGEM}
cd ${PARANOMES}
cd ${PARPERIODO}
SATELITE="T1"
SENSOR="MODIS"
	
ORBITA=""
PONTO=""
IDRUNMODE="NULL"
ORBIT="0"
		
CLOUDCOVERQ1="0"
CLOUDCOVERQ2="0"
CLOUDCOVERQ3="0"
CLOUDCOVERQ4="0"
#CLOUDCOVERMETHOD="M"
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
SATELITEAMBIENTAL="S"
DESATIVADO="N"

OPERATORID="VAZIO"

		
NOMEARQUIVO="${PARARQUIVO}"
ARQUIVOTIF="${PARARQUIVO}"
echo -n "."
PERIODOATUAL="${PARPERIODO}"		
		
ANO="`echo ${PARPERIODO} | cut -c 13-16`"
MES="`echo ${PARPERIODO} | cut -c 18-19`"
DIA="`echo ${PARPERIODO} | cut -c 21-22`"
HRA="`echo ${PARPERIODO} | cut -c 24-25`"
MIN="`echo ${PARPERIODO} | cut -c 27-28`"
SEG="`echo ${PARPERIODO} | cut -c 30-31`"
	
SCENEID="${SATELITE}${SENSOR}${ANO}${MES}${DIA}T${HRA}${MIN}${SEG}"
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
		
# Verifica se a imagem nãrada antes das 06, pois neste horáa mesma se encontra 
# Escura, e dessa forma sem possibilidade de uso
if [ ${HRA} -le 6 ]
then
	DELETED="1"		
	DESATIVADO="S"
fi
		
echo -n "."



# Deleta os registro em caso de necessidade de atualização de dados e controle do CQ
#
SQLDELETE="DELETE FROM catalogo.Scene WHERE SceneId = '${SCENEID}';"
echo "${SQLDELETE}"  > ${ARQUIVOSQLDELETE}
${CMDMYSQL} < ${ARQUIVOSQLDELETE}


SQLDELETE="DELETE FROM catalogo.ModisScene WHERE SceneId = '${SCENEID}';"
echo "${SQLDELETE}"  > ${ARQUIVOSQLDELETE}
${CMDMYSQL} < ${ARQUIVOSQLDELETE}




			
SQLTABELA="INSERT INTO catalogo.Scene "
		
SQLCAMPOS="( SceneId,	Satellite, Sensor, Date, Orbit, CenterLatitude, CenterLongitude," 
SQLCAMPOS="${SQLCAMPOS} TL_Latitude, TL_Longitude, BR_Latitude, BR_Longitude, TR_Latitude, TR_Longitude, BL_Latitude, BL_Longitude," 
SQLCAMPOS="${SQLCAMPOS} Image_UL_Lat, Image_UL_Lon, Image_LR_Lat, Image_LR_Lon, Image_UR_Lat, Image_UR_Lon, Image_LL_Lat, Image_LL_Lon," 
SQLCAMPOS="${SQLCAMPOS} Area_UL_Lat, Area_UL_Lon, Area_LR_Lat, Area_LR_Lon, Area_UR_Lat, Area_UR_Lon, Area_LL_Lat, Area_LL_Lon," 
SQLCAMPOS="${SQLCAMPOS} CloudCoverQ1, CloudCoverQ2, CloudCoverQ3, CloudCoverQ4, CloudCoverMethod," 
SQLCAMPOS="${SQLCAMPOS} Deleted, SateliteAmbiental, Desativado, Catalogo, OperatorId ) "
		
SQLVALORES="VALUES ( " 
SQLVALORES="${SQLVALORES} '${SCENEID}', '${SATELITE}', '${SENSOR}', '${DATA}', ${ORBIT}, ${CENTERLAT}, ${CENTERLON}, " 
SQLVALORES="${SQLVALORES} ${TLLAT}, ${TLLON}, ${BRLAT}, ${BRLON}, ${TRLAT}, ${TRLON}, ${BLLAT}, ${BLLON}, " 
SQLVALORES="${SQLVALORES} ${TLLAT}, ${TLLON}, ${BRLAT}, ${BRLON}, ${TRLAT}, ${TRLON}, ${BLLAT}, ${BLLON}, " 
SQLVALORES="${SQLVALORES} ${TLLAT}, ${TLLON}, ${BRLAT}, ${BRLON}, ${TRLAT}, ${TRLON}, ${BLLAT}, ${BLLON}, " 
SQLVALORES="${SQLVALORES} ${CLOUDCOVERQ1}, ${CLOUDCOVERQ2}, ${CLOUDCOVERQ3}, ${CLOUDCOVERQ4}, '${CLOUDCOVERMETHOD}', " 
SQLVALORES="${SQLVALORES} ${DELETED}, '${SATELITEAMBIENTAL}', '${DESATIVADO}', 3, '${OPERATORID}' );"
		
SQLINSERT="${SQLTABELA} ${SQLCAMPOS} ${SQLVALORES}"
		
echo "${SQLINSERT}" >> ${ARQUIVOSQL}
echo "" >> ${ARQUIVOSQL}
		
CONTADOR=$(($CONTADOR+1))
		
				
DRD="TERRA_1_MODIS_${ANO}${MES}${DIA}_${HRA}${MIN}${SEG}"
GRALHA="${DRD}"
		
		
		
SQLINSERTTERRASCENE="INSERT INTO catalogo.ModisScene "
SQLINSERTTERRASCENE="${SQLINSERTTERRASCENE} ( SceneId,	Gralha, DRD ) " 
SQLINSERTTERRASCENE="${SQLINSERTTERRASCENE} VALUES " 
SQLINSERTTERRASCENE="${SQLINSERTTERRASCENE} ( '${SCENEID}', '${GRALHA}', '${DRD}' ) ;" 
echo "${SQLINSERTTERRASCENE}" >> ${ARQUIVOSCENETERRA}
echo "" >> ${ARQUIVOSCENETERRA}
echo -n "."
${CMDMYSQL} < ${ARQUIVOSQL}
${CMDMYSQL} < ${ARQUIVOSCENETERRA}
echo "."
echo "SCENEID  ${SCENEID}  :: SATELITE: ${SATELITE} - SENSOR: ${SENSOR}   Inserido no Banco de Dados do Catalogo."
	
cd ${DIRATUAL}

