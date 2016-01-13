<?php
/*
Pagina que gera os arquivos ODL 
autor Jose Neto
data 03/2015
*/

include("ingestClass.php");
$_METODO = new INGESTClass();

// recebe os parametros //
$ano_mes = $_REQUEST['ano_mes'];
$passagem = $_REQUEST['passagem'];
$cpf = $_REQUEST['cpf'];
//--echo $lista_ano_mes."<br />";

// Funcao que gera os arquivos ODL //
// 1- separa as varaveis para gerar o ODL //

// 1.1 - Separa o numero de pontos //
// verifica se o nome da passagem tem o tamanho certo //
$tamanho_nome_passagem = strlen($passagem);
if ( $tamanho_nome_passagem != 24 )
{
	echo "passagem com erro";
}
// corta a string e pega a base, ponto inicial e ponto final // LO80010570812015083CUB00
$base = substr($passagem, 3, 3);
$ponto_inicial = substr($passagem, 6, 3);
$ponto_final = substr($passagem, 9, 3);
//--echo $base."-".$ponto_inicial."-".$ponto_final;
// 1.2 - Separa o ano e mes //
$partes_ano_mes = explode("_", $ano_mes);
$ano = $partes_ano_mes[0];
$mes = $partes_ano_mes[1];
// 1.3 - Valida e captura o nome da variavel CPF //
// busca a ultima cadastrada na area //
$CPF = $_METODO->buscaCPF();
// 1.4 - Variavel que contem o nome do INPUT_ID //
$INPUT_ID = $passagem;
// 1.5 - Variavel que contem o nome do INPUT_PATH //
$INPUT_PATH = "/L0_LANDSAT8/MISSION_DATA/".$ano_mes;
// 1.5 - Variavel que contem o nome do L0R_OUTPUT_PATH //
$L0R_OUTPUT_PATH = "/L0_LANDSAT8/L0Ra/".$ano_mes."/".$passagem ;
// 1.6 - Variavel que contem o nome do L0R_TEMP_PATH //
$L0R_TEMP_PATH = "/dados/L0R_TEMP/";
// 1.7 - Variavel que contem o nome do L0R_WORK_PATH //
$L0R_WORK_PATH = "/dados/L0R_WORK/";
// 1.8 - pega o valor do ponto inicial e final e gera a sequencia de numeros que serao usados para gerar os arquivos ODL //
// valor no qual se iniciara o loop //
$teste_valor_ponto_inicial = substr($ponto_inicial, 0, 1);
if ( $teste_valor_ponto_inicial == 0 )
{
	$valor_inicial_loop = substr($ponto_inicial, 1, 2);
}	else	{
		if ( $teste_valor_ponto_inicial >= 1 )
		{
			$valor_inicial_loop = $ponto_inicial;
		}
}
// valor no qual se encerrara o loop //
$teste_valor_ponto_final = substr($ponto_final, 0, 1);
if ( $teste_valor_ponto_final == 0 )
{
	$valor_final_loop = substr($ponto_final, 1, 2);
}	else	{
		if ( $teste_valor_ponto_final >= 1 )
		{
			$valor_final_loop = $ponto_final;
		}
}
// 1.9 - Variaveis que contem partes do nome da passagem //
$parte_passagem_prefixo =  substr($passagem, 0, 3);
$parte_passagem_sufixo =  substr($passagem, 12, 21);

// 2 - Cria os arquivo ODL apartir das variaveis anteriormente capturadas //
// 2.1 - Loop de todos os ponto //
for ($ponto = $valor_inicial_loop; $ponto <= $valor_final_loop; $ponto++) 
{
	// 2.2 - variaveis que irao ser inseridas no template ODL //
	if ( $ponto < 100 )
	{
		$ponto_odl = "0".$ponto;
	}	else	{
		$ponto_odl = "0".$ponto;
	}
	// 2.2.1 - Variavel que contem o valor do L0R_INTERVAL_ID //
	$L0R_INTERVAL_ID = $parte_passagem_prefixo.$base.$ponto_odl.$parte_passagem_sufixo;
	$nome_gerar_arquivo_ODL = $L0R_INTERVAL_ID;
	// 2.2.2 - Alteral o valor da variavel que contem o valor do L0R_TEMP_PATH //
	$L0R_TEMP_PATH_ODL = $L0R_TEMP_PATH.$L0R_INTERVAL_ID;
	// 2.2.2 - Alteral o valor da variavel que contem o valor do L0R_WORK_PATH //
	$L0R_WORK_PATH_ODL = $L0R_WORK_PATH.$L0R_INTERVAL_ID;
	
	// 2.3 - Variaveis prontas, agora cria o arquivo ODL para cada ponto //
	// 2.3.1 - Copia o template com o nome do ODL - base/ponto //
	system("touch ${nome_gerar_arquivo_ODL}.odl ");
	// 2.3.2 - Abrindo o tempalet no banco de dados e alterando os valores pre-definidos //
	// abre o arquivo para ser gravado //
	$arquivo_ODL = fopen("${nome_gerar_arquivo_ODL}.odl", "a");
	// Abre o TEMPLATE do Banco de Dados para gerar o arquivo ODL//	
	$lista_arquivo_ODL_BD = $_METODO->buscaTemplateODL_BD();
	// Lista os dados do Tamplate //
	while($_LINHA_Template = mysql_fetch_array($lista_arquivo_ODL_BD))
	{
		// 2.3.2.1 - Altera o CPF_FILENAME //
		$cpf_gravar = $_LINHA_Template["linha_07"].' = '.'"'.$CPF.'"';
		// 2.3.2.2 - Altera o INPUT_ID //
		$input_id_gravar = $_LINHA_Template["linha_13"].' = '.'"'.$INPUT_ID.'"';
		// 2.3.2.3 - Altera o INPUT_ID //
		$input_path_gravar = $_LINHA_Template["linha_15"].' = '.'"'.$INPUT_PATH.'"';
		// 2.3.2.4 - Altera o L0R_INTERVAL_ID //
		$l0r_interval_id_gravar = $_LINHA_Template["linha_17"].' = '.'"'.$L0R_INTERVAL_ID.'"';
		// 2.3.2.5 - Altera o L0R_OUTPUT_PATH //
		$l0r_output_path_gravar = $_LINHA_Template["linha_19"].' = '.'"'.$L0R_OUTPUT_PATH.'"';
		// 2.3.2.6 - Altera o L0R_TEMP_PATH //
		$l0r_temp_path_gravar = $_LINHA_Template["linha_21"].' = '.'"'.$L0R_TEMP_PATH_ODL.'"';
		// 2.3.2.7 - Altera o L0R_WORK_PATH //
		$l0r_work_path_gravar = $_LINHA_Template["linha_23"].' = '.'"'.$L0R_WORK_PATH_ODL.'"';
		
		// Gravando //
		fwrite($arquivo_ODL, $_LINHA_Template["linha_01"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_02"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_03"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_04"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_05"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_06"]."\n");
		fwrite($arquivo_ODL, $cpf_gravar."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_08"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_09"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_10"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_11"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_12"]."\n");
		fwrite($arquivo_ODL, $input_id_gravar."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_14"]."\n");
		fwrite($arquivo_ODL, $input_path_gravar."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_16"]."\n");
		fwrite($arquivo_ODL, $l0r_interval_id_gravar."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_18"]."\n");
		fwrite($arquivo_ODL, $l0r_output_path_gravar."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_20"]."\n");
		fwrite($arquivo_ODL, $l0r_temp_path_gravar."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_22"]."\n");
		fwrite($arquivo_ODL, $l0r_work_path_gravar."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_24"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_25"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_26"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_27"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_28"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_29"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_30"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_31"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_32"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_33"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_34"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_35"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_36"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_37"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_38"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_39"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_40"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_41"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_42"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_43"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_44"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_45"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_46"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_47"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_48"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_49"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_50"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_51"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_52"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_53"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_54"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_55"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_56"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_57"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_58"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_59"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_60"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_61"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_62"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_63"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_64"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_65"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_66"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_67"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_68"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_69"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_70"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_71"]."\n");
		fwrite($arquivo_ODL, $_LINHA_Template["linha_72"]."\n");
		fclose($arquivo_ODL);

	}
}

// 3 - Movendo os arquivos ODL para a pasta certa //
// 3.1 - Cria a pasta onde sera armazenado os arquivos ODL //
$dir_ODL = "/dados/JPF/";
system("cd $dir_ODL; mkdir ${passagem}_teste");
$dir_ODL_final = $dir_ODL.$passagem."_teste";
// 3.2 - Move os arquivo ODL //
system("mv LO8* $dir_ODL_final");

// 4 - Direcionna os dados para a pagina que ira executar o INGEST //
$parametro_url_INGEST = "valor_inicial=".$valor_inicial_loop."&valor_final=".$valor_final_loop."&dir_ODL=".$dir_ODL_final."&passagem=".$passagem."&ano_mes=".$ano_mes;
// 4.1 - Direcionando a pagina //
echo "
	<script type='text/javascript'>
		window.location.href = 'executaIngest.php?".$parametro_url_INGEST."';
	</script>
";
?>