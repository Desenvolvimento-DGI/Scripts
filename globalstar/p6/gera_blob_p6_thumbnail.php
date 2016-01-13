<?php

$tabela='P6Thumbnail';
$dir_ql='/QUICKLOOK/RESOURCESAT1/LIS3/';
$extensao='_MIN';


$conexao = mysql_pconnect("150.163.134.105:3333","gerente","gerente.200408");
$dbcatalogo = mysql_select_db("catalogo", $conexao);

// String contendo a instruç de pesquisa com o limite de registrs s serem retornados
$stringSQLPesquisa=	'SELECT SceneId FROM ' . $tabela . ' ORDER BY SceneId Desc';
					
// Resgistros retornados
$registros = mysql_query( $stringSQLPesquisa, $conexao );


// Realiza a leitura de cada registro e atribui àariál ratual (Registro Atual)
while ( $ratual = mysql_fetch_assoc( $registros ) ) 
{	

	$sceneidAtual=strtoupper($ratual['SceneId']);
	$nome_ql=$dir_ql . 'QL_' . $sceneidAtual . 'P6' . $extensao . '.png';
	
	$size = filesize($nome_ql);

	$arquivo = fopen($nome_ql, "rb");
	$img_blob = fread($arquivo, $size);
	$img_blob = addslashes($img_blob);
	fclose($arquivo);
	
	$sqlUpdate="UPDATE " . $tabela . " SET NThumbnail = '" . $img_blob . "' WHERE SceneId = '" . $sceneidAtual . "'";

	
	
	
				
	echo "GERANDO BLOB THUMBNAIL DA IMAGEM " . $sceneidAtual . "...\n";
	
	mysql_query($sqlUpdate, $conexao) or die (mysql_error());
	
}

echo "";

mysql_close($conexao);

?>

