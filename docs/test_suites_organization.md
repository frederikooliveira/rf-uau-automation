# Organizacao de Suites de Teste

Objetivo: facilitar visualizacao e execucao das suites sem perder a regra de ouro.

Regra de ouro
- 1 test case = 1 comportamento observavel do sistema.
- Se houver mais de um resultado de negocio no mesmo teste, dividir em novos casos.

## Mapa por pasta

- tests/01_pipeline_setup
  - Finalidade: preparacao de ambiente e pipeline tecnico.
  - Tag principal: setup.
- tests/02_pipeline_smoke
  - Finalidade: validacao rapida de disponibilidade basica.
  - Tag principal: smoke.
- tests/api
  - Finalidade: validacao de contratos e disponibilidade de API REST.
  - Tags principais: api, smoke-api, funcional-api.
- tests/flows
  - Finalidade: testes funcionais de negocio.
  - Tags base: funcional, comportamento-unico.
- tests/90_examples
  - Finalidade: exemplos e diagnostico guiado.
  - Tag principal: examples.

## Regra de estrutura dos arquivos

- Fluxos em `tests/flows/` devem, por padrao, representar um unico comportamento principal por arquivo.
- Se um fluxo tiver mais de um comportamento de negocio claramente distinto, dividir em arquivos separados.
- Dentro de cada arquivo de fluxo, manter 1 test case = 1 comportamento.
- Em `tests/90_examples/`, um arquivo pode conter mais de um test case quando for uma suite de exploracao, diagnostico ou variacao do mesmo tema.
- Mesmo em examples, cada test case continua obedecendo 1 comportamento por caso.

Padrao recomendado para arquivos de fluxo:
- <ordem>_<dominio>_<comportamento_principal>.robot

Exemplos:
- 01_vendas_impressao_resumo_venda.robot
- 01_financeiro_validar_estrutura_emissao_pagamentos.robot
- 02_vendas_abertura_relatorio_demonstrativo_pagamentos.robot
- 09_contas_pagar_preencher_confirmado_dvq.robot

Quando o arquivo tiver varios casos:
- apenas se todos os casos forem variacoes proximas do mesmo comportamento ou diagnostico;
- cada caso deve ter nome independente e descrever um unico resultado final.

## Taxonomia de tags recomendada

Sempre combinar categorias:
- Tipo de suite: setup, smoke, funcional, integracao, regressao, examples.
- Dominio: vendas, financeiro, contas-pagar, uauxt, api.
- Comportamento: resumo-venda, relatorio-demonstrativo, emissao-pagamentos.
- Tecnica (opcional): popup, grid-botao, diagnostico.

Exemplos de combinacao:
- funcional + vendas + resumo-venda
- funcional + vendas + relatorio-demonstrativo + popup
- smoke + uauxt
- regressao + financeiro + emissao-pagamentos

## Nomenclatura dos Test Cases (orientada a comportamento)

Objetivo: ao ler o nome do caso, ficar claro qual comportamento de negocio esta sendo validado.

Padrao recomendado:
- Um unico comportamento observavel por caso.
- Verbo principal + objeto + resultado esperado.
- Evitar termos tecnicos no titulo (click, grid, xpath, probe, id).
- Preferir nome curto e direto, sem listar passos ou sub-resultados.

Formato sugerido:
- <Verbo principal> <Objeto> <Resultado esperado>

Regra pratica:
- Se o titulo tiver dois verbos de negocio diferentes, dividir o caso.
- Se a leitura do nome sugerir "fazer A e depois B" como objetivos independentes, dividir o caso.
- O nome pode ter "E" apenas se ainda representar um unico comportamento final, nao dois resultados separados.

Exemplos bons:
- Abrir Resumo De Venda
- Imprimir Resumo De Venda
- Abrir Relatorio Demonstrativo De Pagamentos
- Validar Estrutura Da Tela Emissao De Pagamentos

Exemplos a evitar:
- Abrir Tela E Preencher Grid E Validar Popup
- Fluxo Completo Contas Pagar
- Fazer Login E Acessar Tela E Validar Grid

Checklist rapido para validar o nome:
- O nome descreve apenas um comportamento observavel?
- O resultado de negocio esperado esta explicito?
- Se eu remover passos tecnicos internos, o nome continua valido?
- Se eu separar o caso em dois nomes, cada um continua fazendo sentido isoladamente?

Regra de divisao:
- Se houver mais de uma validacao de negocio, dividir em mais de um test case.

## Comandos padronizados

- .\\robot-runner.ps1 setup
- .\\robot-runner.ps1 api
- .\\robot-runner.ps1 smoke
- .\\robot-runner.ps1 funcional
- .\\robot-runner.ps1 integracao
- .\\robot-runner.ps1 regressao
- .\\robot-runner.ps1 examples
- .\\robot-runner.ps1 all-suites

## Como evoluir sem quebrar historico

- Nao mover exemplos para flows sem necessidade imediata.
- Ao criar novos flows, iniciar com 1 caso de teste e 1 comportamento.
- Ao identificar teste com multiplos comportamentos, quebrar em casos separados no mesmo arquivo antes de criar novo arquivo.
- Em testes de integracao ou regressao, manter a regra de 1 comportamento e controlar cobertura via tags.
