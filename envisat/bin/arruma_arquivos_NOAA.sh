#!/bin/bash -x

# Script que arruma arquivo renomeados NOAA #
dir_exe="/home/cdsr/bin"
dir_arquivo="/L0_NOAA12"
dir_saida="/GRALHA/RECUPERACAO_DE_DADOS/DADOS_NOAA12"


if [ $1 ]
then

	ano_mes=$1

	dir_arquivo=$dir_arquivo"/"$ano_mes"/HRPT/"

	
	# Lista dos arquivos #
	cd $dir_arquivo
	ls > $dir_exe"/lista_arq"
	cd $dir_exe
	
	while read arquivos
	do
		echo $arquivos
		cp -rf $dir_arquivo"/"$arquivos $dir_exe
		
		# descompacta #
		tar zxf $arquivos
		
		# nome da pasta #
		pasta1=`echo $arquivos | cut -d "." -f1`
		pasta2=`echo $arquivos | cut -d "." -f2`
		pasta=$pasta1"."$pasta2
		
		if [ -e $arquivos ]
		then
			rm -rf $arquivos
		fi
		
		cd $pasta
		# verifica se existe o conjunto de arquivos #
		ls > $dir_exe'/lista_interna1'
		cd $dir_exe
		renomear='nao'
		ver='0'
		cd $pasta
		# vexifica se existe o conjunto de arquivos #
		ls > $dir_exe'/lista_interna2'
		cd $dir_exe
		while read internos
		do
			tipo=`echo $internos | cut -d "." -f3`
			
			if [ $tipo == 'qlk' ] || [ $tipo == 'QLK' ]
			then
				cd $pasta
				mv $internos $pasta".png"
				cd $dir_exe
				#else
					#cd $pasta
					#mv $internos $pasta"."$tipo
					#cd $dir_exe
				fi
		done < $dir_exe'/lista_interna2'
		
		# compacta #
		tar cf $pasta".tar" $pasta
		gzip $pasta".tar"
		# move para diretorio de saida #
		cd $dir_saida
		mkdir -p $ano_mes
		cd $dir_exe
		mv $pasta".tar.gz" $dir_saida"/"$ano_mes
			
		# removendo a pasta #
		cd $dir_exe
		if [ -e $pasta ]
		then
			rm -rf $pasta
		fi
		
		
		
	done < $dir_exe"/lista_arq"
fi
exit
