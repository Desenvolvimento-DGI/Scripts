<?php
/*
	Classe com as funções PHP respnsáveis pelas operacoes de INGEST
	Autor: Jose Neto
	Data: 03/2015
*/
// classe de conexao com o banco de dados //
include("../config/conexao/conexaoBD.php");
class INGESTClass
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
		system("ls /dados/L0_LANDSAT8/MISSION_DATA > lista_ano_mes.txt");
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
		//$diretorio = "/L0_LANDSAT8/MISSION_DATA/".$ano_mes."/";
		$diretorio = "/dados/L0_LANDSAT8/MISSION_DATA/".$ano_mes."/";
		// gera a lista em um arquivo TXT //
		system("ls $diretorio > lista_passagens_por_ano_mes.txt");
		// le a lista e pega os valores //
		$_ARQUIVO_PASSAGENS_ANO_MES_TXT = "lista_passagens_por_ano_mes.txt";
		$lista_txt = fopen ("$_ARQUIVO_PASSAGENS_ANO_MES_TXT","r");
		$_lista_passagens_retornar = "";
		while (!feof ($lista_txt)) 
		{
			$linha_arquivo = fgets($lista_txt,4096);
			$dia_juliano = trim(substr($linha_arquivo, 16, 3));
			// LO80010570812015067CUB00
			$verifica = trim(substr($linha_arquivo, 0, 2));
			if ( $verifica == "LO" || $verifica == "LC" )
			{
				$_lista_passagens_retornar .= ";".$dia_juliano."-".$linha_arquivo;
			}
		}
		//--echo $_lista_passagens_retornar."<br />";
		return($_lista_passagens_retornar);
	}
	// -------------------------------------------------------------------------------------------------------------------- //
	// fim do metodo //
	// -------------------------------------------------------------------------------------------------------------------- //
	
	// -------------------------------------------------------------------------------------------------------------------- //
	// Metodo que lista os arquivos CPF //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function listaArquivosCPF($ano_mes)
	{
		// Recorta a data //
		$ano = explode("_",$ano_mes);
		$ano = "*".$ano[0]."*";
		// diretorio padrao do arquivo CPF //
		$dir_cpf = "/L0_LANDSAT8/AncillaryFiles/CPF/";
		// diretorio de execucao //
		$dir_ingest="/dados/htdocs/Sistema_Processamento_L8/funcaoIngest";
		// gera a lista em um arquivo TXT //
		system("cd ${dir_cpf}; ls -t ${ano} > $dir_ingest/lista_CPF.txt");
		//--echo "ls -t ${dir_cpf}${ano} > lista_CPF.txt";
		// le a lista e pega os valores //
		$_ARQUIVO_CPF_TXT = "lista_CPF.txt";
		$lista_txt = fopen ("$_ARQUIVO_CPF_TXT","r");
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
	public function buscaCPF()
	{
		// diretorio padrao do arquivo CPF //
		$dir_cpf = "/L0_LANDSAT8/AncillaryFiles/CPF/";
		// gera a lista e pega o ultimo arquivo atualizado //
		$ultimo_cpf = exec("ls -ltr $dir_cpf | tail -1 ");
		// separa o resultado e paga o nome do arquivo //
		$partes_ultimo_cpf = explode(" ", $ultimo_cpf);
		$ultimo_cpf_retornar = $dir_cpf."".$partes_ultimo_cpf[8];
		return($ultimo_cpf_retornar);
		
	}
	// -------------------------------------------------------------------------------------------------------------------- //
	// fim do metodo //
	// -------------------------------------------------------------------------------------------------------------------- //
	
	// -------------------------------------------------------------------------------------------------------------------- //
	// Metodo que busca os valores do template no Banco de Dados //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function buscaTemplateODL_BD()
	{
		// SQL para consulta //
		$_SQL = "SELECT * FROM template_arquivo_ODL_L8";
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
	// fim do metodo //
	// -------------------------------------------------------------------------------------------------------------------- //
	
	// -------------------------------------------------------------------------------------------------------------------- //
	// Metodo que grava dados do inicio do processamento da funcao INGEST //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function gravaInicioProcessoIngestL8($_usuario, $_passagem, $_data_inicial, $_status, $caracter_chave)
	{
		// SQL para consulta //
		$_SQL = "INSERT INTO processos_Landsat8(proc_caracter_chave, proc_passagem, proc_data_inicial, proc_status, proc_login_operador, proc_exibir_info, proc_tipo) 
		values('$caracter_chave', '$_passagem', '$_data_inicial', '$_status', '$_usuario', 'SIM', 'INGEST')";
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
	
	// -------------------------------------------------------------------------------------------------------------------- //
	// Metodo que lista os processos em execucao no momento //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function listaProcessosEmExecucao()
	{
		// SQL para consulta //
		$_SQL = "SELECT * FROM processos_Landsat8 WHERE proc_status = 'EXECUTANDO' AND proc_tipo = 'INGEST'";
		//echo $_SQL."<br />";
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
	// fim do metodo //
	// -------------------------------------------------------------------------------------------------------------------- //
	
}
?>