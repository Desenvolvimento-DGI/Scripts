# Backup dos seguintes bancos de dados 
#
#   intranetdev
#   passagens
#   queimadas
#   gerenciador
#

CMDDUMP="/usr/bin/mysqldump "
AREABACKUP="/dados/mysql_bkp"

USUARIO="dgi"
SENHA="dgi.2013"
HOST="sac.dgi.inpe.br"


# Cria os diretorios para os arquivos de backup
mkdir ${AREABACKUP}/intranetdev
mkdir ${AREABACKUP}/passagens
mkdir ${AREABACKUP}/queimadas
mkdir ${AREABACKUP}/gerenciador


# Backup do banco intranetdev
${CMDDUMP} -u ${USUARIO} -p${SENHA} -h ${HOST} --verbose intranetdev --lock-tables=false > ${AREABACKUP}/intranetdev/intranetdev.sql


# Backup do banco passagens
${CMDDUMP} -u ${USUARIO} -p${SENHA} -h ${HOST} --verbose passagens --lock-tables=false > ${AREABACKUP}/passagens/passagens.sql

# Backup do banco queimadas
${CMDDUMP} -u ${USUARIO} -p${SENHA} -h ${HOST} --verbose queimadas --lock-tables=false > ${AREABACKUP}/queimadas/queimadas.sql

# Backup do banco gerenciador
${CMDDUMP} -u ${USUARIO} -p${SENHA} -h ${HOST} --verbose gerenciador --lock-tables=false > ${AREABACKUP}/gerenciador/gerenciador.sql 
 

