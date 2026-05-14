*** Settings ***
Documentation       Etapa 4 - Mover arquivos: Configura o local de saida dos arquivos compilados
...                 para C:/UAU/UAU 10.06/Modulos.
Resource            ../../resources/apps/compilador.resource
Test Tags           setup    mover-arquivos

*** Test Cases ***
Configurar Local Saida Arquivos
    Configurar Local Saida Arquivos