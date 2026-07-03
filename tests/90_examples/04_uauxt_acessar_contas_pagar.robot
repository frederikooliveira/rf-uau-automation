*** Settings ***
Documentation       Exemplo de navegação e acesso à tela de aprovação de pagamentos.
Resource            ../../resources/domains/financeiro.resource
Test Tags           examples    uauxt    navegacao    navegar-contas-pagar

*** Test Cases ***
Acessar Contas A Pagar
    [Documentation]    Acessa a tela Contas a Pagar a partir do UauXT.
    financeiro.Acessar Contas A Pagar Via Icone Capacete Obras
    Log    [EXEMPLO] Tela Contas A Pagar acessada com sucesso.    console=True
