*** Settings ***
Documentation       Dados de descoberta e leitura do grid UauXT por Win32.
...                 Centraliza tokens, timeouts e parametros de probe.


*** Variables ***
${UAUXT_GRID_PROBE_SCRIPT}                resources/scripts/uauxt_probe.py
${UAUXT_GRID_TARGET_TEXT}                 Contas a Pagar
${UAUXT_GRID_PROCESSOS_PAGAMENTO_TARGET_TEXT}    Processos de pagamento
${UAUXT_GRID_WINDOW_TITLE_REGEX}          UAUXT
${UAUXT_GRID_CLASS_TOKENS_CSV}            TG80,C1Grid,GridOleDB,grid
${UAUXT_GRID_PREFERRED_INDEX}             0
${UAUXT_GRID_MAX_ROWS_PREVIEW}            40
${UAUXT_GRID_NAV_ROW_STEPS}               0
${UAUXT_GRID_NAV_COL_STEPS}               0
${UAUXT_GRID_NAV_ROW_DIRECTION}           down
${UAUXT_GRID_NAV_COL_DIRECTION}           right
${UAUXT_GRID_COUNT_REGEX}                 (\d+)
${UAUXT_GRID_CONTAS_PAGAR_CAPTION}        id:ucContainer > id:1 > type:HeaderControl
${UAUXT_GRID_CONTAS_PAGAR_RODAPE}         id:statusBar
${UAUXT_GRID_TIMEOUT_PROBE}               90s
${UAUXT_GRID_HANDLE}                      ${EMPTY}
${UAUXT_GRID_LEFT}                        ${EMPTY}
${UAUXT_GRID_TOP}                         ${EMPTY}
${UAUXT_GRID_RIGHT}                       ${EMPTY}
${UAUXT_GRID_BOTTOM}                      ${EMPTY}
${UAUXT_GRID_BATCH_MOVE_DELAY_MS}         300
${UAUXT_GRID_BATCH_TYPE_DELAY_MS}         250
${UAUXT_GRID_BATCH_COMMIT_DELAY_MS}       350
