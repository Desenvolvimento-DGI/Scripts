#!/bin/bash

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH

PARANO="${1}"
PARMES="${2}"


CMDGZIP='/usr/bin/unzip ' 
PATHGDAL='/usr/local/gdal-1.11.1/bin/'
CMDGDALINFO="${PATHGDAL}gdalinfo -proj4 "

HOMESCRIPT='/home/cdsr/l5/'
NUMPPID="$$"
DIRTMP="${HOMESCRIPT}acoordenada${NUMPPID}"


CMDMYSQL='/usr/bin/mysql --login-path=catalogo-gerente '
ARQUIVOSQL="${DIRTMP}/ATUALIZA_COORDENADAS.sql"
ARQLOG="${HOMESCRIPT}aql_areas_sem_todas_as_bandas.log"


FINAL="2_BC_UTM_WGS84"
TOTAL=0


cd /L2_LANDSAT5

LISTAANOS="`\/bin/ls -1r | grep ${PARANO}_${PARMES}`"


echo "" > ${ARQLOG}

for ANOATUAL in ${LISTAANOS}
do


       cd /L2_LANDSAT5/${ANOATUAL}

	   ANOQL="`echo ${ANOATUAL} | cut -f 1 -d _`"
	   MESQL="`echo ${ANOATUAL} | cut -f 2 -d _`"
	   QL_ANOMES="`echo ${ANOATUAL} | cut -f 1-2 -d _`"



       ARQS="`\/bin/ls -1 | grep -i ^LANDSAT5 | sort`"

       for ARQATUAL in ${ARQS}
       do
	   
			cd /L2_LANDSAT5/${ANOATUAL}/${ARQATUAL}
			
			DIAQL="`echo ${ARQATUAL} | cut -c 19-20`"
			
			LISTAORBITASPONTO="`/bin/ls -1 | grep -i _`"
			for ORBITAPONTOATUAL in ${LISTAORBITASPONTO}
			do

				DIRFINAL="/L2_LANDSAT5/${ANOATUAL}/${ARQATUAL}/${ORBITAPONTOATUAL}/${FINAL}"
				if [ -d "${DIRFINAL}" ]
				then
				                  
                  		  cd ${DIRFINAL}				  
				  	
				
				  QTDEIMG1="`\ls -1 LANDSAT_5_TM_*_BAND5.tif.zip | wc -l`"
				  QTDEIMG2="`\ls -1 LANDSAT_5_TM_*_BAND4.tif.zip | wc -l`"
				  QTDEIMG3="`\ls -1 LANDSAT_5_TM_*_BAND3.tif.zip | wc -l`"

				
				  #if [ -e "${DIRFINAL}/processado.lock" ]
				  #then	
  					  #echo "DIRETORIO  ${DIRFINAL} :: JA PROCESSADO."

					  
					  if [ ${QTDEIMG1} -lt  1 -o ${QTDEIMG2} -lt  1  -o ${QTDEIMG3} -lt  1 ]
					  then
						  echo "NAO EXISTEM AS 3 BANDAS PRA GERAR O QUICKLOOK. COORDENADAS NAO SERAO ATUALIZADAS."
						  echo "${DIRFINAL}"  >>  ${ARQLOG}
						  echo ""
						  echo ""
						  continue	
					  fi				  				 					
					
					  #continue
				  #fi
					

				  
				  echo "LANDSAT-5 :: ATUALIZANDO DADOS DE COORDENADAS DAS IMAGENS"
				  echo "ANO E MES = ${ANOATUAL}"
				  echo "PERIODO = ${ARQATUAL}   -   ORBITA E PONTO  = ${ORBITAPONTOATUAL}"
				  				  				  
				  
				  if [ ${QTDEIMG1} -lt  1 -a ${QTDEIMG2} -lt  1  -a ${QTDEIMG3} -lt  1 ]
				  then
					  echo "NÃ EXISTE NENHUMA BANDA PRA EXTRACAO DE DADOS."
					  echo "${DIRFINAL}"  >>  ${ARQLOG}
					  echo ""
					  echo ""
					  continue				  				  
				  fi		
				  
				  
				  if [ ${QTDEIMG1} -lt  1 -o ${QTDEIMG2} -lt  1  -o ${QTDEIMG3} -lt  1 ]
				  then
					  echo "NAO EXISTEM AS 3 BANDAS PRA GERAR O QUICKLOOK. COORDENADAS NAO SERAO ATUALIZADAS."
					  echo "${DIRFINAL}"  >>  ${ARQLOG}
					  echo ""
					  echo ""
					  continue
				  fi				  				 
				  
				  
				  
				  echo ""
				  
				  
				  
				  mkdir -p  ${DIRTMP}
				  cd ${DIRFINAL}
				  
				  
				  if [ ${QTDEIMG1} -eq  1 ]
				  then
					  IMGPRINCIPAL="`\ls -1 LANDSAT_5_TM_*_BAND5.tif.zip`"
				  else	
				  
					  if [ ${QTDEIMG2} -eq  1 ]
					  then
						  IMGPRINCIPAL="`\ls -1 LANDSAT_5_TM_*_BAND4.tif.zip`"						  
					  else				  
						  IMGPRINCIPAL="`\ls -1 LANDSAT_5_TM_*_BAND3.tif.zip`"
					  fi
				  
				  fi

				  
				  
				  if [ ${QTDEIMG1} -lt  1 -o ${QTDEIMG2} -lt  1  -o ${QTDEIMG3} -lt  1 ]
				  then
					  echo "NAO EXISTEM AS 3 BANDAS PRA GERAR O QUICKLOOK. COORDENADAS NAO SERAO ATUALIZADAS."
					  echo "${DIRFINAL}"  >>  ${ARQUIVOLOG}
					  echo ""
					  continue				  				  
				  fi				  				 
				  
				  
				  
				  
				  
				  NOMEQLMIN="`\ls -1 LANDSAT_5_TM_*_MIN.png`"
				  
				  cp -fv ${IMGPRINCIPAL}  ${DIRTMP}				  				  
				  cd ${DIRTMP}				  				  
				  ${CMDGZIP} -o ${IMGPRINCIPAL}
				  	
					
				  IMGAGEMTMP="`\ls -1 LANDSAT_5_TM_*.tif`"
				  
				  SIANOMESDIA="`echo ${NOMEQLMIN} | cut -f 4 -d _`"
				  SIORBITA="`echo ${NOMEQLMIN} | cut -f 5 -d _`"
				  SIPONTO="`echo ${NOMEQLMIN} | cut -f 6 -d _`"
				  
				  
				  SCENEID="L5TM${SIORBITA}${SIPONTO}${SIANOMESDIA}"				  
				  IMGAGEMGEOREF="`echo ${IMGAGEMTMP} | cut -f 1 -d .`_GEO.tif"
					
				  ${PATHGDAL}gdalwarp -t_srs EPSG:4326 -multi -of GTiff -r near -order 1 ./${IMGAGEMTMP}  ./${IMGAGEMGEOREF}
				  
				 
				  CENTERLATLON="`${CMDGDALINFO} ./${IMGAGEMGEOREF} | grep -i 'Center' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
				  TLLATLON="`${CMDGDALINFO} ./${IMGAGEMGEOREF} | grep -i 'Upper Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"
				  TRLATLON="`${CMDGDALINFO} ./${IMGAGEMGEOREF} | grep -i 'Upper Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
				  BRLATLON="`${CMDGDALINFO} ./${IMGAGEMGEOREF} | grep -i 'Lower Right' | cut -f 1 -d ')' | cut -f 2 -d '(' `"
				  BLLATLON="`${CMDGDALINFO} ./${IMGAGEMGEOREF} | grep -i 'Lower Left'  | cut -f 1 -d ')' | cut -f 2 -d '(' `"
                  
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
				  SQLSET="SET " 
				  #SQLSET="${SQLSET} CenterLatitude = ${CENTERLAT} , CenterLongitude = ${CENTERLON} ,  "
				  SQLSET="${SQLSET} Area_UL_Lat = ${TLLAT} , Area_UL_Lon = ${TLLON} , Area_UR_Lat = ${TRLAT} , Area_UR_Lon = ${TRLON} , " 
				  SQLSET="${SQLSET} Area_LL_Lat = ${BLLAT} , Area_LL_Lon = ${BLLON} , Area_LR_Lat = ${BRLAT} , Area_LR_Lon = ${BRLON}  "				  		
				  SQLWHERE="WHERE SceneId = '${SCENEID}' " 
				  		
				  SQLUPDATE="${SQLTABELA} ${SQLSET} ${SQLWHERE} ;"
				  		
				  echo "${SQLUPDATE}" > ${ARQUIVOSQL}
				  echo "" >> ${ARQUIVOSQL}
				  		
				
   				  ${CMDMYSQL} < ${ARQUIVOSQL}

				  TOTAL=$(( TOTAL + 1 ))
				  
				  echo ""
				  echo "${SQLUPDATE}"
				  echo ""
				  echo ""
				  rm -frv  ${DIRTMP}

				  
 				  echo ""
				  echo ""
				  touch ${DIRFINAL}/processado.lock
				  
				  
				fi
				
			done
				
       done
	   
	   echo ""
	   echo ""

done


echo ""
echo "TOTAL DE REGISTROS PROCESSADOS = ${TOTAL}"
echo ""

