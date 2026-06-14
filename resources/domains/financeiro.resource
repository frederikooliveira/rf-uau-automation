*** Settings ***
Documentation       Keywords de dominio para fluxos financeiros no UauXT.
...                 Responsabilidade: compor fluxos de negocio para Emissao de pagamentos.
Library             Collections
Library             String
Resource            ../apps/uauxt.resource
Resource            ../apps/uauxt_grid.resource
Resource            ../apps/uauxt_financeiro.resource


*** Keywords ***
Validar Locator Configurado
    [Documentation]    Falha cedo quando um locator nao foi mapeado.
    [Arguments]    ${locator}    ${nome_locator}
    IF    '${locator}'.startswith('TODO_CONFIGURAR_')
        Fail    Locator nao configurado: ${nome_locator}. Atualize em resources/data/financeiro_data.resource.
    END

Navegar Para Emissao De Pagamentos
    [Documentation]    Navega pelo menu lateral ate a tela de Emissao de pagamentos.
    Log    [DOM-FIN] Navegando para Emissao de pagamentos...    console=True
    Acessar Item Via Icone Capacete Obras
    ...    ${UAUXT_SUBMENU_FINANCEIRO_TEXTO}
    ...    ${UAUXT_SUBMENU_GESTAO_FINANCEIRA_TEXTO}
    ...    ${UAUXT_SUBMENU_EMISSAO_PAGAMENTOS_TEXTO}
    ${tempo_abertura_ms}=    Aguardar Tela Com Tempo De Abertura
    ...    ${FIN_EMI_WINDOW_LOCATOR}
    ...    tela Emissao de pagamentos
    ...    janela
    ...    ${FIN_EMI_TIMEOUT_PADRAO}
    ...    ${FIN_EMI_TEMPO_MAX_ABERTURA_MS}
    Log    [DOM-FIN] Tela de Emissao de pagamentos acessada em ${tempo_abertura_ms} ms.    console=True

Validar Estrutura Emissao Pagamentos
    [Documentation]    Valida grids principais e inventario de toolbar da tela.
    Log    [DOM-FIN] Validando estrutura tecnica da tela...    console=True
    ${grid_main}=    Registrar Grid UauXT Por Win32
    ...    ${FIN_EMI_TARGET_TEXT}
    ...    ${FIN_EMI_GRID_PRINCIPAL_INDEX}
    Should Not Be Empty    ${grid_main}
    ${grid_sec}=    Registrar Grid UauXT Por Win32
    ...    ${FIN_EMI_TARGET_TEXT}
    ...    ${FIN_EMI_GRID_SECUNDARIO_INDEX}
    Should Not Be Empty    ${grid_sec}
    ${toolbars}=    Listar Botoes Toolbar Via Probe    ${FIN_EMI_TOOLBAR_CLASS}
    Should Not Be Empty    ${toolbars}
    Log    [DOM-FIN] Estrutura validada (grids + toolbar).    console=True
