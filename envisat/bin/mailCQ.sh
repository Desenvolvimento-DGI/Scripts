#!/bin/bash -x

#Variaveis de diretorio#
dir=/home/cdsr/bin
dir_tarefa=/intranet/producao/Controle_de_processos_do_desenvolvimento/id_tarefa

# variavel que controla a execucao do script #
execucao=`cat .execucaoMail | head -1`
if [ $execucao == 'executando' ]
then
	exit
fi

cd $dir
echo "executando" > .execucaoMail

#var=`mysql -u gerente -p gerente.200408 -D teste01 -s -e "select count(*) from teste01"`;

var=`mysql -u gerente -pgerente.200408 -D gerente_io -s -e "SELECT id, id_tarefa, module, argument, host, who FROM Report_turno WHERE envio_email = '' AND (module = 'g2q' OR module = 'tar2q') GROUP BY id_tarefa LIMIT 1"`

#var=`mysql -u gerente -pgerente.200408 -D gerente_io -s -e "SELECT * FROM Report_turno WHERE envio_email = '' AND (module = 'g2q' OR module = 'tar2q') GROUP BY id_tarefa LIMIT 1"`

#var=`mysql -u gerente -pgerente.200408 -D gerente_io -s -e "SELECT * FROM Report_turno"`

echo $var > resultado.txt
#echo "teste" > resultado.txt
# Destinatario de email #
contatos_dgi="jose.azevedo@dgi.inpe.br, cq-dgi@dgi.inpe.br, madalena@dgi.inpe.br"
#contatos_dgi="cq-dgi@dgi.inpe.br"
#--contatos_dgi="jose.azevedo@dgi.inpe.br"
if [ "$var" ]
then
dir=/home/cdsr/bin
while read line 
do 
	cd $dir
	arg1=`echo $line | cut -d " " -f4`
	module=`echo $line | cut -d " " -f3`
	host=`echo $line | cut -d " " -f5`
	oper=`echo $line | cut -d " " -f6`
	id=`echo $line | cut -d " " -f2`
	echo "Operador, Encerrado o processamento do Modulo:" $module  $arg1 >> emailCQ
	echo "                                  " >> emailCQ
	echo "Host que processou:" $host >> emailCQ 
	echo "Operador:" $oper >> emailCQ
	echo "Id:" $id >> emailCQ
	echo "                                  " >> emailCQ
	echo "Queira, por gentileza, iniciar os procedimentos de Controle de Qualidade." >> emailCQ
	echo "                                  " >> emailCQ
	echo "Obrigado." >> emailCQ	
	echo "                                  " >> emailCQ
	echo "                                  " >> emailCQ
	echo "                                  " >> emailCQ
	echo "                                  " >> emailCQ


	assunto="Controle de Qualidade $arg1"

	# verifica se existe o arquivo #
	teste_arq=`ls -l /intranet/producao/Controle_de_processos_do_desenvolvimento/id_tarefa/$id`
	if [ !"$teste_arq" ]
	then
		# Enviando Email #
		mail -s "$assunto" $contatos_dgi < emailCQ
		#cd /home/cdsr/teste	
		#rm -rf email
	fi
	cd $dir
	rm -rf emailCQ

	cd $dir_tarefa
	touch $id

	up=`mysql -u gerente -pgerente.200408 -D gerente_io -s -e "UPDATE Report_turno SET envio_email = 'enviado' WHERE id_tarefa =$id"`
	echo $up

	cd $dir
	done < resultado.txt

else

	echo "Nao existe nova passagem"
	echo data_saida=`date +'%d-%m-%Y'`
fi

# Verifica se existem novam passagens do AQUA, TERRA e NPP para serem controladas #
# Variaveis de Data #
data=`date '+%Y-%m-%d'`
#data='2015-06-08'
# AQUA #
pesq_aqua=`mysql -u gerente -pgerente.200408 -D catalogo -s -e "SELECT SceneId, Date, Satellite FROM Scene WHERE OperatorId = 'VAZIO' 
AND Satellite = 'A1' AND Date = '$data' LIMIT 1"`
if [ "$pesq_aqua" ]
then
	sleep 30
	cd $dir
	sceneid_aqua=`echo $pesq_aqua | cut -d " " -f1`
	data_passagem_aqua=`echo $pesq_aqua | cut -d " " -f2`
	echo "Favor controlar a passagem abaixo:" 		>> emailAQUA
	echo "                                  " 		>> emailAQUA
	echo "Satelite: AQUA"  							>> emailAQUA 
	echo "SceneId:" $sceneid_aqua 					>> emailAQUA
	echo "Data da Passagem:" $data_passagem_aqua	>> emailAQUA
	echo "                                  " 		>> emailAQUA
	echo "Obrigado." 								>> emailAQUA
	echo "CDSR" 									>> emailAQUA	
	assunto="Controle de Qualidade AQUA"
	# envia o email #
	mail -s "$assunto" $contatos_dgi < emailAQUA
	cd $dir
	if [ -e emailAQUA ]
	then
		rm emailAQUA
		up_aqua=`mysql -u gerente -pgerente.200408 -D catalogo -s -e "UPDATE Scene SET OperatorId = 'AGUARDANDO' WHERE Satellite = 'A1' AND SceneId = '$sceneid_aqua'"`
	fi
fi

# TERRA #
pesq_terra=`mysql -u gerente -pgerente.200408 -D catalogo -s -e "SELECT SceneId, Date, Satellite FROM Scene WHERE OperatorId = 'VAZIO' 
AND Satellite = 'T1' AND Date = '$data' LIMIT 1"`
if [ "$pesq_terra" ]
then
	sleep 30
	cd $dir
	sceneid_terra=`echo $pesq_terra | cut -d " " -f1`
	data_passagem_terra=`echo $pesq_terra | cut -d " " -f2`
	echo "Favor controlar a passagem abaixo:" 		>> emailTERRA
	echo "                                  " 		>> emailTERRA
	echo "Satelite: TERRA"  						>> emailTERRA 
	echo "SceneId:" $sceneid_terra 					>> emailTERRA
	echo "Data da Passagem:" $data_passagem_terra	>> emailTERRA
	echo "                                  " 		>> emailTERRA
	echo "Obrigado." 								>> emailTERRA
	echo "CDSR" 									>> emailTERRA	
	assunto="Controle de Qualidade TERRA"
	# envia o email #
	mail -s "$assunto" $contatos_dgi < emailTERRA
	cd $dir
	if [ -e emailTERRA ]
	then
		rm emailTERRA
		up_terra=`mysql -u gerente -pgerente.200408 -D catalogo -s -e "UPDATE Scene SET OperatorId = 'AGUARDANDO' WHERE Satellite = 'T1' AND SceneId = '$sceneid_terra'"`
	fi
fi

# NPP #
pesq_npp=`mysql -u gerente -pgerente.200408 -D catalogo -s -e "SELECT SceneId, Date, Satellite FROM Scene WHERE OperatorId = 'VAZIO' 
AND Satellite = 'NPP' AND Date = '$data' LIMIT 1"`
if [ "$pesq_npp" ]
then
	sleep 30
	cd $dir
	sceneid_npp=`echo $pesq_npp | cut -d " " -f1`
	data_passagem_npp=`echo $pesq_npp | cut -d " " -f2`
	echo "Favor controlar a passagem  abaixo:" 		>> emailNPP
	echo "                                  " 		>> emailNPP
	echo "Satelite: S-NPP"  						>> emailNPP 
	echo "SceneId:" $sceneid_npp 					>> emailNPP
	echo "Data da Passagem:" $data_passagem_npp		>> emailNPP
	echo "                                  " 		>> emailNPP
	echo "Obrigado." 								>> emailNPP
	echo "CDSR" 									>> emailNPP	
	assunto="Controle de Qualidade S-NPP"
	# envia o email #
	mail -s "$assunto" $contatos_dgi < emailNPP
	cd $dir
	if [ -e emailNPP ]
	then
		rm emailNPP
		up_npp=`mysql -u gerente -pgerente.200408 -D catalogo -s -e "UPDATE Scene SET OperatorId = 'AGUARDANDO' WHERE Satellite = 'NPP' AND SceneId = '$sceneid_npp'"`
	fi
fi

cd $dir
echo "livre" > .execucaoMail

exit




