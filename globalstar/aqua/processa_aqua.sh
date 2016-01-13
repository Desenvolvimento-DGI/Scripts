#!/bin/bash -x

# Grar os Quick Look para as imagens do satelite AQUA
# ---------------------------------------------------

DIRATUAL=$(pwd)
ORIGEM='/L2_AQUA/'
DESTINO='/QUICKLOOK/AQUA/MODIS/'
CONTADOR=0

SATELITE='A1'
SENSOR='MODIS'

CMDREMOVER='/usr/bin/rm -f '
CMDGDALINFO='/usr/local/gdal-1.11.1/bin/gdalinfo -proj4 '
CMDZIP='/usr/bin/gzip -f -v -S .zip '
CMDQL='/usr/local/gdal-1.11.1/bin/gdal_translate -of PNG -a_nodata 0 -co "WORLDFILE=YES" -outsize '
CMDREMOVERARQS=""
CMDINSERBD='/home/cdsr/aqua/insere_dados_bd_aqua.sh '


ARQQLMIN="_MIN.png"
ARQQLPEQ="_PEQ.png"
ARQQLMED="_MED.png"
ARQQLGRD="_GRD.png"


LARGURAMAXIMA=132
ALTURAMAXIMA=160

PERCENTUALMINIMO=1
PERCENTUALMAXIMO=300


ARQLOGS="/home/cdsr/aqua/quicklook.log"


echo ""  > ${ARQLOGS}
echo "" >> ${ARQLOGS}
echo "" >> ${ARQLOGS}
AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} GERA QUICKLOOK AQUA :: INICIO" >> ${ARQLOGS}


# Diretós organizados por ano e mes
cd ${ORIGEM}
pwd

LISTAANOMES="`\/usr/bin/ls -1rF ${ORIGEM} | grep '/' `"

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
	LISTAPERIODOS="`\/usr/bin/ls -1rF | grep AQUA_`"
	# echo "${LISTAPERIODOS}"
	
	
	for PERIODOATUAl in ${LISTAPERIODOS}
	do
	
		echo "PERIODOATUAl ==>  ${PERIODOATUAl}"
		cd "./${PERIODOATUAl}"
		pwd
						
		
		NOMEARQUIVO='AQUA.MYDcrefl_TrueColor.*.tif'
		ARQUIVOTIF="`\/usr/bin/ls -1 AQUA.MYDcrefl_TrueColor.*.tif`"
		
		ARQUIVOTIFZIP="`\/usr/bin/ls -1 AQUA.MYDcrefl_TrueColor.*.tif.zip`"
		
		
		# Caso o arquivo jásteja compactado
		# Caso nao exista o arquivo True Color obtem o arquivo alternativo
		if [ "${ARQUIVOTIFZIP}" != "" ]
		then
				cd ..
				echo "Arquivo AQUA.MYDcrefl_TrueColor jáompactado"
				echo ""
				continue					
		fi
		
		
		
		echo ""
		
		# Caso nao exista o arquivo tif referente a imagem
		if [ "${ARQUIVOTIF}" == "" ]
		then	

			AGORA=`date +"%Y/%m/%d %H:%M:%S"`
			echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - SEM ARQUIVO TRUECOLOR" >> ${ARQLOGS}
		
			cd ..
			continue		
		fi
		

		# Caso o arquivo exista, mas esteja vazio		
		TAMARQUIVOTIF="`\/usr/bin/ls -o ${ARQUIVOTIF} | awk '{print $4}' `"
		if [ "${TAMARQUIVOTIF}" == "0" ]
		then

			AGORA=`date +"%Y/%m/%d %H:%M:%S"`
			echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ARQUIVO TRUECOLOR ZERADO" >> ${ARQLOGS}
		
			cd ..
			continue		
		fi
		

		AGORA=`date +"%Y/%m/%d %H:%M:%S"`
		echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${ARQUIVOTIF} - OK" >> ${ARQLOGS}
		
		ANO="`echo ${PERIODOATUAl} | cut -c 12-15`"
		MES="`echo ${PERIODOATUAl} | cut -c 17-18`"
		DIA="`echo ${PERIODOATUAl} | cut -c 20-21`"
		HRA="`echo ${PERIODOATUAl} | cut -c 23-24`"
		MIN="`echo ${PERIODOATUAl} | cut -c 26-27`"
		SEG="`echo ${PERIODOATUAl} | cut -c 29-30`"
		
		NOMEQLPADRAO="QL_${SATELITE}${SENSOR}${ANO}${MES}${DIA}T${HRA}${MIN}${SEG}"
		
		
		echo ""
		echo "${PERIODOATUAl}"
		echo "${NOMEQLPADRAO}"
		
		RESOLUCAO="`/usr/local/gdal-1.11.1/bin/gdalinfo -proj4 ./${ARQUIVOTIF} | grep -i 'Size is' | cut -c 9- `"
		LARGURA=$(echo ${RESOLUCAO} | cut -f 1 -d ',')
		ALTURA=$(echo ${RESOLUCAO} | cut -f 2 -d ',')
		
		# Quicklook com resoluç minima de pixels (3% da resolucao original)
		#LARGURAQL=$(($LARGURA / 100 * 3))
		#ALTURAQL=$(($LARGURA / 100 * 3))

		for PERCENTUALATUAl in `seq ${PERCENTUALMINIMO} ${PERCENTUALMAXIMO}`
		do
			LARGURAQL=$((${LARGURA} * ${PERCENTUALATUAl} * 10 / 10000))
			ALTURAQL=$((${ALTURA} * ${PERCENTUALATUAl} * 10 / 10000))
		
			if [ ${LARGURAQL} -lt  ${LARGURAMAXIMA} -a ${ALTURAQL} -lt  ${ALTURAMAXIMA} ] 
			then
				continue
			else
				break
			fi
		
		done
	


		ARQFINAL="${NOMEQLPADRAO}${ARQQLMIN}"		
		
		${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQUIVOTIF}"  "${DESTINO}${ARQFINAL}"
		CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
		${CMDREMOVERARQS}

		
		# Quicklook com resoluç pequena de pixels (5% da resolucao original)
		LARGURAQL=$(($LARGURA / 100 * 5))
		ALTURAQL=$(($LARGURA / 100 * 5))		
		ARQFINAL="${NOMEQLPADRAO}${ARQQLPEQ}"

		${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQUIVOTIF}"  "${DESTINO}${ARQFINAL}"
		CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
		${CMDREMOVERARQS}
		
		
		# Quicklook com resoluç media de pixels (10% da resolucao original)
		LARGURAQL=$(($LARGURA / 100 * 10))
		ALTURAQL=$(($LARGURA / 100 * 10))		
		ARQFINAL="${NOMEQLPADRAO}${ARQQLMED}"

		${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQUIVOTIF}"  "${DESTINO}${ARQFINAL}"
		CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
		${CMDREMOVERARQS}
		
		
		# Quicklook com resoluç grande de pixels (20% da resolucao original)
		LARGURAQL=$(($LARGURA / 100 * 20))
		ALTURAQL=$(($LARGURA / 100 * 20))		
		ARQFINAL="${NOMEQLPADRAO}${ARQQLGRD}"

		${CMDQL} ${LARGURAQL} ${ALTURAQL} "./${ARQUIVOTIF}"  "${DESTINO}${ARQFINAL}"
		CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
		${CMDREMOVERARQS}
		
		
		#
		# Compacta o arquivo caso o mesmo nãesteja compactado
		
		ARQUIVOTIFFZIP="${ARQUIVOTIF}.zip"
		
		if [  -e "./${ARQUIVOTIF}" ]
		then
			${CMDINSERBD}  "${ORIGEM}"  "${AMATUAl}"  "${PERIODOATUAl}"  "${ARQUIVOTIF}"
			
			echo "Compactando..."
			${CMDZIP} "./${ARQUIVOTIF}" 
			echo ""
			
		fi
		
		
		
		
		CONTADOR=$(($CONTADOR+1))
		
		cd ..
		echo ""
	
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




