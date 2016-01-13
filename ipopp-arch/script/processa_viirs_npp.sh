#!/bin/bash 

# Script processa dados TERRA
# 04/03/2013
# Versao 1.0
	if [ $1 ]
	then  
	  echo "INICIO DO PROCESSAMENTO DOS DADOS $1"
	  cd /home/ipopp/drl/rt-stps/
	  ./bin/batch.sh config/npp.xml $1
	  cd -
	  echo "FIM DO PROCESSAMENTO DO DADOS $1"
	
	else 
	echo "por favor insira o caminho"
	echo "exemplo:"
	echo "processa_modis_npp.sh /RAW_NPP/2013_04/VIIRS/NPP_RAW_2013_04_29.06_09_00"
	fi
