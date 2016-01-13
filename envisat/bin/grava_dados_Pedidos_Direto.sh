#!/bin/bash

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ##
## Script que verifica novas passagens NOAA e METOP e grava no banco de dados as informacoes das passagens ##
## As informacoes sao de pedidos diretos - dados que vao diretamente sem passar pelo catalogo ##
## Autor: Jose Neto ##
## data: 01/2015 ##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ##

# Pega a sistema #
ano_mes=`date '+%Y_%m'`
#ano_mes='2015_01'
# Diretorios de verificacao #
dir_exe='/home/cdsr/bin'
# NOAA #
dir_noaa_15='/L0_NOAA15/'$ano_mes'/HRPT/'
dir_noaa_18='/L0_NOAA18/'$ano_mes'/HRPT/'
dir_noaa_19='/L0_NOAA19/'$ano_mes'/HRPT/'
# Aqua e Terra #
dir_aqua='/L0_AQUA/'$ano_mes'/MODIS/'
dir_terra='/L0_TERRA/'$ano_mes'/MODIS/'

# limpa dados antigos # 
cd $dir_exe
rm -rf listaDadosNovosNOAAPHP
rm -rf listaDadosNovosAquaTerraPHP

# Lista todos os dados e coloca em um unico arquivo - Dados NOAA #
cd $dir_noaa_15
ls -ltr N* > $dir_exe'/listaDadosNovosNOAA'
cd $dir_noaa_18
ls -ltr N* >> $dir_exe'/listaDadosNovosNOAA'
cd $dir_noaa_19
ls -ltr N* >> $dir_exe'/listaDadosNovosNOAA'

# Lista todos os dados e coloca em um unico arquivo - Dados AQUA/TERRA #
cd $dir_aqua
ls -ltr A* > $dir_exe'/listaDadosNovosAquaTerra'
cd $dir_terra
ls -ltr T* >> $dir_exe'/listaDadosNovosAquaTerra'

# Arrumando a lista para o PHP - Lista NOAA #
while read lista
do
	tamanho=`echo $lista | cut -d " " -f5`
	nome_passagem=`echo $lista | cut -d " " -f9`
	
	echo $tamanho';'$nome_passagem >> $dir_exe'/listaDadosNovosNOAAPHP'
	
done < $dir_exe'/listaDadosNovosNOAA'

# Arrumando a lista para o PHP - Lista Aqua e Terra #
while read lista
do
	tamanho=`echo $lista | cut -d " " -f5`
	nome_passagem=`echo $lista | cut -d " " -f9`
	
	echo $tamanho';'$nome_passagem >> $dir_exe'/listaDadosNovosAquaTerraPHP'
	
done < $dir_exe'/listaDadosNovosAquaTerra'

# Executa o script php - NOAA#
cd $dir_exe
parametro_NO=$dir_exe'/listaDadosNovosNOAAPHP'
/usr/bin/php insere_dados_NOAA_BD.php $parametro_NO

# Executa o script php - AQUA e TERRA#
cd $dir_exe
parametro_AT=$dir_exe'/listaDadosNovosAquaTerraPHP'
/usr/bin/php insere_dados_AQUA_TERRA_BD.php $parametro_AT


# Apaga os arquivo utilizados #
cd $dir_exe
rm listaDadosNovosNOAA listaDadosNovosNOAAPHP
rm listaDadosNovosAquaTerra listaDadosNovosAquaTerraPHP


exit
