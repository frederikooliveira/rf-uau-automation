---
description: "Use when creating or editing Robot Framework test files (.robot) in tests/. Covers estrutura obrigatória de Settings/Variables/Test Cases, imports corretos por camada, tags, logs e anti-patterns."
applyTo: "tests/**/*.robot"
---

# Robot Framework — Padrão de testes

## Estrutura obrigatória

```robot
*** Settings ***
Documentation       <Descrição objetiva do que o teste valida.>
Library             Collections
Resource            ../../resources/apps/uauxt.resource
Resource            ../../resources/apps/uauxt_grid.resource   # apenas se usar grid
Test Tags           examples    <contexto>    <tag-funcional>


*** Variables ***
${VARIAVEL_TESTE}    valor


*** Test Cases ***
<Nome Do Caso De Teste Em Titulo>
    [Documentation]    <O que o teste faz e pré-requisitos.>
    Log    [<PREFIXO>] Iniciando <descricao>...    console=True
    <keywords do domínio/apps>
    Log    [<PREFIXO>] Concluido com sucesso.    console=True
```

## Ordem de imports em `*** Settings ***`

1. `Library Collections` (quando usar dicionários)
2. `Resource ../../resources/apps/uauxt.resource` (se usar login/navegação)
3. `Resource ../../resources/apps/uauxt_grid.resource` (se usar grid)
4. Outros resources de apps na sequência
5. **Nunca** importar `resources/data/*` diretamente — os resources de apps/domains já importam

## Tags obrigatórias

| Tag | Quando usar |
|-----|-------------|
| `examples` | Todos os testes em `90_examples/` |
| `uauxt` | Todos que interagem com a aplicação UauXT |
| `fluxo-completo` | Testes que combinam login + navegação + ação |
| `dvq-grid` | Testes de preenchimento DVQ no grid |
| `grid-botao` | Testes de clique em botão de célula do grid |
| `contas-pagar` | Testes de Contas a Pagar |
| `diagnostico` | Testes exploratórios/diagnóstico |

## Variáveis

- Sempre declarar em `*** Variables ***`, nunca hardcodadas no corpo do teste
- Nomenclatura: `${CONTEXTO_DESCRICAO}` em maiúsculas com underscore
- Dados de negócio (empresa, datas, colunas) como variáveis no topo

```robot
*** Variables ***
${EMPRESA_PADRAO}        262
${COLUNA_CONFIRMADO}     5
${VALOR_DVQ}             DVQ
${LINHA_INICIAL}         1
${LINHA_FINAL}           3
```

## Logs — prefixo obrigatório por contexto

| Contexto | Prefixo |
|----------|---------|
| Exemplos / diagnóstico | `[DIAG-GRID]`, `[EXEMPLO]` |
| Contas a Pagar | `[CONTAS_PAGAR]` |
| Login/UauXT | `[UAUXT]` |
| Popup | `[POPUP]` |
| Domínio Pessoas | `[DOM-PESSOAS]` |

Sempre com `console=True` para aparecer no terminal durante execução.

## Keywords locais no teste

Permitido criar `*** Keywords ***` no arquivo de teste apenas para:
- Agrupamento semântico de passos do próprio teste
- Não reutilizável em outros arquivos (senão mover para `resources/domains/`)

## Nomenclatura de arquivos

Padrão: `NN_nome_descritivo.robot`  
Exemplos: `09_fluxo_completo_contas_pagar_dvq.robot`, `13_abrir_vinculos_nota_fiscal_no_grid.robot`

## Anti-patterns

- **Proibido**: locators hardcodados no teste (usar resources/data/)
- **Proibido**: `Sleep` arbitrário — usar `Pausa Controlada` de `sync.resource`
- **Proibido**: automação por imagem (RPA.Images, OCR, screenshot matching)
- **Proibido**: importar `resources/core/*` diretamente no teste
- **Proibido**: regra de negócio fora de `resources/domains/`
