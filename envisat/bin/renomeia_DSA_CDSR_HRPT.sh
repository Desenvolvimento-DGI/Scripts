#!/bin/bash -x

# Script renomeia do padrão DSA para o padfrão CDSR 
# Somente arquivos HRPT dentro das pastas
# Jose Neto 01/2015

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
	
	# Primeiro o script verifica a passagem é HRPT STD #
	# a passagem HRPT STD só possui o arquivo HRPT, nao contem os demais arquivos #
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
				echo "nao encontrou - eh somente HRPT STD"
			else
				cp -rf $dir_hrpt'/HRPT/'$arquivo_hrpt $dir_out
			fi
		done < $dir_exe'/lista_HRPT'
	fi
	
fi
	
	exit
if [ !$missao ] || [ !$ano_mes ]
then	
	# Verificando as pastas 7ARQ e HRPT #
	if [ -e $dir_hrpt'/7ARQ' ]
	then
		
		# Gera a lista de dados #
		cd $dir_hrpt'/7ARQ'
		ls S*.gz > $dir_exe'/lista_7ARQ'
		cd $dir_exe
		# lendo a lista e renomeando os dados #
		while read lista_7arq
		do
			arquivo_antigo=`echo $lista_7arq`
			# capturando o nome da passagem na tabela de nomes #
			prefixo=`echo $arquivo_antigo | cut -d "_" -f1`
			sufixo=`echo $arquivo_antigo | cut -d "_" -f2`
			# nome antigo da passagem #
			nome_antigo=`echo $arquivo_antigo | cut -d "." -f1`
			while read tabela_nomes
			do
				prefixo_tabela=`echo $tabela_nomes | cut -d ";" -f4`
				if [ $prefixo_tabela == $prefixo ]
				then
					satelite=`echo $tabela_nomes | cut -d ";" -f2`
					erg=`echo $tabela_nomes | cut -d ";" -f3`	
					break;
				fi
			done < $dir_exe'/tabelaNOAA.txt'
			
			# separando a data e hora da passagem #
			ano=`echo $sufixo | cut -c1-4`
			mes=`echo $sufixo | cut -c5-6`
			dia=`echo $sufixo | cut -c7-8`
			hor=`echo $sufixo | cut -c9-10`
			min=`echo $sufixo | cut -c11-12`
			#201204010429.gz
			# Nome novo da passagem no padrão CDSR #
			nome_novo=$satelite"_HRPT_STD_"$ano"_"$mes"_"$dia"."$hor"_"$min"_00_"$erg
			
			
			# verificando se o arquivo esta compactado #
			verificador=`echo $arquivo_antigo | cut -d "." -f2`
			if [ $verificador ] && [ $verificador == 'gz' ]
			then
				# copiando o arquivo #
				cp -rf $dir_hrpt'/7ARQ/'$arquivo_antigo $dir_exe
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
					rm -rf $nome_novo
				fi
			else
				
				if [ $verificador ] && [ $verificador == 'tar' ]
				then 
					echo "outros"
				
				else
					# copiando o arquivo #
					cp -rf $dir_hrpt'/7ARQ/'$arquivo_antigo $dir_exe
					# criando a pasta de armazenamento #
					cd $dir_exe
					mkdir $nome_novo
					# movendo o arquivo para a pasta correta #
					mv $arquivo_antigo $nome_novo
					# alterando o nome do arquivo #
					cd $nome_novo
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
						rm -rf $nome_novo
					fi
				fi
			fi
			
	done < $dir_exe'/lista_7ARQ'
		
	fi
	
	# Verificando as pastas 7ARQ e HRPT #
	if [ -e $dir_hrpt'/HRPT' ]
	then
		
		# Gera a lista de dados #
		cd $dir_hrpt'/HRPT'
		ls S*.gz > $dir_exe'/lista_HRPT'
		cd $dir_exe
		# lendo a lista e renomeando os dados #
		while read lista_hrpt
		do
			arquivo_antigo=`echo $lista_hrpt`
			# capturando o nome da passagem na tabela de nomes #
			prefixo=`echo $arquivo_antigo | cut -d "_" -f1`
			sufixo=`echo $arquivo_antigo | cut -d "_" -f2`
			# nome antigo da passagem #
			nome_antigo=`echo $arquivo_antigo | cut -d "." -f1`
			while read tabela_nomes
			do
				prefixo_tabela=`echo $tabela_nomes | cut -d ";" -f4`
				if [ $prefixo_tabela == $prefixo ]
				then
					satelite=`echo $tabela_nomes | cut -d ";" -f2`
					erg=`echo $tabela_nomes | cut -d ";" -f3`	
					break;
				fi
			done < $dir_exe'/tabelaNOAA.txt'
			
			# separando a data e hora da passagem #
			ano=`echo $sufixo | cut -c1-4`
			mes=`echo $sufixo | cut -c5-6`
			dia=`echo $sufixo | cut -c7-8`
			hor=`echo $sufixo | cut -c9-10`
			min=`echo $sufixo | cut -c11-12`
			#201204010429.gz
			# Nome novo da passagem no padrão CDSR #
			nome_novo=$satelite"_HRPT_STD_"$ano"_"$mes"_"$dia"."$hor"_"$min"_00_"$erg
		
			
			# verificando se o arquivo esta compactado #
			verificador=`echo $arquivo_antigo | cut -d "." -f2`
			if [ $verificador ] && [ $verificador == 'gz' ]
			then
				# copiando o arquivo #
				cp -rf $dir_hrpt'/HRPT/'$arquivo_antigo $dir_exe
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
					rm -rf $nome_novo
				fi
			else
				
				if [ $verificador ] && [ $verificador == 'tar' ]
				then 
					echo "outros"
					
				else
					# copiando o arquivo #
					cp -rf $dir_hrpt'/HRPT/'$arquivo_antigo $dir_exe
					cd $dir_exe
					# criando a pasta de armazenamento #
					cd $dir_exe
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
						rm -rf $nome_novo	
					fi
				fi
			fi
			
	done < $dir_exe'/lista_HRPT'
		
	fi
fi

exit
