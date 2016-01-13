#!/bin/bash

HOMESCRIPT='/home/cdsr/cadastro/'
CMDMYSQL='/usr/bin/mysql --login-path=catalogo-gerente '
ARQUIVOSQL="${HOMESCRIPT}atualiza_usuarios_internos.sql"

${CMDMYSQL} < ${ARQUIVOSQL}

