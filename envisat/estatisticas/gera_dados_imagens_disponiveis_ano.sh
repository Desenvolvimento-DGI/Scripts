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
NUMPID=$$
ARQUIVOSAIDA="${AREASCRIPTS}csv/imagens_disponiveis_${NUMPID}.csv"
ARQUIVOTEMP="${AREASCRIPTS}csv/imagens_disponiveis_${NUMPID}.tmp"

touch ${ARQUIVOTEMP}
echo "ANO;FONTE DOS DADOS;SATELITE;TOTAL CENAS UNICAS" > ${ARQUIVOTEMP}

 
if [ "${PARANOINICIAL}" == "*" ]
then

	${CMDPHP} ${AREASCRIPTS}catalogo_disponiveis_por_ano.php ${PARANOINICIAL} ${ARQUIVOTEMP}
	${AREASCRIPTS}l0_disponiveis_por_ano.sh ${PARANOINICIAL} ${ARQUIVOTEMP}

else

	for PARANO in `seq ${PARANOINICIAL} ${PARANOFINAL}`
	do
		${CMDPHP} ${AREASCRIPTS}catalogo_disponiveis_por_ano.php ${PARANO} ${ARQUIVOTEMP}
		${AREASCRIPTS}l0_disponiveis_por_ano.sh ${PARANO} ${ARQUIVOTEMP}

	done
	
fi



clear

echo "IMAGENS DISPONIVEIS POR ANO"
echo ""
echo ""

cat ${ARQUIVOTEMP} | grep -v ';0;'  > ${ARQUIVOSAIDA}
cat ${ARQUIVOSAIDA}

echo ""
echo ""
