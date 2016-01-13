<?php
/*
	Classe com as funções PHP respnsáveis por todas as operações do sistema
	Autor: Jose Neto
	Data: 01/2015
*/

class ConexaoBD
{
	//------------------------------------------------------------------------------------//
	// Funcao privada que faz a conexao com o banco de dados //
	public function conexaoBD()
	{
		$_USER = "dgi";
		$_HOST = "150.163.134.104:3333";
		$_PWD = "dgi.2013";
		$conec = mysql_connect($_HOST, $_USER, $_PWD) or die("NÃO CONECTADO COM O BANCO!");
		mysql_query("SET NAMES 'utf8'");
        mysql_query('SET character_set_connection=utf8');
        mysql_query('SET character_set_client=utf8');
        mysql_query('SET character_set_results=utf8');
		mysql_select_db("processoL8", $conec);
	}
	//------------------------------------------------------------------------------------//
	// Funcao que fecha a conexao com o banco de dados //
	public function fechaConexaoBD()
	{
		$_USER = "dgi";
		$_HOST = "150.163.134.104:3333";
		$_PWD = "dgi.2013";
		$desconec = mysql_connect($_HOST, $_USER, $_PWD) or die("NÃO CONECTADO COM O BANCO!");
		mysql_close($desconec);
	}
	//------------------------------------------------------------------------------------//
}
?>