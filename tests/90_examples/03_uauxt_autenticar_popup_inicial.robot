*** Settings ***
Documentation       Exemplo de login no UauXT com popup inicial.
Resource            ../../resources/apps/uauxt.resource
Test Tags           examples    uauxt

*** Test Cases ***
Autenticar No UauXT
    [Documentation]    Abre o executavel UauXT e autentica o usuario após confirmar o popup inicial.
    Abrir E Logar No UauXT
