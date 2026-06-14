*** Settings ***
Documentation       Keywords de automacao tecnica para telas financeiras do UauXT.
...                 Responsabilidade: interacoes tecnicas de UI para Emissao de pagamentos.
Library             RPA.Windows
Resource            ../core/ui_helpers.resource
Resource            ../core/sync.resource
Resource            ../data/financeiro_data.resource


*** Keywords ***
Aguardar Tela Emissao Pagamentos
    [Documentation]    Aguarda abertura da tela, mede o tempo e valida o limite configurado.
    Log    [UAUXT-FIN] Aguardando contexto da tela Emissao de pagamentos...    console=True
    ${tempo_abertura_ms}=    Aguardar Tela Com Tempo De Abertura
    ...    ${FIN_EMI_WINDOW_LOCATOR}
    ...    tela Emissao de pagamentos
    ...    janela
    ...    ${FIN_EMI_TIMEOUT_PADRAO}
    ...    ${FIN_EMI_TEMPO_MAX_ABERTURA_MS}
    Log    [UAUXT-FIN] Contexto da tela pronto em ${tempo_abertura_ms} ms.    console=True

Aplicar Filtro Emissao Pagamentos
    [Documentation]    Clica no botao de filtro quando o locator estiver configurado.
    Log    [UAUXT-FIN] Aplicando filtro da tela...    console=True
    Should Not Start With    ${FIN_EMI_BTN_FILTRAR_LOCATOR}    TODO_CONFIGURAR_
    Click    ${FIN_EMI_BTN_FILTRAR_LOCATOR}
    Pausa Controlada    ${FIN_EMI_DELAY_CURTO_MS}    Aguardando resultado do filtro
    Log    [UAUXT-FIN] Filtro aplicado.    console=True
