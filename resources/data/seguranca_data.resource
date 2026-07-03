*** Settings ***
Documentation       Dados e locators para o módulo Segurança do UauXT.
...                 Responsabilidade: centralizar variáveis e locators de navegação e tela de usuários.


*** Variables ***
# --- Tela: Usuários ---
${SEGURANCA_USUARIOS_TELA_LOCATOR}         id:MainView and type:WindowControl
${SEGURANCA_USUARIOS_GRID_LOCATOR}         class:TG80.C1GridOleDB32.20
${SEGURANCA_USUARIOS_SSTAB_LOCATOR}        class:SSTabCtlWndClass
${SEGURANCA_USUARIOS_TOOLBAR_CLASS}        msvb_lib_toolbar
${SEGURANCA_USUARIOS_TOOLBAR_IDX}          0

# --- Tela: Grupo de Usuários ---
${SEGURANCA_GRP_USUARIOS_TELA_LOCATOR}         TODO_CONFIGURAR_SEGURANCA_GRP_USUARIOS_TELA
${SEGURANCA_GRP_USUARIOS_GRID_LOCATOR}         TODO_CONFIGURAR_SEGURANCA_GRP_USUARIOS_GRID
${SEGURANCA_GRP_BTN_INSERIR_LOCATOR}          automation_id:5
${SEGURANCA_GRP_BTN_CP_LOCATOR}               automation_id:4

# --- Locators pendentes compartilhados ---
${SEGURANCA_BTN_NOVO_LOCATOR}             TODO_CONFIGURAR_SEGURANCA_BTN_NOVO
${SEGURANCA_BTN_EDITAR_LOCATOR}           TODO_CONFIGURAR_SEGURANCA_BTN_EDITAR
${SEGURANCA_BTN_EXCLUIR_LOCATOR}          TODO_CONFIGURAR_SEGURANCA_BTN_EXCLUIR
${SEGURANCA_COLUNAS_GRID_LOCATOR}         TODO_CONFIGURAR_SEGURANCA_COLUNAS_GRID
