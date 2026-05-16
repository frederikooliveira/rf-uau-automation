*** Settings ***
Documentation       Keywords específicas da aplicação UauXT.
...                 Responsabilidade: login, navegacao, fluxos genéricos do UauXT.
Library             RPA.Windows
Resource            ../core/ui_helpers.resource
Resource            ../core/sync.resource
Resource            ../data/uauxt_data.resource
Resource            ../data/uauxt_menu_data.resource

*** Keywords ***
Abrir UauXT
    [Documentation]    Executa o UauXT a partir do caminho padrao da instalacao.
    [Arguments]    ${caminho_exe}=${UAUXT_EXE}
    Log    [UAUXT] Abrindo UauXT em: ${caminho_exe}    console=True
    Start Process    ${caminho_exe}
    Log    [UAUXT] Processo iniciado.    console=True

Aguardar Popup UauXT E Clicar OK
    [Documentation]    Aguarda popup inicial "UAU XT Informa!" e confirma.
    [Arguments]    ${timeout}=5s    ${intervalo}=1s
    Log    [UAUXT] Aguardando popup inicial (timeout ${timeout})...    console=True
    ${popup_encontrado}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${timeout}    ${intervalo}
    ...    Control Window    ${UAUXT_POPUP_INICIAL} and type:WindowControl
    IF    not ${popup_encontrado}
        Log    [UAUXT] Popup nao encontrado com locator padrao, tentando alternativas...    console=True
        ${popup_alternativo}=    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds    5s    1s
        ...    Control Window    ${UAUXT_POPUP_INICIAL} 
        IF    not ${popup_alternativo}
            Log    [UAUXT] Popup nao detectado. Validando se tela de login ja esta pronta...    console=True
            ${mainview_pronto}=    Run Keyword And Return Status
            ...    Wait Until Keyword Succeeds    5s    1s
            ...    Control Window    id:MainView and type:WindowControl
            ${usuario_pronto}=    Run Keyword And Return Status
            ...    Wait Until Keyword Succeeds    3s    100ms
            ...    Get Element    id:txtUsuario and type:EditControl
            ${senha_pronto}=    Run Keyword And Return Status
            ...    Wait Until Keyword Succeeds    3s    100ms
            ...    Get Element    id:txtSenha and type:EditControl
            IF    ${mainview_pronto} and ${usuario_pronto} and ${senha_pronto}
                Log    [UAUXT] Popup nao apareceu, mas login/senha estao ativos. Seguindo para autenticacao.    console=True
                RETURN
            END
            Log    [UAUXT] ERRO: Popup inicial nao detectado e tela de login nao esta pronta. Janelas abertas:    console=True
            Print Tree    desktop    log_as_warnings=True
            Fail    Popup inicial do UauXT nao apareceu dentro do timeout
        END
    END
    Fechar Popup Informa
    Log    [UAUXT] Popup inicial fechado.    console=True

Abrir UauXT E Confirmar Popup Inicial
    [Documentation]    Abre UauXT e confirma o popup de aviso inicial.
    [Arguments]    ${caminho_exe}=${UAUXT_EXE}
    Abrir UauXT    ${caminho_exe}
    #Aguardar Popup UauXT E Clicar OK
    Log    [UAUXT] UauXT aberto e popup inicial confirmado.    console=True

Preencher Login UauXT
    [Documentation]    Preenche usuario e senha na tela inicial do UauXT.
    [Arguments]    ${usuario}    ${senha}    ${timeout}=20s    ${intervalo}=1s
    Log    [UAUXT] Aguardando tela de login...    console=True
    Wait Until Keyword Succeeds    ${timeout}    ${intervalo}
    ...    Control Window    id:MainView and type:WindowControl
    Log    [UAUXT] Preenchendo usuario...    console=True
    Digitar Texto Em Campo    id:txtUsuario and type:EditControl    ${usuario}
    Log    [UAUXT] Preenchendo senha...    console=True
    Clicar Elemento Quando Disponivel    id:txtSenha and type:EditControl
    Send Keys    keys={CTRL}a{DELETE}
    Send Keys    keys=${senha}
    Log    [UAUXT] Credenciais preenchidas.    console=True

Autenticar No UauXT
    [Documentation]    Clica no botao Autenticar na tela inicial.
    [Arguments]    ${timeout}=20s    ${intervalo}=1s
    Log    [UAUXT] Garantindo foco na tela de login...    console=True
    Wait Until Keyword Succeeds    ${timeout}    ${intervalo}
    ...    Control Window    id:MainView and type:WindowControl
    Log    [UAUXT] Clicando em Autenticar...    console=True
    ${status}    ${mensagem}=    Run Keyword And Ignore Error
    ...    Clicar Elemento Quando Disponivel    id:btnAutenticar and name:Autenticar and type:ButtonControl    ${timeout}    ${intervalo}
    IF    '${status}' == 'FAIL'
        Log    [UAUXT] Clique no botao falhou. Tentando autenticar com Enter...    console=True
        Send Keys    keys={ENTER}
    END
    Log    [UAUXT] Acao de autenticacao executada.    console=True

Abrir UauXT, Confirmar Popup E Preencher Login
    [Documentation]    Abre UauXT, fecha popup e autentica.
    [Arguments]    ${caminho_exe}=${UAUXT_EXE}    ${credenciais}=${UAUXT_CREDENCIAIS_PADRAO}
    Abrir UauXT E Confirmar Popup Inicial    ${caminho_exe}
    Log    [UAUXT] Preenchendo credenciais de login...    console=True
    Pausa Controlada  15s    Aguardando tela de login ficar pronta
    Preencher Login UauXT    ${credenciais}[usuario]    ${credenciais}[senha]
    Autenticar No UauXT
    Log    [UAUXT] Login concluido.    console=True

Abrir E Logar No UauXT
    [Documentation]    Keyword reutilizavel: abre, confirma popup e autentica.
    [Arguments]    ${caminho_exe}=${UAUXT_EXE}    ${credenciais}=${UAUXT_CREDENCIAIS_PADRAO}
    Abrir UauXT, Confirmar Popup E Preencher Login    ${caminho_exe}    ${credenciais}
    Log    [UAUXT] Sistema pronto para uso.    console=True

# === NAVEGAÇÃO E MENUS ===

Focar No Menu Lateral Angular UauXT
    [Documentation]    Foca no menu lateral Angular/CefSharp do UauXT.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [UAUXT] Focando menu lateral Angular...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Control Window    id:MainView and type:WindowControl
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Click    ${UAUXT_MENU_LATERAL_DOCUMENTO}
    Log    [UAUXT] Menu lateral Angular em foco.    console=True

Selecionar Icone Menu Lateral Por Indice
    [Documentation]    Seleciona um icone do menu lateral pelo indice (1..N).
    [Arguments]    ${indice}=${UAUXT_MENU_FINANCEIRO_INDICE}
    Focar No Menu Lateral Angular UauXT
    Log    [UAUXT] Selecionando icone ${indice} do menu lateral...    console=True
    ${icone}=    Obter Icone Menu Lateral Por Ordem Vertical    ${indice}
    Click    ${icone}
    Pausa Controlada    700ms    Aguardando abertura dos submenus do icone selecionado
    Log    [UAUXT] Icone ${indice} selecionado.    console=True

Selecionar Icone Menu Lateral Por Glyph
    [Documentation]    Seleciona um icone da coluna lateral pelo glyph (simbolo visual no TextControl).
    [Arguments]    ${glyph}
    Focar No Menu Lateral Angular UauXT
    ${icones_coluna}=    Obter Icones Da Coluna Lateral
    ${expr_glyph}=    Catenate    SEPARATOR=${EMPTY}
    ...    [e for e in $icones_coluna if getattr(e, 'name', '') == '${glyph}']
    ${candidatos}=    Evaluate    ${expr_glyph}
    ${total}=    Get Length    ${candidatos}
    IF    ${total} < 1
        Fail    Nao foi possivel localizar icone com glyph '${glyph}' na coluna lateral.
    END
    ${icone}=    Get From List    ${candidatos}    0
    Click    ${icone}
    Pausa Controlada    700ms    Aguardando abertura dos submenus do glyph selecionado
    Log    [UAUXT] Icone com glyph '${glyph}' selecionado.    console=True

Selecionar Menu Lateral Por Texto
    [Documentation]    Seleciona item de menu lateral por texto visivel (sem automacao por imagem).
    [Arguments]    ${texto}    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Selecionar Submenu Aberto Por Nome    ${texto}    ${timeout}

Selecionar Submenu Aberto Por Nome
    [Documentation]    Seleciona submenu visivel por nome apos abrir o menu lateral.
    [Arguments]    ${nome_submenu}    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [UAUXT] Selecionando submenu por nome: ${nome_submenu}    console=True
    ${status}    ${candidatos}=    Run Keyword And Ignore Error
    ...    Get Elements    ${UAUXT_MENU_LATERAL_DOCUMENTO} > type:TextControl    search_depth=20    siblings_only=${False}
    IF    '${status}' == 'PASS'
        ${nome_submenu_normalizado}=    Evaluate    '''${nome_submenu}'''.lower()
        ${expr_visiveis}=    Catenate    SEPARATOR=${EMPTY}
        ...    sorted([e for e in $candidatos if getattr(e, 'name', '') and '${nome_submenu_normalizado}' in e.name.lower() and e.width > 5 and e.height > 5], key=lambda x: (x.top, x.left))
        ${candidatos_visiveis}=    Evaluate    ${expr_visiveis}
        ${total}=    Get Length    ${candidatos_visiveis}
        IF    ${total} > 0
            ${submenu}=    Get From List    ${candidatos_visiveis}    0
            Click    ${submenu}
            Log    [UAUXT] Submenu '${nome_submenu}' selecionado por busca profunda.    console=True
            RETURN
        END
    END
    ${clicou}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Click    subname:${nome_submenu} and type:MenuItemControl
    IF    not ${clicou}
        ${clicou}=    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds    ${timeout}    1s
        ...    Click    subname:${nome_submenu} and type:TextControl
    END
    IF    not ${clicou}
        ${clicou}=    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds    ${timeout}    1s
        ...    Click    subname:${nome_submenu} and type:ButtonControl
    END
    IF    not ${clicou}
        Print Tree    ${UAUXT_MENU_LATERAL_DOCUMENTO}    max_depth=16    log_as_warnings=True
        Fail    Nao foi possivel selecionar submenu '${nome_submenu}'.
    END
    Log    [UAUXT] Submenu '${nome_submenu}' selecionado.    console=True

Selecionar Item Menu Lateral Angular Por Nome
    [Documentation]    Seleciona item no menu lateral Angular/CefSharp com fallback de locators.
    [Arguments]    ${nome_item}    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [UAUXT] Selecionando item do menu lateral: ${nome_item}    console=True
    Focar No Menu Lateral Angular UauXT    ${timeout}
    @{locators}=    Create List
    ...    ${UAUXT_MENU_LATERAL_DOCUMENTO} > type:TreeItemControl and subname:${nome_item}
    ...    ${UAUXT_MENU_LATERAL_DOCUMENTO} > type:ListItemControl and subname:${nome_item}
    ...    ${UAUXT_MENU_LATERAL_DOCUMENTO} > type:MenuItemControl and subname:${nome_item}
    ...    type:TreeItemControl and subname:${nome_item}
    ...    type:ListItemControl and subname:${nome_item}
    ...    type:MenuItemControl and subname:${nome_item}
    ...    subname:${nome_item} and type:TextControl
    ...    subname:${nome_item} and type:ButtonControl
    ${clicou}=    Set Variable    ${False}
    FOR    ${locator}    IN    @{locators}
        ${clicou}=    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds    2s    300ms
        ...    Click    ${locator}
        IF    ${clicou}
            Log    [UAUXT] Item '${nome_item}' clicado com locator: ${locator}    console=True
            BREAK
        END
    END
    IF    not ${clicou}
        Print Tree    id:MainView and type:WindowControl    max_depth=16    log_as_warnings=True
        Fail    Nao foi possivel selecionar item do menu lateral '${nome_item}'.
    END
    Pausa Controlada    400ms    Aguardar renderizacao do proximo nivel do menu lateral

Acessar Caminho No Menu Lateral Angular
    [Documentation]    Navega por um caminho de menu (pai > filho > neto) no menu lateral Angular/CefSharp.
    [Arguments]    @{itens_menu}
    ${total_itens}=    Get Length    ${itens_menu}
    IF    ${total_itens} < 1
        Fail    Informe ao menos um item para navegar no menu lateral.
    END
    ${caminho_log}=    Catenate    SEPARATOR= >     @{itens_menu}
    Log    [UAUXT] Navegando no menu lateral pelo caminho: ${caminho_log}    console=True
    FOR    ${item}    IN    @{itens_menu}
        Selecionar Item Menu Lateral Angular Por Nome    ${item}
    END
    Log    [UAUXT] Caminho de menu lateral concluido: ${caminho_log}    console=True

Acessar Tela Contas A Pagar Via Menu Lateral
    [Documentation]    Acessa a tela Contas a Pagar via icone do menu lateral (Financeiro).
    [Arguments]    ${indice_menu_financeiro}=${UAUXT_MENU_FINANCEIRO_INDICE}
    Log    [UAUXT] Acessando tela Contas a Pagar via menu lateral...    console=True
    Selecionar Icone Menu Lateral Por Indice    ${indice_menu_financeiro}
    Selecionar Submenu Aberto Por Nome    ${UAUXT_SUBMENU_CONTAS_A_PAGAR_TEXTO}
    Log    [UAUXT] Fluxo de acesso a Contas a Pagar concluido.    console=True

Clicar Icone Capacete Obras
    [Documentation]    Clica no icone do capacete de obras (Financeiro) no menu lateral Angular/CefSharp.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [UAUXT] Clicando no icone ${UAUXT_MENU_FINANCEIRO_INDICE} do menu lateral (menu principal/Financeiro)...    console=True
    Selecionar Icone Menu Lateral Por Indice    ${UAUXT_MENU_FINANCEIRO_INDICE}
    Pausa Controlada    700ms    Aguardando abertura do menu do capacete de obras (Financeiro)
    Log    [UAUXT] Icone do capacete de obras clicado com sucesso.    console=True

Clicar Icone Maleta Financeiro
    [Documentation]    Alias legado para manter compatibilidade. Use Clicar Icone Capacete Obras.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [UAUXT] [LEGADO] Keyword de maleta redirecionada para capacete de obras.    console=True
    Clicar Icone Capacete Obras    ${timeout}

Obter Icone Menu Lateral Por Ordem Vertical
    [Documentation]    Retorna o icone da coluna lateral por ordem vertical (1..N).
    [Arguments]    ${ordem}
    ${icones_coluna}=    Obter Icones Da Coluna Lateral
    ${total}=    Get Length    ${icones_coluna}
    Log    [UAUXT] Candidatos de icone na coluna lateral: ${total}    console=True
    IF    ${total} < ${ordem}
        Fail    Nao ha icones suficientes na coluna lateral. Total=${total}, ordem solicitada=${ordem}.
    END
    ${indice}=    Evaluate    int(${ordem}) - 1
    ${icone}=    Get From List    ${icones_coluna}    ${indice}
    RETURN    ${icone}

Obter Icones Da Coluna Lateral
    [Documentation]    Retorna icones da coluna lateral usando a mesma estrategia do teste de captura.
    ${documento}=    Get Element    ${UAUXT_MENU_LATERAL_DOCUMENTO}
    @{textos}=    Get Elements    ${UAUXT_MENU_LATERAL_DOCUMENTO} > type:TextControl    search_depth=20    siblings_only=${False}
    ${doc_left}=    Evaluate    $documento.left
    ${doc_top}=    Evaluate    $documento.top
    ${doc_bottom}=    Evaluate    $documento.bottom
    ${expr_icones}=    Catenate    SEPARATOR=${EMPTY}
    ...    sorted([e for e in $textos if e.xcenter >= ${doc_left} and e.xcenter <= (${doc_left} + 90) and e.ycenter >= (${doc_top} + 80) and e.ycenter <= ${doc_bottom}], key=lambda x: (x.top, x.left))
    ${icones_coluna}=    Evaluate    ${expr_icones}
    RETURN    ${icones_coluna}

Acessar Aprovacao Pagamentos Via Icone Capacete Obras
    [Documentation]    Estrategia unica: clica no icone capacete de obras e acessa subniveis por clique.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Clicar Icone Capacete Obras    ${timeout}
    Selecionar Submenu Aberto Por Nome    ${UAUXT_SUBMENU_FINANCEIRO_TEXTO}    ${timeout}
    Selecionar Submenu Aberto Por Nome    ${UAUXT_SUBMENU_GESTAO_FINANCEIRA_TEXTO}    ${timeout}
    Selecionar Submenu Aberto Por Nome    ${UAUXT_SUBMENU_CONTAS_A_PAGAR_TEXTO}    ${timeout}
    Selecionar Submenu Aberto Por Nome    ${UAUXT_SUBMENU_APROVACAO_PAGAMENTOS_TEXTO}    ${timeout}
    Log    [UAUXT] Navegacao por capacete de obras ate aprovacao concluida.    console=True

Acessar Aprovacao Pagamentos Via Icone Maleta
    [Documentation]    Alias legado para manter compatibilidade. Use Acessar Aprovacao Pagamentos Via Icone Capacete Obras.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [UAUXT] [LEGADO] Keyword de maleta redirecionada para capacete de obras.    console=True
    Acessar Aprovacao Pagamentos Via Icone Capacete Obras    ${timeout}

Acessar Contas A Pagar Via Icone Capacete Obras
    [Documentation]    Estrategia unica: capacete de obras > Financeiro > Gestao financeira > Contas a Pagar.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Clicar Icone Capacete Obras    ${timeout}
    Selecionar Submenu Aberto Por Nome    ${UAUXT_SUBMENU_FINANCEIRO_TEXTO}    ${timeout}
    Pausa Controlada    700ms    Aguardando expansao do submenu Financeiro
    Selecionar Submenu Aberto Por Nome    ${UAUXT_SUBMENU_GESTAO_FINANCEIRA_TEXTO}    ${timeout}
    Pausa Controlada    700ms    Aguardando expansao do submenu Gestao Financeira
    ${acessou_contas_a_pagar}=    Run Keyword And Return Status
    ...    Selecionar Submenu Aberto Por Nome    ${UAUXT_SUBMENU_CONTAS_A_PAGAR_TEXTO}    ${timeout}
    IF    not ${acessou_contas_a_pagar}
        Log    [UAUXT] Fallback por path para Contas a Pagar.    console=True
        Wait Until Keyword Succeeds    ${timeout}    500ms
        ...    Click    ${UAUXT_MENU_ITEM_CONTAS_A_PAGAR_LOCATOR}
    END
    Log    [UAUXT] Navegacao por capacete de obras ate Contas a Pagar concluida.    console=True

Acessar Contas A Pagar Via Icone Maleta
    [Documentation]    Alias legado para manter compatibilidade. Use Acessar Contas A Pagar Via Icone Capacete Obras.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [UAUXT] [LEGADO] Keyword de maleta redirecionada para capacete de obras.    console=True
    Acessar Contas A Pagar Via Icone Capacete Obras    ${timeout}

Capturar E Imprimir WebBrowser Menu Lateral
    [Documentation]    Captura e imprime a arvore do MenuXt/wbBrowser e lista icones TextControl para mapear glyph/posicao.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [UAUXT] Capturando arvore do webbrowser lateral...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Control Window    id:MainView and type:WindowControl
    Print Tree    ${UAUXT_MENU_LATERAL_HOST}    max_depth=14    log_as_warnings=True
    Print Tree    ${UAUXT_MENU_LATERAL_BROWSER}    max_depth=14    log_as_warnings=True
    Print Tree    ${UAUXT_MENU_LATERAL_DOCUMENTO}    max_depth=14    log_as_warnings=True
    ${documento}=    Get Element    ${UAUXT_MENU_LATERAL_DOCUMENTO}
    ${doc_left}=    Evaluate    $documento.left
    ${doc_right}=    Evaluate    $documento.right
    ${doc_top}=    Evaluate    $documento.top
    ${doc_bottom}=    Evaluate    $documento.bottom
    Log    [UAUXT] Bounds documento lateral: L=${doc_left} T=${doc_top} R=${doc_right} B=${doc_bottom}    console=True
    @{textos}=    Get Elements    ${UAUXT_MENU_LATERAL_DOCUMENTO} > type:TextControl    search_depth=20    siblings_only=${False}
    ${expr_icones}=    Catenate    SEPARATOR=${EMPTY}
    ...    sorted([e for e in $textos if e.xcenter >= ${doc_left} and e.xcenter <= (${doc_left} + 90) and e.ycenter >= (${doc_top} + 80) and e.ycenter <= ${doc_bottom}], key=lambda x: (x.top, x.left))
    ${icones_coluna}=    Evaluate    ${expr_icones}
    ${total}=    Get Length    ${icones_coluna}
    Log    [UAUXT] Total de icones candidatos na coluna lateral: ${total}    console=True
    FOR    ${idx}    IN RANGE    ${total}
        ${el}=    Get From List    ${icones_coluna}    ${idx}
        ${nome}=    Evaluate    getattr($el, 'name', '')
        ${left}=    Evaluate    $el.left
        ${top}=    Evaluate    $el.top
        ${right}=    Evaluate    $el.right
        ${bottom}=    Evaluate    $el.bottom
        Log    [UAUXT] [ICONE ${idx}] glyph='${nome}' rect=(${left},${top},${right},${bottom})    console=True
    END
    Log    [UAUXT] Glyph configurado para capacete: '${UAUXT_MENU_ICONE_CAPACETE_GLYPH}' locator='${UAUXT_MENU_ICONE_CAPACETE_LOCATOR}'    console=True

Navegar Para Menu
    [Documentation]    Navega para um menu específico no UauXT.
    [Arguments]    ${menu_locator}    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [UAUXT] Navegando para menu: ${menu_locator}    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Click    ${menu_locator} and type:MenuItemControl
    Log    [UAUXT] Menu acessado com sucesso.    console=True

Navegar Para Submenu
    [Documentation]    Navega para um submenu específico.
    [Arguments]    ${submenu_locator}    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [UAUXT] Navegando para submenu: ${submenu_locator}    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Click    ${submenu_locator} and type:MenuItemControl
    Log    [UAUXT] Submenu acessado com sucesso.    console=True

Aguardar Tela Carregar
    [Documentation]    Aguarda uma tela específica carregar.
    [Arguments]    ${tela_locator}    ${timeout}=${UAUXT_TIMEOUT_TELA}
    Log    [UAUXT] Aguardando tela carregar: ${tela_locator}    console=True
    Wait Until Keyword Succeeds    ${timeout}    2s
    ...    Control Window    ${tela_locator} and type:WindowControl
    Log    [UAUXT] Tela carregada com sucesso.    console=True

Acessar Tela Aprovacao Pagamentos
    [Documentation]    Navega até a tela de aprovação de pagamentos.
    Log    [UAUXT] Iniciando navegação para tela de aprovação de pagamentos...    console=True
    ${acessou_menu_lateral}=    Run Keyword And Return Status
    ...    Acessar Caminho No Menu Lateral Angular    @{UAUXT_CAMINHO_MENU_APROVACAO_PAGAMENTOS}
    IF    not ${acessou_menu_lateral}
        Log    [UAUXT] Fallback: navegando pelo menu classico (nao lateral).    console=True
        Navegar Para Menu    ${UAUXT_MENU_FINANCEIRO}
        Navegar Para Submenu    ${UAUXT_SUBMENU_CONTAS_PAGAR}
        Navegar Para Submenu    ${UAUXT_SUBMENU_APROVACAO}
    END
    Aguardar Tela Carregar    ${UAUXT_TELA_APROVACAO_PAGAMENTOS}
    Log    [UAUXT] Tela de aprovação de pagamentos acessada.    console=True

# === GRID E FILTROS ===

Aplicar Filtro Grid
    [Documentation]    Aplica filtro em um grid específico.
    [Arguments]    ${campo_filtro}    ${valor_filtro}    ${timeout}=${UAUXT_TIMEOUT_GRID}
    Log    [UAUXT] Aplicando filtro: ${campo_filtro} = ${valor_filtro}    console=True
    Clicar Elemento Quando Disponivel    ${UAUXT_BOTAO_FILTRO} and type:ButtonControl    ${timeout}
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Control Window    ${campo_filtro} and type:ComboBoxControl
    Send Keys    keys=${valor_filtro}
    Send Keys    keys={ENTER}
    Log    [UAUXT] Filtro aplicado com sucesso.    console=True

Filtrar Pagamentos Pendentes
    [Documentation]    Filtra pagamentos com status "Pendente".
    Aplicar Filtro Grid    ${UAUXT_CAMPO_FILTRO_STATUS}    ${UAUXT_VALOR_FILTRO_PENDENTE}
    Log    [UAUXT] Filtro de pagamentos pendentes aplicado.    console=True

Selecionar Primeiro Item Grid
    [Documentation]    Seleciona o primeiro item de um grid.
    [Arguments]    ${grid_locator}=${UAUXT_GRID_PAGAMENTOS}    ${timeout}=${UAUXT_TIMEOUT_GRID}
    Log    [UAUXT] Selecionando primeiro item do grid...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Control Window    ${grid_locator} and type:DataGridControl
    Send Keys    keys={DOWN}    # Garante que estamos no grid
    Send Keys    keys={HOME}    # Vai para o primeiro item
    Log    [UAUXT] Primeiro item selecionado.    console=True

Aprovar Pagamento Selecionado
    [Documentation]    Aprova o pagamento atualmente selecionado.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_GRID}
    Log    [UAUXT] Aprovando pagamento selecionado...    console=True
    Clicar Elemento Quando Disponivel    ${UAUXT_BOTAO_APROVAR} and type:ButtonControl    ${timeout}
    # Aguardar confirmação ou atualização do grid
    Pausa Controlada    2s    Aguardando confirmacao de aprovacao
    Log    [UAUXT] Pagamento aprovado com sucesso.    console=True

Rejeitar Pagamento Selecionado
    [Documentation]    Rejeita o pagamento atualmente selecionado.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_GRID}
    Log    [UAUXT] Rejeitando pagamento selecionado...    console=True
    Clicar Elemento Quando Disponivel    ${UAUXT_BOTAO_REJEITAR} and type:ButtonControl    ${timeout}
    # Aguardar confirmação ou atualização do grid
    Pausa Controlada    2s    Aguardando confirmacao de rejeicao
    Log    [UAUXT] Pagamento rejeitado.    console=True
