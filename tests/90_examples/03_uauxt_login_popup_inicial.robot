*** Settings ***
Documentation       Exemplo de login no UauXT com popup inicial.
Resource            ../../resources/apps/uauxt.resource
Test Tags           examples    uauxt

*** Test Cases ***
Exemplo Login UauXT Com Popup Inicial
    [Documentation]    Abre o executavel UauXT, confirma o popup inicial, preenche usuario e senha e autentica.
    Abrir E Logar No UauXT
