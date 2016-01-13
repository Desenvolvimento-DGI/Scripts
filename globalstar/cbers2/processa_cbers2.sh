#!/usr/bin/bash


PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH


DIRATUAL=$(pwd)
SATELITE="CBERS2"
IDSATELITE="CB2"

ORIGEM="/L2_CBERS2/"
HOMESCRIPT='/home/cdsr/cbers2/'

SCRIPTGERAQL="${HOMESCRIPT}gera_quicklook_cbers2.sh "
SCRIPTGERADB="${HOMESCRIPT}gera_dados_cbers2.sh "


cd ${ORIGEM}
DIRANOMES="`\ls -1 | egrep -i '^21|^20|^19' | sort`"

for ANOMESATUAL in ${DIRANOMES}
do

	cd ${ORIGEM}${ANOMESATUAL}	
	DIRPERIODOS="`\ls -1 | grep -i ^CBERS_2_ | sort`"
	
	for PERIODOATUAl in ${DIRPERIODOS}
	do
	
		echo "ANO/MES :: ${ANOMESATUAL}   -  PERIODO : ${PERIODOATUAl}"
		
		ANO="`echo ${PERIODOATUAl} | cut -f 5 -d '_'`"
		MES="`echo ${PERIODOATUAl} | cut -f 6 -d '_'`"
		DIA="`echo ${PERIODOATUAl} | cut -f 7 -d '_' | cut -f 1 -d '.'`"
		
		SENSOR="`echo ${PERIODOATUAl} | cut -f 3 -d '_' | cut -c 1-3`"
		
		${SCRIPTGERAQL} ${PERIODOATUAl} ${SATELITE} ${SENSOR} ${ANO} ${MES} ${DIA}
		${SCRIPTGERADB} ${PERIODOATUAl} ${SATELITE} ${SENSOR} ${ANO} ${MES} ${DIA}
	
		echo ""
		echo ""
		
	done
	
done

