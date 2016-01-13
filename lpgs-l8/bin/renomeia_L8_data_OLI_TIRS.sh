#!/bin/bash -x

#-------------------------------------------------------------------#
# Descricao: Script que renomeia as passagens do satelite LANDSAT-8 #
# 1- busca a orbita/ponto no arquivo XML
# 2- altera o nome do diretorio com a orbita/ponto
# Autor: Jose Neto
# Data: 02/2015
#-------------------------------------------------------------------#

# Diretorios #
# Diretorio de execucao #
dir_exe='/home/cdsr/bin'
# Diretorio do arquivo XML #
dir_xml='/L0_LANDSAT8/AncillaryFiles/STS'
# Diretorio do arquivo compactado #
dir_md='/L0_LANDSAT8/MISSION_DATA'

# Verifica se foi informado o parametro da data para realizar o procedimento #
data_procedimento='vazio'
data_procedimento=$1
if [ $data_procedimento == 'vazio' ]
then
	echo "erro"
	exit
fi

# Variaveis de data #
ano=`echo $data_procedimento | cut -d "-" -f1`
mes=`echo $data_procedimento | cut -d "-" -f2`
dia=`echo $data_procedimento | cut -d "-" -f3`
# dia juliano do dia informado #
if [ $mes == 01 ]; then mes_str='Jan'; fi
if [ $mes == 02 ]; then mes_str='Feb'; fi
if [ $mes == 03 ]; then mes_str='Mar'; fi
if [ $mes == 04 ]; then mes_str='Apr'; fi
if [ $mes == 05 ]; then mes_str='May'; fi
if [ $mes == 06 ]; then mes_str='Jun'; fi
if [ $mes == 07 ]; then mes_str='Jul'; fi
if [ $mes == 08 ]; then mes_str='Aug'; fi
if [ $mes == 09 ]; then mes_str='Sep'; fi
if [ $mes == 10 ]; then mes_str='Oct'; fi
if [ $mes == 11 ]; then mes_str='Nov'; fi
if [ $mes == 12 ]; then mes_str='Dec'; fi
# captura o dia juliano da data informada #
dia_juliano=`date '+%j' -d "$mes_str $dia $ano"`
# $ date +"%s" -d "Feb 14 2012" #

# Gera lista de arquivos armazenados #
cd $dir_md'/'$ano'_'$mes
ls *$ano'_'$mes'_'$dia*'.tar.gz' > $dir_exe'/.listaMD_OLI_TIRS'
cd $dir_exe

# Le a lista de arquivos #
while read arquivos_L8
do
	# Remove o .tar.gz do nome do arquivo #
	prefixo=`echo $arquivos_L8 | cut -d "." -f1`
	sufixo=`echo $arquivos_L8 | cut -d "." -f2`
	nome_pasta=$prefixo"."$sufixo
	# cria a pasta #
	cd $dir_exe
	mkdir $nome_pasta
	# copia o arquivo #
	#--cp -rf $dir_md'/'$ano'_'$mes'/'$arquivos_L8 $dir_exe"/"$nome_pasta
	# Descompacta o arquivo #
	cd $nome_pasta
	tar zxf $arquivos_L8
	# Remove o arquivo compactado #
	if [ -e $arquivos_L8 ]
	then
		rm $arquivos_L8
	fi
	
	# Gera lista dos arquivos #
	cd $nome_pasta
	ls 'OLI-RT/' > $dir_exe'/.listaOLI_01'
	ls 'TIRS-RT/' > $dir_exe'/.listaTIRS_01'
	
	exit
	# capturando o ROOT ID do arquivo #
	cd $dir_exe
	root_id_arquivo=`cat $dir_exe'/.listaOLI' | head -1`
	root_id_arquivo=`echo $root_id_arquivo | cut -d "." -f1`

	# pega os arquivos XML que contenham a informacao da passagem #
	cd $dir_xml
	# busca o arquivo que contém os dados das passagens #
	#parametro_pesquisa_01='<ROOT_FILE_ID>'$root_id_arquivo
	parametro_pesquisa_01='<ROOT_FILE_CMD_TIME>'$ano'-'$dia_juliano
	arq_xml=`grep $parametro_pesquisa_01  *.xml`
	cd $dir_exe
	# filtra novamente os arquivos encontrados com o dia juliano #
	
	controle_data_bp='ok'
	for lista in $arq_xml
	do
		ver_xml=`echo $lista | cut -d "." -f2`
		if [ $ver_xml == 'xml:' ]
		then
			arquivo_xml=$lista
			# Verifica no primeiro arquivo #
			continua='nao'
			arquivo_xml=`echo $arquivo_xml | cut -d ":" -f1`
			while read dados_xml
			do
				if [ $dados_xml == '<ROOT_FILE_ID>'$root_id_arquivo'</ROOT_FILE_ID>' ]
				then
					continua='sim'
				fi
				
				if [ $continua == 'sim' ]
				then
					variavel_teste_data=`echo $dados_xml | cut -d ">" -f1`
					variavel_teste_num=`echo $dados_xml | cut -d ">" -f1`
					variavel_teste_id=`echo $dados_xml | cut -d ">" -f1`
					
					# valida a data #
					if [ $variavel_teste_data == '<ROOT_FILE_CMD_TIME' ]
					then
						verifica_data=`echo $dados_xml | cut -d ">" -f2`
						verifica_data=`echo $verifica_data | cut -d "<" -f1`
						parte_data_ano=`echo $verifica_data | cut -d "-" -f1`
						parte_data_juliano=`echo $verifica_data | cut -d "-" -f2`
						if [ $parte_data_ano != $ano ] || [ $parte_data_juliano != $dia_juliano ]
						then
							controle_data_bp='erro'
							echo 'erro'
							
						fi
					else
						#<ROOT_FILE_CMD_TIME>2015-055
						if [ $variavel_teste_num == '<NUM_SCENES' ] && [ $controle_data_bp != 'erro' ]
						then
							numero_de_cenas=`echo $dados_xml | cut -d ">" -f2`
							numero_de_cenas=`echo $numero_de_cenas | cut -d "<" -f1`
						fi
						if [ $variavel_teste_id == '<SCENE_ID' ] && [ $controle_data_bp != 'erro' ]
						then
							scene_id=`echo $dados_xml | cut -d ">" -f2`
							scene_id=`echo $scene_id | cut -d "<" -f1`
							# Arquivo que sera utilizado para gerar IDF #
							arquivo_xml_IDF=$arquivo_xml
							break;
						fi
					fi
				fi
			done < $dir_xml"/"$arquivo_xml
		fi
	done
	
	# Agora, o programa ja possui o valor do scene_id e numero_de_cenas #
	# 1- Arrumar a base e ponto #
	# 2- listar e renomear as passagens #

	# 1- arruma a base e o ponto das passagens #
	base=`echo $scene_id | cut -d "_" -f2`
	ponto_inicial=`echo $scene_id | cut -d "_" -f3`
	teste_ponto_somar=`echo $ponto_inicial | cut -c1`
	if [ $teste_ponto_somar == 0 ]
	then
		ponto_somar=`echo $ponto_inicial | cut -c2-3`
		ponto_final=$(( $ponto_somar + $numero_de_cenas - 1 ))
		# cria o novo nome da passagem #
		nome_novo_l8='LO8'$base''$ponto_inicial'0'$ponto_final''$ano''$dia_juliano'CUB00'
	else
		ponto_somar=`echo $ponto_inicial | cut -c1-3`
		ponto_final=$(( $ponto_somar + $numero_de_cenas - 1 ))
		# cria o novo nome da passagem #
		nome_novo_l8='LO8'$base''$ponto_inicial''$ponto_final''$ano''$dia_juliano'CUB00'
	fi
	
	# LO82320580832015053CUB00 #
	# 2 - Lista e renomeia os arquivos #
	cd $dir_exe
	cd $nome_pasta
	mv 'OLI-RT/' $nome_novo_l8
	mv $nome_novo_l8'/' $dir_exe'/'
	
	# Gera o checksum #
	cd $dir_exe
	cd $nome_novo_l8
	md5sum -b $root_id_arquivo* > $nome_novo_l8'_MD5.txt'

	# Gera o IDF #
	cd $dir_xml
	$HOME/bin/IDFGenerator.pl $dir_exe'/'$nome_novo_l8 $nome_novo_l8 $arquivo_xml_IDF
		
	# Armazena na pasta L0_LANSAT8 #
	cd $dir_exe
	cp -rf $nome_novo_l8 $dir_md'/'$ano'_'$mes'/'

	# Limpa a area home #
	cd $dir_exe
	if [ -e $nome_pasta ]
	then
		rm -rf $nome_pasta
		if [ -e $nome_novo_l8 ] && [ -e $dir_md'/'$ano'_'$mes'/'$nome_novo_l8 ]
		then
			rm -rf $nome_novo_l8
		fi
	fi
		
done < $dir_exe'/.listaMD_OLI_TIRS'



exit
