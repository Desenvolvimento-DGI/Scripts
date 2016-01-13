#!/bin/bash

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH


PERIODO="${1}"
SATELITE="${2}"
SENSOR="${3}"
 
ANO="${4}"
MES="${5}"
DIA="${6}"
 
PARORBITA="${7}"

ORIGEM="/L4_RESOURCESAT2/"
ANOMES="${ANO}_${MES}"



cd ${ORIGEM}${ANOMES}/${PERIODO}

ARQS="`\ls -1 | grep ^R2LS | grep -i ${ANO}${PARORBITA}`"

for DIRATUAL in ${ARQS}
do	
        ORBITA="`echo ${DIRATUAL} | cut -c 15-17`"
        PONTO="`echo ${DIRATUAL} | cut -c 18-20`"
        DIRNOVO="${ORBITA}_${PONTO}"

		# Caso o diretorio atual jáxista nãseráecessáo processáo novamente
		if [ -e ${ORIGEM}${ANOMES}/${PERIODO}/${DIRNOVO} ]
		then		
			rm -frv ${DIRATUAL}
			continue
		fi
		
		
		
        mv -v ${DIRATUAL} ${DIRNOVO}

        cd ${ORIGEM}${ANOMES}/${PERIODO}/${DIRNOVO}

        BANDAS="`\ls -1 BAND*`"
        for BATUAL in ${BANDAS}
        do
                mv -v ${BATUAL}  ${DIRATUAL}_${BATUAL}
        done

        echo ""
        echo ""

        cd ${ORIGEM}${ANOMES}/${PERIODO}

done


