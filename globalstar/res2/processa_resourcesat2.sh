#!/bin/bash
# Funcao pra retornar o numero do mes com base no nome do mes

RETORNA_MES()
{
	VARNOMEMES="${1}"
	
	case ${VARNOMEMES} in
	
		"JAN") VARMES="01";;
		"FEB"|"FEV") VARMES="02";;
		"MAR") VARMES="03";;
		"APR"|"ABR") VARMES="04";;
		"MAY"|"MAI") VARMES="05";;
		"JUN") VARMES="06";;
		"JUL") VARMES="07";;
		"AUG"|"AGO") VARMES="08";;
		"SEP"|"SET") VARMES="09";;
		"OCT"|"OUT") VARMES="10";;
		"NOV") VARMES="11";;
		"DEC"|"DEZ") VARMES="12";;	
		
	esac
	
	echo "$VARMES"
}

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/cdsr/.local/bin:/home/cdsr/bin:/usr/local/gdal-1.11.1/bin:/usr/local/gdal-1.11.1/lib:/usr/local/gdal-1.11.1
export PATH

LD_LIBRARY_PATH=/usr/local/gdal-1.11.1/lib
export LD_LIBRARY_PATH


DESTINO="/L4_RESOURCESAT2/"

DIRATUAL="`pwd`"
AREASCRIPTS="/home/cdsr/res2/"

# Scripts para organizar as áas
# -----------------------------------------------------------
AWIFSORGANIZA="${AREASCRIPTS}organiza_areas_res2_awifs.sh "
LISS3ORGANIZA="${AREASCRIPTS}organiza_areas_res2_liss3.sh "

# Scripts para gerar os aquicklooks
# -----------------------------------------------------------
AWIFSGERAQL="${AREASCRIPTS}gera_quicklook_res2_awifs.sh "
LISS3GERAQL="${AREASCRIPTS}gera_quicklook_res2_liss3.sh "

# Scripts para gerar os registros no banco de dados
# -----------------------------------------------------------
AWIFSGERADADOSDB="${AREASCRIPTS}gera_dados_db_res2_awifs.sh "
LISS3GERADADOSDB="${AREASCRIPTS}gera_dados_db_res2_liss3.sh "


# Scripts para enviar e-mail para o CQ
# -----------------------------------------------------------
AWIFSENVIAEMAIL="${AREASCRIPTS}envia_email_cq_res2_awifs.sh "
LISS3ENVIAEMAIL="${AREASCRIPTS}envia_email_cq_res2_liss3.sh "




NOMEPROGRAMA="`basename $0`"
NPARAMETROS=$#

if [ "${NPARAMETROS}" -lt 1 ]
then
	 
	echo ""
	echo "${NOMEPROGRAMA}"
	echo ""
	echo "Necessario passar o(s) nome(s) do(s) arquivo(s) compactado(s) (.tgz) com o caminho completo."
	echo "O nome de cada arquivo a ser processado deve ser informado com o caminho completo (absoluto):"
	echo "Informar /L4_RESOURCESAT2/2014_10/RS2LS317OCT2014334GODP.tgz e nao somente RS2LS317OCT2014334GODP.tgz"
	echo ""
	echo "Na composiç do nome deve existir a informaç da data completa (DIA, MES e ANO). Estas"
	echo "informacoes sao necessarias para que o processamento ocorra corretamente."
	echo ""
	echo ""
	echo "Exemplo 1: Processar o arquivo RS2LS317OCT2014334GODP.tgz:"
	echo "${NOMEPROGRAMA} /L4_RESOURCESAT2/2014_10/RS2LS317OCT2014334GODP.tgz"
	echo ""
	echo "Exemplo 2: Processar os arquivo RS2LS317OCT2014334GODP.tgz e RS2AWA-D22OCT2014311GODP.tgz:"
	echo "${NOMEPROGRAMA} /L4_RESOURCESAT2/2014_10/RS2LS317OCT2014334GODP.tgz  /L4_RESOURCESAT2/2014_10/RS2AWA-D22OCT2014311GODP.tgz"
	echo ""
	exit 

fi


# Lista dos nomes de arquivos passados como parametro
LISTAARQUIVOSTGS=$@


echo ""
echo "${NOMEPROGRAMA}"
echo ""
echo "Arquivos a serem processados:"

for PARARQUIVOATUAl in ${LISTAARQUIVOSTGS}
do
	echo "${PARARQUIVOATUAl}"
done
echo ""
echo ""





# Executa o processo para cada arquivo vádo
for ARQUIVOTGZATUAL in ${LISTAARQUIVOSTGS}
do

	# Nome do arquivo com o caminho completo
	ARQUIVOTGZ="${ARQUIVOTGZATUAL}"

	if [ ! -e "${ARQUIVOTGZ}" ]
	then

		echo ""
		echo "${NOMEPROGRAMA}"
		echo "Arquivo  ${ARQUIVOTGZ}"
		echo "Arquivo informado nao encontrado ou informado incorretamente."
		echo "Necessario informar o arquivo com o caminho completo e nao apenas o nome do arquivo."
		echo ""
		exit 

	fi



	# Apenas o nome do arquivo
	NOMEARQUIVOTGZ="`basename ${ARQUIVOTGZ}`"


	IDSATELITE="`echo ${NOMEARQUIVOTGZ} | cut -c 1-3`"
	IDSENSOR="`echo ${NOMEARQUIVOTGZ} | cut -c 4-5`"

	SATELITE="RES2"



	# Verifica a nomeacao do arquivo atual
	if [ "${IDSATELITE}" = ""  -o "${IDSATELITE}" != "RS2" ] 
	then

		echo "ARQUIVO ${NOMEARQUIVOTGZ} INVALIDO."
		exit
	fi



	# Verifica se o sensor éISS3
	if [ "${IDSENSOR}" = "LS" ] 
	then

		SENSOR="LIS3"
		NOMESENSOR="LISS3"

		echo ""
		echo "SATELITE = ${SATELITE}"
		echo "SENSOR   = ${SENSOR} (${NOMESENSOR})"
		echo ""

		echo "PROCESSANDO  ${ARQUIVOTGZATUAL} ..."
		echo ""

		DIGITOVERIFICADOR="`echo ${NOMEARQUIVOTGZ} | cut -c 15-15`"
		
		# Realiza verificaç em relaç ao ano informado no nome do arquivo
		if [ "${DIGITOVERIFICADOR}" = "G"  -o "${DIGITOVERIFICADOR}" = "g" ] 
		then

			echo "ARQUIVO ${NOMEARQUIVOTGZ} COM NOMEACAO INCORRETA"
			echo "NECESSARIO EXISTENCIA DO ANO NA COMPOSICAO DO NOME DO ARQUIVO."
			echo ""
			exit
		fi

		
		ANO="`echo ${NOMEARQUIVOTGZ} | cut -c 12-15`"
		NOMEMES="`echo ${NOMEARQUIVOTGZ} | cut -c 9-11`"
		DIA="`echo ${NOMEARQUIVOTGZ} | cut -c 7-8`"
		ORBITA="`echo ${NOMEARQUIVOTGZ} | cut -c 16-18`"
		
		MES=`RETORNA_MES ${NOMEMES}`
		
		ANOMES="${ANO}_${MES}"	
		PERIODO="${SATELITE}_${NOMESENSOR}_${ANO}${MES}${DIA}"
		
		DIRPERIODO="${DESTINO}${ANOMES}/${PERIODO}"
		
		mkdir -p ${DIRPERIODO}
		cd ${DIRPERIODO}
		
		tar -xzvf ${ARQUIVOTGZ}
		
		${LISS3ORGANIZA} ${PERIODO} ${SATELITE} ${NOMESENSOR} ${ANO} ${MES} ${DIA} ${ORBITA}
		${LISS3GERAQL} ${PERIODO} ${SATELITE} ${SENSOR} ${ANO} ${MES} ${DIA} ${ORBITA}
		${LISS3GERADADOSDB} ${PERIODO} ${SATELITE} ${SENSOR} ${ANO} ${MES} ${DIA} ${ORBITA}
		${LISS3ENVIAEMAIL} ${PERIODO} ${SATELITE} ${SENSOR} ${ANO} ${MES} ${DIA} ${ORBITA}
		
		echo ""

	fi


	

	# Verifica se o sensor éWIFS
	if [ "${IDSENSOR}" = "AW" ] 
	then
		SENSOR="AWIF"
		NOMESENSOR="AWIFS"

		echo ""
		echo "SATELITE = ${SATELITE}"
		echo "SENSOR   = ${SENSOR} (${NOMESENSOR})"
		echo ""
		
		echo "PROCESSANDO  ${ARQUIVOTGZATUAL} ..."
		echo ""
		
		DIGITOVERIFICADOR="`echo ${NOMEARQUIVOTGZ} | cut -c 17-17`"
		
		# Realiza verificaç em relaç ao ano informado no nome do arquivo
		if [ "${DIGITOVERIFICADOR}" = "G"  -o "${DIGITOVERIFICADOR}" = "g" ] 
		then

			echo "ARQUIVO ${NOMEARQUIVOTGZ} COM NOMEACAO INCORRETA"
			echo "NECESSARIO EXISTENCIA DO ANO NA COMPOSICAO DO NOME DO ARQUIVO."
			echo ""
			exit
		fi
		
		
		ANO="`echo ${NOMEARQUIVOTGZ} | cut -c 14-17`"
		NOMEMES="`echo ${NOMEARQUIVOTGZ} | cut -c 11-13`"
		DIA="`echo ${NOMEARQUIVOTGZ} | cut -c 9-10`"
		ORBITA="`echo ${NOMEARQUIVOTGZ} | cut -c 18-20`"
		
		MES=`RETORNA_MES ${NOMEMES}`
		
		ANOMES="${ANO}_${MES}"	
		PERIODO="${SATELITE}_${NOMESENSOR}_${ANO}${MES}${DIA}"
		
		DIRPERIODO="${DESTINO}${ANOMES}/${PERIODO}"
		mkdir -p ${DIRPERIODO}
		cd ${DIRPERIODO}
		
		tar -xzvf ${ARQUIVOTGZ} 
		
		${AWIFSORGANIZA} ${PERIODO} ${SATELITE} ${NOMESENSOR} ${ANO} ${MES} ${DIA} ${ORBITA}
		${AWIFSGERAQL} ${PERIODO} ${SATELITE} ${SENSOR} ${ANO} ${MES} ${DIA} ${ORBITA}
		${AWIFSGERADADOSDB} ${PERIODO} ${SATELITE} ${SENSOR} ${ANO} ${MES} ${DIA} ${ORBITA}		
		${AWIFSENVIAEMAIL} ${PERIODO} ${SATELITE} ${SENSOR} ${ANO} ${MES} ${DIA} ${ORBITA}
		
		echo ""

	fi

done


