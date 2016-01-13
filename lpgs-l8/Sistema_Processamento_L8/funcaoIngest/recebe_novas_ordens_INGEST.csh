#!/bin/csh -x

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Descricao: script que recebe o comando que uma nova ordem de servico foi feita #
# Autor: Jose Neto
# Data: 04/2015
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#


setenv NOVAS_HOME  /home/cdsr/COTS64/novas3.1
setenv  NOVASLIB  /home/cdsr/COTS64/novas3.1/lib/
setenv NOVASINC  /home/cdsr/COTS64/novas3.1/include/
setenv JPLDE421 /home/cdsr/COTS64/novas3.1/data/lnxp1900p2053.421
# QT
setenv QTDIR /usr/local/Trolltech/Qt-4.8.4/
setenv QTINC /usr/local/Trolltech/Qt-4.8.4/include
setenv QTLIB /usr/local/Trolltech/Qt-4.8.4/lib

# Oracle
setenv ORACLE_SID LPGS
#setenv  ORACLE_BASE  /u01/app/oracle
#setenv  ORACLE_HOSTNAME  lpgs-l17.dgi.inpe.br
#setenv  ORACLE_HOME  /u01/app/oracle/product/11.2.0/db_1
#setenv  LD_LIBRARY_PATH  /u01/app/oracle/product/11.2.0/db_1/lib:/lib:/usr/lib
#setenv  CLASSPATH  /u01/app/oracle/product/11.2.0/db_1/JRE:/u01/app/oracle/product/11.2.0/db_1/jlib:/u01/app/oracle/product/11.2.0/db_1/rdbms/jlib

# INGEST
setenv INGEST_HOME  /home/cdsr/Ingest_3_6_0

# Subsetter
setenv SUBSETTER_HOME /home/cdsr/SBS_3_0_0

setenv PROCESSING_CENTER INPE
setenv IAS_SERVICES "http://localhost:8080/"

setenv  PATH  /home/cdsr/bin/:/home/cdsr/LPGS_2_4_0/include/:/home/cdsr/SBS_3_0_0/OTS:/home/cdsr/COTS64/hdf5/include/:/home/cdsr/COTS64/gctp3/:/usr/local/Trolltech/Qt-4.8.4/bin/:/usr/local/Trolltech/Qt-4.8.4/lib:${PATH}

setenv PATH /usr/local/Trolltech/Qt-4.8.4/lib/libQtCore.so.4:$PATH
setenv PATH /usr/local/Trolltech/Qt-4.8.4/lib/libQtCore.so.4:$PATH
setenv PATH /usr/local/Trolltech/Qt-4.8.4/lib/libQtCore.so.4:$PATH
setenv PATH /usr/local/Trolltech/Qt-4.8.4/lib/libQtCore.so.4:$PATH
setenv PATH /usr/local/Trolltech/Qt-4.8.4/lib/libQtCore.so.4:$PATH

# Diretorios #
# Diretorio de execucao #
set dir_exe="/dados/htdocs/Sistema_Processamento_L8/funcaoIngest"
# Diretorio das ordens de servico #
set dir_ordem="/dados/htdocs/Sistema_Processamento_L8/ordem_servico"

# Executa a ordem de servico #
set ordem_executar=$1
# Carecter chave para atualizacao #
set caracter_chave=$2
#echo $ordem_executar > $dir_exe"/testeParameto"
set log_file_adc="logsaidaPROCadc"$ordem_executar
set log_file_lg="logsaidaPROClg"$ordem_executar
set log_file_sfc="logsaidaPROCsfc"$ordem_executar
set log_file_mg="logsaidaPROCmg"$ordem_executar
if ($ordem_executar != "") then
	set linhas=`/bin/cat $dir_ordem"/"$ordem_executar`
	foreach linha ($linhas)
        set arquivo_ODL_executar=$linha
		# 1.2.1 - Executa a funcao ADC #
		/home/cdsr/Ingest_3_6_0/ADC $arquivo_ODL_executar > $log_file_adc
		# 1.2.2 - Executa a funcao LG #
		#/home/cdsr/Ingest_3_6_0/LG $arquivo_ODL_executar
		# 1.2.3 - Executa a funcao SFC #
		#/home/cdsr/Ingest_3_6_0/SFC $arquivo_ODL_executar
		#1.2.4 - Executa a funcao MG #
		#/home/cdsr/Ingest_3_6_0/MG $arquivo_ODL_executar
	exit
    end
exit
# Grava na base de dados as informacoes sobre termino do processo #
set status='FINALIZADO'
# data e hora de termino do processo #
set data_final=`date '+%d/%m/%y'`
set hora_final=`date '+%H:%M:%S'`
set data_final=$data_final" "$hora_final
# Atualiza os dados no banco de dados #
set up_terra=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE processo_ingest_L8 SET proc_data_final = '$data_final',proc_status = '$status' WHERE proc_caracter_chave = '$caracter_chave'"`

# Remove a ordem de servico da area de ordens #
sleep 30
cd $dir_ordem
#rm $ordem_executar

# finalizado #

exit
