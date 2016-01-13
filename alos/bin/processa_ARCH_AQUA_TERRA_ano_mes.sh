#!/bin/bash

# Script que dispara o processo AQUA e TERRA por ano_mes #
# Autor: Jose Neto #
# Data: 12/2013 #

# Diretorio de execucao #
dir_exe=/home/cdsr/bin

if [ $# != 3 ]; then
	echo -e '\e[31;1m EXECUCAO INCORRETA. FORMA CORRETA: '$0' SATELITE ANO MES \e[m';
	echo " "
	exit;
fi

sat=$1
ano=$2
mes=$3

if [ $sat != 'AQUA' ] && [ $sat != 'TERRA' ]
then
	echo -e '\e[31;1m SATELITE INCORRETO'$satelite' \e[m';
	echo -e '\e[31;1m INFORME AQUA OU TERRA \e[m';
	exit;
fi
# Validando o parametro Data #
# ANO - deve conter 4 digitos #
ano_valida=`echo ${#ano}`
if [ $ano_valida -lt 4 ]
then
	echo -e '\e[31;1m PARAMETRO ANO INFORMADO INCORRETAMENTE: '$ano' \e[m';
	exit;
fi
# MES - deve conter 2 digitos #
mes_valida=`echo ${#mes}`
if [ $mes_valida -lt 2 ] || [ $mes -ge 13 ] || [ $mes -eq 00 ]
then
	echo -e '\e[31;1m PARAMETRO MES INFORMADO INCORRETAMENTE: '$mes' \e[m';
	exit;
fi
# ./processa_modis_aqua.sh /L0_AQUA/2013_05/MODIS/aquadb.20130520.174010.64.aqua-1.cadu

# Diretorio de busca #
if [ $sat == 'AQUA' ]
then
	dir_arq="/L0_"$sat"/"$ano"_"$mes"/MODIS/"
	# Gera a lista de arquivos da pasta #
	cd $dir_arq
	ls > $dir_exe"/filesArq"
	cd $dir_exe
	# Lendo a lista de arquivos #
	while read files
	do
		echo $files
		echo -e '\e[34;1m EXECUTANDO: processa_modis_aqua.sh '$dir_arq''$files' \e[m';
		cd $dir_exe
		#./processa_modis_aqua.sh $dir_arq''$files
		
		# Script processa dados AQUA
		# 04/03/2013
		# Versao 1.0
		#if [ $1 ]
		#then  
		echo "INICIO DO PROCESSAMENTO DOS DADOS $1"
		cd /home/cdsr/rt-stps/
		./bin/batch.sh config/aqua.xml $dir_arq''$files
			#./bin/batch.sh config/aqua.xml $1
		cd -
		echo "FIM DO PROCESSAMENTO DO DADOS $1"
			
			#else 
			#echo "por favor insira o caminho"
			#echo "exemplo:"
			#echo "processa_modis_aqua.sh /L0_AQUA1/2013_01/MODIS/aquadb.20130101.175830.64.aqua-1.cadu"
			#fi
		# Fim do processo AQUA #
		
		sleep 4000
	done < $dir_exe"/filesArq"

fi

if [ $sat == 'TERRA' ]
then
	dir_arq="/L0_"$sat"/"$ano"_"$mes"/MODIS/"
	# Gera a lista de arquivos da pasta #
	cd $dir_arq
	ls > $dir_exe"/filesArq"
	cd $dir_exe
	# Lendo a lista de arquivos #
	while read files
	do
		echo $files
		echo -e '\e[34;1m EXECUTANDO: processa_modis_terra.sh '$dir_arq''$files' \e[m'; 
		cd $dir_exe
		#./processa_modis_terra.sh $dir_arq''$files
		
		# Script processa dados TERRA
		# 04/03/2013
		# Versao 1.0
		#if [ $1 ]
		#then  
		echo "INICIO DO PROCESSAMENTO DOS DADOS $1"
		cd /home/cdsr/rt-stps/
		./bin/batch.sh config/terra.xml $dir_arq''$files
		#./bin/batch.sh config/terra.xml $1
		cd -
		echo "FIM DO PROCESSAMENTO DO DADOS $1"
			
		#else 
		#echo "por favor insira o caminho"
		#echo "exemplo:"
		#echo "processa_modis_terra.sh /L0_TERRA/2013_01/MODIS/teradb.20130117.133300.64.terra-1.cadu"
		#fi
		# Fim do processo TERRA #
		
		sleep 4000
	done < $dir_exe"/filesArq"
fi


