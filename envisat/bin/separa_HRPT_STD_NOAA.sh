#!/bin/bash -x

# diretorios #
dir_exe='/home/cdsr/bin'
# dir_HRPT #
dir_hrpt='/L0_NOAA'
# diretorio de saida #
dir_out='/GRALHA/RECUPERACAO_DE_DADOS/NOAA_HRPT_STD'
# Recebe os parametros de entrada #
missao=$1
ano_mes=$2

if [ !$missao ] || [ !$ano_mes ]
then
	#diretorio completo do HRPT #
	dir_hrpt=$dir_hrpt''$missao'/'$ano_mes'/'
	
	# Primeiro o script verifica a passagem 顈RPT STD #
	# a passagem HRPT STD s󠰯ssui o arquivo HRPT, nao contem os demais arquivos #
	if [ -e $dir_hrpt'/HRPT' ] && [ -e $dir_hrpt'/7ARQ' ] 
	then
		# Gera a lista de dados #
		cd $dir_hrpt'/HRPT'
		ls S* > $dir_exe'/lista_HRPT'
		cd $dir_exe
		
		# le a lista e compara nas pastas #
		while read lista_hrpt
		do
			echo $lista_hrpt
			arquivo_hrpt=`echo $lista_hrpt`
			if [ -e $dir_hrpt'/7ARQ/'$arquivo_hrpt'.tar.gz' ] || [ -e $dir_hrpt'/7ARQ/'$arquivo_hrpt'.gz' ]
			then
				echo $arquivo_hrpt >> $dir_exe'/lista_juntar_NOAA'
			else
				cp -rf $dir_hrpt'/HRPT/'$arquivo_hrpt $dir_out
			fi
		done < $dir_exe'/lista_HRPT'
	else
		if [ -e $dir_hrpt'/HRPT' ]
		then
		# Gera a lista de dados #
			cd $dir_hrpt'/HRPT'
			ls S* > $dir_exe'/lista_HRPT'
			cd $dir_exe
			
			# le a lista e compara nas pastas #
			while read lista_hrpt
			do
				arquivo_hrpt=`echo $lista_hrpt`
				if [ -e $dir_hrpt'/HRPT/'$arquivo_hrpt'.tar.gz' ]
				then
					echo $arquivo_hrpt >> $dir_exe'/lista_juntar_NOAA'
				else
					cp -rf $dir_hrpt'/HRPT/'$arquivo_hrpt $dir_out
				fi
			done < $dir_exe'/lista_HRPT'
		
		fi
	fi
	
fi
exit
