<?php
/*
Pagina que fornece opções de relatorios do sistema de processamento do LandSat-8 //
autor: Jose Neto
data: 05/2015
*/

include("relatorioClass.php");
$_METODO = new RelatorioClass();

// Classe das configuracoes //
include("../configuracaoClass.php");
configuracaoClass::_CSS_02();

// Recebe os parametros //
$data_inicial = $_POST['data_inicial'];
$data_final = $_POST['data_final'];
$tipo_processo = $_POST['tipo_processo'];
// parametro para o botao exportar excel //
$parametro_excel = "tipo_processo=".$tipo_processo."&data_inicial=".$data_inicial."&data_final=".$data_final;

// Busca os dados na Tabela de processamento //
$_LISTA_TODOS_PROCESSOS = $_METODO->selecionaDadosParaTempoDeProcessamento($data_inicial, $data_final, $tipo_processo);
?>
</head>

<body>
<div class="row" style="margin-top:-80px; margin-left:10px; margin-right:10px;">
    <table width="100%" border="1s">
        <tr>
            <th>PROCESSO</th>
            <th>PASSAGEM</th>
            <th>DATA INICIAL</th>
            <th>DATA FINAL</th>
            <th>OPERADOR</th>
            <th>STATUS</th>
            <th>TIPO</th>
            <th>TEMPO DE PROCESSAMENTO</th>
        </tr>

		<?php
        // Lista os dados //
        while($_DADOS_PROCESSOS = mysql_fetch_array($_LISTA_TODOS_PROCESSOS))
        {
            if ( $_DADOS_PROCESSOS["proc_data_inicial"] && $_DADOS_PROCESSOS["proc_data_final"] )
            {
                $passagem = $_DADOS_PROCESSOS["proc_passagem"]."<br />";
                // Hora inicial //
                $partes_data_hora_inicial = explode(" ", $_DADOS_PROCESSOS["proc_data_inicial"]);
                $partes_data_inicial = explode("/", $partes_data_hora_inicial[0]);
                $data_inicial = $partes_data_inicial[2]."-".$partes_data_inicial[1]."-".$partes_data_inicial[0];
                $data_hora_inicial = $data_inicial." ".$partes_data_hora_inicial[1];
                //$data_hora_inicial_time = strtotime($data_hora_inicial);
                // Hora final //
                $partes_data_hora_final = explode(" ", $_DADOS_PROCESSOS["proc_data_final"]);
                $partes_data_final = explode("/", $partes_data_hora_final[0]);
                $data_final = $partes_data_final[2]."-".$partes_data_final[1]."-".$partes_data_final[0];
                $data_hora_final = $data_final." ".$partes_data_hora_final[1];
                //$data_hora_final_time = strtotime($data_hora_final);
                
                $data_inicial = strtotime($data_hora_inicial);
                $data_final = strtotime($data_hora_final);
		
                $nHoras   = ($data_final - $data_inicial) / 3600;
                $nMinutos = (($data_final - $data_inicial) % 3600) / 60;
				$nsegundos = (($data_final - $data_inicial) % 3600) / 3600;
        		
				//--echo $nHoras."-".$nMinutos."-".$nsegundos."-";
				
                $total_processamento = sprintf('%02d:%02d:%02d', $nHoras, $nMinutos, $nsegundos);
				
				//echo $data_final ."-". $data_inicial;
                
            ?>
                <tr>
                    <td><?php echo $_DADOS_PROCESSOS["id_processo"]; ?></td>
                    <td><?php echo $_DADOS_PROCESSOS["proc_passagem"]; ?></td>
                    <td><?php echo $_DADOS_PROCESSOS["proc_data_inicial"]; ?></td>
                    <td><?php echo $_DADOS_PROCESSOS["proc_data_final"]; ?></td>
                    <td><?php echo strtoupper($_DADOS_PROCESSOS["proc_login_operador"]); ?></td>
                    <td><?php echo $_DADOS_PROCESSOS["proc_status"]; ?></td>
                    <td><?php echo $_DADOS_PROCESSOS["proc_tipo"]; ?></td>
                    <td><?php echo $total_processamento; ?></td>
                </tr>
            <?php
            }
        }
        ?>
        
        
        <tr>
        	<td colspan="7">
            	<div class="container">
                	<div class="row" style="text-align:center">
                        <a href="exportaExcelRelatorioTempoProcesso.php?<?php echo $parametro_excel; ?>" class="btn btn-success" target="new">
                            EXPORTAR
                        </a>
                    </div>
                </div>
            </td>
        </tr>
        
	</table>
</div>
</body>
