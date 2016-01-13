#!/bin/bash

CMDPHP="/usr/bin/php "

# Verificar numero de parametros informados
NUMPARAMETROS=$#


case ${NUMPARAMETROS} in

	0)
	PARANOINICIAL="*"
	PARANOFINAL="*"	
	;;

	1)
	# Parametro referente aos anos inicial e final
	PARANOINICIAL="${1}"
	PARANOFINAL="${PARANOINICIAL}"	
	;;

	2)
	# Parametro referente aos anos inicial e final
	PARANOINICIAL="${1}"
	PARANOFINAL="${2}"		
	;;

	*)
	# Parametro referente aos anos inicial e final
	PARANOINICIAL="${1}"
	PARANOFINAL="${2}"
	;;

esac



DIRATUAL="`pwd`"
AREASCRIPTS="/home/cdsr/estatisticas/"
DIRGRUPO="disponiveis_ano/"
NUMPID=$$
ARQUIVOSAIDA="${AREASCRIPTS}csv/imagens_disponiveis_${NUMPID}.csv"

touch ${ARQUIVOSAIDA}
echo "ANO;FONTE DOS DADOS;SATELITE;TOTAL CENAS UNICAS" > ${ARQUIVOSAIDA}

 
if [ "${PARANOINICIAL}" == "*" ]
then

	${CMDPHP} ${AREASCRIPTS}${DIRGRUPO}catalogo_disponiveis_por_ano.php ${PARANOINICIAL} ${ARQUIVOSAIDA}
	${AREASCRIPTS}${DIRGRUPO}l0_disponiveis_por_ano.sh ${PARANOINICIAL} ${ARQUIVOSAIDA}

else

	for PARANO in `seq ${PARANOINICIAL} ${PARANOFINAL}`
	do
		${CMDPHP} ${AREASCRIPTS}${DIRGRUPO}catalogo_disponiveis_por_ano.php ${PARANO} ${ARQUIVOSAIDA}
		${AREASCRIPTS}${DIRGRUPO}l0_disponiveis_por_ano.sh ${PARANO} ${ARQUIVOSAIDA}

	done
	
fi




echo ""
echo ""

cat ${ARQUIVOSAIDA}
echo ""
