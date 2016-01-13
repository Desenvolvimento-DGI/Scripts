<?php
/* ------------------------------------------------------------------------------
Pagina inical para NOAA
Autor: Jose Neto
Data: 09/2015
-------------------------------------------------------------------------------- */

// Classe dos metodos //
include("noaaClass.php");
// Instancia o objeto //
$_METODO = new NOAAClass();

// Classe das configuracoes //
include("../configuracaoClass.php");
configuracaoClass::_cabecalhoPagina();
configuracaoClass::_CSS_02();
configuracaoClass::_PAINEL_01();
?>

</head>
<body id="pageBody">

<!-- area do meio do site -->
<div id="contentOuterSeparator" style="margin-top:-25px;"></div>

	
    	<div class="span12" class="panel panel-primary" style="border: solid 1px; background-color:#ececfc" >
        
        	<h3>OPERAÇÕES PARA OS SATÉLITES NOAA-15, NOAA-18 E NOAA-19.</h3>
        
      		<div class="span3">
          		<div class="panel panel-primary" style="background-color:#ececec">
                	<br />
                  	<div class="panel-heading">NOAA-15</div>
                        <div class="panel-body" style="margin-left:-10px;">
                            <a href="listaPassagensPorSatelite.php?satelite=NOAA15"><button type="button" class="btn btn-info">LISTAR ULTIMAS PASSAGENS</button></a>
                            <br /><br />
                            <a href="#"><button type="button" class="btn btn-warning">ARMAZENAR PASSAGENS</button></a>
                            <br /><br />
                            <a href="#"><button type="button" class="btn btn-success">BUSCAR PASSAGENS</button></a>
                        </div>
        		</div>
     		</div>
            
            <div class="span3">
          		<div class="panel panel-primary" style="background-color:#ececec">
                	<br />
                  	<div class="panel-heading">NOAA-18</div>
                        <div class="panel-body" style="margin-left:-10px;">
                            <a href="listaPassagensPorSatelite.php?satelite=NOAA18"><button type="button" class="btn btn-info">LISTAR ULTIMAS PASSAGENS</button></a>
                            <br /><br />
                            <a href="#"><button type="button" class="btn btn-warning">ARMAZENAR PASSAGENS</button></a>
                            <br /><br />
                            <a href="#"><button type="button" class="btn btn-success">BUSCAR PASSAGENS</button></a>
                        </div>
        		</div>
     		</div>
            
            <div class="span3">
          		<div class="panel panel-primary" style="background-color:#ececec">
                	<br />
                  	<div class="panel-heading">NOAA-19</div>
                    <div class="panel-body" style="margin-left:-10px;">
                    	<a href="listaPassagensPorSatelite.php?satelite=NOAA19"><button type="button" class="btn btn-info">LISTAR ULTIMAS PASSAGENS</button></a>
                        <br /><br />
                        <a href="#"><button type="button" class="btn btn-warning">ARMAZENAR PASSAGENS</button></a>
                        <br /><br />
                        <a href="#"><button type="button" class="btn btn-success">BUSCAR PASSAGENS</button></a>
                  	</div>
        		</div>
     		</div>
            
      
       
    	</div>
    
</div>
<!-- fim da area do meio do site -->


</body>
</html>
