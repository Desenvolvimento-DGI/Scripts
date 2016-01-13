<?php
/*
Pagina que lista os dados para serem processados
autor: Jose Neto
data: 03/2015
*/

include("lpgsClass.php");
$_METODO = new LPGSClass();

// Classe das configuracoes //
include("../configuracaoClass.php");
configuracaoClass::_CSS_02();

// recebe os parametros //
$ano_mes = $_REQUEST['ano_mes'];


//--echo $lista_ano_mes."<br />";
?>
<div class="container">
	<div class="row" style="background-color:#FFF">
    <table>
        <form action="geraParametrosL1TWORK.php" method="post">
         <tr>
            <th colspan="2">SELECIONE OS DADOS PARA MOSTRAR AS PASSAGENS NA ÁREA L0_LANDSAT-8</th>
                        
         </tr>
         
         <tr>
            <td>
                ANO/MÊS: 
                <select name="ano_mes">
                    <?php
                    // Gera a lista de ano e mes na area L0_LANDSAT8 //
                    $lista_ano_mes = $_METODO->listaAnoMesL0();
                    $valores_ano_mes = explode(";", $lista_ano_mes);
                    //echo $valores_ano_mes[1];
                    $count = count($valores_ano_mes);
                    
                    if ( $ano_mes != 'vazio' )
                    {
                    ?>
                        <option value="<?php echo $ano_mes;?>"><?php echo $ano_mes;?></option>
                        <option value="vazio"></option>
                    <?php
                    }
                    for ($i = 0; $i < $count; $i++)
                    {	
                        if ( $valores_ano_mes[$i] )
                        {
                            $valor_ano_mes = trim($valores_ano_mes[$i]);
                            //-echo $valores_ano_mes[$i];
                    ?>
                            <option value="<?php echo $valor_ano_mes; ?>" onclick="document.location=('paginaLPGS.php?ano_mes=<?php echo $valor_ano_mes?>');">
                                <?php echo $valor_ano_mes; ?>
                            </option>
                    <?php
                        }
                    }
                    ?>
                </select>
            </td>
            </tr>
            <tr>
                <td>
                    PASSAGENS:
                    <select name="passagem" style="width:auto">
                    <?php
                    if ( $ano_mes == 'vazio' )
                    {
                    ?>
                        <option value="vazio">SELECIONE</option>
                    <?php
                    }	else	{
                        // gera lista dos dados dentro da pasta //
                        $lista_de_passagens = $_METODO->listaDadosL0Rp_PorAnoMes($ano_mes);
                        //--echo $lista_de_passagens;
                        $valores_passagens = explode(";", $lista_de_passagens);
                        //--
                        $valores_passagens[] = sort($valores_passagens);
						
                        $count = count($valores_passagens);
                        for ($j = 0; $j < $count; $j++)
                        {
							//--echo $valores_passagens[$j]."<br />";
							if ( $valores_passagens[$j] )
							{
								$valor_passagem_exibir = explode("-", $valores_passagens[$j]);
								//--$tamanho_nome_arquivo = strlen($valor_passagem_exibir[1]);
								if ( isset($valor_passagem_exibir[1]) )
								{
					?>
                               		<option value="<?php echo trim($valor_passagem_exibir[1]);?>"><?php echo trim($valor_passagem_exibir[1]);?></option>
                    <?php
								}
								
							}
                        }
                    }
                    ?>
                </select>
            </td>
        </tr>
        
        <tr>
            <td>
                CPF:
                <select name="cpf" style="width:auto">
                <?php
                if ( $ano_mes == 'vazio' )
                {
                ?>
                    <option value="vazio">SELECIONE</option>
                <?php
                }	else	{
                    // gera lista dos arquivos CPF dentro da pasta //
                    $lista_de_cpfs = $_METODO->listaArquivosCPF();
                    //--echo $lista_de_passagens;
                    $valores_cpf= explode(";", $lista_de_cpfs);
                    $count = count($valores_cpf);
                    for ($k = 0; $k < $count; $k++)
                    {
                        $verifica_cpf = trim(substr($valores_cpf[$k], 0, 2));
                        if ( $verifica_cpf == "L8" )
                        {
                    ?>
                            <option value="<?php echo trim($valores_cpf[$k]);?>"><?php echo trim($valores_cpf[$k]);?></option>
                    <?php
                        }
                    }
                }
                ?>
                </select>
            </td>
        </tr>
        
        <tr>
            <td>
                BPF OLI:
                <select name="bpf_oli" style="width:auto">
                <?php
                if ( $ano_mes == 'vazio' )
                {
                ?>
                    <option value="vazio">SELECIONE</option>
                <?php
                }	else	{
					// variavel que mostra quais arquivos listar //
					$partes_data = explode("_", $ano_mes);
					$ano = $partes_data[0];
					$mes = $partes_data[1];
										
					$controle_BPF = "LO8BPF".$ano.$mes;
                    // gera lista dos arquivos CPF dentro da pasta //
                    $lista_de_bpfs = $_METODO->listaArquivosBPF($controle_BPF);
                    //--echo $lista_de_passagens;
                    $valores_bpf= explode(";", $lista_de_bpfs);
                    $count = count($valores_bpf);
                    for ($k = 0; $k < $count; $k++)
                    {
                        $verifica_bpf = trim(substr($valores_bpf[$k], 0, 2));
                        if ( $verifica_bpf == "LO" or $verifica = "LC" ) 
                        {
                    ?>
                            <option value="<?php echo trim($valores_bpf[$k]);?>"><?php echo trim($valores_bpf[$k]);?></option>
                    <?php
                        }
                    }
                }
                ?>
                </select>
            </td>
        </tr>
        
         <tr>
            <td>
                BPF TIRS:
                <select name="bpf_tirs" style="width:auto">
                <?php
                if ( $ano_mes == 'vazio' )
                {
                ?>
                    <option value="vazio">SELECIONE</option>
                <?php
                }	else	{
					// variavel que mostra quais arquivos listar //
					$partes_data = explode("_", $ano_mes);
					$ano = $partes_data[0];
					$mes = $partes_data[1];
					$controle_BPF = "LT8BPF".$ano.$mes;
                    // gera lista dos arquivos CPF dentro da pasta //
                    $lista_de_bpfs = $_METODO->listaArquivosBPF($controle_BPF);
                    //--echo $lista_de_passagens;
                    $valores_bpf= explode(";", $lista_de_bpfs);
                    $count = count($valores_bpf);
                    for ($k = 0; $k < $count; $k++)
                    {
                        $verifica_bpf = trim(substr($valores_bpf[$k], 0, 2));
                        if ( $verifica_bpf == "LT" ) 
                        {
                    ?>
                            <option value="<?php echo trim($valores_bpf[$k]);?>"><?php echo trim($valores_bpf[$k]);?></option>
                    <?php
                        }
                    }
                }
                ?>
                </select>
            </td>
        </tr>
                  
            
        <tr>
            <td>
            	<button class="btn btn-success">LPGS-L1T</button>
            </td>
        </tr>
        
        </form>
        
    </table>
    </div>
</div>
