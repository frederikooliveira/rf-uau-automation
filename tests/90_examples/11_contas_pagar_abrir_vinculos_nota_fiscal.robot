*** Settings ***
Documentation       Exemplo para abrir Vinculos Nota Fiscal pelo botao de celula no grid de Processos de pagamento.
Resource            ../../resources/apps/uauxt_grid.resource
Test Tags           examples    uauxt    contas-pagar    vinculos-nota-fiscal    grid-botao


*** Variables ***
${LINHA_ALVO}                        0
${COLUNA_BOTAO_VINCULOS_NF}          13


*** Test Cases ***
Abrir Vinculos Nota Fiscal Pela Celula Do Grid
    [Documentation]    Considera a tela ja aberta e com dados carregados no grid de Processos de pagamento.
    Log
    ...    [EXEMPLO] Enviando Alt+Seta para baixo na celula (linha 1, coluna 13) para abrir Vinculos Nota Fiscal...
    ...    console=True
    ${payload}=    Clicar Botao Da Celula No Grid Processos Pagamento
    ...    ${LINHA_ALVO}
    ...    ${COLUNA_BOTAO_VINCULOS_NF}
    ...    alt-down
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Nao foi possivel abrir Vinculos Nota Fiscal a partir da celula alvo.
    Pausa Controlada    1s    Aguardando abertura da tela Vinculos Nota Fiscal
    Log    [EXEMPLO] Acao de abertura de Vinculos Nota Fiscal executada.    console=True
