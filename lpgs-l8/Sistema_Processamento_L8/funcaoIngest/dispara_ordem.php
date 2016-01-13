#!/usr/local/bin/php

<?php
$nome_ordem = "/dados/htdocs/Sistema_Processamento_L8/ordem_servico/ordem_LO82170620762015092CUB00_2015_04";
$caracter_chave = "c92ac580da75652a954f0341";
$comando = "./recebe_novas_ordens_INGEST.sh ".$nome_ordem." ".$caracter_chave;
shell_exec($comando." > /dev/null &");

?>


