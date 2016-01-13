#!/bin/bash -x

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Descricao: script que recebe o comando para executar as Funcoes ADC, Lg, SFC e MG #
# Autor: Jose Neto
# Data: 04/2015
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

#--------------------------------------------------------------------------------------------------------#
# Parametros iniciais para executar os processos ADC, LG, SFC e MG #
#--------------------------------------------------------------------------------------------------------#
# Nome da ordem a ser executada #
ponto_executar=$1
# Carecter chave que permite a identificacao unica no banco de dados #
caracter_chave=$2
# Recebe o ano e mes escolhido #
ano_mes=$3
# Recebe o parametro de controle final para informar se pode finalizar o processo #
controle_final=$4

# Diretorios #
# Diretorio de execucao #
dir_exe="/dados/htdocs/Sistema_Processamento_L8/funcaoIngest"
# Diretorio das ordens de servico #
dir_ordem="/dados/htdocs/Sistema_Processamento_L8/ordem_servico"
# Diretorio L0R_WORK #
dir_work='/dados/L0R_WORK'
# Diretorio L0R_TEMP #
dir_temp='/dados/L0R_TEMP'
# nome da pasta da passagem e do ponto #
nome_passagem=`echo $ponto_executar | cut -d "/" -f4 `
nome_ponto_passagem=`echo $ponto_executar | cut -d "/" -f5 `
nome_ponto_passagem=`echo $nome_ponto_passagem | cut -d "." -f1 `

#--------------------------------------------------------------------------------------------------------#
# fim dos parametros #
#--------------------------------------------------------------------------------------------------------#


#--------------------------------------------------------------------------------------------------------#
# Inicializa todos os parametros atraves do arquivo .cshrc
#--------------------------------------------------------------------------------------------------------#

if [ -e /home/cdsr/.cshrc ]
then
	source /home/cdsr/.cshrc
fi

#--------------------------------------------------------------------------------------------------------#
# fim da execucao do arquivo .cshrc
#--------------------------------------------------------------------------------------------------------#


#--------------------------------------------------------------------------------------------------------#
# Exporta as bibliotecas e funcoes para gerar os produtos #
#--------------------------------------------------------------------------------------------------------#
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/ias_geo_novas_wrapper.c:/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/ias_geo_novas_wrapper.lo:/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/ias_geo_novas_wrapper.o
export PATH=$PATH:'/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/.deps/ias_geo_novas_wrapper.Plo':'/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/.libs/ias_geo_novas_wrapper.o'
export PATH=$PATH:/home/cdsr/COTS64/novas3.1/data/:/home/cdsr/COTS64/gctp3/
export PATH=$PATH:/usr/local/Trolltech/Qt-4.8.4/lib/libQtCore.so.4:/home/cdsr/bin/:/home/cdsr/LPGS_2_4_0/include/:/home/cdsr/SBS_3_0_0/OTS
export PATH=$PATH:/usr/local/Trolltech/Qt-4.8.4/bin/:/usr/local/Trolltech/Qt-4.8.4/lib:
export PATH=$PATH:/home/cdsr/COTS64/hdfview/bin:/usr/local/bin:/bin:/usr/bin:/home/cdsr/LPGS_2_4_0/build_ias/bin
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/tools:/home/oracle/11.2.0/bin
export PATH=$PATH:/home/cdsr/COTS64/hdf5/include/:/home/cdsr/COTS64/hdf5/bin
export PATH=$PATH:/home/oracle/11.2.0/lib/
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/lib/
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/build_ias/iaslib/lib/
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/include/
export PATH=$PATH:/home/cdsr/bin/
export PATH=$PATH:/home/cdsr/SBS_3_0_0/OTS
export PATH=$PATH:/home/cdsr/COTS64/novas3.1/lib/libnovas.a
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/ias_geo_novas_wrapper.c
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/ias_geo_novas_wrapper.lo
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/ias_geo_novas_wrapper.o
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/local_novas_wrapper.h
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/.deps/ias_geo_novas_wrapper.Plo
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/.libs/ias_geo_novas_wrapper.o
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/tests/test_novas_wrapper.c
export PATH=$PATH:/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/tests/.deps/test_novas_wrapper.Po
export PATH=$PATH:'/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/.deps/ias_geo_novas_wrapper.Plo'
export PATH=$PATH:'/home/cdsr/LPGS_2_4_0/ias_lib/misc/geo/.libs/ias_geo_novas_wrapper.o'

export md5sum=/usr/bin/md5sum
export NOVAS_HOME=/home/cdsr/COTS64/novas3.1
export NOVASLIB=/home/cdsr/COTS64/novas3.1/lib/
export NOVASINC=/home/cdsr/COTS64/novas3.1/include/
export QTDIR=/usr/local/Trolltech/Qt-4.8.4/
export QTINC=/usr/local/Trolltech/Qt-4.8.4/include/
export QTLIB=/usr/local/Trolltech/Qt-4.8.4/lib/
export LD_LIBRARY_PATH=/usr/local/Trolltech/Qt-4.8.4/lib/
export JPLDE421=/home/cdsr/COTS64/novas3.1/data/lnxp1900p2053.421

export INGEST_HOME=/home/cdsr/Ingest_3_6_0
export COTS=/home/cdsr/COTS64

export PATH=$PATH:/home/cdsr/COTS64/novas3.1/include/eph_manager.h
export PATH=$PATH:/home/cdsr/COTS64/novas3.1/include/novas.h
export PATH=$PATH:/home/cdsr/COTS64/novas3.1/include/novascon.h
export PATH=$PATH:/home/cdsr/COTS64/novas3.1/include/nutation.h
export PATH=$PATH:/home/cdsr/COTS64/novas3.1/include/solarsystem.h

export IAS=/L0_LANDSAT8/AncillaryFiles/CPF:/home/cdsr/LPGS_2_4_0/ias_lib/io/L0R/ias_l0r.c:/home/cdsr/LPGS_2_4_0/ias_lib/io/L0R/converter/old_L0R/ias_l0r.c
export HDF=/usr/share/cmake/Modules/FindHDF5.cmake:/usr/share/cmake28/Modules/FindHDF5.cmake
export PATH=$PATH:/home/cdsr/COTS64/hdf5/include/:/home/cdsr/COTS64/hdf5/bin
export JPLDE421=/home/cdsr/COTS64/novas3.1/data/lnxp1900p2053.421

export PATH=${INGEST_HOME}:${COTS}:${QTDIR}:${QTLIB}:${QTINC}:${NOVAS_HOME}:${NOVASLIB}:${NOVASINC}:${IAS}:${HDF}:${JPLDE421}:${PATH}

#--------------------------------------------------------------------------------------------------------#
# Fim dos exports #
#--------------------------------------------------------------------------------------------------------#


#--------------------------------------------------------------------------------------------------------#
# Inicia os processos #
#--------------------------------------------------------------------------------------------------------#
log_file_adc="log_saida_ADC_"$nome_ponto_passagem
log_file_lg="log_saida_LG_"$nome_ponto_passagem
log_file_sfc="log_saida_SFC_"$nome_ponto_passagem
log_file_mg="log_saida_MG_"$nome_ponto_passagem
# Executa o arquivo ODL #
if [ $ponto_executar ]
then
	echo $ponto_executar
	# 1.2.1 - Executa a funcao ADC #
	/home/cdsr/Ingest_3_6_0/ADC $ponto_executar >& 'logs/'$log_file_adc
	# 1.2.2 - Executa a funcao LG #
	/home/cdsr/Ingest_3_6_0/LG $ponto_executar >& 'logs/'$log_file_lg
	# 1.2.3 - Executa a funcao SFC #
	/home/cdsr/Ingest_3_6_0/SFC $ponto_executar >& 'logs/'$log_file_sfc
	#1.2.4 - Executa a funcao MG #
	/home/cdsr/Ingest_3_6_0/MG $ponto_executar >& 'logs/'$log_file_mg
fi
#--------------------------------------------------------------------------------------------------------#
# Fim dos processos #
#--------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------------#
# Copia os dados para o destino correto #
#--------------------------------------------------------------------------------------------------------#

# diretorio final do dado #
dir_out='/L0_LANDSAT8/L0Ra/'$ano_mes
# diretorio do dado trabalhado #
dir_work='/dados/L0R_WORK'
# diretorio temporario #
dir_temp='/dados/L0R_TEMP'
# Movendo os dados das passagens #
cd $dir_out
cp -dRfv $dir_work'/'$nome_ponto_passagem $dir_out'/'$nome_passagem
cd $dir_exe
# Depois de copiado e verificado, apaga os dados no L0_WORK //
if [ -e $dir_out'/'$nome_passagem'/'$nome_ponto_passagem ]
then
	cd $dir_work
	rm -rf $nome_ponto_passagem &
	cd $dir_temp
	rm -rf $nome_ponto_passagem &
	cd $dir_exe
fi

#--------------------------------------------------------------------------------------------------------#
# Fim da copia #
#--------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------------#
# Grava na base de dados as informacoes sobre termino do processo #
#--------------------------------------------------------------------------------------------------------#
# Apenas o ultimo ponto tem permissao para gravar #
if [ $controle_final == 1 ]
then
	# Aguarda um tempo para certificar que tudo esta finalizado #
	sleep 10m
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
	
	# Remove o log #
	cd $dir_exe'/logs'
	#--rm -rf $log_file_adc $log_file_lg $log_file_sfc $log_file_mg
	
	# finalizado #
fi

exit
