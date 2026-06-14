*** Settings ***
Documentation       Fluxo de abertura do popup Relatorio demonstrativo de pagamentos.
...                 Pre-requisitos: UauXT aberto e logado; tela Resumo de Venda acessivel via menu.
Resource            ../../../resources/domains/vendas.resource
Test Tags           uauxt    vendas    relatorio-demonstrativo    popup    funcional    comportamento-unico


*** Variables ***
${LINHA_ALVO_RELATORIO}           2


*** Test Cases ***
Abrir Relatorio Demonstrativo De Pagamentos
    [Documentation]    Exibe o relatório de um demonstrativo de pagamento.
    Log    [DOM-VENDAS] Iniciando fluxo de abertura do Relatorio demonstrativo de pagamentos...    console=True
    Abrir Relatorio Demonstrativo De Pagamentos    ${LINHA_ALVO_RELATORIO}
    Log    [DOM-VENDAS] Fluxo de abertura do Relatorio demonstrativo concluido.    console=True
