---
description: "Use when creating or editing Robot Framework test files (.robot) in tests/. Covers estrutura obrigatória de Settings/Variables/Test Cases, imports corretos por camada, tags, logs e anti-patterns."
applyTo: "tests/**/*.robot"
---

# Robot Framework — Padrão de testes

## Onde criar testes

- Padrão para testes de fluxo real: `tests/flows/<contexto>/`
- `tests/90_examples/` somente para exemplos e diagnósticos solicitados explicitamente
- Não criar testes de fluxo real em `tests/90_examples/`

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
2. `Resource ../../resources/domains/<dominio>.resource` **se o contexto de negócio já tiver domain** (contas_pagar, pessoas…)
3. `Resource ../../resources/apps/uauxt.resource` — **somente se o domain não o importar já** (login, navegação sem domínio)
4. `Resource ../../resources/apps/uauxt_grid.resource` — **somente se o domain não o importar já**
5. Outros resources de apps na sequência
6. **Nunca** importar `resources/data/*` diretamente — os resources de apps/domains já importam

### Quando usar domain vs apps diretamente

| Situação | Import correto |
|----------|---------------|
| Fluxo de Contas a Pagar (filtro, grid, banco/conta) | `domains/contas_pagar.resource` |
| Fluxo de Pessoas | `domains/pessoas.resource` |
| Apenas login/navegação sem fluxo de negócio definido | `apps/uauxt.resource` |
| Somente operações de grid genérico | `apps/uauxt_grid.resource` |

**Regra:** se existe um domain para o contexto, importar o domain — nunca reimplementar keywords de negócio no teste.

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

Regra adicional:
- Em `tests/flows/`, não usar `examples` por padrão.
- Em `tests/90_examples/`, incluir `examples`.

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

Permitido criar `*** Keywords ***` no arquivo de teste **somente** para:
- Agrupamento semântico de passos **exclusivos** deste teste
- Lógica que não fará sentido em nenhum outro arquivo

**Proibido** criar keywords locais que:**
- Encapsulem fluxos de negócio já cobertos por um domain existente
- Interajam com popups, grids, campos de formulário de forma reutilizável
- Duplicariam keywords de `resources/domains/` ou `resources/apps/`

**Regra de ouro:** se a keyword descreve *o que o negócio faz* ("Selecionar Empresa", "Alterar Banco", "Configurar Periodo"), ela pertence ao domain, não ao teste.

## Nomenclatura de arquivos

Padrão: `NN_nome_descritivo.robot`  
Exemplos: `09_contas_pagar_preencher_confirmado_dvq.robot`, `13_contas_pagar_abrir_vinculos_nota_fiscal.robot`

## Anti-patterns

- **Proibido**: locators hardcodados no teste (usar resources/data/)
- **Proibido**: `Sleep` arbitrário — usar `Pausa Controlada` de `sync.resource`
- **Proibido**: automação por imagem (RPA.Images, OCR, screenshot matching)
- **Proibido**: importar `resources/core/*` diretamente no teste
- **Proibido**: regra de negócio fora de `resources/domains/`
