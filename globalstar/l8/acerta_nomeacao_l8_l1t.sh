#!/bin/bash 

PARPERIODO="${1}"
PARANO="${2}"
PARMES="${3}"

PARSATELITE="L8"
PARSENSOR="OLI"
DIRSCRIPTS='/home/cdsr/l8/'

ORIGEM='/L1_LANDSAT8/L1T/'
ANOMES="${PARANO}_${PARMES}"

IDSENSOROLI="LO"
AREACOMPLETA="${ORIGEM}${ANOMES}/${PARPERIODO}"

if [ -e "${AREACOMPLETA}" ]
then

	echo ""
	echo "REALIZANDO ACERTO DA NOMEACAO DE PASSAGEM COM SENSORES COMPOSTOS..."
	echo ""
	
	
	cd ${AREACOMPLETA}
	
	PONTOS="`ls -1 | grep ^LC8 | sort`"
	for PONTOATUAL in ${PONTOS}
	do
	
		cd ${AREACOMPLETA}/${PONTOATUAL}
		
		ARQUIVOS="`ls -1 | grep ^LC8 | sort`"
		for ARQUIVOATUAL in ${ARQUIVOS}
		do
		
			NOMEARQUIVO="`echo ${ARQUIVOATUAL} | cut -f 1 -d .`"
			BANDA="`echo ${NOMEARQUIVO} | cut -f 2 -d _`"
			
			NOVOIDSENSOR="LO"
			if [ "${BANDA}" == "B10" ] || [  "${BANDA}" == "B11" ]
			then
				NOVOIDSENSOR="LT"
			fi
	
			PARTEFINAL_ARQUIVO="`echo ${ARQUIVOATUAL} | cut -c 3-`"
			NOVONOMEARQUIVO="${NOVOIDSENSOR}${PARTEFINAL_ARQUIVO}"

			mv -fv  ${ARQUIVOATUAL}  ${NOVONOMEARQUIVO}
		done
		
		
		cd ${AREACOMPLETA}
		PARTEFINAL_PONTOATUAL="`echo ${PONTOATUAL} | cut -c 3-`"	
		NOVOPONTOATUAL="${IDSENSOROLI}${PARTEFINAL_PONTOATUAL}"		
		
		mv -fv ${PONTOATUAL}  ${NOVOPONTOATUAL}
		echo ""
	done

	
	cd ${ORIGEM}${ANOMES}
	
	PARTEFINAL_PARPERIODO="`echo ${PARPERIODO} | cut -c 3-`"	
	NOVOPARPERIODO="${IDSENSOROLI}${PARTEFINAL_PARPERIODO}"

	mv -fv ${PARPERIODO}  ${NOVOPARPERIODO}
	
fi


