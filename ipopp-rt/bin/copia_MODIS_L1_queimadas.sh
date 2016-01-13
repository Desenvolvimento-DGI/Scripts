#!/bin/bash

# Script para copiar dados MODIS para o grupo de QUEIMADAS


# 10/09/2013
# Versao 1.0

sat=$1
source /home/cdsr/.bashrc

if [ ${sat} == AQUA ] || [ ${sat} == TERRA ]
	then
	if [ ${sat} == AQUA ] 
	  then
	  sat_min=aqua  
	else 
	  sat_min=terra
	fi 

	cd  /raid/pub/gsfcdata/${sat_min}/modis/level1/

	echo "Inicio do Processamento.:..."

	for arq in $(/bin/ls M*)
 	do  
  	dir_saida=$(echo ${arq} | cut -f2 -d '.')
  	prefix=$(echo ${arq} | cut -f1 -d '.')
  	sufix=$(echo ${arq} | cut -f3 -d '.')

	 #acertar DATA
	yyyy=$(echo ${dir_saida} | cut -c 1-2)
  	ddd=$(echo ${dir_saida} | cut -c 3-5)
  	hh=$(echo ${dir_saida} | cut -c 6-7)
  	mm=$(echo ${dir_saida} | cut -c 8-9)
  	ss=$(echo ${dir_saida} | cut -c 10-11)

	 # converte para dia Gregoriano
 	ano=$(date -d "20${yyyy}-01-01 + ${ddd} days -1 day" +%Y)
 	mes=$(date -d "20${yyyy}-01-01 + ${ddd} days -1 day" +%m)
 	dia=$(date -d "20${yyyy}-01-01 + ${ddd} days -1 day" +%d)
 
	 # cria diretorio e move arquivos 
 	echo " ${ano}_${mes}_${dia}.${hh}_${mm}_${ss}"
 	mkdir -p /L1_${sat}/${ano}_${mes}/hdf/${sat}_MODIS_${ano}${mes}${dia}_${hh}${mm}${ss}
 	cp  -n ${arq} /L1_${sat}/${ano}_${mes}/hdf/${sat}_MODIS_${ano}${mes}${dia}_${hh}${mm}${ss}/${sat}.${prefix}.${ano}_${mes}_${dia}.${hh}_${mm}_${ss}.${sufix}
	#echo /L1_${sat}1/${ano}_${mes}/hdf/${sat}_MODIS_${ano}${mes}${dia}_${hh}${mm}${ss}/${sat}.${prefix}.${ano}_${mes}_${dia}.${hh}_${mm}_${ss}.${sufix}
	done
	cd /home/cdsr/bin
 else 
        echo "Por favor digitar o Satelite Correto"
        echo " Exemplo:"  
        echo " GOES12 "
        echo " GOES13 "
        echo " Obs:. Todas as letras devem estar em MAIUSCULO"
        exit
fi

echo "Fim do Processamento.:..." 
exit 0
