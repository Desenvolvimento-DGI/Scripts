<?php
/* ------------------------------------------------------------------------------
Metodo que realiza o logout do sistema
Autor: Jose Neto
Data: 02/2015
-------------------------------------------------------------------------------- */

session_start();
session_destroy();
sleep(1);
// Redireciona para o sistema - pagina de login //
header("Location: ../index.php");


?>