#!/bin/bash
# Script para organizar dados TERRA/MODIS processados
# 08/03/2013
# Versao 1.0

cd  /raid/pub/gsfcdata/npp/viirs/level2

echo "Inicio do Processamento.:..."

for lista in $(ls *npp.*)
 do
  arq_saida=$(echo ${lista} | cut -f2 -d '.')

 #acertar DATA
  yyyy=$(echo ${arq_saida} | cut -c 1-2)
  ddd=$(echo ${arq_saida} | cut -c 3-5)
  hh=$(echo ${arq_saida} | cut -c 6-7)
  mm=$(echo ${arq_saida} | cut -c 8-9)
  ss=$(echo ${arq_saida} | cut -c 10-11)

 # converte para dia Gregoriano
 ano=$(date -d "20${yyyy}-01-01 + ${ddd} days -1 day" +%Y)
 mes=$(date -d "20${yyyy}-01-01 + ${ddd} days -1 day" +%m)
 dia=$(date -d "20${yyyy}-01-01 + ${ddd} days -1 day" +%d)

 echo " ${ano}_${mes}_${dia}.${hh}_${mm}_${ss}"
 #mkdir -p teste/npp.${ano}_${mes}_${dia}.${hh}_${mm}_${ss}
 3cp *
# mv *.${arq_saida}.*  ${ano}_${mes}/TERRA.${ano}_${mes}_${dia}.${hh}_${mm}_${ss}
 done

cd -
echo "Fim do Processamento.:..."
exit 0

