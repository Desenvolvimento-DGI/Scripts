#!/bin/bash -x

#################################################################
# descricao: Script que gera o TIF das passagem TERRA com 250m 	#
# Autor: Jose Neto e Reuel										#
# Data: 09/2015 												#
#################################################################

# Diretorios #
# diretorio de execucao #
dir_exe='/home/cdsr/bin/'
# diretorio dos dados #
dir_level1='/raid/pub/gsfcdata/terra/modis/level1'

# Exporta algumas variaveis de ambiente #
export PATH=$PATH:/home/cdsr/drl/SPA/BlueMarble/wrapper/BlueMarble_modis-tcolor
export PATH=$PATH:/raid

# Busca a informação no banco de dados do processamento  IPOPP #

# id do ultimo produto a ser gerado - MOD 250m #
id_passagem=`/usr/bin/mysql -u root -pb28c935 -D DSM -s -e "SELECT id FROM Resources WHERE path LIKE '%MOD02QKM.%' ORDER BY id Desc LIMIT 5"`

# Verifica os ultimos 5 processos TERRA #
for id_passagem_especifica in $id_passagem
do 

	# Variavel com o valor do produto gerado - MOD 250m #
	MOD02_250m=`mysql -u root -pb28c935 -D DSM -s -e "SELECT path FROM Resources WHERE path LIKE '%MOD02QKM.%' AND id = '$id_passagem_especifica'"`
	# recorta a data do produto #
	data_produto=`echo $MOD02_250m | cut -d "." -f2`
	# compara com as passagens ja processadas #
	# varivel que controla o processamento #
	processar='sim'
	while read id_passagens_processadas
	do
		if [ $id_passagens_processadas == $id_passagem_especifica ]
		then
			echo "Passagem já processada!";
			# varivel que controla o processamento #
			processar='nao'
			break;
		else
			# varivel que controla o processamento #
			processar='sim'
		fi
	done < $dir_exe'/.passagens_processadas_250m_TERRA'
	
	# verifica se vai executar o processamento #
	if [ $processar == 'sim' ]
	then
	
		# variaveis com os arquivos necessario #
		arq_MOD021KM=$dir_level1'/MOD021KM.'$data_produto'.hdf'
		arq_MOD02HKM=$dir_level1'/MOD02HKM.'$data_produto'.hdf'
		arq_MOD02QKM=$dir_level1'/MOD02QKM.'$data_produto'.hdf'
		arq_MOD03=$dir_level1'/MOD03.'$data_produto'.hdf'
		# Verica se os arquivos existem nos seus respectivos diretorios #
		# Arquivo de 1KM #
		if [ -e $arq_MOD021KM ]
		then
			parametro_1km=$arq_MOD021KM
		else
			echo "Falta arquivo MOD021KM: "$arq_MOD021KM
			exit
		fi
		# Arquivo de 500m #
		if [ -e $arq_MOD02HKM ]
		then
			parametro_500m=$arq_MOD02HKM
		else
			echo "Falta arquivo MOD021KM: "$arq_MOD02HKM
			exit
		fi
		# Arquivo de 250m #
		if [ -e $arq_MOD02QKM ]
		then
			parametro_250m=$arq_MOD02QKM
		else
			echo "Falta arquivo MOD021KM: "$arq_MOD02QKM
			exit
		fi
		# Arquivo GEO #
		if [ -e $arq_MOD03 ]
		then
			parametro_GEO=$arq_MOD03
		else
			echo "Falta arquivo MOD021KM: "$arq_MOD03
			exit
		fi
		
		# Se todos os arquivos forem encontrados, o processo é executado #
		# acertar data para o arquivo de saida #
        yyyy=$(echo ${data_produto} | cut -c 1-2)
        ddd=$(echo ${data_produto} | cut -c 3-5)
        hh=$(echo ${data_produto} | cut -c 6-7)
        mm=$(echo ${data_produto} | cut -c 8-9)
        ss=$(echo ${data_produto} | cut -c 10-11)

        # converte para dia Gregoriano #
        ano=$(date -d "20${yyyy}-01-01 + ${ddd} days -1 day" +%Y)
        mes=$(date -d "20${yyyy}-01-01 + ${ddd} days -1 day" +%m)
        dia=$(date -d "20${yyyy}-01-01 + ${ddd} days -1 day" +%d)
		
		# diretorio e nome do arquivo de saida #
		dir_saida='/raid/teste/'$ano'_'$mes'_'$dia'.'$hh'_'$mm'_'$ss
		arq_saida='TERRA_TRUE_COLOR_250M_'$ano'_'$mes'_'$dia'.'$hh'_'$mm'_'$ss'.tif'
		nome_arquivo_saida=$dir_saida'/'$arq_saida
		
		# cria o diretorio de saida #
		mkdir -p $dir_saida
		# dispara o processo e gera o produto #
		/home/cdsr/drl/SPA/BlueMarble/wrapper/BlueMarble_modis-tcolor/run  modis.mxd021km $parametro_1km modis.mxd02hkm $parametro_500m modis.mxd02qkm $parametro_250m modis.mxd03 $parametro_GEO modis.sharptcolor $nome_arquivo_saida 

		# grava o Id da passagem na lista de passagens ja processadas #
		cd $dir_exe
		echo $id_passagem_especifica >> $dir_exe'/.passagens_processadas_250m_TERRA'
	fi
	
done



exit
