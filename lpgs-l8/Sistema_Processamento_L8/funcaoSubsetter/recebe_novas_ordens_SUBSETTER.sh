#!/bin/bash -x

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Descricao: script que executa o PROCESSO SUBSETTER #
# Autor: Jose Neto
# Data: 04/2015
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

#--------------------------------------------------------------------------------------------------------#
# Exporta as bibliotecas e funcoes para gerar os produtos #
#--------------------------------------------------------------------------------------------------------#
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/io/L0R/ias_l0r_anc.c:/home/cdsr/LPGS_2_4_0/ias_lib/io/L0R/ias_l0r_anc.lo:/home/cdsr/LPGS_2_4_0/ias_lib/io/L0R/ias_l0r_anc.o
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/io/L0R/.deps/ias_l0r_anc.Plo:/home/cdsr/LPGS_2_4_0/ias_lib/io/L0R/.libs/ias_l0r_anc.o:/home/cdsr/LPGS_2_4_0/ias_lib/io/L0R/converter/old_L0R/ias_l0r_anc.c

export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_logging.h:/home/cdsr/LPGS_2_4_0/ias_lib/misc/ias_logging.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_l0r.h:/home/cdsr/LPGS_2_4_0/ias_lib/io/L0R/ias_l0r.h:/home/cdsr/LPGS_2_4_0/ias_lib/io/L0R/converter/old_L0R/ias_l0r.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/io/L0R/ias_l0r_hdf.h:/home/cdsr/LPGS_2_4_0/ias_lib/io/L0R/converter/old_L0R/ias_l0r_hdf.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_types.h:/home/cdsr/LPGS_2_4_0/ias_lib/misc/ias_types.h
export PATH=$PATH:/home/cdsr/SBS_3_0_0/OTS/:/home/cdsr/SBS_3_0_0/OTS/ot_subsetter.c
export HOME=$PATH:/home/cdsr:/home/cdsr/SBS_3_0_0/OTS/ot_subsetter.c
export SUBSETTER_HOME=$PATH:/home/cdsr/SBS_3_0_0


#--------------------------------------------------------------------------------------------------------#
# Fim dos exports #
#--------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------------#
# Parametros iniciais para executar o processo SUBSETTER #
#--------------------------------------------------------------------------------------------------------#
# Recebe o ano e o mes escolhido #
ano_mes=$1
# Nome da passagem #
passagem=$2
# Nome da ordem de servico #
ordem_servico_subsetter=$3
# Carecter chave que permite a identificacao unica no banco de dados #
caracter_chave=$4

# Diretorios #
# Diretorio de execucao #
dir_exe="/dados/htdocs/Sistema_Processamento_L8/funcaoSubsetter"
# Diretorio das ordens de servico #
dir_ordem="/dados/htdocs/Sistema_Processamento_L8/ordem_servico"
# Diretorio L0Ra #
dir_L0Ra="/dados/L0_LANDSAT8/L0Ra/"$ano_mes"/"$passagem
# Diretorio L0Rp #
dir_L0Rp="/dados/L0_LANDSAT8/L0Rp/"$ano_mes"/"$passagem
# vairaveis #
lista_ordem_executar=$dir_ordem"/"$ordem_servico_subsetter
ano=`echo $ano_mes | cut -d "_" -f1`
mes=`echo $ano_mes | cut -d "_" -f2`
#--------------------------------------------------------------------------------------------------------#
# fim dos parametros #
#--------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------------#
# Inicio do processo SUBSETTER #
#--------------------------------------------------------------------------------------------------------#
log_file_subsetter="log_Subsetter"$ordem_servico_subsetter
# Verifica se foi passada a ordem #
if [ $ordem_servico_subsetter ]
then
	contador=0
	# Le a lista de arquivos para serem processados #
	while read lista_arquivos_subsetter
	do
		# verifica se o arquivo não esta vazio #
		if [ $lista_arquivos_subsetter ]
		then
			# ponta da passagem a executar #
			ponto_executar=$lista_arquivos_subsetter
		
			# executa o processo subsetter #
			/home/cdsr/SBS_3_0_0/OTS/ot_subsetter $ponto_executar $dir_L0Ra"/"$ponto_executar $dir_L0Rp"/"$ponto_executar --scene $ponto_executar >& 'logs/'$log_file_subsetter"_"$contador
		fi
		contador=$(($contador+1))
	done < $lista_ordem_executar
else
	exit
fi
#--------------------------------------------------------------------------------------------------------#
# Fim do processo SUBSETTER #
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
up_subsetter=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE processos_Landsat8 SET proc_data_final = '$data_final', 
proc_status = '$status' WHERE proc_caracter_chave = '$caracter_chave'"`
#--------------------------------------------------------------------------------------------------------#
# Fim da gravacao no banco de dados #
#--------------------------------------------------------------------------------------------------------#

# Remove a ordem de servico da area de ordens #
cd $dir_ordem
rm $ordem_servico_subsetter
# Remove os logs #
cd $dir_exe'/logs'
#--rm -rf $log_file_subsetter*

# finalizado #


exit

