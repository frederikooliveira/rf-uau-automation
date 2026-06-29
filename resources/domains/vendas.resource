*** Settings ***
Documentation       Fluxos de negocio do dominio de Vendas no UauXT.
...                 Responsabilidade: compor fluxos de negocio usando keywords tecnicas dos apps e dados compartilhados via imports indiretos.
Resource            ../apps/uauxt.resource
Resource            ../apps/uauxt_grid.resource
Resource            ../apps/uauxt_vendas.resource


*** Keywords ***
Validar Locator Configurado
    [Documentation]    Falha cedo quando um locator nao foi mapeado.
    [Arguments]    ${locator}    ${nome_locator}
    IF    '${locator}'.startswith('TODO_CONFIGURAR_')
        Fail    Locator nao configurado: ${nome_locator}. Atualize em resources/data/vendas_data.resource.
    END

Acessar Resumo De Venda Via Menu Lateral
    [Documentation]    Acessa Resumo de venda pelo caminho de negócio Vendas > Gestão de Vendas > Resumo de venda.
    [Arguments]    ${timeout}=${VENDAS_TIMEOUT_PADRAO}
    Log    [DOM-VENDAS] Acessando Resumo de Venda pelo menu lateral...    console=True
    ${status}=    Run Keyword And Return Status
    ...    Acessar Item Via Icone Capacete Obras
    ...    ${UAUXT_SUBMENU_VENDAS_TEXTO}
    ...    ${UAUXT_SUBMENU_GESTAO_VENDAS_TEXTO}
    ...    ${UAUXT_SUBMENU_RESUMO_VENDA_TEXTO}
    ...    ${timeout}
    IF    not ${status}
        Fail    Nao foi possivel acessar Resumo de Venda via menu lateral.
    END
    Log    [DOM-VENDAS] Resumo de Venda acessado.    console=True

Navegar Para Resumo De Venda
    [Documentation]    Navega via menu até a tela Resumo de venda (Vendas > Gestão de Vendas > Resumo de venda).
    [Arguments]    ${timeout}=${VENDAS_TIMEOUT_PADRAO}
    Log    [DOM-VENDAS] Navegando para Resumo de Venda...    console=True
    ${abriu_resumo}=    Run Keyword And Return Status
    ...    Acessar Resumo De Venda Via Menu Lateral
    ...    ${timeout}
    IF    not ${abriu_resumo}
        Log    [DOM-VENDAS] Fallback: abrindo Resumo de Venda pelo caminho de submenu via icone.    console=True
        Acessar Resumo De Venda Via Menu Lateral    ${timeout}
    END
    ${tempo_abertura_ms}=    Aguardar Tela Com Tempo De Abertura
    ...    ${VENDAS_RESUMO_TELA_LOCATOR}
    ...    tela Resumo de Venda
    ...    janela
    ...    ${timeout}
    ...    ${VENDAS_RESUMO_TEMPO_MAX_ABERTURA_MS}
    Log    [DOM-VENDAS] Tela Resumo de Venda aberta em ${tempo_abertura_ms} ms.    console=True

Buscar Vendas Com Filtro Todos
    [Documentation]    Seleciona filtro "Todos" e executa busca na tela Resumo de Venda.
    Log    [DOM-VENDAS] Buscando vendas com filtro Todos...    console=True
    Selecionar Filtro Tipo Comprador    ${VENDAS_RESUMO_FILTRO_TODOS_LOCATOR}
    Executar Busca Resumo Venda
    Log    [DOM-VENDAS] Busca concluida.    console=True

Selecionar Empresa E Obra
    [Documentation]    Abre o dialogo de selecao de empresa e obra na tela Resumo de Venda.
    [Arguments]    ${timeout}=${VENDAS_TIMEOUT_PADRAO}
    Validar Locator Configurado    ${VENDAS_RESUMO_BTN_CONTROLE_OBRAS_LOCATOR}    VENDAS_RESUMO_BTN_CONTROLE_OBRAS_LOCATOR
    Log    [DOM-VENDAS] Abrindo seletor de empresa e obra...    console=True
    Abrir Seletor Empresa E Obra
    ...    ${VENDAS_RESUMO_BTN_CONTROLE_OBRAS_LOCATOR}
    ...    ${VENDAS_POPUP_EMPRESA_OBRA_LOCATOR}
    ...    ${timeout}
    Log    [DOM-VENDAS] Dialogo de empresa/obra aberto.    console=True

Selecionar Empresa No Popup
    [Documentation]    No popup de selecao de obras, digita o codigo da empresa e aplica filtro.
    [Arguments]    ${valor_empresa}    ${timeout}=${VENDAS_TIMEOUT_PADRAO}
    Validar Locator Configurado    ${VENDAS_POPUP_EMPRESA_OBRA_LOCATOR}    VENDAS_POPUP_EMPRESA_OBRA_LOCATOR
    Validar Locator Configurado    ${VENDAS_POPUP_GRID_EMPRESA_HEADER_LOCATOR}    VENDAS_POPUP_GRID_EMPRESA_HEADER_LOCATOR
    Selecionar Empresa No Popup Empresa Obra
    ...    ${VENDAS_POPUP_EMPRESA_OBRA_LOCATOR}
    ...    ${VENDAS_POPUP_GRID_EMPRESA_HEADER_LOCATOR}
    ...    ${valor_empresa}
    ...    ${timeout}
    Log    [DOM-VENDAS] Empresa '${valor_empresa}' selecionada.    console=True

Buscar Vendas Por Empresa E Todas As Obras
    [Documentation]    Abre controle de obras, seleciona empresa, marca todas as obras e executa busca.
    [Arguments]    ${codigo_empresa}
    Validar Locator Configurado    ${VENDAS_RESUMO_BTN_CONTROLE_OBRAS_LOCATOR}    VENDAS_RESUMO_BTN_CONTROLE_OBRAS_LOCATOR
    Validar Locator Configurado    ${VENDAS_POPUP_EMPRESA_OBRA_LOCATOR}    VENDAS_POPUP_EMPRESA_OBRA_LOCATOR
    Validar Locator Configurado    ${VENDAS_POPUP_GRID_EMPRESA_HEADER_LOCATOR}    VENDAS_POPUP_GRID_EMPRESA_HEADER_LOCATOR
    Validar Locator Configurado    ${VENDAS_POPUP_SELECIONAR_TODAS_LOCATOR}    VENDAS_POPUP_SELECIONAR_TODAS_LOCATOR
    Log    [DOM-VENDAS] Configurando filtro de empresa/obras para busca no resumo de vendas...    console=True
    Selecionar Empresa E Obra
    Selecionar Empresa No Popup    ${codigo_empresa}
    Executar Busca Resumo Venda
    ${tempo_carregamento_grid_ms}=    Aguardar Grid Principal Resumo Venda Com Tempo De Carregamento
    ...    ${VENDAS_RESUMO_GRID_MIN_REGISTROS}
    Log    [DOM-VENDAS] Grid principal carregado em ${tempo_carregamento_grid_ms} ms apos a busca.    console=True
    Log    [DOM-VENDAS] Busca com empresa '${codigo_empresa}' e todas as obras concluida.    console=True

Imprimir Resumo Da Venda
    [Documentation]    Clica no botão "Resumo" da toolbar para imprimir o resumo da venda selecionada.
    Log    [DOM-VENDAS] Imprimindo resumo da venda...    console=True
    Clicar Botao Toolbar Por Indice Via Probe
    ...    ${VENDAS_RESUMO_TB_RESUMO_INDEX}
    ...    ${VENDAS_RESUMO_TOOLBAR_CLASS}
    Pausa Controlada    ${VENDAS_DELAY_APOS_TOOLBAR_MS}    Aguardando abertura da tela de impressao
    Log    [DOM-VENDAS] Acao Resumo acionada.    console=True

Imprimir Extrato Da Venda
    [Documentation]    Clica no botão "Extrato" da toolbar para imprimir o extrato da venda selecionada.
    Log    [DOM-VENDAS] Imprimindo extrato da venda...    console=True
    Clicar Botao Toolbar Por Indice Via Probe
    ...    ${VENDAS_RESUMO_TB_EXTRATO_INDEX}
    ...    ${VENDAS_RESUMO_TOOLBAR_CLASS}
    Pausa Controlada    ${VENDAS_DELAY_APOS_TOOLBAR_MS}    Aguardando abertura da tela de impressao
    Log    [DOM-VENDAS] Acao Extrato acionada.    console=True

Selecionar Linha E Imprimir Extrato
    [Documentation]    Seleciona uma linha do grid principal e aciona o botão Extrato da toolbar.
    [Arguments]    ${linha_alvo}=0
    Log    [DOM-VENDAS] Selecionando linha ${linha_alvo} no grid principal para emitir extrato...    console=True
    Selecionar Registros No Grid Principal Resumo Venda    ${linha_alvo}
    Imprimir Extrato Da Venda
    Log    [DOM-VENDAS] Extrato acionado para a linha ${linha_alvo}.    console=True

Abrir Relatorio Demonstrativo De Pagamentos
    [Documentation]    Abre o popup de Relatorio demonstrativo via Extrato e valida a janela alvo.
    [Arguments]    ${linha_alvo}=2
    Validar Locator Configurado
    ...    ${VENDAS_REL_DEMONSTRATIVO_JANELA_LOCATOR}
    ...    VENDAS_REL_DEMONSTRATIVO_JANELA_LOCATOR
    Log    [DOM-VENDAS] Abrindo popup de Relatorio demonstrativo de pagamentos...    console=True
    Selecionar Linha E Imprimir Extrato    ${linha_alvo}
    Aguardar Popup Relatorio Demonstrativo De Pagamentos
    Log    [DOM-VENDAS] Popup de Relatorio demonstrativo aberto com sucesso.    console=True

Abrir Nova Venda
    [Documentation]    Clica no botão "Novo" da toolbar para criar uma nova venda.
    Log    [DOM-VENDAS] Abrindo nova venda...    console=True
    Clicar Botao Toolbar Por Indice Via Probe
    ...    ${VENDAS_RESUMO_TB_NOVO_INDEX}
    ...    ${VENDAS_RESUMO_TOOLBAR_CLASS}
    Pausa Controlada    ${VENDAS_DELAY_APOS_TOOLBAR_MS}    Aguardando abertura da tela de nova venda
    Log    [DOM-VENDAS] Nova venda iniciada.    console=True
