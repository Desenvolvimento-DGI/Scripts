<?php
/*
Pagina que remove o processo da lista de passgens processadas
autor: Jose Neto
data: 04/2015
*/

include("homeClass.php");
$_METODO = new HOMEClass();

// Recebe o parametro //
$id_processamento = $_GET['id_processamento'];

// Funcao que remove o processamento da lista //
$_METODO->removeProcessamentoDaLista($id_processamento);

// 5 - Direcionando a pagina //
echo "
	<script type='text/javascript'>
		window.location.href = 'listaDeProcessos.php';
	</script>
";

?>