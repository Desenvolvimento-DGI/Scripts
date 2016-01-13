<?php
// inicializando a sessao //
session_start();
/*
Pagina que executa o comando SUBSETTER 
autor Jose Neto
data 03/2015

# Descricao: o processo funciona da seguinte forma:
1- le-se a pasta L0Ra do arquivo escolhido
2- Cria-se as pastas no mesmo modelo sem nenhum conteudo na area L0Rp
3- executa o SUBSETTER
*/

include("subseterClass.php");
$_METODO = new SUBSETERClass();

// recebe os parametros //
$ano_mes = $_REQUEST['ano_mes'];
$passagem = $_REQUEST['passagem'];
//--echo $lista_ano_mes."<br />";

// verifica se o nome da passagem tem o tamanho certo //
$tamanho_nome_passagem = strlen($passagem);
if ( $tamanho_nome_passagem != 24 )
{
	echo "passagem com erro";
}

// Funcao que cria a pasta base, a que contem o nome completo da passagem //
// 1- cria a pasta base //
$dir_L0Rp = "/L0_LANDSAT8/L0Rp/".$ano_mes;
system("cd $dir_L0Rp; rm -rf $passagem");
system("cd $dir_L0Rp; mkdir $passagem");
$dir_L0Rp_completa = $dir_L0Rp."/".$passagem;

// 1.1- lista de pastas dentro do L0Ra //
$dir_L0Ra = "/L0_LANDSAT8/L0Ra/".$ano_mes;
$dir_L0Ra_completo = $dir_L0Ra."/".$passagem;
$nome_arquivo_da_lista = $passagem."_lista_pastas_L0Ra.txt";
system("ls $dir_L0Ra_completo > ${nome_arquivo_da_lista}");
// 1.2- Le a lista de pastas //
$_PONTOS_DA_PASSAGEM = $nome_arquivo_da_lista;
$lista_pastas_passagem = fopen ("$_PONTOS_DA_PASSAGEM","r");
while (!feof ($lista_pastas_passagem)) 
{
	// Separa o nome do arquivos //
	$pasta_L0Ra = fgets($lista_pastas_passagem,4096);
	// Verifica se  aqruivo nao esta vazio //
	if ( $pasta_L0Ra )
	{
		// para cada valor da lista, deve-se criar a pasta no diretorio L0Rp //
		system("cd $dir_L0Rp_completa; mkdir $pasta_L0Ra");
		//echo $pasta_L0Ra."<br />";
	}
}
sleep(5);
// Diretorio da ordem de serviço do processo SUBSETTER //
$dir_ordem_servico  = "/dados/htdocs/Sistema_Processamento_L8/ordem_servico";
// 1.3- Cria o arquivo dq ordem de servico //
$nome_ordem = "ordem_subsetter_".$passagem."_".$ano_mes;
// Verifica se existe a ordem e apaga se existir //
system("cd ${dir_ordem_servico}; rm ${nome_ordem}");
system("cd ${dir_ordem_servico}; touch ${nome_ordem}");
// abre o arquivo para ser gravado //
$caminho_arquivo_gravar = $dir_ordem_servico."/".$nome_ordem;
$arquivo_ORDEM_gravar = fopen("$caminho_arquivo_gravar", "a");

// 2- Dispara os processo de SUBSETTER //
// 2.1- Gera a ordem com a lista de pontos da passagem //
// Le a lista de pastas //
$_PONTOS_DA_PASSAGEM = $nome_arquivo_da_lista;
$lista_pastas_passagem = fopen ("$_PONTOS_DA_PASSAGEM","r");
while (!feof ($lista_pastas_passagem)) 
{
	// Separa o nome do arquivo ODL //
	$pasta_L0Ra = fgets($lista_pastas_passagem,4096);
	// Verifica se  aqruivo nao esta vazio //
	if ( $pasta_L0Ra )
	{
		// Gravando //
		fwrite($arquivo_ORDEM_gravar, $pasta_L0Ra);	
	}
}
// fecha o arquivo da ordem de servico //
fclose($arquivo_ORDEM_gravar);

// Apaga o arquivo da lista //
system("rm ${nome_arquivo_da_lista}");

// 3- Grava o inicio no banco de dados //
// Gera um caracter aleatorio com numero e letras para diferenciar as passagens //
$chave = $nome_ordem.date("H:i:s");
$caracter_chave = substr(md5($chave),0,24);
$_usuario = $_SESSION['login'];
$_passagem = $passagem;
$_data_inicial = date("d/m/Y H:i:s");
$_status = "EXECUTANDO";
// 3.1 -  Metodo que grava a informacao no banco de dados - Tabela processo_ingest_L8 //
$_METODO->gravaInicioProcessoSubsetterL8($_usuario, $_passagem, $_data_inicial, $_status, $caracter_chave);

// 4- Dispara o processo de SUBSETTER atraves de script  //
// 4.1- parametro de execucao do SUBSETTER //
$parametro_SUBSETTER = $ano_mes." ".$passagem." ".$nome_ordem." ".$caracter_chave;

$comando = "/bin/bash; /dados/htdocs/Sistema_Processamento_L8/funcaoSubsetter/recebe_novas_ordens_SUBSETTER.sh ".$parametro_SUBSETTER." > /dev/null 2>&1 &";
//$comando = "/bin/bash; /dados/htdocs/Sistema_Processamento_L8/funcaoSubsetter/recebe_novas_ordens_SUBSETTER.sh ".$parametro_SUBSETTER;
exec($comando);
//--echo $comando;
// rediereciona a pagina //
echo "
	<script type='text/javascript'>
		window.location.href = 'paginaSubsetter.php?ano_mes=$ano_mes';
	</script>
";
?>