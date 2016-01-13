#!/bin/bash

# Gerar os Quick Look para as imagens do satelite RESOURCESAT1
# SENSOR:  LISS-3
# -----------------------------------------------------------

DIRATUAL=$(pwd)
ORIGEM='/L2_RESOURCESAT1/'
AREATMP='/home/cdsr/p6_awifs/'

SATELITE='P6'
SENSOR='AWIF'

ARQLOGS="/home/cdsr/p6_awifs/p6_awifs_elimina_resgistros_sem_imagem.sql"
ARQLOGSP6="/home/cdsr/p6_awifs/p6scene_awifs_elimina_resgistros_sem_imagem.sql"


echo ""  > ${ARQLOGS}
echo ""  > ${ARQLOGSP6}


# Diretós organizados por ano e mes
cd ${ORIGEM}
pwd

LISTAANOMES="`\ls -1F ${ORIGEM} | grep '/' | sort`"

echo "${LISTAANOMES}"

for AMATUAl in ${LISTAANOMES}
do

	echo ""
	echo "AMATUAl  =  ${AMATUAl}"
	pwd


	
	cd "${ORIGEM}${AMATUAl}"
	pwd
	
	echo ""
	LISTAPERIODOS="`\ls -1F | grep -i AWIFS_2`"
	# echo "${LISTAPERIODOS}"
	
	
	for PERIODOATUAl in ${LISTAPERIODOS}
	do
	
		echo "PERIODOATUAl ==>  ${PERIODOATUAl}"
		cd "${ORIGEM}${AMATUAl}${PERIODOATUAl}"
		pwd
				

		#
		# Coordenadas
		
		LISTACOORDENADAS="`\ls -1F | grep -i _`"
		# echo "${LISTAPERIODOS}"
		
		for COORDENADAATUAl in ${LISTACOORDENADAS}
		do
		
			echo "COORDENADAATUAL ==>  ${COORDENADAATUAl}"
			
			cd "${ORIGEM}${AMATUAl}${PERIODOATUAl}${COORDENADAATUAl}"
			pwd
		
			NUMARQZIPQA="`\ls -1 P6*_A_*BAND*.tif.zip | wc -l`"
			NUMARQZIPQB="`\ls -1 P6*_B_*BAND*.tif.zip | wc -l`"
			NUMARQZIPQC="`\ls -1 P6*_C_*BAND*.tif.zip | wc -l`"
			NUMARQZIPQD="`\ls -1 P6*_D_*BAND*.tif.zip | wc -l`"
				
			
			
			PERIODOIMAGEM="`echo ${PERIODOATUAl} | cut -f 3 -d _`"
			
			ANO="`echo ${PERIODOIMAGEM} | cut -c 1-4`"
			MES="`echo ${PERIODOIMAGEM} | cut -c 5-6`"
			DIA="`echo ${PERIODOIMAGEM} | cut -c 7-8`"
			
			COORDENADAATUAl="`echo ${COORDENADAATUAl} | cut -f 1 -d '/'`"
			ORBITA="`echo ${COORDENADAATUAl} | cut -f 1 -d _`"
			PONTO="`echo ${COORDENADAATUAl} | cut -f 2 -d _`"

			
			SCENEID="${SATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}"

			echo "SCENEID  ::  ${SCENEID}"
			

			if [ ${NUMARQZIPQA} -lt 1 ]
			then
				SCENEIDA="${SCENEID}A"
				echo "Nao existe quadrante A para o SCENEID :   ${SCENEID}"
				echo "DELETE FROM catalogo.Scene Where SceneId = '${SCENEIDA}' and Deleted >= 90;" >>  ${ARQLOGS}
				echo "DELETE FROM catalogo.P6Scene Where SceneId = '${SCENEIDA}';" >>  ${ARQLOGSP6}
			fi
			

			if [ ${NUMARQZIPQB} -lt 1 ]
			then
				SCENEIDB="${SCENEID}B"
				echo "Nao existe quadrante A para o SCENEID :   ${SCENEID}"
				echo "DELETE FROM catalogo.Scene Where SceneId = '${SCENEIDB}' and Deleted >= 90;" >>  ${ARQLOGS}
				echo "DELETE FROM catalogo.P6Scene Where SceneId = '${SCENEIDB}';" >>  ${ARQLOGSP6}
			fi

			
			if [ ${NUMARQZIPQC} -lt 1 ]
			then
				SCENEIDC="${SCENEID}C"
				echo "Nao existe quadrante A para o SCENEID :   ${SCENEID}"
				echo "DELETE FROM catalogo.Scene Where SceneId = '${SCENEIDC}' and Deleted >= 90;" >>  ${ARQLOGS}
				echo "DELETE FROM catalogo.P6Scene Where SceneId = '${SCENEIDC}';" >>  ${ARQLOGSP6}
			fi
			
			
			if [ ${NUMARQZIPQD} -lt 1 ]
			then
				SCENEIDD="${SCENEID}D"
				echo "Nao existe quadrante A para o SCENEID :   ${SCENEID}"
				echo "DELETE FROM catalogo.Scene Where SceneId = '${SCENEIDD}' and Deleted >= 90;" >>  ${ARQLOGS}
				echo "DELETE FROM catalogo.P6Scene Where SceneId = '${SCENEIDD}';" >>  ${ARQLOGSP6}
			fi
			
			
			
			
			cd ${ORIGEM}
			cd ${AMATUAl}
			cd ${PERIODOATUAl}
			cd ${COORDENADAATUAl}
			
		
			echo ""
			echo "Imagem processada."
			echo ""
	

		done
		
	done
		
	
	echo ""
	echo ""
	
done



cd ${DIRATUAL}



