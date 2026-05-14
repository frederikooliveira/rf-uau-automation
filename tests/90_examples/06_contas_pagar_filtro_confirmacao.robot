*** Settings ***
Documentation       Exemplo de filtro por empresa/obra e interação com grid de processos.
Resource            ../../resources/apps/uauxt.resource
Resource            ../../resources/apps/uauxt_grid.resource
Test Tags           examples    uauxt    contas-pagar

*** Keywords ***
Selecionar Empresa No Popup
    [Documentation]    No popup Selecao de obras, digita o valor na celula ja focada da coluna Empresa
    ...                e da duplo clique no cabecalho para aplicar o filtro.
    [Arguments]    ${valor_empresa}    ${timeout}=15s
    Log    [POPUP] Aguardando popup frmSelecaoEmpresaObra...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Control Window    id:frmSelecaoEmpresaObra
    Log    [POPUP] Digitando '${valor_empresa}' na celula de filtro ja focada...    console=True
    Send Keys    keys=${valor_empresa}
    Pausa Controlada    500ms    Aguardando filtro ser aplicado
    Log    [POPUP] Executando duplo clique no cabecalho Empresa...    console=True
    Double Click    id:gridEmpresaObra > name:Empresa and type:HeaderControl
    Log    [POPUP] Duplo clique no cabecalho Empresa realizado.    console=True

Selecionar Empresa E Obra
    [Documentation]    Abre o diálogo de seleção de empresa e obra.
    [Arguments]    ${timeout}=15s
    Log    [CONTAS_PAGAR] Abrindo seletor de empresa e obra...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Click    id:ucContainer > path:1|1|1|2|1
    Pausa Controlada    500ms    Aguardando diálogo de empresa/obra abrir
    Log    [CONTAS_PAGAR] Diálogo de empresa/obra aberto.    console=True

Preencher DVQ Na Coluna Confirmado Do Grid Processos Pagamento
    [Documentation]    Preenche DVQ na coluna Confirmado (5) das duas primeiras linhas do grid.
    Log    [CONTAS_PAGAR] Iniciando processo DVQ no grid...    console=True
    ${payload_linha_1}=    Alterar Celula No Grid Processos Pagamento    1    5    DVQ
    ${ok_linha_1}=    Get From Dictionary    ${payload_linha_1}    ok
    Should Be True    ${ok_linha_1}    Preenchimento de DVQ na linha 1 falhou.
    Log    [CONTAS_PAGAR] DVQ preenchido com sucesso na coluna Confirmado.    console=True

Configurar Periodo Prorrogacao
    [Documentation]    Configura o período de prorrogação com data inicial 01/01/2022 até data atual.
    [Arguments]    ${data_inicial}=01/01/2022    ${timeout}=15s
    Log    [CONTAS_PAGAR] Configurando período de prorrogação...    console=True
    ${data_atual}=    Evaluate    datetime.datetime.now().strftime('%d/%m/%Y')    modules=datetime
    Log    [CONTAS_PAGAR] Data inicial: ${data_inicial}, Data atual: ${data_atual}    console=True
    Aguardar Campos Periodo Prorrogacao    ${timeout}
    Preencher Campo De Data    id:ucContainer > id:mskDataInicial    ${data_inicial}    inicial
    Preencher Campo De Data    id:ucContainer > id:mskDataFinal    ${data_atual}    final
    Executar Busca Com Periodo Prorrogacao    ${data_inicial}    ${data_atual}

Aguardar Campos Periodo Prorrogacao
    [Documentation]    Aguarda os campos de data ficarem disponíveis para edição.
    [Arguments]    ${timeout}=15s
    Wait Until Keyword Succeeds    ${timeout}    500ms
    ...    Get Element    id:ucContainer > id:mskDataInicial

Preencher Campo De Data
    [Documentation]    Preenche um campo de data e confirma com Enter.
    [Arguments]    ${locator}    ${valor_data}    ${nome_campo}
    Log    [CONTAS_PAGAR] Preenchendo data ${nome_campo}: ${valor_data}    console=True
    Click    ${locator}
    Pausa Controlada    20ms    Foco no campo ${nome_campo}
    Send Keys    keys={CTRL}a{DELETE}${valor_data}
    Send Keys    keys={ENTER}

Executar Busca Com Periodo Prorrogacao
    [Documentation]    Aciona o botão Buscar após preenchimento do período.
    [Arguments]    ${data_inicial}    ${data_atual}
    Pausa Controlada    5ms    Aguardando processamento das datas
    Log    [CONTAS_PAGAR] Período de prorrogação configurado. Clicando em Buscar...    console=True
    Log    [CONTAS_PAGAR] Clicando botão Buscar: AutomationId 23    console=True
    Click    id:ucContainer > id:23
    Pausa Controlada    2s    Aguardando resultados da busca
    Log    [CONTAS_PAGAR] Busca executada com período de prorrogação: ${data_inicial} até ${data_atual}.    console=True

*** Test Cases ***
Exemplo Filtro Empresa Obra E Confirmacao Grid
    [Documentation]    Demonstra seleção de empresa/obra, configuração de período e marca confirmação no grid.
    ...                Pré-requisito: estar na tela de Contas a Pagar.
    Log    [EXEMPLO] Iniciando exemplo completo de filtro, período e confirmação...    console=True
    Selecionar Empresa E Obra
    Selecionar Empresa No Popup    262
    Pausa Controlada    1s    Aguardando processamento do filtro
    Configurar Periodo Prorrogacao
    Preencher DVQ Na Coluna Confirmado Do Grid Processos Pagamento
    Log    [EXEMPLO] Exemplo completo de filtro, período e confirmação concluído com sucesso.    console=True
