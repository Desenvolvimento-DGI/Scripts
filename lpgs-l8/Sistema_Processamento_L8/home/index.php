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
                        <a href="index.html" id="divSiteTitle">SISTEMA DE PROCESSAMENTO LANDSAT-8</a><br />
                        <a href="index.html" id="divTagLine">CENTRO DE DADOS DE SENSORIAMENTO REMOTO</a>
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
    		<li class="active"><a href="listaDeProcessos.php" target="areaFuncoes">HOME</a></li>
            <li><a href="../funcaoRenomeia/paginaRenomear.php?ano_mes=vazio&passagens=vazio" target="areaFuncoes">RENOMEAR</a></li>
            <li><a href="../funcaoIngest/paginaIngest.php?ano_mes=vazio&passagens=vazio" target="areaFuncoes">INGEST</a></li>
            <li><a href="../funcaoSubsetter/paginaSubsetter.php?ano_mes=vazio&passagens=vazio" target="areaFuncoes">SUBSETER</a></li>
            <li><a href="../funcaoLPGS/paginaLPGS.php?ano_mes=vazio&passagens=vazio" target="areaFuncoes">LPGS</a></li>
            <li><a href="../funcaoTransfere/paginaTransferir.php?ano_mes=vazio&passagens=vazio" target="areaFuncoes">TRANSFERIR</a></li>
            <li><a href="../areaRelatorioSistemaL8/paginaHomeRelatorio.php" target="areaFuncoes">RELATÓRIOS</a></li>
            <li><a href="listaPassagensProcessadas.php?ano_mes=vazio&passagens=vazio" target="areaFuncoes">REMOVER</a></li>
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
                
                        <iframe name="areaFuncoes" width="100%" height="630px" scrolling="yes" src="listaDeProcessos.php"></iframe>

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
