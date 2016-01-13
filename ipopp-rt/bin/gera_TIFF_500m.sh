#!/bin/bash -x

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Descricao: script que gera imagens 500m do satelite AQUA #
# Autor: Jose Neto
# Data: 05/2015
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#--------------------------------------------------------------------------------#
# Parametros iniciais para executar o processo - Validacao dos parametros #
#--------------------------------------------------------------------------------#
# Parametros #
parametro01=$1
parametro02=$2

# verifica se os parametros foram informados #
if [ $parametro01 ] && [ $parametro02 ]
then
	
	# verifica se existe o parametro - arquivos //
	if [ -e $parametro01 ]
	then
		# varivel de controle 01 #
		controle_processa01='ok'
	else
		controle_processa01='erro'
	fi
	
	if [ -e $parametro02 ]
	then
		# varivel de controle 02 #
		controle_processa02='ok'
	else
		controle_processa02='erro'
	fi
else
	echo "informe os parametros de execucao!"
	exit
fi
#--------------------------------------------------------------------------------#
# fim #
#--------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------#
# Verifica se esta tudo OK para realizar o processo #
#--------------------------------------------------------------------------------#

#++++++++++++++++++++++++++++++++++++#
# ERRO - INFORMAR OPERADOR DO ERRP #
#++++++++++++++++++++++++++++++++++++#
if [ $controle_processa01 == 'erro' ] && [ $controle_processa02 == 'ok' ]
then
	echo "Erro no primeiro parametro - Arquivo nao encontrado!"
	exit
fi

if [ $controle_processa01 == 'ok' ] && [ $controle_processa02 == 'erro' ]
then
	echo "Erro no segundo parametro - Arquivo nao encontrado!"
	exit
fi
if [ $controle_processa01 == 'erro' ] && [ $controle_processa02 == 'erro' ]
then
	echo "Erro em ambos os parametros - Arquivos nao encontrados!"
	exit
fi

#++++++++++++++++++++++++++++++++++++#
# PASSAGEM OK - PROCESSAR #
#++++++++++++++++++++++++++++++++++++#
if [ $controle_processa01 == 'ok' ] && [ $controle_processa02 == 'ok' ]
then
	# diretorio de saida #
	dir_out=`echo $parametro01 | cut -d "/" -f1-7`
	# nome do arquivo de saida #
	arq_out=`echo $parametro01 | cut -d "/" -f8`
	arq_out_01=`echo $arq_out | cut -d "." -f1`
	arq_out_02=`echo $arq_out | cut -d "." -f2`
	arq_out=$arq_out_01".TrueColor."$arq_out_02".tif"
	# diretorio e nome de saida do arquivo TIF #
	dir_arq_out=$dir_out"/"$arq_out
	
	#comando_01='/home/cdsr/drl/SPA/h2g/wrapper/h2g/run input.data'
	comando_exe=`/home/cdsr/drl/SPA/h2g/wrapper/h2g/run input.data $parametro01 geo $parametro02 h2gout $dir_arq_out config.type standard config.name tcolor0_005 output.type geotiff.argb`
	
fi
# /raid/pub/gsfcdata/aqua/modis/level2/MYDcreflhkm.15126162548.hdf 

#/home/cdsr/drl/SPA/h2g/wrapper/h2g/run input.data 
#/raid/pub/gsfcdata/aqua/modis/level2/MYDcreflhkm.15126162548.hdf geo 
#/raid/pub/gsfcdata/aqua/modis/level1/MYD03.15126162548.hdf h2gout 
#/raid/pub/gsfcdata/aqua/modis/level2/MYDcreflhkm_TrueColor.15126162548.tif 
#--/raid/pub/gsfcdata/aqua/modis/level2/MYDcreflhkm.TrueColor.15126162548.tif
#config.type standard config.name tcolor0_005 output.type geotiff.argb
exit

