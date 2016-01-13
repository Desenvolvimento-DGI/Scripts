#!/bin/bash

# Parametro referente ao ano
PARANO="${1}"
ARQUIVOSAIDA="${2}"

TAMANHOANO=${#PARANO}

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
SATELITE="A1"
NOMESATELITE="AQUA"

FILTROSATELITE='AQUA*'
FILTROEXTENSAO=""
ORIGEM="/L0_AQUA/"
FATORDISTRIBUICAO=2
FONTEDADOS='L0 - ACESSO DIRETO'


# Por padrao foi adotado o fator como 2
# Caso o ano informado seja maior ou igual 2009 o fator sera 2
# Assim, a cada novo ano nao sera necessario modificar o codigo
FATORDISTRIBUICAO=2

# Caso o ano informado seja menor ou igual 2008 o fator sera 1
if [ ${PARANO} -le 2008 ]
then
	FATORDISTRIBUICAO=1
fi

 	
	
cd ${ORIGEM}



if [ ${CAMPOANO} = "TODOS" ]
then
	cd ${ORIGEM}
	LISTAANOMES="`\ls -1 | grep _ | sort`"
else
	cd ${ORIGEM}
	LISTAANOMES="`\ls -1 | grep ${CAMPOANO} | sort`"
fi
	




for MESANOATUAL in ${LISTAANOMES}
do
	ANOATUAl="`echo ${MESANOATUAL} | cut -f 1 -d _`"
	MESATUAl="`echo ${MESANOATUAL} | cut -f 2 -d _`"

	TOTALCENAS="`find ${ORIGEM}/${MESANOATUAL}  -name "${FILTROSATELITE}"  -print | wc -l`"
	TOTALGERAL=$(( ${TOTALCENAS} * ${FATORDISTRIBUICAO} ))
	echo "${ANOATUAl}/${MESATUAl} - ${NOMESATELITE} : ${TOTALCENAS}  -  ${FATORDISTRIBUICAO}  -  ${TOTALGERAL}"
	echo "${ANOATUAl};${MESATUAl};${FONTEDADOS};${NOMESATELITE};${TOTALCENAS};${FATORDISTRIBUICAO};${TOTALGERAL}"  >>  ${ARQUIVOSAIDA}
done





cd ${DIRATUAL}

