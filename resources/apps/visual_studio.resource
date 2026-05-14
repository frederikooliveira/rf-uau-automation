*** Settings ***
Documentation       Keywords específicas da aplicação Visual Studio via TFVC.
...                 Responsabilidade: controlar VS e Source Control Explorer.
Library             RPA.Windows
Library             Process
Resource            ../core/ui_helpers.resource
Resource            ../core/sync.resource
Resource            ../data/vs_data.resource

*** Keywords ***
Verificar Ou Abrir Visual Studio
    [Documentation]    Verifica se VS esta aberto. Se nao, inicia e aguarda carregamento.
    Log    [1/3] Verificando se devenv.exe esta em execucao...    console=True
    ${aberto}=    Verificar Processo Em Execucao    devenv.exe
    Log    [1/3] devenv.exe encontrado: ${aberto}    console=True
    IF    not ${aberto}
        Log    [1/3] VS nao esta aberto. Iniciando...    console=True
        Iniciar Visual Studio
        Aguardar Janela Principal Do Visual Studio
    ELSE
        Log    [1/3] VS ja esta aberto. Trazendo para foco...    console=True
        Garantir Janela Em Foco    ${VS_JANELA_PRINCIPAL}
        Log    [1/3] VS em foco.    console=True
    END

Iniciar Visual Studio
    [Documentation]    Inicia devenv.exe e aguarda "Continue without code".
    Log    [Iniciar VS] Executando: ${VS_EXE}    console=True
    Start Process    ${VS_EXE}
    Log    [Iniciar VS] Processo iniciado. Aguardando 5s...    console=True
    Pausa Controlada    5s    Aguardando inicializacao do VS
    Log    [Iniciar VS] Tentando clicar em 'Continue without code'...    console=True
    ${status}    ${msg}=    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    10s    2s    Click    subname:"Continue without code"
    IF    '${status}' == 'FAIL'
        Log    [Iniciar VS] Clique direto falhou. Focando VS e repetindo...    console=True
        Aguardar Janela Por Nome    ${VS_JANELA_PRINCIPAL}    90s
        Wait Until Keyword Succeeds    30s    2s
        ...    Click    subname:"Continue without code"
    END
    Log    [Iniciar VS] 'Continue without code' clicado.    console=True

Aguardar Janela Principal Do Visual Studio
    [Documentation]    Aguarda a janela principal do VS estar responsiva.
    Log    [Aguardar VS] Aguardando janela do VS (ate 120s)...    console=True
    Aguardar Janela Por Nome    ${VS_JANELA_PRINCIPAL}    120s
    Log    [Aguardar VS] Janela principal do VS responsiva.    console=True

Abrir Source Control Explorer
    [Documentation]    Abre o Source Control Explorer via View > Other Windows > Source Control Explorer.
    Log    [SCE] Ativando VS...    console=True
    Garantir Janela Em Foco    ${VS_JANELA_PRINCIPAL}
    Log    [SCE] Abrindo Team Explorer...    console=True
    Click    name:View and type:MenuItemControl
    Wait Until Keyword Succeeds    5s    0.5s    Click    name:"Team Explorer" and type:MenuItemControl
    Pausa Controlada    1s    Reabrindo menu
    Click    name:View and type:MenuItemControl
    Log    [SCE] Abrindo Other Windows...    console=True
    Wait Until Keyword Succeeds    5s    0.5s    Click    subname:"Other Windows" and type:MenuItemControl
    Log    [SCE] Clicando em Source Control Explorer...    console=True
    Wait Until Keyword Succeeds    5s    0.5s    Click    name:"Source Control Explorer" and type:MenuItemControl
    Log    [SCE] Aguardando painel ficar visivel...    console=True
    Aguardar Elemento Por Locator    subname:"Source Control Explorer"    15s

Expandir Item Na Arvore TFS
    [Documentation]    Expande um no intermediario da arvore TFS.
    [Arguments]    ${nome_item}
    Log    [TFS] Buscando '${nome_item}'...    console=True
    ${pane}=    Get Element    id:ExplorerScc
    ${elem}=    Wait Until Keyword Succeeds    10s    1s
    ...    Get Element    name:${nome_item}    root_element=${pane}
    Log    [TFS] '${nome_item}' encontrado. Expandindo...    console=True
    Double Click    ${elem}
    Log    [TFS] '${nome_item}' expandido.    console=True

Selecionar Pasta Alvo Na Arvore TFS
    [Documentation]    Seleciona o no final da arvore com um clique (sem expandir).
    [Arguments]    ${nome_item}
    Log    [TFS] Selecionando pasta alvo '${nome_item}'...    console=True
    ${pane}=    Get Element    id:ExplorerScc
    ${elem}=    Wait Until Keyword Succeeds    10s    1s
    ...    Get Element    name:${nome_item}    root_element=${pane}
    Click    ${elem}
    Log    [TFS] Pasta alvo '${nome_item}' selecionada.    console=True

Get Latest Version Na Pasta Alvo
    [Documentation]    Navega arvore TFVC até ${TFS_PASTA_ALVO} e executa Get Specific Version.
    Log    [GLV] Expandindo: ${TFS_SERVIDOR}    console=True
    Expandir Item Na Arvore TFS    ${TFS_SERVIDOR}
    Log    [GLV] Expandindo: ${TFS_PROJETO}    console=True
    Expandir Item Na Arvore TFS    ${TFS_PROJETO}
    Log    [GLV] Expandindo: ${TFS_BRANCH}    console=True
    Expandir Item Na Arvore TFS    ${TFS_BRANCH}
    Log    [GLV] Selecionando pasta alvo: ${TFS_PASTA_ALVO}    console=True
    Selecionar Pasta Alvo Na Arvore TFS    ${TFS_PASTA_ALVO}
    Log    [GLV] Abrindo menu de contexto...    console=True
    ${pane}=    Get Element    id:ExplorerScc
    ${elem}=    Get Element    name:${TFS_PASTA_ALVO}    root_element=${pane}
    Right Click    ${elem}
    Pausa Controlada    1s    Aguardando menu de contexto
    Log    [GLV] Selecionando Advanced...    console=True
    Send Keys    keys={END}
    Pausa Controlada    300ms    Navegando menu
    Send Keys    keys={RIGHT}
    Pausa Controlada    500ms    Abrindo submenu
    Log    [GLV] Navegando ate Get Specific Version...    console=True
    Send Keys    keys={ENTER}
    Log    [GLV] Aguardando janela Get...    console=True
    Wait Until Keyword Succeeds    10s    1s    Control Window    name:Get
    Log    [GLV] Marcando checkbox 'Overwrite writeable files'...    console=True
    ${cb1}=    Get Element    subname:"Overwrite writeable"
    Click    ${cb1}
    Log    [GLV] Marcando checkbox 'Overwrite all files'...    console=True
    ${cb2}=    Get Element    subname:"Overwrite all files"
    Click    ${cb2}
    Log    [GLV] Clicando em Get...    console=True
    Wait Until Keyword Succeeds    5s    0.5s
    ...    Click    name:Get and type:ButtonControl
    Log    [GLV] Aguardando dialogo fechar...    console=True
    Wait Until Keyword Succeeds    30s    1s
    ...    Run Keyword And Expect Error    *    Control Window    name:Get    timeout=1
    Log    [GLV] Aguardando VS ficar responsivo apos download (900s)...    console=True
    Wait Until Keyword Succeeds    900s    5s
    ...    Garantir Janela Em Foco    ${VS_JANELA_PRINCIPAL}
    Log    [GLV] Get Specific Version concluido.    console=True
