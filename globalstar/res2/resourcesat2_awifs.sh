#!/bin/bash
# Funcao pra retornar o numero do mes com base no nome do mes

RETORNA_MES_NUMERICO()
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

 
SATELITE="RES2"
NOMESATELITE="RESOURCESAT2 (RES2)"

SENSOR="AWIF"
NOMESENSOR="AWIFS"

FILTROSATSENSOR='^RS2AW'
FILTROEXTENSAO=".tgz"
FILTROPRODUTO="GODP"

ORIGEM="/cdsr/VPN/"
DESTINO="/L4_RESOURCESAT2/"

DIRATUAL="`pwd`"
AREASCRIPTS="/home/cdsr/res2/"

CMDCOPIA="/usr/bin/scp cdsr@bbftp.dgi.inpe.br:${ORIGEM}"

ARQUIVOLOCK="${AREASCRIPTS}adm/resourcesat2_awifs.lock" 

# Scripts para processar 
# -----------------------------------------------------------
RES2PROCESSA="${AREASCRIPTS}processa_resourcesat2.sh "

# Nome deste programa/script
NOMEPROGRAMA="`basename $0`"

echo ""
echo "${NOMEPROGRAMA}"
echo "SATELITE :: ${NOMESATELITE} (${SATELITE})"
echo "SENSOR   :: ${NOMESENSOR}"
echo ""
echo "Verificando arquivos na VPN..."


	
# Verifica se o script jásta em execuç atravédo uso de um arquivo de lock (trava)
if [ -e "${ARQUIVOLOCK}" ]
then
	echo ""
	echo "Processamento jáe encontra em execuç."
	exit 0
fi


# Cria  arquivo de lock 
touch ${ARQUIVOLOCK}


# Obtem lista dos arquivos existentes na áa VPN do servidor ftp
LISTAARQUIVOSTGS="`/usr/bin/ssh cdsr@bbftp.dgi.inpe.br ls -1 ${ORIGEM} | grep ${FILTROSATSENSOR} | grep -i ${FILTROEXTENSAO} | grep ${FILTROPRODUTO}`"

TOTALARQUIVOS=0
# Executa o processo para cada arquivo vádo encontrado
#

echo ""
echo "Copiando arquivos da VPN para o servidor local"
echo ""

for ARQUIVOTGZATUAL in ${LISTAARQUIVOSTGS}
do

	IDSATELITE="`echo ${ARQUIVOTGZATUAL} | cut -c 1-3`"
	IDSENSOR="`echo ${ARQUIVOTGZATUAL} | cut -c 4-5`"
			
	ANO="`echo ${ARQUIVOTGZATUAL} | cut -c 14-17`"
	NOMEMES="`echo ${ARQUIVOTGZATUAL} | cut -c 11-13`"
	DIA="`echo ${ARQUIVOTGZATUAL} | cut -c 9-10`"
	ORBITA="`echo ${ARQUIVOTGZATUAL} | cut -c 18-20`"
		
	MES=`RETORNA_MES_NUMERICO ${NOMEMES}`
		
	ANOMES="${ANO}_${MES}"	
	PERIODO="${SATELITE}_${NOMESENSOR}_${ANO}${MES}${DIA}"
	DIRDESTINO="${DESTINO}${ANOMES}"	
	DIRPERIODO="${DIRDESTINO}/${PERIODO}"
			
	# Nome do arquivo com o caminho completo
	ARQUIVOTGZ="${DIRDESTINO}/${ARQUIVOTGZATUAL}"

	# Tamanho do arquivo deve ser sempre o mesmo
	# Para o sensor AWIFS o arquivo deve ter sempre 28
	TAMARQUIVOTGZ="${#ARQUIVOTGZATUAL}"
		
	# Verifica se o arquivo tem o tamanho padrã(28 para AWIFS)
	if [ ${TAMARQUIVOTGZ} -ne 28 ]
	then
		# Vai para o próo arquivo
		continue
	fi
		
	
	
	# Verifica se o arquivo existe na áa de destino
	if [ -e "${ARQUIVOTGZ}" ]
	then
		# Vai para o próo arquivo, pois deve estar ocorrendo o processamento do arquivo atual
		continue
	fi
		
		
	# Verifica se a áa referente ao perío existe na áa de destino
	if [ -e "${DIRPERIODO}" ]
	then
			
		cd ${DIRPERIODO}
		NUMORBITAS="`ls -1 | grep -i ${ORBITA} | wc -l`"
			
			
		# Se existirem diretorios referentes àrbita na áa, o processamento jáoi feito
		if [ ${NUMORBITAS} -gt 0 ]
		then
			# Vai para o próo arquivo, pois o arquivo atual jáoi processado
			continue
		fi			
	
	fi
	
	
	${CMDCOPIA}${ARQUIVOTGZATUAL}  ${DIRDESTINO}
	TOTALARQUIVOS=$(($TOTALARQUIVOS+1))
	
	# Gera uma variavel contendo a lista dos arquivos a serem processados
	ARQUIVOSPROCESSAR="${ARQUIVOSPROCESSAR} ${ARQUIVOTGZ} "
done



echo ""
echo "Processar arquivos copiados"
echo ""

# Realizar o processamento dos arquivos copiados
#
if [ ${TOTALARQUIVOS} -gt 0 ]
then
	${RES2PROCESSA}  ${ARQUIVOSPROCESSAR}
else
	echo "Nenhum arquivo a ser processado"
	rm -fv ${ARQUIVOLOCK}
	exit 0
fi



echo ""
echo "Validar processamento e Remover arquivos copiados da VPN"
echo ""


# Validar o processamento e remover os arquivos pocessados
# Executa o processo para cada arquivo vádo encontrado
#
for ARQUIVOTGZATUAL in ${LISTAARQUIVOSTGS}
do

	IDSATELITE="`echo ${ARQUIVOTGZATUAL} | cut -c 1-3`"
	IDSENSOR="`echo ${ARQUIVOTGZATUAL} | cut -c 4-5`"
	
	ANO="`echo ${ARQUIVOTGZATUAL} | cut -c 14-17`"
	NOMEMES="`echo ${ARQUIVOTGZATUAL} | cut -c 11-13`"
	DIA="`echo ${ARQUIVOTGZATUAL} | cut -c 9-10`"
	ORBITA="`echo ${ARQUIVOTGZATUAL} | cut -c 18-20`"
		
	MES=`RETORNA_MES_NUMERICO ${NOMEMES}`
		
	ANOMES="${ANO}_${MES}"	
	PERIODO="${SATELITE}_${NOMESENSOR}_${ANO}${MES}${DIA}"
	DIRDESTINO="${DESTINO}${ANOMES}"	
	DIRPERIODO="${DIRDESTINO}/${PERIODO}"
				
	# Nome do arquivo com o caminho completo
	ARQUIVOTGZ="${DIRDESTINO}/${ARQUIVOTGZATUAL}"


	if [ -e "${DIRPERIODO}" ]
	then
	
		cd ${DIRPERIODO}
		NUMORBITAS="`ls -1 | grep -i ${ORBITA} | wc -l`"		
		
		# Se existirem diretorios referentes àrbita na áa, o processamento jáoi feito
		# e os arquivos compactados podem ser removidos
		if [ ${NUMORBITAS} -gt 0 ]
		then
			rm -fv ${ARQUIVOTGZ}
		fi
		
	fi
		
done



rm -fv ${ARQUIVOLOCK}

