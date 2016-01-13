#!/bin/bash

DIRATUAL=$(pwd)
DIRSCRIPTS="/home/cdsr/npp"
ORIGEM="/raid/pub/gsfcdata/npp/viirs/level1"
DESTINO="/L2_NPP"
ARQUIVOLOG="${DIRSCRIPTS}/.copia.log"

cd ${ORIGEM}
PERIODOS=$(ls -F1 *.h5 | cut -f 3-4 -d '_' | sort | uniq)

echo "`date` :: Inicio da execucao" > ${ARQUIVOLOG}

for PERIODOATUAL in ${PERIODOS}
do

	echo "${PERIODOATUAL}"

    # Gera o nome do diretorio no padrao AAAAMMDD_hhmmsss
    DATAATUAL=$(echo $PERIODOATUAL | cut -c 2-9)
    HORAATUAL=$(echo $PERIODOATUAL | cut -c 12-18)
	
	ANOATUAL=$(echo $DATAATUAL | cut -c 1-4)
	MESATUAL=$(echo $DATAATUAL | cut -c 5-6)
	DIAATUAL=$(echo $DATAATUAL | cut -c 7-8)

	HRAATUAL=$(echo $HORAATUAL | cut -c 1-2)
	MINATUAL=$(echo $HORAATUAL | cut -c 3-4)
	SEGATUAL=$(echo $HORAATUAL | cut -c 5-6)

	echo "ANO ATUAL = $ANOATUAL"
	echo "MES ATUAL = $MESATUAL"
	echo "DIA ATUAL = $DIAATUAL"


	echo "HRA ATUAL = $HRAATUAL"
	echo "MIN ATUAL = $MINATUAL"
	echo "SEG ATUAL = $SEGATUAL"
			
    DIRETORIOATUAL="NPP_VIIRS.${ANOATUAL}_${MESATUAL}_${DIAATUAL}.${HRAATUAL}_${MINATUAL}_${SEGATUAL}"
	DESTINOATUAL="${DESTINO}/${ANOATUAL}_${MESATUAL}/${DIRETORIOATUAL}"
    
	echo "${DIRETORIOATUAL}"
	echo "${DESTINOATUAL}"
	
	echo ""
	
	
	echo "`date` :: Diretorio atual : ${DIRETORIOATUAL}" >> ${ARQUIVOLOG}		
	
	# cria o diretorio se o mesmo nao existir
    if [ ! -d "${DESTINOATUAL}" ]
    then		
        mkdir "${DESTINOATUAL}"
	chmod 777 "${DESTINOATUAL}"
		echo "Criado diretorio ${DESTINOATUAL}"
    fi

	# Gera a data do periodo atual em formati Juliano
    ANOJULIANO=$(echo ${DATAATUAL} | cut -c 3-4)
	DIAJULIANO=$(date +"%j" -d "${DATAATUAL}")
	
	HORARIOATUALCORRIGIDO=$(echo ${HORAATUAL} | cut -c 1-6)
	# Gera o periodo a ser utilizado para filtrar os arquivos TIFF
	PERIODOJULIANO="${ANOJULIANO}${DIAJULIANO}${HORARIOATUALCORRIGIDO}"

	
	# Gerar a mascara para obter os arquivos H5 e TIFF para o perío atual
	ARQUIVOSH5=" *_${PERIODOATUAL}_*.h5 "
	ARQUIVOSTIFF=" NPP*.${PERIODOJULIANO}.tif "
	
	# Realiza a copia dos arquivos para o diretó criado
	cp -vn ${ARQUIVOSH5}  ${DESTINOATUAL}
	cp -vn ${ARQUIVOSTIFF}  ${DESTINOATUAL}
	
	chmod -R 777  ${DESTINOATUAL}
	
	
	echo "`date` :: Diretorio atual : ${DIRETORIOATUAL} [OK]" >> ${ARQUIVOLOG}	
	echo "" >> ${ARQUIVOLOG}	
	
	echo ""
	echo ""

done

echo "`date` :: Termino da execucao" >> ${ARQUIVOLOG}	

