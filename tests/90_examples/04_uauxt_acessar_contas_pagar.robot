*** Settings ***
Documentation       Exemplo de navegação e acesso à tela de aprovação de pagamentos.
Resource            ../../resources/apps/uauxt.resource
Test Tags           examples    uauxt    navegacao

*** Test Cases ***
Acessar Contas A Pagar
    [Documentation]    Acessa a tela Contas a Pagar a partir do UauXT.
    Acessar Contas A Pagar Via Icone Capacete Obras
    Log    [EXEMPLO] Tela Contas A Pagar acessada com sucesso.    console=True
