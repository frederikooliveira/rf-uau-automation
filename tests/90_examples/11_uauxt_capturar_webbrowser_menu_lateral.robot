*** Settings ***
Documentation       Captura diagnostica da arvore MenuXt/wbBrowser para mapear glyph e posicao de icones no menu lateral.
Resource            ../../resources/apps/uauxt.resource
Test Tags           examples    uauxt    diagnostico    menu-lateral

*** Test Cases ***
Capturar Arvore Do WebBrowser Lateral
    [Documentation]    Requer UauXT aberto/logado. Imprime arvore completa e candidatos de icones da coluna lateral.
    Capturar E Imprimir WebBrowser Menu Lateral
    Log    [EXEMPLO] Captura do webbrowser lateral concluida.    console=True
