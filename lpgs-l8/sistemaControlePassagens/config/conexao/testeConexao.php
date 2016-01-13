<?php
include("conexaoBD.php");
$teste_conec = new ConexaoBD();

// Teste de conexao //
$teste_conec->conexaoBD();
echo "conectou";
?>