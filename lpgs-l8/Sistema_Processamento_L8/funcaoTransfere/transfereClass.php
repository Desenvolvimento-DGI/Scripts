<?php
/*
	Classe com as funções PHP respnsáveis pelas operacoes de INGEST
	Autor: Jose Neto
	Data: 03/2015
*/
// classe de conexao com o banco de dados //
include("../config/conexao/conexaoBD.php");
class TransfereClass
{
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
	
	
	// -------------------------------------------------------------------------------------------------------------------- //
	// Metodo que lista os anos e meses que tem dados na area de L0 //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function listaAnoMesL0()
	{
		// gera a lista em um arquivo TXT //
		system("ls /dados/L1T_WORK/ > lista_ano_mes.txt");
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
		$diretorio = "/dados/L1T_WORK/".$ano_mes;
		//echo $diretorio;
		// gera a lista em um arquivo TXT //
		system("ls $diretorio > lista_passagens_por_ano_mes.txt");
		// le a lista e pega os valores //
		$_ARQUIVO_PASSAGENS_ANO_MES_TXT = "lista_passagens_por_ano_mes.txt";
		$lista_txt = fopen ("$_ARQUIVO_PASSAGENS_ANO_MES_TXT","r");
		$_lista_passagens_retornar = "";
		while (!feof ($lista_txt)) 
		{
			$linha_arquivo = fgets($lista_txt,4096);
			//--echo $linha_arquivo."<br />";
			if ( $linha_arquivo && $linha_arquivo != "" )
			{
				
				// LO80010570812015067CUB00
				$_lista_passagens_retornar .= ";".$linha_arquivo;
			}
		}
		//--echo $_lista_passagens_retornar."<br />";
		return($_lista_passagens_retornar);
	}
	// -------------------------------------------------------------------------------------------------------------------- //
	// fim do metodo //
	// -------------------------------------------------------------------------------------------------------------------- //
	
	
	
	// -------------------------------------------------------------------------------------------------------------------- //
	// Metodo que grava dados do inicio do processamento da funcao INGEST //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function gravaInicioProcessoTransferir($_usuario, $_passagem, $_data_inicial, $_status, $caracter_chave)
	{
		// SQL para consulta //
		$_SQL = "INSERT INTO processos_Landsat8(proc_caracter_chave, proc_passagem, proc_data_inicial, proc_status, proc_login_operador, proc_exibir_info, proc_tipo) 
		values('$caracter_chave', '$_passagem', '$_data_inicial', '$_status', '$_usuario', 'SIM', 'TRANSFERIR')";
		//echo $_SQL."<br />";
		// Abre a conexao com a base de dados //
		self::objetoAbreConexao();
		// executa o SQL //
		mysql_query($_SQL) or die(mysql_error());
		// Fecha a conexao com a base de dados //
		self::objetoFechaConexao();
	}
	// -------------------------------------------------------------------------------------------------------------------- //
	// fim do metodo //
	// -------------------------------------------------------------------------------------------------------------------- //
	
}
?>