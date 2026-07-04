*** Settings ***
Documentation       Cria um novo usuário na tela de manutenção de usuários do UauXT.
...                 Pre-requisito: UauXT aberto e usuário autenticado.
Resource            ../../../resources/domains/seguranca.resource
Test Tags           uauxt    seguranca    usuarios    criar-usuario    funcional


*** Test Cases ***
Criar Novo Usuario Basico
    [Documentation]    Acessa a tela de usuários, abre um novo cadastro, preenche login/nome/e-mail e grava.
    ${login}=    Set Variable    user1
    ${nome}=    Set Variable    Usuario Teste
    ${email}=    Set Variable    teste.user@example.com

    Log    [DOM-SEG] Iniciando fluxo de criação de usuário...    console=True
    Acessar Usuarios Via Menu Lateral
    Clicar Botao Novo Na Tela Usuarios
    Preencher Cadastro Usuario Basico    ${login}    ${nome}    ${email}
    Clicar Botao Gravar Na Tela Usuarios
    Log    [DOM-SEG] Fluxo de criação de usuário concluído até o ponto de preenchimento dos campos.    console=True
