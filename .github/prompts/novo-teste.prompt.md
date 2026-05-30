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
5. **Tags adicionais** além de `examples` e `uauxt`

## Onde criar

Pasta: `tests/90_examples/`  
Nome: próximo número disponível + nome descritivo  
Ex.: `14_validar_aprovacao_nf.robot`

Para encontrar o próximo número:
```
#file:tests/90_examples
```

## Template a seguir

```robot
*** Settings ***
Documentation       <Descricao objetiva do que o teste valida.>
Library             Collections
Resource            ../../resources/apps/uauxt.resource
# Adicionar apenas os resources realmente usados:
# Resource            ../../resources/apps/uauxt_grid.resource
# Resource            ../../resources/domains/<dominio>.resource
Test Tags           examples    uauxt    <tag-funcional>


*** Variables ***
# Declarar aqui todos os valores usados no teste
${VARIAVEL_EXEMPLO}    valor


*** Test Cases ***
<Nome Do Caso Em Titulo>
    [Documentation]    <O que o teste faz. Pre-requisito: <estado inicial esperado>.>
    Log    [<PREFIXO>] Iniciando <descricao>...    console=True
    # Keywords de domínio ou apps aqui
    Log    [<PREFIXO>] Concluido com sucesso.    console=True
```

## Regras obrigatórias

- Sem locators hardcodados no teste — usar constantes dos `resources/data/`
- Sem `Sleep` — usar `Pausa Controlada` de `sync.resource` (via apps)
- Sem automação por imagem
- Prefixo de log: `[DIAG-GRID]`, `[CONTAS_PAGAR]`, `[UAUXT]`, etc. (ver `robot-test.instructions.md`)
- Se usar grid: `Resource ../../resources/apps/uauxt_grid.resource` — não importar `uauxt_grid_data.resource` separadamente
- Variáveis de negócio em `*** Variables ***` com nome descritivo (ex.: `${COLUNA_CONFIRMADO}    5`)

## Após criar o arquivo

Mostre o caminho completo do arquivo criado e as tags que permitem executá-lo com:
```
.\robot-runner.ps1 tag <tag-funcional>
```
