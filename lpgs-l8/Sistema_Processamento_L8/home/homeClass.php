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
		$_SQL = "UPDATE processos_Landsat8 SET proc_exibir_info = 'NAO', proc_status = 'FINALIZADO' WHERE id_processo = $id_processamento";
		//--echo $_SQL."<br />";
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
	
	// -------------------------------------------------------------------------------------------------------------------- //
	// Metodo que lista os anos e meses que tem dados na area de L0 //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function listaDadosRenomeadosAnoMes()
	{
		// gera a lista em um arquivo TXT //
		system("ls -t /dados/L0_LANDSAT8/MISSION_DATA/ > lista_ano_mes.txt");
		// le a lista e pega os valores //
		$_ARQUIVO_ANO_MES_TXT = "lista_ano_mes.txt";
		$lista_txt = fopen ("$_ARQUIVO_ANO_MES_TXT","r");
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
	
	// -------------------------------------------------------------------------------------------------------------------- //
	// Metodo que lista os dados apos a escolha do ano e mes //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function listaDadosL0_PorAnoMes($ano_mes)
	{
		$diretorio = "/dados/L0_LANDSAT8/MISSION_DATA/".$ano_mes."/L*";
		// gera a lista em um arquivo TXT //
		system("ls -d $diretorio > lista_passagens_tar_gz_por_ano_mes.txt");
		// le a lista e pega os valores //
		$_ARQUIVO_PASSAGENS_ANO_MES_TXT = "lista_passagens_tar_gz_por_ano_mes.txt";
		$lista_txt = fopen ("$_ARQUIVO_PASSAGENS_ANO_MES_TXT","r");
		$_lista_passagens_retornar = "";
		while (!feof ($lista_txt)) 
		{
			$linha_arquivo = fgets($lista_txt,4096);
			if ( $linha_arquivo )
			{
				$partes_arquivo = explode("/", $linha_arquivo);
				$nome_do_arquivo_tar_gz = $partes_arquivo[5];
				$_lista_passagens_retornar .= ";".$nome_do_arquivo_tar_gz;
			}
		}
		//--echo $_lista_passagens_retornar."<br />";
		return($_lista_passagens_retornar);
	}
	// -------------------------------------------------------------------------------------------------------------------- //
	// fim do metodo //
	// -------------------------------------------------------------------------------------------------------------------- //


}


?>