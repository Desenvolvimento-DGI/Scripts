<?php
/*
Classe responsavel po todas as configuracoes de CSS e JS
Autor: Jose Neto
Data: 02/2015
*/

// Define a TimeZone //
date_default_timezone_set('UTC');

class configuracaoClass
{
	public static function _cabecalhoPagina(){
	
		$_HEAD = "
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
<title>SISTEMA DE PROCESSAMENTO LANDSAT-8 - CDSR</title>
		";
		
		printf($_HEAD);
	
	}
	
	public static function _FinalizaHead(){
	
		$_CSS_JS = "
</head>
		";
		
		printf($_CSS_JS);
	}
	
	// Configuração de CSS  do index //
	public static function _CSS_01(){
		$_CSS_JS = "
<link rel=\"stylesheet\" href=\"config/scripts/bootstrap/css/bootstrap.min.css\" />
<link rel=\"stylesheet\" href=\"config/scripts/bootstrap/css/bootstrap-responsive.min.css\" />

<link href=\"config/scripts/icons/general/stylesheets/general_foundicons.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />  
<link href=\"config/scripts/icons/social/stylesheets/social_foundicons.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />
<link rel=\"stylesheet\" href=\"config/scripts/fontawesome/css/font-awesome.min.css\">
<link href=\"config/scripts/styles/custom.css\" rel=\"stylesheet\" type=\"text/css\" />
		";
		printf($_CSS_JS);
	}
    // Configuração de JS  do index //
    public static function _JS_01(){
		$_CSS_JS = "
<script src=\"config/scripts/jquery.min.js\" type=\"text/javascript\"></script> 
<script src=\"config/scripts/bootstrap/js/bootstrap.min.js\" type=\"text/javascript\"></script>
<script src=\"config/scripts/default.js\" type=\"text/javascript\"></script>
		";
		printf($_CSS_JS);
	}
	
	
	// Configuração de CSS  das demais paginas //
	public static function _CSS_02(){
		$_CSS_JS = "
<link rel=\"stylesheet\" href=\"../config/scripts/bootstrap/css/bootstrap.min.css\" />
<link rel=\"stylesheet\" href=\"../config/scripts/bootstrap/css/bootstrap-responsive.min.css\" />

<link href=\"../config/scripts/icons/general/stylesheets/general_foundicons.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />  
<link href=\"../config/scripts/icons/social/stylesheets/social_foundicons.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />
<link rel=\"stylesheet\" href=\"../config/scripts/fontawesome/css/font-awesome.min.css\">
<link href=\"../config/scripts/styles/custom.css\" rel=\"stylesheet\" type=\"text/css\" />
<link href=\"../config/scripts/styles/styles.css\" rel=\"stylesheet\" type=\"text/css\" />


		";
		printf($_CSS_JS);
	}
    // Configuração de JS  do index //
    public static function _JS_02(){
		$_CSS_JS = "
<script src=\"../config/scripts/jquery.min.js\" type=\"text/javascript\"></script> 
<script src=\"../config/scripts/bootstrap/js/bootstrap.min.js\" type=\"text/javascript\"></script>
<script src=\"../config/scripts/default.js\" type=\"text/javascript\"></script>
<script src=\"../config/js/controleFormularios.js\" type=\"text/javascript\"></script>
		";
		printf($_CSS_JS);
	}
	
	// Função que gera CALENDARIO personalizado //
	public static function _calendarioJQUERY()
	{		
		$_BIBLIOTECAS = "<!--Calendario-->
						<link rel='stylesheet' href='../config/calendario/jquery-ui.css' />
						<script src='../config/calendario/jquery-1.8.2.js'></script>
						<script src='../config/calendario/jquery-ui.js'></script>";
		$_CALENDARIO = 	'<script>
						$(function() {
							$("#calender_1").datepicker({
								changeMonth: true,
								changeYear: true
							});
						});
						$(function() {
							$("#calender_2").datepicker({
								changeMonth: true,
								changeYear: true
							});
						});
						</script>
						';				
		printf($_BIBLIOTECAS);
		printf($_CALENDARIO);
	}
	
	// ----------------------------------------------------------------------------------------//
	// funcao que importa as bibliotecas CSS e JS //
	public static function _bibliotecasCSSeJS_Paginacao()
	{
		$_BIBLIOTECA = 
		"
<link rel='stylesheet' href='../config/css/bootstrap.min.css' />
<link rel='stylesheet' href='../config/css/styles.css' />
<link rel='stylesheet' href='../config/css/configs.css' />
<!--script src='../config/js/bootstrap.min.js'></script>
<script src='../config/js/scripts.js'></script-->
		";
		printf($_BIBLIOTECA);
	}
	// ----------------------------------------------------------------------------------------//
	// funcao que atualiza a pagina a cada 15 minutos e verifica se a sessao do usuario ainda nao expirou //
	//  //
	public static function _refresh(){
		$_REF = "<script language=\"JavaScript\">
<!--
setTimeout('delayReload()', 90000000);
function delayReload()
{
	if(navigator.userAgent.indexOf(\"MSIE\") != -1){
		history.go(0);
	}else{
		window.location.reload();
	}
}
//-->
</script>	";
		printf($_REF);
		
	}
}
?>