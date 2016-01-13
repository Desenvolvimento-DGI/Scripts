<?php
//error_reporting(E_ALL ^ E_DEPRECATED); // Nãapresenta as mensagens relacionadas a comandos 
//error_reporting(E_ERROR | E_WARNING | E_PARSE);
//error_reporting(E_ERROR);

if ( isset($argv[1]) ) $parAnoInicial=$argv[1];
if ( isset($argv[2]) ) $parAnoFinal=$argv[2];



$conexao = mysql_pconnect("150.163.134.105:3333","gerente","gerente.200408");
$dbcatalogo = mysql_select_db("catalogo", $conexao);


if ( empty($parAnoInicial) &&  empty($parAnoFinal))
{
	$stringSQLParAnoInterno=" WHERE u.userId = r.UserId AND categoria = 'I' ";
	$mensagemAno="Todos os anos";
}
else
{

	if ( empty($parAnoFinal) )
	{
		$stringSQLParAnoInterno=" WHERE u.userId = r.UserId AND categoria = 'I'  AND YEAR(r.ReqDate) = " . $parAnoInicial;
		$mensagemAno=$parAnoInicial;
	}
	else
	{
		$mensagemAno="Ano de " . $parAnoInicial . " ate " . $parAnoFinal;	
		$stringSQLParAnoInterno=" WHERE u.userId = r.UserId AND categoria = 'I' AND YEAR(r.ReqDate) >= " . $parAnoInicial . "  AND YEAR(r.ReqDate) <= " . $parAnoFinal;		
	}
	
}




// String contendo a instrucao de pesquisa e agrupamento para usuáos internos
$stringSQLPesquisaInterno =	"SELECT YEAR(r.ReqDate) as ANO, u.coordenacao as COORDENACAO, u.divisao as DIVISAO, COUNT(r.ReqId) as PEDIDOS  FROM cadastro.User u, catalogo.Request r " . 	$stringSQLParAnoInterno . " GROUP BY ANO, COORDENACAO, DIVISAO ORDER BY Ano, Pedidos DESC" ;

	
	
	
	
echo "\n";
echo "Estatisticas de Pedidos por Usuarios Internos\n";
echo "Periodo: " . $mensagemAno;
echo "\n";
echo "\n";



$registros = mysql_query( $stringSQLPesquisaInterno, $conexao ) or die (mysql_error());
$totalPedidosTodos=0;

$titulo='ANO;COORDENACAO;DIVISAO;TOTAL PEDIDOS';
$dadosExcel= $titulo;

echo "ANO     COORDENACAO         DIVISAO             TOTAL DE PEDIDOS \n";
// Realiza a leitura de cada registro e atribui para a variavel ratual (Registro Atual)
while ( $ratual = mysql_fetch_assoc( $registros ) ) 
{	
	$coordenacaoAtual=strtoupper($ratual['COORDENACAO']);	
	$divisaoAtual=strtoupper($ratual['DIVISAO']);		
	$totalPedidos=strtoupper($ratual['PEDIDOS']);	
	$anoAtual=strtoupper($ratual['ANO']);
	
	echo sprintf("%-8s", $anoAtual) . sprintf("%-20s", $coordenacaoAtual) . sprintf("%-20s", $divisaoAtual) . sprintf("%-10s", $totalPedidos) . "\n";	
	$totalPedidosTodos+=$totalPedidos;	
	
	$dadosExcel = $dadosExcel . "\n" . $anoAtual . ';' . $coordenacaoAtual . ';' . $divisaoAtual . ';' . $totalPedidos;	
	
}

echo "\n";
echo "Total Pedidos dos Usuarios Internos   : " . $totalPedidosTodos . "\n\n";
echo "\n\n";

echo $dadosExcel;
echo "\n\n";

mysql_close($conexao);

?>


