---
description: "Cria um novo resource de domínio em resources/domains/ seguindo o padrão do projeto rf-uau-automation. Use quando precisar modelar um novo fluxo de negócio (ex.: obras, financeiro, aprovacao)."
name: "Novo Domain Resource"
argument-hint: "Ex.: obras, financeiro, aprovacao-nf"
agent: "agent"
---

Crie um novo arquivo `resources/domains/<dominio>.resource` seguindo o padrão do projeto `rf-uau-automation`.

## Informações necessárias

Se o usuário não informou, pergunte:
1. **Nome do domínio** (ex.: obras, financeiro, aprovacao_nf)
2. **Aplicação base** (geralmente `uauxt` — qual app o domínio usa?)
3. **Fluxos principais** (ex.: acessar menu, preencher formulário, gravar, validar)
4. **Locators já mapeados** ou usar `TODO_CONFIGURAR_`?

## Onde criar

- Resource: `resources/domains/<dominio>.resource`
- Dados: `resources/data/<dominio>_data.resource` (criar junto, se não existir)

## Template do domain resource

```robot
*** Settings ***
Documentation       Keywords de dominio de negocio para <Dominio>.
...                 Responsabilidade: fluxos de negocio (nao UI tecnica).
Library             String
Resource            ../apps/uauxt.resource
Resource            ../data/<dominio>_data.resource


*** Keywords ***
Validar Locator Configurado
    [Documentation]    Falha cedo quando um locator nao foi mapeado.
    [Arguments]    ${locator}    ${nome_locator}
    IF    '${locator}'.startswith('TODO_CONFIGURAR_')
        Fail    Locator nao configurado: ${nome_locator}. Atualize em resources/data/<dominio>_data.resource.
    END

Acessar Menu <Dominio>
    [Documentation]    Acessa o menu de <dominio> no UauXT apos login.
    Validar Locator Configurado    ${MENU_<DOMINIO>_LOCATOR}    MENU_<DOMINIO>_LOCATOR
    Log    [DOM-<DOMINIO>] Acessando menu de <dominio>...    console=True
    Clicar Elemento Quando Disponivel    ${MENU_<DOMINIO>_LOCATOR}
    Log    [DOM-<DOMINIO>] Menu de <dominio> acessado.    console=True
```

## Template do data resource

```robot
*** Settings ***
Documentation       Dados e locators para o dominio <Dominio>.
...                 Responsabilidade: centralizar variaveis, locators e dados de teste.


*** Variables ***
# --- Locators de menu ---
${MENU_<DOMINIO>_LOCATOR}             TODO_CONFIGURAR_MENU_<DOMINIO>

# --- Locators de formulario ---
${CAMPO_<CAMPO1>_<DOMINIO>_LOCATOR}   TODO_CONFIGURAR_CAMPO_<CAMPO1>_<DOMINIO>

# --- Timeouts ---
${<DOMINIO>_TIMEOUT_PADRAO}           20s
```

## Regras obrigatórias

- Prefixo de log: `[DOM-<DOMINIO>]` em todas as keywords
- `Validar Locator Configurado` presente e chamada antes de usar qualquer locator
- Imports apenas de `../apps/` e `../data/` — nunca `../core/` diretamente
- Sem automação de UI direta (chamar keywords de apps, não `RPA.Windows` direto)
- Locators não mapeados → `TODO_CONFIGURAR_<NOME>` no data resource

## Após criar os arquivos

Liste os arquivos criados e mostre como importar o novo domain em um teste:
```robot
Resource    ../../resources/domains/<dominio>.resource
```
