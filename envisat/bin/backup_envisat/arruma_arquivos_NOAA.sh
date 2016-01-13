#!/bin/bash -x

# Script que arruma arquivo renomeados NOAA #
dir_exe="/home/cdsr/bin"
dir_arquivo="/home/cdsr/bin/out"
dir_saida="/home/cdsr/bin/out"
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
	
	#rm -rf $arquivos
	
	cd $pasta
	# vexifica se existe o conjunto de arquivos #
	ls > $dir_exe'/lista_interna1'
	cd $dir_exe
	renomear='nao'
	ver='0'
	while read internos
	do
		ver=`echo $internos | cut -d "." -f3`
		if [ $ver ] && [ $ver == 'ext1' ]
		then
			
			cp -rf $dir_exe'/'$pasta'/'$pasta'.ext1/home1/oper/tmp_raw/'* $dir_exe'/'$pasta
			cd $pasta
			#rm -rf $pasta'.ext1'
			cd $dir_exe
			renomear='sim'
		fi
	done < $dir_exe'/lista_interna1'
	
	if [ $renomear == 'sim' ]
	then
		cd $pasta
		# vexifica se existe o conjunto de arquivos #
		ls > $dir_exe'/lista_interna2'
		cd $dir_exe
		while read internos
		do
			tipo=`echo $internos | cut -d "." -f2`
			cd $pasta
			mv $internos $pasta"."$tipo
			cd $dir_exe
		done < $dir_exe'/lista_interna2'
		
		# compacta #
		tar cf $pasta".tar" $pasta
		gzip $pasta".tar"
		
		exit
	fi
	
	
	
done < $dir_exe"/lista_arq"

exit
