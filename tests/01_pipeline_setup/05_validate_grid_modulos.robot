*** Settings ***
Documentation       Teste para validar o grid de modulos apos compilacao.
...                 Responsabilidade: validacao pos-compilacao do UAU Compilador.
Resource            ../../resources/apps/compilador.resource

*** Test Cases ***
Validar Grid Modulos
    [Documentation]    Valida o grid de modulos no UAU Compilador.
    Log    [TEST] Iniciando validacao do grid de modulos...    console=True
    Validar Grid Modulos
    Log    [TEST] Validacao do grid concluida.    console=True