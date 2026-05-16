*** Settings ***
Documentation       Exemplo unificado (03 + 04 + 06): login, acesso a Contas a Pagar, filtro e preenchimento DVQ.
Resource            ../../resources/apps/uauxt.resource
Resource            ../../resources/apps/uauxt_grid.resource
Test Tags           examples    uauxt    contas-pagar    dvq    fluxo-completo


*** Variables ***
${EMPRESA_PADRAO}                    7168
${DATA_INICIAL_PADRAO}               01/01/2022
${COLUNA_CONFIRMADO}                 5
${VALOR_CONFIRMADO}                  DVQ


*** Test Cases ***
Exemplo Fluxo Completo Contas Pagar Com DVQ
    [Documentation]    Abre/loga no UauXT, acessa Contas a Pagar, filtra dados e preenche DVQ.
    Log    [EXEMPLO] Iniciando fluxo completo (login > menu > filtro > DVQ)...    console=True
    Abrir E Logar No UauXT
    Pausa Controlada    35s    Aguardando carregamento completo apos login 
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
    Log    [CONTAS_PAGAR] Resolvendo campo de data '${tipo_campo}'...    console=True
    ${popup_aberto}=    Run Keyword And Return Status
    ...    Control Window    id:frmSelecaoEmpresaObra and type:WindowControl
    IF    ${popup_aberto}
        Log    [CONTAS_PAGAR] Popup de empresa/obra ainda aberto. Confirmando selecao para voltar ao formulario...    console=True
        Send Keys    keys={ENTER}
        Pausa Controlada    700ms    Aguardando fechamento do popup de empresa/obra
    END
    Wait Until Keyword Succeeds    ${timeout}    500ms
    ...    Control Window    id:MainView and type:WindowControl
    @{locators}=    Obter Locators Campo Data    ${tipo_campo}
    FOR    ${locator}    IN    @{locators}
        ${ok}=    Run Keyword And Return Status
        ...    Get Element    ${locator}
        IF    ${ok}
            Log    [CONTAS_PAGAR] Campo '${tipo_campo}' localizado com: ${locator}    console=True
            RETURN    ${locator}
        END
    END
    Log    [CONTAS_PAGAR] Nao foi possivel localizar campo '${tipo_campo}'. Dump de arvore para diagnostico.    console=True
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
    [Documentation]    Preenche valor na coluna Confirmado (5) nas linhas 1 e 2 do grid de Processos de pagamento.
    [Arguments]    ${valor}=${VALOR_CONFIRMADO}
    ${payload_linha_1}=    Alterar Celula No Grid Processos Pagamento    0    ${COLUNA_CONFIRMADO}    ${valor}
    ${ok_linha_1}=    Get From Dictionary    ${payload_linha_1}    ok
    Should Be True    ${ok_linha_1}    Preenchimento na linha 1 falhou.
    ${payload_linha_2}=    Alterar Celula No Grid Processos Pagamento    1    ${COLUNA_CONFIRMADO}    ${valor}
    ${ok_linha_2}=    Get From Dictionary    ${payload_linha_2}    ok
    Should Be True    ${ok_linha_2}    Preenchimento na linha 2 falhou.


