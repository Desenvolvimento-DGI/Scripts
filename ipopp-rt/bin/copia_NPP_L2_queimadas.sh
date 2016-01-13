# Script para copiar dados MODIS para o grupo de QUEIMADAS
# 10/09/2013
# Versao 1.0

	cp -n  /raid/pub/gsfcdata/npp/viirs/level2/NPP_CVIIRS_L2*.tif  /L1_NPP/dados/
	#cp -n  /raid/pub/gsfcdata/npp/viirs/level2/AVAFO*    /L1_NPP/dados/
	cp -n  /raid/pub/gsfcdata/npp/viirs/level2/FireLoc*  /L1_NPP/dados/

	echo "Inicio do Processamento.:..."

echo "Fim do Processamento.:..." 
exit 0
