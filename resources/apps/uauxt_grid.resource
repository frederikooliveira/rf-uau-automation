*** Settings ***
Documentation       Keywords de automacao tecnica para descoberta de grid no UauXT.
...                 Responsabilidade: localizar componente Win32 do grid, navegar por teclado e ler linhas por clipboard.
Library             Collections
Library             OperatingSystem
Library             Process
Library             RPA.Windows
Resource            ../core/sync.resource
Resource            ../data/uauxt_grid_data.resource


*** Keywords ***
Parsear Payload Json Do Probe
    [Documentation]    Converte stdout JSON para dicionario Robot.
    [Arguments]    ${json_output}
    ${json_text}=    Evaluate    (lambda s: s[s.find('{'):s.rfind('}')+1].strip() if ('{' in s and '}' in s and s.find('{') <= s.rfind('}')) else s.strip())($json_output)
    Should Not Be Empty    ${json_text}    Probe retornou saida vazia ou sem JSON valido.
    ${payload}=    Evaluate    json.loads($json_text)    modules=json
    RETURN    ${payload}

Extrair Grid Selecionado Do Payload
    [Documentation]    Extrai o bloco selected e valida resposta do probe.
    [Arguments]    ${payload}
    ${ok}=    Get From Dictionary    ${payload}    ok
    IF    not ${ok}
        Fail    Nao foi possivel localizar grid no UauXT: ${payload}
    END
    ${selected}=    Get From Dictionary    ${payload}    selected
    RETURN    ${selected}

Logar Grid Selecionado
    [Documentation]    Escreve em log os dados principais do grid encontrado.
    [Arguments]    ${selected}
    ${handle}=    Get From Dictionary    ${selected}    handle
    ${left}=    Get From Dictionary    ${selected}    left
    ${top}=    Get From Dictionary    ${selected}    top
    ${right}=    Get From Dictionary    ${selected}    right
    ${bottom}=    Get From Dictionary    ${selected}    bottom
    ${width}=    Get From Dictionary    ${selected}    width
    ${height}=    Get From Dictionary    ${selected}    height
    Log
    ...    [UAUXT-GRID] Grid localizado. Handle=${handle} Rect=(${left},${top},${right},${bottom})
    ...    console=True
    Log    [UAUXT-GRID] Tamanho do grid: ${width}x${height}    console=True

Executar Probe Grid UauXT
    [Documentation]    Executa script Python de probe do grid e retorna stdout JSON.
    [Arguments]    @{args}
    ${python_exe}=    Normalize Path    ${EXECDIR}${/}.venv${/}Scripts${/}python.exe
    ${script_path}=    Normalize Path    ${EXECDIR}${/}${UAUXT_GRID_PROBE_SCRIPT}
    Log    [UAUXT-GRID] Executando probe: ${script_path} ${args}    console=True
    ${result}=    Run Process
    ...    ${python_exe}
    ...    ${script_path}
    ...    @{args}
    ...    stdout=PIPE
    ...    stderr=PIPE
    ...    env:PYTHONWARNINGS=ignore:32-bit application should be automated using 32-bit Python
    ...    timeout=${UAUXT_GRID_TIMEOUT_PROBE}
    # Exemplo de log detalhado do probe (desativado para nao poluir a execucao):
    # Log    [UAUXT-GRID] stdout: ${result.stdout}    console=True
    # IF    $result.stderr != ''
    #     Log    [UAUXT-GRID] stderr: ${result.stderr}    console=True
    # END
    IF    ${result.rc} != 0
        Fail    Probe de grid falhou com rc=${result.rc}. Veja logs [UAUXT-GRID].
    END
    RETURN    ${result.stdout}

Registrar Grid UauXT Por Win32
    [Documentation]    Localiza o grid pelo probe Win32 e retorna metadados do componente.
    [Arguments]    ${target_text}=${UAUXT_GRID_TARGET_TEXT}    ${grid_index}=${UAUXT_GRID_PREFERRED_INDEX}
    ${json_output}=    Executar Probe Grid UauXT
    ...    find-grid
    ...    --target-text
    ...    ${target_text}
    ...    --window-title-regex
    ...    ${UAUXT_GRID_WINDOW_TITLE_REGEX}
    ...    --tokens
    ...    ${UAUXT_GRID_CLASS_TOKENS_CSV}
    ...    --grid-index
    ...    ${grid_index}
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${selected}=    Extrair Grid Selecionado Do Payload    ${payload}
    Logar Grid Selecionado    ${selected}
    RETURN    ${selected}

Posicionar Cursor No Grid UauXT
    [Documentation]    Foca grid, envia PageUp para topo e navega por setas (linhas/colunas).
    [Arguments]
    ...    ${target_text}=${UAUXT_GRID_TARGET_TEXT}
    ...    ${grid_index}=${UAUXT_GRID_PREFERRED_INDEX}
    ...    ${row_steps}=${UAUXT_GRID_NAV_ROW_STEPS}
    ...    ${col_steps}=${UAUXT_GRID_NAV_COL_STEPS}
    ...    ${row_direction}=${UAUXT_GRID_NAV_ROW_DIRECTION}
    ...    ${col_direction}=${UAUXT_GRID_NAV_COL_DIRECTION}
    ${grid}=    Registrar Grid UauXT Por Win32    ${target_text}    ${grid_index}
    ${handle}=    Get From Dictionary    ${grid}    handle
    ${json_output}=    Executar Probe Grid UauXT
    ...    navigate-grid
    ...    --handle
    ...    ${handle}
    ...    --page-up-times
    ...    1
    ...    --row-steps
    ...    ${row_steps}
    ...    --col-steps
    ...    ${col_steps}
    ...    --row-direction
    ...    ${row_direction}
    ...    --col-direction
    ...    ${col_direction}
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Nao foi possivel posicionar cursor no grid.
    Log    [UAUXT-GRID] Cursor posicionado no grid. handle=${handle} linha=${row_steps} coluna=${col_steps}    console=True
    RETURN    ${payload}

Preencher Valor No Grid UauXT
    [Documentation]    Localiza grid, volta ao topo (PageUp+Home) e preenche valor em linhas sequenciais de uma coluna.
    [Arguments]     ${target_text}=${UAUXT_GRID_TARGET_TEXT}
    ...    ${grid_index}=${UAUXT_GRID_PREFERRED_INDEX}
    ...    ${start_row}=0
    ...    ${col_index}=1
    ...    ${rows_count}=1
    ...    ${value}=${EMPTY}
    ${grid}=    Registrar Grid UauXT Por Win32    ${target_text}    ${grid_index}
    ${handle}=    Get From Dictionary    ${grid}    handle
    ${json_output}=    Executar Probe Grid UauXT
    ...    fill-grid
    ...    --handle
    ...    ${handle}
    ...    --page-up-times
    ...    1
    ...    --start-row
    ...    ${start_row}
    ...    --col-index
    ...    ${col_index}
    ...    --rows-count
    ...    ${rows_count}
    ...    --value
    ...    ${value}
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Nao foi possivel preencher valor no grid.
    Log    [UAUXT-GRID] Preenchimento aplicado. handle=${handle} coluna=${col_index} linhas=${rows_count} valor='${value}'    console=True
    RETURN    ${payload}

Alterar Celula No Grid UauXT
    [Documentation]    Altera uma celula especifica do grid informando linha, coluna e valor.
    [Arguments]   ${target_text}=${UAUXT_GRID_TARGET_TEXT}
    ...    ${row_index}=0
    ...    ${col_index}=1
    ...    ${value}=${EMPTY}
    ...    ${grid_index}=${UAUXT_GRID_PREFERRED_INDEX}
    ${grid}=    Registrar Grid UauXT Por Win32    ${target_text}    ${grid_index}
    ${handle}=    Get From Dictionary    ${grid}    handle
    ${json_output}=    Executar Probe Grid UauXT
    ...    set-cell
    ...    --handle
    ...    ${handle}
    ...    --page-up-times
    ...    1
    ...    --row-index
    ...    ${row_index}
    ...    --col-index
    ...    ${col_index}
    ...    --value
    ...    ${value}
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Nao foi possivel alterar celula no grid.
    Log    [UAUXT-GRID] Celula alterada. handle=${handle} linha=${row_index} coluna=${col_index} valor='${value}'    console=True
    RETURN    ${payload}

Alterar Celula No Grid Processos Pagamento
    [Documentation]    Altera celula no grid fixo de Processos de pagamento com assinatura simplificada.
    [Arguments]    ${row_index}    ${col_index}    ${value}
    ${payload}=    Alterar Celula No Grid UauXT
    ...    Processos de pagamento
    ...    ${row_index}
    ...    ${col_index}
    ...    ${value}
    RETURN    ${payload}

Ler Valor Da Celula No Grid UauXT
    [Documentation]    Le o valor de uma celula especifica do grid informando linha e coluna (0-based).
    [Arguments]    ${target_text}=${UAUXT_GRID_TARGET_TEXT}
    ...    ${row_index}=0
    ...    ${col_index}=1
    ...    ${grid_index}=${UAUXT_GRID_PREFERRED_INDEX}
    ${grid}=    Registrar Grid UauXT Por Win32    ${target_text}    ${grid_index}
    ${handle}=    Get From Dictionary    ${grid}    handle
    ${json_output}=    Executar Probe Grid UauXT
    ...    get-cell
    ...    --handle
    ...    ${handle}
    ...    --page-up-times
    ...    1
    ...    --row-index
    ...    ${row_index}
    ...    --col-index
    ...    ${col_index}
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Nao foi possivel ler valor da celula no grid.
    ${cell_value}=    Get From Dictionary    ${payload}    value
    Log    [UAUXT-GRID] Valor lido. handle=${handle} linha=${row_index} coluna=${col_index} valor='${cell_value}'    console=True
    RETURN    ${cell_value}

Ler Valor Da Celula No Grid Processos Pagamento
    [Documentation]    Le valor de uma celula do grid de Processos de pagamento (linha 1-based, converte internamente).
    [Arguments]    ${row_index}    ${col_index}
    ${row_0}=    Evaluate    int($row_index) - 1 if int($row_index) >= 1 else int($row_index)
    ${cell_value}=    Ler Valor Da Celula No Grid UauXT
    ...    ${UAUXT_GRID_PROCESSOS_PAGAMENTO_TARGET_TEXT}
    ...    ${row_0}
    ...    ${col_index}
    ...    ${UAUXT_GRID_PREFERRED_INDEX}
    RETURN    ${cell_value}

Alterar Celulas No Grid UauXT Por Indices De Linha
    [Documentation]    Preenche uma coluna para uma lista de indices de linha em uma unica navegacao.
    [Arguments]    ${target_text}=${UAUXT_GRID_TARGET_TEXT}
    ...    ${col_index}=1
    ...    ${value}=${EMPTY}
    ...    ${grid_index}=${UAUXT_GRID_PREFERRED_INDEX}
    ...    ${move_delay_ms}=${UAUXT_GRID_BATCH_MOVE_DELAY_MS}
    ...    ${type_delay_ms}=${UAUXT_GRID_BATCH_TYPE_DELAY_MS}
    ...    ${commit_delay_ms}=${UAUXT_GRID_BATCH_COMMIT_DELAY_MS}
    ...    @{row_indexes}
    ${total_indices}=    Get Length    ${row_indexes}
    Should Be True    ${total_indices} > 0    Informe ao menos um indice de linha para preenchimento em lote.
    ${row_indexes_csv}=    Evaluate    ','.join(str(int(i)) for i in $row_indexes)
    ${grid}=    Registrar Grid UauXT Por Win32    ${target_text}    ${grid_index}
    ${handle}=    Get From Dictionary    ${grid}    handle
    ${json_output}=    Executar Probe Grid UauXT
    ...    fill-grid-indexes
    ...    --handle
    ...    ${handle}
    ...    --page-up-times
    ...    1
    ...    --col-index
    ...    ${col_index}
    ...    --row-indexes
    ...    ${row_indexes_csv}
    ...    --value
    ...    ${value}
    ...    --move-delay-ms
    ...    ${move_delay_ms}
    ...    --type-delay-ms
    ...    ${type_delay_ms}
    ...    --commit-delay-ms
    ...    ${commit_delay_ms}
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${ok}=    Get From Dictionary    ${payload}    ok
    ${touched_rows}=    Get From Dictionary    ${payload}    touched_rows
    Should Be True    ${ok}    Nao foi possivel alterar celulas no grid por indices de linha.
    Log
    ...    [UAUXT-GRID] Preenchimento em lote aplicado. handle=${handle} coluna=${col_index} indices=${row_indexes_csv} tocadas=${touched_rows} valor='${value}' delays(ms)=move:${move_delay_ms},type:${type_delay_ms},commit:${commit_delay_ms}
    ...    console=True
    RETURN    ${payload}

Alterar Celulas No Grid Processos Pagamento Por Indices De Linha
    [Documentation]    Preenche coluna no grid de Processos de pagamento para lista de linhas (0-based).
    [Arguments]    ${col_index}    ${value}
    ...    ${move_delay_ms}=${UAUXT_GRID_BATCH_MOVE_DELAY_MS}
    ...    ${type_delay_ms}=${UAUXT_GRID_BATCH_TYPE_DELAY_MS}
    ...    ${commit_delay_ms}=${UAUXT_GRID_BATCH_COMMIT_DELAY_MS}
    ...    @{row_indexes}
    ${payload}=    Alterar Celulas No Grid UauXT Por Indices De Linha
    ...    ${UAUXT_GRID_PROCESSOS_PAGAMENTO_TARGET_TEXT}
    ...    ${col_index}
    ...    ${value}
    ...    ${UAUXT_GRID_PREFERRED_INDEX}
    ...    ${move_delay_ms}
    ...    ${type_delay_ms}
    ...    ${commit_delay_ms}
    ...    @{row_indexes}
    RETURN    ${payload}

Alterar Celulas No Grid Processos Pagamento Por Faixa De Linhas
    [Documentation]    Preenche coluna no grid de Processos de pagamento para uma faixa inclusiva.
    ...                Regra de base: se linha_inicial >= 1, interpreta como 1-based; se linha_inicial = 0, interpreta como 0-based.
    ...                Commit via DOWN apos cada celula, inclusive a ultima, para garantir saida do modo edicao.
    [Arguments]    ${col_index}    ${value}    ${linha_inicial}    ${linha_final}
    ...    ${move_delay_ms}=${UAUXT_GRID_BATCH_MOVE_DELAY_MS}
    ...    ${type_delay_ms}=${UAUXT_GRID_BATCH_TYPE_DELAY_MS}
    ...    ${commit_delay_ms}=${UAUXT_GRID_BATCH_COMMIT_DELAY_MS}
    ${inicio}=    Convert To Integer    ${linha_inicial}
    ${fim}=    Convert To Integer    ${linha_final}
    Should Be True    ${inicio} >= 0    linha_inicial deve ser >= 0.
    Should Be True    ${fim} >= ${inicio}    linha_final deve ser >= linha_inicial.
    ${usa_base_um}=    Evaluate    int($inicio) >= 1
    ${inicio_0}=    Evaluate    int($inicio) - 1 if bool($usa_base_um) else int($inicio)
    ${fim_0}=    Evaluate    int($fim) - 1 if bool($usa_base_um) else int($fim)
    ${row_indexes}=    Evaluate    list(range(int($inicio_0), int($fim_0) + 1))
    ${payload}=    Alterar Celulas No Grid Processos Pagamento Por Indices De Linha
    ...    ${col_index}
    ...    ${value}
    ...    ${move_delay_ms}
    ...    ${type_delay_ms}
    ...    ${commit_delay_ms}
    ...    @{row_indexes}
    Log
    ...    [UAUXT-GRID] Faixa recebida ${linha_inicial}..${linha_final} (base_um=${usa_base_um}) mapeada para indices 0-based ${inicio_0}..${fim_0}.
    ...    console=True
    RETURN    ${payload}

Clicar Botao Da Celula No Grid UauXT
    [Documentation]    Posiciona em uma celula do grid e clica no canto direito da celula.
    [Arguments]    ${target_text}=${UAUXT_GRID_TARGET_TEXT}
    ...    ${row_index}=0
    ...    ${col_index}=13
    ...    ${grid_index}=${UAUXT_GRID_PREFERRED_INDEX}
    ...    ${interaction_mode}=right-corner-click
    IF    '${interaction_mode}' == 'alt-down'
        ${grid}=    Registrar Grid UauXT Por Win32    ${target_text}    ${grid_index}
        ${handle}=    Get From Dictionary    ${grid}    handle
        ${json_output}=    Executar Probe Grid UauXT
        ...    click-cell-button
        ...    --handle
        ...    ${handle}
        ...    --page-up-times
        ...    1
        ...    --row-index
        ...    ${row_index}
        ...    --col-index
        ...    ${col_index}
        ...    --interaction-mode
        ...    alt-down
        ${payload_alt}=    Parsear Payload Json Do Probe    ${json_output}
        ${ok_alt}=    Get From Dictionary    ${payload_alt}    ok
        Should Be True    ${ok_alt}    Nao foi possivel executar Alt+Down na celula alvo.
        Log
        ...    [UAUXT-GRID] Acao na celula executada via Alt+Down no probe. handle=${handle} linha=${row_index} coluna=${col_index}
        ...    console=True
        RETURN    ${payload_alt}
    END
    ${grid}=    Registrar Grid UauXT Por Win32    ${target_text}    ${grid_index}
    ${handle}=    Get From Dictionary    ${grid}    handle
    ${json_output}=    Executar Probe Grid UauXT
    ...    click-cell-button
    ...    --handle
    ...    ${handle}
    ...    --page-up-times
    ...    1
    ...    --row-index
    ...    ${row_index}
    ...    --col-index
    ...    ${col_index}
    ...    --interaction-mode
    ...    ${interaction_mode}
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Nao foi possivel acionar botao da celula no grid.
    Log
    ...    [UAUXT-GRID] Acao na celula executada. handle=${handle} linha=${row_index} coluna=${col_index} modo=${interaction_mode}
    ...    console=True
    RETURN    ${payload}

Clicar Botao Da Celula No Grid Processos Pagamento
    [Documentation]    Aciona botao de celula no grid fixo de Processos de pagamento.
    [Arguments]    ${row_index}=0    ${col_index}=13    ${interaction_mode}=right-corner-click
    ${payload}=    Clicar Botao Da Celula No Grid UauXT
    ...    ${UAUXT_GRID_PROCESSOS_PAGAMENTO_TARGET_TEXT}
    ...    ${row_index}
    ...    ${col_index}
    ...    ${UAUXT_GRID_PREFERRED_INDEX}
    ...    ${interaction_mode}
    RETURN    ${payload}

Ciclar Opcao Da Celula No Grid Processos Pagamento
    [Documentation]    Posiciona na celula alvo do grid e envia Alt+Seta para baixo para ciclar/abrir opcoes.
    [Arguments]    ${row_index}=0    ${col_index}=13
    ${payload}=    Clicar Botao Da Celula No Grid Processos Pagamento
    ...    ${row_index}
    ...    ${col_index}
    ...    alt-down
    RETURN    ${payload}

Duplo Clique Na Linha Do Grid UauXT
    [Documentation]    Navega ate a linha alvo do grid e executa duplo clique no centro da linha.
    ...                Util para abrir telas de manutencao ou detalhe do registro.
    ...                row_index: 0-based.
    [Arguments]    ${row_index}=0
    ...    ${target_text}=${UAUXT_GRID_TARGET_TEXT}
    ...    ${grid_index}=${UAUXT_GRID_PREFERRED_INDEX}
    ${grid}=    Registrar Grid UauXT Por Win32    ${target_text}    ${grid_index}
    ${handle}=    Get From Dictionary    ${grid}    handle
    ${json_output}=    Executar Probe Grid UauXT
    ...    click-cell-button
    ...    --handle
    ...    ${handle}
    ...    --page-up-times
    ...    1
    ...    --row-index
    ...    ${row_index}
    ...    --col-index
    ...    1
    ...    --interaction-mode
    ...    double-click
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Duplo clique na linha ${row_index} do grid falhou.
    Log    [UAUXT-GRID] Duplo clique executado na linha ${row_index}. handle=${handle}    console=True
    RETURN    ${payload}

Duplo Clique Na Linha Do Grid Processos Pagamento
    [Documentation]    Duplo clique na linha alvo do grid fixo de Processos de pagamento (0-based).
    [Arguments]    ${row_index}=0
    ${payload}=    Duplo Clique Na Linha Do Grid UauXT
    ...    ${row_index}
    ...    ${UAUXT_GRID_PROCESSOS_PAGAMENTO_TARGET_TEXT}
    ...    ${UAUXT_GRID_PREFERRED_INDEX}
    RETURN    ${payload}

Selecionar Linha No Grid UauXT
    [Documentation]    Navega ate a linha alvo e clica na coluna 0 (seletor/checkbox do grid) para marca-la.
    ...                row_index: 0-based.
    [Arguments]    ${row_index}=0
    ...    ${target_text}=${UAUXT_GRID_TARGET_TEXT}
    ...    ${grid_index}=${UAUXT_GRID_PREFERRED_INDEX}
    ${grid}=    Registrar Grid UauXT Por Win32    ${target_text}    ${grid_index}
    ${handle}=    Get From Dictionary    ${grid}    handle
    ${json_output}=    Executar Probe Grid UauXT
    ...    click-cell-button
    ...    --handle
    ...    ${handle}
    ...    --page-up-times
    ...    1
    ...    --row-index
    ...    ${row_index}
    ...    --col-index
    ...    0
    ...    --interaction-mode
    ...    check-row
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Selecao da linha ${row_index} do grid falhou.
    Log    [UAUXT-GRID] Linha ${row_index} selecionada (col 0 - checkbox). handle=${handle}    console=True
    RETURN    ${payload}

Selecionar Linha No Grid Processos Pagamento
    [Documentation]    Seleciona (clique simples) a linha alvo do grid fixo de Processos de pagamento (0-based).
    [Arguments]    ${row_index}=0
    ${payload}=    Selecionar Linha No Grid UauXT
    ...    ${row_index}
    ...    ${UAUXT_GRID_PROCESSOS_PAGAMENTO_TARGET_TEXT}
    ...    ${UAUXT_GRID_PREFERRED_INDEX}
    RETURN    ${payload}

Clicar Botao Toolbar Por Indice Via Probe
    [Documentation]    Clica em botao da toolbar VB6 (msvb_lib_toolbar) pelo indice 0-based.
    ...                A toolbar VB6 nao expoe textos via API — identifique indices com
    ...                'Listar Botoes Toolbar Via Probe' ou probe list-toolbar-buttons.
    ...                click_x_pct: fracao horizontal do rect do botao (0.0=esq, 0.5=centro, 1.0=dir).
    ...                Use ~0.85 para clicar no dropdown/sidebutton de split-buttons.
    [Arguments]    ${button_index}    ${toolbar_class}=msvb_lib_toolbar    ${click_x_pct}=0.5
    Log    [UAUXT-GRID] Clicando botao toolbar idx=${button_index} (x_pct=${click_x_pct}) via probe...    console=True
    ${json_output}=    Executar Probe Grid UauXT
    ...    click-toolbar-button
    ...    --button-index
    ...    ${button_index}
    ...    --toolbar-class
    ...    ${toolbar_class}
    ...    --click-x-pct
    ...    ${click_x_pct}
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Clique no botao idx=${button_index} da toolbar falhou: ${payload}
    Log    [UAUXT-GRID] Botao idx=${button_index} clicado com sucesso.    console=True
    RETURN    ${payload}

Listar Botoes Toolbar Via Probe
    [Documentation]    Descobre e retorna todos os botoes das toolbars da janela UauXT ativa.
    ...                Use para mapear indices de botoes em qualquer tela com msvb_lib_toolbar.
    ...                Retorna payload JSON com lista de toolbars e seus botoes (index + screen_center).
    [Arguments]    ${toolbar_class}=msvb_lib_toolbar
    Log    [UAUXT-GRID] Listando botoes da toolbar '${toolbar_class}'...    console=True
    ${json_output}=    Executar Probe Grid UauXT
    ...    list-toolbar-buttons
    ...    --toolbar-class
    ...    ${toolbar_class}
    ...    --pretty
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    Log    [UAUXT-GRID] Toolbars encontradas: ${payload}    console=True
    RETURN    ${payload}

Mapear Botoes Toolbar Via Probe
    [Documentation]    Faz hover em cada botao da toolbar e captura o nome via tooltip VB6.
    ...                Resultado: lista com index, name (ou "?"), screen_center e is_separator.
    ...                Use para auto-mapear indices em qualquer tela do UauXT.
    ...                toolbar_index: 0=toolbar principal (maior area), 1=segunda (ex: visoes verticais).
    ...                ATENCAO: move o mouse fisicamente sobre cada botao — nao interagir durante execucao.
    ...                hover_delay: tempo (segundos) de espera por tooltip apos hover (default: 0.9).
    [Arguments]    ${toolbar_class}=msvb_lib_toolbar    ${toolbar_index}=0    ${hover_delay}=0.9
    Log    [UAUXT-GRID] Mapeando toolbar '${toolbar_class}' (index=${toolbar_index}) via hover+tooltip...    console=True
    ${json_output}=    Executar Probe Grid UauXT
    ...    map-toolbar-buttons
    ...    --toolbar-class
    ...    ${toolbar_class}
    ...    --toolbar-index
    ...    ${toolbar_index}
    ...    --hover-delay
    ...    ${hover_delay}
    ...    --pretty
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${ok}=    Get From Dictionary    ${payload}    ok
    Should Be True    ${ok}    Mapeamento de toolbar falhou: ${payload}
    ${mapped}=    Get From Dictionary    ${payload}    mapped
    ${total}=     Get From Dictionary    ${payload}    total_buttons
    Log    [UAUXT-GRID] Mapeamento concluido: ${mapped}/${total} botoes com nome identificado.    console=True
    RETURN    ${payload}

Ler Preview De Linhas Do Grid Por Handle
    [Arguments]    ${grid_handle}    ${max_rows}=${UAUXT_GRID_MAX_ROWS_PREVIEW}    ${page_downs}=0
    ${json_output}=    Executar Probe Grid UauXT
    ...    read-grid
    ...    --handle
    ...    ${grid_handle}
    ...    --max-rows
    ...    ${max_rows}
    ...    --page-downs
    ...    ${page_downs}
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${rows}=    Get From Dictionary    ${payload}    rows
    ${rows_count}=    Get From Dictionary    ${payload}    rows_found
    Log    [UAUXT-GRID] Preview de linhas coletado. total=${rows_count}    console=True
    RETURN    ${rows}

Validar Texto Em Linhas Do Grid Por Handle
    [Documentation]    Valida se um texto aparece em alguma linha retornada pelo clipboard.
    [Arguments]    ${grid_handle}    ${texto}    ${max_rows}=${UAUXT_GRID_MAX_ROWS_PREVIEW}    ${page_downs}=0
    ${json_output}=    Executar Probe Grid UauXT
    ...    read-grid
    ...    --handle
    ...    ${grid_handle}
    ...    --contains
    ...    ${texto}
    ...    --max-rows
    ...    ${max_rows}
    ...    --page-downs
    ...    ${page_downs}
    ${payload}=    Parsear Payload Json Do Probe    ${json_output}
    ${found}=    Get From Dictionary    ${payload}    contains_found
    ${rows_count}=    Get From Dictionary    ${payload}    rows_found
    Log    [UAUXT-GRID] Verificacao texto='${texto}' resultado=${found} linhas_lidas=${rows_count}    console=True
    Should Be True    ${found}    Texto '${texto}' nao encontrado nas linhas do grid.

Validar Locator De Grid Configurado
    [Documentation]    Garante que locator nao ficou como TODO_CONFIGURAR_*.
    [Arguments]    ${locator}    ${nome_locator}
    ${locator_text}=    Convert To String    ${locator}
    Should Not Be Empty    ${locator_text}    Locator '${nome_locator}' nao informado.
    ${is_todo}=    Evaluate    str($locator_text).strip().startswith('TODO_CONFIGURAR_')
    Should Be True    not ${is_todo}    Locator '${nome_locator}' precisa ser configurado em resources/data.

Extrair Texto Do Rodape Do Grid
    [Documentation]    Extrai texto do rodape priorizando Name de TextControl e fallbacks.
    [Arguments]    ${rodape_locator}
    ${rodape_texto}=    Set Variable    ${EMPTY}
    ${status}    ${valor}=    Run Keyword And Ignore Error    Get Value    ${rodape_locator}
    IF    '${status}' == 'PASS' and '${valor}' != ''
        ${rodape_texto}=    Convert To String    ${valor}
    END
    IF    '${rodape_texto}' == ''
        ${status_elem}    ${rodape_elem}=    Run Keyword And Ignore Error    Get Element    ${rodape_locator}
        IF    '${status_elem}' == 'PASS'
            ${rodape_texto}=    Evaluate    str(getattr($rodape_elem, 'name', '')).strip()
        END
    END
    ${rodape_texto}=    Evaluate    '' if str($rodape_texto).strip().lower() in ['statusstrip1', 'statusbar', 'barra de status'] else str($rodape_texto).strip()
    IF    '${rodape_texto}' == ''
        ${status_textos}    ${textos}=    Run Keyword And Ignore Error
        ...    Get Elements    ${rodape_locator} > type:TextControl    search_depth=8    siblings_only=${False}
        IF    '${status_textos}' == 'PASS'
            ${rodape_texto}=    Evaluate
            ...    (lambda items: next((t for t in items if 'Selecionado:' in t and 'Total:' in t), ' '.join(items)))([str(getattr(t, 'name', '')).strip() for t in $textos if str(getattr(t, 'name', '')).strip()])
        END
    END
    IF    '${rodape_texto}' == ''
        ${status_global}    ${todos_textos}=    Run Keyword And Ignore Error
        ...    Get Elements    type:TextControl    search_depth=30    siblings_only=${False}
        IF    '${status_global}' == 'PASS'
            ${rodape_texto}=    Evaluate
            ...    (lambda items: next((t for t in items if 'Selecionado:' in t or 'Total:' in t or 'Tempo gasto:' in t), ''))([str(getattr(e, 'name', '')).strip() for e in $todos_textos if str(getattr(e, 'name', '')).strip()])
        END
    END
    RETURN    ${rodape_texto}

Obter Quantidade Registros Do Grid Pelo Rodape
    [Documentation]    Da duplo clique no caption do grid e extrai quantidade de registros do rodape.
    [Arguments]    ${grid_handle}    ${rodape_locator}    ${regex_contagem}=${UAUXT_GRID_COUNT_REGEX}    ${min_registros}=0
    Validar Locator De Grid Configurado    ${rodape_locator}    rodape_locator
    ${refresh_json}=    Executar Probe Grid UauXT
    ...    refresh-footer
    ...    --handle
    ...    ${grid_handle}
    ...    --page-up-times
    ...    1
    ${refresh_payload}=    Parsear Payload Json Do Probe    ${refresh_json}
    ${refresh_ok}=    Get From Dictionary    ${refresh_payload}    ok
    Should Be True    ${refresh_ok}    Nao foi possivel atualizar grid via caption por navegacao.
    Pausa Controlada    700ms    Aguardando atualizacao do rodape do grid
    ${rodape_texto}=    Extrair Texto Do Rodape Do Grid    ${rodape_locator}
    Should Not Be Empty    ${rodape_texto}    Rodape do grid nao retornou texto para contagem.
    Log    [UAUXT-GRID] Texto completo do rodape: ${rodape_texto}    console=True
    ${trecho_selecionado}=    Evaluate
    ...    (lambda t: t.split('Selecionado:', 1)[1].split('Total:', 1)[0] if ('Selecionado:' in t and 'Total:' in t) else '')(str($rodape_texto))
    Should Not Be Empty
    ...    ${trecho_selecionado}
    ...    Formato do rodape inesperado. Esperado trecho entre 'Selecionado:' e 'Total:'. Texto: '${rodape_texto}'
    ${digitos}=    Evaluate    ''.join(ch for ch in str($trecho_selecionado) if ch.isdigit())
    Should Not Be Empty    ${digitos}    Nao foi possivel extrair numero do trecho Selecionado: '${trecho_selecionado}'
    ${qtd}=    Convert To Integer    ${digitos}
    Should Be True    int($qtd) >= int($min_registros)    Quantidade invalida no rodape: '${rodape_texto}'
    Log    [UAUXT-GRID] Quantidade de registros no rodape: ${qtd} (texto='${rodape_texto}')    console=True
    RETURN    ${qtd}

Contabilizar Processos No Grid Contas A Pagar
    [Documentation]    Conta processos no grid usando o mesmo acesso Win32/probe aplicado no fluxo DVQ.
    [Arguments]    ${min_registros}=1
    ${grid}=    Registrar Grid UauXT Por Win32
    ...    ${UAUXT_GRID_PROCESSOS_PAGAMENTO_TARGET_TEXT}
    ...    ${UAUXT_GRID_PREFERRED_INDEX}
    ${handle}=    Get From Dictionary    ${grid}    handle
    Log    [UAUXT-GRID] Grid de processos localizado para contagem. handle=${handle}    console=True
    ${qtd}=    Obter Quantidade Registros Do Grid Pelo Rodape
    ...    ${handle}
    ...    ${UAUXT_GRID_CONTAS_PAGAR_RODAPE}
    ...    ${UAUXT_GRID_COUNT_REGEX}
    ...    ${min_registros}
    RETURN    ${qtd}
