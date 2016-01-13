<?php
// inicializando a sessao //
session_start();
/*
Pagina que executa a funcao INGEST utilizando os arquivos ODL 
autor Jose Neto
data 04/2015
*/
error_reporting(E_ALL);
include("renomearClass.php");
$_METODO = new RENOMEARClass();

// Recebe os parametros para renomear //
$ano_mes = $_POST['ano_mes'];
$passagem = $_POST['passagem'];
$xml = $_POST['xml'];

// 1- Grava o inicio do processo no banco de dados //
// 1.1- Gera um caracter aleatorio com numero e letras para diferenciar as passagens //
$chave = $passagem.date("H:i:s");
$caracter_chave = substr(md5($chave),0,24);
$_usuario = $_SESSION['login'];
$_passagem = $passagem;
$_data_inicial = date("d/m/Y H:i:s");
$_status = "EXECUTANDO";
// 1.2 -  Metodo que grava a informacao no banco de dados - Tabela processo_renomear_L8 //
$_METODO->gravaInicioProcessoRenomearL8($_usuario, $_passagem, $_data_inicial, $_status, $caracter_chave);

// 1.3 -  Metodo que grava as informacao no banco de dados - Tabela dados_renomear //
$_METODO->gravaDadosProcessoRenomearL8($_passagem, $ano_mes, $caracter_chave, $xml);

// 1.4- Grava no banco de dados as informacoes do processo renomear - Tabela processo_renomear_L8 //
// Executa o script responsavel por renomear #
$parametro_de_renomear = $ano_mes." ".$passagem." ".$xml." ".$caracter_chave;
$comando = "/bin/bash; /dados/htdocs/Sistema_Processamento_L8/funcaoRenomeia/executa_funcao_renomear_L8.sh ${parametro_de_renomear} > /dev/null 2>&1 &";
//--$comando = "/home/cdsr/bin/IDFGenerator.pl /dados/htdocs/Sistema_Processamento_L8/funcaoRenomeia/LO82170620762015092CUB00 LO82170620762015092CUB00 /L0_LANDSAT8/AncillaryFiles/STS/506_MOE_STS_2015092000000_2015095000000_2015090211120_OPS_CUB.xml > logIDF01";
//--echo $comando;
exec($comando);


// 2 - Direcionando a pagina //
echo "
	<script type='text/javascript'>
		window.location.href = 'paginaRenomear.php?ano_mes=$ano_mes';
	</script>
";

?>
