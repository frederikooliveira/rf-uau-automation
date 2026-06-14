# rf-uau-automation

Automação de desktop Windows legada usando **Robot Framework 7** + **RPA.Windows** para aplicações como UAU Compilador, Visual Studio e UauXT.

## 🏗️ Arquitetura

Estrutura em camadas de reusabilidade e separação de responsabilidades:

```
rf-uau-automation/
├── resources/
│   ├── core/                     # Camada técnica genérica
│   │   ├── ui_helpers.resource   # Clicar, digitar, janelas, processos
│   │   └── sync.resource         # Esperas inteligentes, pausas controladas
│   ├── apps/                      # Camada aplicativa (por sistema)
│   │   ├── compilador.resource   # UAU Compilador
│   │   ├── visual_studio.resource # Visual Studio
│   │   ├── uauxt.resource        # UauXT
│   │   └── uauxt_grid.resource   # Operacoes tecnicas de grid (probe/win32)
│   ├── domains/                   # Camada de negócio (por domínio)
│   │   └── pessoas.resource      # Cadastro de pessoas
│   ├── data/                      # Camada de dados
│   │   ├── compilador_data.resource   # Paths, locators, timeouts
│   │   ├── vs_data.resource
│   │   ├── uauxt_data.resource
│   │   ├── uauxt_grid_data.resource
│   │   └── pessoas_data.resource
│   ├── scripts/                   # Scripts Python de suporte tecnico
│   │   └── uauxt_probe.py         # Probe oficial Win32 do UauXT (grid + toolbar)
│   └── screenshots/               # Capturas de tela (screenshots)
├── tests/
│   ├── 01_pipeline_setup/        # Pipeline base: baixar, compilar, publicar, validar
│   ├── 90_examples/              # Exemplos reutilizáveis para QA
│   └── flows/                    # Fluxos multi-etapa (futuro)
├── docs/
│   └── examples.md               # Guia prático de exemplos e padrões
├── results/                      # Relatórios gerados
├── .github/
│   └── copilot-instructions.md   # Instruções objetivas para IA (Copilot)
├── CONTRIBUTING.md               # 📖 Governança e padrões de contribuição
├── robot-runner.ps1              # Executor Robot Framework
├── robot.toml                    # Configuração Robot Framework
├── requirements.txt              # Dependências Python
└── README.md                     # Este arquivo
```

## 🚀 Quickstart

### 1. Configuração Inicial

```bash
# Python 3.11 é obrigatório (rpaframework incompatível com 3.14)
py -3.11 -m venv .venv

# Ativar virtual environment
.venv\Scripts\activate

# Instalar dependências
pip install -r requirements.txt
```

### 2. Executar Testes

```powershell
# Setup completo (baixar, compilar, mover)
.\robot-runner.ps1 setup

# Exemplos e referências executáveis
.\robot-runner.ps1 examples

# Tudo
.\robot-runner.ps1 all-suites
```

### 3. Ver Relatórios

Após execução, abrir:
```
results/
├── log.html       # Log detalhado
├── report.html    # Relatório visual
└── output.xml     # Dados brutos
```

## 📚 Documentação

### Para Contribuintes

Leia **`CONTRIBUTING.md`** para:
- ✅ Estrutura de camadas (CORE, APPS, DOMAINS, DATA)
- ✅ Convenções de nomenclatura
- ✅ Quando/onde criar novo código
- ✅ Checklist de revisão de código
- ✅ Troubleshooting comum

Para instruções curtas e objetivas de IA (Copilot), use:
- ✅ **`.github/copilot-instructions.md`**

### Exemplos Rápidos

Os exemplos reutilizáveis foram centralizados em:

- `docs/examples.md` para leitura orientada por padrão
- `tests/90_examples/` para execução prática

#### Usar um locator existente
```robot
*** Settings ***
Resource    ../../resources/apps/compilador.resource

*** Test Cases ***
Testar Compilacao
    Abrir UAU Compilador
    Configurar Opcoes Compilador
    Aguardar Compilacao
```

#### Adicionar novo locator
1. Editar `resources/data/{app}_data.resource`
2. Começar com `TODO_CONFIGURAR_` até mapear a UI real
3. Atualizar keyword em `resources/apps/{app}.resource`

#### Criar novo teste de negócio
1. Criar arquivo em `tests/90_examples/` para exemplos ou em `tests/flows/` para fluxos compostos
2. Importar `resources/apps/uauxt.resource` e `resources/domains/pessoas.resource`
3. Usar keywords de domains (negócio), não de apps (técnico)

#### Navegação e menus no UauXT
1. Configurações de menu em `resources/data/uauxt_menu_data.resource`
2. Keywords de navegação em `resources/apps/uauxt.resource`
3. Exemplos executáveis:
    - `04_uauxt_acessar_contas_pagar.robot` - Acesso à tela
    - `05_uauxt_aprovacao_pagamento.robot` - Aprovação em grid

## 🔧 Comandos Runner

```powershell
# Dependências
.\robot-runner.ps1 deps

# Setup de pipeline (etapas 1-5)
.\robot-runner.ps1 setup

# Etapas individuais
.\robot-runner.ps1 modulos           # Etapa 3
.\robot-runner.ps1 mover-arquivos    # Etapa 4

# Suites principais
.\robot-runner.ps1 examples          # Suite de exemplos reutilizáveis

# Grupos
.\robot-runner.ps1 all-suites        # Todas as suites cadastradas

# Por tag
.\robot-runner.ps1 tag pessoas       # Apenas testes com @tag pessoas
.\robot-runner.ps1 tag uauxt         # Apenas testes do UauXT
.\robot-runner.ps1 tag navegacao     # Apenas testes de navegação
.\robot-runner.ps1 tag "contas-pagarANDdvq"   # Multiplas tags (expressao Robot)

# Aguardar compilação
.\robot-runner.ps1 aguardar          # Aguarda componentes
.\robot-runner.ps1 aguardar-modulos  # Aguarda módulos
```

## 🤖 Padrao IA e Scripts

- Script Python oficial integrado ao projeto: `resources/scripts/uauxt_probe.py`.
- Scripts temporarios de investigacao nao devem permanecer no repositorio.
- Para novos recursos de automacao assistidos por IA:
    1. criar dados em `resources/data/*_data.resource`
    2. criar keyword tecnico em `resources/apps/*.resource`
    3. criar exemplo executavel em `tests/90_examples/`
    4. validar com `--dryrun` e depois execucao real por tag

## 📋 Checklist de Contribuição

Antes de fazer commit:

- [ ] Leu **`CONTRIBUTING.md`**?
- [ ] Imports corretos (camadas ordenadas)?
- [ ] Keywords têm `[Documentation]`?
- [ ] Locators começam com `TODO_CONFIGURAR_`?
- [ ] Logs têm prefixo console (`[COMP]`, `[UAUXT]`, etc)?
- [ ] Sem `Sleep` arbitrário (usar `Pausa Controlada`)?
- [ ] Test cases têm tags (`setup`, `smoke`, `pessoas`, etc)?
- [ ] Variáveis em `data/`, não hardcoded?

## 🐛 Troubleshooting

### Locator não encontrado

```robot
# Debug: imprimir árvore de elementos
Print Tree    ${app_window}    log_as_warnings=True
```

### Teste flaky (inconsistente)

- Substituir `Sleep` por `Aguardar Elemento Com Log`
- Adicionar `Garantir Janela Em Foco` antes de clicar
- Aumentar timeout em `Aguardar Resultado Compilacao`

### Python/venv não encontrado

```powershell
# Confirmar que Python 3.13 está instalado
py -3.13 --version

# Recriar venv
rm .venv
py -3.13 -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

## 📝 Variáveis de Ambiente (Futuro)

Quando implementar config por ambiente:
```robot
Resource    ../config/${AMBIENTE}_vars.resource    # dev ou prod
```

## 📞 Suporte

- **Padrões & Organização:** Ver `CONTRIBUTING.md`
- **Erros RPA.Windows:** Consultar [documentação oficial](https://robocorp.com/docs/libraries/rpa-framework/rpa-windows)
- **Sintaxe Robot:** [Robot Framework User Guide](https://robotframework.org/robotframework/#documentation)

---

**Versão:** 1.0  
**Data de Atualização:** 22 de Abril de 2026  
**Mantido por:** Tim QA Automation
