*** Settings ***
Documentation       Fluxo de busca e impressao de resumo na tela Resumo de Venda.
...                 Pre-requisitos: UauXT aberto e logado; tela Resumo de Venda acessivel via menu.
Resource            ../../../resources/domains/vendas.resource
Test Tags           uauxt    vendas    resumo-venda    funcional    comportamento-unico


*** Variables ***
${EMPRESA_PADRAO}      262


*** Test Cases ***
Acessar Tela Resumo de Vendas
    [Documentation]    Imprime o resumo da tela Resumo de Venda.
    Log    [DOM-VENDAS] Iniciando impressao do resumo de venda...    console=True
    Navegar Para Resumo De Venda
    Buscar Vendas Por Empresa E Todas As Obras    ${EMPRESA_PADRAO}
    Log    [DOM-VENDAS] Impressao do resumo de venda concluida com sucesso.    console=True
