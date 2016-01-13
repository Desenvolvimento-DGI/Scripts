<?php

$sceneid=$argv[1];
$img_ql_grande=$argv[2];


$tabela='RES2Browse';
$size = filesize($img_ql_grande);

$arquivo = fopen($img_ql_grande, "rb");
$img_browse_blob = fread($arquivo, $size);
$img_browse_blob = addslashes($img_browse_blob);
fclose($arquivo);

$sqlInsere="INSERT INTO " . $tabela . " ( SceneId, Browse ) VALUES ('" . $sceneid . "', '" . $img_browse_blob . "')";
$conexao = mysql_pconnect("150.163.134.105:3333","gerente","gerente.200408");
$dbcatalogo = mysql_select_db("catalogo", $conexao);

mysql_query($sqlInsere) or die (mysql_error());
mysql_close($conexao);

?>

