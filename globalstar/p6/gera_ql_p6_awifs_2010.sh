#!/bin/bash -x

# Gerar os Quick Look para as imagens do satelite RESOURCESAT1
# SENSOR:  AWIFS
# -----------------------------------------------------------

DIRATUAL=$(pwd)
#ORIGEM='/L2_RESOURCESAT1/'
ORIGEM='/L4_RAPIDEYE/dados/P6AWIFS/'
DESTINO='/QUICKLOOK/QUICKLOOK/P6/AWIF/'
CONTADOR=0

AREATMP='/home/cdsr/p6/AWIF2010/'

SATELITE='P6'
SENSOR='AWIF'


LARGURAMAXIMA=132
ALTURAMAXIMA=160

PERCENTUALMINIMO=1
PERCENTUALMAXIMO=300



USUARIO='gerente'
PASSWORD='gerente.200408'
HOSTDB='envisat.dgi.inpe.br'
PORTA='3333'

CMDMYSQL="/usr/bin/mysql --user=${USUARIO} --password=${PASSWORD} -h ${HOSTDB} -P ${PORTA} "

ARQUIVOSQL="/home/cdsr/p6/AWIFS_UPDATE_SCENE_2010.sql"




CMDGDALWARP='gdalwarp -t_srs EPSG:4291 -multi -of GTiff -r near -order 1  '
CMDREMOVER='rm -f '
CMDGDALINFO="gdalinfo -proj4 "
CMDZIP='gzip -f -v -S .zip '
CMDUNZIP='gzip -d -f -v -S .zip '
CMDQL='gdal_translate -of PNG -a_nodata 0 -ot Byte -scale -outsize '
CMDREMOVERARQS=""
#CMDINSERBD='/home/cdsr/p6/insere_dados_bd_p6.sh '

CMDTRANSLATE='gdal_translate -of GTIFF -a_nodata 0 '
CMDMERGE='gdal_merge.py -o '


ARQQLMIN="_MIN.png"
ARQQLPEQ="_PEQ.png"
ARQQLMED="_MED.png"
ARQQLGRD="_GRD.png"

ARQLOGS="/home/cdsr/p6/quicklookawifs2010.log"


echo ""  > ${ARQLOGS}
echo "" >> ${ARQLOGS}
echo "" >> ${ARQLOGS}
AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} GERA QUICKLOOK RESOURCESAT-1 : AWIFS :: INICIO" >> ${ARQLOGS}


# Diretós organizados por ano e mes
cd ${ORIGEM}
pwd

LISTAANOMES="`\ls -1F ${ORIGEM} | grep ^2010 | grep '/' | sort`"

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
	LISTAPERIODOS="`\ls -1F | grep -i AWIFS_2010`"
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
		
		
			QUADRANTES="`\ls -1 | grep .tif.zip | cut -f 6 -d _ | sort | uniq `"
		
		
			for QUADRANTEATUAL in ${QUADRANTES}
			do
		
		
				NOMEARQUIVOBAND3ZIP="`\ls -1 P6_*_${QUADRANTEATUAL}_L2_BAND3.tif.zip`"
				NOMEARQUIVOBAND4ZIP="`\ls -1 P6_*_${QUADRANTEATUAL}_L2_BAND4.tif.zip`"
				NOMEARQUIVOBAND5ZIP="`\ls -1 P6_*_${QUADRANTEATUAL}_L2_BAND5.tif.zip`"
					
					
				if [ -e "${ORIGEM}${AMATUAl}${PERIODOATUAl}${COORDENADAATUAl}processado_${QUADRANTEATUAL}.lock" ]
				then				
					echo ""
					echo "Arquivo járocessado"
					echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl} JÁPROCESSADO" >> ${ARQLOGS}
					
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
				ARQUIVOTIFBAND3="`\ls -1 P6*_${QUADRANTEATUAL}_L2_BAND3.tif `"
				ARQUIVOTIFBAND4="`\ls -1 P6*_${QUADRANTEATUAL}_L2_BAND4.tif `"
				ARQUIVOTIFBAND5="`\ls -1 P6*_${QUADRANTEATUAL}_L2_BAND5.tif `"

				
				
				PERIODOIMAGEM="`echo ${PERIODOATUAl} | cut -f 3 -d _`"
				
				ANO="`echo ${PERIODOIMAGEM} | cut -c 1-4`"
				MES="`echo ${PERIODOIMAGEM} | cut -c 5-6`"
				DIA="`echo ${PERIODOIMAGEM} | cut -c 7-8`"
				
				COORDENADAATUAl="`echo ${COORDENADAATUAl} | cut -f 1 -d '/'`"
				ORBITA="`echo ${COORDENADAATUAl} | cut -f 1 -d _`"
				PONTO="`echo ${COORDENADAATUAl} | cut -f 2 -d _`"

				
				SCENEID="${SATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}${QUADRANTEATUAL}"
				NOMEQLPADRAO="QL_${SCENEID}"
			
				
				
				
				NOMEARQTIF="P6_AWIFS_${ANO}${MES}${DIA}_${ORBITA}_${PONTO}_${QUADRANTEATUAL}_L2"
				ARQTIFFINAL="${AREATMP}${NOMEARQTIF}.tif"
				
				NOMEARQTIFGEO="${NOMEARQTIF}_GEO"
				ARQTIFGEOFINAL="${AREATMP}${NOMEARQTIFGEO}.tif"
				

				cd ${AREATMP}			
				${CMDMERGE} ${ARQTIFFINAL} -of GTIFF -n 0  -separate ${ARQUIVOTIFBAND5} ${ARQUIVOTIFBAND4} ${ARQUIVOTIFBAND3}
				
				${CMDGDALWARP} ${ARQTIFFINAL} ${ARQTIFGEOFINAL}
				
				
				AGORA=`date +"%Y/%m/%d %H:%M:%S"`
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl} - OK" >> ${ARQLOGS}
			
			
			
				echo ""
				echo "${PERIODOATUAl}"
				echo "${NOMEQLPADRAO}"
			
				RESOLUCAO="`gdalinfo -proj4  ${ARQTIFGEOFINAL} | grep -i 'Size is' | cut -c 9- `"
				LARGURA=$(echo ${RESOLUCAO} | cut -f 1 -d ',')
				ALTURA=$(echo ${RESOLUCAO} | cut -f 2 -d ',')
				
				CONTADORQL=0

				if [ "${LARGURA}" == "" ]
				then
					echo ""
					echo "Erro com dimensãdo arquivo ${ARQTIFGEOFINAL} - Em branco"
					echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO ${ARQTIFGEOFINAL} COM PROBLEMAS DE DIMENSÃ - EM BRANCO" >> ${ARQLOGS}	
					echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO TIFF3 ${ARQUIVOTIFBAND3} COM PROBLEMAS DE DIMENSÃ " >> ${ARQLOGS}	
					echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO TIFF4 ${ARQUIVOTIFBAND4} COM PROBLEMAS DE DIMENSÃ " >> ${ARQLOGS}	
					echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO TIFF5 ${ARQUIVOTIFBAND5} COM PROBLEMAS DE DIMENSÃ " >> ${ARQLOGS}	

					rm -f -v ${AREATMP}*.tif*
					
					continue
					
					
				fi
				
				if [ ${LARGURA} -lt 1 ]
				then
					echo ""
					echo "Erro com dimensãdo arquivo ${ARQTIFGEOFINAL} - Valor invádo"
					echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO ${ARQTIFGEOFINAL} COM PROBLEMAS DE DIMENSÃ - VALOR INVALIDO" >> ${ARQLOGS}	
					echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO TIFF3 ${ARQUIVOTIFBAND3} COM PROBLEMAS DE DIMENSÃ " >> ${ARQLOGS}	
					echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO TIFF4 ${ARQUIVOTIFBAND4} COM PROBLEMAS DE DIMENSÃ " >> ${ARQLOGS}	
					echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAl}- ARQUIVO TIFF5 ${ARQUIVOTIFBAND5} COM PROBLEMAS DE DIMENSÃ " >> ${ARQLOGS}					
					
					rm -f -v ${AREATMP}*.tif*
					
					continue
				fi
				
				
			
			
			
				# Quicklook com resoluç minima de pixels 
				
				LARGURAQL=$(( ${LARGURA}  * 12 / 10 / 100 ))
				ALTURAQL=$(( ${ALTURA}  * 12 / 10 / 100))						
				
							

							
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
				echo ${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFGEOFINAL}"  "${DESTINO}${ARQFINAL}"
				
				if [ ! -e "${DESTINO}${ARQFINAL}" ]
				then		
					${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFGEOFINAL}"  "${DESTINO}${ARQFINAL}"
					CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
					${CMDREMOVERARQS}
					CONTADORQL=$((${CONTADORQL} + 1))
				fi

				
				
				
				
				
			
				# Quicklook com resoluç pequena de pixels 
				
				LARGURAQL=$(( ${LARGURA}  * 2 / 100 ))
				ALTURAQL=$(( ${ALTURA}  * 2  / 100))						
				
				ARQFINAL="${NOMEQLPADRAO}${ARQQLPEQ}"
				echo ${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFGEOFINAL}"  "${DESTINO}${ARQFINAL}"
				
				if [ ! -e "${DESTINO}${ARQFINAL}" ]
				then		
					${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFGEOFINAL}"  "${DESTINO}${ARQFINAL}"
					CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
					${CMDREMOVERARQS}
					CONTADORQL=$((${CONTADORQL} + 1))
				fi
			
			
			
			
			
			
			
				# Quicklook com resoluç media de pixels (400 pixels de largura)

				# Quicklook com resoluç pequena de pixels 
				
				LARGURAQL=$(( ${LARGURA}  * 4 / 100 ))
				ALTURAQL=$(( ${ALTURA}  * 4 / 100))						

				
				ARQFINAL="${NOMEQLPADRAO}${ARQQLMED}"
				echo ${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFGEOFINAL}"  "${DESTINO}${ARQFINAL}"

				if [ ! -e "${DESTINO}${ARQFINAL}" ]
				then		
					${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFGEOFINAL}"  "${DESTINO}${ARQFINAL}"
					CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
					${CMDREMOVERARQS}
					CONTADORQL=$((${CONTADORQL} + 1))
				fi
			
			
			
			
			
			
			
				# Quicklook com resoluç GRANDE de pixels (800 pixels de largura)

				LARGURAQL=$(( ${LARGURA}  / 100 ))
				ALTURAQL=$(( ${ALTURA}  / 100))						

				ARQFINAL="${NOMEQLPADRAO}${ARQQLGRD}"
				echo ${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFGEOFINAL}"  "${DESTINO}${ARQFINAL}"

				
				if [ !  -e "${DESTINO}${ARQFINAL}" ]
				then		
					${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFGEOFINAL}"  "${DESTINO}${ARQFINAL}"
					CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
					${CMDREMOVERARQS}
					CONTADORQL=$((${CONTADORQL} + 1))
				fi
			




				# Atualizar banco de dados com coordenadas




				CENTERLATLON="`gdalinfo -proj4  ${ARQTIFGEOFINAL} | grep -i 'Center' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
				TLLATLON="`gdalinfo -proj4  ${ARQTIFGEOFINAL} | grep -i 'Upper Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"
				TRLATLON="`gdalinfo -proj4  ${ARQTIFGEOFINAL} | grep -i 'Upper Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
				BRLATLON="`gdalinfo -proj4  ${ARQTIFGEOFINAL} | grep -i 'Lower Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
				BLLATLON="`gdalinfo -proj4  ${ARQTIFGEOFINAL} | grep -i 'Lower Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"

				CENTERLON="`echo ${CENTERLATLON} | cut -f 1 -d ','`"
				CENTERLAT="`echo ${CENTERLATLON} | cut -f 2 -d ','`"

				TLLON="`echo ${TLLATLON} | cut -f 1 -d ','`"
				TLLAT="`echo ${TLLATLON} | cut -f 2 -d ','`"

				TRLON="`echo ${TRLATLON} | cut -f 1 -d ','`"		
				TRLAT="`echo ${TRLATLON} | cut -f 2 -d ','`"

				BLLON="`echo ${BLLATLON} | cut -f 1 -d ','`"
				BLLAT="`echo ${BLLATLON} | cut -f 2 -d ','`"

				BRLON="`echo ${BRLATLON} | cut -f 1 -d ','`"
				BRLAT="`echo ${BRLATLON} | cut -f 2 -d ','`"





				SQLTABELA="UPDATE catalogo.Scene "
						
				SQLCAMPOS="SET CenterLatitude = ${CENTERLAT}, CenterLongitude = ${CENTERLON}," 
				SQLCAMPOS="${SQLCAMPOS} TL_Latitude = ${TLLAT}, TL_Longitude = ${TLLON}, BR_Latitude = ${BRLAT}, BR_Longitude = ${BRLON}, "
				SQLCAMPOS="${SQLCAMPOS} TR_Latitude = ${TRLAT}, TR_Longitude = ${TRLON}, BL_Latitude = ${BLLAT}, BL_Longitude = ${BLLON} ,  " 
				SQLCAMPOS="${SQLCAMPOS} Quadrante = '${QUADRANTEATUAL}' " 
						
				SQLWHERE="WHERE SceneId = '${SCENEID}';" 
						
				SQLUPDATE="${SQLTABELA} ${SQLCAMPOS} ${SQLWHERE}"
						
				echo "${SQLUPDATE}" > ${ARQUIVOSQL}
				echo "" >> ${ARQUIVOSQL}
						
						
				${CMDMYSQL} < ${ARQUIVOSQL}

			
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
				
				
				touch  ${ORIGEM}${AMATUAl}${PERIODOATUAl}${COORDENADAATUAl}/processado_${QUADRANTEATUAL}.lock
			
			
				echo ""
				echo "Imagem processada."
				echo ""
		

				# Seráxecutado apenas uma vez
				#exit

			
			done
			# fim Quadrante
			
			
			
			
		done
		# Fim coordenada


		# Seráxecutado apenas uma vez
		#exit
	done
	# fim perío	
	
	echo ""
	echo ""
	
	AGORA=`date +"%Y/%m/%d %H:%M:%S"`
	echo "${AGORA} ${AMATUAl} - TERMINO" >> ${ARQLOGS}
	
	
	# Seráxecutado apenas uma vez
	#exit

	
done
# Fim Ano mes



AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} GERA QUICKLOOK RESOURCESAT-1 : LISS-3 :: TERMINO" >> ${ARQLOGS}
echo "" >> ${ARQLOGS}

cd ${DIRATUAL}


echo ""
echo "TOTAL DE REGISTROS  IDENTIFICADOS = $CONTADOR"
echo "TOTAL DE QUICKLOOKS CRIADOS       = $CONTADORQL"
echo ""

