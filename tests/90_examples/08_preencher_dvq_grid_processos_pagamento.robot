*** Settings ***
Documentation       Exemplo de preenchimento da coluna Confirmado no grid Processos de pagamento.
Library             Collections
Resource            ../../resources/apps/uauxt.resource
Resource            ../../resources/apps/uauxt_grid.resource
Test Tags           examples    uauxt    diagnostico    dvq


*** Test Cases ***
Preencher DVQ Na Coluna Confirmado Do Grid Processos Pagamento
    [Documentation]    Localiza o grid e altera celulas da coluna Confirmado nas linhas 1 e 2.
    ...                Pre-requisito: estar na tela de Processos de pagamento com grid visivel.
    Log    [DIAG-GRID] Iniciando preenchimento de DVQ no grid de Processos de pagamento...    console=True
    ${payload_linha_1}=    Alterar Celula No Grid Processos Pagamento    0    5    DVQ
    ${ok_linha_1}=    Get From Dictionary    ${payload_linha_1}    ok
    Should Be True    ${ok_linha_1}    Preenchimento de DVQ na linha 1 falhou.
    ${payload_linha_2}=    Alterar Celula No Grid Processos Pagamento    1    5    DVQ
    ${ok_linha_2}=    Get From Dictionary    ${payload_linha_2}    ok
    Should Be True    ${ok_linha_2}    Preenchimento de DVQ na linha 2 falhou.
    Log    [DIAG-GRID] Preenchimento de DVQ concluido com sucesso.    console=True
