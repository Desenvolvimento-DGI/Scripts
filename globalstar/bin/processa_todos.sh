#!/bin/bash

ARQUIVOLOG='/home/cdsr/bin/processa_todos.log'

# Registra o inicio da execucao
echo "" >> ${ARQUIVOLOG}
echo "`date -R`  ::  INICIO  Processamento dados satelite" >> ${ARQUIVOLOG}
echo "" >> ${ARQUIVOLOG}



# Processa imagens do satelite AQUA
echo "`date -R`  ::  AQUA    Inicio  processamento" >> ${ARQUIVOLOG}
cd /home/cdsr/aqua
/home/cdsr/aqua/processa_aqua.sh
echo "`date -R`  ::  AQUA    Termino processamento" >> ${ARQUIVOLOG}
echo "" >> ${ARQUIVOLOG}


# Processa imagens do satelite TERRA 
echo "`date -R`  ::  TERRA   Inicio  processamento" >> ${ARQUIVOLOG}
cd /home/cdsr/terra
/home/cdsr/terra/processa_terra.sh
echo "`date -R`  ::  TERRA   Termino processamento" >> ${ARQUIVOLOG}
echo "" >> ${ARQUIVOLOG}


# Processa imagens do satelite S-NPP 
echo "`date -R`  ::  SNPP    Inicio  processamento" >> ${ARQUIVOLOG}
cd /home/cdsr/npp
/home/cdsr/npp/processa_npp.sh
echo "`date -R`  ::  SNPP    Termino processamento" >> ${ARQUIVOLOG}
echo "" >> ${ARQUIVOLOG}



# Registra o termino da execucao
echo "`date -R`  ::  TERMINO Processamento dados satelite" >> ${ARQUIVOLOG}
echo "" >> ${ARQUIVOLOG}
echo "" >> ${ARQUIVOLOG}
