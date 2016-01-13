#!/bin/bash -x

#################################################################
# descricao: Script que gera o TIF das passagem TERRA com 250m 	#
# Autor: Jose Neto e Reuel										#
# Data: 09/2015 												#
#################################################################

# Diretorios #
# diretorio de execucao #
dir_exe='/home/cdsr/bin/'
# diretorio dos dados #
dir_level1='/raid/pub/gsfcdata/terra/modis/level1/'

# Exporta algumas variaveis de ambiente #
export PATH=$PATH:/home/cdsr/drl/SPA/BlueMarble/wrapper/BlueMarble_modis-tcolor
export PATH=$PATH:/raid

# Busca a informação no banco de dados do processamento  IPOPP #

# id do ultimo produto a ser gerado - MOD 250m #
id_passagem=`/usr/bin/mysql -u root -pb28c935 -D DSM -s -e "SELECT id FROM Resources WHERE path LIKE '%MOD02QKM.%' ORDER BY id Desc LIMIT 5"`

# Verifica os ultimos 5 processos TERRA #
for id_passagem_especifica in $id_passagem
do 

	# Variavel com o valor do produto gerado - MOD 250m #
	MOD02_250m=`mysql -u root -pb28c935 -D DSM -s -e "SELECT path FROM Resources WHERE path LIKE '%MOD02QKM.%' AND id = '$id_passagem_especifica'"`

	# compara com as passagens ja processadas #
	while read id_passagens_processadas
	do
	
		echo $id_passagens_processadas
	
	done < $dir_exe'/.passagens_processadas_250m_TERRA'
	
done



exit
# Variavel com o valor do produto gerado - MOD 250m #
MOD02_250m=`mysql -u root -pb28c935 -D DSM -s -e "SELECT path FROM Resources WHERE path LIKE '%MOD02QKM.%' AND id = '$id_passagem'"`

# recorta a data do produto #
data_produto=`echo $MOD02_250m | cut -d "." -f2`

# verifica se o Id da passagem é maior #
ultimo_Id_processado=`cat $dir_exe'/.ultimo_Id_processado' | head -1`
if [ $id_passagem -gt $ultimo_Id_processado ]
then


if [ -e '/raid/pub/gsfcdata/terra/modis/level1/MOD021KM.'$data'.hdf' ]
then
	parametro_1km='/raid/pub/gsfcdata/terra/modis/level1/MOD021KM.'$data'.hdf'
else
	echo "Falta arquivo MOD021KM: "$parametro_1km
	exit
fi

if [ -e '/raid/pub/gsfcdata/terra/modis/level1/MOD02HKM.'$data'.hdf' ]
then
	parametro_500m='/raid/pub/gsfcdata/terra/modis/level1/MOD02HKM.'$data'.hdf'
else
	echo "Falta arquivo MOD02HKM: "$parametro_500m
	exit
fi

if [ -e '/raid/pub/gsfcdata/terra/modis/level1/MOD02QKM.'$data'.hdf' ]
then
	parametro_250m='/raid/pub/gsfcdata/terra/modis/level1/MOD02QKM.'$data'.hdf'
else
	echo "Falta arquivo MOD02QKM: "$parametro_250m
	exit
fi

if [ -e '/raid/pub/gsfcdata/terra/modis/level1/MOD03.'$data'.hdf' ]
then
	parametro_GEO='/raid/pub/gsfcdata/terra/modis/level1/MOD03.'$data'.hdf'
else
	echo "Falta arquivo GEO: "$parametro_GEO
	exit
fi

#arruma data Reuel 

         #acertar DATA
        yyyy=$(echo ${data} | cut -c 1-2)
        ddd=$(echo ${data} | cut -c 3-5)
        hh=$(echo ${data} | cut -c 6-7)
        mm=$(echo ${data} | cut -c 8-9)
        ss=$(echo ${data} | cut -c 10-11)

         # converte para dia Gregoriano
        ano=$(date -d "20${yyyy}-01-01 + ${ddd} days -1 day" +%Y)
        mes=$(date -d "20${yyyy}-01-01 + ${ddd} days -1 day" +%m)
        dia=$(date -d "20${yyyy}-01-01 + ${ddd} days -1 day" +%d)
 


nome_saida=/raid/teste/${ano}_${mes}_${dia}.${hh}_${mm}_${ss}/TERRA_TRUE_COLOR_250M_${ano}_${mes}_${dia}.${hh}_${mm}_${ss}.tif

# dispara o processo e gera o produto #
mkdir -p /raid/teste/${ano}_${mes}_${dia}.${hh}_${mm}_${ss}
#mkdir -p /raid/teste/$data
/home/cdsr/drl/SPA/BlueMarble/wrapper/BlueMarble_modis-tcolor/run  modis.mxd021km $parametro_1km modis.mxd02hkm $parametro_500m modis.mxd02qkm $parametro_250m modis.mxd03 $parametro_GEO modis.sharptcolor $nome_saida 
#/raid/pub/gsfcdata/terra/modis/level1/MOD021KM.15241140918.hdf modis.mxd02hkm  /raid/pub/gsfcdata/terra/modis/level1/MOD02HKM.15241140918.hdf modis.mxd02qkm 
#/raid/pub/gsfcdata/terra/modis/level1/MOD02QKM.15241140918.hdf  modis.mxd03  /raid/pub/gsfcdata/terra/modis/level1/MOD03.15241140918.hdf   
#modis.sharptcolor  /home/cdsr/teste/TERRA_TRUE_COLOR_15241140918.tif

cd /home/cdsr/bin
echo $id_passagem > '.ultimo_Id_processado'

fi

exit
