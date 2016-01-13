<?php
/* ------------------------------------------------------------------------
	Classe com as funções PHP respnsáveis pelas operacoes de LOGIN e LOGOUT 
	Autor: Jose Neto
	Data: 01/2015
--------------------------------------------------------------------------- */
// classe de conexao com o banco de dados //
include("../config/conexao/conexaoBD.php");
class LoginClass
{
	/*
	// ----------------------------------------------------------------------- //
	// ----------------------------------------------------------------------- //
	// Os dados de acesso sao padronizados, os mesmos para CQ e Manager //
	// Funcao privada que faz a conexao com o banco de dados //
	private function conexaoBD_Catalogo()
	{
		$_USER = "gerente";
		$_HOST = "150.163.134.105:3333";
		$_PWD = "gerente.200408";
		$conec = mysql_connect($_HOST, $_USER, $_PWD) or die("NÃO CONECTADO COM O BANCO!");
		mysql_query("SET NAMES 'utf8'");
        mysql_query('SET character_set_connection=utf8');
        mysql_query('SET character_set_client=utf8');
        mysql_query('SET character_set_results=utf8');
		mysql_select_db("catalogo", $conec);
	}
	// Funcao que fecha a conexao com o banco de dados //
	private function fechaConexaoBD()
	{
		$_USER = "gerente";
		$_HOST = "150.163.134.105:3333";
		$_PWD = "gerente.200408";
		$conec = mysql_connect($_HOST, $_USER, $_PWD) or die("NÃO CONECTADO COM O BANCO!");
		mysql_close($conec);
	}
	// ----------------------------------------------------------------------- //
	*/
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
	// Abre e fecha a conexao com o banco de dados //
	// -------------------------------------------------------------------------------------------------------------------- //
	private function objetoAbreConexao()
	{
		
		$_BANCO = new ConexaoBD();
		$_BANCO->conexaoBD();
	}
	private function objetoFechaConexao()
	{
		$_BANCO = new ConexaoBD();
		$_BANCO->fechaConexaoBD();
	}
	// -------------------------------------------------------------------------------------------------------------------- //
	// Fim dos metodos de conexao e fecha conexao //
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
	
	
	// ----------------------------------------------------------------------- //
	// Funcao que realiza a busca do login e senha no banco de dados //
	public function verificaLoginSenha($_login, $_senha)
	{
		$_SQL = "SELECT * FROM usuario WHERE user_login = '$_login' AND user_senha = '$_senha'";
		// Abre a conexao com a base de dados //
		self::objetoAbreConexao();
		// executa o SQL //
		$this->resultado = mysql_query($_SQL) or die(mysql_error());
		// Fecha a conexao com a base de dados //
		self::objetoFechaConexao();
		// Se usuario e senha corretos, monta a sessao do usuario //
		$verificador = mysql_num_rows($this->resultado);		
		if ( $verificador != 0 )
		{
			// Dados do Login //
			while($_OUT = mysql_fetch_array($this->resultado))
			{
				// Realiza o login //
				session_start();
				$id_user = $_OUT['user_id'];
				$_SESSION['login'] = $_OUT['user_login'];
				$status_login = "logado";
				return($status_login);
			}
		}	else	{
			// Usuario ou Senha errado //
			$status_login = "usuario-senha-erro";
			return($status_login);
		}
	}
}

?>