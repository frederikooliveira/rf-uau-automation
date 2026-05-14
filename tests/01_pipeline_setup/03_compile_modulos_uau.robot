*** Settings ***
Documentation       Etapa 3 - Compilar modulos: Compila apenas os modulos UAU apos a compilacao geral.
Resource            ../../resources/apps/compilador.resource
Test Tags           setup    modulos

*** Test Cases ***
Compilar Modulos UAU
    Compilar Modulos UAU

Aguardar Compilacao Modulos
    [Documentation]    Aguarda o resultado da compilacao dos modulos ja iniciada.
    Aguardar Compilacao Modulos