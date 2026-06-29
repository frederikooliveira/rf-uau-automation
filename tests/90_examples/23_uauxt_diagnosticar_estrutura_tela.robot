*** Settings ***
Documentation       Diagnostico estrutural generalista de tela UauXT (grids, sstabs, toolbars e controles).
...                 Objetivo: gerar insumos para estruturar data/apps/domain sem mapear todas as colunas.
Library             Collections
Resource            ../../resources/apps/uauxt.resource
Resource            ../../resources/apps/uauxt_grid.resource
Test Tags           examples    uauxt    diagnostico    mapeamento-estrutura


*** Variables ***
${DIAG_TARGET_TEXT}                     Resumo de venda
${DIAG_WINDOW_TITLE_REGEX}              UAUXT
${DIAG_GRID_TOKENS_CSV}                 TG80,C1Grid,GridOleDB,grid
${DIAG_GRID_INDEXES_CSV}                0,1
${DIAG_TOOLBAR_CLASS}                   msvb_lib_toolbar
${DIAG_SSTAB_CLASS}                     SSTabCtlWndClass
${DIAG_WINDOW_LOCATOR}                  id:MainView and type:WindowControl
${DIAG_PRINT_TREE_MAX_DEPTH}            12
${DIAG_MAX_CONTROLES_POR_CLASSE}        5
${DIAG_NAVEGAR_ANTES}                   ${False}
${DIAG_CAMINHO_MENU_CSV}                Financeiro,Gestao Financeira,Emissao de pagamentos
@{DIAG_CONTROL_CLASSES}
...    msvb_lib_toolbar
...    SSTabCtlWndClass
...    TG80.C1GridOleDB32.20


*** Test Cases ***
Mapear Estrutura Basica Da Tela UauXT
    [Documentation]    Diagnostico parametrizavel para qualquer tela UauXT.
    ...                Sobrescreva variaveis via --variable (target_text, grid_indexes, classes etc.).
    Log    [DIAG-TELA] Iniciando diagnostico estrutural generalista...    console=True
    Log    [DIAG-TELA] Target='${DIAG_TARGET_TEXT}' Grids='${DIAG_GRID_INDEXES_CSV}'    console=True
    Navegar Para Tela De Diagnostico Se Solicitado
    Run Keyword And Ignore Error    Control Window    ${DIAG_WINDOW_LOCATOR}
    Diagnosticar Grids Por Lista
    Diagnosticar SSTabs
    Diagnosticar Toolbars
    Diagnosticar Controles Principais
    Run Keyword And Ignore Error
    ...    Print Tree    ${DIAG_WINDOW_LOCATOR}    max_depth=${DIAG_PRINT_TREE_MAX_DEPTH}    log_as_warnings=True
    Log    [DIAG-TELA] Diagnostico concluido.    console=True


*** Keywords ***
Diagnosticar Grids Por Lista
    [Documentation]    Executa find-grid para cada indice informado em DIAG_GRID_INDEXES_CSV.
    ${grid_indexes}=    Obter Lista A Partir De Csv    ${DIAG_GRID_INDEXES_CSV}
    FOR    ${grid_index}    IN    @{grid_indexes}
        Diagnosticar Grid Por Indice    ${grid_index}
    END

Diagnosticar Grid Por Indice
    [Documentation]    Executa find-grid para um indice especifico e registra resultado sem falhar diagnostico.
    [Arguments]    ${grid_index}
    ${json_output}=    Executar Probe Grid UauXT
    ...    find-grid
    ...    --target-text
    ...    ${DIAG_TARGET_TEXT}
    ...    --window-title-regex
    ...    ${DIAG_WINDOW_TITLE_REGEX}
    ...    --tokens
    ...    ${DIAG_GRID_TOKENS_CSV}
    ...    --grid-index
    ...    ${grid_index}
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${ok}=    Get From Dictionary    ${payload}    ok
    IF    ${ok}
        Logar Grid Selecionado Do Diagnostico    ${payload}    ${grid_index}
        RETURN
    END
    Log    [DIAG-TELA] Grid idx=${grid_index} nao encontrado com target atual.    console=True

Logar Grid Selecionado Do Diagnostico
    [Documentation]    Extrai os dados do grid selecionado e escreve no log.
    [Arguments]    ${payload}    ${grid_index}
    ${selected}=    Get From Dictionary    ${payload}    selected
    ${handle}=    Get From Dictionary    ${selected}    handle
    ${class_name}=    Get From Dictionary    ${selected}    class_name
    ${left}=    Get From Dictionary    ${selected}    left
    ${top}=    Get From Dictionary    ${selected}    top
    ${right}=    Get From Dictionary    ${selected}    right
    ${bottom}=    Get From Dictionary    ${selected}    bottom
    Log
    ...    [DIAG-TELA] Grid idx=${grid_index} handle=${handle} class=${class_name}
    ...    console=True
    Log    [DIAG-TELA] Grid idx=${grid_index} rect=(${left},${top},${right},${bottom})    console=True

Diagnosticar SSTabs
    [Documentation]    Lista quantos controles SSTabCtlWndClass estao presentes e registra posicoes.
    ${sstabs}=    Obter Elementos Por Classe    ${DIAG_SSTAB_CLASS}    SSTabs
    ${count}=    Get Length    ${sstabs}
    IF    ${count} < 1
        RETURN
    END
    Log    [DIAG-TELA] SSTabs detectados: ${count}    console=True
    Logar Lista De SSTabs    ${sstabs}    ${count}

Logar Lista De SSTabs
    [Documentation]    Itera pelos SSTabs encontrados e registra retangulos.
    [Arguments]    ${sstabs}    ${count}
    FOR    ${idx}    IN RANGE    ${count}
        ${ctrl}=    Get From List    ${sstabs}    ${idx}
        ${left}=    Evaluate    int($ctrl.left)
        ${top}=    Evaluate    int($ctrl.top)
        ${right}=    Evaluate    int($ctrl.right)
        ${bottom}=    Evaluate    int($ctrl.bottom)
        Log    [DIAG-TELA] SSTab #${idx} rect=(${left},${top},${right},${bottom})    console=True
    END

Diagnosticar Toolbars
    [Documentation]    Lista botoes das toolbars VB6 detectadas pela classe informada.
    ${status}    ${payload}=    Run Keyword And Ignore Error
    ...    Listar Botoes Toolbar Via Probe    ${DIAG_TOOLBAR_CLASS}
    IF    '${status}' != 'PASS'
        Log    [DIAG-TELA] Toolbars: classe ${DIAG_TOOLBAR_CLASS} nao encontrada.    console=True
        RETURN
    END
    Should Not Be Empty    ${payload}

Diagnosticar Controles Principais
    [Documentation]    Lista quantidade e exemplos de controles por classe para gerar insumos de estrutura.
    FOR    ${class_name}    IN    @{DIAG_CONTROL_CLASSES}
        Diagnosticar Classe De Controle    ${class_name}
    END

Navegar Para Tela De Diagnostico Se Solicitado
    [Documentation]    Quando DIAG_NAVEGAR_ANTES=True, navega pelo caminho de menu antes do diagnostico.
    IF    not ${DIAG_NAVEGAR_ANTES}
        RETURN
    END
    @{caminho_menu}=    Obter Lista A Partir De Csv    ${DIAG_CAMINHO_MENU_CSV}
    ${caminho_log}=    Catenate    SEPARATOR= >     @{caminho_menu}
    Log    [DIAG-TELA] Navegando pelo menu: ${caminho_log}    console=True
    Run Keyword And Ignore Error    Acessar Caminho No Menu Lateral Angular    @{caminho_menu}

Obter Elementos Por Classe
    [Documentation]    Retorna elementos da classe ou lista vazia sem interromper diagnostico.
    [Arguments]    ${class_name}    ${rotulo}
    ${status}    ${elements}=    Run Keyword And Ignore Error    Get Elements    class:${class_name}
    IF    '${status}' == 'PASS'
        RETURN    ${elements}
    END
    Log    [DIAG-TELA] ${rotulo}: classe ${class_name} nao encontrada.    console=True
    @{empty}=    Create List
    RETURN    @{empty}

Diagnosticar Classe De Controle
    [Documentation]    Loga total de controles da classe e exemplos com nome/rect.
    [Arguments]    ${class_name}
    ${status}    ${elements}=    Run Keyword And Ignore Error    Get Elements    class:${class_name}
    IF    '${status}' != 'PASS'
        Log    [DIAG-TELA] Classe ${class_name}: nao encontrada.    console=True
        RETURN
    END
    ${count}=    Get Length    ${elements}
    Log    [DIAG-TELA] Classe ${class_name}: total=${count}    console=True
    ${limit}=    Evaluate    min(int($count), int($DIAG_MAX_CONTROLES_POR_CLASSE))
    FOR    ${idx}    IN RANGE    ${limit}
        ${ctrl}=    Get From List    ${elements}    ${idx}
        Logar Controle De Exemplo    ${class_name}    ${idx}    ${ctrl}
    END

Logar Controle De Exemplo
    [Documentation]    Loga dados resumidos de um controle para apoiar criacao de locators.
    [Arguments]    ${class_name}    ${idx}    ${ctrl}
    ${name}=    Evaluate    str(getattr($ctrl, 'name', ''))
    ${left}=    Evaluate    int($ctrl.left)
    ${top}=    Evaluate    int($ctrl.top)
    ${right}=    Evaluate    int($ctrl.right)
    ${bottom}=    Evaluate    int($ctrl.bottom)
    Log
    ...    [DIAG-TELA] Classe ${class_name} #${idx}: name='${name}' rect=(${left},${top},${right},${bottom})
    ...    console=True

Obter Lista A Partir De Csv
    [Documentation]    Converte CSV em lista sem espacos em branco nas pontas.
    [Arguments]    ${csv_value}
    @{values}=    Evaluate    [item.strip() for item in str($csv_value).split(',') if item.strip()]
    RETURN    @{values}
