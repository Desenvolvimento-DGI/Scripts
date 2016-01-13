#!/bin/bash

# Gerar os Quick Look para as imagens do satelite RESOURCESAT1
# SENSOR:  AWIFS
# -----------------------------------------------------------

PARANO="${1}"

DIRATUAL=$(pwd)
#ORIGEM='/L2_RESOURCESAT1/'
ORIGEM='/L4_RAPIDEYE/dados/P6AWIFS/'
DESTINO='/QUICKLOOK/RESOURCESAT1/AWIF/'
CONTADOR=0
NUMPID=$$
AREATMP="/home/cdsr/p6-teste/AWIF${NUMPID}/"

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



CMDGDALWARP='gdalwarp -of GTIFF -t_srs EPSG:4326  '
CMDREMOVER='rm -f '
CMDGDALINFO="gdalinfo -proj4 "
CMDZIP='gzip -f -v -S .zip '
CMDUNZIP='gzip -d -f -v -S .zip '
CMDQL='gdal_translate -of PNG -a_nodata 0 -outsize '
CMDREMOVERARQS=""
#CMDINSERBD='/home/cdsr/p6/insere_dados_bd_p6.sh '

CMDTRANSLATE='gdal_translate -of GTIFF -ot Byte -scale '
CMDMERGE='gdal_merge.py -o '


ARQQLMIN="_MIN.png"
ARQQLPEQ="_PEQ.png"
ARQQLMED="_MED.png"
ARQQLGRD="_GRD.png"


# Diretós organizados por ano e mes
cd ${ORIGEM}
pwd

LISTAANOMES="`\ls -1F ${ORIGEM} | grep ${PARANO} | grep '/' | sort`"

echo "${LISTAANOMES}"

for AMATUAl in ${LISTAANOMES}
do

	echo ""
	echo "AMATUAl  =  ${AMATUAl}"
	pwd
	
	cd "${ORIGEM}${AMATUAl}"
	pwd
	
	echo ""
	LISTAPERIODOS="`\ls -1F | grep -i P6_AWIFS_`"
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
		
		
			QUADRANTES="`\ls -1 | grep -i .tif.zip | cut -f 6 -d _ | sort | uniq `"
		
		
			for QUADRANTEATUAL in ${QUADRANTES}
			do
		
				cd "${ORIGEM}${AMATUAl}${PERIODOATUAl}${COORDENADAATUAl}"
				
				mkdir ${AREATMP}
		
				NOMEARQUIVOBAND3ZIP="`\ls -1 P6_*_${QUADRANTEATUAL}_L2_BAND3.tif.zip`"
				NOMEARQUIVOBAND4ZIP="`\ls -1 P6_*_${QUADRANTEATUAL}_L2_BAND4.tif.zip`"
				NOMEARQUIVOBAND5ZIP="`\ls -1 P6_*_${QUADRANTEATUAL}_L2_BAND5.tif.zip`"
									
					
				cp -fv ${NOMEARQUIVOBAND3ZIP} ${AREATMP}
				cp -fv ${NOMEARQUIVOBAND4ZIP} ${AREATMP}
				cp -fv ${NOMEARQUIVOBAND5ZIP} ${AREATMP}
					
					
				
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
				ARQTIFGEO8BITS="${AREATMP}${NOMEARQTIFGEO}_8BITS.tif"

				
				# Acessa a area temporaria para processamento
				cd ${AREATMP}	
				
				
				${CMDMERGE} ${ARQTIFFINAL} -of GTIFF -separate ${ARQUIVOTIFBAND5} ${ARQUIVOTIFBAND4} ${ARQUIVOTIFBAND3}
				${CMDGDALWARP} ${ARQTIFFINAL} ${ARQTIFGEOFINAL}
				
				${CMDTRANSLATE} ${ARQTIFGEOFINAL} ${ARQTIFGEO8BITS}
				
				
			
			
				echo ""
				echo "${PERIODOATUAl}"
				echo "${NOMEQLPADRAO}"
			
				RESOLUCAO="`gdalinfo -proj4  ${ARQTIFGEOFINAL} | grep -i 'Size is' | cut -c 9- `"
				LARGURA=$(echo ${RESOLUCAO} | cut -f 1 -d ',')
				ALTURA=$(echo ${RESOLUCAO} | cut -f 2 -d ',')
				

				
				if [ "${LARGURA}" == "" ]
				then
					echo ""
					echo "Erro com dimensãdo arquivo ${ARQTIFGEOFINAL} - Em branco"
					cd ..
					rm -frv ${AREATMP}
					sleep 5					
					continue
				fi
				
				if [ ${LARGURA} -lt 1 ]
				then
					echo ""
					echo "Erro com dimensãdo arquivo ${ARQTIFGEOFINAL} - Valor invádo"
					cd ..
					rm -frv ${AREATMP}
					sleep 5
					continue
				fi
				
				
			
			
			
				# Quicklook com resolucao minima de pixels 
				
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
				rm -fv "${DESTINO}${ARQFINAL}" 
				
				${CMDQL} ${LARGURAQL} ${ALTURAQL} "${ARQTIFGEO8BITS}"  "${DESTINO}${ARQFINAL}"
				CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
				${CMDREMOVERARQS}				
				
				
				
			
				# Quicklook com resolucao pequena de pixels 
				
				
				ARQFINAL="${NOMEQLPADRAO}${ARQQLPEQ}"
				rm -fv "${DESTINO}${ARQFINAL}"

				${CMDQL} 3% 3% "${ARQTIFGEO8BITS}"  "${DESTINO}${ARQFINAL}"
				CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
				${CMDREMOVERARQS}
			
			

				# Quicklook com resolucao media de pixels 
				ARQFINAL="${NOMEQLPADRAO}${ARQQLMED}"
				rm -fv "${DESTINO}${ARQFINAL}" 

				${CMDQL} 5% 5% "${ARQTIFGEO8BITS}"  "${DESTINO}${ARQFINAL}"
				CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
				${CMDREMOVERARQS}
			
			
			
			
				# Quicklook com resolucao GRANDE de pixels 
				ARQFINAL="${NOMEQLPADRAO}${ARQQLGRD}"
				rm -fv "${DESTINO}${ARQFINAL}"
					
				${CMDQL} 10% 10% "${ARQTIFGEO8BITS}"  "${DESTINO}${ARQFINAL}"
				CMDREMOVERARQS="${CMDREMOVER} ${DESTINO}${NOMEQLPADRAO}*.aux.xml  ${DESTINO}${NOMEQLPADRAO}*.wld"
				${CMDREMOVERARQS}


				
				
				
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
				SQLCAMPOS="${SQLCAMPOS} Area_TL_Lat = ${TLLAT}, TL_Lon = ${TLLON}, BR_Lat = ${BRLAT}, BR_Lon = ${BRLON}, "
				SQLCAMPOS="${SQLCAMPOS} Area_TR_Lat = ${TRLAT}, TR_Lon = ${TRLON}, BL_Lat = ${BLLAT}, BL_Lon = ${BLLON} " 
						
				SQLWHERE="WHERE SceneId = '${SCENEID}';" 
						
				SQLUPDATE="${SQLTABELA} ${SQLCAMPOS} ${SQLWHERE}"
						
				echo "${SQLUPDATE}" > ${ARQUIVOSQL}
				echo "" >> ${ARQUIVOSQL}
						
						
				${CMDMYSQL} < ${ARQUIVOSQL}

			
				CONTADOR=$(($CONTADOR+1))
			
				cd /home/cdsr				
				rm -frv ${AREATMP}
				
				
				echo ""
				echo ""
				echo ""
				echo "Imagem processada."
				echo ""
		

				# Seráxecutado apenas uma vez
				#exit

			
			done
			# fim Quadrante			
			#exit
			
			
		done
		# Fim coordenada


		# Seráxecutado apenas uma vez
		#exit
	done
	# fim perío	
	
	echo ""
	echo ""
	
	# Seráxecutado apenas uma vez
	#exit

	
done
# Fim Ano mes


cd ${DIRATUAL}


echo ""
echo "TOTAL DE REGISTROS  IDENTIFICADOS = $CONTADOR"
echo "TOTAL DE QUICKLOOKS CRIADOS       = $CONTADORQL"
echo ""

