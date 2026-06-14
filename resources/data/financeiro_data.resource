*** Settings ***
Documentation       Dados e locators para o contexto Financeiro (Emissao de pagamentos).
...                 Responsabilidade: centralizar variaveis, locators e dados de teste.


*** Variables ***
# --- Menu / Tela ---
@{FIN_EMI_MENU_CAMINHO}                Financeiro    Gestao Financeira    Emissao de pagamentos
${FIN_EMI_TARGET_TEXT}                 Emissao de pagamentos
${FIN_EMI_WINDOW_LOCATOR}              id:MainView and type:WindowControl

# --- Grid / Toolbar (Win32) ---
${FIN_EMI_TOOLBAR_CLASS}               msvb_lib_toolbar
${FIN_EMI_GRID_PRINCIPAL_INDEX}        0
${FIN_EMI_GRID_SECUNDARIO_INDEX}       1

# --- Timeouts / Delays ---
${FIN_EMI_TIMEOUT_PADRAO}              20s
${FIN_EMI_DELAY_CURTO_MS}              400ms
${FIN_EMI_TEMPO_MAX_ABERTURA_MS}       15000

# --- Locators confirmados ---
${FIN_EMI_JANELA_MAINVIEW_LOCATOR}     id:MainView and type:WindowControl

# --- Locators pendentes (placeholder de configuracao) ---
${FIN_EMI_BTN_FILTRAR_LOCATOR}         TODO_CONFIGURAR_FIN_EMI_BTN_FILTRAR
${FIN_EMI_SSTAB_LOCATOR}               TODO_CONFIGURAR_FIN_EMI_SSTAB
${FIN_EMI_GRID_COLS_MAIN}              TODO_CONFIGURAR_FIN_EMI_GRID_COLS_MAIN
${FIN_EMI_GRID_COLS_SEC}               TODO_CONFIGURAR_FIN_EMI_GRID_COLS_SEC
${FIN_EMI_TB_BOTOES_MAPEADOS}          TODO_CONFIGURAR_FIN_EMI_TB_BOTOES_MAPEADOS
