#!/bin/bash -x

# Script renomeia do padrão DSA para o padfrão CDSR 
# Somente arquivos HRPT dentro das pastas
# Jose Neto 01/2015

# diretorios #
dir_exe='/home/cdsr/bin'
# dir_HRPT #
dir_hrpt='/GRALHA/RECUPERACAO_DE_DADOS/NOAA_HRPT_STD'
# diretorio de saida #
dir_out='/GRALHA/RECUPERACAO_DE_DADOS/Dados_NOAA_HRPT_STD'




# lista dos dados com .GZ #
cd $dir_hrpt
ls S*.gz > $dir_exe'/lista_renomear_std'
cd $dir_exe
# lendo a lista #
while read lista_std
do
	arquivo_antigo=$lista_std
	# capturando o nome da passagem na tabela de nomes #
	prefixo=`echo $arquivo_antigo | cut -d "_" -f1`
	sufixo=`echo $arquivo_antigo | cut -d "_" -f2`
	# nome antigo da passagem #
	nome_antigo=`echo $arquivo_antigo | cut -d "." -f1`
	while read tabela_nomes
	do
		satelite=0
		prefixo_tabela=`echo $tabela_nomes | cut -d ";" -f4`
	if [ $prefixo_tabela == $prefixo ]
	then
		satelite=`echo $tabela_nomes | cut -d ";" -f2`
		erg=`echo $tabela_nomes | cut -d ";" -f3`	
		break;
	fi
	done < $dir_exe'/tabelaNOAA.txt'
	if [ $satelite != 0 ]
	then
		#separando a data e hora da passagem #
		ano=`echo $sufixo | cut -c1-4`
		mes=`echo $sufixo | cut -c5-6`
		dia=`echo $sufixo | cut -c7-8`
		hor=`echo $sufixo | cut -c9-10`
		min=`echo $sufixo | cut -c11-12`
		#201204010429.gz
		#Nome novo da passagem no padrão CDSR #
		nome_novo=$satelite"_HRPT_STD_"$ano"_"$mes"_"$dia"."$hor"_"$min"_00_"$erg
		
		# copiando o arquivo #
		cp -rf $dir_hrpt'/'$arquivo_antigo $dir_exe
		cd $dir_exe
		# criando a pasta de armazenamento #
		mkdir $nome_novo
		# movendo o arquivo para a pasta correta #
		mv $arquivo_antigo $nome_novo
		# descompactado o arquivo #
		cd $nome_novo
		gzip -d $arquivo_antigo
		# alterando o nome do arquivo #
		mv $nome_antigo $nome_novo".hrpt"
		# compactando novamente o arquivo #
		cd $dir_exe
		tar cf $nome_novo".tar" $nome_novo
		gzip $nome_novo".tar"
		# movendo para a pasta final #
		cd $dir_out
		mkdir -p $ano"_"$mes
		cd $dir_exe
		mv $nome_novo".tar.gz" $dir_out'/'$ano"_"$mes'/'
		# apaga o arquivo base #
		cd $dir_exe
		if [ -e $nome_novo ]
		then
			rm -rf $dir_hrpt'/'$arquivo_antigo
			rm -rf $nome_novo
		fi
	fi
	
	
done < $dir_exe'/lista_renomear_std'


# lista dos dados sem o GZ#
cd $dir_hrpt
ls S* > $dir_exe'/lista_renomear_std'
cd $dir_exe
# lendo a lista #
while read lista_std
do
	arquivo_antigo=$lista_std
	# capturando o nome da passagem na tabela de nomes #
	prefixo=`echo $arquivo_antigo | cut -d "_" -f1`
	sufixo=`echo $arquivo_antigo | cut -d "_" -f2`
	# nome antigo da passagem #
	nome_antigo=`echo $arquivo_antigo | cut -d "." -f1`
	while read tabela_nomes
	do
		satelite=0
		prefixo_tabela=`echo $tabela_nomes | cut -d ";" -f4`
		if [ $prefixo_tabela == $prefixo ]
		then
			satelite=`echo $tabela_nomes | cut -d ";" -f2`
			erg=`echo $tabela_nomes | cut -d ";" -f3`	
			break;
		fi
	done < $dir_exe'/tabelaNOAA.txt'
	
	if [ $satelite != 0 ]
	then 
		#separando a data e hora da passagem #
		ano=`echo $sufixo | cut -c1-4`
		mes=`echo $sufixo | cut -c5-6`
		dia=`echo $sufixo | cut -c7-8`
		hor=`echo $sufixo | cut -c9-10`
		min=`echo $sufixo | cut -c11-12`
		#201204010429.gz
		#Nome novo da passagem no padrão CDSR #
		nome_novo=$satelite"_HRPT_STD_"$ano"_"$mes"_"$dia"."$hor"_"$min"_00_"$erg
		
		# copiando o arquivo #
		cp -rf $dir_hrpt'/'$arquivo_antigo $dir_exe
		cd $dir_exe
		# criando a pasta de armazenamento #
		mkdir $nome_novo
		# movendo o arquivo para a pasta correta #
		mv $arquivo_antigo $nome_novo
		
		# alterando o nome do arquivo #
		mv $nome_antigo $nome_novo".hrpt"
		# compactando novamente o arquivo #
		cd $dir_exe
		tar cf $nome_novo".tar" $nome_novo
		gzip $nome_novo".tar"
		# movendo para a pasta final #
		cd $dir_out
		mkdir -p $ano"_"$mes
		cd $dir_exe
		mv $nome_novo".tar.gz" $dir_out'/'$ano"_"$mes'/'
		# apaga o arquivo base #
		cd $dir_exe
		if [ -e $nome_novo ]
		then
			rm -rf $dir_hrpt'/'$arquivo_antigo
			rm -rf $nome_novo
		fi
	
	fi
	
done < $dir_exe'/lista_renomear_std'

exit
