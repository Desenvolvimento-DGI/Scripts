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
	$stringSQLParAno="";
	$stringSQLParAnoInterno=" WHERE  categoria = 'I' ";
	
	$mensagemAno="Todos os anos";
}
else
{

	if ( empty($parAnoFinal) )
	{
		$stringSQLParAno=" WHERE YEAR(registerDate) = " . $parAnoInicial;	
		$stringSQLParAnoInterno=" WHERE  categoria = 'I'  AND YEAR(registerDate) = " . $parAnoInicial;

		$mensagemAno=$parAnoInicial;
	}
	else
	{
		$mensagemAno="Ano de " . $parAnoInicial . " ate " . $parAnoFinal;	
		$stringSQLParAno=" WHERE YEAR(registerDate) >= " . $parAnoInicial . "  AND YEAR(registerDate) <= " . $parAnoFinal ;	
		$stringSQLParAnoInterno=" WHERE categoria = 'I' AND YEAR(registerDate) >= " . $parAnoInicial . "  AND YEAR(registerDate) <= " . $parAnoFinal;
		
	}
	
}


// String contendo a instrucao de pesquisa e agrupamento para todos os usuáos
$stringSQLPesquisaUsuarios =	"SELECT YEAR(registerDate) as ANO, categoria, COUNT(1) as total  FROM cadastro.User " . $stringSQLParAno . 
								" GROUP BY ANO, categoria ORDER BY ANO, categoria";


// String contendo a instrucao de pesquisa e agrupamento para usuáos internos
$stringSQLPesquisaInterno =	"SELECT YEAR(registerDate) as ANO, coordenacao as COORDENACAO, divisao as DIVISAO, COUNT(1) as USUARIOS FROM cadastro.User " .
							$stringSQLParAnoInterno . " GROUP BY ANO, COORDENACAO, DIVISAO ORDER BY ANO, COORDENACAO, DIVISAO" ;

	
	
	
	
echo "\n";
echo "Estatisticas de Usuáos Cadastrados - Internos e Externos\n";
echo "Periodo: " . $mensagemAno;
echo "\n";
echo "\n";
echo "Todos Usuarios - Internos e Externos\n";
echo "------------------------------------\n\n";



// Todos os Usuáos - Internos e Externos	
// Resgistros retornados
$registros = mysql_query( $stringSQLPesquisaUsuarios, $conexao ) or die (mysql_error());
$totalUsuariosTodos=0;

// Realiza a leitura de cada registro e atribui para a variavel ratual (Registro Atual)
while ( $ratual = mysql_fetch_assoc( $registros ) ) 
{	
	$categoriaAtual=strtoupper($ratual['categoria']);	
	$totalUsuarios=strtoupper($ratual['total']);	
	$anoAtual=strtoupper($ratual['ANO']);	

	$descricaoCategoria="";
	
	if ( $categoriaAtual == 'I' ) $descricaoCategoria="Usuarios Internos";
	if ( $categoriaAtual == 'E' ) $descricaoCategoria="Usuarios Externos";

	
	echo $anoAtual . "  " . $descricaoCategoria . "(" . $categoriaAtual . ")  :  " . $totalUsuarios . "\n";	
	$totalUsuariosTodos+=$totalUsuarios;	
}

echo "\n";
echo "Total Geral                  : " . $totalUsuariosTodos . "\n\n\n";


// -------------------------------------------------------------------------------------


// Todos os Usuáos Internos
// Resgistros retornados

echo "\n";
echo "Apenas Usuarios Internos\n";
echo "-------------------------\n\n";


$registros = mysql_query( $stringSQLPesquisaInterno, $conexao ) or die (mysql_error());
$totalUsuariosTodos=0;

$titulo='ANO;COORDENACAO;DIVISAO;TOTAL USUARIOS';
$dadosExcel= $titulo;

echo "ANO     COORDENACAO         DIVISAO             TOTAL DE USUARIOS \n";

// Realiza a leitura de cada registro e atribui para a variavel ratual (Registro Atual)
while ( $ratual = mysql_fetch_assoc( $registros ) ) 
{	
	$coordenacaoAtual=strtoupper($ratual['COORDENACAO']);	
	$divisaoAtual=strtoupper($ratual['DIVISAO']);		
	$totalUsuarios=strtoupper($ratual['USUARIOS']);	
	$anoAtual=strtoupper($ratual['ANO']);
	
	echo sprintf("%-8s", $anoAtual) . sprintf("%-20s", $coordenacaoAtual) . sprintf("%-20s", $divisaoAtual) . sprintf("%-10s", $totalUsuarios) . "\n";		
	$dadosExcel = $dadosExcel . "\n" . $anoAtual . ';' . $coordenacaoAtual . ';' . $divisaoAtual . ';' . $totalUsuarios;	

	$totalUsuariosTodos+=$totalUsuarios;	
}

echo "\n";
echo "Total Usuarios Internos   : " . $totalUsuariosTodos . "\n\n";
echo "\n\n";

echo $dadosExcel;
echo "\n\n";
mysql_close($conexao);

?>


