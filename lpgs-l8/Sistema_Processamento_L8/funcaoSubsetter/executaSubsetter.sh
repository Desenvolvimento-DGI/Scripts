#!/bin/bash -x

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Descricao: script que executa o PROCESSO SUBSETTER #
# Autor: Jose Neto
# Data: 04/2015
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

#--------------------------------------------------------------------------------------------------------#
# Parametros iniciais para executar o processo SUBSETTER #
#--------------------------------------------------------------------------------------------------------#
# Recebe o ano e o mes escolhido #
ano_mes=$1
# Nome da pasta Base - Orbita/ponto inicial/ponto final #
dir_L0Rp_completo=$2
# Nome da pasta Base - Orbita/ponto inicial/ponto final #
ordem_servico_subsetter=$3
# Carecter chave que permite a identificacao unica no banco de dados #
caracter_chave=$4

# Diretorios #
# Diretorio de execucao #
dir_exe="/dados/htdocs/Sistema_Processamento_L8/funcaoIngest"
# Diretorio das ordens de servico #
dir_ordem="/dados/htdocs/Sistema_Processamento_L8/ordem_servico"
# Diretorio L0R_WORK #
dir_work='/dados/L0R_WORK'
# Diretorio L0R_TEMP #
dir_temp='/dados/L0R_TEMP'
#--------------------------------------------------------------------------------------------------------#
# fim dos parametros #
#--------------------------------------------------------------------------------------------------------#


exit

if ($#argv < 3) then
    echo "Sorry, but you entered too few parameters"
    echo "usage:  $0 arquivo.jpl ANO MES IntervalId SceneId" 
    exit
endif
if ( ! -d  /L0_LANDSAT8/L0Rp/$1_$2/$3/$4 ) then
	mkdir /L0_LANDSAT8/L0Rp/$1_$2/$3/$4
endif
echo /L0_LANDSAT8/L0Ra/$1_$2/$3/$4
echo /L0_LANDSAT8/L0Rp/$1_$2/$3
$HOME/SBS_3_0_0/OTS/ot_subsetter $4 /L0_LANDSAT8/L0Ra/$1_$2/$3/$4 /L0_LANDSAT8/L0Rp/$1_$2/$3/$4 --scene $4 

# $HOME/SBS_3_0_0/OTS/ot_subsetter LO82190702015074CUB00 /L0_LANDSAT8/L0Ra/2015_03/LO82190620802015074CUB00/LO82190702015074CUB00 /L0_LANDSAT8/L0Rp/2015_03/LO82190620802015074CUB00/LO82190700802015074CUB00 --scene LO82190702015074CUB00

