#!/bin/bash -x

# Autor: José Neto
# Data: 2014-07
# Versao: 2.0

# Script pega os dados do formato DSA e converte para o formato CDSR #

# Diretorio execução #
dir_exe="/home/cdsr/bin"
# Diretorio de saida #
dir_out="/GRALHA/RECUPERACAO_DE_DADOS/Dados_formato_CDSR"

# parametros recebidos no comando #
satelite=$2
ano_mes=$1

if [ $satelite ] && [ $ano_mes ]
then

	#diretorio de entrada #
	dir_hrpt='/L0_'$satelite'/'$ano_mes'/HRPT/'
	dir_7arq='/L0_'$satelite'/'$ano_mes'/7ARQ/'
	# verifica se existe o arquivo #
	if [ -e $dir_hrpt ] && [ -e $dir_7arq ]
	then
		# Gera a lista de arquivos 7ARQ #
		cd $dir_7arq
		ls *".tar.gz"> $dir_exe'/lista7Arq'
		cd $dir_exe
		# lendo a lista #
		while read arq7
		do
			nome_c=`echo $arq7 | cut -d "." -f1`
			prefixo=`echo $nome_c | cut -d "_" -f1`
			sulfixo=`echo $nome_c | cut -d "_" -f2`
			
			nome_velho=$prefixo"_"$sulfixo
			
			# variaveis #
			yy=`echo $sulfixo | cut -c1-4`
			mm=`echo $sulfixo | cut -c5-6`
			dd=`echo $sulfixo | cut -c7-8`
			hh=`echo $sulfixo | cut -c9-10`
			mi=`echo $sulfixo | cut -c11-12`
			ss='00'
			
			# Buscando a ERG #
			# decodificando o prefixo com base na tabela da DSA #
			while read tabela
			do
				prefixo_tabela=`echo $tabela | cut -d ";" -f4`
				
				if [ $prefixo == $prefixo_tabela ]
				then
					erg=`echo $tabela | cut -d ";" -f3`
					sat_tabela=`echo $tabela | cut -d ";" -f2`
					break;
				fi
				
			done < $dir_exe"/tabelaNOAA.txt"
			
			# Nome no padrão novo #
			nome_novo=$sat_tabela"_HRPT_"$yy"_"$mm"_"$dd"."$hh"_"$mi"_"$ss"_"$erg
			
			# copiando o arquivo #
			cd $dir_exe
			mkdir $nome_novo
			cd $nome_novo
			cp -rf $dir_7arq"/"$arq7 .
			#descompactanto#
			#gzip -d $arq7
			tar zxf $nome_velho".tar.gz"
			rm -rf $nome_velho".tar.gz"
			#exit
						
			#renomeando a pasta #
			ls > $dir_exe'/listaArqRenomear'
			while read arquivos_rename
			do
				tipo=`echo $arquivos_rename | cut -d "." -f2`
				mv """$arquivos_rename""" $nome_novo"."$tipo
				
			done < $dir_exe'/listaArqRenomear'
			
			cd $dir_exe
			
			# compactando e enviando para a saida #
			tar cf $nome_novo".tar" $nome_novo
			gzip $nome_novo".tar"
			rm -rf $nome_novo
			
			mkdir -p $dir_out"/"$satelite"/"$ano_mes
			mv $nome_novo".tar.gz" $dir_out"/"$satelite"/"$ano_mes"/"
			cd $dir_exe
			
		done < $dir_exe'/lista7Arq'
		
	fi


fi

exit
