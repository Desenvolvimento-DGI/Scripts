#!/bin/bash -x

# Gera a lista de arquivos com padrão anterior ao novissiomo #
# Renomeia no padrao CDSR
# Autor: José Neto
# Data: 06/2014

# Diretorio principal #
dir_exe='/home/cdsr/bin/'
# diretorio de saida #
dir_out=/GRALHA/RECUPERACAO_DE_DADOS/Dados_NOAA_renomeados_novissimo

# Parametros de entrada #
ano_mes=$2
satelite=$1

if [ $ano_mes ] && [ $satelite ]
then
	# Diretorio de pesquisa #
	#dir_hrpt="/L0_"$satelite"/"$ano_mes"/HRPT"
	dir_hrpt="/GRALHA/RECUPERACAO_DE_DADOS/Dados_BACKUP/"$satelite"/"$ano_mes
	cd $dir_hrpt
	#ls 'NOAA'*'_HRPT_C'*  > $dir_exe'/lista_nome_novo_'$ano_mes'_'$satelite
	#ls 'NOAA'*'_HRPT_N'*  >> $dir_exe'/lista_nome_novo_'$ano_mes'_'$satelite
	
	ls 'NOAA'*'_NT1_'*  > $dir_exe'/lista_nome_novo_'$ano_mes'_'$satelite
	
	cd $dir_exe
	# lendo a lista #
	while read arquivos
	do
		nome_antigo_01=`echo $arquivos | cut -d "." -f1`
		nome_antigo_02=`echo $arquivos | cut -d "." -f2`
		nome_antigo=$nome_antigo_01'.'$nome_antigo_02
		
		ano=`echo $nome_antigo | cut -d "_" -f5`
		mes=`echo $nome_antigo | cut -d "_" -f6`
		erg=`echo $nome_antigo | cut -d "_" -f4`
		sat=`echo $nome_antigo | cut -d "_" -f1`
		missao=`echo $nome_antigo | cut -d "_" -f2`
		
		dia_hora=`echo $nome_antigo | cut -d "_" -f7`
		dia=`echo $dia_hora | cut -d "." -f1`
		hora=`echo $dia_hora | cut -d "." -f2`
		min=`echo $nome_antigo | cut -d "_" -f8`
		seg=`echo $nome_antigo | cut -d "_" -f9`
		
		nome_novo=$sat'_'$missao'_HRPT_'$ano'_'$mes'_'$dia'.'$hora'_'$min'_'$seg'_'$erg
		
		# copiando o arquivo 
		cd $dir_exe
		cp -rf $dir_hrpt"/"$arquivos .
		# Extraindo
		tar zxf $arquivos
		cd $dir_exe
		rm -rf $arquivos
		
		# testa o nome do arquivo #
		if [ -e $nome_novo ]
		then
			# listando arquivos #
			cd $dir_exe'/'$nome_novo
			ls > $dir_exe'/listaNomeAntigo'
			cd $dir_exe
			pasta_abrir=$nome_novo
		fi
		if [ -e $nome_antigo ]
		then
			# listando arquivos #
			cd $dir_exe'/'$nome_antigo
			ls > $dir_exe'/listaNomeAntigo'
			cd $dir_exe
			pasta_abrir=$nome_antigo
		fi
		
		if [ $erg == 'NT1' ]
		then
		
			while read arq_rename
			do
				tipo=`echo $arq_rename | cut -d "." -f3`
				teste_outro=`echo $arq_rename | cut -d "_" -f10`
				
				if [ $teste_outro ]
				then
					teste_outro=`echo $teste_outro | cut -d "." -f1`
					
					if [ $teste_outro == 'CALIBRATION' ]
					then
						# renomeando os arquivos #
						cd $pasta_abrir
						nome_novo_02=$sat'_'$missao'_HRPT_'$ano'_'$mes'_'$dia'.'$hora'_'$min'_'$seg'_CALIBRATION_'$erg
						mv $arq_rename $nome_novo_02"."$tipo
						#echo $arq_rename $nome_novo_02"."$tipo
						cd $dir_exe
					fi			
					if [ $teste_outro == 'IDAP' ]
					then
						# renomeando os arquivos #
						cd $pasta_abrir
						nome_novo_02=$sat'_'$missao'_HRPT_'$ano'_'$mes'_'$dia'.'$hora'_'$min'_'$seg'_IDAP_'$erg
						mv $arq_rename $nome_novo_02"."$tipo
						echo $arq_rename $nome_novo_02"."$tipo
						cd $dir_exe
					fi
					
					if [ $teste_outro == 'IR' ]
					then
						# renomeando os arquivos #
						cd $pasta_abrir
						nome_novo_02=$sat'_'$missao'_HRPT_'$ano'_'$mes'_'$dia'.'$hora'_'$min'_'$seg'_IR_CURVES_'$erg
						mv $arq_rename $nome_novo_02"."$tipo
						#echo $arq_rename $nome_novo_02"."$tipo
						cd $dir_exe
					fi
					
					if [ $teste_outro == 'VIS' ]
					then
						# renomeando os arquivos #
						cd $pasta_abrir
						nome_novo_02=$sat'_'$missao'_HRPT_'$ano'_'$mes'_'$dia'.'$hora'_'$min'_'$seg'_VIS_CURVES_'$erg
						mv $arq_rename $nome_novo_02"."$tipo
						#echo $arq_rename $nome_novo_02"."$tipo
						cd $dir_exe
					fi
					
					if [ $teste_outro == 'L1B' ]
					then
						# renomeando os arquivos #
						cd $pasta_abrir
						nome_novo_02=$sat'_'$missao'_HRPT_'$ano'_'$mes'_'$dia'.'$hora'_'$min'_'$seg'_L1B_'$erg
						mv $arq_rename $nome_novo_02"."$tipo
						#echo $arq_rename $nome_novo_02"."$tipo
						cd $dir_exe
					fi
					
					if [ $teste_outro == 'TOVISTIP' ]
					then
						# renomeando os arquivos #
						cd $pasta_abrir
						nome_novo_02=$sat'_'$missao'_HRPT_'$ano'_'$mes'_'$dia'.'$hora'_'$min'_'$seg'_TOVISTIP_'$erg
						mv $arq_rename $nome_novo_02"."$tipo
						#echo $arq_rename $nome_novo_02"."$tipo
						cd $dir_exe
					fi
				else
				
					if [ $tipo == 'satelite' ]
					then
						cd $pasta_abrir
						rm -rf satelite
						cd $dir_exe
					else
					# renomeando os arquivos #
					#if [ $tipo == 'qlk' ] || [ $tipo == 'png' ] || [ $tipo == 'QLK' ] || [ $tipo == 'PNG' ]
					#then
					#	cd $nome_antigo
					#	mv $nome_antigo"."$tipo $nome_novo"_ORIGINAL.png"
					#	cd $dir_exe
					#else
						cd $pasta_abrir
						mv $arq_rename $nome_novo"."$tipo
						cd $dir_exe
					#fi
					fi
				fi
			done < $dir_exe'/listaNomeAntigo'
			
			cd $dir_exe
			mv $pasta_abrir $nome_novo
			
			# compacta #
			tar cf $nome_novo".tar" $nome_novo
			gzip $nome_novo".tar"
		
			# movendo para o diretorio de saida #
			cd $dir_out
			mkdir -p $satelite'/'$ano_mes
			cd $dir_exe
			mv $nome_novo'.tar.gz' $dir_out'/'$satelite'/'$ano_mes
			cd $dir_exe
			rm -rf $nome_novo
			
			
			
		fi	
	done < $dir_exe'/lista_nome_novo_'$ano_mes'_'$satelite
fi

exit

