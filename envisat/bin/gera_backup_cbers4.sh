#!/bin/bash
 
BINHOME='/home/cdsr/bin'
CONFIGFILE="${BINHOME}/.contribdb/secretkey.txt"

GZIP='/bin/gzip '
MYSQLDUMP='/usr/bin/mysqldump '
 
USER="`cat ${CONFIGFILE} | grep -i 'USER_ROOT' | cut -f 2 -d '='`"
PASSWORD="`cat ${CONFIGFILE} | grep -i 'PASSWORD_ROOT' | cut -f 2 -d '='`"
PORTDB="`cat ${CONFIGFILE} | grep -i 'PORT_DB' | cut -f 2 -d '='`"
OUTPUTDIR="`cat ${CONFIGFILE} | grep -i 'OUTPUT_DIR' | cut -f 2 -d '='`"
 
#BANCOSDEDADOS=`mysql --user=${USER}  --password=${PASSWORD} -e 'SHOW DATABASES' | grep -iv Database'`
BANCOSDEDADOS='catalogo_cbers catalogo_CBERS mster mster_cbers grdb_cbers pacdb_cbers'

 
for DBATUAL in ${BANCOSDEDADOS}
do
	echo "Banco de dados: ${DBATUAL}"
	cd  ${OUTPUTDIR}
	rm -fr ${DBATUAL}
	
	mkdir -p ${OUTPUTDIR}/${DBATUAL}
	
	# Backup de todas as tabelas do banco de dados atual	
	TABELAS=`mysql --user=${USER}  --password=${PASSWORD} -e "USE ${DBATUAL} ; SHOW TABLES" | grep -iv 'Tables_in'`
	for TABELAATUAL in ${TABELAS}
	do
		echo "Banco de dados: ${DBATUAL}   Tabela: ${TABELAATUAL}"
		
		ARQUIVOSQLATUAL="${OUTPUTDIR}/${DBATUAL}/${TABELAATUAL}.sql"
		${MYSQLDUMP} --force --opt --verbose --user=${USER} --password=${PASSWORD}  ${DBATUAL}  ${TABELAATUAL}  > ${ARQUIVOSQLATUAL}
		echo ""
		echo ""
		
		${GZIP} -v ${ARQUIVOSQLATUAL}
		echo ""
		echo ""
		
    done	
	echo ""
	echo ""
	
done
