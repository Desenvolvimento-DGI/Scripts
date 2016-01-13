<?php

$sceneid=$argv[1];
$img_ql_minimo=$argv[2];


$tabela='RES2Thumbnail';
$size = filesize($img_ql_minimo);

$arquivo = fopen($img_ql_minimo, "rb");
$img_thumbnail_blob = fread($arquivo, $size);
$img_thumbnail_blob = addslashes($img_thumbnail_blob);
fclose($arquivo);

$sqlInsere="INSERT INTO " . $tabela . " ( SceneId, Thumbnail ) VALUES ('" . $sceneid . "', '" . $img_thumbnail_blob . "')";
$conexao = mysql_pconnect("150.163.134.105:3333","gerente","gerente.200408");
$dbcatalogo = mysql_select_db("catalogo", $conexao);

mysql_query($sqlInsere) or die (mysql_error());
mysql_close($conexao);

?>

