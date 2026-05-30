*** Settings ***
Documentation       Exemplo de impressao de nota de debito via sidebutton (dropdown) do botao Imprimir
...                 na toolbar de Contas a Pagar.
...                 O sidebutton (indice 9) fica a direita do botao Imprimir (indice 8) e abre um
...                 menu com a opcao "Nota de debito".
...                 Pre-requisito: estar na tela de Contas a Pagar com registros carregados no grid.
Resource            ../../resources/domains/contas_pagar.resource
Resource            ../../resources/data/contas_pagar_data.resource
Test Tags           examples    uauxt    contas-pagar    toolbar-acoes    imprimir-nota-debito


*** Variables ***
${LINHA_ALVO}                        4


*** Test Cases ***
Selecionar Linha E Imprimir Nota Debito Via Dropdown Toolbar
    [Documentation]    Seleciona a linha ${LINHA_ALVO} (0-based) do grid Processos de pagamento,
    ...                abre o dropdown do botao Imprimir (sidebutton idx=9) e clica em "Nota de debito"
    ...                para abrir a tela de impressao da nota de debito.
    ...                Pre-requisito: tela de Contas a Pagar aberta com registros no grid.
    Log    [CONTAS_PAGAR] Iniciando impressao de nota de debito na linha ${LINHA_ALVO}...    console=True
    Selecionar Linha E Imprimir Nota Debito    ${LINHA_ALVO}
    Log    [CONTAS_PAGAR] Nota de debito acionada para linha ${LINHA_ALVO}.    console=True
