#!/bin/bash -x

# Descricao: Este script fica monitorando novas passagens AQUA.
# Quando encontra uma passagem nova, eh disparado o processo de geracao de produto - IPOPP RT
# Autor: Jose Neto
# Data: 10/2014
# Versao: 1.0


# Diretorios #
# Diretorio de execucao #
dir_exe='/home/cdsr/bin'
# Diretorio dos dados AQUA L0 #
dir_aqua='/L0_AQUA'


# Variaveis de Data #
dia=`date '+%d'`
mes=`date '+%m'`
ano=`date '+%Y'`


# Antes que o processo seja executado, eh necessario 
# verificar se nao existe ourto sendo executado
pesquisa_processo=`ps -ef | grep teste.sh | tail -2 | head -1`
verificacao=`echo $pesquisa_processo | cut -d " " -f8`
if [ $verificacao != 'grep' ]
then
	# Se a variavel contiver outro comando firente de grep, tem processo sendo executado#
	echo processo rodando
	exit
	# finaliza o procedimento #
fi

# Verificando os dados AQUA #
dir_aqua=$dir_aqua'/'$ano'_'$mes'/MODIS'
if [ -e $dir_aqua ]
then
	cd $dir_aqua
	# pega o nome do ultimo arquivo na pasta 
	arquivo_AQUA=`ls -ltr *CB3 | tail -1`
	tamanho_AQUA=`echo $arquivo_AQUA | cut -d " " -f5`
	arquivo_AQUA=`echo $arquivo_AQUA | cut -d " " -f9`
	
	# Verifica se o arquivo é novo #
	cd $dir_exe
	ultimo_processado=`cat .ultimo_AQUA_processado`
	if [ $ultimo_processado != $arquivo_AQUA ]
	then
		$arquivo_aqua
		# Verifica se o arquivo nao esta vazio #
		if [ $tamanho_AQUA -gt 0 ]
		then
			# ./processa_modis_aqua.sh #
			
			# executa o processo AQUA #
			paremetro_processo=$dir_aqua"/"$arquivo_AQUA
			
			echo 'processa_modis_aqua' $paremetro_processo
		else
			#################################################################				
			# envia email informando que o dado esta zerado #
			# Arquivo com problema #
			#contatos_dgi="jose.azevedo@dgi.inpe.br, operadores-dgi@dgi.inpe.br"
			contatos_dgi="jose.azevedo@dgi.inpe.br"
			mail -s "ERRO - AQUA" $contatos_dgi << MAIL
Prezado(a)s,

A passagem AQUA da Antena CB3 - $arquivo_AQUA - esta ZERADA.
Favor verificar na pasta: 
$dir_aqua
			
				Centro de Dados de Sensoriamento Remoto - CDSR 
MAIL
#######################################################################################	
		fi
	fi
fi

exit
