# Copilot Instructions - rf-uau-automation

Escopo: orientacoes objetivas para a IA gerar codigo consistente neste repositorio.

## Regras obrigatorias

- Usar automacao de UI exclusivamente com RPA.Windows.
- Nao usar automacao por imagem (RPA.Images, OCR, screenshot matching).
- Nao adicionar locators hardcoded em testes; centralizar em resources/data.
- Evitar Sleep arbitrario; preferir keywords de sincronizacao reutilizaveis.

## Arquitetura obrigatoria

- resources/core: helpers tecnicos genericos (UI, sync)
- resources/apps: automacao por aplicacao (compilador, visual_studio, uauxt, desktop_tools)
- resources/domains: fluxos de negocio (ex.: pessoas)
- resources/data: variaveis, locators, dados de teste

Dependencias entre camadas:
- Permitido: core -> (nenhuma), apps -> core+data, domains -> apps+data
- Proibido: core depender de apps/domains; apps conter regra de negocio

## Convencoes de nomenclatura

- Arquivos apps: <app>.resource (ex.: visual_studio.resource)
- Arquivos domains: <dominio>.resource
- Arquivos data: <contexto>_data.resource
- Testes: NN_nome_descritivo.robot (ex.: 01_baixar_versao.robot)
- Keywords: iniciar com verbo e nome descritivo
- Variaveis Robot: nome com no maximo 40 caracteres (sem contar `${` e `}`)

## Padrao para novos locators

- Criar primeiro em resources/data/<contexto>_data.resource
- Enquanto nao mapeado, usar TODO_CONFIGURAR_<NOME>
- Validar locator configurado antes de interagir na UI

## Execucao e validacao

- Runner principal: robot-runner.ps1
- Suites principais:
  - .\\robot-runner.ps1 setup
  - .\\robot-runner.ps1 examples
  - .\\robot-runner.ps1 all-suites

## Politica de scripts Python

- Script oficial de suporte ao grid: resources/scripts/uauxt_probe.py
- Nao manter no repositorio scripts temporarios de debug (`tmp_*`, `diagnostico_*`) sem uso real nos resources/tests.

## Checklist minimo antes de sugerir mudancas

- Imports seguem arquitetura em camadas
- Sem hardcode de paths/locators em teste
- Logs com prefixo de contexto (ex.: [COMP], [UAUXT], [DOM-PESSOAS])
- Sem uso de automacao por imagem
- Mudancas pequenas e focadas no objetivo
- Sem duplicacao de probe: reutilizar `resources/apps/uauxt_grid.resource` para acoes Win32 de grid/toolbar
