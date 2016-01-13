#!/bin/bash -x


ano=$1

if [ $ano ]
then

	for i in `seq 1 12`;
	do
		if [ $i -lt 10 ]
		then
			mes=0$i
		else
			mes=$i
		fi
	
		ano_mes=$ano'_'$mes

		./arruma_arquivos_NOAA.sh $ano_mes
	done 
fi

exit
