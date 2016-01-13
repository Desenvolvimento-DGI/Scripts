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

?>
<div class="container">
	<div class="row" style="background-color:#FFF">
        
        <ul class="thumbnails">
      		<li class="span4">
        		<div class="thumbnail">
          			<img src="../imagens/img-rel-tempo-proc.png" alt="">
          			<h3>RELÁTORIO</h3>
                    
                    <div style="border:1px solid #ececec; background-color:#E8F5FF; padding-bottom:10px;">
                        <p>Gera relatórios sobre o tempo de processamento dos processos do sistema. Os processos são o RENOMEAR, INGEST, SUBSETTER e o LPGS.</p>
                        <a href="seleciodaDadosParaRelatorioDeTempo.php" class="btn btn-success">ACESSAR</a>
                    </div>
                    <br /><br />
                    <div style="border:1px solid #ececec; background-color:#E8F5FF; padding-bottom:10px;">
                        <p>Gera relatórios sobre o tempo de processamento completo. Retorna o tempo total que uma passagem demorou para processar.</p>
                        <a href="seleciodadadosParaRelatorioDeTempoCompleto.php" class="btn btn-success">ACESSAR</a>
                    </div>
                    
        		</div>
      		</li>
            
            <li class="span4">
        		<div class="thumbnail">
          			<img src="../imagens/img-rel-pass-proc.png" alt="">
          			<h3>RELÁTORIO</h3>
          			<p>Gera relatórios sobre a quantidade de passagens processadas por período. Separa o número também de passagens processdas por Operador.</p>
                    <a href="relatorioDeTempoDeProcessamento.php" class="btn btn-success">ENTRAR</a>
        		</div>
      		</li>
    	</ul>
        
    </div>
</div>