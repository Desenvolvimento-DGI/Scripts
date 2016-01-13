#!/bin/bash 

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH



DIRATUAL=$(pwd)
PERIODO="${1}"
SATELITE="${2}"
SENSOR="${3}"
 
ANO="${4}"
MES="${5}"
#DIA="${6}"

PARORBITA="${6}"



ANOMES="${ANO}_${MES}"
DIAJULIANO="`echo ${PERIODO} | cut -c 17-19`"


ORIGEML1="/L1_LANDSAT8/L1T/"

ORIGEM="${ORIGEML1}${ANOMES}/${PERIODO}/"
DESTINO="/QUICKLOOK/LANDSAT8/${SENSOR}/"

CMDGZIP='/usr/bin/gzip ' 

LARGURAMAXIMA=132
ALTURAMAXIMA=160

PERCENTUALMINIMO=1
PERCENTUALMAXIMO=300

CMDGZIP='/usr/bin/gzip ' 
PATHGDAL='/usr/local/gdal-1.11.1/bin/'
HOMESCRIPT='/home/cdsr/l8/'
cd ${HOMESCRIPT}
 

cd ${ORIGEM}


COORDENADAS="`\ls -1r | grep -i LO8${PARORBITA}`"

for COORDATUAL in ${COORDENADAS}
do

        cd ${ORIGEM}${COORDATUAL}

        ORBITA="`echo ${COORDATUAL} | cut -c 4-6`"
        PONTO="`echo ${COORDATUAL} | cut -c 7-9`"

        DATA="`cat *_MTL.txt | grep DATE_ACQUIRED | cut -f 2 -d  = | cut -c 2-`"

        ANO="`echo ${DATA} | cut -f 1 -d '-'`"
        MES="`echo ${DATA} | cut -f 2 -d '-'`"
        DIA="`echo ${DATA} | cut -f 3 -d '-'`"


        SCENEID="${SATELITE}${SENSOR}${ORBITA}${PONTO}${ANO}${MES}${DIA}"
        QLPADRAO="QL_${SCENEID}"

        ${CMDGZIP} -f -d -v -S .zip *_B6.TIF.zip
        ${CMDGZIP} -f -d -v -S .zip *_B5.TIF.zip
        ${CMDGZIP} -f -d -v -S .zip *_B4.TIF.zip

        IMG1="`\ls -1 L*_B6.TIF`"
        IMG2="`\ls -1 L*_B5.TIF`"
        IMG3="`\ls -1 L*_B4.TIF`"

        NOMEPADRAO="`echo ${IMG1} | cut -f 1 -d _`"


        TIFFSAIDA="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_FULL.tif"
        TIFFSAIDA8BITS="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_8BITS.tif"                        
        TIFFSAIDA8BITSGEO="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_GEO_8BITS.tif"
        TIFFSAIDA8BITSGEOTMP="${ORIGEM}${COORDATUAL}/${NOMEPADRAO}_GEO_8BITS_TMP.tif"

        QLSAIDAMIN="${DESTINO}${QLPADRAO}_MIN.png"
        QLSAIDAPEQ="${DESTINO}${QLPADRAO}_PEQ.png"
        QLSAIDAMED="${DESTINO}${QLPADRAO}_MED.png"
        QLSAIDAGRD="${DESTINO}${QLPADRAO}_GRD.png"

        echo ""
        echo ""



	if [ -e "${ORIGEM}${COORDATUAL}/processado.lock" ]
	then
		continue
	fi


	#rm -fv {TIFFSAIDA8BITS} ${TIFFSAIDA8BITSGEO} ${TIFFSAIDA}

        #if [ ! -e ${TIFFSAIDAGEO8BITS} ]
        #then


                rm -fv ${TIFFSAIDA}

                ${CMDGZIP} -f -d -v -S .zip *_B6.TIF.zip
                ${CMDGZIP} -f -d -v -S .zip *_B5.TIF.zip
                ${CMDGZIP} -f -d -v -S .zip *_B4.TIF.zip
                echo ""

                ${PATHGDAL}gdal_merge.py -of GTIFF -o ${TIFFSAIDA} -separate ${IMG1} ${IMG2} ${IMG3}
		#${PATHGDAL}gdalwarp -t_srs EPSG:4326 -of GTIFF ${TIFFSAIDA} ${TIFFSAIDAGEO}
                #${PATHGDAL}gdal_translate -ot Byte -scale -b 1 -b 2 -b 3 ${TIFFSAIDAGEO} ${TIFFSAIDAGEO8BITS}
				
		${PATHGDAL}gdal_translate -of GTIFF -ot Byte -scale ${TIFFSAIDA} ${TIFFSAIDA8BITS}
		${PATHGDAL}gdalwarp -of GTIFF -t_srs EPSG:4326  ${TIFFSAIDA8BITS} ${TIFFSAIDA8BITSGEO}
                
				

        #fi

        RESOLUCAO="`${PATHGDAL}gdalinfo  ${TIFFSAIDA8BITSGEO} | grep -i 'Size is' | cut -c 9-22 `"
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

        ${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize ${LARGURAQL} ${ALTURAQL} ${TIFFSAIDA8BITSGEO} ${QLSAIDAMIN}

        # Quicklook com resoluçequena de pixels 
        ${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize 3% 3% ${TIFFSAIDA8BITSGEO} ${QLSAIDAPEQ}

        # Quicklook com resoluçedia de pixels 
        ${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize 6% 6% ${TIFFSAIDA8BITSGEO} ${QLSAIDAMED}

        # Quicklook com resoluçrande de pixels 
        ${PATHGDAL}gdal_translate -of PNG -a_nodata 0 -outsize 10% 10% ${TIFFSAIDA8BITSGEO} ${QLSAIDAGRD}


        rm -fv "${QLSAIDAMIN}*.xml"
        rm -fv "${QLSAIDAPEQ}*.xml"
        rm -fv "${QLSAIDAMED}*.xml"
        rm -fv "${QLSAIDAGRD}*.xml"



        cp -fv ${QLSAIDAMIN} ${ORIGEM}${COORDATUAL}
        cp -fv ${QLSAIDAGRD} ${ORIGEM}${COORDATUAL}

        


        ${CMDGZIP} -f -v -S .zip *_B1*.TIF
        ${CMDGZIP} -f -v -S .zip *_B2*.TIF
        ${CMDGZIP} -f -v -S .zip *_B3*.TIF
        ${CMDGZIP} -f -v -S .zip *_B4*.TIF
        ${CMDGZIP} -f -v -S .zip *_B5*.TIF
        ${CMDGZIP} -f -v -S .zip *_B6*.TIF
        ${CMDGZIP} -f -v -S .zip *_B7*.TIF
        ${CMDGZIP} -f -v -S .zip *_B8*.TIF
        ${CMDGZIP} -f -v -S .zip *_B9*.TIF
        ${CMDGZIP} -f -v -S .zip *_BQA*.TIF


        #rm -f ${TIFFSAIDA} ${TIFFSAIDAGEO}
        rm -fv ${TIFFSAIDA} ${TIFFSAIDA8BITS} ${TIFFSAIDA8BITSGEOTMP} 

        echo ""
        echo ""
        echo ""

done

cd ${DIRATUAL}
		
