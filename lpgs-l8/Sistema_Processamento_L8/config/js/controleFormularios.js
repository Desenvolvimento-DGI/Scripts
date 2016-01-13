// JavaScript Document
// Funcao que controle o preenchimento do formulario de cobertura de nuvens //
function validaForm(){
	form = document.cobNuvens;
	// Verifica se o campo está vazio //
	if (form.Q1.value == "")
	{
		alert("CAMPO DE COBERTURA DE NUVENS É OBRIGATÓRIO");
        form.Q1.focus();
        return false;
	}
	if (form.Q2.value == "")
	{
		alert("CAMPO DE COBERTURA DE NUVENS É OBRIGATÓRIO");
        form.Q2.focus();
        return false;
	}
	if (form.Q3.value == "")
	{
		alert("CAMPO DE COBERTURA DE NUVENS É OBRIGATÓRIO");
        form.Q3.focus();
        return false;
	}
	if (form.Q4.value == "")
	{
		alert("CAMPO DE COBERTURA DE NUVENS É OBRIGATÓRIO");
        form.Q4.focus();
        return false;
	}
	// Verifica se foi informado numeros de 0 a 100 apenas - multiplos de 10 //
	if (form.Q1.value != 0 && form.Q1.value != 10 && form.Q1.value != 20 && form.Q1.value != 30 && form.Q1.value != 40 && form.Q1.value != 50 && form.Q1.value != 60 && form.Q1.value != 70 && form.Q1.value != 70 && form.Q1.value != 80 && form.Q1.value != 90 && form.Q1.value != 100 )
	{
		alert("VALOR NÃO PERMITIDO");
        form.Q1.focus();
        return false;
	}
	if (form.Q2.value != 0 && form.Q2.value != 10 && form.Q2.value != 20 && form.Q2.value != 30 && form.Q2.value != 40 && form.Q2.value != 50 && form.Q2.value != 60 && form.Q2.value != 70 && form.Q2.value != 70 && form.Q2.value != 80 && form.Q2.value != 90 && form.Q2.value != 100 )
	{
		alert("VALOR NÃO PERMITIDO");
        form.Q2.focus();
        return false;
	}
	if (form.Q3.value != 0 && form.Q3.value != 10 && form.Q3.value != 20 && form.Q3.value != 30 && form.Q3.value != 40 && form.Q3.value != 50 && form.Q3.value != 60 && form.Q3.value != 70 && form.Q3.value != 70 && form.Q3.value != 80 && form.Q3.value != 90 && form.Q3.value != 100 )
	{
		alert("VALOR NÃO PERMITIDO");
        form.Q3.focus();
        return false;
	}
	if (form.Q4.value != 0 && form.Q4.value != 10 && form.Q4.value != 20 && form.Q4.value != 30 && form.Q4.value != 40 && form.Q4.value != 50 && form.Q4.value != 60 && form.Q4.value != 70 && form.Q4.value != 70 && form.Q4.value != 80 && form.Q4.value != 90 && form.Q4.value != 100 )
	{
		alert("VALOR NÃO PERMITIDO");
        form.Q4.focus();
        return false;
	}
	
}