*** Settings ***
Documentation       Keywords específicas da aplicação UauXT.
...                 Responsabilidade: login, navegacao, fluxos genéricos do UauXT.
Library             OperatingSystem
Library             Process
Library             RPA.Windows
Resource            ../core/ui_helpers.resource
Resource            ../core/sync.resource
Resource            ../data/uauxt_data.resource
Resource            ../data/uauxt_menu_data.resource

*** Keywords ***
Preencher Campo UauXT Por Locator Via RPA
    [Documentation]    Preenche um controle do UauXT diretamente via RPA.Windows sem subprocesso.
    [Arguments]    ${locator}    ${texto}
    ${strategy}=    Evaluate    str('${locator}').split(':', 1)[0].strip()
    ${identificador}=    Evaluate    str('${locator}').split(':', 1)[1].strip()
    ${locator_rpa}=    Set Variable    ${locator}
    IF    '${strategy}' == 'automation_id' or '${strategy}' == 'control_id'
        ${locator_rpa}=    Set Variable    id:${identificador}
    END
    Click    ${locator_rpa}
    Set Value    ${locator_rpa}    ${texto}

Preencher Campo UauXT Por Locator
    [Documentation]    Foca e preenche um controle do UauXT via locator como automation_id:123 ou control_id:123, priorizando o caminho direto do RPA.Windows e usando o probe como fallback.
    [Arguments]    ${locator}    ${texto}
    ${strategy}=    Evaluate    str('${locator}').split(':', 1)[0].strip()
    ${identificador}=    Evaluate    str('${locator}').split(':', 1)[1].strip()

    ${preencheu}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    3s    200ms
    ...    Preencher Campo UauXT Por Locator Via RPA
    ...    ${locator}
    ...    ${texto}

    IF    ${preencheu}
        Log    [UAUXT] Controle ${locator} preenchido com sucesso via RPA.Windows.    console=True
        RETURN
    END

    IF    '${strategy}' == 'control_id'
        ${flag}=    Set Variable    --control-id
    ELSE
        ${flag}=    Set Variable    --automation-id
    END
    ${python_exe}=    Normalize Path    ${EXECDIR}${/}.venv${/}Scripts${/}python.exe
    ${script_path}=    Normalize Path    ${EXECDIR}${/}resources${/}scripts${/}uauxt_probe.py
    ${result}=    Run Process
    ...    ${python_exe}
    ...    ${script_path}
    ...    set-control-text
    ...    ${flag}
    ...    ${identificador}
    ...    --value
    ...    ${texto}
    ...    stdout=PIPE
    ...    stderr=PIPE
    ...    timeout=${UAUXT_TIMEOUT_PADRAO}
    IF    ${result.rc} != 0
        Fail    Falha ao preencher o controle ${locator}: ${result.stderr}
    END
    Log    [UAUXT] Controle ${locator} preenchido com sucesso via probe.    console=True

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
    # Aguardar Popup UauXT E Clicar OK

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
    Pausa Controlada  5s    Aguardando tela de login ficar pronta
    Preencher Login UauXT    ${credenciais}[usuario]    ${credenciais}[senha]
    Autenticar No UauXT
    Log    [UAUXT] Login concluido.    console=True

Abrir E Logar No UauXT
    [Documentation]    Keyword reutilizavel: abre, confirma popup e autentica.
    [Arguments]    ${caminho_exe}=${UAUXT_EXE}    ${credenciais}=${UAUXT_CREDENCIAIS_PADRAO}
    Abrir UauXT, Confirmar Popup E Preencher Login    ${caminho_exe}    ${credenciais}
    Log    [UAUXT] Sistema pronto para uso.    console=True

Abrir Seletor Empresa E Obra
    [Documentation]    Clica no botao de empresa/obra e aguarda abertura do popup de selecao.
    [Arguments]    ${botao_empresa_obra_locator}    ${popup_empresa_obra_locator}
    ...    ${timeout}=${UAUXT_TIMEOUT_PADRAO}
    Log    [UAUXT] Abrindo seletor de empresa e obra...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Click    ${botao_empresa_obra_locator}
    Pausa Controlada    500ms    Aguardando dialogo de empresa/obra abrir
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Control Window    ${popup_empresa_obra_locator}
    Log    [UAUXT] Dialogo de empresa/obra aberto.    console=True

Selecionar Empresa No Popup Empresa Obra
    [Documentation]    No popup de empresa/obra, digita o codigo da empresa e aplica no grid pelo cabecalho Empresa.
    [Arguments]    ${popup_empresa_obra_locator}    ${grid_empresa_header_locator}    ${codigo_empresa}
    ...    ${timeout}=${UAUXT_TIMEOUT_PADRAO}
    Log    [UAUXT] Selecionando empresa '${codigo_empresa}' no popup...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Control Window    ${popup_empresa_obra_locator}
    Send Keys    keys=${codigo_empresa}
    Pausa Controlada    500ms    Aguardando filtro ser aplicado
    Double Click    ${grid_empresa_header_locator}
    Log    [UAUXT] Empresa '${codigo_empresa}' selecionada no popup.    console=True

# === NAVEGAÇÃO E MENUS ===

Focar No Menu Lateral Angular UauXT
    [Documentation]    Foca no menu lateral Angular do UauXT.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [UAUXT] Focando menu lateral...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Control Window    id:MainView and type:WindowControl
    ${focou_menu}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${timeout}    300ms
    ...    Click    ${UAUXT_MENU_LATERAL_BROWSER}
    IF    not ${focou_menu}
        ${focou_menu}=    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds    ${timeout}    300ms
        ...    Click    ${UAUXT_MENU_LATERAL_HOST}
    END
    IF    not ${focou_menu}
        Fail    Nao foi possivel focar no menu lateral (wbBrowser/MenuXt).
    END
    Log    [UAUXT] Menu lateral em foco.    console=True

Obter Icones Da Coluna Lateral
    [Documentation]    Retorna os icones da coluna lateral a partir do browser do menu.
    ${browser}=    Get Element    ${UAUXT_MENU_LATERAL_BROWSER}
    @{textos}=    Get Elements    ${UAUXT_MENU_LATERAL_BROWSER} > type:TextControl    search_depth=20    siblings_only=${False}
    @{botoes}=    Get Elements    ${UAUXT_MENU_LATERAL_BROWSER} > type:ButtonControl    search_depth=20    siblings_only=${False}
    @{elementos}=    Combine Lists    ${textos}    ${botoes}
    ${browser_left}=    Evaluate    $browser.left
    ${browser_top}=    Evaluate    $browser.top
    ${browser_bottom}=    Evaluate    $browser.bottom
    ${expr_icones}=    Catenate    SEPARATOR=${EMPTY}
    ...    sorted([e for e in $elementos if e.xcenter >= ${browser_left} and e.xcenter <= (${browser_left} + 90) and e.ycenter >= (${browser_top} + 80) and e.ycenter <= ${browser_bottom}], key=lambda x: (x.top, x.left))
    ${icones_coluna}=    Evaluate    ${expr_icones}
    RETURN    ${icones_coluna}

Obter Icone Menu Lateral Por Ordem Vertical
    [Documentation]    Retorna o icone da coluna lateral por ordem vertical (1..N).
    [Arguments]    ${ordem}
    ${icones_coluna}=    Obter Icones Da Coluna Lateral
    ${total}=    Get Length    ${icones_coluna}
    IF    ${total} < ${ordem}
        Fail    Nao ha icones suficientes na coluna lateral. Total=${total}, ordem solicitada=${ordem}.
    END
    ${indice}=    Evaluate    int(${ordem}) - 1
    ${icone}=    Get From List    ${icones_coluna}    ${indice}
    RETURN    ${icone}

Acessar Menu Lateral Por Indice
    [Documentation]    Foca o menu lateral e seleciona um icone pelo indice.
    [Arguments]    ${indice}=${UAUXT_MENU_FINANCEIRO_INDICE}
    Focar No Menu Lateral Angular UauXT
    ${icone}=    Obter Icone Menu Lateral Por Ordem Vertical    ${indice}
    Click    ${icone}
    Pausa Controlada    80ms    Aguardando abertura do submenu
    Log    [UAUXT] Menu lateral acessado no indice ${indice}.    console=True

Selecionar Icone Menu Lateral Por Indice
    [Documentation]    Mantem compatibilidade com o fluxo anterior.
    [Arguments]    ${indice}=${UAUXT_MENU_FINANCEIRO_INDICE}
    Acessar Menu Lateral Por Indice    ${indice}

Selecionar Submenu Por Texto Visual
    [Documentation]    Busca no container do menu lateral um elemento visual cujo texto corresponda exatamente ao submenu desejado.
    [Arguments]    ${nome_submenu}    ${timeout}=${UAUXT_TIMEOUT_MENU}
    ${nome_submenu_normalizado}=    Evaluate    str('${nome_submenu}').strip().casefold()
    @{tipos}=    Create List    TextControl    ButtonControl    MenuItemControl    TreeItemControl    ListItemControl
    FOR    ${tipo}    IN    @{tipos}
        @{elementos}=    Get Elements    ${UAUXT_MENU_LATERAL_BROWSER} > type:${tipo}    search_depth=30    siblings_only=${False}
        FOR    ${elemento}    IN    @{elementos}
            ${nome_elem}=    Evaluate    str(getattr($elemento, 'name', '')).strip()
            ${subname_elem}=    Evaluate    str(getattr($elemento, 'subname', '')).strip()
            ${texto_elem}=    Evaluate    str(getattr($elemento, 'text', '')).strip()
            ${texto_total}=    Catenate    SEPARATOR=${SPACE}    ${nome_elem}    ${subname_elem}    ${texto_elem}
            ${texto_total_normalizado}=    Evaluate    str('${texto_total}').strip().casefold()
            ${matches}=    Evaluate    $texto_total_normalizado == $nome_submenu_normalizado
            IF    ${matches}
                ${clicou}=    Run Keyword And Return Status
                ...    Wait Until Keyword Succeeds    ${timeout}    300ms
                ...    Click    ${elemento}
                IF    ${clicou}
                    RETURN    ${True}
                END
            END
        END
    END
    RETURN    ${False}

Selecionar Submenu Aberto Por Nome
    [Documentation]    Seleciona submenu visivel por texto no menu lateral do WebView2.
    [Arguments]    ${nome_submenu}    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Log    [UAUXT] Navegando para: ${nome_submenu}    console=True
    ${clicou}=    Run Keyword And Return Status
    ...    Selecionar Submenu Por Texto Visual    ${nome_submenu}    ${timeout}
    IF    not ${clicou}
        Fail    Nao foi possivel selecionar submenu '${nome_submenu}' pelo metodo de texto visual.
    END
    Log    [UAUXT] Item '${nome_submenu}' selecionado.    console=True

Clicar Icone Capacete Obras
    [Documentation]    Clica no icone do capacete de obras (Financeiro) no menu lateral.
    [Arguments]    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Acessar Menu Lateral Por Indice    ${UAUXT_MENU_FINANCEIRO_INDICE}
    Pausa Controlada    30ms    Aguardando abertura do menu
    Log    [UAUXT] Icone clicado.    console=True

_Acessar Item Via Icone Capacete Obras Interno
    [Documentation]    Executa o caminho padrao via capacete com 3 niveis de submenu.
    [Arguments]    ${submenu_nivel_1}    ${submenu_nivel_2}    ${submenu_nivel_3}
    ...    ${timeout}=${UAUXT_TIMEOUT_MENU}
    Clicar Icone Capacete Obras    ${timeout}
    Selecionar Submenu Aberto Por Nome    ${submenu_nivel_1}    ${timeout}
    Pausa Controlada    30ms    Aguardando expansao do submenu ${submenu_nivel_1}
    Selecionar Submenu Aberto Por Nome    ${submenu_nivel_2}    ${timeout}
    Pausa Controlada    30ms    Aguardando expansao do submenu ${submenu_nivel_2}
    Selecionar Submenu Aberto Por Nome    ${submenu_nivel_3}    ${timeout}

Acessar Item Via Icone Capacete Obras
    [Documentation]    Padrao de acesso: capacete de obras > nivel 1 > nivel 2 > nivel 3, com retry controlado.
    [Arguments]    ${submenu_nivel_1}    ${submenu_nivel_2}    ${submenu_nivel_3}
    ...    ${timeout}=${UAUXT_TIMEOUT_MENU}
    ${status}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${timeout}    500ms
    ...    _Acessar Item Via Icone Capacete Obras Interno
    ...    ${submenu_nivel_1}
    ...    ${submenu_nivel_2}
    ...    ${submenu_nivel_3}
    ...    ${timeout}
    IF    not ${status}
        Fail    Nao foi possivel acessar item '${submenu_nivel_1} > ${submenu_nivel_2} > ${submenu_nivel_3}' via menu lateral.
    END
    Log    [UAUXT] Caminho '${submenu_nivel_1} > ${submenu_nivel_2} > ${submenu_nivel_3}' acessado com sucesso.    console=True

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
