<?php
/*
Pagina que fornece opções de relatorios do sistema de processamento do LandSat-8 //
autor: Jose Neto
data: 05/2015
*/

include("relatorioClass.php");
$_METODO = new RelatorioClass();

// Classe das configuracoes //
include("../configuracaoClass.php");
configuracaoClass::_CSS_02();

// Recebe os parametros //
$data_inicial = $_POST['data_inicial'];
$data_final = $_POST['data_final'];

// parametro para o botao exportar excel //
//--$parametro_excel = "tipo_processo=".$tipo_processo."&data_inicial=".$data_inicial."&data_final=".$data_final;

// Busca os dados na Tabela de processamento //
$_LISTA_TODOS_PROCESSOS = $_METODO->selecionaDadosParaTempoDeProcessamentoCompleto($data_inicial, $data_final);
while($_DADOS_PROCESSOS = mysql_fetch_array($_LISTA_TODOS_PROCESSOS))
{
	
	$passagem_processada = $_DADOS_PROCESSOS['proc_nome_final'];
	if ($passagem_processada && $passagem_processada != '' )
	{
		// Para cada passagem, deve calcular o tempo de processamento //
		// Retorna o tempo de processo INGEST da passagem //
		$dados_processo_ingest = $_METODO->retornaTempoProcessoIngest($passagem_processada);
		echo $passagem_processada."-".$dados_processo_ingest."<br />";
		// Retorna o tempo de processo SUBSETTER da passagem //
		//--$dados_processo_ingest = $_METODO->retornaTempoProcessoSubsetter($passagem_processada);
		// Retorna o tempo de processo LPGS-L1T da passagem //
		//--$dados_processo_ingest = $_METODO->retornaTempoProcessoLPGS($passagem_processada);
	}
}

?>

