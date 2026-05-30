---
description: "Cria um novo resource de automação de app em resources/apps/ seguindo o padrão do projeto rf-uau-automation. Use quando precisar automatizar uma nova aplicação ou módulo de UI (ex.: novo módulo do UauXT, nova ferramenta desktop)."
name: "Novo Apps Resource"
argument-hint: "Ex.: uauxt_aprovacao, desktop_relatorios"
agent: "agent"
---

Crie um novo arquivo `resources/apps/<app>.resource` seguindo o padrão do projeto `rf-uau-automation`.

## Informações necessárias

Se o usuário não informou, pergunte:
1. **Nome do app/módulo** (ex.: uauxt_aprovacao, compilador_modulos)
2. **Tecnologia de automação** (RPA.Windows para desktop Win32 — padrão do projeto)
3. **Operações principais** (ex.: abrir janela, preencher campo, clicar botão, ler resultado)
4. **Locators já conhecidos** ou usar `TODO_CONFIGURAR_`?

## Onde criar

- Resource: `resources/apps/<app>.resource`
- Dados: `resources/data/<app>_data.resource` (criar junto, se não existir)

## Template do apps resource

```robot
*** Settings ***
Documentation       Keywords de automacao tecnica para <App>.
...                 Responsabilidade: interacao direta de UI com <App>.
Library             RPA.Windows
Resource            ../core/ui_helpers.resource
Resource            ../core/sync.resource
Resource            ../data/<app>_data.resource


*** Keywords ***
Abrir <App>
    [Documentation]    Abre a janela principal de <App>.
    Log    [<APP>] Abrindo <App>...    console=True
    # implementacao
    Log    [<APP>] <App> aberto.    console=True

Aguardar <App> Pronto
    [Documentation]    Aguarda <App> estar pronto para interacao.
    [Arguments]    ${timeout}=${<APP>_TIMEOUT_PADRAO}
    Log    [<APP>] Aguardando <App> pronto (timeout ${timeout})...    console=True
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Control Window    ${<APP>_JANELA_PRINCIPAL}
    Log    [<APP>] <App> pronto.    console=True
```

## Template do data resource

```robot
*** Settings ***
Documentation       Dados e locators para <App>.
...                 Responsabilidade: centralizar variaveis, locators e constantes.


*** Variables ***
# --- Caminhos ---
${<APP>_EXE}                          %{<APP>_EXE=caminho_padrao}

# --- Locators ---
${<APP>_JANELA_PRINCIPAL}             TODO_CONFIGURAR_<APP>_JANELA_PRINCIPAL
${<APP>_BOTAO_X}                      TODO_CONFIGURAR_<APP>_BOTAO_X

# --- Timeouts ---
${<APP>_TIMEOUT_PADRAO}               20s
```

## Regras obrigatórias

- `Library RPA.Windows` — automação de UI exclusivamente Win32
- Sem `RPA.Images`, OCR ou screenshot matching
- Prefixo de log: `[<APP>]` em todas as keywords
- Imports: somente `core/` e `data/` — nunca `domains/`
- Sem regra de negócio — apenas operações técnicas de UI
- Locators não mapeados → `TODO_CONFIGURAR_<NOME>` no data resource
- Sincronização via `sync.resource` — sem `Sleep` arbitrário

## Após criar os arquivos

Liste os arquivos criados e mostre como importar o novo apps resource:
- Em outro apps resource ou domain: `Resource    ../apps/<app>.resource`
- Em teste: `Resource    ../../resources/apps/<app>.resource`
