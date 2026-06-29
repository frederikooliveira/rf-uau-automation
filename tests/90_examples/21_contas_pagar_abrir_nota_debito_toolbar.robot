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
Abrir Nota De Debito
    [Documentation]    Abre a tela de nota de debito a partir do grid de Processos de pagamento.
    ...                Pre-requisito: tela de Contas a Pagar aberta com registros no grid.
    Log    [CONTAS_PAGAR] Iniciando abertura da nota de debito na linha ${LINHA_ALVO}...    console=True
    Selecionar Linha E Imprimir Nota Debito    ${LINHA_ALVO}
    Log    [CONTAS_PAGAR] Nota de debito aberta para linha ${LINHA_ALVO}.    console=True
