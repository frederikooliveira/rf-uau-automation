---
description: "Cria um novo arquivo de teste Robot Framework (.robot) no padrão do projeto rf-uau-automation. Use quando precisar criar um novo teste de automação para o UauXT."
name: "Novo Teste Robot"
argument-hint: "Ex.: fluxo de aprovação de NF em Contas a Pagar"
agent: "agent"
---

Crie um novo arquivo de teste Robot Framework seguindo estritamente o padrão do projeto `rf-uau-automation`.

## Informações necessárias

Se o usuário não informou, pergunte:
1. **Nome descritivo** do teste (ex.: "validar aprovação de NF")
2. **Contexto funcional** (ex.: contas-pagar, pessoas, aprovacao)
3. **Recursos** que o teste usará (uauxt login, grid, menu, etc.)
4. **Pré-requisito**: tela já aberta ou precisa de login completo?
5. **Tipo do teste**: fluxo real (`tests/flows`) ou exemplo (`tests/90_examples`)
6. **Tags adicionais** além de `uauxt`

## Onde criar

Pasta padrao: `tests/flows/<contexto>/`  
Nome: próximo número disponível + nome descritivo  
Ex.: `01_validar_aprovacao_nf.robot`

Somente quando o usuario pedir explicitamente **exemplo/diagnostico**, usar:
- `tests/90_examples/NN_nome_descritivo.robot`

Para encontrar o próximo número na pasta alvo:
```
#file:tests/flows/<contexto>
```

## Domains disponíveis

Antes de definir imports, verificar se existe domain para o contexto:

| Contexto | Domain | Principais keywords |
|----------|--------|---------------------|
| Contas a Pagar | `resources/domains/contas_pagar.resource` | `Selecionar Empresa E Obra`, `Selecionar Empresa No Popup`, `Configurar Periodo Prorrogacao`, `Preencher Confirmado Por Faixa`, `Alterar Banco Do Processo`, `Alterar Conta Do Processo` |
| Pessoas | `resources/domains/pessoas.resource` | (ver arquivo) |

**Regra:** se o contexto tiver domain, o import principal é o domain — não reimplementar keywords de negócio no teste.

## Template a seguir

```robot
*** Settings ***
Documentation       <Descricao objetiva do que o teste valida.>
Library             Collections
# SE existir domain para o contexto, importar o domain (ele já inclui apps/data):
Resource            ../../resources/domains/<dominio>.resource
# SE não houver domain (ex.: apenas login/navegação genérica):
# Resource            ../../resources/apps/uauxt.resource
# Resource            ../../resources/apps/uauxt_grid.resource
# Fluxo real (padrao):
Test Tags           uauxt    <tag-funcional>
# Exemplo/diagnostico (somente em tests/90_examples):
# Test Tags         examples    uauxt    <tag-funcional>


*** Variables ***
# Declarar aqui todos os valores usados no teste
${VARIAVEL_EXEMPLO}    valor


*** Test Cases ***
<Nome Do Caso Em Titulo>
    [Documentation]    <O que o teste faz. Pre-requisito: <estado inicial esperado>.>
    Log    [<PREFIXO>] Iniciando <descricao>...    console=True
    # Keywords de domínio ou apps aqui — NUNCA reimplementar fluxos de negócio no teste
    Log    [<PREFIXO>] Concluido com sucesso.    console=True
```

## Regras obrigatórias

- Sem locators hardcodados no teste — usar constantes dos `resources/data/`
- Sem `Sleep` — usar `Pausa Controlada` de `sync.resource` (via apps)
- Sem automação por imagem
- Prefixo de log: `[DIAG-GRID]`, `[CONTAS_PAGAR]`, `[UAUXT]`, etc. (ver `robot-test.instructions.md`)
- **Se existe domain para o contexto, importar o domain — não reimplementar keywords de negócio no teste**
- Variáveis de negócio em `*** Variables ***` com nome descritivo (ex.: `${COLUNA_CONFIRMADO}    5`)
- Nao usar tag `examples` em testes de fluxo real (`tests/flows`)
- Usar tag `examples` apenas em `tests/90_examples`

## Após criar o arquivo

Mostre o caminho completo do arquivo criado e as tags que permitem executá-lo com:
```
.\robot-runner.ps1 tag <tag-funcional>
```
