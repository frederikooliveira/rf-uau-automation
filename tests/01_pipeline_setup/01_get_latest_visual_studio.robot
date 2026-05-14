*** Settings ***
Documentation       Etapa 1 - Baixar versao: Abre o Visual Studio, conecta ao TFS e executa Get Latest Version
...                 na pasta globaltec/UAU/10.06/Producao no Source Control Explorer.
Resource            ../../resources/apps/visual_studio.resource
Test Tags           setup    vs    tfs

*** Test Cases ***
Get Latest Version Producao
    [Documentation]    Verifica se o Visual Studio esta aberto (abre se necessario),
    ...                navega ate globaltec > UAU > 10.06 > Producao no Source Control Explorer
    ...                e executa Get Latest Version.
    Verificar Ou Abrir Visual Studio
    Abrir Source Control Explorer
    Get Latest Version Na Pasta Alvo
