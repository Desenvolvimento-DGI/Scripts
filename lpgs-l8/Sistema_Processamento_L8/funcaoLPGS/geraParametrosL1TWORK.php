<?php
// inicializando a sessao //
session_start();
/*
Pagina que inicia o processo de LPGS-L1T
autor Jose Neto
data 05/2015

# Descricao: o processo funciona da seguinte forma:
1- le-se a lista de arquivos da passagem - pontos 
2- Cria-se as pastas no correto com o parametro_files alterado
3- redireciona para a pagina que ira disparar o processo 
*/

include("lpgsClass.php");
$_METODO = new LPGSClass();

// recebe os parametros //
$ano_mes = $_REQUEST['ano_mes'];
$passagem = $_REQUEST['passagem'];
$cpf = $_REQUEST['cpf'];
$bpf_oli = $_REQUEST['bpf_oli'];
$bpf_tirs = $_REQUEST['bpf_tirs'];
//--echo $passagem."<br />";

// Variaveis que armazenam o diretorio do CPF e BPF //
$CPF = "/L0_LANDSAT8/AncillaryFiles/CPF/".$cpf;
$BPF_OLI = "/L0_LANDSAT8/AncillaryFiles/BPF/".$bpf_oli;
$BPF_TIRS = "/L0_LANDSAT8/AncillaryFiles/BPF/".$bpf_tirs;
$CPF."-".$BPF_OLI."-".$BPF_TIRS;
//--echo $CPF."<br />";

// 1- pega os pontos que a passagem possui //
$dir_base_L0Rp = "/dados/L0_LANDSAT8/L0Rp";
$dir_passagem = $dir_base_L0Rp."/".$ano_mes."/".$passagem;
// 1.1 - Cria a pasta na area L1T_WORK //
$dir_L1T_base = "/dados/L1T_WORK";
$dir_L1T_completo = $dir_L1T_base."/".$ano_mes."/".$passagem;
//--echo $dir_L1T_completo."<br />";
system("mkdir -p ${dir_L1T_completo}");
// 1.1 - gera a lista dos pontos da passagem //
system("ls ${dir_passagem} > lista_pontos_Passagem.txt");
// 1.2 - le a lista com os pontos //
$_LISTA_PONTOS = "lista_pontos_Passagem.txt";
$lista_dos_pontos = fopen ("$_LISTA_PONTOS","r");

// cria arquivo da ordem de servico a ser executado //
$nome_ordem_servico = "ordem_LPGS_".$passagem;
$dir_ordem_base = "/dados/htdocs/Sistema_Processamento_L8/ordem_servico";
$dir_e_nome_ordem_servico = $dir_ordem_base."/".$nome_ordem_servico;
// antes de criar verifica se existe e apaga //
system("rm $dir_e_nome_ordem_servico");
// cria a ordem para a passagem //
system("touch $dir_e_nome_ordem_servico");
// abre a ordem de servico para ser gravada //
$gravar_info_ordem_servico = fopen("${dir_e_nome_ordem_servico}", "a");

while (!feof ($lista_dos_pontos)) 
{
	// Para cada ponto gera o conjunto de parametros necessarios para o processamento L1T //
	$ponto_da_passagem = fgets($lista_dos_pontos,4096);
	// verifica se o nome da passagem esta correto //
	$verifica = substr($ponto_da_passagem, 0, 2);
	if ( $verifica == "LO" or $verifica == "LC"  )
	{
		// 1.2.1 - separa a base e ponto da passagem //
		$base = substr($ponto_da_passagem, 3, 3);
		$base_ordem = $base;
		$ponto = substr($ponto_da_passagem, 6, 3);
		//--echo $ponto."<br />";
		$ponto_ondem = $ponto;
		// 1.2.2 - valida base e o ponto //
		$verifica_base = substr($base, 0, 2);
		if ( $verifica_base == '00' )
		{
			$base = substr($base, 2, 1);
		}
		$verifica_base = substr($base, 0, 1);
		if ( $verifica_base == '0' )
		{
			$base = substr($base, 1, 2);
		}
		//--//
		$verifica_ponto = substr($ponto, 0, 1);
		if ( $verifica_ponto == '0' )
		{
			$ponto = substr($ponto, 1, 2);
		}
		// 1.2.2 - para cada base e ponto e necessario descobrir a Zona //
		//--$zona = system("egrep '^${base}\|${ponto}\|' PATH_ROW_TO_UTM_ZONE.ldr");
		$zona = system("grep ^'${base}|${ponto}|' PATH_ROW_TO_UTM_ZONE.ldr");
		//--echo "<br />";
		//--echo "<br />";
		//--echo "grep ^'${base}|${ponto}|' PATH_ROW_TO_UTM_ZONE.ldr<br />";
		
		$partes_zona = explode("|", $zona);
		$zona = $partes_zona[2];
		//--echo "<br />";
		print_r($partes_zona);
		print_r($zona);
		//--echo "<br />";
		//--echo "<hr />";
		// 1.2.3 - Cria a pasta com o conteudo para cada ponto da passagem //
		$ponto_da_passagem = trim($ponto_da_passagem);
		$dir_ponto_passagem_completo = $dir_L1T_completo."/".$ponto_da_passagem;
		$dir_ponto_passagem_completo_L0Rp=$dir_passagem."/".$ponto_da_passagem;
		//--echo "mkdir -p $dir_ponto_passagem_completo";
		system("mkdir -p $dir_ponto_passagem_completo");
		// 1.2.3 - Copia o conteudo da pasta param_files para o nome da pasta //
		system("cp -rf param_files/* ${dir_ponto_passagem_completo}");
		// 1.2.4 - Cria o arquivo setup_work //
		// cria o arquivo //
		$nome_arquivo_setup_work = $dir_ponto_passagem_completo."/setup_work_order.odl";
		// antes de criar verifica se existe e apaga o existente //
		system("rm $nome_arquivo_setup_work");
		//--echo "touch $nome_arquivo_setup_work";
		system("touch $nome_arquivo_setup_work");
		// abre o arquivo para ser gravado setup work //
		$gravar_arquivo_SETUP_WORK = fopen("${nome_arquivo_setup_work}", "a"); 
		
		// lista os dados do template //
		$template_SETUP_WORK = $_METODO->buscaTemplateSetupWork();
		while($_LINHA_Template_SETUP = mysql_fetch_array($template_SETUP_WORK))
		{
			
			// variaveis para o arquivo setup_work //
			$L0R_FILENAME = $_LINHA_Template_SETUP["linha_03"].'"'.$dir_ponto_passagem_completo_L0Rp."/".$ponto_da_passagem.'"';
			$CAL_PARM_FILENAME = $_LINHA_Template_SETUP["linha_04"].'"'.$CPF.'"';
			$BIAS_PARM_FILENAME_OLI = $_LINHA_Template_SETUP["linha_05"].'"'.$BPF_OLI.'"';
			$BIAS_PARM_FILENAME_TIRS = $_LINHA_Template_SETUP["linha_06"].'"'.$BPF_TIRS.'"';
			$UTM_ZONE = $_LINHA_Template_SETUP["linha_12"]."".$zona;
			
			// Gravando //
			fwrite($gravar_arquivo_SETUP_WORK, $_LINHA_Template_SETUP["linha_01"]."\n");
			fwrite($gravar_arquivo_SETUP_WORK, $_LINHA_Template_SETUP["linha_02"]."\n");
			fwrite($gravar_arquivo_SETUP_WORK, $L0R_FILENAME."\n");
			fwrite($gravar_arquivo_SETUP_WORK, $CAL_PARM_FILENAME."\n");
			fwrite($gravar_arquivo_SETUP_WORK, $BIAS_PARM_FILENAME_OLI."\n");
			fwrite($gravar_arquivo_SETUP_WORK, $BIAS_PARM_FILENAME_TIRS."\n");
			fwrite($gravar_arquivo_SETUP_WORK, $_LINHA_Template_SETUP["linha_07"]."\n");
			fwrite($gravar_arquivo_SETUP_WORK, $_LINHA_Template_SETUP["linha_08"]."\n");
			fwrite($gravar_arquivo_SETUP_WORK, $_LINHA_Template_SETUP["linha_09"]."\n");
			fwrite($gravar_arquivo_SETUP_WORK, $_LINHA_Template_SETUP["linha_10"]."\n");
			fwrite($gravar_arquivo_SETUP_WORK, $_LINHA_Template_SETUP["linha_11"]."\n");
			fwrite($gravar_arquivo_SETUP_WORK, $UTM_ZONE."\n");
			fwrite($gravar_arquivo_SETUP_WORK, $_LINHA_Template_SETUP["linha_13"]."\n");
			fwrite($gravar_arquivo_SETUP_WORK, $_LINHA_Template_SETUP["linha_14"]."\n");
			// Fecha o arquivo //
			fclose($gravar_arquivo_SETUP_WORK);
			
		}
		
		// Variaveis para a ordem de servico //
		$linha_para_ordem_servico = $ponto_da_passagem.";".$dir_ponto_passagem_completo.";".$base_ordem.";".$ponto_ondem.";".$zona;
		// Grava a ordem de servico para executar a funcao //
		fwrite($gravar_info_ordem_servico, $linha_para_ordem_servico."\n");
		
	}	
}

// Fecha o arquivo da ordem de servico //
fclose($gravar_info_ordem_servico);

// Parametro para que a proxima pagina utilizara para executar a funcao LPGS L1T //
$parametro_lpgs = "ano_mes=".$ano_mes."&passagem=".$passagem."&ordem_servico=".$nome_ordem_servico;

// rediereciona a pagina //
echo "
	<script type='text/javascript'>
		window.location.href = 'executaL1TWORK.php?$parametro_lpgs';
	</script>
";

?>
