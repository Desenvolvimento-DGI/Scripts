#!/bin/bash 

# Script processa dados TERRA
# 04/03/2013
# Versao 1.0
	if [ $1 ]
	then  
	  echo "INICIO DO PROCESSAMENTO DOS DADOS $1"
	  cd /home/ipopp/drl/rt-stps/
	  ./bin/batch.sh config/terra.xml $1
	  cd -
	  echo "FIM DO PROCESSAMENTO DO DADOS $1"
	
	else 
	echo "por favor insira o caminho"
	echo "exemplo:"
	echo "processa_modis_terra.sh /L0_TERRA/2013_01/MODIS/teradb.20130117.133300.64.terra-1.cadu"
	fi
