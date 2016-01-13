#!/bin/bash
 
 
DIRORIGEM='/L4_RAPIDEYE/'
LISTARE='RE1 RE2 RE3 RE4 RE5'


CONTADOR=0

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

			##
			# Compactar arquivo tif
			
			cd ${DIRORIGEM}${REATUAL}/${ANOMESATUAL}/${PERIODOATUAL}
			TIFFATUAL="`\ls -1 *.tif | cut -c 1-52 | sort | uniq`"
			TIFFATUAL="${TIFFATUAL}.tif"
			
			gzip -v -S .zip ./${TIFFATUAL}
			
			##
			
			CONTADOR=$(($CONTADOR+1))
			
			cd ..
			
		done
		
		cd ..
	
	done

	cd ..

done

echo ""
echo "Total de registros gerados = ${CONTADOR}"
echo ""

