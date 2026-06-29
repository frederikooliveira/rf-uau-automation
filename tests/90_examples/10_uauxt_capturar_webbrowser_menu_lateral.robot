*** Settings ***
Documentation       Validacao simples de navegacao no menu lateral (WebView2) com baixo volume de logs.
Resource            ../../resources/domains/vendas.resource
Test Tags           examples    uauxt    diagnostico    menu-lateral    navegacao

*** Variables ***
${MENU_TIMEOUT_TESTE}                ${UAUXT_TIMEOUT_MENU}

*** Test Cases ***
Validar Navegacao Simples No Menu Lateral
    [Documentation]    Requer UauXT aberto/logado. Exemplo simples para acessar a tela Resumo de venda.
    Log    [EXEMPLO] Iniciando navegacao simples no menu lateral...    console=True
    Navegar Para Resumo De Venda    ${MENU_TIMEOUT_TESTE}
    Log    [EXEMPLO] Navegacao simples concluida com sucesso.    console=True
