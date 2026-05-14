*** Settings ***
Documentation       Exemplos de reuso de massa de dados do dominio pessoas.
Resource            ../../resources/domains/pessoas.resource
Test Tags           examples    dados

*** Test Cases ***
Exemplo Reuso Dados Pessoa Padrao
    [Documentation]    Obtem dados centralizados e valida campos essenciais.
    ${pessoa}=    Obter Dados Pessoa    padrao
    Should Be Equal As Strings    ${pessoa}[nome]    Joao Silva
    Should Match Regexp    ${pessoa}[cpf]    ^\\d{11}$

Exemplo Montar Texto Pessoa
    [Documentation]    Converte dicionario para texto padronizado para logs.
    ${pessoa}=    Obter Dados Pessoa    alternativa
    ${texto}=    Montar Texto Pessoa    ${pessoa}
    Should Contain    ${texto}    Nome:
    Should Contain    ${texto}    CPF:
    Should Contain    ${texto}    Email:
