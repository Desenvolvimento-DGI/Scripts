<?php
/*
	Classe com as funções PHP - Home do sistema
	Autor: Jose Neto
	Data: 03/2015
*/
// classe de conexao com o banco de dados //
include("../config/conexao/conexaoBD.php");
class HOMEClass
{
	//--------------------------------------------------------------------------------------------------------------------//
	// Abre e fecha a conexao com o banco de dados //
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
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
	// Fim dos metodos de conexao e fecha conexao //
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
	
	
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
	// Funcao que lista todos os processos do sistema //
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
	public function listaTodosProcessos()
	{
		// SQL para consulta //
		$_SQL = "SELECT * FROM processos_Landsat8 WHERE proc_exibir_info = 'SIM' ";
		//-echo $_SQL."<br />";
		// Abre a conexao com a base de dados //
		self::objetoAbreConexao();
		// executa o SQL //
		$this->resultado = mysql_query($_SQL) or die(mysql_error());
		// Retorna o valor para a pagina //
		return($this->resultado);
		// Fecha a conexao com a base de dados //
		self::objetoFechaConexao();
	}
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
	// fim do metodo //
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
	// Funcao que remove a informacao do processamento INGEST da lista //
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
	public function removeProcessamentoDaLista($id_processamento)
	{
		// SQL para consulta //
		$_SQL = "UPDATE processos_Landsat8 SET proc_exibir_info = 'NAO' WHERE id_processo = $id_processamento";
		// Abre a conexao com a base de dados //
		self::objetoAbreConexao();
		// executa o SQL //
		$this->resultado = mysql_query($_SQL) or die(mysql_error());
		// Retorna o valor para a pagina //
		return($this->resultado);
		// Fecha a conexao com a base de dados //
		self::objetoFechaConexao();
	}
	
	// -------------------------------------------------------------------------------------------------------------------- //
	// Metodo que lista os Logs do processamento //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function listaLogsDeProcessamento($variavel_completa_pesquisa)
	{
		// gera a lista em um arquivo TXT //
		system("ls ${variavel_completa_pesquisa} > listaLogs.txt");
		// le a lista e pega os valores //
		$_ARQUIVO_LOG = "listaLogs.txt";
		$lista_txt = fopen ("$_ARQUIVO_LOG","r");
		$_lista_retornar = "";
		while (!feof ($lista_txt)) 
		{
			$_lista_retornar .= ";".$linha_arquivo = fgets($lista_txt,4096);
		}
		//echo $_lista_retornar."<br />";
		return($_lista_retornar);
	}
	// -------------------------------------------------------------------------------------------------------------------- //
	// fim do metodo //
	// -------------------------------------------------------------------------------------------------------------------- //


}


?>