#!/bin/bash

# Script processa dados AQUA
# 04/03/2013
# Versao 1.0
	if [ $1 ]
	then  
	  echo "INICIO DO PROCESSAMENTO DOS DADOS $1"
	  cd /home/cdsr/drl/rt-stps/
	  ./bin/batch.sh config/aqua.xml $1
	  cd -
	  echo "FIM DO PROCESSAMENTO DO DADOS $1"
	
	else 
	echo "por favor insira o caminho"
	echo "exemplo:"
	echo "processa_modis_aqua.sh /L0_AQUA1/2013_01/MODIS/aquadb.20130101.175830.64.aqua-1.cadu"
	fi
