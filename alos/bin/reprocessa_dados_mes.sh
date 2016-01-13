#!/bin/bash 
#-------------

yyyy_mm=$1
sat=$2
sat_min=$(echo ${sat} | tr '[:upper:]' '[:lower:]')
sat_mai=$(echo ${sat} | tr '[:lower:]' '[:upper:]')

dir_entrada="/mnt/cluster/${sat_mai}/${yyyy_mm}/MODIS/"


echo "Inicio do Reprocessamento"

# identificando satelite

if [ ${sat_mai} == "AQUA" ]||[ ${sat_mai} == "TERRA" ]||[ ${sat_mai} == "NPP" ]; then
  if [ ${sat_mai} == "NPP" ]; then
	dir_entrada="/mnt/cluster/${sat_mai}/${yyyy_mm}/VIIRS/"
  fi	

# copia dos auxiliares
ano=$(echo ${1} |cut -c 1-4)
mes=$(echo ${1} |cut -c 6-7)
cp /mnt/cluster/TERRA/DRLAncillary/*${ano}-${mes}* /raid/pub/CompressedArchivedAncillary/
/home/cdsr/drl/reprocessing/ingest-ancillaries.sh

	
# criar lista de arquivos 
	for lista_dado  in $(ls ${dir_entrada})
	do
	  echo ${lista_dado}
 	  if [ ${sat_mai} = "AQUA" ]; then	
	    /home/cdsr/bin/processa_modis_aqua.sh  ${dir_entrada}/${lista_dado}
          elif [ ${sat_mai} = "TERRA" ]; then
	    /home/cdsr/bin/processa_modis_terra.sh ${dir_entrada}/${lista_dado} 
	  else 
            /home/cdsr/bin/processa_viirs_npp.sh ${dir_entrada}/${lista_dado}	
	  fi
	done
else
echo "Por Favor verifique o nome do satelite"
fi
rm -rf /raid/pub/CompressedArchivedAncillary/*
