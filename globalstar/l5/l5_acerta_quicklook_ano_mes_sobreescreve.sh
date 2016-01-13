#!/bin/bash

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH

PARANO="${1}"
PARMES="${2}"



DIRQL="/QUICKLOOK/LANDSAT5/TM/"
HOMESCRIPT='/home/cdsr/l5/'

FINAL="2_BC_UTM_WGS84"
TOTAL=0

cd /L2_LANDSAT5

LISTAANOS="`\/bin/ls -1r | grep ${PARANO}_${PARMES}`"

for ANOATUAL in ${LISTAANOS}
do

       cd /L2_LANDSAT5/${ANOATUAL}

       pwd

	   ANOQL="`echo ${ANOATUAL} | cut -f 1 -d _`"
	   MESQL="`echo ${ANOATUAL} | cut -f 2 -d _`"
	   QL_ANOMES="`echo ${ANOATUAL} | cut -f 1-2 -d _`"
	   
       ARQS="`\/bin/ls -1r | grep -i ^LANDSAT5 `"

       for ARQATUAL in ${ARQS}
       do
	   
			DIAQL="`echo ${ARQATUAL} | cut -c 19-20`"
	   
			cd /L2_LANDSAT5/${ANOATUAL}/${ARQATUAL}
			
			LISTAORBITASPONTO="`/bin/ls -1r | grep -i _`"
			for ORBITAPONTOATUAL in ${LISTAORBITASPONTO}
			do

				
				DIRFINAL="/L2_LANDSAT5/${ANOATUAL}/${ARQATUAL}/${ORBITAPONTOATUAL}/${FINAL}"
				if [ -d "${DIRFINAL}" ]
				then
				
                  cd ${DIRFINAL}
                  pwd
				  
				  
				  				  				  				  
				  QLGRDNOME="`\ls -1 *_GRD.png`"
				  QLGRD="${DIRFINAL}/${QLGRDNOME}"
				  
				  if [ -f "${QLGRD}" ]
				  then

					  TOTAL=$(( TOTAL + 1 ))
					  
					  
					  echo "LANDSAT-5  :: PROCESSANDO QUICKLOOK DO ANO E MES = ${ANOATUAL}"
					  echo "PERIODO = ${ARQATUAL}   -   ORBITA E PONTO  = ${ORBITAPONTOATUAL}"
					
					  mkdir -p  ${DIRQL}${QL_ANOMES}

	  				  QLORBITA="`echo ${ORBITAPONTOATUAL} | cut -f 1 -d _`"
	  				  QLPONTO="`echo ${ORBITAPONTOATUAL} | cut -f 2 -d _`"

					
					  NOMEQLPADRAO="L5TM${QLORBITA}${QLPONTO}${ANOQL}${MESQL}${DIAQL}"
					  
					  QLSAIDAMIN="`\ls -1 *_MIN.png`"
					  QLSAIDAPEQ="`\ls -1 *_PEQ.png`"
					  QLSAIDAMED="`\ls -1 *_MED.png`"
					  QLSAIDAGRD="`\ls -1 *_GRD.png`"

					  NOVOQLSAIDAMIN="QL_${NOMEQLPADRAO}_MIN.png"
					  NOVOQLSAIDAPEQ="QL_${NOMEQLPADRAO}_PEQ.png"
					  NOVOQLSAIDAMED="QL_${NOMEQLPADRAO}_MED.png"
					  NOVOQLSAIDAGRD="QL_${NOMEQLPADRAO}_GRD.png"
					  
					  
					  

					  cp -fv  ${DIRFINAL}/${QLSAIDAMIN}   ${DIRQL}${QL_ANOMES}/${NOVOQLSAIDAMIN}
					  cp -fv  ${DIRFINAL}/${QLSAIDAPEQ}   ${DIRQL}${QL_ANOMES}/${NOVOQLSAIDAPEQ}
					  cp -fv  ${DIRFINAL}/${QLSAIDAMED}   ${DIRQL}${QL_ANOMES}/${NOVOQLSAIDAMED}
					  cp -fv  ${DIRFINAL}/${QLSAIDAGRD}   ${DIRQL}${QL_ANOMES}/${NOVOQLSAIDAGRD}
					  
					  
					  echo ""
					  
				  fi
				  
				  
				  
				fi
				
			done
				
       done
   

done

echo ${TOTAL}

