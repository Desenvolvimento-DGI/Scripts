#!/bin/bash 
#Script para backup em fitas dos dados DGI
#Backup dos dados do /intranet e /dados/mysql_bkp

date > /home/cdsr/bin/.date.txt

mail -s "INICIO DO BACKUP EM FITAS" reuel@dgi.inpe.br, cdsr@dgi.inpe.br, operadores-dgi@dgi.inpe.br, analuisa.marucco@dgi.inpe.br < /home/cdsr/bin/.date.txt
rm -rf /home/cdsr/bin/.date.txt

echo " INICIO DO BACKUP EM FITAS "

tar -zcvf /dev/nst0 /intranet
tar -zcvf /dev/nst0 /dados/mysql_bkp

echo " FIM  DO BACKUP EM FITAS "
echo " AGUARDE... "

#mt -f /dev/nst0 rewoff

echo " VOCE PODE RETIRAR A FITA DA UNIDADE "
date > /home/cdsr/bin/.date.txt

mail -s "FIM DO BACKUP EM FITAS" reuel@dgi.inpe.br, cdsr@dgi.inpe.br, operadores-dgi@dgi.inpe.br  < /home/cdsr/bin/.date.txt
#rm -rf /home/cdsr/bin/.date.txt

