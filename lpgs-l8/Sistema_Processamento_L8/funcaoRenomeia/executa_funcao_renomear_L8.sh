#!/bin/bash -x

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Descricao: Script que renomeia as passagens do satelite LANDSAT-8 atraves da interface WEB #
# Autor: Jose Neto
# Data: 04/2015
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#


#--------------------------------------------------------------------------------------------#
# Exporta as bibliotecas e funcoes para gerar os produtos #
#--------------------------------------------------------------------------------------------#
export md5sum=$PATH:/usr/bin/md5sum
export PATH=$PATH:/home/cdsr/bin/:/L0_LANDSAT8/AncillaryFiles/STS
#--------------------------------------------------------------------------------------------#
# Fim dos exports #
#--------------------------------------------------------------------------------------------#


#--------------------------------------------------------------------------------------------#
# Parametros iniciais para executar os processos que renomeia a passagem #
#--------------------------------------------------------------------------------------------#
# ano e mes da passagem #
ano_mes=$1
# nome da passagem #
nome_passagem=$2
# nome do arquivo XML que contem informacoes de base e ponto da passagem #
arquivo_xml=$3
# caracter chava para o banco de dados #
caracter_chave=$4
# Diretorios #
# Diretorio de execucao #
dir_exe='/dados/htdocs/Sistema_Processamento_L8/funcaoRenomeia'
# Diretorio do arquivo XML #
dir_xml='/L0_LANDSAT8/AncillaryFiles/STS'
# Diretorio do arquivo compactado #
dir_md='/L0_LANDSAT8/MISSION_DATA'
#--------------------------------------------------------------------------------------------#
# fim dos parametros #
#--------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------#
# Acerta as variaveis e indica os locais corretos dos dados #
#--------------------------------------------------------------------------------------------#
# variavel contem o caminho completo do diretorio e do arquivo #
dir_completo_passagem=$dir_md'/'$ano_mes'/'$nome_passagem
# variavel contem o caminho completo e o nome do arquivo XML #
dir_completo_xml=$dir_xml'/'$arquivo_xml
# variaves de dia, mes e ano#
ano=`echo $ano_mes | cut -d "_" -f1`
mes=`echo $ano_mes | cut -d "_" -f2`
dia=`echo $nome_passagem | cut -d "_" -f6`
dia=`echo $dia | cut -d "." -f1`

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

# Remove o .tar.gz do nome do arquivo #
prefixo=`echo $nome_passagem | cut -d "." -f1`
sufixo=`echo $nome_passagem | cut -d "." -f2`

# Nome da pasta que armazenara os arquivos renomeados
pasta_arquivo_renomeado=$prefixo'.'$sufixo
#--------------------------------------------------------------------------------------------#
# fim dos acertos #
#--------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------#
# Processo de renomear #
#--------------------------------------------------------------------------------------------#
# verifica se existe a pasta #
cd $dir_exe
if [ -e $pasta_arquivo_renomeado ]
then
	echo 'ok'
	rm -rf $pasta_arquivo_renomeado
fi
# Cria a pasta que armazenara os arquivos renomeados #
cd $dir_exe
mkdir $pasta_arquivo_renomeado
# copia o arquivo #
cd $dir_exe
cp -rf $dir_completo_passagem $dir_exe'/'$pasta_arquivo_renomeado
# Descompacta o arquivo #
cd $pasta_arquivo_renomeado
tar zxf $nome_passagem
# Remove o arquivo compactado #
if [ -e $nome_passagem ]
then
	rm $nome_passagem
fi
# move o conteudo da pasta OLI-RT #
cd $dir_exe

# verifica se existe outra pasta dentro #
if [ -e $pasta_arquivo_renomeado'/OLI-RT/' ] 
then 
	cp -rf $pasta_arquivo_renomeado'/OLI-RT/'* $dir_exe'/'$pasta_arquivo_renomeado
fi

# As vezes a passagem vem com o nome errado #
if [ -e $pasta_arquivo_renomeado'/OLI_RT/' ] 
then
	cd $dir_exe'/'$pasta_arquivo_renomeado
	mv 'OLI_RT' 'OLI-RT'
	cd $dir_exe
	cp -rf $pasta_arquivo_renomeado'/OLI-RT/'*	$dir_exe'/'$pasta_arquivo_renomeado
fi




# Verificacoes para dados do sensor TIRS
# ======================================
#


# verifica se existe outra pasta dentro #
if [ -e $pasta_arquivo_renomeado'/TIRS-RT/' ]
then
        cp -rf $pasta_arquivo_renomeado'/TIRS-RT/'* $dir_exe'/'$pasta_arquivo_renomeado
fi

# As vezes a passagem vem com o nome errado #
if [ -e $pasta_arquivo_renomeado'/TIRS_RT/' ]
then
        cd $dir_exe'/'$pasta_arquivo_renomeado
        mv 'TIRS_RT' 'TIRS-RT'
        cd $dir_exe
        cp -rf $pasta_arquivo_renomeado'/TIRS-RT/'*      $dir_exe'/'$pasta_arquivo_renomeado
fi


#
# ======================================
#




# apaga os arquivos desnecessarios #
cd $dir_exe'/'$pasta_arquivo_renomeado
rm -rf 'OLI-RT'
rm -rf 'TIRS_RT'


# Gera lista dos arquivos dentro da pasta OLI #
cd $dir_exe'/'$pasta_arquivo_renomeado
ls | grep -iv TEMP | grep -iv TIRS | grep -iv OLI  > $dir_exe'/.listaOLI'

echo ""
echo ""
cat $dir_exe'/.listaOLI'
echo ""
echo ""


num_root_id=`cat $dir_exe'/.listaOLI' | grep -i . | cut -d "." -f1 | sort | uniq | wc -l`

echo ""
echo ""
echo "num_root_id = $num_root_id"
echo ""
echo ""





if [ "${num_root_id}" == 1 ]
then 
	# capturando o ROOT ID do arquivo #
	cd $dir_exe
	root_id_arquivo=`cat $dir_exe'/.listaOLI' | head -1`
	root_id_arquivo=`echo $root_id_arquivo | cut -d "." -f1`

	tirs_root_id_arquivo=""
	prefixo_sensor="LO8"
fi


if [ "${num_root_id}" == 2 ]
then

        # capturando o ROOT ID do arquivo #
        cd $dir_exe
        root_id_arquivo=`cat $dir_exe'/.listaOLI' | grep -i "." |  cut -d "." -f1 | sort | uniq | tail -1`
        tirs_root_id_arquivo=`cat $dir_exe'/.listaOLI' | grep -i "." | cut -d "." -f1 | sort | uniq | head -1`
	tirs_root_id_arquivo="${tirs_root_id_arquivo}*"

	prefixo_sensor="LC8"
fi




# variavel que controla o status do processo #
controle_processo_01='AGUARDANDO'

# Lista o arquivo XML e procura quantos pontos a passagem possui #
continua='nao'
while read dados_xml
do
	#----echo $dados_xml - '<ROOT_FILE_ID>'$root_id_arquivo'</ROOT_FILE_ID>' >> lista01
	if [ $dados_xml == '<ROOT_FILE_ID>'$root_id_arquivo'</ROOT_FILE_ID>' ]
	then
		continua='sim'
	fi
	if [ $continua == 'sim' ]
	then
		variavel_teste_num=`echo $dados_xml | cut -d ">" -f1`
		variavel_teste_id=`echo $dados_xml | cut -d ">" -f1`
		if [ $variavel_teste_num == '<NUM_SCENES' ]
		then
			numero_de_cenas=`echo $dados_xml | cut -d ">" -f2`
			numero_de_cenas=`echo $numero_de_cenas | cut -d "<" -f1`
		fi
		if [ $variavel_teste_id == '<SCENE_ID' ]
		then
			scene_id=`echo $dados_xml | cut -d ">" -f2`
			scene_id=`echo $scene_id | cut -d "<" -f1`
			# Arquivo que sera utilizado para gerar IDF #
			arquivo_xml_IDF=$arquivo_xml
			# variavel que controla o status do processo #
			controle_processo_01='OK'
			break;
		fi
	fi
done < $dir_completo_xml

# Verifica se encontrou as informacoes corretamente #
if [ $controle_processo_01 == "OK" ]
then
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
		# nome_novo_l8='LC8'$base''$ponto_inicial'0'$ponto_final''$ano''$dia_juliano'CUB00'
		nome_novo_l8=$prefixo_sensor''$base''$ponto_inicial'0'$ponto_final''$ano''$dia_juliano'CUB00'
	else
		ponto_somar=`echo $ponto_inicial | cut -c1-3`
		ponto_final=$(( $ponto_somar + $numero_de_cenas - 1 ))
		# cria o novo nome da passagem #
		# nome_novo_l8='LC8'$base''$ponto_inicial''$ponto_final''$ano''$dia_juliano'CUB00'
		nome_novo_l8=$prefixo_sensor''$base''$ponto_inicial''$ponto_final''$ano''$dia_juliano'CUB00'
	fi
		
	# 2 - Lista e renomeia os arquivos #
	cd $dir_exe
	mv $pasta_arquivo_renomeado $nome_novo_l8
	#--------------------------------------------------------------------------------------------#
	# Gera o checksum #
	#--------------------------------------------------------------------------------------------#
	cd $dir_exe'/'$nome_novo_l8
	#md5sum -b $root_id_arquivo* > $nome_novo_l8'_MD5.txt'
	md5sum -b $tirs_root_id_arquivo  $root_id_arquivo* > $nome_novo_l8'_MD5.txt'


	#--------------------------------------------------------------------------------------------#
	# fim do checksim #
	#--------------------------------------------------------------------------------------------#
	
	#--------------------------------------------------------------------------------------------#
	# Gera o IDF #
	#--------------------------------------------------------------------------------------------#
	cd $dir_xml
	/home/cdsr/bin/IDFGenerator.pl $dir_exe'/'$nome_novo_l8 $nome_novo_l8 $dir_xml'/'$arquivo_xml_IDF
	#--------------------------------------------------------------------------------------------#
	# fim do IDF #
	#--------------------------------------------------------------------------------------------#

	#--------------------------------------------------------------------------------------------#
	# Verifica se gerou o MD5 e o IDF para a passagem #
	#--------------------------------------------------------------------------------------------#
	arquivo_MD5=$nome_novo_l8'_MD5.txt'
	arquivo_IDF=$nome_novo_l8'_IDF.xml'
	cd $dir_exe'/'$nome_novo_l8
	if [ -e $arquivo_MD5 ]
	then
		MD5='OK'
	else
		MD5='ERRO'
	fi
	if [ -e $arquivo_IDF ]
	then
		IDF='OK'
	else
		IDF='ERRO'
	fi
	#--------------------------------------------------------------------------------------------#
	# fim da verificacao #
	#--------------------------------------------------------------------------------------------#
	
	#--------------------------------------------------------------------------------------------#
	# Move a passagem renomeada para o direotrio de L0_LANDSAT8 #
	#--------------------------------------------------------------------------------------------#
	# Diretorio padrao de saida #
	dir_saida='/dados/L0_LANDSAT8/MISSION_DATA'
	cd $dir_exe
	if [ -e $dir_saida'/'$ano_mes'/'$nome_novo_l8 ]
	then
		cd $dir_saida'/'$ano_mes'/'
		rm -rf $nome_novo_l8
	fi
	cd $dir_exe
	#--mv $nome_novo_l8 $dir_md'/'$ano_mes
	# cria o diretorio de saida #
	mkdir -p $dir_saida'/'$ano_mes'/'
	mv $nome_novo_l8 $dir_saida'/'$ano_mes
	#-- teste -- cp -rf $nome_novo_l8 $dir_md'/'$ano_mes
	#--------------------------------------------------------------------------------------------#
	# fim  #
	#--------------------------------------------------------------------------------------------#
	
	#--------------------------------------------------------------------------------------------#
	# Grava no banco de dados os status #
	#--------------------------------------------------------------------------------------------#
	
	# Variaveis de Data #
	dia=`date '+%d'`
	mes=`date '+%m'`
	ano=`date '+%Y'`
	# Variaveis de hora #
	hora=`date '+%H'`
	min=`date '+%M'`
	seg=`date '+%S'`
	# data e hora de termino do processo #
	data_final=$dia'/'$mes'/'$ano' '$hora':'$min':'$seg
	
	# Atualiza os dados no banco de dados #
	# Se MD5 ou IDF com erro - Grava erro #
	if [ $MD5 == "ERRO" ] || [ $IDF == "ERRO" ]
	then
		# MD5 #
		if [ $MD5 == "ERRO" ]
		then
			# Atualiza a tabela do processo #
			up_renomeia=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE processos_Landsat8 SET proc_data_final = '$data_final', 
			proc_nome_final = '$nome_novo_l8', proc_status = 'ERRO-MD5' WHERE proc_caracter_chave = '$caracter_chave'"`
			# Atualiza a tabela que grava dados da função renomear #
			up_renomeia=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE dados_renomear SET dr_nome_renomeado = '$nome_novo_l8', 
			dr_status = 'RENOMEADO-ERRO-MD5' WHERE dr_chave_processo = '$caracter_chave'"`
		fi
		# IDF #
		if [ $IDF == "ERRO" ]
		then
			# Atualiza a tabela do processo #
			up_renomeia=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE processos_Landsat8 SET proc_data_final = '$data_final', 
			proc_nome_final = '$nome_novo_l8', proc_status = 'ERRO-IDF' WHERE proc_caracter_chave = '$caracter_chave'"`
			# Atualiza a tabela que grava dados da função renomear #
			up_renomeia=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE dados_renomear SET dr_nome_renomeado = '$nome_novo_l8', 
			dr_status = 'RENOMEADO-ERRO-IDF' WHERE dr_chave_processo = '$caracter_chave'"`
		fi
		# MD5 e IDF #
		if [ $MD5 == "ERRO" ] && [ $IDF == "ERRO" ]
		then
			# Atualiza a tabela do processo #
			up_renomeia=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE processos_Landsat8 SET proc_data_final = '$data_final', 
			proc_nome_final = '$nome_novo_l8', proc_status = 'ERRO-MD5-IDF' WHERE proc_caracter_chave = '$caracter_chave'"`
			
			# Atualiza a tabela que grava dados da função renomear #
			up_renomeia=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE dados_renomear SET dr_nome_renomeado = '$nome_novo_l8', 
			dr_status = 'RENOMEADO-ERRO-MD5-IDF' WHERE dr_chave_processo = '$caracter_chave'"`
			
		fi
	else
		# Atualiza a tabela do processo #
		up_renomeia=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE processos_Landsat8 SET proc_data_final = '$data_final', 
		proc_nome_final = '$nome_novo_l8', proc_status = 'FINALIZADO' WHERE proc_caracter_chave = '$caracter_chave'"`
		# Atualiza a tabela que grava dados da função renomear #
		up_renomeia=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE dados_renomear SET dr_nome_renomeado = '$nome_novo_l8', 
		dr_status = 'RENOMEADO-OK' WHERE dr_chave_processo = '$caracter_chave'"`
	fi

else
	# Alguma variavel faltando, grava erro #
	# Atualiza os dados no banco de dados #
	up_renomeia=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE processos_Landsat8 SET proc_data_final = '$data_final', 
	proc_nome_final = '$nome_novo_l8', proc_status = 'ERRO-ROOT_ID' WHERE proc_caracter_chave = '$caracter_chave'"`
	# Atualiza a tabela que grava dados da função renomear #
	up_renomeia=`mysql -h 150.163.134.104 -P3333 -u dgi -pdgi.2013 -D sistema_L8 -s -e "UPDATE dados_renomear SET dr_status = 'ERRO-ROOT_ID' 
	WHERE dr_chave_processo = '$caracter_chave'"`
	
	cd $dir_exe
	rm -rf $pasta_arquivo_renomeado

fi

#--------------------------------------------------------------------------------------------------------#
# fim dodo processo de renomear #
#--------------------------------------------------------------------------------------------------------#

exit

