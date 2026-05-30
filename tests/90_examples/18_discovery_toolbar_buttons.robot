*** Settings ***
Documentation       Discovery automatico de botoes de toolbar msvb_lib_toolbar via hover + tooltip.
...                 Faz hover com o mouse em cada botao da toolbar da tela ativa no UauXT e
...                 captura o nome do tooltip VB6. Gera um mapa completo de index -> nome.
...
...                 ATENCAO: nao interagir com o mouse durante a execucao (dura ~15s para 15 botoes).
...                 PRE-REQUISITO: abrir no UauXT a tela cuja toolbar voce quer mapear.
...
...                 Uso: .\robot-runner.ps1 tag toolbar-discovery
...                 Saida: tabela no log com index, nome, screen_center por botao.
Resource            ../../resources/apps/uauxt_grid.resource
Test Tags           examples    uauxt    toolbar-discovery    listar-toolbar


*** Test Cases ***
Mapear Todos Os Botoes Da Toolbar Ativa
    [Documentation]    Faz hover em cada botao da toolbar da tela aberta no UauXT e captura
    ...                o nome via tooltip VB6 (msvb_lib_tooltips). Imprime mapa completo no log.
    ...                Copie os nomes para contas_pagar_data.resource substituindo TODO_CONFIGURAR_TOOLBAR_IDX_N.
    ${payload}=    Mapear Botoes Toolbar Via Probe
    ${mapping}=    Get From Dictionary    ${payload}    mapping
    ${mapped}=     Get From Dictionary    ${payload}    mapped
    ${total}=      Get From Dictionary    ${payload}    total_buttons
    Log    [DISCOVERY] ============================================================    console=True
    Log    [DISCOVERY] MAPA DE BOTOES DA TOOLBAR                                      console=True
    Log    [DISCOVERY] ============================================================    console=True
    FOR    ${btn}    IN    @{mapping}
        ${idx}=    Get From Dictionary    ${btn}    index
        ${sep}=    Get From Dictionary    ${btn}    is_separator
        IF    ${sep}
            Log    [DISCOVERY] idx=${idx} --- SEPARADOR ---    console=True
        ELSE
            ${name}=    Get From Dictionary    ${btn}    name
            ${sc}=      Get From Dictionary    ${btn}    screen_center
            ${sc_str}=  Convert To String    ${sc}
            ${msg}=     Set Variable    [DISCOVERY] idx=${idx}  name="${name}"  screen_center=${sc_str}
            Log    ${msg}    console=True
        END
    END
    Log    [DISCOVERY] ============================================================    console=True
    Log    [DISCOVERY] Resultado: ${mapped}/${total} botoes com nome identificado.    console=True
    Log    [DISCOVERY] Botoes com "?" = tooltip nao capturado (identifique por screen_center).    console=True
    Should Be True    ${total} > 0    Nenhum botao encontrado na toolbar.
