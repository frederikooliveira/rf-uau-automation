*** Settings ***
Documentation       Keywords de dominio de negocio para Contas a Pagar.
...                 Responsabilidade: fluxos de negocio (nao UI tecnica).
Library             String
Library             Collections
Resource            ../apps/uauxt.resource
Resource            ../apps/uauxt_grid.resource
Resource            ../data/contas_pagar_data.resource


*** Keywords ***
Validar Locator Configurado
    [Documentation]    Falha cedo quando um locator nao foi mapeado.
    [Arguments]    ${locator}    ${nome_locator}
    IF    '${locator}'.startswith('TODO_CONFIGURAR_')
        Fail    Locator nao configurado: ${nome_locator}. Atualize em resources/data/contas_pagar_data.resource.
    END

Selecionar Empresa E Obra
    [Documentation]    Abre o dialogo de selecao de empresa e obra.
    [Arguments]    ${timeout}=${CONTAS_PAGAR_TIMEOUT_PADRAO}
    Validar Locator Configurado    ${CONTAS_PAGAR_BOTAO_EMPRESA_OBRA_LOCATOR}    CONTAS_PAGAR_BOTAO_EMPRESA_OBRA_LOCATOR
    Log    [DOM-CP] Abrindo seletor de empresa e obra...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Click    ${CONTAS_PAGAR_BOTAO_EMPRESA_OBRA_LOCATOR}
    Pausa Controlada    500ms    Aguardando dialogo de empresa/obra abrir
    Log    [DOM-CP] Dialogo de empresa/obra aberto.    console=True

Selecionar Empresa No Popup
    [Documentation]    No popup de selecao de obras, digita o codigo da empresa e aplica filtro
    ...                por duplo clique no cabecalho Empresa.
    [Arguments]    ${valor_empresa}    ${timeout}=${CONTAS_PAGAR_TIMEOUT_PADRAO}
    Validar Locator Configurado    ${CONTAS_PAGAR_POPUP_EMPRESA_LOCATOR}    CONTAS_PAGAR_POPUP_EMPRESA_LOCATOR
    Validar Locator Configurado    ${CONTAS_PAGAR_GRID_EMPRESA_HEADER_LOCATOR}    CONTAS_PAGAR_GRID_EMPRESA_HEADER_LOCATOR
    Log    [DOM-CP] Aguardando popup de selecao de empresa...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Control Window    ${CONTAS_PAGAR_POPUP_EMPRESA_LOCATOR}
    Log    [DOM-CP] Digitando codigo da empresa: '${valor_empresa}'...    console=True
    Send Keys    keys=${valor_empresa}
    Pausa Controlada    500ms    Aguardando filtro ser aplicado
    Double Click    ${CONTAS_PAGAR_GRID_EMPRESA_HEADER_LOCATOR}
    Log    [DOM-CP] Empresa '${valor_empresa}' selecionada.    console=True

Configurar Periodo Prorrogacao
    [Documentation]    Configura periodo de prorrogacao (data inicial ate data atual) e executa busca.
    [Arguments]    ${data_inicial}=${CONTAS_PAGAR_DATA_INICIAL_PADRAO}    ${timeout}=${CONTAS_PAGAR_TIMEOUT_PADRAO}
    ${data_atual}=    Evaluate    datetime.datetime.now().strftime('%d/%m/%Y')    modules=datetime
    Log    [DOM-CP] Configurando periodo ${data_inicial} ate ${data_atual}...    console=True
    ${locator_inicial}=    Aguardar Campo Data Por Tipo    inicial    ${timeout}
    ${locator_final}=    Aguardar Campo Data Por Tipo    final    ${timeout}
    Preencher Campo De Data    ${locator_inicial}    ${data_inicial}    inicial
    Preencher Campo De Data    ${locator_final}    ${data_atual}    final
    Executar Busca
    Log    [DOM-CP] Periodo configurado e busca executada.    console=True

Aguardar Campo Data Por Tipo
    [Documentation]    Resolve e aguarda locator do campo de data (inicial/final) com fallback.
    [Arguments]    ${tipo_campo}    ${timeout}=${CONTAS_PAGAR_TIMEOUT_PADRAO}
    Log    [DOM-CP] Resolvendo campo de data '${tipo_campo}'...    console=True
    @{locators}=    Obter Locators Campo Data    ${tipo_campo}
    FOR    ${locator}    IN    @{locators}
        ${ok}=    Run Keyword And Return Status    Get Element    ${locator}
        IF    ${ok}
            Log    [DOM-CP] Campo '${tipo_campo}' localizado: ${locator}    console=True
            RETURN    ${locator}
        END
    END
    Print Tree    id:MainView and type:WindowControl    max_depth=16    log_as_warnings=True
    Fail    Campo de data '${tipo_campo}' nao localizado. Revise locators em contas_pagar_data.resource.

Obter Locators Campo Data
    [Documentation]    Retorna lista de locators candidatos para campo de data inicial ou final.
    [Arguments]    ${tipo_campo}
    IF    '${tipo_campo}' == 'inicial'
        @{locators}=    Create List
        ...    ${CONTAS_PAGAR_CAMPO_DATA_INICIAL_LOCATOR}
        ...    id:mskDataInicial and type:EditControl
        ...    subname:Inicial and type:EditControl
        ...    name:Data Inicial and type:EditControl
        RETURN    @{locators}
    END
    @{locators}=    Create List
    ...    ${CONTAS_PAGAR_CAMPO_DATA_FINAL_LOCATOR}
    ...    id:mskDataFinal and type:EditControl
    ...    subname:Final and type:EditControl
    ...    name:Data Final and type:EditControl
    RETURN    @{locators}

Preencher Campo De Data
    [Documentation]    Limpa e preenche um campo de data, confirmando com Enter.
    [Arguments]    ${locator}    ${valor_data}    ${nome_campo}
    Log    [DOM-CP] Preenchendo data ${nome_campo}: ${valor_data}    console=True
    Click    ${locator}
    Pausa Controlada    20ms    Foco no campo ${nome_campo}
    Send Keys    keys={CTRL}a{DELETE}${valor_data}
    Send Keys    keys={ENTER}

Executar Busca
    [Documentation]    Aciona o botao Buscar com fallback de locators.
    Log    [DOM-CP] Executando busca...    console=True
    @{locators}=    Create List
    ...    ${CONTAS_PAGAR_BOTAO_BUSCAR_LOCATOR}
    ...    id:23 and type:ButtonControl
    ...    name:Buscar and type:ButtonControl
    ...    subname:Buscar and type:ButtonControl
    FOR    ${locator}    IN    @{locators}
        ${ok}=    Run Keyword And Return Status    Get Element    ${locator}
        IF    ${ok}
            Click    ${locator}
            Pausa Controlada    2s    Aguardando resultados da busca
            Log    [DOM-CP] Busca executada.    console=True
            RETURN
        END
    END
    Print Tree    id:MainView and type:WindowControl    max_depth=16    log_as_warnings=True
    Fail    Botao Buscar nao localizado. Revise locators em contas_pagar_data.resource.

Preencher Confirmado Por Faixa
    [Documentation]    Preenche a coluna Confirmado do grid de Processos de pagamento para uma faixa de linhas.
    [Arguments]    ${valor}    ${linha_inicial}    ${linha_final}
    Log    [DOM-CP] Preenchendo '${valor}' na coluna Confirmado, linhas ${linha_inicial}..${linha_final}...    console=True
    ${payload}=    Alterar Celulas No Grid Processos Pagamento Por Faixa De Linhas
    ...    ${CONTAS_PAGAR_COLUNA_CONFIRMADO}
    ...    ${valor}
    ...    ${linha_inicial}
    ...    ${linha_final}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Preenchimento de '${valor}' na coluna Confirmado falhou (faixa ${linha_inicial}..${linha_final}).
    Log    [DOM-CP] Coluna Confirmado preenchida com '${valor}'.    console=True

Alterar Banco Do Processo
    [Documentation]    Abre o popup de banco na linha alvo, digita o codigo e confirma.
    [Arguments]    ${row_index}    ${codigo_banco}
    Log    [DOM-CP] Alterando banco da linha ${row_index} para '${codigo_banco}'...    console=True
    ${payload}=    Clicar Botao Da Celula No Grid Processos Pagamento
    ...    ${row_index}
    ...    ${CONTAS_PAGAR_COLUNA_BANCO}
    ...    alt-down
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Nao foi possivel acionar popup de banco na linha ${row_index}.
    Pausa Controlada    800ms    Aguardando abertura do popup de banco
    Send Keys    keys=${codigo_banco}
    Pausa Controlada    300ms    Aguardando filtro do banco
    Send Keys    keys={ENTER}
    Pausa Controlada    500ms    Aguardando confirmacao e retorno ao grid
    Log    [DOM-CP] Banco '${codigo_banco}' selecionado na linha ${row_index}.    console=True

Alterar Conta Do Processo
    [Documentation]    Abre o popup de conta na linha alvo, digita o codigo e confirma.
    [Arguments]    ${row_index}    ${codigo_conta}
    Log    [DOM-CP] Alterando conta da linha ${row_index} para '${codigo_conta}'...    console=True
    ${payload}=    Clicar Botao Da Celula No Grid Processos Pagamento
    ...    ${row_index}
    ...    ${CONTAS_PAGAR_COLUNA_CONTA}
    ...    alt-down
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Nao foi possivel acionar popup de conta na linha ${row_index}.
    Pausa Controlada    800ms    Aguardando abertura do popup de conta
    Send Keys    keys=${codigo_conta}
    Pausa Controlada    300ms    Aguardando filtro da conta
    Send Keys    keys={ENTER}
    Pausa Controlada    500ms    Aguardando confirmacao e retorno ao grid
    Log    [DOM-CP] Conta '${codigo_conta}' selecionada na linha ${row_index}.    console=True

Clicar Botao Na Toolbar Acoes
    [Documentation]    Clica em botao da toolbar de acoes (msvb_lib_toolbar) pelo indice 0-based.
    ...                Indices mapeados em contas_pagar_data.resource (ex.: CONTAS_PAGAR_TOOLBAR_MANUTENCAO_INDEX).
    ...                Use keyword 'Listar Botoes Toolbar Via Probe' para descobrir novos indices.
    ...                click_x_pct: fracao horizontal do clique no rect do botao (0.5=centro, 0.85=borda direita/dropdown).
    [Arguments]    ${button_index}    ${timeout}=10s    ${click_x_pct}=0.5
    Log    [DOM-CP] Clicando botao toolbar idx=${button_index} (x_pct=${click_x_pct}) via probe Win32...    console=True
    Clicar Botao Toolbar Por Indice Via Probe    ${button_index}    click_x_pct=${click_x_pct}
    Log    [DOM-CP] Botao idx=${button_index} clicado com sucesso.    console=True

Selecionar Linha E Clicar Toolbar
    [Documentation]    Seleciona uma linha no grid de Processos de pagamento e clica em um botao da toolbar de acoes.
    ...                button_index: indice 0-based do botao na toolbar (veja contas_pagar_data.resource).
    [Arguments]    ${row_index}    ${button_index}    ${timeout}=${CONTAS_PAGAR_TIMEOUT_PADRAO}
    Log    [DOM-CP] Selecionando linha ${row_index} e acionando toolbar idx=${button_index}...    console=True
    Selecionar Linha No Grid Processos Pagamento    ${row_index}
    Pausa Controlada    300ms    Aguardando selecao da linha
    Clicar Botao Na Toolbar Acoes    ${button_index}    ${timeout}
    Log    [DOM-CP] Toolbar idx=${button_index} acionada para linha ${row_index}.    console=True

Clicar Dropdown Imprimir E Selecionar Nota Debito
    [Documentation]    Abre o menu dropdown do botao Imprimir clicando na borda direita (sidebutton/split-button)
    ...                e seleciona a opcao "Nota de debito" via teclado (DOWN + ENTER).
    ...                Menus popup VB6 nao expõem elementos via UIA — navegacao por teclado e obrigatoria.
    ...                Como ha apenas uma opcao no submenu, um DOWN e suficiente para selecionar.
    ...                Pre-requisito: linha ja selecionada no grid.
    Log    [DOM-CP] Abrindo dropdown do botao Imprimir (split-button, x_pct=0.85)...    console=True
    Clicar Botao Na Toolbar Acoes    ${CONTAS_PAGAR_TOOLBAR_IMPRIMIR_SOLICITACAO_INDEX}    click_x_pct=0.85
    Pausa Controlada    400ms    Aguardando menu dropdown abrir
    Log    [DOM-CP] Selecionando primeira opcao do menu via teclado (DOWN + ENTER)...    console=True
    Send Keys    keys={DOWN}
    Pausa Controlada    150ms    Aguardando foco no primeiro item
    Send Keys    keys={ENTER}
    Pausa Controlada    500ms    Aguardando tela de impressao de nota de debito
    Log    [DOM-CP] Opcao 'Nota de debito' acionada com sucesso.    console=True

Selecionar Linha E Imprimir Nota Debito
    [Documentation]    Seleciona uma linha no grid de Processos de pagamento e aciona a impressao
    ...                de nota de debito via dropdown do botao Imprimir.
    [Arguments]    ${row_index}    ${timeout}=${CONTAS_PAGAR_TIMEOUT_PADRAO}
    Log    [DOM-CP] Selecionando linha ${row_index} para impressao de nota de debito...    console=True
    Selecionar Linha No Grid Processos Pagamento    ${row_index}
    Pausa Controlada    300ms    Aguardando selecao da linha
    Clicar Dropdown Imprimir E Selecionar Nota Debito
    Log    [DOM-CP] Impressao de nota de debito acionada para linha ${row_index}.    console=True

