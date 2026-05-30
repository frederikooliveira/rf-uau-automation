*** Settings ***
Documentation       Exemplo unificado (03 + 04 + 06): login, acesso a Contas a Pagar, filtro e preenchimento DVQ.
Resource            ../../resources/apps/uauxt.resource
Resource            ../../resources/apps/uauxt_grid.resource
Test Tags           examples    uauxt    contas-pagar    dvq    fluxo-completo


*** Variables ***
${EMPRESA_PADRAO}                    262
${DATA_INICIAL_PADRAO}               01/01/2022
${COLUNA_CONFIRMADO}                 5
${VALOR_CONFIRMADO}                  DVQ
${LINHA_INICIAL_DVQ}                 0
${LINHA_FINAL_DVQ}                   1


*** Test Cases ***
Exemplo Fluxo Completo Contas Pagar Com DVQ
    [Documentation]    Abre/loga no UauXT, acessa Contas a Pagar, filtra dados e preenche DVQ.
    Log    [EXEMPLO] Iniciando fluxo completo (login > menu > filtro > DVQ)...    console=True
    Abrir E Logar No UauXT
    Pausa Controlada    10s    Aguardando carregamento completo apos login
    Acessar Contas A Pagar Via Icone Capacete Obras
    Selecionar Empresa E Obra
    Selecionar Empresa No Popup    ${EMPRESA_PADRAO}
    Pausa Controlada    1s    Aguardando processamento do filtro de empresa
    Configurar Periodo Prorrogacao
    Preencher DVQ Nas Duas Primeiras Linhas
    Log    [EXEMPLO] Fluxo completo concluido com sucesso.    console=True


*** Keywords ***
Selecionar Empresa No Popup
    [Documentation]    No popup Selecao de obras, digita o valor e aplica filtro por duplo clique no cabecalho Empresa.
    [Arguments]    ${valor_empresa}    ${timeout}=15s
    Log    [POPUP] Aguardando popup frmSelecaoEmpresaObra...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Control Window    id:frmSelecaoEmpresaObra
    Log    [POPUP] Digitando '${valor_empresa}' na celula de filtro ja focada...    console=True
    Send Keys    keys=${valor_empresa}
    Pausa Controlada    500ms    Aguardando filtro ser aplicado
    Double Click    id:gridEmpresaObra > name:Empresa and type:HeaderControl
    Log    [POPUP] Filtro de empresa aplicado no popup.    console=True

Selecionar Empresa E Obra
    [Documentation]    Abre o dialogo de selecao de empresa/obra.
    [Arguments]    ${timeout}=15s
    Log    [CONTAS_PAGAR] Abrindo seletor de empresa e obra...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Click    id:ucContainer > path:1|1|1|2|1
    Pausa Controlada    500ms    Aguardando dialogo abrir

Configurar Periodo Prorrogacao
    [Documentation]    Configura periodo (data inicial ate data atual) e executa busca.
    [Arguments]    ${data_inicial}=${DATA_INICIAL_PADRAO}    ${timeout}=15s
    ${data_atual}=    Evaluate    datetime.datetime.now().strftime('%d/%m/%Y')    modules=datetime
    Log    [CONTAS_PAGAR] Configurando periodo ${data_inicial} ate ${data_atual}...    console=True
    ${locator_inicial}=    Aguardar Campos Periodo Prorrogacao    inicial    ${timeout}
    ${locator_final}=    Aguardar Campos Periodo Prorrogacao    final    ${timeout}
    Preencher Campo De Data    ${locator_inicial}    ${data_inicial}    inicial
    Preencher Campo De Data    ${locator_final}    ${data_atual}    final
    Executar Busca Com Periodo Prorrogacao

Aguardar Campos Periodo Prorrogacao
    [Documentation]    Aguarda e resolve locator do campo de data (inicial/final), com fallback entre versões.
    [Arguments]    ${tipo_campo}=inicial    ${timeout}=5s
    Log    [CONTAS_PAGAR] Resolvendo campo de data '${tipo_campo}' (timeout=${timeout})...    console=True
    @{locators}=    Obter Locators Campo Data    ${tipo_campo}
    FOR    ${locator}    IN    @{locators}
        ${ok}=    Run Keyword And Return Status
        ...    Get Element    ${locator}
        IF    ${ok}
            Log    [CONTAS_PAGAR] Campo '${tipo_campo}' localizado com: ${locator}    console=True
            RETURN    ${locator}
        END
    END
    Log
    ...    [CONTAS_PAGAR] Nao foi possivel localizar campo '${tipo_campo}'.
    ...    Dump de arvore para diagnostico.
    ...    console=True
    Print Tree    id:MainView and type:WindowControl    max_depth=16    log_as_warnings=True
    Fail    Campo de data '${tipo_campo}' nao localizado. Revise locators desta tela.

Obter Locators Campo Data
    [Documentation]    Retorna lista de locators candidatos para campo de data inicial/final.
    [Arguments]    ${tipo_campo}
    IF    '${tipo_campo}' == 'inicial'
        @{locators}=    Create List
        ...    id:ucContainer > id:mskDataInicial
        ...    id:mskDataInicial and type:EditControl
        ...    subname:Inicial and type:EditControl
        ...    name:Data Inicial and type:EditControl
        RETURN    @{locators}
    END
    @{locators}=    Create List
    ...    id:ucContainer > id:mskDataFinal
    ...    id:mskDataFinal and type:EditControl
    ...    subname:Final and type:EditControl
    ...    name:Data Final and type:EditControl
    RETURN    @{locators}

Preencher Campo De Data
    [Documentation]    Preenche um campo de data e confirma com Enter.
    [Arguments]    ${locator}    ${valor_data}    ${nome_campo}
    Click    ${locator}
    Send Keys    keys={CTRL}a{DELETE}${valor_data}
    Send Keys    keys={ENTER}
    Log    [CONTAS_PAGAR] Data ${nome_campo} preenchida: ${valor_data}.    console=True

Executar Busca Com Periodo Prorrogacao
    [Documentation]    Executa busca após preencher período.
    ${locator_busca}=    Resolver Locator Botao Buscar
    Click    ${locator_busca}
    Pausa Controlada    2s    Aguardando retorno da busca

Resolver Locator Botao Buscar
    [Documentation]    Resolve botão Buscar com fallback de locators.
    @{locators}=    Create List
    ...    id:ucContainer > id:23
    ...    id:23 and type:ButtonControl
    ...    name:Buscar and type:ButtonControl
    ...    subname:Buscar and type:ButtonControl
    FOR    ${locator}    IN    @{locators}
        ${ok}=    Run Keyword And Return Status
        ...    Get Element    ${locator}
        IF    ${ok}
            Log    [CONTAS_PAGAR] Botao Buscar localizado com: ${locator}    console=True
            RETURN    ${locator}
        END
    END
    Print Tree    id:MainView and type:WindowControl    max_depth=16    log_as_warnings=True
    Fail    Botao Buscar nao localizado com os locators candidatos.

Preencher DVQ Nas Duas Primeiras Linhas
    [Documentation]    Preenche DVQ na coluna Confirmado para uma faixa de linhas (0-based, inclusiva).
    [Arguments]    ${valor}=${VALOR_CONFIRMADO}
    ...    ${linha_inicial}=${LINHA_INICIAL_DVQ}
    ...    ${linha_final}=${LINHA_FINAL_DVQ}
    ${payload}=    Alterar Celulas No Grid Processos Pagamento Por Faixa De Linhas
    ...    ${COLUNA_CONFIRMADO}
    ...    ${valor}
    ...    ${linha_inicial}
    ...    ${linha_final}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True
    ...    ${ok}
    ...    Preenchimento em lote de DVQ falhou para faixa ${linha_inicial}..${linha_final}.
