#!/bin/bash 

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH


ORIGEM="/L2_CBERS4/"
DESTINO="${ORIGEM}"

DESTINOQL='/QUICKLOOK/CBERS4/MUX/'

LARGURAMAXIMA=132
ALTURAMAXIMA=160

PERCENTUALMINIMO=1
PERCENTUALMAXIMO=300

NUMPPID="$$"

CMDGZIP='/usr/bin/gzip ' 
PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/cb4/'

CMDGDALINFO="${PATHGDAL}gdalinfo -proj4 "
CMDMYSQL='/usr/bin/mysql --login-path=catalogo-gerente '

ARQUIVOSQL="${HOMESCRIPT}INSERTCB4MUX_${NUMPPID}.sql"
ARQUIVOSQLSCENE="${HOMESCRIPT}INSERTSCENECB4MUX_${NUMPPID}.sql"
LOGARQUIVOSCORROMPIDOS="${HOMESCRIPT}MUX-ARQUIVOS-CORROMPIDOS-${NUMPPID}.log"

DIRPARTEFINAl='2_NN_UTM_WGS84'


cd ${HOMESCRIPT}
 

echo ""  > ${LOGARQUIVOSCORROMPIDOS}

 
 
cd ${ORIGEM}
DIRANOMES="`\ls -1r | grep _ | grep ^20`"

for ANOMESATUAL in ${DIRANOMES}
do

	echo "ANO MES :: ${ANOMESATUAL} ..."
	
	cd ${ORIGEM}${ANOMESATUAL}
	DIRPERIODOS="`\ls -1r | grep ^CBERS4_MUX_`"

	for PERIODOATUAL in ${DIRPERIODOS}
	do

		cd ${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}
		DIRPONTOS="`\ls -1 | sort` "
		
		for PONTOATUAL in ${DIRPONTOS}
		do


			DIRIMAGEM="${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}/${PONTOATUAL}/${DIRPARTEFINAl}"
			cd ${DIRIMAGEM}
		

			
			
			#if [ -f "${DIRIMAGEM}/processado.lock" ]
			#then
				#echo "${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}/${PONTOATUAL}  JA PROCESSADO - EXCLUA O ARQUIVO PRA REPROCESSAR"
				#continue
			#fi
			
			
			TIFORIGINALZIP="`\ls -1 *.TIF.zip`"
			TIFORIGINAL="`\ls -1 *.TIF`"
			
			if [ ! -f "${DIRIMAGEM}/${TIFORIGINAL}" ] && [ ! -f "${DIRIMAGEM}/${TIFORIGINALZIP}" ]
			then			
				echo "${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}/${PONTOATUAL}  NAO EXISTE IMAGEM (TIF) PRA PROCESSAMENTO"
				continue				
			fi
			
			
			
			# Sera executada a extracao caso exista um arquivo compactado (.zip)
			if [ ! -f "${DIRIMAGEM}/${TIFORIGINAL}"  ] && [ -f "${DIRIMAGEM}/${TIFORIGINALZIP}" ]
			then
				echo ""
				echo "${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}/${PONTOATUAL}  PRE-PROCESSAMENTO :: DESCOMPACTANDO IMAGEM ..."
				echo ""
			
				${CMDGZIP} -S .zip -v -d ${TIFORIGINALZIP}				
			fi
			
			
			
			# Apos extracao do arquivo compactado (.zip), deve existir a imagem em formato TIF
			TIFORIGINAL="`\ls -1 *.TIF`"			
			if [ ! -f "${DIRIMAGEM}/${TIFORIGINAL}" ]
			then			
				echo "${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}/${PONTOATUAL}  NAO EXISTE IMAGEM (TIF) PRA PROCESSAMENTO"
				continue				
			fi
			
			
			
			echo ""
			echo "${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}/${PONTOATUAL}  IMAGEM EM PROCESSAMENTO ..."
			echo ""
			
			HORARIOPASSAGEM="`echo ${PERIODOATUAL} | cut -f 2 -d .`"
			
			TIFNOMEPADRAO="`echo ${TIFORIGINAL} | cut -f 1 -d .`"
			
			TIFBANDAS342="${TIFNOMEPADRAO}-342.tif"
			TIFBANDAS342GEO="${TIFNOMEPADRAO}-342-GEO.tif"
			TIFBANDAS342GEOPC="${TIFNOMEPADRAO}-342-GEO-PC.tif"
			TIFBANDAS342GEOPCEQLZ="${TIFNOMEPADRAO}-342-GEO-PC-EQLZ.tif"
						
									
			
			SATELITE="CB4"
			MISSAO="4"
			NOMESATELITE="CBERS${MISSAO}"
			
			SENSOR="MUX"
			ORBITA="`echo ${TIFNOMEPADRAO} | cut -f 3 -d -`"
			PONTO="`echo ${TIFNOMEPADRAO} | cut -f 4 -d -`"
								
			
			DATA="`echo ${TIFNOMEPADRAO} | cut -f 5 -d -`"
			ANO="`echo ${DATA} | cut -c 1-4`"
			MES="`echo ${DATA} | cut -c 5-6`"
			DIA="`echo ${DATA} | cut -c 7-8`"

			DATAAMD="${ANO}-${MES}-${DIA}"
			

			SCENEID="${SATELITE}${SENSOR}${ORBITA}${PONTO}${DATA}"	
			GRALHA="${NOMESATELITE}_${MISSAO}_${SENSOR}_${DATA}_${HORARIOPASSAGEM}_${ORBITA}_${PONTO}"
			DRD="${GRALHA}"


			PNGMIN="QL_${SCENEID}_MIN.png"
			PNGPEQ="QL_${SCENEID}_PEQ.png"
			PNGMED="QL_${SCENEID}_MED.png"
			PNGGRD="QL_${SCENEID}_GRD.png"	
			PNGENM="QL_${SCENEID}_ENM.png"	
			
			

			# Valores padronizados
				
			IDSATELITE="CB4"	
					

			echo "TIFNOMEPADRAO = ${TIFNOMEPADRAO}"			
			ARQMETADADOS="`\ls -1 ${TIFNOMEPADRAO}.XML`"
			echo "ARQMETADADOS = ${ARQMETADADOS}"


			
			if [ ! -f "${DIRIMAGEM}/${ARQMETADADOS}"  ]
			then		
				echo "${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}/${PONTOATUAL}  NAO EXISTE METADADOS (.XML) PRA PROCESSAMENTO"
				continue
			fi

			
			
			
			rm -fv ${TIFBANDAS342} ${TIFBANDAS342GEO} ${TIFBANDAS342GEOPC} ${TIFBANDAS342GEOPCEQLZ} ${TIFBANDAS342GEOPCEQLZCG}
			rm -fv ${PNGMIN} ${PNGPEQ} ${PNGMED} ${PNGGRD} ${PNGENM}
			
			
			
			echo ""
			echo "Gerando composicao com as bandas 3,4,2 ..."
			echo ""
					
			${PATHGDAL}gdal_translate -of GTIFF -b 3 -b 4 -b 2 ${TIFORIGINAL}  ${TIFBANDAS342}
			RETORNOEXECUCAO=$?
			
			if [ "${RETORNOEXECUCAO}" == "0" ]
			then			
			
				echo ""
				echo "Reprojetando coordenadas para o sistemas 4326 (WGS84) ..."
				echo ""
				${PATHGDAL}gdalwarp -t_srs EPSG:4326 -multi -of GTiff -r near -order 1 ${TIFBANDAS342}  ${TIFBANDAS342GEO}

				#TIFBANDAS342GEO="${TIFBANDAS342}"

				echo ""
				echo "Redimensionando imagem ..."
				echo ""
				${PATHGDAL}gdal_translate -of GTIFF -outsize 40% 40% ${TIFBANDAS342GEO}  ${TIFBANDAS342GEOPC}


				echo ""
				echo "Aplicando ajuste de equalizaç na imagem ..."
				echo ""
				convert -brightness-contrast 20x30  ${TIFBANDAS342GEOPC}  ${TIFBANDAS342GEOPCEQLZ}
				

				echo ""
				echo "Gerando PNG de tamanho enorme da imagem ..."
				echo ""
				${PATHGDAL}gdal_translate -of PNG ${TIFBANDAS342GEOPCEQLZ}  ${PNGENM}
								
				
								
				
				
				RESOLUCAO="`${PATHGDAL}gdalinfo  ${TIFORIGINAL} | grep -i 'Size is' | cut -c 9-22 `"
				LARGURA=$(echo ${RESOLUCAO} | cut -f 1 -d ',')
				ALTURA=$(echo ${RESOLUCAO} | cut -f 2 -d ',')        


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
				
				
				echo ""
				echo "Gerando quicklooks ..."
				echo ""
						 
				 
				# Quicklook com resolucao minima de pixels 
				${PATHGDAL}gdal_translate -of PNG -a_nodata 0  -outsize ${LARGURAQL} ${ALTURAQL} ${PNGENM} ${PNGMIN}

				# Quicklook com resolucao pequena de pixels 
				${PATHGDAL}gdal_translate -of PNG -a_nodata 0  -outsize 10% 10% ${PNGENM} ${PNGPEQ}

				# Quicklook com resolucao media de pixels 
				${PATHGDAL}gdal_translate -of PNG -a_nodata 0  -outsize 20% 20% ${PNGENM} ${PNGMED}

				# Quicklook com resolucao grande de pixels 
				${PATHGDAL}gdal_translate -of PNG -a_nodata 0  -outsize 30% 30% ${PNGENM} ${PNGGRD}
				
				
				echo ""
				echo "Copiando quicklooks para /QUICKLOOK/CBERS4/MUX ..."
				echo ""
				
				mkdir -p ${DESTINOQL}${ANO}
				cp -fv ${PNGMIN} ${PNGPEQ} ${PNGMED} ${PNGGRD}  ${DESTINOQL}${ANO}


				
				
				echo ""
				echo "Removendo arquivos temporáos ..."
				echo ""
				
				
				rm -fv *.aux.xml *.png.xml 
				rm -fv ${TIFBANDAS342} ${TIFBANDAS342GEO} ${TIFBANDAS342GEOPC} ${TIFBANDAS342GEOPCEQLZ} 
				rm -fv ${PNGPEQ} ${PNGMED} ${PNGENM}

			
			else
				# Ocorreu algum problema ao tentar gerar composicao com cores verdadeiras
				echo "ARQUIVO CORROMPIDO :: ${DIRIMAGEM}/${TIFORIGINAL}"  >> ${LOGARQUIVOSCORROMPIDOS}
			fi
			
			
			
			echo ""
			echo "Compactando imagem ..."
			echo ""
			
			${CMDGZIP}	-S .zip -v ${TIFORIGINAL}
				
			echo ""
			echo ""
			echo ""
			
		done

	done
done	

cd ${DIRATUAL}
		

