*** Settings ***
Documentation       Dados de dominio para cadastro de pessoas no UauXT.
...                 Responsabilidade: massa de dados e locators de negocio.

*** Variables ***
# Massa de dados: Pessoas para testes
&{PESSOA_PADRAO}        nome=Joao Silva       cpf=11122233344    email=joao.silva@empresa.com    telefone=11999990001
&{PESSOA_ALTERNATIVA}   nome=Maria Souza      cpf=55566677788    email=maria.souza@empresa.com   telefone=21988880002
&{PESSOA_INVALIDA_CPF}  nome=Teste CPF Invalido    cpf=12345678900    email=cpf.invalido@empresa.com    telefone=31977770003

# Locators para formulario de cadastro de pessoas
# TODO: Configurar os locators abaixo apos mapear a UI real do sistema.
${MENU_PESSOAS_LOCATOR}         TODO_CONFIGURAR_MENU_PESSOAS
${BOTAO_NOVO_PESSOA_LOCATOR}    TODO_CONFIGURAR_BOTAO_NOVO
${CAMPO_NOME_PESSOA_LOCATOR}    TODO_CONFIGURAR_CAMPO_NOME
${CAMPO_CPF_PESSOA_LOCATOR}     TODO_CONFIGURAR_CAMPO_CPF
${CAMPO_EMAIL_PESSOA_LOCATOR}   TODO_CONFIGURAR_CAMPO_EMAIL
${CAMPO_TELEFONE_PESSOA_LOCATOR}    TODO_CONFIGURAR_CAMPO_TELEFONE
${BOTAO_GRAVAR_PESSOA_LOCATOR}  TODO_CONFIGURAR_BOTAO_GRAVAR
