#!/bin/bash

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH

PARPERIODOINICIAL="${1}"
PARPERIODOFINAL="${2}"

for ANOATUAL in `seq ${PARPERIODOINICIAL} ${PARPERIODOFINAL}`
do

	for MESATUAL in `seq 1 12`
	do
	
		NOVOMESATUAL=$(( MESATUAL + 100 ))
		NOVOMESATUAL="`echo ${NOVOMESATUAL} | cut -c 2-3`"		
	
		clear	
		echo "LANDSAT-5"
		echo ""
		echo "/home/cdsr/l5/gera_quicklook_l5.sh ${ANOATUAL}  ${NOVOMESATUAL}"
		echo ""
		echo ""
		
		/home/cdsr/l5/gera_quicklook_l5.sh ${ANOATUAL}  ${NOVOMESATUAL}
		
	done

done

