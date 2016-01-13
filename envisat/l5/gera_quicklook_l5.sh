#!/bin/bash

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH

LARGURAMAXIMA=132
ALTURAMAXIMA=160

PERCENTUALMINIMO=1
PERCENTUALMAXIMO=300

CMDGZIP='/usr/bin/gzip ' 
PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/l5/'



ORBITAPONTOATUAL="226_068_0"
FINAL="2_BC_UTM_WGS84"
TOTAL=0

for ANOATUAL in `seq 2004 2007`
do

     for MESATUAL in `seq 1 12`
     do


       NOVOMES=$(( MESATUAL + 100 ))
       NOVOMES="`echo ${NOVOMES} | cut -c 2-3`"

       ANOMESATUAL="${ANOATUAL}_${NOVOMES}"


       cd /L2_LANDSAT5/${ANOMESATUAL}

       pwd


       ARQS="`\ls -1 | grep -i ^LANDSAT5_TM_ | sort`"

       for ARQATUAL in ${ARQS}
           do

				DIRFINAL="/L2_LANDSAT5/${ANOMESATUAL}/${ARQATUAL}/${ORBITAPONTOATUAL}/${FINAL}"
				if [ -d "${DIRFINAL}" ]
				then
                  TOTAL=$(( TOTAL + 1 ))
                  cd ${DIRFINAL}
                  pwd
				  
				  
				  ${CMDGZIP} -f -d -v -S .zip LANDSAT_5_TM_*_BAND5.tif.zip
				  ${CMDGZIP} -f -d -v -S .zip LANDSAT_5_TM_*_BAND4.tif.zip
				  ${CMDGZIP} -f -d -v -S .zip LANDSAT_5_TM_*_BAND3.tif.zip
				  
				  
				  IMG1="`\ls -1 LANDSAT_5_TM_*_BAND5.tif`"
				  IMG2="`\ls -1 LANDSAT_5_TM_*_BAND4.tif`"
				  IMG3="`\ls -1 LANDSAT_5_TM_*_BAND3.tif`"
							
				  NOMEPADRAO="`echo ${IMG1} | cut -f 1-7 -d .`"
				  QLPADRAO="${NOMEPADRAO}"  
				  
				  TIFFSAIDA="${DIRFINAL}/${NOMEPADRAO}_FULL.tif"
				  TIFFSAIDAGEO="${DIRFINAL}/${NOMEPADRAO}_GEO.tif"                        
				  TIFFSAIDAGEO8BITS="${DIRFINAL}/${NOMEPADRAO}_GEO_8BITS.tif"
				  TIFFSAIDAGEO8BITSTMP="${DIRFINAL}/${NOMEPADRAO}_GEO_8BITS_TMP.tif"
				  
				  QLSAIDAMIN="${DIRFINAL}/${QLPADRAO}_MIN.png"
				  QLSAIDAPEQ="${DIRFINAL}/${QLPADRAO}_PEQ.png"
				  QLSAIDAMED="${DIRFINAL}/${QLPADRAO}_MED.png"
				  QLSAIDAGRD="${DIRFINAL}/${QLPADRAO}_GRD.png"
				  
				  
				  rm -fv ${TIFFSAIDA} ${TIFFSAIDAGEO} ${TIFFSAIDAGEO8BITS} ${TIFFSAIDAGEO8BITSTMP}

				  
				  ${PATHGDAL}gdal_merge.py -o ${TIFFSAIDA}  -of GTIFF -separate ${IMG1} ${IMG2} ${IMG3}
				  ${PATHGDAL}gdal_translate -ot Byte -scale -b 1 -b 2 -b 3 ${TIFFSAIDA} ${TIFFSAIDAGEO8BITS}
				  	
				  	                  
				  RESOLUCAO="`${PATHGDAL}gdalinfo  ${TIFFSAIDAGEO8BITS} | grep -i 'Size is' | cut -c 9-22 `"
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
				  
				  
				  if [ -e "${QLSAIDAMIN}" ]
				  then
				  	rm -fv "${QLSAIDAMIN}*"
				  fi
                  
				  if [ -e "${QLSAIDAPEQ}" ]
				  then
				  	rm -fv "${QLSAIDAPEQ}*"
				  fi
				  
				  if [ -e "${QLSAIDAMED}" ]
				  then
				  	rm -fv "${QLSAIDAMED}*"
				  fi
				  
				  if [ -e "${QLSAIDAGRD}" ]
				  then
				  	rm -fv "${QLSAIDAGRD}*"
				  fi
				  
				  echo ""
				  
				  ${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize ${LARGURAQL} ${ALTURAQL} ${TIFFSAIDAGEO8BITS} ${QLSAIDAMIN}	
				  
				  # Quicklook com resoluçequena de pixels 
				  ${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize 5% 5% ${TIFFSAIDAGEO8BITS} ${QLSAIDAPEQ}
				  
				  # Quicklook com resoluçedia de pixels 
				  ${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize 10% 10% ${TIFFSAIDAGEO8BITS} ${QLSAIDAMED}
				  
				  # Quicklook com resoluçrande de pixels 
				  ${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize 20% 20% ${TIFFSAIDAGEO8BITS} ${QLSAIDAGRD}
				

				  rm -fv ${TIFFSAIDA} ${TIFFSAIDAGEO} ${TIFFSAIDAGEO8BITS} ${TIFFSAIDAGEO8BITSTMP}
				  
				  
				  ${CMDGZIP} -f -v -S .zip LANDSAT_5_TM_*_BAND5.tif
				  ${CMDGZIP} -f -v -S .zip LANDSAT_5_TM_*_BAND4.tif
				  ${CMDGZIP} -f -v -S .zip LANDSAT_5_TM_*_BAND3.tif
				  
				  
				fi
				
       done

    done

done

echo ${TOTAL}

