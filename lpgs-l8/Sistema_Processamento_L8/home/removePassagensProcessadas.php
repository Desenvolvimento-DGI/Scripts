<?php
// inicializando a sessao //
session_start();

/*
Pagina que lista os dados para serem processados
autor: Jose Neto
data: 03/2015
*/

include("homeClass.php");
$_METODO = new HOMEClass();

// Pega o login do usuario //
$_usuario = $_SESSION['login'];

//------------------------------------------------------------------------//
// CSS com a configuracao da tabela - ../config/scripts/styles/styles.css //
//------------------------------------------------------------------------//
// recebe os parametros //
$ano_mes = $_REQUEST['ano_mes'];
$passagem = $_REQUEST['passagem'];

// Remove os arquivos da area de processamento //
// Arquivo renomeado - Mission Data //
$dir_renomeado = "/dados/L0_LANDSAT8/MISSION_DATA/".$ano_mes;
system("cd $dir_renomeado; rm -rf $passagem;");
//echo "cd $dir_renomeado; rm -rf $passagem;";

// Arquivo renomeado - L0Ra //
$dir_l0ra = "/dados/L0_LANDSAT8/L0Ra/".$ano_mes;
system("cd $dir_l0ra; rm -rf $passagem;");
//echo "cd $dir_l0ra; rm -rf $passagem;";

// Arquivo renomeado - L0Rp //
$dir_l0rp = "/dados/L0_LANDSAT8/L0Rp/".$ano_mes;
system("cd $dir_l0rp; rm -rf $passagem;");
//echo "cd $dir_l0rp; rm -rf $passagem;";

// Arquivo L1T //
$dir_l1t = "/dados/L1T_WORK/".$ano_mes;
system("cd $dir_l1t; rm -rf $passagem;");
//echo "cd $dir_l1t; rm -rf $passagem;";

// Recorta o nome da passagem //
$prefixo = substr($passagem, 0, 6);
$sufixo = substr($passagem, 12, 12);
$passagem_remover = $prefixo."*".$sufixo;

// Arquivo L0R_Temp //
$dir_temp = "/dados/L0R_TEMP";
system("cd $dir_temp; rm -rf $passagem_remover;");
//--echo "cd $dir_temp; rm -rf $passagem_remover;;";

// Arquivo L0R_Temp //
$dir_work = "/dados/L0R_WORK";
system("cd $dir_work; rm -rf $passagem_remover;");
//--echo "cd $dir_work; rm -rf $passagem_remover;;";

// Direcionando a pagina //
echo "
	<script type='text/javascript'>
		window.location.href = 'listaPassagensProcessadas.php?ano_mes=$ano_mes&passagem=vazio';
	</script>
";

?>
