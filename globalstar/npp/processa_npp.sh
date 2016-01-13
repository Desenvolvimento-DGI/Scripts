#!/bin/bash

DIRATUAL=$(pwd)
ORIGEM="/L2_NPP/"
DESTINO="/QUICKLOOK/S-NPP/VIIRS/"

CMDREMOVER='/usr/bin/rm -f '
CMDGDALINFO='/usr/local/gdal-1.11.1/bin/gdalinfo -proj4 ' 
CMDZIP='/usr/bin/gzip -f -v -S .zip '
CMDQL='/usr/local/gdal-1.11.1/bin/gdal_translate -of PNG -a_nodata 0 -co "WORLDFILE=YES" -outsize '
CMDREMOVERARQS=""
CMDINSERBD='/home/cdsr/npp/insere_dados_bd_npp.sh '


ARQQLMIN="_MIN.png"
ARQQLPEQ="_PEQ.png"
ARQQLMED="_MED.png"
ARQQLGRD="_GRD.png"



LARGURAMAXIMA=132
ALTURAMAXIMA=160

PERCENTUALMINIMO=1
PERCENTUALMAXIMO=300


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
	
	cd "./${AMATUAl}"
	pwd
	
	echo ""
	LISTAPERIODOS="`\/usr/bin/ls -1rF | grep NPP_VIIRS | grep -iv _L1`"
	
	
	for PERIODOATUAl in ${LISTAPERIODOS}
	do
	
		echo "PERIODOATUAl ==>  ${PERIODOATUAl}"
		cd "./${PERIODOATUAl}"
		pwd
		
				
		#ARQUIVOTIF="`\ls -1 NPP_TCOLOR_SDR.*.tif`"
		#ARQUIVOTIFZIP="`\ls -1 NPP_TCOLOR_SDR.*.tif.zip`"
		
		ARQUIVOTIF="`\/usr/bin/ls -1 NPP_CVIIRS_L2*.TCOLOR.h5.tif`"
		ARQUIVOTIFZIP="`\/usr/bin/ls -1 NPP_CVIIRS_L2*.TCOLOR.h5.tif.zip`"



		
		# Caso o arquivo jásteja compactado
		# Caso nao exista o arquivo True Color obtem o arquivo alternativo
		if [ "${ARQUIVOTIFZIP}" != "" ]
		then
				cd ..
				echo "Arquivo NPP_CVIIRS_L2 jáompactado"
				echo ""
				continue					
		fi
		

		
		
		# Caso nao exista o arquivo alternativo, sera necessario analisar o proximo
		# periodo
		if [ "${ARQUIVOTIF}" == "" ]
		then
			cd ..
				echo "Nao existe arquivo NPP_CVIIRS_L2 valido pra gerar registro no Banco de Dados"
				echo ""
			continue		
		fi
		

		# Caso o arquivo esteja vazio		
		TAMARQUIVOTIF="`\/usr/bin/ls -o ${ARQUIVOTIF} | awk '{print $4}' `"
		if [ "${TAMARQUIVOTIF}" == "0" ]
		then
			cd ..
				echo "Tamanho do arquivo NPP_CVIIRS_L2 nao éalido"
				echo ""
			continue		
		fi

				
		
		ANO="`echo ${PERIODOATUAl} | cut -c 11-14`"
		MES="`echo ${PERIODOATUAl} | cut -c 16-17`"
		DIA="`echo ${PERIODOATUAl} | cut -c 19-20`"
		HRA="`echo ${PERIODOATUAl} | cut -c 22-23`"
		MIN="`echo ${PERIODOATUAl} | cut -c 25-26`"
		SEG="`echo ${PERIODOATUAl} | cut -c 28-29`"
		
		NOMEQLPADRAO="QL_NPPVIIRS${ANO}${MES}${DIA}T${HRA}${MIN}${SEG}"
		
		
		echo ""
		echo "${PERIODOATUAl}"
		echo "${NOMEQLPADRAO}"
		
		RESOLUCAO="`/usr/local/gdal-1.11.1/bin/gdalinfo -proj4 ./${ARQUIVOTIF} | grep -i 'Size is' | cut -c 9- `"
		LARGURA=$(echo ${RESOLUCAO} | cut -f 1 -d ',')
		ALTURA=$(echo ${RESOLUCAO} | cut -f 2 -d ',')
		
		# Quicklook com resoluç minima de pixels (3% da resolucao original)
		#LARGURAQL=$(($LARGURA / 100 * 3))
		#ALTURAQL=$(($LARGURA / 100 * 3))
		ARQFINAL="${NOMEQLPADRAO}${ARQQLMIN}"		

	
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
		
		if [ -e "./${ARQUIVOTIF}" ]
		then	

			${CMDINSERBD}  "${ORIGEM}"  "${AMATUAl}"  "${PERIODOATUAl}"  "${ARQUIVOTIF}"
							
			echo "Compactando..."
			${CMDZIP} "./${ARQUIVOTIF}" 
			echo ""			
			
		fi
		
		
		
		cd ..
		echo ""
	
	done
	
	
	cd ${ORIGEM}
	
	echo ""
	echo ""
	

done

cd ${DIRATUAL}



