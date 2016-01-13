<?php

// Parametros de linha de comando
if ( isset($argv[1]) ) 
{
	$arquivo_lista = $argv[1];
}

// Elimina os espaços vazio no caminho do arquivo
$arquivo_lista = trim($arquivo_lista);

// Abre o arquivo da lista e verifica //
$lista = fopen ($arquivo_lista,"r");
while (!feof ($lista)) 
{
	$linha = fgets($lista,4096);
	//echo $linha."<br />";
	if ( $linha )
	{
		$partes = explode(";", $linha);
		//echo $partes['1'];
	
		if ( $partes[1] )
		{
			$tamanho_passagem = $partes[0];
			$nome_passagem = $partes[1];
			
			// pega os dados da passagem //
			$partes_passagem = explode("_", $nome_passagem);
			$satelite = $partes_passagem[0].$partes_passagem[1];
			$sensor = 'AVHRR';
			
			// Recorta a data e hora//
			$ano = $partes_passagem[3];
			$mes = $partes_passagem[4];
			$dia_hora = explode(".", $partes_passagem[5]);
			$dia = $dia_hora[0];
			$hora = $dia_hora[1];
			$min = $partes_passagem[6];
			$seg = $partes_passagem[7];
			$erg_parte = explode(".", $partes_passagem[8]);
			$erg = $erg_parte[0];
			// data no formato a ir no banco de dados //
			$data_hora_banco = $ano."-".$mes."-".$dia." ".$hora.":".$min.":".$seg;
			
			// SQL para consulta //
			$_SQL = "SELECT arquivo FROM pedidosDireto WHERE arquivo = '$nome_passagem'";
			
			// Conecta ao banco de dados //
			$con = mysql_pconnect("150.163.134.96:3333","gerente","gerente.200408");
			$dbCatalogo = mysql_select_db("catalogo",$con) or die ("Site temporariamente fora de servi&ccedil;o ");
			
			// Resultado da consulta //
			$resultado = mysql_query($_SQL, $con) or die (mysql_error());
			// Verifica se já foi inserido //
			$verificacao = mysql_num_rows($resultado);
			//echo $verificacao;
			if ( $verificacao == 0 )
			{
				// Grava como pedido do Alberto Setzer //
				$_INSERE_QUIMADAS = "INSERT INTO pedidosDireto(UserId, arquivo, tamanho, data_pedido, Satellite, Sensor, Estacao_Recepcao) 
				VALUES('asetzer','$nome_passagem','$tamanho_passagem','$data_hora_banco','$satelite','$sensor','$erg')";
				mysql_query($_INSERE_QUIMADAS, $con) or die (mysql_error());
				// Grava como pedido do Sergio Pereira - DSA //
				$_INSERE_DSA = "INSERT INTO pedidosDireto(UserId, arquivo, tamanho, data_pedido, Satellite, Sensor, Estacao_Recepcao) 
				VALUES('sergiobentz','$nome_passagem','$tamanho_passagem','$data_hora_banco','$satelite','$sensor','$erg')";
				mysql_query($_INSERE_DSA, $con) or die (mysql_error());
				// Grava os pedidos para Luiz Gonzaga //
				$_INSERE_GONZAGA = "INSERT INTO pedidosDireto(UserId, arquivo, tamanho, data_pedido, Satellite, Sensor, Estacao_Recepcao) 
				VALUES('lgonzaga','$nome_passagem','$tamanho_passagem','$data_hora_banco','$satelite','$sensor','$erg')";
				mysql_query($_INSERE_GONZAGA, $con) or die (mysql_error());
				// Grava para o Manoel Joseane Mafra - SINDA NATAL //
				$_INSERE_SINDA = "INSERT INTO pedidosDireto(UserId, arquivo, tamanho, data_pedido, Satellite, Sensor, Estacao_Recepcao) 
				VALUES('manoel_mafra','$nome_passagem','$tamanho_passagem','$data_hora_banco','$satelite','$sensor','$erg')";
				mysql_query($_INSERE_SINDA, $con) or die (mysql_error());
			}
		}
	}
}
		

?>