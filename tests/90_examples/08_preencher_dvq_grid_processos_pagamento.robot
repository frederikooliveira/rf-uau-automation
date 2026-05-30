*** Settings ***
Documentation       Exemplo de preenchimento da coluna Confirmado no grid Processos de pagamento.
Library             Collections
Resource            ../../resources/apps/uauxt.resource
Resource            ../../resources/apps/uauxt_grid.resource
Test Tags           examples    uauxt    diagnostico    dvq-grid


*** Variables ***
${COLUNA_CONFIRMADO}               5
${VALOR_DVQ}                       DVQ
${LINHA_INICIAL_DVQ}               2
${LINHA_FINAL_DVQ}                 3


*** Test Cases ***
Preencher DVQ Na Coluna Confirmado Do Grid Processos Pagamento
    [Documentation]    Localiza o grid e altera celulas da coluna Confirmado em uma faixa de linhas (por padrao, 1-based).
    ...                Pre-requisito: estar na tela de Processos de pagamento com grid visivel.
    Log    [DIAG-GRID] Iniciando preenchimento de DVQ no grid de Processos de pagamento...    console=True
    ${payload}=    Alterar Celulas No Grid Processos Pagamento Por Faixa De Linhas
    ...    ${COLUNA_CONFIRMADO}
    ...    ${VALOR_DVQ}
    ...    ${LINHA_INICIAL_DVQ}
    ...    ${LINHA_FINAL_DVQ}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Preenchimento de DVQ por faixa de linhas falhou.
   # Log    [DIAG-GRID] Validando valores gravados na faixa ${LINHA_INICIAL_DVQ}..${LINHA_FINAL_DVQ}...    console=True
   # ${inicio}=    Convert To Integer    ${LINHA_INICIAL_DVQ}
   # ${fim}=    Convert To Integer    ${LINHA_FINAL_DVQ}
   # FOR    ${linha}    IN RANGE    ${inicio}    ${fim + 1}
   #     ${valor_lido}=    Ler Valor Da Celula No Grid Processos Pagamento
   #     ...    ${linha}
   #     ...    ${COLUNA_CONFIRMADO}
   #     Should Be Equal As Strings    ${valor_lido}    ${VALOR_DVQ}
   #     ...    Linha ${linha}: esperado '${VALOR_DVQ}' mas encontrado '${valor_lido}'
   #     Log    [DIAG-GRID] Linha ${linha} OK: '${valor_lido}'    console=True
   # END
   # Log    [DIAG-GRID] Preenchimento de DVQ concluido e validado com sucesso.    console=True
