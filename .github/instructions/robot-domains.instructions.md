---
description: "Use when creating or editing resources/domains/*.resource files. Covers imports permitidos por camada, prefixo de log, composição de fluxos de negócio e anti-patterns."
applyTo: "resources/domains/*.resource"
---

# Camada domains — Padrão de resource

## Responsabilidade

Fluxos de negócio compostos por keywords de `apps`. Sabe **o quê** fazer (regra de negócio), delega **como** para a camada apps.  
Não contém automação de UI direta.

## Estrutura obrigatória

```robot
*** Settings ***
Documentation       Keywords de dominio de negocio para <dominio>.
...                 Responsabilidade: fluxos de negocio (nao UI tecnica).
Library             String
Resource            ../apps/<app_principal>.resource
Resource            ../data/<dominio>_data.resource


*** Keywords ***
Validar Locator Configurado
    [Documentation]    Falha cedo quando um locator nao foi mapeado.
    [Arguments]    ${locator}    ${nome_locator}
    IF    '${locator}'.startswith('TODO_CONFIGURAR_')
        Fail    Locator nao configurado: ${nome_locator}. Atualize em resources/data/<dominio>_data.resource.
    END

<Verbo Acao De Negocio>
    [Documentation]    <Fluxo de negócio descrito em termos do domínio.>
    Validar Locator Configurado    ${LOCATOR_USADO}    LOCATOR_USADO
    Log    [DOM-<DOMINIO>] <Mensagem>...    console=True
    <keywords de apps>
    Log    [DOM-<DOMINIO>] <Resultado>.    console=True
```

## Imports permitidos

| Permitido | Proibido |
|-----------|----------|
| `Resource ../apps/*.resource` | `resources/core/*` diretamente |
| `Resource ../data/<dominio>_data.resource` | UI direta (`RPA.Windows` sem passar por apps) |
| `Library String`, `Collections` | Locators hardcodados |

## Prefixo de log

Padrão: `[DOM-<DOMINIO>]`

| Domain | Prefixo |
|--------|---------|
| `pessoas.resource` | `[DOM-PESSOAS]` |
| Futuro `obras.resource` | `[DOM-OBRAS]` |
| Futuro `financeiro.resource` | `[DOM-FIN]` |

## Keyword `Validar Locator Configurado`

Deve estar presente em todo domain resource. Chamar no início de qualquer keyword que use locator de `data/`:

```robot
Preencher Cadastro De Pessoa
    [Arguments]    ${pessoa}
    Validar Locator Configurado    ${CAMPO_NOME_PESSOA_LOCATOR}    CAMPO_NOME_PESSOA_LOCATOR
    Validar Locator Configurado    ${CAMPO_CPF_PESSOA_LOCATOR}     CAMPO_CPF_PESSOA_LOCATOR
    ...
```

## Padrão de keywords de domínio

Nomenclatura: `<Verbo> <Substantivo Do Domínio>`  
Exemplos: `Acessar Menu Pessoas`, `Preencher Cadastro De Pessoa`, `Gravar Cadastro De Pessoa`

Sequência típica num fluxo:
1. Validar locators
2. Log de início `[DOM-X] Iniciando...`
3. Chamadas a keywords de `apps/`
4. Log de conclusão `[DOM-X] Concluido.`

## Anti-patterns

- **Proibido**: importar `resources/core/*` diretamente
- **Proibido**: chamar `RPA.Windows` diretamente — passar por `apps/`
- **Proibido**: locators hardcodados — usar `resources/data/<dominio>_data.resource`
- **Proibido**: `Sleep` — usar keywords de sync via apps
- **Proibido**: regra de negócio espalhada em múltiplos levels (concentrar no domain)
