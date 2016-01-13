<?php
/*
Pagina que lista os LOGS das passagens processadas
autor: Jose Neto
data: 05/2015
*/

include("homeClass.php");
$_METODO = new HOMEClass();

// Classe das configuracoes //
include("../configuracaoClass.php");
configuracaoClass::_CSS_02();

// Recebe o parametro do nome da passagem e tipo de processo para realizar a consulta na area de logs //
$passagem = $_REQUEST['passagem'];
$tipo_processo = $_REQUEST['tipo_processo'];
// Recorta o nome da passagem //
$prefixo_pesquisa = substr($passagem, 0, 6);
$sufixo_pesquisa = substr($passagem, 12, 12);
// Variavel de pesquisa //
$variavel_pesquisa = "*".$prefixo_pesquisa."*".$sufixo_pesquisa;
// seleciona qual log deve ser buscado //
// diretorio da pesquisa dos logs //
switch ($tipo_processo) 
{
	case 'INGEST':
		$diretorio_pesquisa = '/dados/htdocs/Sistema_Processamento_L8/funcaoIngest/logs';
		break;
	case 'SUBSETTER':
		$diretorio_pesquisa = '/dados/htdocs/Sistema_Processamento_L8/funcaoSubsetter/logs';
		break;
}
// variavel completa para pesquisa //
$variavel_completa_pesquisa = $diretorio_pesquisa."/".$variavel_pesquisa;
// gera a lista de logs disponiveis //
$LISTA_DE_LOGS = $_METODO->listaLogsDeProcessamento($variavel_completa_pesquisa);

// le a lista e exibe na tela //
$logs_processamento = explode(";", $LISTA_DE_LOGS);
$count = count($logs_processamento);
if ( $count == 0 )
{
		echo "<h4>NENHUM LOG ENCONTRADO PARA O PROCESSO!</h4>";
}	else	{
	for ($i = 0; $i < $count; $i++)
	{	
		if ( trim($logs_processamento[$i]) )
		{
			$conteudo_do_log = trim($logs_processamento[$i]);
			$partes_do_log = explode("/", $conteudo_do_log);
			$url_log = "<a href='http://lpgs-l8.dgi.inpe.br:8080/Sistema_Processamento_L8/funcaoIngest/logs/".$partes_do_log[6]."'>".$partes_do_log[6]."</a>";
			echo $url_log."<br />";
		}	
	}
}
// /dados/htdocs/Sistema_Processamento_L8/funcaoIngest/logs/log_saida_LG_LO82170722015140CUB00//
// LO82170620762015140CUB00 //

?>
