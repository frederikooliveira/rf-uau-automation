*** Settings ***
Documentation       Dados e locators para o módulo de Vendas do UauXT.
...                 Responsabilidade: centralizar variáveis, locators e dados de teste.


*** Variables ***
# --- Janela / Caminho de Acesso ---
${VENDAS_MENU_ITEM_LOCATOR}                 name:Vendas
${VENDAS_GESTAO_VENDAS_LOCATOR}             name:Gestão de Vendas
${VENDAS_RESUMO_VENDA_LOCATOR}              name:Resumo de venda

# --- Handles Win32 (descobertos em runtime — usar Find em vez de fixar handle) ---
# Toolbar principal (msvb_lib_toolbar) rect aprox: [1988, 96, 3837, 142]
# Toolbar lateral (msvb_lib_toolbar)  rect aprox: [1987, 192, 2047, 246]
# Grid principal  (TG80.C1GridOleDB32.20) rect aprox: [2049, 194, 3828, 592]
# Grid SSTab      (TG80.C1GridOleDB32.20) rect aprox: [2051, 626, 3823, 994]
# SSTabCtlWndClass rect aprox: [2049, 600, 3828, 998]

# --- Toolbar Resumo de Venda — Índices (0-based) ---
${VENDAS_RESUMO_TB_NOVO_INDEX}              0     # "Novo"
${VENDAS_RESUMO_TB_DATA_CALC_INDEX}         1     # "Data calc."
${VENDAS_RESUMO_TB_RESUMO_INDEX}            2     # "Resumo"      fsStyle=sep
${VENDAS_RESUMO_TB_EXTRATO_INDEX}           3     # "Extrato"     fsStyle=sep
${VENDAS_RESUMO_TB_IMP_PAR_INDEX}           4     # "Imp. par."
${VENDAS_RESUMO_TB_CUSTAS_INDEX}            5     # "Custas"
${VENDAS_RESUMO_TB_IMPOSTO_INDEX}           6     # "Imposto"
${VENDAS_RESUMO_TB_ALUGUEL_INDEX}           7     # "Aluguel"     fsStyle=sep
${VENDAS_RESUMO_TB_RESCISAO_INDEX}          8     # "Rescisão"
${VENDAS_RESUMO_TB_PROMISSORIA_INDEX}       9     # "Promis."
${VENDAS_RESUMO_TB_DEM_COR_INDEX}           10    # "Dem. cor."
${VENDAS_RESUMO_TB_RECIBO_INDEX}            11    # "Recibo"      fsState=0 (desabilitado)
${VENDAS_RESUMO_TB_EXT_PROD_INDEX}          12    # "Ext. prod."  fsState=0 (desabilitado)
${VENDAS_RESUMO_TB_ESPELHO_INDEX}           13    # "Espelho"     fsStyle=sep; fsState=0
${VENDAS_RESUMO_TB_ESTOQUE_INDEX}           14    # "Estoque"
${VENDAS_RESUMO_TB_REC_AVUL_INDEX}          15    # "Rec. avul."
${VENDAS_RESUMO_TB_SIGN_INDEX}              16    # "Sign"        fsStyle=sep

# --- Botões fora da toolbar (ThunderRT6CommandButton) ---
${VENDAS_RESUMO_BTN_GRAVAR_LOCATOR}         name:&Gravar
${VENDAS_RESUMO_BTN_SAIR_LOCATOR}           name:&Sair
${VENDAS_RESUMO_BTN_BUSCAR_LOCATOR}         id:ucContainer > id:45 and type:ButtonControl
${VENDAS_RESUMO_BTN_CONTROLE_OBRAS_LOCATOR}    id:ucContainer > id:btnEmpresaObra and type:ButtonControl
${VENDAS_RESUMO_TELA_LOCATOR}               id:MainView and type:WindowControl

# --- Popup Empresa/Obra ---
${VENDAS_POPUP_EMPRESA_OBRA_LOCATOR}        id:frmSelecaoEmpresaObra
${VENDAS_POPUP_GRID_EMPRESA_HEADER_LOCATOR}    id:gridEmpresaObra > name:Empresa and type:HeaderControl
${VENDAS_POPUP_SELECIONAR_TODAS_LOCATOR}    name:Selecionar todas
${VENDAS_POPUP_SELEC_TODAS_ALT_LOC}    name:Selecionar Todas
${VENDAS_POPUP_SELEC_TODAS_AMP_LOC}    name:&Selecionar todas

# --- Filtros de tipo de comprador (OptionButton) ---
${VENDAS_RESUMO_FILTRO_TODOS_LOCATOR}       name:Todos
${VENDAS_RESUMO_FILTRO_TITULAR_LOCATOR}     name:Titular
${VENDAS_RESUMO_FILTRO_NAO_TITULAR_LOCATOR}    name:Não titular
${VENDAS_RESUMO_FILTRO_AVALISTA_LOCATOR}    name:Avalista
${VENDAS_RESUMO_FILTRO_PROPRIETARIO_LOC}   name:Proprietário

# --- CheckBoxes de filtro ---
${VENDAS_RESUMO_CHK_POR_TITULAR_LOCATOR}    name:Por titular
${VENDAS_RESUMO_CHK_ANTECIPACAO_LOCATOR}    name:Antecipação

# --- Classe da toolbar de ações ---
${VENDAS_RESUMO_TOOLBAR_CLASS}              msvb_lib_toolbar

# --- Timeouts ---
${VENDAS_TIMEOUT_PADRAO}                    20s
${VENDAS_TIMEOUT_BUSCA}                     30s
${VENDAS_RESUMO_TEMPO_MAX_ABERTURA_MS}      15000

# --- Delays ---
${VENDAS_DELAY_APOS_BUSCA_MS}               800ms
${VENDAS_DELAY_APOS_TOOLBAR_MS}             500ms

# --- Grid principal (Resumo de Venda) ---
${VENDAS_RESUMO_GRID_TARGET_TEXT}           Resumo de venda
${VENDAS_RESUMO_GRID_INDEX}                 0
${VENDAS_RESUMO_GRID_MIN_REGISTROS}         1
${VENDAS_RESUMO_GRID_MAX_ROWS_PREVIEW}      30
${VENDAS_TIMEOUT_CARREGAMENTO_GRID}         45s
${VENDAS_RESUMO_MAX_CARREG_GRID_MS}    15000

# --- Popup Relatorio demonstrativo de pagamentos ---
${VENDAS_REL_DEMONSTRATIVO_JANELA_LOCATOR}    class:ThunderRT6FormDC and subname:demonstrativo and type:WindowControl
${VENDAS_REL_DEMONSTRATIVO_TOOLBAR_CLASS}     msvb_lib_toolbar
${VENDAS_REL_DEMONSTRATIVO_GRID_CLASS}        TG80.C1GridOleDB32.20
${VENDAS_REL_DEMONSTRATIVO_TIMEOUT_PADRAO}    20s

# --- Toolbar popup (mapeamento parcial) ---
${VENDAS_RELDEM_TB_IDX_ESQ_CAND}    0
${VENDAS_RELDEM_TB_IDX_DIR_CAND}    2
${VENDAS_RELDEM_TB_BTN_ESQ_IDX}     TODO_CONFIGURAR_VENDAS_RELDEM_TB_BTN_ESQ_IDX
${VENDAS_RELDEM_TB_BTN_DIR_IDX}     TODO_CONFIGURAR_VENDAS_RELDEM_TB_BTN_DIR_IDX

# --- Grid popup (pendente de ancoragem semantica/colunas) ---
${VENDAS_RELDEM_GRID_TARGET_TEXT}    TODO_CONFIGURAR_VENDAS_RELDEM_GRID_TARGET_TEXT
${VENDAS_RELDEM_COL_CRIT_1}          TODO_CONFIGURAR_VENDAS_RELDEM_COL_CRIT_1
