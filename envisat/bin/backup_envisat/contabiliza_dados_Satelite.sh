#!/bin/bash -x

# Script conta o numero de arquivos dentro do L0 para cada satelite #
# Autor: Jose Neto
# Data: 10/2014

# Diretorios #
dir_exe='/home/cdsr/bin'
# Diretorio L0 #
dir_L0='/L0_'

total=0
valor=0
ano_teste='vazio'

# verifica o parametro de entrada - satelite #
if [ $1 ]
then
	satelite=$1

	# verifica qual foi o satelite selecionado #
	case "$satelite" in
		NOAA12)
			sensor='HRPT';
			pesquisa='NOAA'
			;;
		NOAA14)
			sensor='HRPT'
			pesquisa='NOAA'
			;;
		NOAA15)
			sensor='HRPT'
			pesquisa='NOAA'
			;;
		NOAA16)
			sensor='HRPT'
			pesquisa='NOAA'
			;;
		NOAA17)
			sensor='HRPT'
			pesquisa='NOAA'
			;;
		NOAA18)
			sensor='HRPT'
			pesquisa='NOAA'
			;;
		NOAA19)
			sensor='HRPT'
			pesquisa='NOAA'
			;;
		AQUA)
			sensor='MODIS'
			pesquisa='AQUA'
			;;
		TERRA)
			sensor='MODIS'
			pesquisa='TERRA'
			;;
		NPP)
			sensor='VIIRS'
			pesquisa='NPP'
			;;
    esac

	# diretorio L0
	dir_L0=$dir_L0''$satelite
	# lista dos anos com os dados #
	cd $dir_L0
	ls > $dir_exe'/listaSat_ano-mes'
	echo 'fim' >> $dir_exe'/listaSat_ano-mes'
	# lendo a lista #
	while read ano_mes
	do
		ano=`echo $ano_mes | cut -d "_" -f1`
		if [ $ano != $ano_teste ]
		then
			variavel_ano=$mes
			echo 'Total' $ano_teste ':' $total >> total$satelite
			total=0
			valor=0
		fi
		ano_teste=$ano
		dir_L0_2=$dir_L0'/'$ano_mes'/'$sensor'/'
		# verifica se existe o diretorio #
		#if [ -e $dir_L0_2 ]
		#then
		if [ $ano == 'fim' ]
		then
			exit
		else
			cd $dir_L0_2
			valor=`ls $pesquisa* | wc -l`
			cd $dir_exe
			total=$(($valor+$total))
		fi
		#fi
	done < $dir_exe'/listaSat_ano-mes'

	

else

	exit
fi




exit
