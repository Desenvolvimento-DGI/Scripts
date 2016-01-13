<?php
// inicializando a sessao //
session_start();
/*
Pagina que executa a funcao LPGS L1T 
autor Jose Neto
data 04/2015
*/
error_reporting(E_ALL);
include("lpgsClass.php");
$_METODO = new LPGSClass();

// recebe os parametros //
$ordem_servico_executar = $_REQUEST['ordem_servico'];
$passagem = $_REQUEST['passagem'];
$ano_mes = $_REQUEST['ano_mes'];
// chave de controle unica //
$caracter_chave = substr(md5($passagem),0,24); 

// 1 -  Grava na tabela de controlde processos o inicio da funcao LPGS L1T //
$_usuario = $_SESSION['login'];
$_passagem = $passagem;
$_data_inicial = date("d/m/Y H:i:s");
$_status = "EXECUTANDO";
// 1.1 -  Metodo que grava a informacao no banco de dados - Tabela processo_ingest_L8 //
$_METODO->gravaInicioProcessoLPGSL1T($_usuario, $_passagem, $_data_inicial, $_status, $caracter_chave);

// 2 - Executa o processo de LPGS L1T //
$parametro_execucao_LPGS = $ano_mes." ".$passagem." ".$ordem_servico_executar." ".$caracter_chave;
//--$comando = "/bin/bash; /dados/htdocs/Sistema_Processamento_L8/funcaoLPGS/executa_ordem_funcao_LPGS.sh ".$parametro_execucao_LPGS." > /dev/null 2>&1 &";
$comando = "/dados/htdocs/Sistema_Processamento_L8/funcaoLPGS/executa_ordem_funcao_LPGS.sh ".$parametro_execucao_LPGS." > /dev/null 2>&1 &";
//$comando = "./teste_executa.csh ";
//--$comando = "/bin/bash; /dados/htdocs/Sistema_Processamento_L8/funcaoLPGS/executa_ordem_funcao_LPGS.sh ".$parametro_execucao_LPGS;
//system("./teste_executa.csh");
//--echo $comando."<br />";
shell_exec($comando);

// 5 - Direcionando a pagina //
echo "
	<script type='text/javascript'>
		window.location.href = 'paginaLPGS.php?ano_mes=$ano_mes';
	</script>
";

?>
