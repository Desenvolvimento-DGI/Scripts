#!/bin/bash -x

#################################################################
# descricao: Script que gera o TIF das passagem S-NPP com 250m 	#
# Autor: Jose Neto e Reuel										#
# Data: 09/2015 												#
#################################################################

# Diretorios #
# diretorio de execucao #
dir_exe='/home/cdsr/bin/'

# diretorio dos dados #
dir_level1='/raid/pub/gsfcdata/npp/viirs/level1'
dir_level2='/raid/pub/gsfcdata/npp/viirs/level2'

# Exporta algumas variaveis de ambiente #
export PATH=$PATH:/home/cdsr/drl/SPA/BlueMarble/wrapper/BlueMarble_modis-tcolor
export PATH=$PATH:/raid

# Busca a informação no banco de dados do processamento  IPOPP #

# id do ultimo produto a ser gerado - MOD 250m #
id_passagem=`/usr/bin/mysql -u root -pb28c935 -D DSM -s -e "SELECT id FROM Resources WHERE path LIKE '%CVIIRSI%' ORDER BY id Desc LIMIT 1"`

# Verifica os ultimos 5 processos TERRA #
for id_passagem_especifica in $id_passagem
do 

	# Variavel com o valor do produto gerado - MOD 250m #
	CVIIRSI=`mysql -u root -pb28c935 -D DSM -s -e "SELECT path FROM Resources WHERE path LIKE '%CVIIRSI%' AND id = '$id_passagem_especifica'"`
	# recorta a data do produto #
	data_produto=`echo $CVIIRSI | cut -d "_" -f7`
	# recorta demais parametros #
	#CVIIRSI=CVIIRSI_npp_d20150917_t1628570_e1644358_b00001_c20150918170828839000_all-_dev.hdf
	parte2=`echo $CVIIRSI | cut -d "_" -f2`
	parte3=`echo $CVIIRSI | cut -d "_" -f3`
	parte4=`echo $CVIIRSI | cut -d "_" -f4`
	parte5=`echo $CVIIRSI | cut -d "_" -f5`
	parte6=`echo $CVIIRSI | cut -d "_" -f6`
	# nome da parate complementar da passagem #
	parte_complemento=$parte2'_'$parte3"_"$parte4'_'$parte5'_'$parte6
	
	# parametro de consulta #
	pesquisa_GITCO='GITCO_'$parte2'_'$parte3'_'$parte4'_'$parte5
	# Busca o nome da variavel GEO no banco de dados #
	arquivo_GITCO=`mysql -u root -pb28c935 -D DSM -s -e "SELECT path FROM Resources WHERE path LIKE '%$pesquisa_GITCO%' "`
	
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
	done < $dir_exe'/.passagens_processadas_250m_NPP'
	
	# verifica se vai executar o processamento #
	if [ $processar == 'sim' ]
	then
	
		# variaveis com os arquivos necessario #
		CVIIRSM=$dir_level2'/CVIIRSM_'$parte_complemento'_'$data_produto'_all-_dev.hdf'
		CVIIRSI=$dir_level2'/CVIIRSI_'$parte_complemento'_'$data_produto'_all-_dev.hdf'
		GITCO=$dir_level1'/'$arquivo_GITCO
		
		# Verica se os arquivos existem nos seus respectivos diretorios #
		# Arquivo de 500m #
		if [ -e $CVIIRSM ]
		then
			parametro_500m=$CVIIRSM
		else
			echo "Falta arquivo CVIIRSM: "$CVIIRSM
			exit
		fi
		# Arquivo de 250m #
		if [ -e $CVIIRSI ]
		then
			parametro_250m=$CVIIRSI
		else
			echo "Falta arquivo CVIIRSI: "$CVIIRSI
			exit
		fi
		# Arquivo GEO #
		if [ -e $GITCO ]
		then
			parametro_GEO=$GITCO
		else
			echo "Falta arquivo GITCO: "$GITCO
			exit
		fi 
		
		# Se todos os arquivos forem encontrados, o processo é executado #
		# acertar data para o arquivo de saida #
        ano=$(echo ${data_produto} | cut -c 2-5)
        mes=$(echo ${data_produto} | cut -c 6-7)
		dia=$(echo ${data_produto} | cut -c 8-9)
        hh=$(echo ${data_produto} | cut -c 10-11)
        mm=$(echo ${data_produto} | cut -c 12-13)
        ss=$(echo ${data_produto} | cut -c 14-15)
		
		dia_juliano=`date -d $ano'-'$mes'-'$dia +%j `
		ano_2=`echo $ano | cut -c3-4`

        # diretorio e nome do arquivo de saida #
		dir_saida='/raid/TIFF_250M/NPP/'$ano'_'$mes'_'$dia'.'$hh'_'$mm'_'$ss
		arq_saida='NPP_CVIIRS_L2.'$ano_2''$dia_juliano''$hh''$mm''$ss'.TCOLOR.250M.h5.tif'
		nome_arquivo_saida=$dir_saida'/'$arq_saida
		
		
		# cria o diretorio de saida #
		mkdir -p $dir_saida
		# dispara o processo e gera o produto #
		/home/cdsr/drl/SPA/BlueMarble/wrapper/BlueMarble_viirs-tcolor/run viirs.mcrefl $parametro_500m viirs.icrefl $parametro_250m viirs.gitco $parametro_GEO viirs.sharptcolor $nome_arquivo_saida 

		# grava o Id da passagem na lista de passagens ja processadas #
		cd $dir_exe
		echo $id_passagem_especifica >> $dir_exe'/.passagens_processadas_250m_NPP'
	fi
	
done



exit
