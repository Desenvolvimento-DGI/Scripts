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

ARQUIVOSQLDELETE="${HOMESCRIPT}DELETECB4WFI_${NUMPPID}.sql"
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
	DIRPERIODOS="`\ls -1r | grep ^CBERS4_MUX`"

	for PERIODOATUAL in ${DIRPERIODOS}
	do

		cd ${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}
		DIRPONTOS="`\ls -1 | sort` "
		
		for PONTOATUAL in ${DIRPONTOS}
		do


			DIRIMAGEM="${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}/${PONTOATUAL}/${DIRPARTEFINAl}"
			cd ${DIRIMAGEM}
		

			
			
			if [ -f "${DIRIMAGEM}/processado.lock" ]
			then
				echo "${ORIGEM}${ANOMESATUAL}/${PERIODOATUAL}/${PONTOATUAL}  JA PROCESSADO - EXCLUA O ARQUIVO PRA REPROCESSAR"
				continue
			fi
			
			
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

			CATALOGO="3"
				
			IDSATELITE="CB4"	
			IDRUNMODE="NULL"
			ORBIT="0"
			ORBITNO="0"
					
			CLOUDCOVERQ1="0"
			CLOUDCOVERQ2="0"
			CLOUDCOVERQ3="0"
			CLOUDCOVERQ4="0"
			CLOUDCOVERMETHOD="A"
					
			IMAGEORIENTATION="0"
				
			CENTERTIME="0"
			STARTTIME="0"
			STOPTIME="0" 
					
			SYNCLOSSES="NULL"	
			NUMMISSSWATH="NULL"	
			PERMISSSWATH="NULL"	
			BITSLIPS="NULL"
					
			GRADE="0"
			DELETED="0"
					
			EXPORTDATE="NULL"
			DATASET="NULL"

			QUADRANTE="NULL"
			CONTROLADOCQ="N"


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
			
			
			PERCPEQ='10%'
			PERCMED='20%'
			PERCGRD='30%'
			
			
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

				
				
				# Coordenadas
				CENTERLATLON="`${CMDGDALINFO} ./${TIFBANDAS342GEO} | grep -i 'Center' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
				TLLATLON="`${CMDGDALINFO} ./${TIFBANDAS342GEO} | grep -i 'Upper Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"
				TRLATLON="`${CMDGDALINFO} ./${TIFBANDAS342GEO} | grep -i 'Upper Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
				BRLATLON="`${CMDGDALINFO} ./${TIFBANDAS342GEO} | grep -i 'Lower Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
				BLLATLON="`${CMDGDALINFO} ./${TIFBANDAS342GEO} | grep -i 'Lower Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"
				

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
				
							
				
				INGESTDATE="`cat ${ARQMETADADOS} | grep -i '<sceneDate>' | sed -e 's/<[^>]*>//g' | cut -f 1 -d .`"
				SCENETIME="`cat ${ARQMETADADOS} | grep -i '<sceneTime>' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"

				IMAGEQUALITY="`cat ${ARQMETADADOS} | grep -i '<overallQuality>' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
				SUNELEVATION="`cat ${ARQMETADADOS} | grep -i '<sunElevation>' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
				SUNAZIMUTH="`cat ${ARQMETADADOS} | grep -i '<sunAzimuthElevation>' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
				ZONE="`cat ${ARQMETADADOS} | grep -i '<zone>' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"


				# Latitudes e longitudes dos véices da Imagem
				IMAGEULLAT="`cat ${ARQMETADADOS} | grep -i '<dataUpperLeftLat>'   | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
				IMAGEULLON="`cat ${ARQMETADADOS} | grep -i '<dataUpperLeftLong>'  | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"

				IMAGEURLAT="`cat ${ARQMETADADOS} | grep -i '<dataUpperRightLat>'  | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
				IMAGEURLON="`cat ${ARQMETADADOS} | grep -i '<dataUpperRightLong>' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"

				IMAGELLLAT="`cat ${ARQMETADADOS} | grep -i '<dataLowerLeftLat>'   | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
				IMAGELLLON="`cat ${ARQMETADADOS} | grep -i '<dataLowerLeftLong>'  | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"

				IMAGELRLAT="`cat ${ARQMETADADOS} | grep -i '<dataLowerRightLat>'  | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
				IMAGELRLON="`cat ${ARQMETADADOS} | grep -i '<dataLowerRightLong>' | sed -e 's/<[^>]*>//g' | sed -e 's/[[:blank:]]//g'`"
				
				
				#IMAGECLOUDCOVER='40.00'
				
				
				
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
				${PATHGDAL}gdal_translate -of PNG -a_nodata 0  -outsize ${PERCPEQ} ${PERCPEQ} ${PNGENM} ${PNGPEQ}

				# Quicklook com resolucao media de pixels 
				${PATHGDAL}gdal_translate -of PNG -a_nodata 0  -outsize ${PERCMED} ${PERCMED} ${PNGENM} ${PNGMED}

				# Quicklook com resolucao grande de pixels 
				${PATHGDAL}gdal_translate -of PNG -a_nodata 0  -outsize ${PERCGRD} ${PERCGRD} ${PNGENM} ${PNGGRD}

				
											
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

				
				
				# Geração do registro em banco de dados

				echo ""
				echo "Gerando registro no banco de dados ..."
				echo ""
				
				
				echo "" > ${ARQUIVOSQL}
				echo "" > ${ARQUIVOSQLDELETE}
				echo "" > ${ARQUIVOSQLSCENE}
				
							
				# Deleta os registro em caso de necessidade de atualização de dados e controle do CQ
				#
				SQLDELETE="DELETE FROM catalogo.Scene WHERE SceneId = '${SCENEID}';"
				echo "${SQLDELETE}"  > ${ARQUIVOSQLDELETE}
				${CMDMYSQL} < ${ARQUIVOSQLDELETE}
				
				
				SQLDELETE="DELETE FROM catalogo.CbersScene WHERE SceneId = '${SCENEID}';"
				echo "${SQLDELETE}"  > ${ARQUIVOSQLDELETE}
				${CMDMYSQL} < ${ARQUIVOSQLDELETE}


				
				
				SQLTABELA="INSERT INTO catalogo.Scene "
						
				SQLCAMPOS="( SceneId,	Satellite, Sensor, Date, Path, Row, Orbit, CenterLatitude, CenterLongitude," 
				SQLCAMPOS="${SQLCAMPOS} TL_Latitude, TL_Longitude, BR_Latitude, BR_Longitude, TR_Latitude, TR_Longitude, BL_Latitude, BL_Longitude," 
				SQLCAMPOS="${SQLCAMPOS} CloudCoverQ1, CloudCoverQ2, CloudCoverQ3, CloudCoverQ4, CloudCoverMethod, IngestDate, " 
				SQLCAMPOS="${SQLCAMPOS} Image_UL_Lat, Image_UL_Lon, Image_UR_Lat, Image_UR_Lon, Image_LL_Lat, Image_LL_Lon, Image_LR_Lat, Image_LR_Lon, "  
				SQLCAMPOS="${SQLCAMPOS} Area_UL_Lat, Area_UL_Lon, Area_LR_Lat, Area_LR_Lon, Area_UR_Lat, Area_UR_Lon, Area_LL_Lat, Area_LL_Lon, "  
				SQLCAMPOS="${SQLCAMPOS} Deleted, Catalogo, "
				#SQLCAMPOS="${SQLCAMPOS} Image_CloudCover, Image_Quality ) "
				SQLCAMPOS="${SQLCAMPOS} Image_Quality ) "
						
				SQLVALORES="VALUES ( " 
				SQLVALORES="${SQLVALORES} '${SCENEID}', '${SATELITE}', '${SENSOR}', '${DATA}', '${ORBITA}', '${PONTO}', ${ORBITNO}, ${CENTERLAT}, ${CENTERLON}, " 
				SQLVALORES="${SQLVALORES} ${TLLAT}, ${TLLON}, ${BRLAT}, ${BRLON}, ${TRLAT}, ${TRLON}, ${BLLAT}, ${BLLON}, " 
				SQLVALORES="${SQLVALORES} ${CLOUDCOVERQ1}, ${CLOUDCOVERQ2}, ${CLOUDCOVERQ3}, ${CLOUDCOVERQ4}, '${CLOUDCOVERMETHOD}', '${INGESTDATE}', " 
				SQLVALORES="${SQLVALORES} ${IMAGEULLAT}, ${IMAGEULLON}, ${IMAGEURLAT}, ${IMAGEURLON}, ${IMAGELLLAT}, ${IMAGELLLON}, ${IMAGELRLAT}, ${IMAGELRLON}, " 
				SQLVALORES="${SQLVALORES} ${TLLAT}, ${TLLON}, ${BRLAT}, ${BRLON}, ${TRLAT}, ${TRLON}, ${BLLAT}, ${BLLON}, " 
				SQLVALORES="${SQLVALORES} ${DELETED}, ${CATALOGO}, "
				#SQLVALORES="${SQLVALORES} ${IMAGECLOUDCOVER}, ${IMAGEQUALITY} );"
				SQLVALORES="${SQLVALORES} ${IMAGEQUALITY} );"
						
				SQLINSERT="${SQLTABELA} ${SQLCAMPOS} ${SQLVALORES}"
						
				echo "${SQLINSERT}"  >> ${ARQUIVOSQL}
						
						
				SQLINSERTSCENE="INSERT INTO catalogo.CbersScene "
				SQLINSERTSCENE="${SQLINSERTSCENE} ( SceneId, Gralha, DRD, SunAzimuth, SunElevation ) " 
				SQLINSERTSCENE="${SQLINSERTSCENE} VALUES " 
				SQLINSERTSCENE="${SQLINSERTSCENE} ( '${SCENEID}', '${GRALHA}', '${DRD}', ${SUNAZIMUTH}, ${SUNELEVATION} ) ;" 

				echo "${SQLINSERTSCENE}" >> ${ARQUIVOSQLSCENE}


				${CMDMYSQL} < ${ARQUIVOSQL}
				${CMDMYSQL} < ${ARQUIVOSQLSCENE}
					
				rm -fv ${ARQUIVOSQL} ${ARQUIVOSQLSCENE} ${ARQUIVOSQLDELETE}

			
			else
				# Ocorreu algum problema ao tentar gerar composicao com cores verdadeiras
				echo "ARQUIVO CORROMPIDO :: ${DIRIMAGEM}/${TIFORIGINAL}"  >> ${LOGARQUIVOSCORROMPIDOS}
			fi
			
			
			
			echo ""
			echo "Compactando imagem ..."
			echo ""
			
			${CMDGZIP}	-S .zip -v ${TIFORIGINAL}
				
			touch ${DIRIMAGEM}/processado.lock
			
			
			echo ""
			echo ""
			echo ""
			
		done

	done
done	

cd ${DIRATUAL}
		

