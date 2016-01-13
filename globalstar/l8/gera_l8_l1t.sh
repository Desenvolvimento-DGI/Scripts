#!/bin/bash 

VERMELHO='\033[0;31m'
AZUL='\033[0;34m'
NEGRITO='\033[1m'
NORMAL='\033[0m' 


ALIASSCRIPT='processa_l8_l1t'

PARPERIODO="${1}"
PARSATELITE="L8"
PARSENSOR="OLI"
DIRSCRIPTS='/home/cdsr/l8/'

SATELITE="`echo ${PARPERIODO} | cut -c 1-3`"
ORBITA="`echo ${PARPERIODO} | cut -c 4-6`"
ANO="`echo ${PARPERIODO} | cut -c 13-16`"
DIAJULIANO="`echo ${PARPERIODO} | cut -c 17-19`"

NUMPPID="$$"

CMDEMAIL='/usr/bin/mail '
EMAILOPERACAO='jose.renato@dgi.inpe.br,operadores-dgi@dgi.inpe.br,cdsr@dgi.inpe.br,marilia.moura@dgi.inpe.br'
ARQEMAILOPERACAO="${DIRSCRIPTS}OLI_MSG_OPERACAO_${NUMPPID}.txt"


ORIGEM='/L1_LANDSAT8/L1T/'

# Validar se o parametro PARPERIODO foi informado
if [ "${PARPERIODO}" == "" ]
then
	# Parametro nao informado
	echo ""
	echo -e "${AZUL}${NEGRITO}PROCESSAMENTO DO LANDSAT-8${NORMAL}"
	echo -e "${VERMELHO}${NEGRITO}PROBLEMA COM A EXECUCAO DO PROCESSAMENTO DO LANDSAT-8${NORMAL}"
	echo ""
	echo ""
	echo -e "${VERMELHO}${NEGRITO}PARAMENTRO${NORMAL} REFERENTE AO PERIODO A PROCESSAR ${VERMELHO}${NEGRITO}NAO FOI INFORMADO${NORMAL}"
	echo "SEGUE A LINHA DE COMANDO DIGITADA:"
	echo -e "${VERMELHO}${NEGRITO}$0 $* ${NORMAL}"
	echo ""
	echo -e "NECESSARIO INFORMAR A ${VERMELHO}${NEGRITO}AREA A SER PROCESSADA${NORMAL} COMO PARAMETRO PARA A EXECUCAO"
	echo "CORRETA DO SCRIPT ${ALIASSCRIPT}"

	# Envio do e-mail 
	echo "PROCESSAMENTO DO LANDSAT-8" > ${ARQEMAILOPERACAO}
	echo "PROBLEMA COM A EXECUCAO DO PROCESSAMENTO DO LANDSAT-8" >> ${ARQEMAILOPERACAO}
	echo "" >> ${ARQEMAILOPERACAO}
	echo "PARAMENTRO REFERENTE AO PERIODO A PROCESSAR NAO FOI INFORMADO" >> ${ARQEMAILOPERACAO}
	echo "SEGUE A LINHA DE COMANDO DIGITADA:" >> ${ARQEMAILOPERACAO}
	echo "$0 $*" >> ${ARQEMAILOPERACAO}
	echo "" >> ${ARQEMAILOPERACAO}
	echo "NECESSARIO INFORMAR A AREA A SER PROCESSADA COMO PARAMETRO PARA A EXECUCAO" >> ${ARQEMAILOPERACAO}
	echo "CORRETA DO SCRIPT ${ALIASSCRIPT}" >> ${ARQEMAILOPERACAO}
	echo "" >> ${ARQEMAILOPERACAO}
	
	
	
	ASSUNTOEMAIL="ERRO PROCESSAMENTO DO LANDSAT-8:: PARAMETRO NAO INFORMADO AO EXECUTAR O SCRIPT ${ALIASSCRIPT}"
	${CMDEMAIL} -s "${ASSUNTOEMAIL}" ${EMAILOPERACAO} < ${ARQEMAILOPERACAO}
	
	rm -fv ${ARQEMAILOPERACAO}

	echo ""
	echo ""
	
	exit 0
fi




# Validar se o parametro PARPERIODO foi informado com o 
# tamanho correto (24 caracteres)
# Ex. parametro correto:   LO80010570812015147CUB00
#
TAMANHOPARAMETRO=${#PARPERIODO}
if [ ${TAMANHOPARAMETRO} != 24 ]
then
	# Parametro invalido
	echo ""
	echo -e "${AZUL}${NEGRITO}PROCESSAMENTO DO LANDSAT-8${NORMAL}"
	echo -e "${VERMELHO}${NEGRITO}PROBLEMA COM A EXECUCAO DO PROCESSAMENTO DO LANDSAT-8${NORMAL}"
	echo ""
	echo ""
	echo -e "${VERMELHO}${NEGRITO}PARAMENTRO${NORMAL} REFERENTE AO PERIODO A PROCESSAR ${VERMELHO}${NEGRITO}NAO ESTA CORRETO${NORMAL}"
	echo "SEGUE A LINHA DE COMANDO DIGITADA:"
	echo -e "${VERMELHO}${NEGRITO}$0 $* ${NORMAL}"
	echo ""
	echo -e "NECESSARIO INFORMAR A ${VERMELHO}${NEGRITO}AREA A SER PROCESSADA CORRETAMENTE${NORMAL} PARA A EXECUCAO DO SCRIPT ${ALIASSCRIPT}"

	
	echo "PROCESSAMENTO DO LANDSAT-8" > ${ARQEMAILOPERACAO}
	echo "PROBLEMA COM A EXECUCAO DO PROCESSAMENTO DO LANDSAT-8" >> ${ARQEMAILOPERACAO}
	echo "" >> ${ARQEMAILOPERACAO}
	echo "PARAMENTRO REFERENTE AO PERIODO A PROCESSAR NAO ESTA CORRETO" >> ${ARQEMAILOPERACAO}
	echo "SEGUE A LINHA DE COMANDO DIGITADA:" >> ${ARQEMAILOPERACAO}
	echo "$0 $*" >> ${ARQEMAILOPERACAO}
	echo "" >> ${ARQEMAILOPERACAO}
	echo "NECESSARIO INFORMAR A AREA A SER PROCESSADA CORRETAMENTE PARA A EXECUCAO "
	echo "DO SCRIPT ${ALIASSCRIPT}" >> ${ARQEMAILOPERACAO}

	
	
	ASSUNTOEMAIL="ERRO PROCESSAMENTO DO LANDSAT-8:: PARAMETRO INFORMADO INCORRETAMENTE AO EXECUTAR O SCRIPT ${ALIASSCRIPT}"
	${CMDEMAIL} -s "${ASSUNTOEMAIL}" ${EMAILOPERACAO} < ${ARQEMAILOPERACAO}
	
	rm -fv ${ARQEMAILOPERACAO}

	echo ""
	echo ""
	
	exit 0
	
fi



# Verifica se existe a áa 

echo "VERIFICANDO E VALIDANDO PASSAGEM ${PARPERIODO} ..."
QDEPROCESSAR="`find ${ORIGEM} -name ${PARPERIODO} -print | wc -l`"

# Validar se a áa referente ao parametro PARPERIODO existe e
# Processa-la em caso positivo

if [ ${QDEPROCESSAR} -gt 0 ]
then
		
	DIAJULIANO="`echo ${PARPERIODO} | cut -c 17-19`"

	DATAGREGORIANAATUAL=""
	MES=""
	PARDIA=""
	for MESATUAl in `seq 1 12`
	do
		for DIAATUAL in `seq 1 31`
		do
			DATAGREGORIANAATUAL="${MESATUAl}/${DIAATUAL}/${ANO}"
			DATAJULIANOATUAL="`date +"%j" -d ${DATAGREGORIANAATUAL}`"

			if [ "${DATAGREGORIANAATUAL}" == "10/18/2015" ] && [ "${DIAJULIANO}" == "291"  ]
			then
				DATAJULIANOATUAL=291
				MES=10
				PARDIA=18
				break
			fi

		
			if [ $? -eq 0 ] && [ "${DATAJULIANOATUAL}" == "${DIAJULIANO}" ]
			then
				echo "ENCONTROU A DATA CORRETA ::  ${DATAJULIANOATUAL}  =   ${DIAJULIANO}"
				echo ""
				MES=${MESATUAl}
				PARDIA=${DIAATUAL}
				break
			fi		


		done
		if [ "${DATAJULIANOATUAL}" == "${DIAJULIANO}" ]
		then
			break
		fi
	done


	# Acerta o valor do mes caso seja menor que 10 preenchendo com zero a esquerda
	MES=$(( MES + 100 ))
	MES="`echo ${MES} | cut -c 2-3`"

	PARDIA=$(( PARDIA + 100 ))
	PARDIA="`echo ${PARDIA} | cut -c 2-3`"
	ANO="`echo ${PARPERIODO} | cut -c 13-16`"
	DIRANOMES="${ANO}_${MES}"
	
	
	
	
		
	# Necessario validacao sobre a composicao dos sensores
	#
	# 1. Se existirem dados apenas do sensor OLI nao sera necessario nenhum processamento adicional
	#    mantendo a nomeacao das areas e dos arquivos
	#
	# 2. Se existirem cenas dos sensores OLI e TIRS, sera necessario processamento adicional para
	#    tratar da nomeacao do area do periodo e dos arquivos, pois os dados foram gerados com a
	#    a nomecao iniciada por LC8 porque o dados bruto inicial possui dados compostos de cenas dos
	#    sensores OLI e TIRS, e o sistemas de processamento necessita que sejam identificados dessa
	#    forma 
	#
	
	COMPOSICAOSENSOR="`echo ${PARPERIODO} | cut -c 1-2`"
	
	if [ "${COMPOSICAOSENSOR}" == "LC" ]
	then
		${DIRSCRIPTS}acerta_nomeacao_l8_l1t.sh  ${PARPERIODO} ${ANO} ${MES}
		
		IDSENSOROLI="LO"
		PARTEFINAL_PARPARAMETRO="`echo ${PARPERIODO} | cut -c 3-`"
		NOVOPARPERIODO="${IDSENSOROLI}${PARTEFINAL_PARPARAMETRO}"
		
		PARPERIODO="${NOVOPARPERIODO}"
	fi
		
		
	
	
	# Executa, respectivamente, os scripts responsáis por gerar o quicklook e os registros no banco de dados

	${DIRSCRIPTS}gera_quicklook_l8_l1t.sh  ${PARPERIODO}  ${PARSATELITE}  ${PARSENSOR}  ${ANO}  ${MES}  ${ORBITA} ${PARDIA}
	${DIRSCRIPTS}gera_dados_db_l8_lt1.sh   ${PARPERIODO}  ${PARSATELITE}  ${PARSENSOR}  ${ANO}  ${MES}  ${ORBITA} ${PARDIA}
	${DIRSCRIPTS}envia_email_l8_l1t.sh     ${PARPERIODO}  ${PARSATELITE}  ${PARSENSOR}  ${ANO}  ${MES}  ${ORBITA} ${PARDIA} 
	
else
	# Area informada nãexiste ou ainda nãfoi transferida 
	# enviar e-mail e apresentar mensagem em tela
	
	echo ""
	echo -e "${AZUL}${NEGRITO}PROCESSAMENTO DO LANDSAT-8${NORMAL}"
	echo -e "${VERMELHO}${NEGRITO}PROBLEMA COM A EXECUCAO DO PROCESSAMENTO DO LANDSAT-8${NORMAL}"
	echo ""
	echo ""
	echo -e "${VERMELHO}${NEGRITO}PARAMENTRO${NORMAL} REFERENTE AO PERIODO A PROCESSAR ${VERMELHO}${NEGRITO}NAO EXISTE NA AREA /L1_LANDSAT8/L1T${NORMAL}"
	echo "SEGUE A LINHA DE COMANDO DIGITADA:"
	echo -e "${VERMELHO}${NEGRITO}$0 $* ${NORMAL}"
	echo ""
	echo -e "NECESSARIO INFORMAR A ${VERMELHO}${NEGRITO}AREA A SER PROCESSADA CORRETAMENTE${NORMAL} PARA A EXECUCAO DO SCRIPT ${ALIASSCRIPT}"
	echo ""
	echo ""	
	
	
	echo "PROCESSAMENTO DO LANDSAT-8" > ${ARQEMAILOPERACAO}
	echo "PROBLEMA COM A EXECUCAO DO PROCESSAMENTO DO LANDSAT-8" >> ${ARQEMAILOPERACAO}
	echo "" >> ${ARQEMAILOPERACAO}
	echo "PARAMENTRO REFERENTE AO PERIODO A PROCESSAR NAO EXISTE NA AREA ${ORIGEM}" >> ${ARQEMAILOPERACAO}
	echo "SEGUE A LINHA DE COMANDO DIGITADA:" >> ${ARQEMAILOPERACAO}
	echo "$0 $*" >> ${ARQEMAILOPERACAO}
	echo "" >> ${ARQEMAILOPERACAO}
	echo "NECESSARIO INFORMAR A AREA A SER PROCESSADA CORRETAMENTE$ PARA A EXECUCAO DO SCRIPT ${ALIASSCRIPT}" >> ${ARQEMAILOPERACAO}
	echo "" >> ${ARQEMAILOPERACAO}
	echo ""	>> ${ARQEMAILOPERACAO}
	
	
	ASSUNTOEMAIL="ERRO PROCESSAMENTO DO LANDSAT-8:: PARAMETRO INFORMADO NAO EXISTE NA AREA ${ORIGEM}"
	${CMDEMAIL} -s "${ASSUNTOEMAIL}" ${EMAILOPERACAO} < ${ARQEMAILOPERACAO}
	
	rm -f ${ARQEMAILOPERACAO}

	echo ""
	echo ""
		
	
fi

