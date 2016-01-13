<?php

//echo date_default_timezone_get();
echo "";

//ini_alter('date.timezone','America/Sao_Paulo');

@date_default_timezone_set('America/Sao_Paulo');
echo date('Y-m-d H:i:s');
echo "\n\n";
@date_default_timezone_set('UTC');
echo date('Y-m-d H:i:s');
echo "";
?>

