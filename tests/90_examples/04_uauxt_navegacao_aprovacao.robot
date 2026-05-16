*** Settings ***
Documentation       Exemplo de navegação e acesso à tela de aprovação de pagamentos.
Resource            ../../resources/apps/uauxt.resource
Test Tags           examples    uauxt    navegacao

*** Test Cases ***
Exemplo Navegacao Para Tela Contas A Pagar
    [Documentation]    Com UauXT ja aberto/logado, navega por clique no icone do capacete de obras
    ...                e avanca nos subniveis ate Contas a Pagar.
    Acessar Contas A Pagar Via Icone Capacete Obras
    Log    [EXEMPLO] Navegacao lateral para tela Contas a Pagar concluida com sucesso.    console=True
