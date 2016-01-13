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

// Classe das configuracoes //
include("../configuracaoClass.php");
configuracaoClass::_cabecalhoPagina();
configuracaoClass::_CSS_02();
// atualiza a pagina a cada 30 segundos //
echo "<meta http-equiv=\"refresh\" content=\"30\">";


// Pega o login do usuario //
$_usuario = $_SESSION['login'];

//------------------------------------------------------------------------//
// CSS com a configuracao da tabela - ../config/scripts/styles/styles.css //
//------------------------------------------------------------------------//
// recebe os parametros //
$ano_mes = $_REQUEST['ano_mes'];

?>
<script language="Javascript">
function confirmacao() {
     var resposta = confirm("Deseja remover esse registro?");
 
     if (resposta == true) {
          return(true);
     }	else	{
		 return(false);
	 }
}
</script>
</head>

<body>
<div class="row" style="margin-top:-80px; margin-left:10px; margin-right:10px;">
    <table width="100%" border="1s">
    	<tr>
            <th colspan="2">SELECIONE OS DADOS PARA SEREM REMOVIDOS DA ÁREA DE PROCESSAMENTO</th>       
         </tr>
         
         
         <form action="removePassagensProcessadas.php" method="post" onSubmit="return confirmacao()">
         
        <tr>
            <tr>
            <td>
                ANO/MÊS: 
                <select name="ano_mes">
                    <?php
                    // Gera a lista de ano e mes na area L0_LANDSAT8 //
                    $lista_ano_mes = $_METODO->listaDadosRenomeadosAnoMes();
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
                            <option value="<?php echo $valor_ano_mes; ?>" onclick="document.location=('listaPassagensProcessadas.php?ano_mes=<?php echo $valor_ano_mes?>');">
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
					$lista_de_passagens = $_METODO->listaDadosL0_PorAnoMes($ano_mes);
					//echo $lista_de_passagens;
					$valores_passagens = explode(";", $lista_de_passagens);
					//--
					$count = count($valores_passagens);
					for ($j = 0; $j < $count; $j++)
                	{
						$tamanho_nome_arquivo = strlen($valores_passagens[$j]);
						if ( $tamanho_nome_arquivo > 6 )
						{
				?>
                			<option value="<?php echo trim($valores_passagens[$j]);?>"><?php echo trim($valores_passagens[$j]);?></option>
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
            	<button class="btn btn-danger">REMOVER</button>
    	</td>
		</tr>
    
    </form>
    </table>
</div>
</body>
