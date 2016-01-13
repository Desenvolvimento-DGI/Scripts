#!/bin/bash -x

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Descricao: script que recebe o comando que uma nova ordem de servico foi feita #
# Autor: Jose Neto
# Data: 04/2015
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

# Diretorios #
# Diretorio de execucao #
dir_exe="/dados/htdocs/Sistema_Processamento_L8/funcaoIngest"
# Diretorio das ordens de servico #
dir_ordem="/dados/htdocs/Sistema_Processamento_L8/ordem_servico"

# Executa a ordem de servico #
ordem_executar=$1
# Carecter chave para atualizacao #
caracter_chave=$2
#echo $ordem_executar > $dir_exe"/testeParameto"

if [ $ordem_executar ]
then
	# lista os valores da ordem de servico do INGEST #
	caminho_ordem_listar=$dir_ordem"/"$ordem_executar
	# Lendo a lista das ordens #
	while read lista_ordem
	do
		arquivo_ODL_executar=`echo $lista_ordem`
		#--echo $arquivo_ODL_executar
		# 1.2.1 - Executa a funcao ADC #
		/home/cdsr/Ingest_3_6_0/ADC $arquivo_ODL_executar
		# 1.2.2 - Executa a funcao LG #
		/home/cdsr/Ingest_3_6_0/LG $arquivo_ODL_executar
		# 1.2.3 - Executa a funcao SFC #
		/home/cdsr/Ingest_3_6_0/SFC $arquivo_ODL_executar
		#1.2.4 - Executa a funcao MG #
		/home/cdsr/Ingest_3_6_0/MG $arquivo_ODL_executar
	done < $caminho_ordem_listar
fi

# Grava na base de dados as informacoes sobre termino do processo #
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
up_terra=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE processo_ingest_L8 SET proc_data_final = '$data_final', 
proc_status = '$status' WHERE proc_caracter_chave = '$caracter_chave'"`

# Remove a ordem de servico da area de ordens #
sleep 30
cd $dir_ordem
#rm $ordem_executar

# finalizado #

exit
