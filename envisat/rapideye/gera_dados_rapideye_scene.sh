#!/bin/bash
 
 
ARQUIVOSQL='/home/cdsr/rapideye/insert_rapideye_scene.sql' 
INSERTSQL='';

DIRORIGEM='/L4_RAPIDEYE/'
LISTARE='RE1 RE2 RE3 RE4 RE5'


CONTADOR=0

echo "" > ${ARQUIVOSQL}

for REATUAL in ${LISTARE} 
do
	cd ${DIRORIGEM}${REATUAL}
	
	DIRANOMES="`\ls -1`"	
	for ANOMESATUAL in ${DIRANOMES}
	do
	
		cd ${DIRORIGEM}${REATUAL}/${ANOMESATUAL}
				
		DIRPERIODOS="`\ls -1 | grep _REIS`"		
		for PERIODOATUAL in ${DIRPERIODOS}
		do	
		
			SATELITE="${REATUAL}"
			SENSOR='REIS'
			NUMERO="`echo ${SATELITE} | cut -c 3-3`"
			
			
			ANO="`echo ${PERIODOATUAL} | cut -c 10-13`"
			MES="`echo ${PERIODOATUAL} | cut -c 15-16`"
			DIA="`echo ${PERIODOATUAL} | cut -c 18-19`"
			
			HRA="`echo ${PERIODOATUAL} | cut -c 21-22`"
			MIN="`echo ${PERIODOATUAL} | cut -c 24-25`"
			SEG="`echo ${PERIODOATUAL} | cut -c 27-28`"
			
			NUMEROR="`echo ${PERIODOATUAL} | cut -c 30-37`"
			
			
			echo "REATUAL  = ${REATUAL}    ANOMESATUAL = ${ANOMESATUAL}    PERIODOATUAL = ${PERIODOATUAL}"

			echo "SATELITE = ${SATELITE}"
			echo "SENSOR   = ${SENSOR}"
			echo "NUMERO = ${NUMERO}"
			
			echo "ANO = ${ANO}"
			echo "MES = ${MES}"
			echo "DIA = ${DIA}"
			
			echo "HRA = ${HRA}"
			echo "MIN = ${MIN}"
			echo "SEG = ${SEG}"
			
			echo "NUMEROR = ${NUMEROR}"

			
			
			SCENEID="${SATELITE}${SENSOR}${ANO}${MES}${DIA}T${HRA}${MIN}${SEG}R${NUMEROR}"
			GRALHA="${SATELITE}_${NUMERO}_${SENSOR}_${ANO}${MES}${DIA}_${HRA}${MIN}${SEG}_${NUMEROR}"
			DRD="${GRALHA}"
			

			echo "SCENEID = ${SCENEID}"
			echo "GRALHA = ${GRALHA}"

			INSERTSQL="INSERT INTO catalogo.RapideyeScene ( SceneId, Gralha, DRD ) VALUES "
			INSERTSQL="${INSERTSQL} ( '${SCENEID}', '${GRALHA}', '${DRD}' ) ;" 
		
			echo ${INSERTSQL} >> ${ARQUIVOSQL}
			echo "" >> ${ARQUIVOSQL}
			
			echo ""
			echo ""

			CONTADOR=$(($CONTADOR+1))
			
		done
		
		cd ..
	
	done

	cd ..

done

echo ""
echo "Total de registros gerados = ${CONTADOR}"
echo ""

