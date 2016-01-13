#!/bin/bash -x

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Descricao: script que recebe o comando que uma nova ordem de servico foi feita #
# Autor: Jose Neto
# Data: 04/2015
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#--------------------------------------------------------------------------------------------------------#
# Parametros iniciais para executar os processos ADC, LG, SFC e MG #
#--------------------------------------------------------------------------------------------------------#
# Nome da ordem a ser executada #
ordem_executar=$1
# Carecter chave que permite a identificacao unica no banco de dados #
caracter_chave=$2
# Recebe o ano e mes escolhido #
ano_mes=$3
# nome da pasta final #
pasta_final_passagem=`echo $ordem_executar | cut -d "_" -f2`
# Diretorios #
# Diretorio de execucao #
dir_exe="/dados/htdocs/Sistema_Processamento_L8/funcaoIngest"
# Diretorio das ordens de servico #
dir_ordem="/dados/htdocs/Sistema_Processamento_L8/ordem_servico"
# Diretorio L0R_WORK #
dir_work='/dados/L0R_WORK'
# Diretorio L0R_TEMP #
dir_temp='/dados/L0R_TEMP'
# diretorio final do dado #
dir_out='/L0_LANDSAT8/L0Ra/'$ano_mes
#--------------------------------------------------------------------------------------------------------#
# fim dos parametros #
#--------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------------#
# Antes de iniciar os processos, deve ser criado as pastas na area L0_WORK e L0_TEMP #
#--------------------------------------------------------------------------------------------------------#
if [ $ordem_executar ]
then
	lista_ordem_criar_pastas=$dir_ordem"/"$ordem_executar
	if [ -e $caminho_ordem_listar ]
	then
		while read lista_criar_pasta
		do
			parte_info_ODL=`echo $lista_criar_pasta | cut -d "." -f1`
			pasta_criar=`echo $parte_info_ODL | cut -d "/" -f5`
			# Cria a pasta no diretorio L0_WORK #
			mkdir -p $dir_work'/'$pasta_criar
			cd $dir_work
			chmod 777 $pasta_criar
			cd $dir_exe
			# Cria a pasta no diretorio L0_TEMP #
			mkdir -p $dir_temp'/'$pasta_criar
			cd $dir_temp
			chmod 777 $pasta_criar
			cd $dir_exe
		done < $lista_ordem_criar_pastas
		
	else
		exit
	fi
	# Cria a pasta de saida do dado final na area L0_LANDSAT8 #
	if [ -e $dir_out'/'$pasta_final_passagem ]
	then
		cd $dir_out
		rm -rf $pasta_final_passagem
	fi
	cd $dir_out
	mkdir -p $pasta_final_passagem
	cd $dir_exe
else
	exit
fi

#--------------------------------------------------------------------------------------------------------#
# Fim da criacao das pastas #
#--------------------------------------------------------------------------------------------------------#


#--------------------------------------------------------------------------------------------------------#
# Inicia os processos #
#--------------------------------------------------------------------------------------------------------#
# lista os valores da ordem de servico do INGEST #
caminho_ordem_listar=$dir_ordem"/"$ordem_executar
# pega o valor do ultimo ponto da passagem 3
ultimo_ponto=`tail -1 $dir_ordem"/"$ordem_executar`

contador=1
# Lendo a lista das ordens #
while read lista_ordem
do
	if [ $contador == 5 ] || [ $contador == 10 ] || [ $contador == 15 ] || [ $contador == 20 ] || [ $contador == 25 ]
	then
		sleep 10m
	fi
	
	# o script dispara quatro pontos de cada vez #
	arquivo_ODL_executar=`echo $lista_ordem`
	
	# Se for o ultimo ponto, o controle permite o script finalizar o processo #
	if [ $ultimo_ponto == $arquivo_ODL_executar ]
	then
		# 1- Finaliza o processo #
		controle_final=1
	else
		# 0- Nao finaliza o processo #
		controle_final=0
	fi
	
	# executa o script que ira processar a passagem - ADC, LG, SFC e MG #
	#./executa_processos_ADC_LG_SFC_MG.sh $arquivo_ODL_executar $caracter_chave $ano_mes $controle_final >/dev/null 2>&1 &
	./executa_processos_ADC_LG_SFC_MG.sh $arquivo_ODL_executar $caracter_chave $ano_mes $controle_final &
	echo $arquivo_ODL_executar
	
	contador=$(($contador+1))
done  < $caminho_ordem_listar

#--------------------------------------------------------------------------------------------------------#
# Fim dos processos #
#--------------------------------------------------------------------------------------------------------#

# Remove a ordem de servico da area de ordens #
cd $dir_ordem
rm $ordem_executar

exit
