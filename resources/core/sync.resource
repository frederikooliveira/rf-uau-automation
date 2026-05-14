*** Settings ***
Documentation       Camada de sincronizacao inteligente para padroes comuns de espera.
...                 Encapsula Sleep + Wait Until com logica mais semantica.
Library             RPA.Windows
Library             Collections

*** Keywords ***
Aguardar Popup Informa
    [Documentation]    Aguarda um popup de informacao (titulo contendo "Informa").
    [Arguments]    ${timeout}=50s    ${intervalo}=1s
    [Tags]    popup
    Log    [SYNC] Procurando popup de informacao...    console=True
    Wait Until Keyword Succeeds    ${timeout}    ${intervalo}
    ...    Run Keyword And Return Status
    ...    Control Window    subname:Informa
    Log    [SYNC] Popup de informacao detectado.    console=True

Clicar OK Em Popup Informa
    [Documentation]    Clica em OK no popup de informacao.
    [Arguments]    ${timeout}=5s
    [Tags]    popup
    Control Window    subname:Informa
    ${clicou}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${timeout}    0.5s
    ...    Click    name:OK and type:ButtonControl
    IF    not ${clicou}
        Send Keys    keys={Enter}
    END
    Log    [SYNC] OK clicado em popup.    console=True

Fechar Popup Informa
    [Documentation]    Aguarda e fecha popup de informacao em uma keyword.
    [Arguments]    ${timeout}=50s
    [Tags]    popup
    Aguardar Popup Informa    ${timeout}
    Clicar OK Em Popup Informa
    Log    [SYNC] Popup de informacao fechado.    console=True

Aguardar Elemento Com Log
    [Documentation]    Aguarda elemento com log descritivo ao inicio e fim.
    [Arguments]    ${locator}    ${descricao}    ${timeout}=20s
    Log    [SYNC] Aguardando ${descricao} (${locator})...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s    Get Element    ${locator}
    Log    [SYNC] ${descricao} disponivel.    console=True

Pausa Controlada
    [Documentation]    Sleep com motivo registrado em log.
    [Arguments]    ${duracao}    ${motivo}
    Log    [SYNC] Pausa de ${duracao}: ${motivo}    console=True
    Sleep    ${duracao}
