<?php

$tabela='Scene';

$sqlUpdate="UPDATE " . $tabela;
$conexao = mysql_pconnect("150.163.134.105:3333","gerente","gerente.200408");
$dbcatalogo = mysql_select_db("catalogo", $conexao);

// String contendo a instruç de pesquisa com o limite de registrs s serem retornados
$stringSQLPesquisa=	"SELECT SceneId, TL_Latitude, TL_Longitude, BL_Latitude, BL_Longitude, TR_Latitude, TR_Longitude, BR_Latitude, BR_Longitude  " .
					"FROM Scene WHERE Catalogo = 1 AND Satellite = 'P6' AND Sensor = 'LIS3' ORDER BY Date DESC, SceneId Desc";
					
// Resgistros retornados
$registros = mysql_query( $stringSQLPesquisa, $conexao );


// Realiza a leitura de cada registro e atribui àariál ratual (Registro Atual)
while ( $ratual = mysql_fetch_assoc( $registros ) ) 
{	

	$sceneidAtual=strtoupper($ratual['SceneId']);
	
	$TL_Latitude=$ratual['TL_Latitude'];
	$TL_Longitude=$ratual['TL_Longitude'];
	$TR_Latitude=$ratual['TR_Latitude'];
	$TR_Longitude=$ratual['TR_Longitude'];
	
	$BL_Latitude=$ratual['BL_Latitude'];
	$BL_Longitude=$ratual['BL_Longitude'];
	$BR_Latitude=$ratual['BR_Latitude'];
	$BR_Longitude=$ratual['BR_Longitude'];
	
	$sqlUpdate="UPDATE " . $tabela . 
				" SET Image_UL_Lat = " . $TL_Latitude . " , Image_UL_Lon = " . $TL_Longitude . " , Image_LL_Lat = " . $BL_Latitude . " , Image_LL_Lon = " . $BL_Longitude .
				",    Image_UR_Lat = " . $TR_Latitude . " , Image_UR_Lon = " . $TR_Longitude . " , Image_LR_Lat = " . $BR_Latitude . " , Image_LR_Lon = " . $BR_Longitude .
				" WHERE SceneId LIKE \"" . $sceneidAtual . "%\"";
				
	echo "ACERTANDO IMAGEM " . $sceneidAtual . "...\n";
	
	mysql_query($sqlUpdate, $conexao) or die (mysql_error());
 
}

echo "";

mysql_close($conexao);

?>

