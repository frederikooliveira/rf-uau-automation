*** Settings ***
Documentation       Etapa 2 - Compilar componentes: Abre o UAUCompilador.exe apos baixar versao,
...                 configura opcoes e inicia compilacao dos componentes.
Resource            ../../resources/apps/compilador.resource
Test Tags           setup    compilador

*** Test Cases ***
Abrir UAU Compilador
    Abrir UAU Compilador
    Configurar Opcoes Compilador

Aguardar Compilacao
    [Documentation]    Aguarda o resultado da compilacao ja iniciada.
    Aguardar Compilacao
