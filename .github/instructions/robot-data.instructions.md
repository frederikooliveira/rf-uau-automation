---
description: "Use when creating or editing resources/data/*_data.resource files. Covers nomenclatura de variáveis, padrão TODO_CONFIGURAR_, separação por contexto e anti-patterns."
applyTo: "resources/data/*_data.resource"
---

# Camada data — Padrão de resource

## Responsabilidade

Centralizar **todos** os locators, constantes e dados de teste. Nenhuma keyword — apenas `*** Variables ***`.

## Estrutura obrigatória

```robot
*** Settings ***
Documentation       Dados e locators para <contexto>.
...                 Responsabilidade: centralizar variaveis, locators e dados de teste.


*** Variables ***
# --- Locators ---
${CONTEXTO_ELEMENTO_LOCATOR}          id:meuElemento

# --- Constantes ---
${CONTEXTO_TIMEOUT_PADRAO}            20s

# --- Dados de teste ---
${CONTEXTO_DADO_PADRAO}               valor_padrao
```

## Nomenclatura de variáveis

Regra obrigatoria para este repositorio:
- Nome de variavel com no maximo 40 caracteres (sem contar `${` e `}`).
- Se exceder 40, abreviar mantendo contexto legivel (ex.: `DEMONSTRATIVO` -> `RELDEM`, `TOOLBAR` -> `TB`, `INDEX` -> `IDX`).

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Locator UI | `${CONTEXTO_CAMPO_LOCATOR}` | `${CAMPO_NOME_PESSOA_LOCATOR}` |
| Timeout | `${CONTEXTO_TIMEOUT_X}` | `${UAUXT_TIMEOUT_PADRAO}` |
| Delay batch | `${CONTEXTO_BATCH_X_DELAY_MS}` | `${UAUXT_GRID_BATCH_MOVE_DELAY_MS}` |
| Dado de teste | `${CONTEXTO_DADO_X}` | `${EMPRESA_PADRAO}` |
| Flag/regex | `${CONTEXTO_X_REGEX}` | `${UAUXT_GRID_COUNT_REGEX}` |

## Locators não mapeados

Usar placeholder `TODO_CONFIGURAR_<NOME>` enquanto não mapeado:
```robot
${CAMPO_NOVO_LOCATOR}    TODO_CONFIGURAR_CAMPO_NOVO
```
A keyword `Validar Locator Configurado` (em domains) detecta e falha com mensagem clara.  
**Nunca deixar `TODO_CONFIGURAR_` em produção sem issue registrada.**

## Separação por arquivo

| Arquivo | Conteúdo |
|---------|----------|
| `uauxt_data.resource` | Caminhos, credenciais, locators de login |
| `uauxt_grid_data.resource` | Probe, delays, locators do grid |
| `uauxt_menu_data.resource` | Locators do menu lateral |
| `pessoas_data.resource` | Locators e dados do domínio Pessoas |
| `compilador_data.resource` | Constantes do compilador |
| `vs_data.resource` | Caminhos do Visual Studio |

Novo contexto → novo arquivo `<contexto>_data.resource`.

## Credenciais

Nunca valores reais neste arquivo. Usar variáveis de ambiente:
```robot
${MINHA_SENHA}    %{MINHA_SENHA=ENV.MINHA_SENHA}
```

## Anti-patterns

- **Proibido**: keywords em arquivos `_data.resource`
- **Proibido**: credenciais em texto plano
- **Proibido**: locators em arquivos de teste ou resource de apps/domains
- **Proibido**: valores mágicos sem nome descritivo (ex.: `5` → `${COLUNA_CONFIRMADO}    5`)
