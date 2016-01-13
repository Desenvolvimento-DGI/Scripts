#!/bin/bash 
#Script para backup em fitas dos dados DGI
#Backup dos dados do /intranet e /dados/mysql_bkp

LOGBACKUP="/home/cdsr/bin/.date.txt"

echo "BACKUP DIARIO" > "${LOGBACKUP}"
echo "INICIO  : `date`" >> "${LOGBACKUP}"

mail -s "INICIO DO BACKUP EM FITAS" reuel@dgi.inpe.br, jose.renato@dgi.inpe.br, cdsr@dgi.inpe.br, operadores-dgi@dgi.inpe.br, analuisa.marucco@dgi.inpe.br < /home/cdsr/bin/.date.txt


echo " INICIO DO BACKUP EM FITAS "
tar -zcvf /dev/nst0 /dados/rsync_bkp/diario/envisat/
echo " FIM  DO BACKUP EM FITAS "
echo " AGUARDE... "

echo " VOCE PODE RETIRAR A FITA DA UNIDADE "

echo "TERMINO : `date`" >> "${LOGBACKUP}"
mail -s "FIM DO BACKUP EM FITAS" reuel@dgi.inpe.br, jose.renato@dgi.inpe.br, cdsr@dgi.inpe.br, operadores-dgi@dgi.inpe.br, analuisa.marucco@dgi.inpe.br  < /home/cdsr/bin/.date.txt

