*** Settings ***
Documentation       Fluxo de acesso a tela Emissao de pagamentos.
...                 Pre-requisito: UauXT aberto e usuario autenticado.
Resource            ../../../resources/domains/financeiro.resource
Test Tags           uauxt    financeiro    emissao-pagamentos    funcional    comportamento-unico


*** Test Cases ***
Acessar Tela Emissao De Pagamentos
    [Documentation]    Acessa a tela Emissao de pagamentos.
    Log    [DOM-FIN] Iniciando acesso a tela Emissao de pagamentos...    console=True
    Navegar Para Emissao De Pagamentos
    Log    [DOM-FIN] Tela Emissao de pagamentos acessada com sucesso.    console=True
