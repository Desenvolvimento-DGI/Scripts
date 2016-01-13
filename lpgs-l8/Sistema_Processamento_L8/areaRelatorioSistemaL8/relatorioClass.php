<?php
/*
	Classe com as funções PHP respnsáveis pelas operacoes de INGEST
	Autor: Jose Neto
	Data: 03/2015
*/
// classe de conexao com o banco de dados //
include("../config/conexao/conexaoBD.php");
class RelatorioClass
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
	// Metodo que busca as passagem em um determinado periodo de tempo //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function selecionaDadosParaTempoDeProcessamento($data_inicial, $data_final, $tipo_processo)
	{
		
		// acerta as variaveis //
		$partes_data_incial = explode(" ", $data_inicial);
		$data_inicial = $partes_data_incial[0];
		$partes_data_final = explode(" ", $data_final);
		$data_final = $partes_data_final[0];
		
		// SQL para consulta //
		$_SQL = "SELECT * FROM processos_Landsat8 WHERE proc_data_inicial >= '$data_inicial' AND proc_data_final <= '$data_final' AND proc_tipo = '$tipo_processo'";
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
	
	
	// -------------------------------------------------------------------------------------------------------------------- //
	// Metodo que busca as passagem em um determinado periodo de tempo para relatorio completo //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function selecionaDadosParaTempoDeProcessamentoCompleto($data_inicial, $data_final)
	{
		
		// acerta as variaveis //
		$partes_data_incial = explode(" ", $data_inicial);
		$data_inicial = $partes_data_incial[0];
		$partes_data_final = explode(" ", $data_final);
		$data_final = $partes_data_final[0];
		
		// SQL para consulta //
		$_SQL = "SELECT * FROM processos_Landsat8 WHERE proc_data_inicial >= '$data_inicial' AND proc_data_final <= '$data_final' AND proc_tipo = 'RENOMEAR'";
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
	
	
	// -------------------------------------------------------------------------------------------------------------------- //
	// Metodo que busca os dados do processo INGEST e retorna o tempo apenas //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function retornaTempoProcessoIngest($passagem_processada)
	{
		// inicia a variavel com um valor neutro //
		$total_processamento_ingest = '0';
		// Realiza a consulta //
		$_CONSULTA_INGEST = self::selectDadosProcessoIngest($passagem_processada);
		while ( $DADOS_INGEST = mysql_fetch_array($_CONSULTA_INGEST) )
		{
			// Data completa de inicio e termino do processo //
			$data_inicio = $DADOS_INGEST['proc_data_inicial'];
			$data_fim = $DADOS_INGEST['proc_data_final'];
			if ( $data_inicio && $data_fim && $data_inicio!= '' && $data_fim != '' )
			{
				// data e hora incial do processo
				$parte_data_incial_01 = explode(" ", $data_inicio);
				$parte_data_inicial = explode("/", $parte_data_incial_01[0]);
				$data_inicial_formato_certo = $parte_data_inicial[2]."-".$parte_data_inicial[1]."-".$parte_data_inicial[0];
				$data_e_hora_inicial_certo = $data_inicial_formato_certo." ".$parte_data_incial_01[1];
				// data e hora final do processo
				$parte_data_final_01 = explode(" ", $data_fim);
				$parte_data_final = explode("/", $parte_data_final_01[0]);
				$data_final_formato_certo = $parte_data_final[2]."-".$parte_data_final[1]."-".$parte_data_final[0];
				$data_e_hora_final_certo = $data_final_formato_certo." ".$parte_data_final_01[1];
				
				echo $data_e_hora_inicial_certo."-".$data_e_hora_final_certo."<br />";
				
				$data_e_hora_inicial_time = strtotime($data_e_hora_inicial_certo);
				$data_e_hora_final_time = strtotime($data_e_hora_final_certo);
				
				$nHoras   = ($data_e_hora_final_time - $data_e_hora_inicial_time) / 3600;
				$nMinutos = (($data_e_hora_final_time - $data_e_hora_inicial_time) % 3600) / 60;
				$nsegundos = (($data_e_hora_final_time - $data_e_hora_inicial_time) % 3600) / 3600;
				$total_processamento_ingest = sprintf('%02d:%02d:%02d', $nHoras, $nMinutos, $nsegundos);
				echo $total_processamento_ingest."<br />";
				/*
				
				
				// recorta a hora inicial e final //
				$parte_data_incial = explode(" ", $data_inicio);
				$hora_inicial = $parte_data_incial[1];
				$parte_data_fim = explode(" ", $data_fim);
				$hora_final = $parte_data_fim[1];
				
				$hora_inicial_time = strtotime($hora_inicial);
				$hora_final_time = strtotime($hora_final);
			
				$nHoras   = ($hora_final_time - $hora_inicial_time) / 3600;
				$nMinutos = (($hora_final_time - $hora_inicial_time) % 3600) / 60;
				$nsegundos = (($hora_final_time - $hora_inicial_time) % 3600) / 3600;
				//--echo $nHoras.":".$nMinutos.":".$nsegundos."<br />";
				$total_processamento_ingest = sprintf('%02d:%02d:%02d', $nHoras, $nMinutos, $nsegundos);
				//echo $total_processamento_ingest."<br />";
				*/
			}
		}
		if ( $total_processamento_ingest && $total_processamento_ingest != '0' )
		{
		return($total_processamento_ingest);
		}	else	{
			$total_processamento_ingest = "vazio";
			return($total_processamento_ingest);
		}
		
	}
	private function selectDadosProcessoIngest($passagem_processada)
	{
		// SQL para consulta //
		$_SQL = "SELECT * FROM processos_Landsat8 WHERE proc_passagem = '$passagem_processada' AND proc_tipo = 'INGEST' ORDER BY id_processo Desc LIMIT 1";
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
	
	
	
	// -------------------------------------------------------------------------------------------------------------------- //
	// Metodo que busca os dados do processo SUBSETTER e retorna o tempo apenas //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function retornaTempoProcessoSubsetter($passagem_processada)
	{
		// inicia a variavel com um valor neutro //
		$total_processamento_subsetter = '0';
		// Realiza a consulta //
		$_CONSULTA_SUBSETTER = self::selectDadosProcessoSubsetter($passagem_processada);
		while ( $DADOS_SUBSETTER = mysql_fetch_array($_CONSULTA_SUBSETTER) )
		{
			// Data completa de inicio e termino do processo //
			$data_inicio = $DADOS_SUBSETTER['proc_data_inicial'];
			$data_fim = $DADOS_SUBSETTER['proc_data_final'];
			if ( $data_inicio && $data_fim )
			{
				// recorta a hora inicial e final //
				$parte_data_incial = explode(" ", $data_inicio);
				$hora_inicial = $parte_data_incial[1];
				$parte_data_fim = explode(" ", $data_fim);
				$hora_final = $parte_data_fim[1];
				
				$hora_inicial_time = strtotime($hora_inicial);
				$hora_final_time = strtotime($hora_final);
			
				$nHoras   = ($hora_final_time - $hora_inicial_time) / 3600;
				$nMinutos = (($hora_final_time - $hora_inicial_time) % 3600) / 60;
				$nsegundos = (($hora_final_time - $hora_inicial_time) % 3600) / 3600;
				//--echo $nHoras.":".$nMinutos.":".$nsegundos."<br />";
				$total_processamento_subsetter = sprintf('%02d:%02d:%02d', $nHoras, $nMinutos, $nsegundos);
				//--echo $total_processamento_subsetter."<br />";
			}
		}
		return($total_processamento_subsetter);
		
	}
	private function selectDadosProcessoSubsetter($passagem_processada)
	{
		// SQL para consulta //
		$_SQL = "SELECT * FROM processos_Landsat8 WHERE proc_passagem = '$passagem_processada' AND proc_tipo = 'SUBSETTER' ORDER BY proc_data_inicial";
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
	
	
	
	// -------------------------------------------------------------------------------------------------------------------- //
	// Metodo que busca os dados do processo LPGS e retorna o tempo apenas //
	// -------------------------------------------------------------------------------------------------------------------- //
	public function retornaTempoProcessoLPGS($passagem_processada)
	{
		// inicia a variavel com um valor neutro //
		$total_processamento_lpgs = '0';
		// Realiza a consulta //
		$_CONSULTA_LPGS = self::selectDadosProcessoLpgs($passagem_processada);
		while ( $DADOS_LPGS = mysql_fetch_array($_CONSULTA_LPGS) )
		{
			// Data completa de inicio e termino do processo //
			$data_inicio = $DADOS_LPGS['proc_data_inicial'];
			$data_fim = $DADOS_LPGS['proc_data_final'];
			
			echo $data_inicio."-".$data_fim."<br />";
			if ( $data_inicio && $data_fim )
			{
				// recorta a hora inicial e final //
				$parte_data_incial = explode(" ", $data_inicio);
				$hora_inicial = $parte_data_incial[1];
				$parte_data_fim = explode(" ", $data_fim);
				$hora_final = $parte_data_fim[1];
				
				$hora_inicial_time = strtotime($hora_inicial);
				$hora_final_time = strtotime($hora_final);
			
				$nHoras   = ($hora_final_time - $hora_inicial_time) / 3600;
				$nMinutos = (($hora_final_time - $hora_inicial_time) % 3600) / 60;
				$nsegundos = (($hora_final_time - $hora_inicial_time) % 3600) / 3600;
				//--echo $nHoras.":".$nMinutos.":".$nsegundos."<br />";
				$total_processamento_lpgs = sprintf('%02d:%02d:%02d', $nHoras, $nMinutos, $nsegundos);
				echo $total_processamento_lpgs."<br />";
			}
		}
		//return($total_processamento_ingest);
		
	}
	private function selectDadosProcessoLpgs($passagem_processada)
	{
		// SQL para consulta //
		$_SQL = "SELECT * FROM processos_Landsat8 WHERE proc_passagem = '$passagem_processada' AND proc_tipo = 'LPGS-L1T' ORDER BY proc_data_inicial";
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