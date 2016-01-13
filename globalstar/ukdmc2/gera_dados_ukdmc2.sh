#!/bin/bash -x

# Grar os Quick Look para as imagens do satelite UK-DMC2
# ------------------------------------------------------

DIRATUAL=$(pwd)
ORIGEM='/L2_UKDMC2/'
DESTINO='/QUICKLOOK/UK-DMC-2/SLIM/'
CONTADOR=0

SATELITE='UKDMC2'
SENSOR='SLIM'


CMDGDALWARP='gdalwarp -t_srs EPSG:4291 -multi -of GTiff -r near -order 1 '
CMDREMOVER='rm -f '
CMDGDALINFO="gdalinfo -proj4 "
CMDZIP='gzip -f -v -S .zip '
CMDUNZIP='/usr/bin/unzip '
CMDQL="gdal_translate -of PNG -a_nodata 0 -outsize "
CMDREMOVERARQS=""
CMDINSERBD='/home/cdsr/ukdmc2/insere_dados_bd_ukdmc2.sh '


ARQQLMIN="_MIN.png"
ARQQLPEQ="_PEQ.png"
ARQQLMED="_MED.png"
ARQQLGRD="_GRD.png"

ARQLOGS="/home/cdsr/ukdmc2/quicklook.log"


echo ""  > ${ARQLOGS}
echo "" >> ${ARQLOGS}
echo "" >> ${ARQLOGS}
AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} GERA QUICKLOOK UKDMC2 :: INICIO" >> ${ARQLOGS}


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


	AGORA=`date +"%Y/%m/%d %H:%M:%S"`
	echo "${AGORA} ${AMATUAl} - INICIO" >> ${ARQLOGS}

	
	cd "./${AMATUAl}"
	pwd
	
	echo ""
	LISTAPERIODOS="`\ls -1F`"
	# echo "${LISTAPERIODOS}"
	
	
	for PERIODOATUAl in ${LISTAPERIODOS}
	do
	
		echo "PERIODOATUAl ==>  ${PERIODOATUAl}"
		cd "./${PERIODOATUAl}"
		pwd
				

		#
		# Coordenadas
		
		LISTACOORDENADAS="`\ls -1F`"
		# echo "${LISTAPERIODOS}"
		
		for COORDENADAATUAl in ${LISTACOORDENADAS}
		do
		
			echo "COORDENADAATUAL ==>  ${COORDENADAATUAl}"
			cd "./${COORDENADAATUAl}"
			pwd
		
			NOMEARQUIVOZIP="`\ls -1 UKDMC_2_SLIM*.zip`"
				

			# Caso nao exista o arquivo referente a imagem
			if [ "${NOMEARQUIVOZIP}" == "" ]
			then	

				AGORA=`date +"%Y/%m/%d %H:%M:%S"`
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- SEM ARQUIVO NA AREA" >> ${ARQLOGS}
			
				cd ..
				continue		
			fi

			
			
			if [ -e "./processado.lock" ]
			then				
				echo ""
				echo "Arquivo járocessado"
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO ${NOMEARQUIVOZIP} JÁPROCESSADO" >> ${ARQLOGS}
				
				cd ..
				continue
			fi
			
				
		
			echo ""
			echo "Descompactando ${NOMEARQUIVOZIP} ..."
			${CMDUNZIP}  ${NOMEARQUIVOZIP}			
		
			echo ""
		

			ARQUIVOTIF="`\ls -1 *.tif | grep -iv _GEO`"
			ARQGEO="`echo ${ARQUIVOTIF} | cut -f 1 -d .`_GEO.tif"

			${CMDGDALWARP} ${ARQUIVOTIF} ${ARQGEO}

			
			AGORA=`date +"%Y/%m/%d %H:%M:%S"`
			echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${ARQUIVOTIF} - OK" >> ${ARQLOGS}
		
			PERIODOIMAGEM="`echo ${PERIODOATUAl} | cut -f 3 -d _`"
			
			ANO="`echo ${PERIODOIMAGEM} | cut -c 1-4`"
			MES="`echo ${PERIODOIMAGEM} | cut -c 5-6`"
			DIA="`echo ${PERIODOIMAGEM} | cut -c 7-8`"
			
			COORDENADAATUAl="`echo ${COORDENADAATUAl} | cut -f 1 -d '/'`"
			LONGITUDE="`echo ${COORDENADAATUAl} | cut -f 1 -d _`"
			LATITUDE="`echo ${COORDENADAATUAl} | cut -f 2 -d _`"

			
			SCENEID="${SATELITE}${SENSOR}${ANO}${MES}${DIA}${LONGITUDE}${LATITUDE}"
			NOMEQLPADRAO="QL_${SCENEID}"
		
		
		
			echo ""
			echo "${PERIODOATUAl}"
			echo "${NOMEQLPADRAO}"
		
			RESOLUCAO="`gdalinfo -proj4 ./${ARQUIVOTIF} | grep -i 'Size is' | cut -c 9- `"
			LARGURA=$(echo ${RESOLUCAO} | cut -f 1 -d ',')
			ALTURA=$(echo ${RESOLUCAO} | cut -f 2 -d ',')
			
			CONTADORQL=0

			if [ "${LARGURA}" == "" ]
			then
				echo ""
				echo "Erro com dimensãdo arquivo ${NOMEARQUIVOZIP} - Em branco"
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO ${NOMEARQUIVOZIP} COM PROBLEMAS DE DIMENSÃ - EM BRANCO" >> ${ARQLOGS}	
				cd ..
				continue
			fi
			
			if [ ${LARGURA} -lt 1 ]
			then
				echo ""
				echo "Erro com dimensãdo arquivo ${NOMEARQUIVOZIP} - Valor invádo"
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO ${NOMEARQUIVOZIP} COM PROBLEMAS DE DIMENSÃ - VALOR INVALIDO" >> ${ARQLOGS}	
				cd ..
				continue
			fi
			
			
		
			# Quicklook com resoluç minima de pixels 
			
			if [ ${LARGURA} -gt 14000 ]
			then
				LARGURAQL=$(( ${LARGURA} / 100 * 5 / 7 ))
				ALTURAQL=$(( ${ALTURA} / 100 * 5 / 7 ))
			else
				LARGURAQL=$(( ${LARGURA} / 100 ))
				ALTURAQL=$(( ${ALTURA} / 100 ))						
			fi
			
			
			if [ ${LARGURA} -lt 200 ]
			then
				LARGURAQL=${LARGURA}
				ALTURAQL=${ALTURA}
			fi

			

			ARQFINAL="${NOMEQLPADRAO}${ARQQLMIN}"	
			echo ${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQGEO}"  "${DESTINO}${ARQFINAL}"
			
			if [ ! -e "${DESTINO}${ARQFINAL}" ]
			then		
				${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQGEO}"  "${DESTINO}${ARQFINAL}"
				CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
				${CMDREMOVERARQS}
			else
				CONTADORQL=$((${CONTADORQL} + 1))
			fi

			
			
			
			
			
		
			# Quicklook com resoluç pequena de pixels 
			
			if [ ${LARGURA} -gt 14000 ]
			then
				LARGURAQL=$(( ${LARGURA} / 100 * 7 / 6 ))
				ALTURAQL=$(( ${ALTURA} / 100 * 7 / 6 ))
			else
				LARGURAQL=$(( ${LARGURA} / 100 * 4 / 3))
				ALTURAQL=$(( ${ALTURA} / 100 * 4 / 3))						
			fi
			
			if [ ${LARGURA} -lt 200 ]
			then
				LARGURAQL=${LARGURA}
				ALTURAQL=${ALTURA}
			fi

			
			ARQFINAL="${NOMEQLPADRAO}${ARQQLPEQ}"
			echo ${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQGEO}"  "${DESTINO}${ARQFINAL}"
			
			if [ ! -e "${DESTINO}${ARQFINAL}" ]
			then		
				${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQGEO}"  "${DESTINO}${ARQFINAL}"
				CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
				${CMDREMOVERARQS}
			else
				CONTADORQL=$((${CONTADORQL} + 1))
			fi
		
		
		
		
		
		
		
			# Quicklook com resoluç media de pixels (400 pixels de largura)

			# Quicklook com resoluç pequena de pixels 
			
			if [ ${LARGURA} -gt 14000 ]
			then
				LARGURAQL=$(( ${LARGURA} / 100 * 3 ))
				ALTURAQL=$(( ${ALTURA} / 100 * 3 ))
			else
				LARGURAQL=$(( ${LARGURA} / 100 * 7 / 2))
				ALTURAQL=$(( ${ALTURA} / 100 * 7 / 2))						
			fi

			if [ ${LARGURA} -lt 200 ]
			then
				LARGURAQL=${LARGURA}
				ALTURAQL=${ALTURA}
			fi
			
			ARQFINAL="${NOMEQLPADRAO}${ARQQLMED}"
			echo ${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQGEO}"  "${DESTINO}${ARQFINAL}"

			if [ ! -e "${DESTINO}${ARQFINAL}" ]
			then		
				${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQGEO}"  "${DESTINO}${ARQFINAL}"
				CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
				${CMDREMOVERARQS}
			else
				CONTADORQL=$((${CONTADORQL} + 1))
			fi
		
		
		
		
		
		
		
			# Quicklook com resoluç media de pixels (800 pixels de largura)

			if [ ${LARGURA} -gt 14000 ]
			then
				LARGURAQL=$(( ${LARGURA} / 100 * 5 ))
				ALTURAQL=$(( ${ALTURA} / 100 * 5 ))
			else
				LARGURAQL=$(( ${LARGURA} / 100 * 6))
				ALTURAQL=$(( ${ALTURA} / 100 * 6))						
			fi

			if [ ${LARGURA} -lt 200 ]
			then
				LARGURAQL=${LARGURA}
				ALTURAQL=${ALTURA}
			fi

			ARQFINAL="${NOMEQLPADRAO}${ARQQLGRD}"
			echo ${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQGEO}"  "${DESTINO}${ARQFINAL}"

			
			if [ !  -e "${DESTINO}${ARQFINAL}" ]
			then		
				${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQGEO}"  "${DESTINO}${ARQFINAL}"
				CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
				${CMDREMOVERARQS}
			else
				CONTADORQL=$((${CONTADORQL} + 1))
			fi
		
		
		
			if [ ${CONTADORQL} -eq 0 ]
			then
				${CMDINSERBD}  "${ORIGEM}"   "${AMATUAl}"   "${PERIODOATUAl}"   "${COORDENADAATUAl}"   "${ARQGEO}"   "${NOMEARQUIVOZIP}" "${ARQUIVOTIF}"		
			fi
		
		
			CONTADOR=$(($CONTADOR+1))
		
			ARQREMOVER="`\ls -1 | grep -iv .zip`"
			for ARQATUAl in ${ARQREMOVER}
			do
				${CMDREMOVER} ${ARQATUAl}
			done
			touch ./processado.lock
		
		
			cd ..
			echo ""
			echo "Imagem processada."
			echo ""
	
		done
		
		cd ..
	
	done
		
	cd ${ORIGEM}
	
	echo ""
	echo ""
	
	AGORA=`date +"%Y/%m/%d %H:%M:%S"`
	echo "${AGORA} ${AMATUAl} - TERMINO" >> ${ARQLOGS}
	

done


AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} GERA QUICKLOOK AQUA :: TERMINO" >> ${ARQLOGS}
echo "" >> ${ARQLOGS}

cd ${DIRATUAL}


echo ""
echo "TOTAL DE REGISTROS IDENTIFICADOS = $CONTADOR"
echo ""

