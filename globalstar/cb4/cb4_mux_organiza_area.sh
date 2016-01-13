#!/bin/bash 

ORIGEM="${1}"
PERIODO="${2}"

AREACOMPLETA="${ORIGEM}${PERIODO}"

if [ ! -d "${AREACOMPLETA}" ]
then
	echo "AREA ${AREACOMPLETA}   NAO EXISTE"
	exit 0
fi

clear
DIRATUAL="`pwd`"

DESTINO="/L2_CBERS4/"
DIRSCRIPT="/home/cdsr/cb4/"
DIRPARTEFINAl='2_NN_UTM_WGS84'

IDSATELITE="CB4"
SATELITE="CBERS4"
MISSAO="4"
SENSOR="MUX"



echo ""
echo "ORIGEM  = ${ORIGEM}"
echo "PERIODO = ${PERIODO}"
echo ""
echo "AREACOMPLETA = ${AREACOMPLETA}"
echo ""



cd ${AREACOMPLETA}
DIRS="`\ls -1`"
PRIMEIRO='S'


for PONTOATUAL in ${DIRS}
do
 
   cd ${AREACOMPLETA}/${PONTOATUAL}
   pwd
      
   
   TIF="`ls -1 *.TIF`"
 
   ORBITA="`echo ${TIF} | cut -f 3 -d -`"
   ROW="`echo ${TIF} | cut -f 4 -d -`"
 
   NORBITA="${ORBITA}"
   NROW="${ROW}"
 
 
   NORBITA=$((NORBITA + 1000))
   NORBITA="`echo ${NORBITA} | cut -c 2-`"

   NROW=$((NROW + 1000))
   NROW="`echo ${NROW} | cut -c 2-`"


   if [ "${PRIMEIRO}" == "S" ]
   then
   
	   DATACOMPLETA="`echo ${TIF} | cut -f 5 -d -`"
	   ANO="`echo ${DATACOMPLETA} | cut -c 1-4`"
	   MES="`echo ${DATACOMPLETA} | cut -c 5-6`"
	   DIA="`echo ${DATACOMPLETA} | cut -c 7-8`"
	   
	   ANOMES="${ANO}_${MES}"
		  	   
	   ARQMETADADOS="`ls -1 *.XML`"	   
	   SCENEDATE="`cat ${ARQMETADADOS} | grep -i '<sceneDate>' | sed -e 's/<[^>]*>//g' | cut -f 1 -d .`"
	   
	   HRA="`echo ${SCENEDATE} | cut -c 12-13`"
	   MIN="`echo ${SCENEDATE} | cut -c 15-16`"
	   SEG="`echo ${SCENEDATE} | cut -c 18-19`"
	   
	   HORAPASSSAGEM="${HRA}${MIN}${SEG}"
	   
	   PERIODOPADRONIZADO="${SATELITE}_${SENSOR}_${ANO}${MES}${DIA}.${HRA}${MIN}${SEG}"
	   
	   PRIMEIRO="N"	
   fi
 
   echo ""
   echo "VARIAVEIS"
   echo ""
   
   echo "ORIGEM  = ${ORIGEM}"
   echo "PERIODO = ${PERIODO}"
   echo "AREACOMPLETA = ${AREACOMPLETA}"
   echo ""
   echo "ANO = ${ANO}"
   echo "MES = ${MES}"
   echo "DIA = ${DIA}"
   echo ""
   echo "HRA = ${HRA}"
   echo "MIN = ${MIN}"
   echo "SEG = ${SEG}"
   echo ""
   echo "ANOMES = ${ANOMES}"
   echo "PRIMEIRO = ${PRIMEIRO}"
   echo ""
   echo "PERIODOPADRONIZADO = ${PERIODOPADRONIZADO}"
   
   
   echo ""
   echo ""
   
 
   LISTAARQUIVOS="`\ls -1 `"

   for AATUAL in ${LISTAARQUIVOS}	
   do
   
 
	   NOMEARQ_INICIO="`echo ${AATUAL} | cut -f 1-2 -d -`"
	   NOMEARQ_FINAL="`echo ${AATUAL} | cut -f 5- -d -`"
	 
	   NOVONOME="${NOMEARQ_INICIO}-${NORBITA}-${NROW}-${NOMEARQ_FINAL}"	 
	   mv -fv  ${AATUAL}  ${NOVONOME}   
   done
   
   
   LISTAARQUIVOSNOVOS="`\ls -1`"
   
   mkdir -p ${DIRPARTEFINAl}
   mv -fv ${LISTAARQUIVOSNOVOS}  ${DIRPARTEFINAl}
   
   ORBITAPONTO="${NORBITA}_${NROW}_0" 
   
   cd ${AREACOMPLETA}  
   mv -fv ${PONTOATUAL} ${ORBITAPONTO}
   
   echo ""
   echo ""
   echo ""
 
done

echo ""
echo ""
cd ${ORIGEM}
mv -fv ${PERIODO}  ${DESTINO}${ANOMES}/${PERIODOPADRONIZADO}
echo ""

cd ${DIRATUAL}

