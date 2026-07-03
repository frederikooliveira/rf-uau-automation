---
description: "Gera apenas a ação de navegação para abrir uma tela UauXT a partir do JSON de mapeamento, usando os campos relevantes do JSON e sem criar scaffolding completo."
name: "Scaffold Navegação Tela UauXT"
argument-hint: "Cole o JSON do mapeamento da tela"
agent: "agent"
---

Crie ou atualize apenas a ação de navegação que abre a tela descrita no JSON.

## Entrada esperada

- JSON produzido por "Mapear Tela UauXT (Baixo Custo)"

Use os campos abaixo para tomar a decisão:
- `nome_tela`, `caminho_acesso` e `acao_navegacao` para definir a keyword e os passos
- `locators_confirmados` para preencher locators já conhecidos
- `locators_pendentes` para manter placeholders `TODO_CONFIGURAR_`
- `resumo.toolbars`, `resumo.grids` e demais campos apenas como contexto técnico; não gerar scaffolding completo com base neles

Se faltar algo essencial, perguntar apenas o mínimo:
1. nome de app ou recurso alvo (se não houver um recurso existente adequado)
2. nome de domínio, se for necessário para organizar a keyword

## Regras obrigatórias

- Respeitar arquitetura em camadas: core -> apps -> domains
- Não criar arquivos de data/apps/domain/teste completos, salvo solicitação explícita
- Criar apenas o necessário para a navegação: preferencialmente uma keyword em um recurso existente, por exemplo em resources/apps/uauxt.resource ou em resources/domains/<dominio>.resource
- Se houver locators novos e ainda não existirem, registrar em resources/data/<contexto>_data.resource como `TODO_CONFIGURAR_`
- Não colocar regra de negócio em apps
- Não usar automação por imagem
- Reutilizar keywords já existentes para menu, toolbar e grid
- Se o JSON indicar `acao_navegacao.tipo = menu`, usar a keyword compartilhada de navegação do app
- Se o JSON indicar `toolbar`, usar a keyword compartilhada de toolbar
- Não criar testes automaticamente nesta etapa
- Não inventar dados; use placeholders para o que não estiver confirmado

## Artefatos a gerar

- Preferencialmente: atualizar um recurso existente com a keyword de navegação
- Opcionalmente: criar ou atualizar resources/data/<contexto>_data.resource se houver locators novos
- Não criar: testes, arquivos de app/domain/data completos, ou qualquer outra estrutura extra

## Como usar o JSON

1. Identifique `acao_navegacao.nome_keyword`
2. Use `acao_navegacao.tipo` e `acao_navegacao.passos` para montar a implementação
3. Use `nome_tela` e `caminho_acesso` para nomear o contexto da keyword e os logs
4. Use `locators_confirmados` para preencher valores reais
5. Use `locators_pendentes` para manter placeholders e não inventar
6. Ignore o restante do JSON, exceto como contexto técnico

## Saída da execução

1. Lista dos arquivos criados/alterados
2. Resumo da keyword de navegação gerada
3. Lista de placeholders pendentes
4. Observação se a implementação ficou restrita à navegação
