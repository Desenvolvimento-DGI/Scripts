<?php
// inicializando a sessao //
session_start();

/*
Pagina que lista os dados para serem processados
autor: Jose Neto
data: 03/2015
*/

include("homeClass.php");
$_METODO = new HOMEClass();

// Classe das configuracoes //
include("../configuracaoClass.php");
configuracaoClass::_cabecalhoPagina();
configuracaoClass::_CSS_02();
// atualiza a pagina a cada 30 segundos //
echo "<meta http-equiv=\"refresh\" content=\"30\">";


// Pega o login do usuario //
$_usuario = $_SESSION['login'];

//------------------------------------------------------------------------//
// CSS com a configuracao da tabela - ../config/scripts/styles/styles.css //
//------------------------------------------------------------------------//
?>

</head>

<body>
<div class="row" style="margin-top:-80px; margin-left:10px; margin-right:10px;">
    <table width="100%" border="1s">
        <tr>
            <th>PROCESSO</th>
            <th>PASSAGEM</th>
            <th>DATA INICIAL</th>
            <th>STATUS</th>
            <th>DATA FINAL</th>
            <th>OPERADOR</th>
            <th>TIPO</th>
            <th colspan="2" style="background-color:#F60">
            <?php
			// exibe o espaço disponivel no /dados
			$tamanho_dados = exec('df -hl /dados');
			$tamanho_dados = substr($tamanho_dados, 34, 4);
			echo "/dados = ".$tamanho_dados;
			?>            
            </th>
        </tr>
    <?php
    // Lista de Processos no sistema //
	$stilo_td = 01;
    $_LISTA_TODOS_PROCESSOS = $_METODO->listaTodosProcessos();
    while($_DADOS_PROCESSOS = mysql_fetch_array($_LISTA_TODOS_PROCESSOS))
    {
		if ( $stilo_td == 01 )
		{
			$stilo_td = 02;
    ?>
            <tr class="cor_td_01">
                <td><?php echo $_DADOS_PROCESSOS['id_processo']; ?></td>
                <td><?php echo $_DADOS_PROCESSOS['proc_passagem']; ?></td>
                <td><?php echo $_DADOS_PROCESSOS['proc_data_inicial']; ?></td>
                <td><?php echo $_DADOS_PROCESSOS['proc_status']; ?></td>
                <td><?php echo $_DADOS_PROCESSOS['proc_data_final']; ?></td>
                <td><?php echo strtoupper($_DADOS_PROCESSOS['proc_login_operador']); ?></td>
                <td><?php echo $_DADOS_PROCESSOS['proc_tipo']; ?></td>
                <td>
                    <?php
                    if ( $_DADOS_PROCESSOS['proc_tipo'] == 'INGEST' )
                    {
                    ?>
                        <a href="listaLogsPorPassagem.php?passagem=<?php echo $_DADOS_PROCESSOS['proc_passagem']; ?>&tipo_processo=<?php echo $_DADOS_PROCESSOS['proc_tipo']; ?>" target="_blank">
                            <button class="btn btn-inverse btn-small">LOGS</button>        
                        </a>
                    <?php
                    }
					?>
				</td>
				<td>
                	<?php
					if  ( $_usuario == $_DADOS_PROCESSOS['proc_login_operador'] )
					{
					?>
                    <a href="removeProcessoDaLista.php?id_processamento=<?php echo $_DADOS_PROCESSOS['id_processo'];?>&tipo=<?php echo $_DADOS_PROCESSOS['proc_tipo']; ?>">
                        <button class="btn btn-success btn-small">ARQUIVAR</button>        
                    </a>
                    <?php
					}	else	{
					?>
                    	<button class="btn btn-warning btn-small">ARQUIVAR</button>        
                    <?php
					}
					?>
                </td>
            </tr>
    <?php
		}	else	{
			$stilo_td = 01;
	?>
    		<tr class="cor_td_02">
                <td><?php echo $_DADOS_PROCESSOS['id_processo']; ?></td>
                <td><?php echo $_DADOS_PROCESSOS['proc_passagem']; ?></td>
                <td><?php echo $_DADOS_PROCESSOS['proc_data_inicial']; ?></td>
                <td><?php echo $_DADOS_PROCESSOS['proc_status']; ?></td>
                <td><?php echo $_DADOS_PROCESSOS['proc_data_final']; ?></td>
                <td><?php echo strtoupper($_DADOS_PROCESSOS['proc_login_operador']); ?></td>
                <td><?php echo $_DADOS_PROCESSOS['proc_tipo']; ?></td>
                <td>
                    <?php
                    if ( $_DADOS_PROCESSOS['proc_tipo'] == 'INGEST' )
                    {
                    ?>
                        <a href="listaLogsPorPassagem.php?passagem=<?php echo $_DADOS_PROCESSOS['proc_passagem']; ?>&tipo_processo=<?php echo $_DADOS_PROCESSOS['proc_tipo']; ?>" target="_blank">
                            <button class="btn btn-inverse btn-small">LOGS</button>        
                        </a>
                    <?php
                    }
					?>
				</td>
				<td>
                    <?php
					if  ( $_usuario == $_DADOS_PROCESSOS['proc_login_operador'] )
					{
					?>
                    <a href="removeProcessoDaLista.php?id_processamento=<?php echo $_DADOS_PROCESSOS['id_processo'];?>&tipo=<?php echo $_DADOS_PROCESSOS['proc_tipo']; ?>">
                        <button class="btn btn-success btn-small">ARQUIVAR</button>        
                    </a>
                    <?php
					}	else	{
					?>
                    	<button class="btn btn-warning btn-small">ARQUIVAR</button>        
                    <?php
					}
					?>
                </td>
            </tr>
    <?php
		}
    }
    ?>
    </table>
</div>
</body>
