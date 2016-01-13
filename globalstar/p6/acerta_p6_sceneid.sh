<?php

$tabela='Scene';

$sqlUpdate="UPDATE " . $tabela;
$conexao = mysql_pconnect("150.163.134.105:3333","gerente","gerente.200408");
$dbcatalogo = mysql_select_db("catalogo", $conexao);

// String contendo a instruç de pesquisa com o limite de registrs s serem retornados
$stringSQLPesquisa=	'SELECT SceneId, TL_Latitude, TL_Longitude, TR_Latitude, TR_Longitude, BL_Latitude, BL_Longitude, BR_Latitude, BR_Longitude  ' .
					'FROM Scene WHERE Catalogo > 1 AND Satellite = "P6" AND Sensor = "LIS3" AND SceneID LIKE "P6LIS3%P6"ORDER BY Date DESC, SceneId Desc';
					
// Resgistros retornados
$registros = mysql_query( $stringSQLPesquisa, $conexao );


// Realiza a leitura de cada registro e atribui àariál ratual (Registro Atual)
while ( $ratual = mysql_fetch_assoc( $registros ) ) 
{	

	$sceneidAtual=strtoupper($ratual['SceneId']);
	$sceneidNovo=substr($sceneidAtual,0,strlen($sceneidAtual)-2);
	
	
	
	$TL_Latitude=$ratual['TL_Latitude'];
	$TL_Longitude=$ratual['TL_Longitude'];
	$TR_Latitude=$ratual['TR_Latitude'];
	$TR_Longitude=$ratual['TR_Longitude'];
	
	$BL_Latitude=$ratual['BL_Latitude'];
	$BL_Longitude=$ratual['BL_Longitude'];
	$BR_Latitude=$ratual['BR_Latitude'];
	$BR_Longitude=$ratual['BR_Longitude'];
	
	
	
	
	$sqlUpdate="UPDATE " . $tabela . 
				" SET TL_Latitude = " . $TL_Latitude . " , TL_Longitude = " . $TL_Longitude . " , BL_Latitude = " . $BL_Latitude . " , BL_Longitude = " . $BL_Longitude .
				",    TR_Latitude = " . $TR_Latitude . " , TR_Longitude = " . $TR_Longitude . " , BR_Latitude = " . $BR_Latitude . " , BR_Longitude = " . $BR_Longitude .
				" WHERE SceneId LIKE \"" . $sceneidNovo . "\"";
				
	echo "ACERTANDO IMAGEM " . $sceneidAtual . " para " . $sceneidNovo . " ...\n";
	echo $sqlUpdate;
	echo "";

	
	mysql_query($sqlUpdate, $conexao) or die (mysql_error());
	
}

echo "";

mysql_close($conexao);

?>

