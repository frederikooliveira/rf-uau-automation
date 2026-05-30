*** Settings ***
Documentation       Configuracoes de menus e navegação do UauXT.
...                 Centraliza locators e caminhos de menus para reutilização.

*** Variables ***
# === MENUS PRINCIPAIS ===
${UAUXT_MENU_FINANCEIRO}           name:Financeiro
${UAUXT_MENU_COMPRAS}              name:Compras
${UAUXT_MENU_VENDAS}               name:Vendas
${UAUXT_MENU_ESTOQUE}              name:Estoque

# === SUBMENUS FINANCEIRO ===
${UAUXT_SUBMENU_CONTAS_PAGAR}      name:Contas a Pagar
${UAUXT_SUBMENU_CONTAS_RECEBER}    name:Contas a Receber
${UAUXT_SUBMENU_APROVACAO}         name:Aprovação de Pagamentos

# === TELAS/CONTEUDOS ===
${UAUXT_TELA_APROVACAO_PAGAMENTOS}    name:Aprovação de Pagamentos
${UAUXT_GRID_PAGAMENTOS}           id:ucContainer > id:1

# === CONTROLES DA TELA DE APROVAÇÃO ===
${UAUXT_BOTAO_APROVAR}            name:Aprovar
${UAUXT_BOTAO_REJEITAR}           name:Rejeitar
${UAUXT_BOTAO_FILTRO}             name:Filtro
${UAUXT_CAMPO_FILTRO_STATUS}      name:Status
${UAUXT_VALOR_FILTRO_PENDENTE}    Pendente

# === NAVEGAÇÃO ===
${UAUXT_BARRA_MENUS}              id:MenuBar
${UAUXT_AREA_TRABALHO}            id:WorkArea

# === MENU LATERAL ANGULAR (CEFSHARP) ===
${UAUXT_MENU_LATERAL_HOST}        id:MenuXt and type:PaneControl
${UAUXT_MENU_LATERAL_BROWSER}     id:wbBrowser and type:PaneControl
${UAUXT_MENU_LATERAL_DOCUMENTO}   id:MenuXt > id:wbBrowser > type:DocumentControl and name:ErpxtApp
# Indice 6, caso tenha o senior X vinculado. Senão é o 5.
${UAUXT_MENU_FINANCEIRO_INDICE}   5 
${UAUXT_MENU_ICONE_CAPACETE_GLYPH}    
${UAUXT_MENU_ICONE_CAPACETE_LOCATOR}    ${UAUXT_MENU_LATERAL_DOCUMENTO} > path:1|7|1|1
@{UAUXT_MENU_ICONES_FINANCEIRO_CANDIDATOS}
...    ${UAUXT_MENU_LATERAL_DOCUMENTO} > path:1|7|1|1
...    ${UAUXT_MENU_ICONE_CAPACETE_LOCATOR}
${UAUXT_MENU_ICONE_CAPACETE_TOP_MIN}    330
${UAUXT_MENU_ICONE_CAPACETE_TOP_MAX}    390

# Alias legado (compatibilidade)
${UAUXT_MENU_ICONE_MALETA_GLYPH}    ${UAUXT_MENU_ICONE_CAPACETE_GLYPH}
${UAUXT_MENU_ICONE_MALETA_TOP_MIN}    ${UAUXT_MENU_ICONE_CAPACETE_TOP_MIN}
${UAUXT_MENU_ICONE_MALETA_TOP_MAX}    ${UAUXT_MENU_ICONE_CAPACETE_TOP_MAX}

# Submenus abertos a partir do icone de Financeiro
${UAUXT_SUBMENU_FINANCEIRO_TEXTO}    Financeiro
${UAUXT_SUBMENU_GESTAO_FINANCEIRA_TEXTO}    Financeira
${UAUXT_SUBMENU_CONTAS_A_PAGAR_TEXTO}    Contas a Pagar
${UAUXT_SUBMENU_APROVACAO_PAGAMENTOS_TEXTO}    Aprovação de Pagamentos
@{UAUXT_CAMINHO_MENU_APROVACAO_PAGAMENTOS}    Financeiro    Contas a Pagar    Aprovação de Pagamentos
${UAUXT_MENU_ITEM_FINANCEIRO_LOCATOR}    ${UAUXT_MENU_LATERAL_DOCUMENTO} > path:1|8|1|1
${UAUXT_MENU_ITEM_GESTAO_FINANCEIRA_LOCATOR}    ${UAUXT_MENU_LATERAL_DOCUMENTO} > path:1|7|1|1
${UAUXT_MENU_ITEM_CONTAS_A_PAGAR_LOCATOR}    ${UAUXT_MENU_LATERAL_DOCUMENTO} > path:1|6|1|1|1

${UAUXT_TELA_CONTAS_A_PAGAR}    name:Contas a Pagar

# === TIMEouts PARA NAVEGAÇÃO ===
${UAUXT_TIMEOUT_MENU}             5s
${UAUXT_TIMEOUT_TELA}             30s
${UAUXT_TIMEOUT_GRID}             20s
