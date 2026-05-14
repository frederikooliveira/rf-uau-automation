# Guia de Exemplos Reutilizaveis para QA

Este guia concentra exemplos prontos para reutilizacao.
A execucao dos exemplos foi agrupada em [tests/90_examples](../tests/90_examples).

## Objetivo

- Mostrar como usar resources existentes sem duplicar keyword
- Reforcar padrao de camadas (core, apps, domains, data)
- Facilitar onboarding de novos QAs

## Como executar os exemplos

Opcao 1: comando dedicado no runner
- .\robot-runner.ps1 examples

Opcao 2: por tag
- .\robot-runner.ps1 tag examples

## Padrao 1: Teste tecnico usando APPS

Quando usar:
- Validar comportamento tecnico de interface de um sistema especifico

Estrutura recomendada:

```robot
*** Settings ***
Resource    ../../resources/apps/compilador.resource
Test Tags   setup    compilador

*** Test Cases ***
Fluxo Tecnico Compilador
    Abrir UAU Compilador
    Configurar Opcoes Compilador
    Aguardar Compilacao
```

## Padrao 2: Teste funcional usando DOMAINS

Quando usar:
- Validar regra de negocio

Estrutura recomendada:

```robot
*** Settings ***
Resource    ../../resources/apps/uauxt.resource
Resource    ../../resources/domains/pessoas.resource
Test Tags   pessoas    funcional

Suite Setup    Abrir E Logar No UauXT

*** Test Cases ***
Cadastrar Pessoa Padrao
    Cadastrar Pessoa Basica    padrao
```

## Padrao 3: Reuso de dados centralizados

Quando usar:
- Evitar hardcode em teste

Estrutura recomendada:

```robot
*** Test Cases ***
Reusar Massa Centralizada
    ${pessoa}=    Obter Dados Pessoa    alternativa
    ${texto}=     Montar Texto Pessoa    ${pessoa}
    Should Contain    ${texto}    Nome:
```

## Padrao 4: Sincronizacao sem Sleep arbitrario

Quando usar:
- Fluxos sujeitos a variacao de tempo de UI

Estrutura recomendada:

```robot
*** Keywords ***
Aguardar E Clicar
    [Arguments]    ${locator}    ${descricao}
    Aguardar Elemento Com Log    ${locator}    ${descricao}
    Clicar Elemento Quando Disponivel    ${locator}
```

## Checklist rapido antes do PR

- Keyword no resource correto da camada
- Locator em data, nao no teste
- Sem automacao por imagem
- Sem Sleep arbitrario
- Logs com prefixo padrao
