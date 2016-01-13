#!/bin/bash -x


#Variaveis de diretorio#
dir=/home/cdsr/bin
dir_tarefa=/intranet/producao/Controle_de_processos_do_desenvolvimento/id_tarefa

#var=`mysql -u gerente -p gerente.200408 -D teste01 -s -e "select count(*) from teste01"`;

var=`mysql -u gerente -pgerente.200408 -D gerente_io -s -e "SELECT id, id_tarefa, module, argument, host, who FROM Report_turno WHERE envio_email = '' AND (module = 'g2q' OR module = 'tar2q') GROUP BY id_tarefa LIMIT 1"`

#var=`mysql -u gerente -pgerente.200408 -D gerente_io -s -e "SELECT * FROM Report_turno WHERE envio_email = '' AND (module = 'g2q' OR module = 'tar2q') GROUP BY id_tarefa LIMIT 1"`

#var=`mysql -u gerente -pgerente.200408 -D gerente_io -s -e "SELECT * FROM Report_turno"`

echo $var > resultado.txt
#echo "teste" > resultado.txt
# Destinatario de email #
contatos_dgi="jose.azevedo@dgi.inpe.br, cq-dgi@dgi.inpe.br"
#contatos_dgi="cq-dgi@dgi.inpe.br"
#contatos_dgi="jose.azevedo@dgi.inpe.br"
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

cd $dir
#rm -rf resultado.txt
exit




