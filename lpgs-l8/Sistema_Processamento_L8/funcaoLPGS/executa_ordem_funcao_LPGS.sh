#!/bin/bash -x

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Descricao: script que executa o PROCESSO LPGS L1T #
# Autor: Jose Neto
# Data: 05/2015
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
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_base/dms/setup_work_order/read_l0r_metadata.c
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/io/L0R/converter/old_L0R/ias_l0r_mta.c
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_base/dms/setup_work_order/read_l0r_metadata.c
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/bin/setup_work_order:/home/cdsr/LPGS_2_4_0/ias_base/dms/setup_work_order
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_base/dms/setup_work_order/setup_work_order.c


export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_logging.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/ias_logging.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_db.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/database_access/ias_db.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_db_get_connect_info.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/database_access/ias_db_get_connect_info.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_miscellaneous.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/miscellaneous/ias_miscellaneous.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_satellite_attributes.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/satellite_attributes/ias_satellite_attributes.h
export PATH=$PATH:/home/cdsr/COTS64/gctp3/include/gctp.h

export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_base/dms/setup_work_order/setup_work_order.h
export PATH=$PATH:/home/cdsr:/bin/bash:/bin/csh
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/bin/setup_work_order
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_base/dms/setup_work_order
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_base/dms/setup_work_order/setup_work_order.c
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_logging.h:/home/cdsr/LPGS_2_4_0/ias_lib/misc/ias_logging.h

export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_logging.h:/home/cdsr/LPGS_2_4_0/ias_lib/misc/ias_logging.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_db.h:/home/cdsr/LPGS_2_4_0/ias_lib/misc/database_access/ias_db.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_db_get_connect_info.h:/home/cdsr/LPGS_2_4_0/ias_lib/misc/database_access/ias_db_get_connect_info.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_miscellaneous.h:/home/cdsr/LPGS_2_4_0/ias_lib/misc/miscellaneous/ias_miscellaneous.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/include/ias_satellite_attributes.h:/home/cdsr/LPGS_2_4_0/ias_lib/misc/satellite_attributes/ias_satellite_attributes.h
export PATH=$PATH:/home/cdsr/COTS64/gctp3/include/gctp.h:/home/cdsr/LPGS_2_4_0/ias_base/dms/setup_work_order/setup_work_order.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/bin/retrieve_elevation:/home/cdsr/LPGS_2_4_0/ias_base/dms/retrieve_elevation:/home/cdsr/LPGS_2_4_0/ias_base/dms/retrieve_elevation/dem_types.h


#
export NOVAS_HOME=$PATH:/home/cdsr/COTS64/novas3.1
export NOVASLIB=$PATH:/home/cdsr/COTS64/novas3.1/lib/
export NOVASINC=$PATH:/home/cdsr/COTS64/novas3.1/include/
export JPLDE421=$PATH:/home/cdsr/COTS64/novas3.1/data/lnxp1900p2053.421

export QTDIR=$PATH:/usr/local/Trolltech/Qt-4.8.4/
export QTINC=$PATH:/usr/local/Trolltech/Qt-4.8.4/include
export QTLIB=$PATH:/usr/local/Trolltech/Qt-4.8.4/lib
#

#--------------------------------------------------------------------------------------------------------#
# Fim dos exports #
#--------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------------#
# Parametros iniciais para executar o processo LPGS L1T #
#--------------------------------------------------------------------------------------------------------#
# Recebe o ano e o mes escolhido #
ano_mes=$1
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
log_file_LPGS="logsaidaLPGS"$ordem_servico_lpgs
while read ordem_executar
do
	# verifica se a variavel esta vazia #
	if [ $ordem_executar ]
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
		csh ./lpgs.sh $base $ponto >& $dir_exe'/logs/'$log_file_LPGS'_'$contador
		echo $base $ponto
		cd $dir_exe

		contador=$(($contador+1))
	fi
done < $dir_ordem'/'$ordem_servico_lpgs
#--------------------------------------------------------------------------------------------------------#
# fim do processo #
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
# Remove a ordem de servico da area de ordens #
cd $dir_ordem
rm $ordem_servico_lpgs
# Remove os logs #
cd $dir_exe'/logs'
rm -rf $log_file_LPGS*

# finalizado #

exit

