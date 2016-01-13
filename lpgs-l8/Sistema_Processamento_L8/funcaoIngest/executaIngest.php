<?php
// inicializando a sessao //
session_start();
/*
Pagina que executa a funcao INGEST utilizando os arquivos ODL 
autor Jose Neto
data 04/2015
*/
error_reporting(E_ALL);
include("ingestClass.php");
$_METODO = new INGESTClass();

// recebe os parametros //
$valor_inicial_loop = $_REQUEST['valor_inicial'];
$valor_final_loop = $_REQUEST['valor_final'];
$dir_arquivo_ODL = $_REQUEST['dir_ODL'];
$passagem = $_REQUEST['passagem'];
$ano_mes = $_REQUEST['ano_mes'];

//echo $valor_inicial_loop."-".$valor_final_loop."-".$dir_arquivo_ODL."-".$passagem."-".$ano_mes;

// 1 - Inicio da funcao //

// 1.1 - Cria a ordem de serviço do processo a ser inicado //
$dir_ordem_servico  = "/dados/htdocs/Sistema_Processamento_L8/ordem_servico";
// Cria o arquivo dq ordem de servico //
$nome_ordem = "ordem_".$passagem."_".$ano_mes;
// Verifica se existe a ordem e apaga se existir //
system("cd ${dir_ordem_servico}; rm ordem_${passagem}_${ano_mes}");
system("cd ${dir_ordem_servico}; touch ordem_${passagem}_${ano_mes}");
// abre o arquivo para ser gravado //
$caminho_arquivo_gravar = $dir_ordem_servico."/ordem_".$passagem."_".$ano_mes;
$arquivo_ORDEM_gravar = fopen("$caminho_arquivo_gravar", "a");

// 1.2 - gera a lista dos arquivos no diretorio para serem executados //
system("ls $dir_arquivo_ODL > lista_dispara_INGEST_${passagem}");
// Le a lista de arquivos //
$_ARQUIVO_PASSAGENS_ODL = "lista_dispara_INGEST_${passagem}";
$lista_ODL = fopen ("$_ARQUIVO_PASSAGENS_ODL","r");

while (!feof ($lista_ODL)) 
{
	// Separa o nome do arquivo ODL //
	$arquivo_ODL = fgets($lista_ODL,4096);
	
	// Verifica se  aqruivo nao esta vazio //
	if ( $arquivo_ODL )
	{
		$parametro_executar_ODL = $dir_arquivo_ODL."/".$arquivo_ODL;
		// Gravando //
		fwrite($arquivo_ORDEM_gravar, $parametro_executar_ODL);		
	}
}
# fecha o arquivo da ordem de servico #
fclose($arquivo_ORDEM_gravar);
# apaga o arquivo temporario com a lista de arquivos ODL //
system("rm lista_dispara_INGEST_${passagem}");

// 3 - Grava no banco de dados o processo iniciado //
// Gera um caracter aleatorio com numero e letras para diferenciar as passagens //
$chave = $nome_ordem.date("H:i:s");
$caracter_chave = substr(md5($chave),0,24); 
$_usuario = $_SESSION['login'];
$_passagem = $passagem;
$_data_inicial = date("d/m/Y H:i:s");
$_status = "EXECUTANDO";
// 3.1 -  Metodo que grava a informacao no banco de dados - Tabela processo_ingest_L8 //
$_METODO->gravaInicioProcessoIngestL8($_usuario, $_passagem, $_data_inicial, $_status, $caracter_chave);

// 4 - Executa o processo de INGEST //
$comando = "/bin/bash; /dados/htdocs/Sistema_Processamento_L8/funcaoIngest/recebe_novas_ordens_INGEST.sh ".$nome_ordem." ".$caracter_chave." ".$ano_mes." > /dev/null 2>&1 &";
exec($comando);
//--echo $comando;

//--//shell_exec($comando." > logSaida.log > /dev/null &");


// 5 - Direcionando a pagina //
echo "
	<script type='text/javascript'>
		window.location.href = 'paginaIngest.php?ano_mes=$ano_mes';
	</script>
";

?>
