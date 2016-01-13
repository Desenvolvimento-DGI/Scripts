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




# Dados referente ao satéte
SATELITE="GOES13"
NOMESATELITE="GOES-13"

FILTROEXTENSAO=""
ORIGEM="/L0_GOES13"



	# Dados referente ao satéte
	SATELITE="GOES13"
	NOMESATELITE="GOES-13"
	FILTROEXTENSAO=""
	ORIGEM="/L0_GOES13"


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
		
		TOTALCENAS1=0
		TOTALCENAS2=0
		TOTALCENAS3=0
		TOTALCENAS4=0
					

		FILTROSATELITE="S*"
		TOTALCENAS1="`find ${ORIGEM}/${MESANOATUAL}/GVAR/LINUX  -name "${FILTROSATELITE}"  -print | wc -l`"

		FILTROSATELITE="S*"
		TOTALCENAS2="`find ${ORIGEM}/${MESANOATUAL}/TDF  -name "${FILTROSATELITE}"  -print | wc -l`"

		FILTROSATELITE="GOES*"
		TOTALCENAS3="`find ${ORIGEM}/${MESANOATUAL}/CP*  -name "${FILTROSATELITE}"  -print | wc -l`"

		FILTROSATELITE="GOES*"
		TOTALCENAS4="`find ${ORIGEM}/${MESANOATUAL}/CP*  -name "${FILTROSATELITE}"  -print | wc -l`"

		TOTALCENAS=$(( ${TOTALCENAS1} + ${TOTALCENAS2} + ${TOTALCENAS3} + ${TOTALCENAS4} ))
		TOTALGERAL=$(( ${TOTALCENAS} * ${FATORDISTRIBUICAO} ))
				
		echo "${ANOATUAl}/${MESATUAl} - ${NOMESATELITE} : ${TOTALCENAS}  -  ${FATORDISTRIBUICAO}  -  ${TOTALGERAL}"	
		echo "${ANOATUAl};${MESATUAl};${FONTEDADOS};${NOMESATELITE};${TOTALCENAS};${FATORDISTRIBUICAO};${TOTALGERAL}"  >>  ${ARQUIVOSAIDA}			
		
	done

	

cd ${DIRATUAL}

