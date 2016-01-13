#!/bin/bash

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH

PARANO="${1}"
PARMES="${2}"




LARGURAMAXIMA=132
ALTURAMAXIMA=160

PERCENTUALMINIMO=1
PERCENTUALMAXIMO=300

CMDGZIP='/usr/bin/unzip ' 
PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/l5/'
NUMPPID="$$"
DIRTMP="${HOMESCRIPT}nql${NUMPPID}"

ARQLOG="${HOMESCRIPT}novo_gql_areas_sem_todas_as_bandas_${NUMPPID}.log"

FINAL="2_BC_UTM_WGS84"
TOTAL=0

echo "${DIRFINAL}" > "${ARQLOG}"

cd /L2_LANDSAT5

LISTAANOS="`\/bin/ls -1r | grep ${PARANO}_${PARMES}`"

for ANOATUAL in ${LISTAANOS}
do


       cd /L2_LANDSAT5/${ANOATUAL}

       pwd


       ARQS="`\/bin/ls -1r | grep -i ^LANDSAT5`"

       for ARQATUAL in ${ARQS}
       do
	   
			cd /L2_LANDSAT5/${ANOATUAL}/${ARQATUAL}
			
			LISTAORBITASPONTO="`/bin/ls -1r | grep -i _`"
			for ORBITAPONTOATUAL in ${LISTAORBITASPONTO}
			do

				DIRFINAL="/L2_LANDSAT5/${ANOATUAL}/${ARQATUAL}/${ORBITAPONTOATUAL}/${FINAL}"
				if [ -d "${DIRFINAL}" ]
				then
				                  
                  cd ${DIRFINAL}				  
				  NUMQLGRDNOME="`\ls -1 *_GRD.png | wc -l`"
				  #QLGRD="${DIRFINAL}/${QLGRDNOME}"
				  				  
				  #if [ ${NUMQLGRDNOME} -gt 0  ]
				  #then
				  #  echo "DIRETORIO  ${DIRFINAL} :: JA PROCESSADO."
				  #  continue
				  #fi

					  
				  QTDEIMG1="`\ls -1 LANDSAT_5_TM_*_BAND5.tif.zip | wc -l`"
				  QTDEIMG2="`\ls -1 LANDSAT_5_TM_*_BAND4.tif.zip | wc -l`"
				  QTDEIMG3="`\ls -1 LANDSAT_5_TM_*_BAND3.tif.zip | wc -l`"
				  
				  echo "LANDSAT-5 :: GERANDO QUICKLOOKS DO ANO E MES = ${ANOATUAL}"
				  echo "PERIODO = ${ARQATUAL}   -   ORBITA E PONTO  = ${ORBITAPONTOATUAL}"
				  
				  if [ ${QTDEIMG1} -lt  1 -o ${QTDEIMG2} -lt  1  -o ${QTDEIMG3} -lt  1 ]
				  then
					  echo "UMA, DUAS OU TODAS AS BANDAS NAO EXISTEM. IMPOSSIVEL GERAR COMPOSICAO."
					  echo "${DIRFINAL}  ::  UMA, DUAS OU TODAS AS BANDAS NAO EXISTEM" >> "${ARQLOG}"
					  echo ""
					  echo ""
					  continue				  				  
				  fi				  				 
				  
				  
				  echo ""
				  
				  mkdir -p  ${DIRTMP}
				  cd ${DIRFINAL}
				  
				  
				  cp -fv LANDSAT_5_TM_*_BAND5.tif.zip  ${DIRTMP}
				  cp -fv LANDSAT_5_TM_*_BAND4.tif.zip  ${DIRTMP}
				  cp -fv LANDSAT_5_TM_*_BAND3.tif.zip  ${DIRTMP}
				  
				  
				  cd ${DIRTMP}				  
				  
				  ${CMDGZIP} -o LANDSAT_5_TM_*_BAND5.tif.zip
				  ${CMDGZIP} -o LANDSAT_5_TM_*_BAND4.tif.zip
				  ${CMDGZIP} -o LANDSAT_5_TM_*_BAND3.tif.zip
				  
				  
				  IMG1="`\ls -1 LANDSAT_5_TM_*_BAND5.tif`"
				  IMG2="`\ls -1 LANDSAT_5_TM_*_BAND4.tif`"
				  IMG3="`\ls -1 LANDSAT_5_TM_*_BAND3.tif`"
							

				  XIMG1="`echo ${IMG1} | cut -f 1 -d .`.xml"
				  XIMG2="`echo ${IMG2} | cut -f 1 -d .`.xml"
				  XIMG3="`echo ${IMG3} | cut -f 1 -d .`.xml"
							
							
				  NOMEPADRAO="`echo ${IMG1} | cut -f 1-7 -d _`"
				  QLPADRAO="${NOMEPADRAO}"  
				  
				  TIFFSAIDA="${DIRTMP}/${QLPADRAO}_FULL.tif"			  
				  TIFFSAIDAGEO="${DIRTMP}/${QLPADRAO}_FULL_GEO.tif"			  
				  
				  
				  TIF_QLSAIDAMIN="${DIRTMP}/${QLPADRAO}_MIN.tif"
				  TIF_QLSAIDAPEQ="${DIRTMP}/${QLPADRAO}_PEQ.tif"
				  TIF_QLSAIDAMED="${DIRTMP}/${QLPADRAO}_MED.tif"
				  TIF_QLSAIDAGRD="${DIRTMP}/${QLPADRAO}_GRD.tif"


				  
				  TIF8_QLSAIDAMIN="${DIRTMP}/${QLPADRAO}_MIN_8BITS.tif"
				  TIF8_QLSAIDAPEQ="${DIRTMP}/${QLPADRAO}_PEQ_8BITS.tif"
				  TIF8_QLSAIDAMED="${DIRTMP}/${QLPADRAO}_MED_8BITS.tif"
				  TIF8_QLSAIDAGRD="${DIRTMP}/${QLPADRAO}_GRD_8BITS.tif"

				  
				  PNG_QLSAIDAMIN="${DIRFINAL}/${QLPADRAO}_MIN.png"
				  PNG_QLSAIDAPEQ="${DIRFINAL}/${QLPADRAO}_PEQ.png"
				  PNG_QLSAIDAMED="${DIRFINAL}/${QLPADRAO}_MED.png"
				  PNG_QLSAIDAGRD="${DIRFINAL}/${QLPADRAO}_GRD.png"

				  
				  
				  rm -fv ${TIFFSAIDA} ${TIFFSAIDAGEO}
				  rm -fv ${TIF_QLSAIDAMIN}  ${TIF_QLSAIDAPEQ}  ${TIF_QLSAIDAMED}  ${TIF_QLSAIDAGRD} 
				  rm -fv ${TIF8_QLSAIDAMIN}  ${TIF8_QLSAIDAPEQ}  ${TIF8_QLSAIDAMED}  ${TIF8_QLSAIDAGRD} 
				  rm -fv ${PNG_QLSAIDAMIN}  ${PNG_QLSAIDAPEQ}  ${PNG_QLSAIDAMED}  ${PNG_QLSAIDAGRD} 

				  				  				 
				  
				  ${PATHGDAL}gdal_merge.py -of GTIFF -co TWF=YES -o ${TIFFSAIDA} -separate ${IMG1} ${IMG2} ${IMG3}				  
				  ${PATHGDAL}gdalwarp -t_srs EPSG:4326 -of GTIFF  ${TIFFSAIDA}  ${TIFFSAIDAGEO}				  				  	
				  	                  
				  RESOLUCAO="`${PATHGDAL}gdalinfo  ${TIFFSAIDA} | grep -i 'Size is' | cut -c 9-22 `"
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
				  
				  # GERAR OS ARQUIVOS QUICKLOOK EM FORMATO TIFF

				  ${PATHGDAL}gdal_translate -of GTIFF -outsize ${LARGURAQL} ${ALTURAQL} ${TIFFSAIDAGEO} ${TIF_QLSAIDAMIN}	
				  
				  # Quicklook com resoluçequena de pixels 
				  ${PATHGDAL}gdal_translate -of GTIFF -outsize 4% 4%   ${TIFFSAIDAGEO} ${TIF_QLSAIDAPEQ}
				  
				  # Quicklook com resoluçedia de pixels 
				  ${PATHGDAL}gdal_translate -of GTIFF -outsize 6% 6%   ${TIFFSAIDAGEO} ${TIF_QLSAIDAMED}
				  
				  # Quicklook com resoluçrande de pixels 
				  ${PATHGDAL}gdal_translate -of GTIFF -outsize 10% 10% ${TIFFSAIDAGEO} ${TIF_QLSAIDAGRD}
				
				
				
				
				  echo ""
				  echo ""
					  
				  # GERAR OS ARQUIVOS QUICKLOOK EM FORMATO TIFF DE 8 BITS

				  ${PATHGDAL}gdal_translate -of GTIFF -ot Byte -scale -b 1 -b 2 -b 3  ${TIF_QLSAIDAMIN} ${TIF8_QLSAIDAMIN}	
				  
				  # Quicklook com resoluçequena de pixels 
				  ${PATHGDAL}gdal_translate -of GTIFF -ot Byte -scale -b 1 -b 2 -b 3  ${TIF_QLSAIDAPEQ} ${TIF8_QLSAIDAPEQ}
				  
				  # Quicklook com resoluçedia de pixels 
				  ${PATHGDAL}gdal_translate -of GTIFF -ot Byte -scale -b 1 -b 2 -b 3  ${TIF_QLSAIDAMED} ${TIF8_QLSAIDAMED}
				  
				  # Quicklook com resoluçrande de pixels 
				  ${PATHGDAL}gdal_translate -of GTIFF -ot Byte -scale -b 1 -b 2 -b 3  ${TIF_QLSAIDAGRD} ${TIF8_QLSAIDAGRD}
				
				
				
				  echo ""
				  echo ""
								
				
				  # GERAR OS ARQUIVOS QUICKLOOK EM FORMATO PNG
				
				  ${PATHGDAL}gdal_translate -of PNG -a_nodata 0  ${TIF8_QLSAIDAMIN} ${PNG_QLSAIDAMIN}	
				  
				  # Quicklook com resoluçequena de pixels 
				  ${PATHGDAL}gdal_translate -of PNG -a_nodata 0  ${TIF8_QLSAIDAPEQ} ${PNG_QLSAIDAPEQ}
				  
				  # Quicklook com resoluçedia de pixels 
				  ${PATHGDAL}gdal_translate -of PNG -a_nodata 0  ${TIF8_QLSAIDAMED} ${PNG_QLSAIDAMED}
				  
				  # Quicklook com resoluçrande de pixels 
				  ${PATHGDAL}gdal_translate -of PNG -a_nodata 0  ${TIF8_QLSAIDAGRD} ${PNG_QLSAIDAGRD}






				  rm -fv ${TIFFSAIDA} ${TIFFSAIDAGEO} 
				  rm -fv ${TIF_QLSAIDAMIN}  ${TIF_QLSAIDAPEQ}  ${TIF_QLSAIDAMED}  ${TIF_QLSAIDAGRD} 
				  rm -fv ${TIF8_QLSAIDAMIN}  ${TIF8_QLSAIDAPEQ}  ${TIF8_QLSAIDAMED}  ${TIF8_QLSAIDAGRD}

				  				  
				  
				  TOTAL=$(( TOTAL + 1 ))

				  rm -frv  ${DIRTMP}

				  
				  
 				  echo ""
				  echo ""
				  				  
				  
				fi
				
			done
				
       done

done


echo ""
echo "TOTAL DE REGISTROS PROCESSADOS = ${TOTAL}"
echo ""

