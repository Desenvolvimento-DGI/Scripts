<?php
/*
Pagina que gera os arquivos ODL 
autor: Jose Neto
data: 03/2015
*/

include("ingestClass.php");
$_METODO = new INGESTClass();

// recebe os parametros //
$ano_mes = $_REQUEST['ano_mes'];
$passagem = $_REQUEST['passagem'];
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
// 1.10 - Cria a pasta onde sera armazenado os arquivos ODL //
$dir_ODL = "/dados/JPF/";
//system("cd $dir_ODL; mkdir ${passagem}_teste");
$dir_ODL_final = $dir_ODL.$passagem."_teste";

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
	// 2.3.2 - Abrindo o arquivo e alterando os valores pre-definidos //
	// abre o arquivo para ser gravado //
	$arquivo_ODL = fopen("${nome_gerar_arquivo_ODL}.odl", "a");
	// Abre o TEMPLATE do Banco de Dados para gerar o arquivo ODL//	
	$lista_arquivo_ODL_BD = $_METODO->buscaTemplateODL_BD();
	// Lista os dados do Tamplate //
	while($_LINHA_Template = mysql_fetch_array($lista_arquivo_ODL_BD))
	{
		
		// 2.3.2.1 - Altera o CPF_FILENAME //
		$cpf_gravar = $_LINHA_Template["linha_07"].'"'.$CPF.'"';
		
		fwrite($_LINHA_Template["linha_01"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_02"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_03"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_04"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_05"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_06"], $arquivo_ODL);
		fwrite($cpf_gravar, $arquivo_ODL);
		fwrite($_LINHA_Template["linha_08"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_09"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_10"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_10"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_11"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_12"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_13"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_14"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_15"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_16"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_17"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_18"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_19"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_20"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_21"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_22"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_23"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_24"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_25"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_26"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_27"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_28"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_29"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_30"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_31"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_32"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_33"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_34"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_35"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_36"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_37"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_38"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_39"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_40"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_41"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_42"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_43"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_44"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_45"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_46"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_47"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_48"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_49"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_50"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_51"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_52"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_53"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_54"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_55"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_56"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_57"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_58"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_59"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_60"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_61"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_62"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_63"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_64"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_65"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_66"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_67"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_68"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_69"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_70"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_71"], $arquivo_ODL);
		fwrite($_LINHA_Template["linha_72"], $arquivo_ODL);
		
		// 2.3.2.1 - Altera o CPF_FILENAME //
		$find_CPF="CPF_FILENAME";
		$pos_CPF = strpos($linha_ODL, $find_CPF);
		if ( $pos_CPF !== false )
		{
			$partes_linha_CPF = explode("=", $linha_ODL);
			$cpf_gravar = $partes_linha_CPF[0].' = '.'"'.$CPF.'"';
			// Escreve no arquivo ODL //
			fwrite($arquivo_ODL, $cpf_gravar);
		}
		// 2.3.2.2 - Altera o INPUT_ID //
		$find_INPUT_ID="INPUT_ID";
		$pos_INPUT_ID = strpos($linha_ODL, $find_INPUT_ID);
		if ( $pos_INPUT_ID !== false )
		{
			$partes_linha_INPUT_ID = explode("=", $linha_ODL);
			$input_id_gravar = $partes_linha_INPUT_ID[0].' = '.'"'.$INPUT_ID.'"';
			// Escreve no arquivo ODL //
			fwrite($arquivo_ODL, $input_id_gravar);
		}
		// 2.3.2.3 - Altera o INPUT_ID //
		$find_INPUT_PATH="INPUT_PATH";
		$pos_INPUT_PATH = strpos($linha_ODL, $find_INPUT_PATH);
		if ( $pos_INPUT_PATH !== false )
		{
			$partes_linha_INPUT_PATH = explode("=", $linha_ODL);
			$input_path_gravar = $partes_linha_INPUT_PATH[0].' = '.'"'.$INPUT_PATH.'"';
			// Escreve no arquivo ODL //
			fwrite($arquivo_ODL, $input_path_gravar);
		}
		// 2.3.2.4 - Altera o L0R_INTERVAL_ID //
		$find_L0R_INTERVAL_ID="L0R_INTERVAL_ID";
		$pos_INTERVAL_ID = strpos($linha_ODL, $find_L0R_INTERVAL_ID);
		if ( $pos_INTERVAL_ID !== false )
		{
			$partes_linha_L0R_INTERVAL_ID = explode("=", $linha_ODL);
			$l0r_interval_id_gravar = $partes_linha_L0R_INTERVAL_ID[0].' = '.'"'.$L0R_INTERVAL_ID.'"';
			// Escreve no arquivo ODL //
			fwrite($arquivo_ODL, $l0r_interval_id_gravar);
		}
		// 2.3.2.5 - Altera o L0R_OUTPUT_PATH //
		$find_L0R_OUTPUT_PATH="L0R_OUTPUT_PATH";
		$pos_OUTPUT_PATH = strpos($linha_ODL, $find_L0R_OUTPUT_PATH);
		if ( $pos_OUTPUT_PATH !== false )
		{
			$partes_linha_L0R_OUTPUT_PATH = explode("=", $linha_ODL);
			$l0r_output_path_gravar = $partes_linha_L0R_OUTPUT_PATH[0].' = '.'"'.$L0R_OUTPUT_PATH.'"';
			// Escreve no arquivo ODL //
			fwrite($arquivo_ODL, $l0r_output_path_gravar);
		}
		// 2.3.2.6 - Altera o L0R_TEMP_PATH //
		$find_L0R_TEMP_PATH="L0R_TEMP_PATH";
		$pos_TEMP_PATH = strpos($linha_ODL, $find_L0R_TEMP_PATH);
		if ( $pos_TEMP_PATH !== false )
		{
			$partes_linha_L0R_TEMP_PATH = explode("=", $linha_ODL);
			$l0r_temp_path_gravar = $partes_linha_L0R_TEMP_PATH[0].' = '.'"'.$L0R_TEMP_PATH_ODL.'"';
			// Escreve no arquivo ODL //
			fwrite($arquivo_ODL, $l0r_temp_path_gravar);
		}
		// 2.3.2.7 - Altera o L0R_WORK_PATH //
		$find_L0R_WORK_PATH="L0R_WORK_PATH";
		$pos_WORK_PATH = strpos($linha_ODL, $find_L0R_WORK_PATH);
		if ( $pos_WORK_PATH !== false )
		{
			$partes_linha_L0R_WORK_PATH = explode("=", $linha_ODL);
			$l0r_work_path_gravar = $partes_linha_L0R_WORK_PATH[0].' = '.'"'.$L0R_WORK_PATH_ODL.'"';
			// Escreve no arquivo ODL //
			fwrite($arquivo_ODL, $l0r_work_path_gravar);
		}
		
 		if ( $pos !== true )
		{
			// Escreve no arquivo ODL //
			fwrite($arquivo_ODL, $linha_ODL);
		}
		
		
	}
	
	/*
	$template_ODL = $_METODO->buscaTemplateODL($nome_gerar_arquivo_ODL);
	// 2.3.2.2 - Funcao que substitui as tags marcadas no template //
	// cria o array com as tags a serem substituidas //
	$arr_Tags_ODL = array(
		'CPF_FILENAME'=>$CPF,
		'INPUT_ID'=>$INPUT_ID,
		'INPUT_PATH'=>$INPUT_PATH,
		'L0R_INTERVAL_ID'=>$L0R_INTERVAL_ID,
		'L0R_OUTPUT_PATH'=>$L0R_OUTPUT_PATH,
		'L0R_TEMP_PATH'=>$L0R_TEMP_PATH_ODL,
		'L0R_WORK_PATH'=>$L0R_WORK_PATH_ODL
	);
	
	/*foreach ($arr_Tags_ODL as $k => $v) {
   	 echo "\$a[$k] => $v.\n<br />";
	}
	$_METODO->substituiTagsTemplateODL($template_ODL, $nome_gerar_arquivo_ODL, $arr_Tags_ODL);
	
	*/
	
	
	break;
	// INPUT_ID = "LO80020580762015090CUB00" // OK
	// L0R_INTERVAL_ID = "LO80020582015090CUB00" //
    // L0R_OUTPUT_PATH = "/L0_LANDSAT8/L0Ra/2015_03/LO80020580762015090CUB00/" //
    // L0R_TEMP_PATH = "/dados/L0R_TEMP/LO80020582015090CUB00" //
    // L0R_WORK_PATH = "/dados/L0R_WORK/LO80020582015090CUB00" //
}










?>