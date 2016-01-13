<?php
/* ------------------------------------------------------------------------------
Pagina Inicial do sistema - Contem o login. 
Autor: Jose Neto
Data: 03/2015
-------------------------------------------------------------------------------- */
// Classe das configuracoes //
include("configuracaoClass.php");
configuracaoClass::_cabecalhoPagina();
configuracaoClass::_CSS_01();
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
<!-- area do meio do site -->
<div id="contentOuterSeparator"></div>

<div class="container">
	<div class="span12" id="divMain" style="margin-left:-50px;">
		<h1></h1>

		<br /><br /><br />
					
		<hr style="margin:45px 0 35px" />
                    
		<div class="lead">
			<form action="login/executaLogin.php" method="post">
				<h3>LOGIN: <input type="text" name="usuario" ></h2>
				<h3>SENHA: <input type="password" name="senha" ></h2>
				<button type="submit">ACESSAR</button>
			</form>
		</div>
		<hr style="margin:45px 0 35px" />
		<br />
		
        <div id="footerInnerSeparator"></div>
		<div id="footerInnerSeparator"></div>
		<div id="footerInnerSeparator"></div>
        
    </div>

</div>
<!-- fim da area do meio do site -->

<div id="footerOuterSeparator"><br /></div>
<div id="footerOuterSeparator"><br /></div>
<div id="footerOuterSeparator"><br /></div>
<div id="footerOuterSeparator"><br /></div>

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