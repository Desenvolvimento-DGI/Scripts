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
DIRGRUPO="entregues_ano/"
NUMPID=$$
ARQUIVOSAIDA="${AREASCRIPTS}csv/imagens_entregues_${NUMPID}.csv"
ARQUIVOTEMP="${AREASCRIPTS}csv/imagens_entregues_${NUMPID}.tmp"

touch ${ARQUIVOSAIDA}
echo "ANO;FONTE DOS DADOS;SATELITE;TOTAL CENAS UNICAS;FATOR DISTRIBUICAO;TOTAL GERAL" > ${ARQUIVOTEMP}

  
if [ "${PARANOINICIAL}" == "*" ]
then

	${CMDPHP} ${AREASCRIPTS}${DIRGRUPO}catalogo_entregues_por_ano.php ${PARANOINICIAL} ${ARQUIVOTEMP}
	${AREASCRIPTS}${DIRGRUPO}l0_entregues_por_ano.sh ${PARANOINICIAL} ${ARQUIVOTEMP}

else

	for PARANO in `seq ${PARANOINICIAL} ${PARANOFINAL}`
	do
		${CMDPHP} ${AREASCRIPTS}${DIRGRUPO}catalogo_entregues_por_ano.php ${PARANO} ${ARQUIVOTEMP}
		${AREASCRIPTS}${DIRGRUPO}l0_entregues_por_ano.sh ${PARANO} ${ARQUIVOTEMP}

	done
	
fi




echo ""
echo ""

cat ${ARQUIVOTEMP} | grep -v ';0;'  > ${ARQUIVOSAIDA}
cat ${ARQUIVOSAIDA} 

echo ""
echo ""

