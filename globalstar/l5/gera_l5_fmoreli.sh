#!/bin/bash

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH

ANOINICIAL="2004"
ANOFINAL="2007"


CMDGZIP='/usr/bin/unzip ' 
PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/l5/'

DESTINOQL="${HOMESCRIPT}ql_fmoreli/"

FINAL="2_BC_UTM_WGS84"
TOTAL=0

cd /L2_LANDSAT5

PARAMETROANO="2007"
 

	LISTAANOS="`\/bin/ls -1 | grep ${PARAMETROANO}_`"

	for ANOATUAL in ${LISTAANOS}
	do


		   cd /L2_LANDSAT5/${ANOATUAL}

		   pwd


		   ARQS="`\/bin/ls -1 | grep -i ^LANDSAT5 | sort`"

		   for ARQATUAL in ${ARQS}
		   do
		   
				cd /L2_LANDSAT5/${ANOATUAL}/${ARQATUAL}
				
				LISTAORBITASPONTO="`/bin/ls -1 | grep ^226_068`"
				for ORBITAPONTOATUAL in ${LISTAORBITASPONTO}
				do

					DIRFINAL="/L2_LANDSAT5/${ANOATUAL}/${ARQATUAL}/${ORBITAPONTOATUAL}/${FINAL}"
					if [ -d "${DIRFINAL}" ]
					then
					  TOTAL=$(( TOTAL + 1 ))
					  cd ${DIRFINAL}
					  pwd
					  
					  
					  echo "LANDSAT-5"
					  echo "========="
					  echo ""
					  echo "GERANDO QUICKLOOKS DO ANO E MES = ${ANOATUAL}"
					  echo "PERIODO = ${ARQATUAL}"
					  echo "ORBITA E PONTO  = ${ORBITAPONTOATUAL}"
					  echo ""
					  echo ""
					  
					  
					  
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
					  
					  TIFFSAIDA="${DESTINOQL}/${NOMEPADRAO}_FULL.tif"
					  TIFFSAIDAGEO="${DESTINOQL}/${NOMEPADRAO}_GEO.tif"                        
					  TIFFSAIDAGEO8BITS="${DESTINOQL}/${NOMEPADRAO}_GEO_8BITS.tif"
					  TIFFSAIDAGEO8BITSTMP="${DESTINOQL}/${NOMEPADRAO}_GEO_8BITS_TMP.tif"
					  

					  QLSAIDAGRD="${DESTINOQL}/${QLPADRAO}_GRD.png"
					  QLSAIDAGRDJPG="${DESTINOQL}/${QLPADRAO}_GRD.jpg"
					  
					  
					  rm -fv ${TIFFSAIDA} ${TIFFSAIDAGEO} ${TIFFSAIDAGEO8BITS} ${TIFFSAIDAGEO8BITSTMP}

					  
					  ${PATHGDAL}gdal_merge.py -o ${TIFFSAIDA}  -of GTIFF -separate ${IMG1} ${IMG2} ${IMG3}
					  ${PATHGDAL}gdal_translate -ot Byte -scale -b 1 -b 2 -b 3 ${TIFFSAIDA} ${TIFFSAIDAGEO8BITS}
						
					  
					  
					  
					  if [ -e "${QLSAIDAGRD}" ]
					  then
						rm -fv "${QLSAIDAGRD}*"
					  fi
					  
					  echo ""
					  
					  
					  # Quicklook com resoluçrande de pixels 
					  ${PATHGDAL}gdal_translate -of PNG -a_nodata 0 ${TIFFSAIDAGEO8BITS} ${QLSAIDAGRD}
					  ${PATHGDAL}gdal_translate -of JPEG -a_nodata 0 ${TIFFSAIDAGEO8BITS} ${QLSAIDAGRDJPG}
					

					  rm -fv ${TIFFSAIDA} ${TIFFSAIDAGEO} ${TIFFSAIDAGEO8BITS} ${TIFFSAIDAGEO8BITSTMP} 
					  rm -fv ${IMG1} ${IMG2} ${IMG3} ${XIMG1} ${XIMG2} ${XIMG3} 

					  
					  for CONTADOR in `seq 1 6`
					  do
						echo ""
					  done
					  
					  
					  
					fi
					
				done
					
		   done

	done



echo ${TOTAL}

