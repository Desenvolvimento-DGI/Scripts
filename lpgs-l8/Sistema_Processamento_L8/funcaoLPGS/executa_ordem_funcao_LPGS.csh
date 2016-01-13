#!/bin/csh -e

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Descricao: script que executa o PROCESSO LPGS L1T #
# Autor: Jose Neto
# Data: 05/2015
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#


# LPGS
alias lpgsenv 'setenv BUILDROOT /home/cdsr/LPGS_2_4_0; setenv SRCROOT $BUILDROOT; source $SRCROOT/ias_lib/setup/setup_db lpgs-l8.dgi.inpe.br; source $SRCROOT/ias_lib/setup/iaslib_setup --enable-dev --64 $BUILDROOT/build_ias; source $SRCROOT/ias_base/setup/iasbase_setup 
/home/cdsr/LPGS_2_4_0/root_proc_dir; source $SRCROOT/lpgs/setup/lpgs_setup;' 
lpgsenv


cd /dados/L1T_WORK/2015_05/LO82150640752015126CUB00/LO82150652015126CUB00
./lpgs.sh 215 065 > /dados/htdocs/Sistema_Processamento_L8/funcaoLPGS/logssaida.txt

exit
#--------------------------------------------------------------------------------------------------------#
# Parametros iniciais para executar o processo LPGS L1T #
#--------------------------------------------------------------------------------------------------------#
# Recebe o ano e o mes escolhido #
set ano_mes=$1
# Nome da passagem #
passagem=$2
# Nome da ordem de servico #
ordem_servico_lpgs=$3
# Carecter chave que permite a identificacao unica no banco de dados #
caracter_chave=$4
# Diretorios #
# Diretorio de execucao #
dir_exe="/dados/htdocs/Sistema_Processamento_L8/funcaoLPGS"
# Diretorio das ordens de servico #
dir_ordem="/dados/htdocs/Sistema_Processamento_L8/ordem_servico"
# Diretorio da passagem #
dir_passagem='/dados/L1T_WORK/'$ano_mes'/'$passagem
#--------------------------------------------------------------------------------------------------------#
# fim dos parametros #
#--------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------------#
# Le a ordem de servico e executa a funcao LPGS para cada ponto #
#--------------------------------------------------------------------------------------------------------#
# le a ordem de servico #
contador=0
while read ordem_executar
do
	# verifica se a variavel esta vazia #
	if [ $ordem_executar ]
	then
	if [ $contador == 1 ]
	then
		# recorta os valores da linha da ordem de servico #
		# ponto da passagem #
		ponto_da_passagem=`echo $ordem_executar | cut -d ";" -f1`
		# base da passagem #
		base=`echo $ordem_executar | cut -d ";" -f3`
		# zona do ponto da passagem #
		ponto=`echo $ordem_executar | cut -d ";" -f4`
		# executa a funcao LPGS L1T #
		dir_passagem_ponto=$dir_passagem'/'$ponto_da_passagem
		#--export PATH=$PATH:$dir_passagem_ponto
		cd $dir_passagem_ponto
		#chmod 775 lpgs.sh
		./lpgs.sh $base $ponto >& $dir_exe'/logs_saida'$contador
		#/bin/bash
		echo $base $ponto
		cd $dir_exe
		exit
	fi	
		contador=$(($contador+1))
	fi
done < $dir_ordem'/'$ordem_servico_lpgs
#--------------------------------------------------------------------------------------------------------#
# fim do processo #
#--------------------------------------------------------------------------------------------------------#
exit
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
# Remove a ordem de servico da area de ordens #
cd $dir_ordem
#--rm $ordem_executar

# finalizado #


exit

