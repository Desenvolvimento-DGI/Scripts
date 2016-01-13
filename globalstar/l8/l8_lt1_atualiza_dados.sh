#!/bin/bash

PATH=/bin:/sbin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH


DIRATUAL=$(pwd)
ORIGEM='/L1_LANDSAT8/L1T/'
CONTADOR=0
 
SATELITE="L8"
SENSOR="OLI"

PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/l8/'

CMDGDALWARP='${PATHGDAL}gdalwarp -t_srs EPSG:4291 -multi -of GTiff -r near -order 1 '
CMDREMOVER='/usr/bin/rm -fv '
CMDGDALINFO="${PATHGDAL}gdalinfo -proj4 "
CMDZIP='/usr/bin/gzip -f -v -S .zip '
CMDQL="${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize "
CMDREMOVERARQS=""
CMDMYSQL='/usr/bin/mysql --login-path=catalogo-gerente '

NUMPID="$$"

ARQUIVOSQL="/home/cdsr/l8/UPDATEL8OLI_${NUMPID}.sql"

QLORIGEM="/QUICKLOOK/LANDSAT8/OLI/"
CMDPHP="/usr/local/web/php-5.6.1/bin/php "
AREASCRIPTS="/home/cdsr/l8/"



echo "" > ${ARQUIVOSQL}

AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} ATUALIZA DADOS LANDSAT8 :: INICIO" 


# Diretórganizados por ano e mes
cd ${ORIGEM}

LISTAANOMES="`\ls -1F ${ORIGEM} | sort`"

for AMATUAl in ${LISTAANOMES}
do
	echo ""
	echo "ANO E MES ATUAL  =  ${AMATUAl}"
	
	cd "${ORIGEM}${AMATUAl}"	
	LISTAPERIODOS="`\ls -1F | sort`"	
	
	for PERIODOATUAl in ${LISTAPERIODOS}
	do	
		cd "${ORIGEM}${AMATUAl}${PERIODOATUAl}"
				
 
		#
		# Coordenadas
		
		LISTACOORDENADAS="`\ls -1F | grep -i ^LO8`"
		# echo "${LISTAPERIODOS}"
		
		for COORDENADAATUAL in ${LISTACOORDENADAS}
		do		
			echo "" > ${ARQUIVOSQL}			
		
			cd "${ORIGEM}${AMATUAl}${PERIODOATUAl}${COORDENADAATUAL}"
		
			NOMEARQUIVO="`\ls -1 *_MTL.txt`"
			# Caso nao exista o arquivo referente a imagem
			if [ "${NOMEARQUIVO}" == "" ]
			then	

				AGORA=`date +"%Y/%m/%d %H:%M:%S"`
				echo "${AGORA} ${AMATUAl} - ${PERIODOATUAl} - ${COORDENADAATUAL}- SEM ARQUIVO METADADOS NA AREA" 
				echo ""
				cd ..
				continue		
			fi
		
					
			DATA="`cat *_MTL.txt | grep DATE_ACQUIRED | cut -f 2 -d  = | cut -c 2-`"
			
			ANO="`echo ${DATA} | cut -f 1 -d '-'`"
			MES="`echo ${DATA} | cut -f 2 -d '-'`"
			DIA="`echo ${DATA} | cut -f 3 -d '-'`"			
			
			COORDENADAATUAL="`echo ${COORDENADAATUAL} | cut -f 1 -d '/'`"
			ORBITA="`echo ${COORDENADAATUAL} | cut -c 4-6`"
			PONTO="`echo ${COORDENADAATUAL} | cut -c 7-9`"
			
			SCENEID="${SATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}"

			# Nota da imagem 
			IMAGECLOUDCOVER="`cat *_MTL.txt | grep 'CLOUD_COVER' | cut -f 2 -d '=' | cut -c 2-`"	
			
			# Nota relativo ao percentual de cobertura de nuvens da imagem toda	
			IMAGEQUALITY="`cat *_MTL.txt | grep 'IMAGE_QUALITY_' | cut -f 2 -d '=' | cut -c 2-`"	
						
						
			SQLTABELA="UPDATE catalogo.Scene "								
			SQLSET=" SET Image_CloudCover = ${IMAGECLOUDCOVER}, Image_Quality = ${IMAGEQUALITY}  "					
			SQLWHERE=" WHERE SceneId = '${SCENEID}' "
					
			SQLUPDATE="${SQLTABELA} ${SQLSET} ${SQLWHERE} ;"
					
			echo "${SQLUPDATE}" >> ${ARQUIVOSQL}										
			${CMDMYSQL} < ${ARQUIVOSQL}
		
			CONTADOR=$(($CONTADOR+1))		
		    
			echo "SCENEID =  ${SCENEID}    -   IMAGEM PROCESSADA COM SUCESSO."
			cd ..
	
		done
		
		cd ..
	
	done
		
	cd ${ORIGEM}
	
	echo ""
	echo ""

done

${CMDREMOVER} ${ARQUIVOSQL}

AGORA=`date +"%Y/%m/%d %H:%M:%S"`
echo "${AGORA} ATUALIZADOS DADOS LANDSAT8 :: TERMINO" 
echo "" 

cd ${DIRATUAL}


echo ""
echo "TOTAL DE REGISTROS IDENTIFICADOS = $CONTADOR"
echo ""


