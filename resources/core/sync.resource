*** Settings ***
Documentation       Camada de sincronizacao inteligente para padroes comuns de espera.
...                 Encapsula Sleep + Wait Until com logica mais semantica.
Library             Collections
Library             RPA.Windows


*** Keywords ***
Aguardar Popup Informa
    [Documentation]    Aguarda um popup de informacao (titulo contendo "Informa").
    [Tags]    popup
    [Arguments]    ${timeout}=50s    ${intervalo}=1s
    Log    [SYNC] Procurando popup de informacao...    console=True
    Wait Until Keyword Succeeds    ${timeout}    ${intervalo}
    ...    Run Keyword And Return Status
    ...    Control Window    subname:Informa
    Log    [SYNC] Popup de informacao detectado.    console=True

Clicar OK Em Popup Informa
    [Documentation]    Clica em OK no popup de informacao.
    [Tags]    popup
    [Arguments]    ${timeout}=5s
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
    [Tags]    popup
    [Arguments]    ${timeout}=50s
    Aguardar Popup Informa    ${timeout}
    Clicar OK Em Popup Informa
    Log    [SYNC] Popup de informacao fechado.    console=True

Aguardar Elemento Com Log
    [Documentation]    Aguarda elemento com log descritivo ao inicio e fim.
    [Arguments]    ${locator}    ${descricao}    ${timeout}=20s
    Log    [SYNC] Aguardando ${descricao} (${locator})...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s    Get Element    ${locator}
    Log    [SYNC] ${descricao} disponivel.    console=True

Aguardar Elemento Com Tempo De Abertura
    [Documentation]    Aguarda elemento, mede tempo de abertura e valida opcionalmente um limite maximo em ms.
    [Arguments]    ${locator}    ${descricao}    ${timeout}=20s    ${intervalo}=1s    ${tempo_maximo_ms}=${None}
    Log    [SYNC] Aguardando ${descricao} (${locator})...    console=True
    ${inicio}=    Evaluate    __import__('time').perf_counter()
    Wait Until Keyword Succeeds    ${timeout}    ${intervalo}    Get Element    ${locator}
    ${fim}=    Evaluate    __import__('time').perf_counter()
    ${tempo_ms}=    Evaluate    int(round((${fim} - ${inicio}) * 1000))
    ${tempo_s}=    Evaluate    round((${fim} - ${inicio}), 3)
    Log    [SYNC] ${descricao} disponivel em ${tempo_s}s (${tempo_ms} ms).    console=True
    IF    $tempo_maximo_ms is not None
        Should Be True
        ...    ${tempo_ms} <= ${tempo_maximo_ms}
        ...    Tempo de abertura acima do limite para ${descricao}: ${tempo_ms} ms > ${tempo_maximo_ms} ms.
    END
    RETURN    ${tempo_ms}

Aguardar Janela Com Tempo De Abertura
    [Documentation]    Aguarda janela com Control Window, mede tempo e valida opcionalmente um limite maximo em ms.
    [Arguments]    ${window_locator}    ${descricao}    ${timeout}=20s    ${intervalo}=1s    ${tempo_maximo_ms}=${None}
    Log    [SYNC] Aguardando ${descricao} (${window_locator})...    console=True
    ${inicio}=    Evaluate    __import__('time').perf_counter()
    Wait Until Keyword Succeeds    ${timeout}    ${intervalo}    Control Window    ${window_locator}
    ${fim}=    Evaluate    __import__('time').perf_counter()
    ${tempo_ms}=    Evaluate    int(round((${fim} - ${inicio}) * 1000))
    ${tempo_s}=    Evaluate    round((${fim} - ${inicio}), 3)
    Log    [SYNC] ${descricao} disponivel em ${tempo_s}s (${tempo_ms} ms).    console=True
    IF    $tempo_maximo_ms is not None
        Should Be True
        ...    ${tempo_ms} <= ${tempo_maximo_ms}
        ...    Tempo de abertura acima do limite para ${descricao}: ${tempo_ms} ms > ${tempo_maximo_ms} ms.
    END
    RETURN    ${tempo_ms}

Aguardar Tela Com Tempo De Abertura
    [Documentation]    Aguarda uma tela por janela ou elemento, mede tempo de abertura e valida limite opcional.
    [Arguments]    ${locator}    ${descricao}    ${tipo_espera}=janela
    ...    ${timeout}=20s    ${tempo_maximo_ms}=${None}
    IF    '${tipo_espera}' == 'janela'
        ${tempo_ms}=    Aguardar Janela Com Tempo De Abertura
        ...    ${locator}
        ...    ${descricao}
        ...    ${timeout}
        ...    1s
        ...    ${tempo_maximo_ms}
        RETURN    ${tempo_ms}
    END
    IF    '${tipo_espera}' == 'elemento'
        ${tempo_ms}=    Aguardar Elemento Com Tempo De Abertura
        ...    ${locator}
        ...    ${descricao}
        ...    ${timeout}
        ...    1s
        ...    ${tempo_maximo_ms}
        RETURN    ${tempo_ms}
    END
    Fail    Tipo de espera invalido: ${tipo_espera}. Use janela ou elemento.

Pausa Controlada
    [Documentation]    Sleep com motivo registrado em log.
    [Arguments]    ${duracao}    ${motivo}
    Log    [SYNC] Pausa de ${duracao}: ${motivo}    console=True
    Sleep    ${duracao}
