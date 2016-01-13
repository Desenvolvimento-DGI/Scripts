#!/bin/bash -x

# Script para renomear dados NOAA antigos #
# Autor: Jose Neto #
# Data: 13/08/2012 #
# Vesrao: 2.0 #

d_lista=/GRALHA/RECUPERACAO_DE_DADOS

# diretorio de execucao do script #
d_exe=/home/cdsr/bin
# diretorio dos arquivos recuparados #
d_arqs=/GRALHA/RECUPERACAO_DE_DADOS
# diretorio para entrada dos dados #
d_hrpt=/home/cdsr/bin/entrada
# diretorio de saida e renomeacao temporario #
d_out=/home/cdsr/bin/out
# diretorio final onde os arquivos serão alocados #
d_fim=/GRALHA/RECUPERACAO_DE_DADOS/Dados_Renomeados_NOAA

# gera a lista de arquivos extraidos de DVD # 
cd $d_arqs
ls -d "CD"* > $d_exe"/listaCD"

cd $d_exe


# lendo a lista de arquivos DVD #
while read dvds
do

	pasta_dvd=`echo $dvds | cut -d " " -f1`
	
	# gera a lista de arquivos dentro das pastas dos DVDs #
	ls -ltr $d_arqs"/"$pasta_dvd > $d_exe"/arquivosCD"
	
	# Lendo os arquivos dentro das pastas dos DVDs #
	while read arquivos
	do
		
		total=`echo $arquivos | cut -d " " -f1`
		if [ $total != 'total' ]
		then
			#Nome do arquivo a ser renomeado #
			arquivo_renomear=`echo $arquivos | cut -d " " -f9`
			
			# verificando a extensao do arquivo #
			extensao=`echo $arquivo_renomear | cut -d "." -f3`
			# Arquivo para extracao #
			arquivo_01=`echo $arquivo_renomear | cut -d "." -f1`
			
			arquivo_02=`echo $arquivo_renomear | cut -d "." -f2`
			arquivo_tar=$arquivo_01"."$arquivo_02
			
			# Tipos de descompactacao para cada tipo de extensao  - GZ #
			if [ $extensao == 'gz' ]
			then
				# copiando o arquivo para uma area de execucao #
				cp -rf $d_arqs"/"$pasta_dvd"/"$arquivo_renomear $d_out
				# desconpacta e extrai #
				cd $d_out
				# cria diretorio para descompactacao #
				mkdir $arquivo_01
				mv $arquivo_renomear $arquivo_01"/"
				cd $arquivo_01
				# Descompacta #
				gzip -d $arquivo_renomear
				# Extrai #
				tar xvf $arquivo_tar
				# apaga o arquivo tar.gz #
				rm -rf $arquivo_tar
				# gera a lista de arquivos dentro da pasta da passagem #
				ls -ltr > $d_exe"/arquivosRenomear"
				
				# Variaveis de dados - erg, data, hora, satelite #
				sat=`echo $arquivo_01 | cut -d "_" -f1-2`
				erg=`echo $arquivo_01 | cut -d "_" -f5`
				erg=`echo $erg | cut -d "." -f1`
				if [ $erg ]
				then
					erg=$erg
				else
					erg='CP1'
				fi
				
				nome_sat=`echo $sat | cut -d "_" -f1`
				#verifica se o nome esta em minusculo#
				if [ $nome_sat == 'noaa' ]
				then
					missao_sat=`echo $sat | cut -d "_" -f2`
					sat='NOAA_'$missao_sat
				fi
				
				# arumando o nome da estacao #
				if [ $erg == 'cb1' ]; then  erg='CB1'; fi
				if [ $erg == 'cb2' ]; then  erg='CB2'; fi
				if [ $erg == 'cp1' ]; then  erg='CP1'; fi
				if [ $erg == 'cp2' ]; then  erg='CP2'; fi
				
				data=`echo $arquivo_01 | cut -d "_" -f3`
				yy=`echo $data | cut -c1-4`
				mm=`echo $data | cut -c5-6`
				dd=`echo $data | cut -c7-8`
					
				data=`echo $arquivo_01 | cut -d "_" -f4`
				hor=`echo $data | cut -c1-2`
				min=`echo $data | cut -c3-4`
				
				seg=00
				filepath=$sat"_HRPT_"$yy"_"$mm"_"$dd"."$hor"_"$min"_"$seg"_"$erg
				
				# Processo de Renomear - A pasta já foi criada, basta renomear os arquivo #
				# lendo a lista de arquivos da passagem #
				while read arqs_renomear
				do
					total_arq=`echo $arqs_renomear | cut -d " " -f1`
					if [ $total_arq != 'total' ]
					then
						
						arquivo_old=`echo $arqs_renomear | cut -d " " -f9`
						tipo=`echo $arquivo_old | cut -d "." -f2`
						cd $d_out"/"$arquivo_01
						mv $arquivo_old $filepath"."$tipo
						cd $d_exe
						
					fi
				done < $d_exe"/arquivosRenomear"
				
				cd $d_out 
				# Renomeado a pasta e compactando #
				mv $arquivo_01 $filepath
				tar cf $filepath".tar" $filepath
				gzip $filepath".tar"
				rm -rf $filepath".tar" $filepath
				
				# movendo para area final #
				cd $d_fim
				mkdir -p $erg"/"$yy"_"$mm
				cd $d_out
				mv $filepath".tar.gz" $d_fim"/"$erg"/"$yy"_"$mm
				
				cd $d_exe
				
			fi
			
			if [ $extensao == 'Z' ]
			then
			
				# copiando o arquivo para uma area de execucao #
				cp -rf $d_arqs"/"$pasta_dvd"/"$arquivo_renomear $d_out
				# desconpacta e extrai #
				cd $d_out
				# cria diretorio para descompactacao #
				mkdir $arquivo_01
				mv $arquivo_renomear $arquivo_01"/"
				cd $arquivo_01
				# Descompacta #
				gunzip -d $arquivo_renomear
				# Extrai #
				tar xvf $arquivo_tar
				# apaga o arquivo tar.gz #
				rm -rf $arquivo_tar
				# gera a lista de arquivos dentro da pasta da passagem #
				ls -ltr > $d_exe"/arquivosRenomear"
							
				cd $d_out			
							
				# Variaveis de dados - erg, data, hora, satelite #
				sat=`echo $arquivo_01 | cut -d "_" -f1-2`
				erg=`echo $arquivo_01 | cut -d "_" -f5`
				erg=`echo $erg | cut -d "." -f1`
				
				if [ $erg ]
				then
					erg=$erg
				else
					erg='CP1'
				fi
				
				nome_sat=`echo $sat | cut -d "_" -f1`
				#verifica se o nome esta em minusculo#
				if [ $nome_sat == 'noaa' ]
				then
					missao_sat=`echo $sat | cut -d "_" -f2`
					sat='NOAA_'$missao_sat
				fi
				
				# arumando o nome da estacao #
				if [ $erg == 'cb1' ]; then  erg='CB1'; fi
				if [ $erg == 'cb2' ]; then  erg='CB2'; fi
				if [ $erg == 'cp1' ]; then  erg='CP1'; fi
				if [ $erg == 'cp2' ]; then  erg='CP2'; fi
				
				data=`echo $arquivo_01 | cut -d "_" -f3`
				yy=`echo $data | cut -c1-4`
				mm=`echo $data | cut -c5-6`
				dd=`echo $data | cut -c7-8`
					
				data=`echo $arquivo_01 | cut -d "_" -f4`
				hor=`echo $data | cut -c1-2`
				min=`echo $data | cut -c3-4`
				
				seg=00
				filepath=$sat"_HRPT_"$yy"_"$mm"_"$dd"."$hor"_"$min"_"$seg"_"$erg
				
				# Processo de Renomear - A pasta já foi criada, basta renomear os arquivo #
				# lendo a lista de arquivos da passagem #
				while read arqs_renomear
				do
					total_arq=`echo $arqs_renomear | cut -d " " -f1`
					if [ $total_arq != 'total' ]
					then
						
						arquivo_old=`echo $arqs_renomear | cut -d " " -f9`
						tipo=`echo $arquivo_old | cut -d "." -f2`
						cd $d_out"/"$arquivo_01
						mv $arquivo_old $filepath"."$tipo
						cd $d_exe
						
					fi
				done < $d_exe"/arquivosRenomear"
				
				cd $d_out 
				# Renomeado a pasta e compactando #
				mv $arquivo_01 $filepath
				tar cf $filepath".tar" $filepath
				gzip $filepath".tar"
				rm -rf $filepath".tar" $filepath
				
				# movendo para area final #
				cd $d_fim
				mkdir -p $erg"/"$yy"_"$mm
				cd $d_out
				mv $filepath".tar.gz" $d_fim"/"$erg"/"$yy"_"$mm
				
				cd $d_exe
				
				
			fi
			
			if [ $extensao != 'Z' ] && [ $extensao != 'gz' ] 
			then
				# salvando as passagens com extensão diferente #
				saida=$arquivo_renomear"-"$dvds 
				echo $saida >> $d_exe"/"saida_dvd.txt
			fi
			
		fi
	done < $d_exe"/arquivosCD"
	
	

done < $d_exe"/listaCD"



exit;









