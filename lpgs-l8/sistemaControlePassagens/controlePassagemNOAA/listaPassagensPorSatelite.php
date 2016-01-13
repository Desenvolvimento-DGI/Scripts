<?php
// inicializando a sessao //
session_start();

/*
Descricao: Pagina que lista as ultimas passagens na area de L0_NOAA, L0_METOP-B, etc.
Autor: Jose Neto
Data: 09/2015
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


// Recebe os parametros //
$nome_satelite = $_GET['satelite'];
$data = $_GET['data'];

// Valida o satelite - cria a variavel do L0 correto //
switch ($nome_satelite) {
    case 'AQUA':
        $pasta_satelite = '/Level-0/AQUA';
		$satelite = 'AQUA';
        break;
    case 'CBERS-4':
        $pasta_satelite = '/Level-0/CBERS4';
		$satelite = 'CBERS4';
        break;
    case 'FENG-YUN':
        $pasta_satelite = '/Level-0/FY';
		$satelite = 'FY';
        break;
		case 'LANDSAT-7':
        $pasta_satelite = '/Level-0/LANDSAT-7';
		$satelite = 'LANDSAT7';
        break;
    case 'LANDSAT-8':
        $pasta_satelite = '/Level-0/LANDSAT8';
		$satelite = 'LANDSAT8';
        break;
    case 'METOP-B':
        $pasta_satelite = '/Level-0/METOPB';
		$satelite = 'METOPB';
        break;
	case 'NOAA-15':
        $pasta_satelite = '/Level-0/NOAA15';
		$satelite = 'NOAA15';
        break;
    case 'NOAA-18':
        $pasta_satelite = '/Level-0/NOAA18';
		$satelite = 'NOAA18';
        break;
    case 'NOAA-19':
        $pasta_satelite = '/Level-0/NOAA19';
		$satelite = 'NOAA19';
        break;
	case 'RESOURCESAT-2':
        $pasta_satelite = '/Level-0/RESOURCESAT2';
		$satelite = 'RESOURCESAT2';
        break;
    case 'S-NPP':
        $pasta_satelite = '/Level-0/NPP';
		$satelite = 'NPP';
        break;
    case 'TERRA':
        $pasta_satelite = '/Level-0/TERRA';
		$satelite = 'TERRA';
        break;
}

// Valida a data //
// se data for vazia, gera lista do mes atual //
if ( $data == 'vazio' )
{
	// pega o ano e mes atual do sistema //
	$data_diretorio = date("Y_m");
}	else	{
	// utiliza a data informada //
	$data_diretorio = $data;
}

//------------------------------------------------------------------------//
// CSS com a configuracao da tabela - ../config/scripts/styles/styles.css //
//------------------------------------------------------------------------//
?>

</head>

<body>
<div class="row" style="margin-top:-80px; margin-left:10px; margin-right:10px;">
    <table width="100%" border="1s">
        <tr>
        	<th>AQUA</th>
            <th>LANDSAT-7</th>
            <th>LANDSAT-8</th>
            <th>METOP-B</th>
            <th>FENG-YUN</th>
            <th>NOAA-15</th>
            <th>NOAA-18</th>
            <th>NOAA-19</th>
            <th>S-NPP</th>
            <th>TERRA</th>
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
