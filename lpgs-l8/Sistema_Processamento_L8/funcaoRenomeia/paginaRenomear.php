<?php
/*
Pagina que lista os dados para serem processados
autor: Jose Neto
data: 03/2015
*/

include("renomearClass.php");
$_METODO = new RENOMEARClass();

// Classe das configuracoes //
include("../configuracaoClass.php");
configuracaoClass::_CSS_02();

// recebe os parametros //
$ano_mes = $_REQUEST['ano_mes'];


//--echo $lista_ano_mes."<br />";
?>
<table>
	<form action="executaFuncaoRenomear.php" method="post">
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
                    <option value="vazio">SELECIONE</option>
                <?php
				}
				for ($i = 0; $i < $count; $i++)
                {	
                    if ( $valores_ano_mes[$i] )
                    {
						$valor_ano_mes = trim($valores_ano_mes[$i]);
                        //-echo $valores_ano_mes[$i];
                ?>
						<option value="<?php echo $valor_ano_mes; ?>" onclick="document.location=('paginaRenomear.php?ano_mes=<?php echo $valor_ano_mes?>');">
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
           	STS - XML:
            <select name="xml" style="width:auto">
            <?php
			if ( $ano_mes == 'vazio' )
			{
			?>
               	<option value="vazio">SELECIONE</option>
            <?php
			}	else	{
				// gera lista dos arquivos CPF dentro da pasta //
				$lista_de_xmls = $_METODO->listaArquivosSTSXML();
				//--echo $lista_de_passagens;
				$valores_xml= explode(";", $lista_de_xmls);
				$count = count($valores_xml);
				for ($k = 0; $k < $count; $k++)
                {
					if ( $valores_xml[$k] )
					{
				?>
                		<option value="<?php echo trim($valores_xml[$k]);?>"><?php echo trim($valores_xml[$k]);?></option>
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
            	<button class="btn btn-success">RENOMEAR</button>
    	</td>
	</tr>
    
    </form>
    
</table>