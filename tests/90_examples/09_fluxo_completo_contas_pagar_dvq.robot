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


*** Test Cases ***
Exemplo Fluxo Completo Contas Pagar Com DVQ
    [Documentation]    Abre/loga no UauXT, acessa Contas a Pagar, filtra dados e preenche DVQ.
    Log    [EXEMPLO] Iniciando fluxo completo (login > menu > filtro > DVQ)...    console=True
    Abrir E Logar No UauXT
    Pausa Controlada    15s    Aguardando processamento do filtro de empresa
    Acessar Contas A Pagar Via Icone Maleta
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
    Aguardar Campos Periodo Prorrogacao    ${timeout}
    Preencher Campo De Data    id:ucContainer > id:mskDataInicial    ${data_inicial}    inicial
    Preencher Campo De Data    id:ucContainer > id:mskDataFinal    ${data_atual}    final
    Executar Busca Com Periodo Prorrogacao

Aguardar Campos Periodo Prorrogacao
    [Documentation]    Aguarda os campos de data ficarem disponíveis para edição.
    [Arguments]    ${timeout}=15s
    Wait Until Keyword Succeeds    ${timeout}    500ms
    ...    Get Element    id:ucContainer > id:mskDataInicial

Preencher Campo De Data
    [Documentation]    Preenche um campo de data e confirma com Enter.
    [Arguments]    ${locator}    ${valor_data}    ${nome_campo}
    Click    ${locator}
    Send Keys    keys={CTRL}a{DELETE}${valor_data}
    Send Keys    keys={ENTER}
    Log    [CONTAS_PAGAR] Data ${nome_campo} preenchida: ${valor_data}.    console=True

Executar Busca Com Periodo Prorrogacao
    [Documentation]    Executa busca após preencher período.
    Click    id:ucContainer > id:23
    Pausa Controlada    2s    Aguardando retorno da busca

Preencher DVQ Nas Duas Primeiras Linhas
    [Documentation]    Preenche valor na coluna Confirmado (5) nas linhas 1 e 2 do grid de Processos de pagamento.
    [Arguments]    ${valor}=${VALOR_CONFIRMADO}
    ${payload_linha_1}=    Alterar Celula No Grid Processos Pagamento    0    ${COLUNA_CONFIRMADO}    ${valor}
    ${ok_linha_1}=    Get From Dictionary    ${payload_linha_1}    ok
    Should Be True    ${ok_linha_1}    Preenchimento na linha 1 falhou.
    ${payload_linha_2}=    Alterar Celula No Grid Processos Pagamento    1    ${COLUNA_CONFIRMADO}    ${valor}
    ${ok_linha_2}=    Get From Dictionary    ${payload_linha_2}    ok
    Should Be True    ${ok_linha_2}    Preenchimento na linha 2 falhou.


