<?php
//error_reporting(E_ALL ^ E_DEPRECATED); // Nãapresenta as mensagens relacionadas a comandos 
//error_reporting(E_ERROR | E_WARNING | E_PARSE);
//error_reporting(E_ERROR);

$parAno=$argv[1];
$parArquivo=$argv[2];

echo $parArquivo;
echo "";

$conexao = mysql_pconnect("150.163.134.105:3333","gerente","gerente.200408");
$dbcatalogo = mysql_select_db("catalogo", $conexao);



if ( empty($parAno) )
{
	$stringSQLParAno="";	
	$mensagemAno="Todos os anos";
}
else
{
	$stringSQLParAno=" AND YEAR(i.ProDate)= " . $parAno . " ";	
	$mensagemAno=$parAno;
}




// String contendo a instrucao de pesquisa e agrupamento
$stringSQLPesquisa=	
"SELECT YEAR(i.ProDate) as Ano, 
		MONTH(i.ProDate) as Mes, 

		CASE 
			WHEN (s.Satellite) = 'A1' 		THEN 'AQUA'
			WHEN (s.Satellite) = 'T1' 		THEN 'TERRA'		
			WHEN (s.Satellite) = 'UKDMC' 	THEN 'UK-DMC'
			WHEN (s.Satellite) = 'UKDMC2' 	THEN 'UK-DMC-2'
			WHEN (s.Satellite) = 'NPP' 		THEN 'S-NPP'		
			WHEN (s.Satellite) = 'CB4' 		THEN 'CBERS4'
			WHEN (s.Satellite) = 'CB2' 		THEN 'CBERS2'
			WHEN (s.Satellite) = 'CB2B' 	THEN 'CBERS2B'		
			WHEN (s.Satellite) = 'P6' 		THEN 'RESOURCESAT-1'
			WHEN (s.Satellite) = 'RES2' 	THEN 'RESOURCESAT-2'		
			WHEN (s.Satellite) = 'L1' 		THEN 'LANDSAT-1'
			WHEN (s.Satellite) = 'L2' 		THEN 'LANDSAT-2'
			WHEN (s.Satellite) = 'L3' 		THEN 'LANDSAT-3'
			WHEN (s.Satellite) = 'L5' 		THEN 'LANDSAT-5'
			WHEN (s.Satellite) = 'L7' 		THEN 'LANDSAT-7'		
			WHEN (s.Satellite) = 'L8' 		THEN 'LANDSAT-8'		
			WHEN (s.Satellite) = 'RE1' 		THEN 'RAPIDEYE-1'
			WHEN (s.Satellite) = 'RE2' 		THEN 'RAPIDEYE-2'
			WHEN (s.Satellite) = 'RE3' 		THEN 'RAPIDEYE-3'
			WHEN (s.Satellite) = 'RE4' 		THEN 'RAPIDEYE-4'
			WHEN (s.Satellite) = 'RE5' 		THEN 'RAPIDEYE-5'
			ELSE s.Satellite			
		END 
		AS Satelite, 		
		COUNT( i.SceneId ) AS CenasPedidas
FROM catalogo.RequestItem i, catalogo.Scene s 
WHERE s.SceneId = i.SceneId " . $stringSQLParAno . 
" GROUP BY Ano, Mes, Satelite
  ORDER BY Ano, Mes, Satelite";
  
  
	
echo "\n";
echo "Estatisticas de imagens entregues - Satelites\n";
echo "Periodo: " . $mensagemAno;
echo "\n";
echo "\n";
	
// Resgistros retornados
$registros = mysql_query( $stringSQLPesquisa, $conexao ) or die (mysql_error());
$totalCenasPedidas=0;

$hArquivo=fopen($parArquivo, 'a');
$textoEstatistica='';

// Realiza a leitura de cada registro e atribui para a variavel ratual (Registro Atual)
while ( $ratual = mysql_fetch_assoc( $registros ) ) 
{	
	$anoAtual=strtoupper($ratual['Ano']);	
	$mesAtual=strtoupper($ratual['Mes']);	
	$sateliteAtual=strtoupper($ratual['Satelite']);	
	$cenasPedidas=$ratual['CenasPedidas'];

	$textoMesAtual=$mesAtual;
	if ( $mesAtual < 10 )
	{
		$textoMesAtual='0' . $mesAtual;
	}
	
	echo $anoAtual . '/' . $textoMesAtual . ' - ' . $sateliteAtual . " : " . $cenasPedidas . "\n";	
		
		
	$textoEstatistica=$anoAtual . ';' . $textoMesAtual . ';CATALOGO;' . trim($sateliteAtual) . ';' . $cenasPedidas . ';1;' . $cenasPedidas . "\n";
	$totalCenasPedidas+=$cenasPedidas;
	
	fwrite($hArquivo, $textoEstatistica);
}

fclose($hArquivo);

echo "\n";
echo "Total Geral   : " . $totalCenasPedidas . "\n\n";


mysql_close($conexao);

?>


