*** Settings ***
Documentation       Camada técnica de helpers genéricos para automação UI Windows.
...                 Responsabilidade: encontrar, clicar, digitar em controles genéricos.
...                 Independente de aplicação.
Library             RPA.Windows
Library             Process

*** Keywords ***
Clicar Elemento Quando Disponivel
    [Documentation]    Clica em qualquer elemento da UI assim que ele estiver disponivel.
    [Arguments]    ${locator}    ${timeout}=20s    ${intervalo}=1s
    Wait Until Keyword Succeeds    ${timeout}    ${intervalo}    Click    ${locator}

Aguardar Janela Por Nome
    [Documentation]    Aguarda uma janela ficar responsiva por nome parcial ou exato.
    [Arguments]    ${locator}    ${timeout}=20s    ${intervalo}=1s
    Wait Until Keyword Succeeds    ${timeout}    ${intervalo}    Control Window    ${locator}

Aguardar Elemento Por Locator
    [Documentation]    Aguarda um elemento estar disponivel sem clickar.
    [Arguments]    ${locator}    ${timeout}=20s    ${intervalo}=1s
    Wait Until Keyword Succeeds    ${timeout}    ${intervalo}    Get Element    ${locator}

Verificar Processo Em Execucao
    [Documentation]    Verifica se um processo esta em execucao via tasklist.
    [Arguments]    ${nome_exe}
    ${resultado}=    Run Process    tasklist    /FI    IMAGENAME eq ${nome_exe}    /NH
    ${em_execucao}=    Evaluate    "${nome_exe}".lower() in """${resultado.stdout}""".lower()
    RETURN    ${em_execucao}

Iniciar Processo Se Nao Existe
    [Documentation]    Inicia um processo apenas se ele nao estiver em execucao.
    [Arguments]    ${caminho_exe}    ${nome_exe}
    ${em_execucao}=    Verificar Processo Em Execucao    ${nome_exe}
    IF    not ${em_execucao}
        Log    [UI] Iniciando processo ${nome_exe}...    console=True
        Start Process    ${caminho_exe}
        Sleep    5s
    ELSE
        Log    [UI] Processo ${nome_exe} ja esta em execucao.    console=True
    END

Garantir Janela Em Foco
    [Documentation]    Garante que uma janela esta em foco, com timeout configuravel.
    [Arguments]    ${locator}    ${timeout}=30s
    Wait Until Keyword Succeeds    ${timeout}    1s    Control Window    ${locator}

Digitar Texto Em Campo
    [Documentation]    Digita texto em um campo de entrada.
    [Arguments]    ${locator}    ${texto}    ${validador}=${None}
    IF    $validador is None
        Set Value    ${locator}    ${texto}
    ELSE
        Set Value    ${locator}    ${texto}    validator=${validador}
    END

Obter Valor Campo
    [Documentation]    Obtem o valor de um elemento (input, label, etc).
    [Arguments]    ${locator}
    ${valor}=    Get Value    ${locator}
    RETURN    ${valor}

Limpar Campo
    [Documentation]    Limpa o conteudo de um campo de entrada.
    [Arguments]    ${locator}
    Click    ${locator}
    Send Keys    keys={CTRL}a{DELETE}
    Sleep    300ms
