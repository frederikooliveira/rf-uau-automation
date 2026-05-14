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

Ler Preview De Linhas Do Grid Por Handle
    [Documentation]    Le linhas do grid por handle usando Ctrl+A/Ctrl+C e clipboard.
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
