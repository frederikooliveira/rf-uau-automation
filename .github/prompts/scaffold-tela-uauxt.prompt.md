---
description: "Gera estrutura base de uma nova tela (data/apps/domain/teste) a partir de um JSON de mapeamento, com placeholders TODO_CONFIGURAR_ e baixo custo de manutencao."
name: "Scaffold Tela UauXT"
argument-hint: "Cole o JSON do mapeamento da tela"
agent: "agent"
---

Crie os artefatos da tela a partir do JSON de mapeamento fornecido pelo usuario.

## Entrada esperada

- JSON produzido por "Mapear Tela UauXT (Baixo Custo)"

Se faltar algo essencial, perguntar apenas o minimo:
1. nome de app (arquivo em resources/apps)
2. nome de dominio (arquivo em resources/domains)
3. pasta de teste (default: tests/flows/<contexto>)
4. confirmar se e teste de exemplo (se sim, usar tests/90_examples)

## Regras obrigatorias

- Respeitar arquitetura em camadas: core -> apps -> domains
- Nao colocar regra de negocio em apps
- Nao criar locator hardcoded em teste
- Locators nao confirmados devem ficar como TODO_CONFIGURAR_<NOME>
- Nao usar automacao por imagem
- Evitar mudancas grandes; gerar somente o necessario
- Padrao de criacao de testes: tests/flows/<contexto>
- `tests/90_examples` somente se o usuario pedir explicitamente teste de exemplo/diagnostico
- Nao duplicar chamadas de probe com `Run Process` em recursos de contexto quando ja houver keyword compartilhada
- Reutilizar `resources/apps/uauxt_grid.resource` para operacoes Win32 de grid/toolbar

## Arquivos para gerar (quando nao existirem)

1. resources/data/<contexto>_data.resource
2. resources/apps/<app>.resource
3. resources/domains/<dominio>.resource
4. tests/flows/<contexto>/NN_<nome_descritivo>.robot

Quando explicitamente solicitado como exemplo:
- tests/90_examples/NN_<nome_descritivo>.robot

Opcional (somente se realmente necessario):
- resources/core/<helper>.resource (apenas helper tecnico reutilizavel)

## Regras de conteudo por camada

### data
- Apenas *** Variables ***
- Locators, indices, constantes, dados
- TODO_CONFIGURAR_ para itens pendentes

### apps
- Keywords tecnicas de UI
- Logs com prefixo de app
- Importa core + data
- Nao encapsular novamente comandos de probe ja expostos por `uauxt_grid.resource`

### domains
- Fluxo de negocio
- Usa apenas apps + data
- Incluir "Validar Locator Configurado"
- Quando houver acao de toolbar/grid Win32, usar keyword compartilhada de `uauxt_grid.resource`
- Para acesso de tela via menu, usar keyword dedicada em `resources/apps/uauxt.resource`
- Padrao de navegacao: encapsular no app (ex.: `Acessar <Tela> Via ...`) com fallback robusto
- Evitar cliques encadeados de menu diretamente no domain

### teste
- Usa domain quando existir
- Em flows: tags de fluxo/contexto (sem `examples` por padrao)
- Em examples: incluir tag `examples`
- Logs com prefixo de contexto

## Saida da execucao

1. Lista dos arquivos criados/alterados
2. Resumo curto do que ficou pendente (TODO_CONFIGURAR_)
3. Comando sugerido para execucao por tag
