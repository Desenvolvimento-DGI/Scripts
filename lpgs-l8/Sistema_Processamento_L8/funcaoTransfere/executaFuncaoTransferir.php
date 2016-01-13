<?php
// inicializando a sessao //
session_start();
/*
Pagina que executa a funcao Tranferir Passagem 
autor Jose Neto
data 04/2015

Descricao: O script apenas copia a passagem e a descompacta na area L1_LANDSAT-8 para que a Maquina GlobalStar possa ver os dados da passagem
e posteriormente possa executar a função que cadastra a passagem no Banco de Dados do Catalogo 
*/
//error_reporting(E_ALL);
include("transfereClass.php");
$_METODO = new TransfereClass();

// Recebe os parametros para Tranferir //
$ano_mes = $_POST['ano_mes'];
$passagem = $_POST['passagem'];

// 1 - Grava no banco de dados o processo iniciado //
// Gera um caracter aleatorio com numero e letras para diferenciar as passagens //
$chave = $passagem.date("H:i:s");
$caracter_chave = substr(md5($chave),0,24); 
$_usuario = $_SESSION['login'];
$_passagem = $passagem;
$_data_inicial = date("d/m/Y H:i:s");
$_status = "EXECUTANDO";
// 1.1 -  Metodo que grava a informacao no banco de dados - Tabela processo_ingest_L8 //
$_METODO->gravaInicioProcessoTransferir($_usuario, $_passagem, $_data_inicial, $_status, $caracter_chave);

// 2 - Executa o processo de Tranferencia //
$comando = "/bin/bash; /dados/htdocs/Sistema_Processamento_L8/funcaoTransfere/executa_Tranferir.sh ".$passagem." ".$ano_mes." ".$caracter_chave." > /dev/null 2>&1 &";
exec($comando);
//--echo $comando;

// 2 - Direcionando a pagina //
echo "
	<script type='text/javascript'>
		window.location.href = 'paginaTransferir.php?ano_mes=$ano_mes';
	</script>
";

?>
