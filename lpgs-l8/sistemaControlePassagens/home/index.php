<?php
/* ------------------------------------------------------------------------------
Pagina inical apos logar no sistema
Autor: Jose Neto
Data: 01/2015
-------------------------------------------------------------------------------- */

// verifica se o usuario ainda está logado //
session_start();
//$login_user = $_SESSION['login'];
if ( $_SESSION['login'] == '' )
{
	echo "
		<script>
			alert(\"SESSÃO EXPIROU. É OBRIGATÓRIO REALIZAR NOVAMENTE O LOGIN\");
			window.location.href = \"../index.php\";
		</script>
	";
}

// Classe dos metodos //
include("homeClass.php");
// Instancia o objeto //
$_METODO = new HOMEClass();

// Classe das configuracoes //
include("../configuracaoClass.php");
configuracaoClass::_cabecalhoPagina();
configuracaoClass::_CSS_02();
?>

</head>

<body id="pageBody">


<!-- barra do topo da pagina -->
<div id="decorative2">
    <div class="container">
        <div class="divPanel topArea notop nobottom">
            <div class="row-fluid">
                <div class="span12">
                    <div id="divLogo" class="pull-left">
                        <a href="index.html" id="divSiteTitle">SISTEMA DE CONTROLE DE PASSAGENS DE SATÉLITES </a><br />
                        <a href="index.html" id="divTagLine">DIVISÃO DE GERAÇÃO DE IMAGENS</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- fim da barra do topo da pagina -->

<!---Menu horizontal-->
<div class="navbar">
	<div class="navbar-inner">
    	<ul class="nav">
    		<li class="active"><a href="bemVindo.php" target="areaFuncoes" target="areaFuncoes">HOME</a></li>
            <!--li class="active"><a href="listaDePassagensL0.php?satelite=AQUA&data=vazio" target="areaFuncoes">AQUA</a></li>
            <li class="active"><a href="listaDePassagensL0.php?satelite=CBERS-4&data=vazio" target="areaFuncoes">CBERS-4</a></li>
            <li class="active"><a href="listaDePassagensL0.php?satelite=FENG-YUN&data=vazio" target="areaFuncoes">FENG-YUN</a></li>
            <li class="active"><a href="listaDePassagensL0.php?satelite=LANDSAT-7&data=vazio" target="areaFuncoes">LANDSAT-7</a></li>
            <li class="active"><a href="listaDePassagensL0.php?satelite=LANDSAT-8&data=vazio" target="areaFuncoes">LANDSAT-8</a></li>
            <li class="active"><a href="listaDePassagensL0.php?satelite=METOP-B&data=vazio" target="areaFuncoes">METOP-B</a></li!-->
            <li class="active"><a href="../controlePassagemNOAA/homeNoaa.php" target="areaFuncoes">NOAA</a></li>
            <!--li class="active"><a href="listaDePassagensL0.php?satelite=RESOURCESAT-2&data=vazio" target="areaFuncoes">RESOURCESAT-2</a></li>
            <li class="active"><a href="listaDePassagensL0.php?satelite=S-NPP&data=vazio" target="areaFuncoes">S-NPP</a></li>
            <li class="active"><a href="listaDePassagensL0.php?satelite=TERRA&data=vazio" target="areaFuncoes">TERRA</a></li!-->
    		<li><a href="../login/executaLogout.php">LOGOUT</a></li>
    	</ul>
	</div>
        
</div>
<!---fim do Menu horizontal-->

<!-- area do meio do site -->
<div id="contentOuterSeparator" style="margin-top:-25px;"></div>

    <div class="divPanel page-content">

        <div class="row-fluid">

                <div class="span11" id="divMain">
                
                        <iframe name="areaFuncoes" width="100%" height="630px" scrolling="yes" src="bemVindo.php"></iframe>

                    <!--iframe name="areaPesquisa" width="100%" height="700px" src="painelDePesquisa.php" scrolling="no" frameborder="1"></iframe-->
				</div>

            </div>

        <div id="footerInnerSeparator"></div>

    </div>

</div>
<!-- fim da area do meio do site -->
<div id="divFooter" class="footerArea">
    <div class="container">
        <div class="divPanel">
            <div class="row-fluid">
                <div class="span12" id="footerArea1">
                	<h5 style="text-align:center">CDSR-2015</h5>
                </div>
           </div>
    	</div>
    </div>
</div>

<?php
// Script JavaScript //
configuracaoClass::_JS_01();
?>
</body>
</html>

<!--div class="row">
    <div class="col-md-12">
		<!--iframe name="areaPesquisa" width="100%" height="700px" src="painelDePesquisa.php"></iframe>
	</div>
</div-->
