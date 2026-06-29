*** Settings ***
Documentation       Diagnostico generico para localizar e analisar grids no UauXT por parametros.
Library             Collections
Library             String
Resource            ../../resources/apps/uauxt.resource
Resource            ../../resources/apps/uauxt_grid.resource
Test Tags           examples    uauxt    diagnostico


*** Variables ***
${DIAG_TARGET_TEXT}                 Contas a Pagar
${DIAG_GRID_INDEX}                  0
${DIAG_WINDOW_TITLE_REGEX}          UAUXT
${DIAG_CLASS_TOKENS_CSV}            TG80,C1Grid,GridOleDB,grid
${DIAG_TOP_CANDIDATES}              5


*** Keywords ***
Diagnosticar Grid Da Tela
    [Documentation]    Executa find-grid com parametros e retorna payload completo para analise.
    [Arguments]
    ...    ${target_text}=${DIAG_TARGET_TEXT}
    ...    ${grid_index}=${DIAG_GRID_INDEX}
    ...    ${window_title_regex}=${DIAG_WINDOW_TITLE_REGEX}
    ...    ${tokens_csv}=${DIAG_CLASS_TOKENS_CSV}
    ...    ${top_candidates}=${DIAG_TOP_CANDIDATES}
    Log    [DIAG-GRID] Iniciando diagnostico. target='${target_text}' grid_index=${grid_index}    console=True
    ${json_output}=    Executar Probe Grid UauXT
    ...    find-grid
    ...    --target-text
    ...    ${target_text}
    ...    --window-title-regex
    ...    ${window_title_regex}
    ...    --tokens
    ...    ${tokens_csv}
    ...    --grid-index
    ...    ${grid_index}
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Nao foi possivel localizar grid para diagnostico: ${payload}
    ${count}=    Get From Dictionary    ${payload}    count
    ${selected}=    Get From Dictionary    ${payload}    selected
    ${handle}=    Get From Dictionary    ${selected}    handle
    ${class_name}=    Get From Dictionary    ${selected}    class_name
    ${score}=    Get From Dictionary    ${selected}    score
    ${parent_chain}=    Get From Dictionary    ${selected}    parent_chain
    Log    [DIAG-GRID] Total de candidatos: ${count}    console=True
    Log    [DIAG-GRID] Selecionado: handle=${handle} class='${class_name}' score=${score}    console=True
    Log    [DIAG-GRID] Parent chain: ${parent_chain}    console=True
    Logar Top Candidatos Do Grid    ${payload}    ${top_candidates}
    RETURN    ${payload}

Logar Top Candidatos Do Grid
    [Documentation]    Exibe top candidatos para apoiar ajuste de target/tokens/grid_index.
    [Arguments]    ${payload}    ${top_candidates}=5
    ${candidates}=    Get From Dictionary    ${payload}    top_candidates
    ${total}=    Get Length    ${candidates}
    ${limit}=    Evaluate    min(int($top_candidates), int($total))
    Log    [DIAG-GRID] Exibindo top ${limit} de ${total} candidatos.    console=True
    FOR    ${idx}    IN RANGE    ${limit}
        ${item}=    Get From List    ${candidates}    ${idx}
        ${handle}=    Get From Dictionary    ${item}    handle
        ${class_name}=    Get From Dictionary    ${item}    class_name
        ${score}=    Get From Dictionary    ${item}    score
        ${left}=    Get From Dictionary    ${item}    left
        ${top}=    Get From Dictionary    ${item}    top
        ${right}=    Get From Dictionary    ${item}    right
        ${bottom}=    Get From Dictionary    ${item}    bottom
        Log
        ...    [DIAG-GRID] #${idx} handle=${handle} class='${class_name}' score=${score} rect=(${left},${top},${right},${bottom})
        ...    console=True
    END


*** Test Cases ***
Diagnosticar Grids De Tela Informada
    [Documentation]    Diagnostico parametrizavel de grids. Pode sobrescrever variaveis via --variable.
    ...                Ex.: --variable DIAG_TARGET_TEXT:Processos de pagamento
    ...                Ex.: --variable DIAG_GRID_INDEX:0 --variable DIAG_TOP_CANDIDATES:10
    ${payload}=    Diagnosticar Grid Da Tela
    Should Not Be Empty    ${payload}    Diagnostico nao retornou payload.
