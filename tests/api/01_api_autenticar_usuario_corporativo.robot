*** Settings ***
Documentation       Valida autenticacao corporativa via endpoint oficial da API.
Resource            ../../resources/apps/api_client.resource
Test Tags           api    funcional-api    autenticacao    comportamento-unico


*** Variables ***
${STATUS_ESPERADO}          200


*** Test Cases ***
Autenticar Usuario Corporativo Na Api
    [Documentation]    Executa autenticacao corporativa e valida retorno HTTP esperado.
    Log    [API] Iniciando autenticacao corporativa...    console=True
    Validar Configuracao Base Da Api
    Criar Sessao Api Padrao
    ${response}=    Autenticar Usuario Corporativo
    Validar Status Http    ${response}    ${STATUS_ESPERADO}
    Log    [API] Autenticacao corporativa validada com sucesso.    console=True
