<?php
header("Content-type: application/vnd.ms-excel");
header("Content-Disposition: attachment; filename=tempoProcessar.xls");
header("Pragma: no-cache");

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
$data_inicial = $_GET['data_inicial'];
$data_final = $_GET['data_final'];
$tipo_processo = $_GET['tipo_processo'];


// Busca os dados na Tabela de processamento //
$_LISTA_TODOS_PROCESSOS = $_METODO->selecionaDadosParaTempoDeProcessamento($data_inicial, $data_final, $tipo_processo);
$excel = "";
$excel .= "<table width=\"100%\" border=\"1s\">";
$excel .= "<tr>";
$excel .= "<th>PROCESSO</th>";
$excel .= "<th>PASSAGEM</th>";
$excel .= "<th>DATA INICIAL</th>";
$excel .= "<th>DATA FINAL</th>";
$excel .= "<th>OPERADOR</th>";
$excel .= "<th>STATUS</th>";
$excel .= "<th>TEMPO DE PROCESSAMENTO</th>";
$excel .= "</tr>";

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
                
        $excel .= "<tr>";
        $excel .= "<td>".$_DADOS_PROCESSOS["id_processo"]."</td>";
        $excel .= "<td>".$_DADOS_PROCESSOS["proc_passagem"]."</td>";
        $excel .= "<td>".$_DADOS_PROCESSOS["proc_data_inicial"]."</td>";
        $excel .= "<td>".$_DADOS_PROCESSOS["proc_data_final"]."</td>";
        $excel .= "<td>".strtoupper($_DADOS_PROCESSOS["proc_login_operador"])."</td>";
        $excel .= "<td>".$_DADOS_PROCESSOS["proc_status"]."</td>";
        $excel .= "<td>".$total_processamento."</td>";
        $excel .= "</tr>";
           
	}
}
$excel .= "<table>";
echo $excel;
?>
        
