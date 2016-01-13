#!/bin/bash

/home/cdsr/bin/arruma_dados_modis.sh AQUA
/home/cdsr/bin/arruma_dados_modis.sh TERRA
/home/cdsr/bin/copia_MODIS_L1_queimadas.sh AQUA
/home/cdsr/bin/copia_MODIS_L1_queimadas.sh TERRA
#/home/cdsr/bin/copia_NPP_L2_queimadas.sh


# Alguns processos do IMAP param de ser executados sem explicacao #
# entao reiniciando-os novamente esse problema é corrigido #
#/home/cdsr/drl/tools/services.sh start


exit 
