<?php
//error_reporting(E_ALL ^ E_DEPRECATED); // Nãapresenta as mensagens relacionadas a comandos 
//error_reporting(E_ERROR | E_WARNING | E_PARSE);
//error_reporting(E_ERROR);
$parAno=$argv[1];
$parArquivo=$argv[2];
$conexao = mysql_pconnect("150.163.134.105:3333","gerente","gerente.200408");
$dbcatalogo = mysql_select_db("catalogo", $conexao);
if ( empty($parAno) )
{
	$stringSQLParAno="";	
	$mensagemAno="Todos os anos";
}
else
{
	$stringSQLParAno=" WHERE YEAR(Date) = " . $parAno . " ";	
	$mensagemAno=$parAno;
}
// String contendo a instrucao de pesquisa e agrupamento
$stringSQLPesquisa=	
"SELECT 	
	CASE 
		WHEN (Satellite) = 'A1' 		THEN 'AQUA'
		WHEN (Satellite) = 'T1' 		THEN 'TERRA'		
		WHEN (Satellite) = 'UKDMC' 		THEN 'UK-DMC'
		WHEN (Satellite) = 'UKDMC2' 	THEN 'UK-DMC-2'
		WHEN (Satellite) = 'NPP' 		THEN 'S-NPP'		
		WHEN (Satellite) = 'CB2' 		THEN 'CBERS2'
		WHEN (Satellite) = 'CB2B' 		THEN 'CBERS2B'		
		WHEN (Satellite) = 'P6' 		THEN 'RESOURCESAT-1'
		WHEN (Satellite) = 'RES2' 		THEN 'RESOURCESAT-2'		
		WHEN (Satellite) = 'L1' 		THEN 'LANDSAT-1'
		WHEN (Satellite) = 'L2' 		THEN 'LANDSAT-2'
		WHEN (Satellite) = 'L3' 		THEN 'LANDSAT-3'
		WHEN (Satellite) = 'L5' 		THEN 'LANDSAT-5'
		WHEN (Satellite) = 'L7' 		THEN 'LANDSAT-7'		
		WHEN (Satellite) = 'L8'			THEN 'LANDSAT-8'
		WHEN (Satellite) = 'RE1' 		THEN 'RAPIDEYE-1'
		WHEN (Satellite) = 'RE2' 		THEN 'RAPIDEYE-2'
		WHEN (Satellite) = 'RE3' 		THEN 'RAPIDEYE-3'
		WHEN (Satellite) = 'RE4' 		THEN 'RAPIDEYE-4'
		WHEN (Satellite) = 'RE5' 		THEN 'RAPIDEYE-5'
		WHEN (Satellite) = 'CB4'                THEN 'CBERS-4   '
		ELSE Satellite
	END 
	AS Satelite, 
	YEAR(Date) as Ano,
	MONTH(Date) as Mes,
	COUNT( SceneId ) AS CenasDisponiveis
FROM catalogo.Scene
$stringSQLParAno " . 
" GROUP BY Satelite, Ano, Mes 
  ORDER BY Satelite, Ano, Mes ";
	
echo "\n";
echo "Estatisticas de imagens disponiveis - Satelites\n";
echo "Periodo: " . $mensagemAno;
echo "\n";
echo "\n";
	
// Resgistros retornados
$registros = mysql_query( $stringSQLPesquisa, $conexao ) or die (mysql_error());
$totalCenasDisponiveis=0;
$hArquivo=fopen($parArquivo, 'a');
$textoEstatistica='';
// Realiza a leitura de cada registro e atribui para a variavel ratual (Registro Atual)
while ( $ratual = mysql_fetch_assoc( $registros ) ) 
{	
	$sateliteAtual=strtoupper($ratual['Satelite']);	
	$cenasDisponiveis=$ratual['CenasDisponiveis'];
	$anoAtual=$ratual['Ano'];
	$mesAtual=$ratual['Mes'];

	
	echo $sateliteAtual . " : " . $cenasDisponiveis . "\n";	
	$totalCenasDisponiveis+=$cenasDisponiveis;
		
	$textoEstatistica=$anoAtual . ';' . $mesAtual . ';CATALOGO;' . trim($sateliteAtual) . ';' . $cenasDisponiveis . "\n";
	
	fwrite($hArquivo, $textoEstatistica);
}
fclose($hArquivo);
echo "\n";
echo "Total Geral   : " . $totalCenasDisponiveis . "\n\n";
mysql_close($conexao);
?>

