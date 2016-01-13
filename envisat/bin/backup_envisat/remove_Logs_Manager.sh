#!/bin/bash -x

# Este script remove os logs do Manager de dois dias atrás #
# Autor: José Neto #
# Data: 12/2013 #
# Versao: 1.0 #

# Diretorio de execucao #
d_exe=/home/cdsr/bin
# Diretorio dos Logs #
dir_logs=/intranet/producao/manager/logs/stDebug

cd $dir_logs
find . -mtime +4 -exec echo {} \; > $d_exe"/lista_logs"

cd $d_exe

# Lendo o arquivo com os logs a serem apagados #
while read logs
do

	log=`echo $logs | cut -d "/" -f2`
	
	# Removendo da area de Logs #
	cd $dir_logs
	rm -rf $log
	cd $d_exe

done < $d_exe"/lista_logs"


# Removendo os arquivos KMZ #

# Diretorio do KMZ #
d_kmz=/intranet/producao/manager

# lista dos arquivos KMZ #
cd $d_kmz
find . -name "*.kmz" -mtime +4 -exec echo {} \; > $d_exe"/lista_kmz"

cd $d_exe

# Lendo os arquivos KMZ #
while read kmz
do

	arq_kmz=`echo $kmz | cut -d "/" -f2`
	echo $arq_kmz
	
	# Removendo o arquivo KMZ #
	cd $d_kmz
	rm -rf $arq_kmz
	cd $d_exe

done < $d_exe"/lista_kmz"


# removendo os arquivos TXT #
cd $d_exe
rm -rf lista_logs lista_kmz

exit
