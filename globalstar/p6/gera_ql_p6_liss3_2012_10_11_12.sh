#!/bin/bash -x

# Gerar os Quick Look para as imagens do satelite RESOURCESAT1
# SENSOR:  LISS-3
# -----------------------------------------------------------

DIRATUAL=$(pwd)
#ORIGEM='/L2_RESOURCESAT1/'
ORIGEM='/L4_RAPIDEYE/dados/P6/'
DESTINO='/QUICKLOOK/QUICKLOOK/P6/LIS3/'
CONTADOR=0

AREATMP='/home/cdsr/p6/LIS32013/'

SATELITE='P6'
SENSOR='LIS3'



CMDGDALWARP='gdalwarp -t_srs EPSG:4291 -multi -of GTiff -r near -order 1  -co compress=jpeg '
CMDREMOVER='rm -f '
CMDGDALINFO="gdalinfo -proj4 "
CMDZIP='gzip -f -v -S .zip '
CMDUNZIP='gzip -d -f -v -S .zip '
CMDQL='gdal_translate -of PNG -a_nodata 0 -outsize '
CMDREMOVERARQS=""
#CMDINSERBD='/home/cdsr/p6/insere_dados_bd_p6.sh '

CMDTRANSLATE='gdal_translate -of GTIFF -a_nodata 0 '
CMDMERGE='gdal_merge.py -o '


ARQQLMIN="_MIN.png"
ARQQLPEQ="_PEQ.png"
ARQQLMED="_MED.png"
ARQQLGRD="_GRD.png"

ARQLOGS="/home/cdsr/p6/quicklook2013.log"


echo ""  > ${ARQLOGS}
echo "" >> ${ARQLOGS}
echo "" >> ${ARQLOGS}
AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} GERA QUICKLOOK RESOURCESAT-1 : LISS-3 :: INICIO" >> ${ARQLOGS}


# Diretós organizados por ano e mes
cd ${ORIGEM}
pwd

LISTAANOMES="`\ls -1F ${ORIGEM} | grep '/' | grep ^2012_1 | sort`"

echo "${LISTAANOMES}"

for AMATUAl in ${LISTAANOMES}
do

	echo ""
	echo "AMATUAl  =  ${AMATUAl}"
	pwd


	AGORA=`date +"%Y/%m/%d %H:%M:%S"`
	echo "${AGORA} ${AMATUAl} - INICIO" >> ${ARQLOGS}

	
	cd "${ORIGEM}${AMATUAl}"
	pwd
	
	echo ""
	LISTAPERIODOS="`\ls -1F | grep -i LISS3_20`"
	# echo "${LISTAPERIODOS}"
	
	
	for PERIODOATUAl in ${LISTAPERIODOS}
	do
	
		echo "PERIODOATUAl ==>  ${PERIODOATUAl}"
		cd "${ORIGEM}${AMATUAl}${PERIODOATUAl}"
		pwd
				

		#
		# Coordenadas
		
		LISTACOORDENADAS="`\ls -1F`"
		# echo "${LISTAPERIODOS}"
		
		for COORDENADAATUAl in ${LISTACOORDENADAS}
		do
		
			echo "COORDENADAATUAL ==>  ${COORDENADAATUAl}"
			
			cd "${ORIGEM}${AMATUAl}${PERIODOATUAl}${COORDENADAATUAl}"
			pwd
		
			#NOMEARQUIVOBAND2ZIP="`\ls -1 P6*BAND2.tif.zip`"
			NOMEARQUIVOBAND3ZIP="`\ls -1 P6*BAND3.tif.zip`"
			NOMEARQUIVOBAND4ZIP="`\ls -1 P6*BAND4.tif.zip`"
			NOMEARQUIVOBAND5ZIP="`\ls -1 P6*BAND5.tif.zip`"
				
				
			if [ -e "${ORIGEM}${AMATUAl}${PERIODOATUAl}${COORDENADAATUAl}processado.lock" ]
			then				
				echo ""
				echo "Arquivo járocessado"
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl} JÁPROCESSADO" >> ${ARQLOGS}
				
				cd ..
				continue
			fi
				
				
				
			cp -fvn ${NOMEARQUIVOBAND3ZIP} ${AREATMP}
			cp -fvn ${NOMEARQUIVOBAND4ZIP} ${AREATMP}
			cp -fvn ${NOMEARQUIVOBAND5ZIP} ${AREATMP}
				
				
			
			#echo ""
			#echo "Descompactando ${NOMEARQUIVOBAND2ZIP} ..."
			#${CMDUNZIP}  ${NOMEARQUIVOBAND2ZIP}			
		
			cd ${AREATMP}
			
			echo "Descompactando ${NOMEARQUIVOBAND3ZIP} ..."
			${CMDUNZIP}  ${AREATMP}${NOMEARQUIVOBAND3ZIP}			

			echo "Descompactando ${NOMEARQUIVOBAND4ZIP} ..."
			${CMDUNZIP}  ${AREATMP}${NOMEARQUIVOBAND4ZIP}			

			echo "Descompactando ${NOMEARQUIVOBAND5ZIP} ..."
			${CMDUNZIP}  ${AREATMP}${NOMEARQUIVOBAND5ZIP}			


			echo ""
		
		    cd ${AREATMP}

			#ARQUIVOTIFBAND2="`\ls -1 P6*BAND2.tif | grep -iv _GEO | grep -iv _TRSP`"
			ARQUIVOTIFBAND3="`\ls -1 P6*BAND3.tif | grep -iv _GEO | grep -iv _TRSP`"
			ARQUIVOTIFBAND4="`\ls -1 P6*BAND4.tif | grep -iv _GEO | grep -iv _TRSP`"
			ARQUIVOTIFBAND5="`\ls -1 P6*BAND5.tif | grep -iv _GEO | grep -iv _TRSP`"

			ARQTIFFINAL="${AREATMP}P6_LISS3_COMPOSICAO.tif"

			cd ${AREATMP}			
			${CMDMERGE} ${ARQTIFFINAL} -of GTIFF -n 0  -separate ${ARQUIVOTIFBAND5} ${ARQUIVOTIFBAND4} ${ARQUIVOTIFBAND3}
			
			
			
			AGORA=`date +"%Y/%m/%d %H:%M:%S"`
			echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl} - OK" >> ${ARQLOGS}
		
			PERIODOIMAGEM="`echo ${PERIODOATUAl} | cut -f 3 -d _`"
			
			ANO="`echo ${PERIODOIMAGEM} | cut -c 1-4`"
			MES="`echo ${PERIODOIMAGEM} | cut -c 5-6`"
			DIA="`echo ${PERIODOIMAGEM} | cut -c 7-8`"
			
			COORDENADAATUAl="`echo ${COORDENADAATUAl} | cut -f 1 -d '/'`"
			ORBITA="`echo ${COORDENADAATUAl} | cut -f 1 -d _`"
			PONTO="`echo ${COORDENADAATUAl} | cut -f 2 -d _`"

			
			SCENEID="${SATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}P6"
			NOMEQLPADRAO="QL_${SCENEID}"
		
		
		
			echo ""
			echo "${PERIODOATUAl}"
			echo "${NOMEQLPADRAO}"
		
			RESOLUCAO="`gdalinfo -proj4  ${ARQTIFFINAL} | grep -i 'Size is' | cut -c 9- `"
			LARGURA=$(echo ${RESOLUCAO} | cut -f 1 -d ',')
			ALTURA=$(echo ${RESOLUCAO} | cut -f 2 -d ',')
			
			CONTADORQL=0

			if [ "${LARGURA}" == "" ]
			then
				echo ""
				echo "Erro com dimensãdo arquivo ${ARQTIFFINAL} - Em branco"
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO ${ARQTIFFINAL} COM PROBLEMAS DE DIMENSÃ - EM BRANCO" >> ${ARQLOGS}	
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO TIFF3 ${ARQUIVOTIFBAND3} COM PROBLEMAS DE DIMENSÃ " >> ${ARQLOGS}	
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO TIFF4 ${ARQUIVOTIFBAND4} COM PROBLEMAS DE DIMENSÃ " >> ${ARQLOGS}	
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO TIFF5 ${ARQUIVOTIFBAND5} COM PROBLEMAS DE DIMENSÃ " >> ${ARQLOGS}	

				rm -f -v ${AREATMP}*.tif*
				
				continue
				
				
			fi
			
			if [ ${LARGURA} -lt 1 ]
			then
				echo ""
				echo "Erro com dimensãdo arquivo ${ARQTIFFINAL} - Valor invádo"
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO ${ARQTIFFINAL} COM PROBLEMAS DE DIMENSÃ - VALOR INVALIDO" >> ${ARQLOGS}	
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO TIFF3 ${ARQUIVOTIFBAND3} COM PROBLEMAS DE DIMENSÃ " >> ${ARQLOGS}	
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO TIFF4 ${ARQUIVOTIFBAND4} COM PROBLEMAS DE DIMENSÃ " >> ${ARQLOGS}	
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO TIFF5 ${ARQUIVOTIFBAND5} COM PROBLEMAS DE DIMENSÃ " >> ${ARQLOGS}					
				
				rm -f -v ${AREATMP}*.tif*
				
				continue
			fi
			
			
		
		
		
			# Quicklook com resoluç minima de pixels 
			
			LARGURAQL=$(( ${LARGURA}  * 12 / 10 / 100 ))
			ALTURAQL=$(( ${ALTURA}  * 12 / 10 / 100))						
			
						

			ARQFINAL="${NOMEQLPADRAO}${ARQQLMIN}"	
			echo ${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFFINAL}"  "${DESTINO}${ARQFINAL}"
			
			if [ ! -e "${DESTINO}${ARQFINAL}" ]
			then		
				${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFFINAL}"  "${DESTINO}${ARQFINAL}"
				CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
				${CMDREMOVERARQS}
				CONTADORQL=$((${CONTADORQL} + 1))
			fi

			
			
			
			
			
		
			# Quicklook com resoluç pequena de pixels 
			
			LARGURAQL=$(( ${LARGURA}  * 22 / 10 / 100 ))
			ALTURAQL=$(( ${ALTURA}  * 22 / 10 / 100))						
			
			ARQFINAL="${NOMEQLPADRAO}${ARQQLPEQ}"
			echo ${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFFINAL}"  "${DESTINO}${ARQFINAL}"
			
			if [ ! -e "${DESTINO}${ARQFINAL}" ]
			then		
				${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFFINAL}"  "${DESTINO}${ARQFINAL}"
				CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
				${CMDREMOVERARQS}
				CONTADORQL=$((${CONTADORQL} + 1))
			fi
		
		
		
		
		
		
		
			# Quicklook com resoluç media de pixels (400 pixels de largura)

			# Quicklook com resoluç pequena de pixels 
			
			LARGURAQL=$(( ${LARGURA}  * 4 / 100 ))
			ALTURAQL=$(( ${ALTURA}  * 4 / 100))						

			
			ARQFINAL="${NOMEQLPADRAO}${ARQQLMED}"
			echo ${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFFINAL}"  "${DESTINO}${ARQFINAL}"

			if [ ! -e "${DESTINO}${ARQFINAL}" ]
			then		
				${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFFINAL}"  "${DESTINO}${ARQFINAL}"
				CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
				${CMDREMOVERARQS}
				CONTADORQL=$((${CONTADORQL} + 1))
			fi
		
		
		
		
		
		
		
			# Quicklook com resoluç media de pixels (800 pixels de largura)

			LARGURAQL=$(( ${LARGURA}  * 11 / 100 ))
			ALTURAQL=$(( ${ALTURA}  * 11 / 100))						

			ARQFINAL="${NOMEQLPADRAO}${ARQQLGRD}"
			echo ${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFFINAL}"  "${DESTINO}${ARQFINAL}"

			
			if [ !  -e "${DESTINO}${ARQFINAL}" ]
			then		
				${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFFINAL}"  "${DESTINO}${ARQFINAL}"
				CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
				${CMDREMOVERARQS}
				CONTADORQL=$((${CONTADORQL} + 1))
			fi
		
		
			CONTADOR=$(($CONTADOR+1))
		
		    cd ${AREATMP}
			
			#ARQREMOVER="`\ls -1 P6*.*`"
			
			rm -f -v ${AREATMP}*.tif*
			
			#for ARQATUAl in ${ARQREMOVER}
			#do
			#	${CMDREMOVER} -v  ${AREATMP}${ARQATUAl}
			#done
			
			echo ""
			echo ""
			echo ""
			
			
			cd ${ORIGEM}
			cd ${AMATUAl}
			cd ${PERIODOATUAl}
			cd ${COORDENADAATUAl}
			
			
			touch  ${ORIGEM}${AMATUAl}${PERIODOATUAl}${COORDENADAATUAl}/processado.lock
		
		
			echo ""
			echo "Imagem processada."
			echo ""
	

			# Seráxecutado apenas uma vez
			#exit

		done
		


		# Seráxecutado apenas uma vez
		#exit
	done
		
	
	echo ""
	echo ""
	
	AGORA=`date +"%Y/%m/%d %H:%M:%S"`
	echo "${AGORA} ${AMATUAl} - TERMINO" >> ${ARQLOGS}
	
	
	# Seráxecutado apenas uma vez
	#exit

	
done


AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} GERA QUICKLOOK RESOURCESAT-1 : LISS-3 :: TERMINO" >> ${ARQLOGS}
echo "" >> ${ARQLOGS}

cd ${DIRATUAL}


echo ""
echo "TOTAL DE REGISTROS  IDENTIFICADOS = $CONTADOR"
echo "TOTAL DE QUICKLOOKS CRIADOS       = $CONTADORQL"
echo ""

