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

# Dados referente ao satéte
SATELITE="METOPB"
NOMESATELITE="METOP-B"

FILTROSATELITE='METOP-B*'
FILTROEXTENSAO=""
ORIGEM="/Level-0/METOPB"
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





cd ${ORIGEM}

TOTALCENAS="`find ${ORIGEM}/${FILTROPERIODO}  -name "${FILTROSATELITE}"  -print | wc -l`"
TOTALGERAL=$(( ${TOTALCENAS} * ${FATORDISTRIBUICAO} ))
echo "${NOMESATELITE} : ${TOTALCENAS}  -  ${FATORDISTRIBUICAO}  -  ${TOTALGERAL}"

echo "${CAMPOANO};${FONTEDADOS};${NOMESATELITE};${TOTALCENAS};${FATORDISTRIBUICAO};${TOTALGERAL}"  >>  ${ARQUIVOSAIDA}

cd ${DIRATUAL}

