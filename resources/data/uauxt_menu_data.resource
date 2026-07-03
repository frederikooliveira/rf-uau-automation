*** Settings ***
Documentation       Configuracoes de menus e navegação do UauXT.
...                 Centraliza locators e caminhos de menus para reutilização.

*** Variables ***
# === MENU LATERAL ANGULAR (WEBVIEW2 + LEGADO) ===
${UAUXT_MENU_LATERAL_HOST}        id:MenuXt and type:PaneControl
${UAUXT_MENU_LATERAL_BROWSER}     id:wbBrowser and type:PaneControl
${UAUXT_MENU_FINANCEIRO_INDICE}   5

# === SUBMENUS E TELAS ===
${UAUXT_SUBMENU_FINANCEIRO_TEXTO}    Financeiro
${UAUXT_SUBMENU_GESTAO_FINANCEIRA_TEXTO}    Gestão Financeira
${UAUXT_SUBMENU_CONTAS_A_PAGAR_TEXTO}    Contas a Pagar
${UAUXT_SUBMENU_EMISSAO_PAGAMENTOS_TEXTO}    Emissão de Pagamentos
${UAUXT_SUBMENU_SEGURANCA_TEXTO}    Segurança
${UAUXT_SUBMENU_GESTAO_SEGURANCA_TEXTO}    Gestão de Segurança
${UAUXT_SUBMENU_USUARIOS_TEXTO}    Usuários
${UAUXT_SUBMENU_GRUPO_USUARIOS_TEXTO}    Grupos de Usuários
${UAUXT_SUBMENU_VENDAS_TEXTO}    Vendas
${UAUXT_SUBMENU_GESTAO_VENDAS_TEXTO}    Gestão de Vendas
${UAUXT_SUBMENU_RESUMO_VENDA_TEXTO}    Resumo de venda

# === CONTROLES DA TELA DE APROVAÇÃO ===
${UAUXT_GRID_PAGAMENTOS}           id:ucContainer > id:1
${UAUXT_BOTAO_APROVAR}            name:Aprovar
${UAUXT_BOTAO_REJEITAR}           name:Rejeitar
${UAUXT_BOTAO_FILTRO}             name:Filtro
${UAUXT_CAMPO_FILTRO_STATUS}      name:Status
${UAUXT_VALOR_FILTRO_PENDENTE}    Pendente

# === TIMEOUTS PARA NAVEGAÇÃO ===
${UAUXT_TIMEOUT_MENU}             20s
${UAUXT_TIMEOUT_TELA}             30s
${UAUXT_TIMEOUT_GRID}             20s
