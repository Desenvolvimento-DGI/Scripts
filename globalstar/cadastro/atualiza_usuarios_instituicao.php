<?php
//CMDPHP="/usr/local/web/php-5.6.1/bin/php "
$arquivo="/home/cdsr/cadastro/usuarios_2015.txt";


$conexao = mysql_pconnect("150.163.134.105:3333","gerente","gerente.200408");
$dbcatalogo = mysql_select_db("catalogo", $conexao);

$hArquivo=fopen($arquivo, "r");
$totalUsuarios=0;

// Realiza a leitura de cada registro e atribui para a variavel ratual (Registro Atual)
while ( ! feof($hArquivo) ) 
{	
	$totalUsuarios++;
	
	$linhaAtual=rtrim(fgets($hArquivo, 4096));
	list($useridAtual, $emailAtual, $instituicaoAtual) = explode(";", $linhaAtual);	

	if ( empty($useridAtual) ) continue;
	
	
	$sqlUpdateUser="UPDATE cadastro.User SET company = '" . $instituicaoAtual . "' WHERE userId = '" . $useridAtual . "' AND email = '" . $emailAtual . "'";
	$resultado = mysql_query( $sqlUpdateUser, $conexao ) or die (mysql_error());
	
	echo "Usuáo : " . $useridAtual . "   -  Instituicao Atualizada : " . $instituicaoAtual . "\n";	
	echo $sqlUpdateUser . "\n\n";

}

fclose($hArquivo);

echo "\nTotal Geral de Usuarios   : " . $totalUsuarios . "\n\n";


mysql_close($conexao);

?>


