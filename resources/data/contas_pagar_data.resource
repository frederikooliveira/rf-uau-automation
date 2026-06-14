*** Settings ***
Documentation       Dados e locators para o dominio Contas a Pagar.
...                 Responsabilidade: centralizar variaveis, locators e constantes.


*** Variables ***
# --- Colunas do grid Processos de pagamento (0-based) ---
${CONTAS_PAGAR_COLUNA_CONFIRMADO}             5
${CONTAS_PAGAR_COLUNA_BANCO}                  15
${CONTAS_PAGAR_COLUNA_CONTA}                  16

# --- Locators do popup de selecao de empresa/obra ---
${CONTAS_PAGAR_POPUP_EMPRESA_LOCATOR}         id:frmSelecaoEmpresaObra
${CONTAS_PAGAR_GRID_EMPRESA_HEADER_LOCATOR}   id:gridEmpresaObra > name:Empresa and type:HeaderControl
${CONTAS_PAGAR_BOTAO_EMPRESA_OBRA_LOCATOR}    id:ucContainer > path:1|1|1|2|1

# --- Locators dos campos de periodo ---
${CONTAS_PAGAR_CAMPO_DATA_INICIAL_LOCATOR}    id:ucContainer > id:mskDataInicial
${CONTAS_PAGAR_CAMPO_DATA_FINAL_LOCATOR}      id:ucContainer > id:mskDataFinal
${CONTAS_PAGAR_BOTAO_BUSCAR_LOCATOR}          id:ucContainer > id:23

# --- Timeouts e delays ---
${CONTAS_PAGAR_TIMEOUT_PADRAO}                15s
${CONTAS_PAGAR_DATA_INICIAL_PADRAO}           01/01/2022

# --- Toolbar de ações (msvb_lib_toolbar, toolbar_index=0 — horizontal) ---
# NOTA: msvb_lib_toolbar (VB6) nao expoe textos via UIA/MSAA/TB_GETBUTTONTEXTW.
# Indices mapeados via hover+tooltip em 30/05/2026 (probe map-toolbar-buttons, 13/15 com nome):
#
#   [0]  → Novo  (desabilitado nesta tela)
#   [1]  → SEPARADOR
#   [2]  → Confirmar parcela e enviá-la para emissões
#   [3]  → Manutenção  (tooltip: "Reparcelamento de parcelas")
#   [4]  → Vínculo PL  (tooltip: "Visualizar os respectivos vínculos com planejamento") ← confirmado (test 16)
#   [5]  → Protocolo   (tooltip: "Número do malote de envio de documentos para o cliente")
#   [6]  → (dropdown do Protocolo — mesmo rect/tooltip que [5])
#   [7]  → Filtrar processos por nota fiscal
#   [8]  → Imprimir Solicitação de pagamento
#   [9]  → (dropdown do Imprimir — sidebutton à direita de [8])
#          abre menu com opção "Nota de débito"
#   [10] → Gerar notas para processos com a chave de NFe vinculada
#   [11] → Devolução
#   [12] → SEPARADOR
#   [13] → Chaves Pix  (tooltip: "Manutenção de chaves pix")
#   [14] → Filtrar Processos
#   [15] → Exibe os históricos de alteração da confirmação DVQ
#   [16] → SEPARADOR
#   [17] → Acompanhamento da assinatura digital
#   [18] → Acompanhamento de fluxo BPM
#
# Para re-mapear: .venv\Scripts\python.exe resources/scripts/uauxt_probe.py map-toolbar-buttons --toolbar-index 0 --pretty
${CONTAS_PAGAR_TLB_ACOES_LOCATOR}                   class:msvb_lib_toolbar
${CONTAS_PAGAR_TLB_NOVO_IDX}                      0
${CONTAS_PAGAR_TLB_CONFIRMAR_PARCELA_IDX}         2
${CONTAS_PAGAR_TLB_MANUTENCAO_IDX}                3
${CONTAS_PAGAR_TLB_VINCULO_PL_IDX}                4
${CONTAS_PAGAR_TLB_PROTOCOLO_IDX}                 5
${CONTAS_PAGAR_TLB_FILTRAR_NOTA_FISCAL_IDX}       7
${CONTAS_PAGAR_TLB_IMPRIMIR_SOLICITACAO_IDX}      8
${CONTAS_PAGAR_TLB_IMPRIMIR_DROPDOWN_IDX}         9
${CONTAS_PAGAR_TLB_GERAR_NFE_IDX}                 10
${CONTAS_PAGAR_TLB_DEVOLUCAO_IDX}                 11
${CONTAS_PAGAR_TLB_CHAVES_PIX_IDX}                13
${CONTAS_PAGAR_TLB_FILTRAR_PROCESSOS_IDX}         14
${CONTAS_PAGAR_TLB_HISTORICO_DVQ_IDX}             15
${CONTAS_PAGAR_TLB_ASSINATURA_DIGITAL_IDX}        17
${CONTAS_PAGAR_TLB_BPM_IDX}                       18

# --- Menu dropdown do botão Imprimir (navegacao por teclado — VB6 popup nao expoe UIA) ---
# Apos clicar o sidebutton (x_pct=0.85 no idx=8), enviar {DOWN} + {ENTER} para selecionar "Nota de debito".

# --- Toolbar de visões (msvb_lib_toolbar, toolbar_index=1 — vertical esquerda) ---
# Mapeado via hover+tooltip em 30/05/2026 (2/2 identificados):
#   [0]  → Processos de pagamento  (visão padrão)
#   [1]  → Análise do contas a pagar
#
# Para re-mapear: .venv\Scripts\python.exe resources/scripts/uauxt_probe.py map-toolbar-buttons --toolbar-index 1 --pretty
${CONTAS_PAGAR_TLB_VISOES_PROCESSOS_IDX}          0
${CONTAS_PAGAR_TLB_VISOES_ANALISE_IDX}            1
