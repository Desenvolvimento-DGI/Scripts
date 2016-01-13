<?php

$_USER = "dgi";
$_HOST = "sac.dgi.inpe.br:3333";
$_PWD = "dgi.2013";


//ini_set('display_errors',1);
//ini_set('display_startup_erros',1);
error_reporting(E_ALL);
//$link = mysqli_connect($_HOST,$_USER,$_PWD,"queimadas") or die("Error " . mysqli_error($link)); 
$conec = mysql_connect($_HOST, $_USER, $_PWD) or die("NÃO CONECTADO COM O BANCO!");
$db = mysql_select_db("sistema_L8",$conec) or die ("Não foi possivel selecionar o Banco de Dados");
echo "con - SAC<br />";
/*
$_USER = "dgi";
$_HOST = "sac.dgi.inpe.br:3333";
$_PWD = "dgi.2013";
$conec = mysql_connect($_HOST, $_USER, $_PWD) or die("NÃO CONECTADO COM O BANCO!");
		mysql_query("SET NAMES 'utf8'");
        mysql_query('SET character_set_connection=utf8');
        mysql_query('SET character_set_client=utf8');
        mysql_query('SET character_set_results=utf8');
		mysql_select_db("intranetdev", $conec);
*/
//$out=mysql_query("Show Tables;");
//echo $out[0];
?>