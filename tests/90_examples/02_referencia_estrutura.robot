*** Settings ***
Documentation       Exemplo de referencia de organizacao por camadas.
Resource            ../../resources/data/compilador_data.resource
Resource            ../../resources/data/uauxt_data.resource
Test Tags           examples    arquitetura

*** Test Cases ***
Exemplo Uso Variaveis Centralizadas
    [Documentation]    Demonstra uso de variaveis de data sem hardcode no teste.
    Should Contain    ${COMPILADOR_EXE}    UAUCompilador.exe
    Should Contain    ${UAUXT_EXE}    UauXT.exe
    Should Match Regexp    ${COMPILADOR_TIMEOUT_PADRAO}    ^\\d+s$
