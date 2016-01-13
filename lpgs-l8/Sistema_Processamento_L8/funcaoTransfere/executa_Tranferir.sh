#!/bin/bash -x 

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Descricao: script que recebe o comando para executar a Tranferencia do Dados L8   #
# Autor: Jose Neto
# Data: 06/2015
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

#--------------------------------------------------------------------------------------------------------#
# Parametros iniciais para executar o processo #
#--------------------------------------------------------------------------------------------------------#
# Nome da passagem #
passagem=$1
# Recebe o ano e mes escolhido #
ano_mes=$2
# Carecter chave que permite a identificacao unica no banco de dados #
caracter_chave=$3

# Diretorios #
# Diretorio de execucao #
dir_exe="/dados/htdocs/Sistema_Processamento_L8/funcaoTransfere"
# Diretorio base dos dados LandSat-8 #
dir_base="/dados/L1T_WORK/"

#--------------------------------------------------------------------------------------------------------#
# fim dos parametros #
#--------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------------#
# Manipulacao e Transferencia dos Dados #
#--------------------------------------------------------------------------------------------------------#
# Diretorio completo da passagem #
dir_passagem=$dir_base"/"$ano_mes"/"$passagem

# Diretorio de saida #
dir_saida_base_L1T="/L1_LANDSAT8/L1T/"$ano_mes"/"
dir_saida_L1T="/L1_LANDSAT8/L1T/"$ano_mes"/"$passagem

# Verifica se a pasta existe #
if [ -e $dir_saida_L1T ]
then
	# exclui a pasta se existir #
	cd $dir_saida_base_L1T
	rm -rf $passagem
	cd $dir_exe
fi

# Cria a pasta de Saida #
mkdir -p $dir_saida_L1T

# Le os pontos dentro da passagem #
for PONTOS in $(ls $dir_passagem)
do
	# vafirica se os pontos estao OK #
	verifica=`echo $PONTOS | cut -c1-3`
	if [ $verifica == "LO8" ] || [ $verifica == "LC8" ] 
	then
		# Diretorio do ponto atual #
		dir_ponto_passagem=$dir_passagem"/"$PONTOS
		# arquivo do ponto da passagem #
		arquivo_ponto_tar_gz=$PONTOS".tar.gz"
		# Verifica se existe o Arquivo Tar.Gz #
		if [ -e $dir_ponto_passagem"/"$arquivo_ponto_tar_gz ]
		then
			# Cria o ponto na pasta de saida L1T #
			dir_saida_L1T_ponto=$dir_saida_L1T"/"$PONTOS
			mkdir $dir_saida_L1T_ponto
			
			# copia o arquivo GZ dos pontos da passagem #
			cd $dir_ponto_passagem
			cp -rf $arquivo_ponto_tar_gz $dir_saida_L1T_ponto
			mv $arquivo_ponto_tar_gz $dir_saida_L1T_ponto
			
			# descompacta o ponto da passagem #
			cd $dir_saida_L1T_ponto
			tar zxf $arquivo_ponto_tar_gz
			
			# apaga o arquivo Tar.Gz da pasta de saida #
			cd $dir_saida_L1T_ponto
			rm -rf $arquivo_ponto_tar_gz
		fi
	fi
done

#--------------------------------------------------------------------------------------------------------#
# fim #
#--------------------------------------------------------------------------------------------------------#


#--------------------------------------------------------------------------------------------------------#
# Grava na base de dados as informacoes sobre termino do processo #
#--------------------------------------------------------------------------------------------------------#
status='FINALIZADO'
# Variaveis de Data #
dia=`date '+%d'`
mes=`date '+%m'`
ano=`date '+%Y'`
# Variaveis de hora #
hora=`date '+%H'`
min=`date '+%M'`
seg=`date '+%S'`
# data e hora de termino do processo #
data_final=$dia'/'$mes'/'$ano' '$hora':'$min':'$seg
# Atualiza os dados no banco de dados #
up_ingest=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE processos_Landsat8 SET proc_data_final = '$data_final', proc_status = '$status' WHERE proc_caracter_chave = '$caracter_chave'"`
#--------------------------------------------------------------------------------------------------------#
# Fim da gravacao no banco de dados #
#--------------------------------------------------------------------------------------------------------#

exit
