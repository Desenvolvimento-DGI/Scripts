#!/bin/bash
 
# Parametro referente ao ano
PARANO="${1}"
ARQUIVOSAIDA="${2}"

TAMANHOANO="${#PARANO}"

if [ ${TAMANHOANO} -ne 4  -o "${PARANO}" = "*" ]
then
	# Ano nao informado ou incorreto
	PARANO='*'
	FILTROPERIODO='*'
	CAMPOANO='TODOS'
else
	# Ano informado
	FILTROPERIODO="${PARANO}*"
	CAMPOANO="${PARANO}"
fi
	
 	
	
DIRATUAL="`pwd`"
FONTEDADOS='L0 - ACESSO DIRETO'



# Por padrao foi adotado o fator como 2
# Caso o ano informado seja maior ou igual 2004 o fator sera 2
# Assim, a cada novo ano nao sera necessario modificar o codigo
FATORDISTRIBUICAO=2

# Caso o ano informado seja menor ou igual 2003 o fator sera 1
if [ ${PARANO} -le 2003 ]
then
	FATORDISTRIBUICAO=1
fi


# Dados referente ao saté
SATELITE="GOES12"
NOMESATELITE="GOES-12"

FILTROEXTENSAO=""
ORIGEM="/Level-0/GOES12"

cd ${ORIGEM}


case ${PARANO} in
	2009)					
		# Todos as areas de 2009 estao vazias
		#
		TOTALCENAS=0
		TOTALGERAL=0
		;;			

	2010)					
		# Apenas os meses 02 e 12 possuem dados
		#
		FILTROSATELITE="S*"
		TOTALCENAS="`find ${ORIGEM}/${FILTROPERIODO}/GVAR  -name "${FILTROSATELITE}"  -print | wc -l`"
		TOTALGERAL=$(( ${TOTALCENAS} * ${FATORDISTRIBUICAO} ))
		;;			


	2011)
		# Os meses 01, 02, 03 e 04 possuem os arquivos na raiz do diretorio GVAR, nao possuindo
		# organizacao por subdiretorios
		#
		FILTROSATELITE="S*"
		TOTALCENAS1="`find ${ORIGEM}/2011_0{1,2,3,4}/GVAR  -name "${FILTROSATELITE}"  -print | wc -l`"
								
		# Os meses 06 e 07 nao existem
		# O mes 05 esta vazio		
		# O mes 08 esta vazio, possuindo somente a estrutura de diretorios		
				
		# Os meses 09 e 10 possuem a area GVAR com apenas o diretorio LINUX
		FILTROSATELITE="S*"
		TOTALCENAS2="`find ${ORIGEM}/2011_{09,10}/GVAR/LINUX  -name "${FILTROSATELITE}"  -print | wc -l`"				
				
		# O mes 11 possui a area GVAR com todos os subdiretorios, mas possui dados apenas no subdiretorio LINUX
		# Possui o diretorio TDF, mas esta vazio
		FILTROSATELITE="S*"
		TOTALCENAS3="`find ${ORIGEM}/2011_11/GVAR/LINUX  -name "${FILTROSATELITE}"  -print | wc -l`"
				
		# O mes 12 possui a area GVAR com os subdiretorios LINUX e UNIX
		# Os arquivos no subdiretorio LINUX estãnormais, mas o arquivos no subdiretorio UNIX estãzerados
		# Possui o diretorio TDF, mas os arquivos estãcom tamanho zerado
		FILTROSATELITE="S*"
		TOTALCENAS4="`find ${ORIGEM}/2011_12/GVAR/LINUX  -name "${FILTROSATELITE}"  -print | wc -l`"				

				
		# Totalizacao dos arquivos
		# 
		TOTALCENAS=$(( ${TOTALCENAS1} + ${TOTALCENAS2} + ${TOTALCENAS3} + ${TOTALCENAS4} ))
		TOTALGERAL=$(( ${TOTALCENAS} * ${FATORDISTRIBUICAO} ))		
		;;			


	2012)
		# Devido a despadronizacao das area referente ao ano de 2012, sera realizada uma contagem
		# para cada mes de 2012 separadamente
		#

		# Mes 01
		#
		FILTROSATELITE="S*"
		TOTALCENAS1="`find ${ORIGEM}/2012_01/GVAR/LINUX  -name "${FILTROSATELITE}"  -print | wc -l`"
		

		# Mes 02
		#
		FILTROSATELITE="S*"
		TOTALCENAS2="`find ${ORIGEM}/2012_02/GVAR/LINUX  -name "${FILTROSATELITE}"  -print | wc -l`"

		# Mes 03
		#
		FILTROSATELITE="S*"
		TOTALCENAS3="`find ${ORIGEM}/2012_03/GVAR/LINUX  -name "${FILTROSATELITE}"  -print | wc -l`"

		# Mes 04
		# Deverao ser contabilizados os subdiretorios LINUX e UNIX da area GVAR devido as dados serem diferentes
		#
		FILTROSATELITE="S*"
		TOTALCENAS4="`find ${ORIGEM}/2012_04/GVAR/{LINUX,UNIX}  -name "${FILTROSATELITE}"  -print | wc -l`"


		# Mes 05
		# Deverao ser contabilizados os subdiretorios LINUX e UNIX da area GVAR devido as dados serem diferentes
		#
		FILTROSATELITE="S*"
		TOTALCENAS5="`find ${ORIGEM}/2012_05/GVAR/{LINUX,UNIX}  -name "${FILTROSATELITE}"  -print | wc -l`"


		# Mes 06
		# Deverao ser contabilizados os subdiretorios LINUX e UNIX da area GVAR devido as dados serem diferentes
		#
		FILTROSATELITE="S*"
		TOTALCENAS6="`find ${ORIGEM}/2012_06/GVAR/{LINUX,UNIX}  -name "${FILTROSATELITE}"  -print | wc -l`"


		# Mes 07
		# Deverao ser contabilizados os subdiretorios LINUX e UNIX da area GVAR devido as dados serem diferentes
		#
		FILTROSATELITE="S*"
		TOTALCENAS7="`find ${ORIGEM}/2012_07/GVAR/{LINUX,UNIX}  -name "${FILTROSATELITE}"  -print | wc -l`"


		# Mes 08
		# Deverao ser contabilizados os subdiretorios LINUX e UNIX da area GVAR devido as dados serem diferentes
		#
		FILTROSATELITE="S*"
		TOTALCENAS8="`find ${ORIGEM}/2012_08/GVAR/{LINUX,UNIX}  -name "${FILTROSATELITE}"  -print | wc -l`"


		# Mes 09
		# Deverao ser contabilizados os subdiretorios LINUX e UNIX da area GVAR devido as dados serem diferentes
		#
		FILTROSATELITE="S*"
		TOTALCENAS9="`find ${ORIGEM}/2012_09/GVAR/{LINUX,UNIX}  -name "${FILTROSATELITE}"  -print | wc -l`"


		# Mes 10
		# Deverao ser contabilizados os subdiretorios LINUX e UNIX da area GVAR devido as dados serem diferentes
		#
		FILTROSATELITE="S*"
		TOTALCENAS10="`find ${ORIGEM}/2012_10/GVAR/{LINUX,UNIX}  -name "${FILTROSATELITE}"  -print | wc -l`"
		

		# Mes 11
		# Deverao ser contabilizados os subdiretorios LINUX, UNIX e WINDOWS da area GVAR devido as dados serem diferentes
		#
		FILTROSATELITE="S*"
		TOTALCENAS11="`find ${ORIGEM}/2012_11/GVAR/{LINUX,UNIX,WINDOWS}  -name "${FILTROSATELITE}"  -print | wc -l`"

		# Mes 12
		# Devera ser contabilizado apenas o subdiretorios WINDOWS da area GVAR devido as dados nos subdiretorios LINUX e 
		# UNIX jáxistirem no WINDOWS
		#
		FILTROSATELITE="S*"
		TOTALCENAS12="`find ${ORIGEM}/2012_12/GVAR/WINDOWS  -name "${FILTROSATELITE}"  -print | wc -l`"

				
		# Totalizacao dos arquivos
		# 
		TOTALCENAS=$(( ${TOTALCENAS1} + ${TOTALCENAS2}  + ${TOTALCENAS3}  + ${TOTALCENAS4}  + ${TOTALCENAS5}  + ${TOTALCENAS6}  + ${TOTALCENAS7}  ))
		TOTALCENAS=$(( ${TOTALCENAS}  + ${TOTALCENAS8}  + ${TOTALCENAS9}  + ${TOTALCENAS10} + ${TOTALCENAS11} + ${TOTALCENAS12} ))
		
		TOTALGERAL=$(( ${TOTALCENAS} * ${FATORDISTRIBUICAO} ))		
		;;			


	2013)
		# Todos os meses de 2013 possuem dados apenas no subdiretorio WINDOWS da area GVAR
		# A area TDF nãpossui arquivos
		#
		FILTROSATELITE="S*"
		TOTALCENAS="`find ${ORIGEM}/2013_*/GVAR/WINDOWS  -name "${FILTROSATELITE}"  -print | wc -l`"
		TOTALGERAL=$(( ${TOTALCENAS} * ${FATORDISTRIBUICAO} ))
		;;
		

	*)
		# Para os anos restantes, que nãexistem, apresenta os valores zerados
		TOTALCENAS=0
		TOTALGERAL=0
esac		
		
echo "${NOMESATELITE} : ${TOTALCENAS}  -  ${FATORDISTRIBUICAO}  -  ${TOTALGERAL}"	
echo "${CAMPOANO};${FONTEDADOS};${NOMESATELITE};${TOTALCENAS};${FATORDISTRIBUICAO};${TOTALGERAL}"  >>  ${ARQUIVOSAIDA}
	

cd ${DIRATUAL}


