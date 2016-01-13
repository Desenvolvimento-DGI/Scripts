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
			echo $arquivos
			arq=`echo $arquivos | cut -d " " -f9`
			sat=`echo $arq | cut -d "_" -f1`
			sat2=`echo $arq | cut -d "_" -f2`
			data=`echo $arq | cut -d "_" -f3`
			ano=`echo $data | cut -c1-4`
			mes=`echo $data | cut -c5-6`
			
			if [ $sat == 'NOAA' ] && [ $sat2 == '12' ]
			then
				if [ $ano == '2003' ] && [ $mes == '07' ]
				then
					cd $d_exe
					echo $arquivos >> listaAnosNOAA12_defeito
				fi
			
			fi
			
		fi
	done < $d_exe"/arquivosCD"
	
	

done < $d_exe"/listaCD"



exit
