<?php
/*
	Classe com as funções PHP respnsáveis por conectar e desconectar
	Autor: Jose Neto
	Data: 03/2015
*/

// Define a TimeZone //
date_default_timezone_set('UTC');

class ConexaoBD
{
	//------------------------------------------------------------------------------------//
	// Funcao privada que faz a conexao com o banco de dados //
	public function conexaoBD()
	{
		$_USER = "dgi";
		$_HOST = "150.163.134.104:3333";
		$_PWD = "dgi.2013";
		$conec = @mysql_connect($_HOST, $_USER, $_PWD) or die("NÃO CONECTADO COM O BANCO!");
		mysql_query("SET NAMES 'utf8'");
        mysql_query('SET character_set_connection=utf8');
        mysql_query('SET character_set_client=utf8');
        mysql_query('SET character_set_results=utf8');
		mysql_select_db("sistema_L8", $conec);
		
	}
	//------------------------------------------------------------------------------------//
	// Funcao que fecha a conexao com o banco de dados //
	public function fechaConexaoBD()
	{
		$_USER = "dgi";
		$_HOST = "150.163.134.104:3333";
		$_PWD = "dgi.2013";
		$desconec = @mysql_connect($_HOST, $_USER, $_PWD) or die("NÃO CONECTADO COM O BANCO!");
		mysql_close($desconec);
	}
	//------------------------------------------------------------------------------------//
}
?>