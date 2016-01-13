#!/bin/bash -x

# Script que apaga os logs dos processamentos INGEST e SUBSETTER #
# Autor: Jose Neto #
# Data: 10/2015 #

# Apaga logs INGEST #
find /dados/htdocs/Sistema_Processamento_L8/funcaoIngest/logs/log_saida* -mtime +6 -exec rm -rf {} \;
# Apaga logs SUBSETTER #
find /dados/htdocs/Sistema_Processamento_L8/funcaoSubsetter/logs/log_Subsetterordem* -mtime +6 -exec rm -rf {} \;

exit
