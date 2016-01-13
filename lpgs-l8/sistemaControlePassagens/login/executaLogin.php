<?php
/* ------------------------------------------------------------------------------
Metodo que realiza o login ou redireciona novamente para nova tentativa de login
Autor: Jose Neto
Data: 01/2015
-------------------------------------------------------------------------------- */
include("loginClass.php");
$_METODO = new LoginClass();

// Recebe os parametros via POST //
$_login = $_POST['usuario'];
$_senha = $_POST['senha'];

// Verifica se existe o usuario e a senha cadastrados no Banco de Dados //
$_status_login = $_METODO->verificaLoginSenha($_login, $_senha);
if ( $_status_login == "logado" )
{
	// Redireciona para o sistema //
	header("Location: ../home/index.php");
}	else 	{
	if ( $_status_login == "logado" )
	{
		// Redireciona para a pagina de login com erro de usuario e senha //	
	}
	if ( $_status_login == "logado" )
	{
		// Redireciona para a pagina de login com erro de permissao //	
	}
}
?>