#!/bin/bash -x

# autor: Jose Neto
# data: 03/2014


# diretorios #
dir_exe=/home/cdsr/bin
dir_out=/mnt/hd1


# lendo a lista #
while read lista
do

	caminho=`echo $lista | cut -d "/" -f2-15`
	caminho="/Dados_alta_resoluocao/"$caminho
	
	contador=1
	for i in {1..20}
	do
		teste=`echo $caminho | cut -d "/" -f$i`
		if [ "$teste" ]
		then
			contador=$(( $contador+1 ))
		fi
	done
	contador=$(( $contador -1 ))
	pasta=`echo $caminho | cut -d "/" -f4-$contador`
	
	if [ -e """$caminho""" ]
	then
		cd $dir_out
		mkdir -p $dir_out"/""""$pasta"""
		cd $dir_out"/""""$pasta"""
		cp -rf """$caminho""" .
		cd $dir_exe
		echo "teste"
	else
		echo $caminho >> $dir_exe"/listaNaoCopiados"
	fi
	
	

done < $dir_exe"/IBGE.txt"


exit
