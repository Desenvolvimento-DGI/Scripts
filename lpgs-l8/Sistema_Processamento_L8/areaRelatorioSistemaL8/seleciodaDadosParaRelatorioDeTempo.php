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
ConfiguracaoClass::_calendarioJQUERY();
?>

<div class="container">
	<div class="row" style="background-color:#FFF">
        
        <ul class="thumbnails">
      		<li class="span12">
        		<div class="thumbnail">
          			<form method="post" action="relatorioDeTempoDeProcessamento.php">
                        <h3>SELECINA O INTERVALO A SER CONSULTADO</h3>
                        
                        <h4>TIPO DE PROCESSO</h4>
                        <p>
                        	<select name="tipo_processo">
                            	<option value="RENOMEAR">RENOMEAR</option>
                                <option value="INGEST">INGEST</option>
                                <option value="SUBSETTER">SUBSETTER</option>
                                <option value="LPGS">LPGS</option>
                                <option value="TRANSFERIR">TRANSFERIR</option>
                            </select>
                      	</p>
                        
                        <h4>DATA INICIAL</h4>
                        <p>
                        	<input type="text" name="data_inicial" id="calender_1" value="<?php echo date('d/m/Y', strtotime("-2 days")); ?>"  style="width:auto" />
                      	</p>
                        
                        <h4>DATA FINAL</h4>
                        <p>
                        	<input type="text" name="data_final" id="calender_2" value="<?php echo date("d/m/Y") ?>" style="width:auto" />
                       	</p>
                        
                        <p>
                            <button class="btn btn-success" type="submit">GERAR RELATÓRIO</button>
                        </p>
                    </form>
        		</div>
      		</li>
     	</ul>
	</div>
</div>
