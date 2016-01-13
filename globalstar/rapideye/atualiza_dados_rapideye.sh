#!/bin/bash

HOMESCRIPT='/home/cdsr/rapideye/'
NUMPID="$$"

CMDMYSQL='/usr/bin/mysql --login-path=catalogo-gerente '
ARQUIVOSQL="${HOMESCRIPT}/UPDATERAPIDEYE${NUMPID}.sql"

HOMEL4='/L4_RAPIDEYE/'
LISTASATELITES='RE1 RE2 RE3 RE4 RE5'
SENSOR='REIS'

# Satelites
for SATELITE in ${LISTASATELITES}
do

	PATHSATELITE="${HOMEL4}${SATELITE}"
	cd ${PATHSATELITE}
	
	# Ano e mes
	LISTAANOMES="`ls -1 | grep -i _`"
	for ANOMES in ${LISTAANOMES}
	do
	
		PATHANOMES="${PATHSATELITE}/${ANOMES}"
		cd ${PATHANOMES}
				
				
		echo "" > ${ARQUIVOSQL}	
		
		# Cenas
		LISTACENAS="`ls -1 | grep -i REIS`"
		for CENA in ${LISTACENAS}
		do
		
			PATHCENA="${PATHANOMES}/${CENA}"
			cd ${PATHCENA}
			
			ARQUIVOXML="`ls -1 *_metadata.xml`"
			
			TILEID="`echo ${ARQUIVOXML} | cut -f 1 -d _`"
			ANO="`echo ${ARQUIVOXML} | cut -c 9-12`"
			MES="`echo ${ARQUIVOXML} | cut -c 14-15`"
			DIA="`echo ${ARQUIVOXML} | cut -c 17-18`"
			VALORT="`echo ${ARQUIVOXML} | cut -c 20-25`"
			VALORR="`echo ${ARQUIVOXML} | cut -c 38-45`"
			
			SCENEID="${SATELITE}${SENSOR}${ANO}${MES}${DIA}T${VALORT}R${VALORR}"			
			
			echo "SATELITE : ${SATELITE} - ${ANOMES} - ${CENA}  ::  SCENID = ${SCENEID}     TILE-ID = ${TILEID} "
			
			SQLTABELA=" catalogo.Scene "								
			SQLSET=" SET TileId = ${TILEID} "					
			SQLWHERE=" WHERE SceneId = '${SCENEID}' "					
			SQLUPDATE="UPDATE ${SQLTABELA} ${SQLSET} ${SQLWHERE} ;"
						
			echo "${SQLUPDATE}" >> ${ARQUIVOSQL}										
					
		done
		# Cenas
		echo ""
		echo ""
		echo "Executando atualizacao dos tile id..."
		${CMDMYSQL} < ${ARQUIVOSQL}
		echo ""
		echo ""
		sleep 1
		
	
	done
	# Ano e mes
	clear

done
# Satelites

