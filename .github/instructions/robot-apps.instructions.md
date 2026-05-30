---
description: "Use when creating or editing resources/apps/*.resource files. Covers imports permitidos por camada, prefixos de log, validação de locators e anti-patterns."
applyTo: "resources/apps/*.resource"
---

# Camada apps — Padrão de resource

## Responsabilidade

Automação técnica de UI por aplicação. Sabe **como** interagir com a aplicação, não **o quê** o negócio quer.  
Não contém regra de negócio — isso fica em `resources/domains/`.

## Estrutura obrigatória

```robot
*** Settings ***
Documentation       Keywords de automacao tecnica para <app>.
...                 Responsabilidade: <descricao tecnica>.
Library             RPA.Windows
Resource            ../core/ui_helpers.resource
Resource            ../core/sync.resource
Resource            ../data/<contexto>_data.resource


*** Keywords ***
<Verbo Descritivo Da Acao>
    [Documentation]    <O que faz e pré-condições.>
    Log    [<APP>] <Mensagem>...    console=True
    <implementacao>
    Log    [<APP>] <Resultado>.    console=True
```

## Imports permitidos

| Permitido | Proibido |
|-----------|----------|
| `Library RPA.Windows` | `resources/domains/*` |
| `Library Collections`, `Process`, `OperatingSystem` | Regra de negócio inline |
| `Resource ../core/ui_helpers.resource` | Locators hardcodados |
| `Resource ../core/sync.resource` | Automação por imagem |
| `Resource ../data/<contexto>_data.resource` | |

## Prefixo de log

Cada app tem prefixo fixo entre colchetes:

| Resource | Prefixo |
|----------|---------|
| `uauxt.resource` | `[UAUXT]` |
| `uauxt_grid.resource` | `[UAUXT-GRID]` |
| `compilador.resource` | `[COMP]` |
| `visual_studio.resource` | `[VS]` |
| `uauxt_grid.resource` (probe) | `[UAUXT-GRID]` |

## Validação de locator

Antes de qualquer interação com locator vindo de `data/`, validar:
```robot
Validar Locator De Grid Configurado    ${MEU_LOCATOR}    MEU_LOCATOR
```
Ou para locators simples:
```robot
Should Not Be Empty    ${MEU_LOCATOR}
Should Not Start With    ${MEU_LOCATOR}    TODO_CONFIGURAR_
```

## Sincronização

Nunca usar `Sleep` arbitrário. Usar keywords de `sync.resource`:
- `Pausa Controlada    500ms    Motivo descritivo`
- `Aguardar Elemento Com Log    ${locator}    descricao`
- `Aguardar Popup Informa`

## Anti-patterns

- **Proibido**: importar `resources/domains/*`
- **Proibido**: conter regra de negócio (ex.: "se DVQ então...")
- **Proibido**: locators hardcodados — centralizar em `resources/data/<contexto>_data.resource`
- **Proibido**: `RPA.Images`, OCR, screenshot matching
- **Proibido**: `Sleep` sem justificativa — usar `Pausa Controlada`
