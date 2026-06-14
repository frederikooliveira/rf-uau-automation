*** Settings ***
Documentation       Keywords de automacao tecnica para o modulo de Vendas do UauXT.
...                 Responsabilidade: interagir com toolbar, grids e filtros da tela Resumo de Venda.
Library             Collections
Library             RPA.Windows
Resource            ../core/ui_helpers.resource
Resource            ../core/sync.resource
Resource            ../data/vendas_data.resource
Resource            ./uauxt_grid.resource


*** Keywords ***
Selecionar Todas No Popup Resumo Venda
    [Documentation]    Clica na opcao Selecionar todas do popup de empresa/obra.
    Log    [UAUXT-VENDAS] Selecionando todas as obras no popup...    console=True
    ${popup_aberto}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    1s    30ms
    ...    Control Window    ${VENDAS_POPUP_EMPRESA_OBRA_LOCATOR}
    IF    not ${popup_aberto}
        Log
        ...    [UAUXT-VENDAS] Popup de empresa/obra nao esta mais aberto. Seguindo sem selecionar todas.
        ...    console=True
        RETURN
    END
    ${clicou_por_locator}=    Run Keyword And Return Status
    ...    Clicar Opcao Selecionar Todas No Popup Por Locator
    IF    not ${clicou_por_locator}    Selecionar Todas No Popup Via Teclado
    Log    [UAUXT-VENDAS] Selecao de todas as obras concluida.    console=True

Clicar Opcao Selecionar Todas No Popup Por Locator
    [Documentation]    Tenta clicar na opcao Selecionar todas usando locators de nome no escopo do popup.
    FOR    ${locator}    IN
    ...    ${VENDAS_POPUP_SELECIONAR_TODAS_LOCATOR}
    ...    ${VENDAS_POPUP_SELEC_TODAS_ALT_LOC}
    ...    ${VENDAS_POPUP_SELEC_TODAS_AMP_LOC}
        ${locator_popup}=    Set Variable    ${VENDAS_POPUP_EMPRESA_OBRA_LOCATOR} > ${locator}
        ${ok}=    Run Keyword And Return Status    Click    ${locator_popup}
        IF    ${ok}
            Pausa Controlada    300ms    Aguardando selecao de todas as obras
            Log    [UAUXT-VENDAS] Opcao Selecionar todas acionada.    console=True
            RETURN
        END
    END
    Fail    Nao foi possivel localizar a opcao Selecionar todas por locator no popup.

Selecionar Todas No Popup Via Teclado
    [Documentation]    Fallback por teclado para selecionar todas as obras no popup.
    Log    [UAUXT-VENDAS] Fallback: selecionando todas via teclado (Ctrl+A + Enter)...    console=True
    Send Keys    keys={CTRL}a
    Pausa Controlada    300ms    Aguardando selecao de todas via teclado
    Send Keys    keys={ENTER}
    Pausa Controlada    300ms    Aguardando confirmacao da selecao

Executar Busca Resumo Venda
    [Documentation]    Clica no botão &Buscar da tela Resumo de Venda.
    Log    [UAUXT-VENDAS] Executando busca...    console=True
    Wait Until Keyword Succeeds    ${VENDAS_TIMEOUT_BUSCA}    1s
    ...    Click    ${VENDAS_RESUMO_BTN_BUSCAR_LOCATOR}
    Pausa Controlada    ${VENDAS_DELAY_APOS_BUSCA_MS}    Aguardando carregamento dos resultados
    Log    [UAUXT-VENDAS] Busca executada com locator id (AutomationId=45).    console=True

Selecionar Filtro Tipo Comprador
    [Documentation]    Seleciona filtro de tipo de comprador.
    ...                Opcoes: Todos, Titular, Nao titular, Avalista, Proprietario.
    [Arguments]    ${filtro_locator}
    Log    [UAUXT-VENDAS] Selecionando filtro tipo comprador: ${filtro_locator}...    console=True
    Click    ${filtro_locator}
    Log    [UAUXT-VENDAS] Filtro selecionado.    console=True

Marcar Checkbox Filtro Resumo Venda
    [Documentation]    Marca ou desmarca checkbox de filtro (Por titular ou Antecipação).
    [Arguments]    ${checkbox_locator}
    Log    [UAUXT-VENDAS] Alternando checkbox: ${checkbox_locator}...    console=True
    Click    ${checkbox_locator}
    Log    [UAUXT-VENDAS] Checkbox alternado.    console=True

Aguardar Tela Resumo Venda
    [Documentation]    Aguarda abertura da tela, mede o tempo e valida o limite configurado.
    Log    [UAUXT-VENDAS] Aguardando contexto da tela Resumo de Venda...    console=True
    ${tempo_abertura_ms}=    Aguardar Tela Com Tempo De Abertura
    ...    ${VENDAS_RESUMO_TELA_LOCATOR}
    ...    tela Resumo de Venda
    ...    elemento
    ...    ${VENDAS_TIMEOUT_PADRAO}
    ...    ${VENDAS_RESUMO_TEMPO_MAX_ABERTURA_MS}
    Log    [UAUXT-VENDAS] Contexto da tela pronto em ${tempo_abertura_ms} ms.    console=True

Obter Quantidade De Registros No Grid Principal Resumo Venda
    [Documentation]    Localiza o grid principal do resumo de venda e retorna a quantidade de linhas lidas no preview.
    [Arguments]    ${min_registros}=0
    ${grid}=    Registrar Grid UauXT Por Win32
    ...    ${VENDAS_RESUMO_GRID_TARGET_TEXT}
    ...    ${VENDAS_RESUMO_GRID_INDEX}
    ${handle}=    Get From Dictionary    ${grid}    handle
    ${rows}=    Ler Preview De Linhas Do Grid Por Handle
    ...    ${handle}
    ...    ${VENDAS_RESUMO_GRID_MAX_ROWS_PREVIEW}
    ${qtd_registros}=    Get Length    ${rows}
    Should Be True
    ...    int(${qtd_registros}) >= int(${min_registros})
    ...    Grid principal do resumo de venda sem registros suficientes: ${qtd_registros} < ${min_registros}.
    Log
    ...    [UAUXT-VENDAS] Grid principal com ${qtd_registros} registro(s) no preview. handle=${handle}
    ...    console=True
    RETURN    ${qtd_registros}

Aguardar Grid Principal Resumo Venda Com Tempo De Carregamento
    [Documentation]    Aguarda o preenchimento do grid principal apos a busca, mede o tempo e valida o limite maximo.
    [Arguments]    ${min_registros}=${VENDAS_RESUMO_GRID_MIN_REGISTROS}
    Log    [UAUXT-VENDAS] Aguardando preenchimento do grid principal do resumo de venda...    console=True
    ${inicio}=    Evaluate    __import__('time').perf_counter()
    Wait Until Keyword Succeeds    ${VENDAS_TIMEOUT_CARREGAMENTO_GRID}    1s
    ...    Obter Quantidade De Registros No Grid Principal Resumo Venda    ${min_registros}
    ${fim}=    Evaluate    __import__('time').perf_counter()
    ${tempo_ms}=    Evaluate    int(round((${fim} - ${inicio}) * 1000))
    ${tempo_s}=    Evaluate    round((${fim} - ${inicio}), 3)
    Log
    ...    [UAUXT-VENDAS] Grid principal carregado em ${tempo_s}s (${tempo_ms} ms).
    ...    console=True
    Should Be True
    ...    ${tempo_ms} <= ${VENDAS_RESUMO_MAX_CARREG_GRID_MS}
    ...    Tempo de carregamento do grid acima do limite: ${tempo_ms} ms > ${VENDAS_RESUMO_MAX_CARREG_GRID_MS} ms.
    RETURN    ${tempo_ms}

Selecionar Registros No Grid Principal Resumo Venda
    [Documentation]    Seleciona linhas (indices 0-based) no grid principal do resumo de venda.
    [Arguments]    @{row_indexes}
    ${total_indices}=    Get Length    ${row_indexes}
    Should Be True    ${total_indices} > 0    Informe ao menos um indice de linha para selecao no grid principal.
    Log    [UAUXT-VENDAS] Selecionando ${total_indices} registro(s) no grid principal...    console=True
    FOR    ${row_index}    IN    @{row_indexes}
        Selecionar Linha No Grid UauXT
        ...    ${row_index}
        ...    ${VENDAS_RESUMO_GRID_TARGET_TEXT}
        ...    ${VENDAS_RESUMO_GRID_INDEX}
    END
    Log    [UAUXT-VENDAS] Selecao de registros no grid principal concluida.    console=True

Aguardar Popup Relatorio Demonstrativo De Pagamentos
    [Documentation]    Aguarda o popup de Relatorio demonstrativo de pagamentos e garante o contexto ativo.
    [Arguments]    ${timeout}=${VENDAS_REL_DEMONSTRATIVO_TIMEOUT_PADRAO}
    Log    [UAUXT-VENDAS] Aguardando popup de Relatorio demonstrativo de pagamentos...    console=True
    ${achou_janela}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Control Window    ${VENDAS_REL_DEMONSTRATIVO_JANELA_LOCATOR}
    IF    ${achou_janela}
        Log    [UAUXT-VENDAS] Popup localizado por subname + classe.    console=True
        Log    [UAUXT-VENDAS] Popup de Relatorio demonstrativo de pagamentos ativo.    console=True
        RETURN
    END
    Fail    Nao foi possivel localizar a janela do relatorio demonstrativo de pagamentos.
