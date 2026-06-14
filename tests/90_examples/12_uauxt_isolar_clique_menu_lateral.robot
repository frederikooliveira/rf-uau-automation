*** Settings ***
Documentation       Isolamento do clique por indice no menu lateral do UauXT para diagnostico.
Resource            ../../resources/apps/uauxt.resource
Test Tags           examples    uauxt    diagnostico    menu-indice

*** Variables ***
${INDICE_ICONE_TESTE}    ${UAUXT_MENU_FINANCEIRO_INDICE}
${GLYPH_ICONE_TESTE}     ${UAUXT_MENU_ICONE_CAPACETE_GLYPH}
${SUBMENU_TESTE}         ${UAUXT_SUBMENU_FINANCEIRO_TEXTO}

*** Test Cases ***
Isolar Clique Por Indice No Menu Lateral
    [Documentation]    Requer UauXT aberto/logado. Testa apenas foco + clique por indice no menu lateral.
    Log    [DIAG-INDICE] Iniciando isolamento do clique por indice ${INDICE_ICONE_TESTE}.    console=True
    Focar No Menu Lateral Angular UauXT
    Selecionar Icone Menu Lateral Por Indice    ${INDICE_ICONE_TESTE}
    Pausa Controlada    1s    Aguardando efeito visual do clique por indice
    Log    [DIAG-INDICE] Clique por indice executado.    console=True

Isolar Clique Por Indice Com Captura Da Arvore
    [Documentation]    Requer UauXT aberto/logado. Captura arvore antes/depois para conferir se houve mudanca no menu.
    Log    [DIAG-INDICE] Captura antes do clique por indice.    console=True
    Capturar E Imprimir WebBrowser Menu Lateral
    Selecionar Icone Menu Lateral Por Indice    ${INDICE_ICONE_TESTE}
    Pausa Controlada    1s    Aguardando efeito visual do clique por indice
    Log    [DIAG-INDICE] Captura apos clique por indice.    console=True
    Capturar E Imprimir WebBrowser Menu Lateral

Isolar Navegacao Por Glyph Do Icone
    [Documentation]    Requer UauXT aberto/logado. Testa navegacao pelo glyph do icone lateral.
    Log    [DIAG-GLYPH] Iniciando isolamento por glyph '${GLYPH_ICONE_TESTE}'.    console=True
    Selecionar Icone Menu Lateral Por Glyph    ${GLYPH_ICONE_TESTE}
    Pausa Controlada    1s    Aguardando efeito visual do clique por glyph
    Log    [DIAG-GLYPH] Clique por glyph executado.    console=True

Isolar Navegacao Por Texto De Menu
    [Documentation]    Requer UauXT aberto/logado. Abre icone e seleciona submenu por texto.
    Log    [DIAG-TEXTO] Abrindo menu por indice e navegando por texto '${SUBMENU_TESTE}'.    console=True
    Selecionar Icone Menu Lateral Por Indice    ${INDICE_ICONE_TESTE}
    Selecionar Menu Lateral Por Texto    ${SUBMENU_TESTE}
    Pausa Controlada    1s    Aguardando efeito visual da navegacao por texto
    Log    [DIAG-TEXTO] Navegacao por texto executada.    console=True
