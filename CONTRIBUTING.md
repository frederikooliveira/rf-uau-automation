# Instruções de Padronização - Robot Framework RPA Projeto UAU

> Nota: para instrucoes objetivas da IA (GitHub Copilot), o arquivo oficial e `.github/copilot-instructions.md`.
> Este documento permanece como guia detalhado de arquitetura e processo para o time.

## 1. Visão Geral da Arquitetura

Este projeto segue a arquitetura em camadas de **Robot Framework** para máxima reusabilidade, manutenibilidade e separação de responsabilidades:

```
resources/
├── core/               # Camada técnica genérica (UI, Sync)
├── apps/               # Camada aplicativa (por sistema: compilador, vs, uauxt, desktop_tools)
├── domains/            # Camada de negócio (por domínio: pessoas)
└── data/               # Camada de dados (variáveis, massas, locators)

tests/
├── 01_pipeline_setup/  # Pipeline base: baixar, compilar, publicar, validar
├── 90_examples/        # Exemplos executaveis de referencia para QA
└── flows/              # Fluxos multi-etapa (compostos)

config/                # Configurações por ambiente (futuro)
```

## 1.1 Politica de Scripts de Suporte

- Scripts Python em `resources/scripts/` devem existir apenas quando usados por resources/tests.
- Script oficial atual: `uauxt_probe.py` (probe Win32 do UauXT — grid e toolbar).
- Scripts temporarios de investigacao (ex.: `tmp_*`, `diagnostico_*`) devem ser removidos antes de finalizar PR.

## 1.2 Fluxo Recomendado para Mudancas com IA

1. Criar/ajustar variaveis e locators em `resources/data/*_data.resource`.
2. Implementar keyword tecnico em `resources/apps/*.resource`.
3. Criar ou atualizar exemplo executavel em `tests/90_examples/`.
4. Validar com `--dryrun` e depois execucao real por tag.
5. Atualizar README/docs quando novos fluxos virarem padrao.

## 2. Estrutura de Camadas

### 2.1 Camada CORE (`resources/core/`)

**Responsabilidade:** Helpers técnicos genéricos de UI, sincronização e processos.

**Arquivo:** `ui_helpers.resource`
- Keywords para clicar, digitar, obter valores
- Gerenciar janelas e processos
- **NÃO depende de:** apps, domains, dados de negócio
- **Exemplos:**
  ```robot
  Clicar Elemento Quando Disponivel    ${locator}
  Garantir Janela Em Foco              ${COMPILADOR_JANELA}
  Verificar Processo Em Execucao      UAUCompilador.exe
  ```

**Arquivo:** `sync.resource`
- Keywords de espera inteligente com log
- Encapsula Sleep com semântica
- **NÃO depende de:** dados específicos
- **Exemplos:**
  ```robot
  Aguardar Elemento Com Log    ${locator}    ${descricao}
  Fechar Popup Informa
  Pausa Controlada              1s    Motivo da pausa
  ```

**Regra:** Keywords em `core/` devem ser agnósticas a aplicação. Se contêm lógica específica (ex: "fechar compilador"), pertence a `apps/`.

---

### 2.2 Camada APPS (`resources/apps/`)

**Responsabilidade:** Controle de interface e fluxos técnicos de cada aplicação.

**Arquivos:**
- `compilador.resource` — UAU Compilador
- `visual_studio.resource` — Visual Studio
- `uauxt.resource` — UauXT (login, navegação básica)
- `desktop_tools.resource` — Ferramentas genéricas (Notepad, etc)

**Exemplo de estrutura (compilador.resource):**
```robot
*** Settings ***
Resource    ../core/ui_helpers.resource
Resource    ../core/sync.resource
Resource    ../data/compilador_data.resource

*** Keywords ***
Abrir UAU Compilador
    # Verifica se processo existe → inicia se necessário → aguarda janela

Configurar Opcoes Compilador
    # Preenche campos, marca checkboxes, clica em botões específicos do compilador

Validar Grid Modulos
    # Navega estrutura do grid (CustomControl → EditControl) e valida dados
```

**Regra:** Keywords em `apps/` devem:
1. Depender de `core/` para UI técnica
2. Usar locators de `data/{app}_data.resource`
3. **NÃO conter lógica de negócio** (ex: "se módulo falhou, enviar email")
4. Ser a camada de "como fazer", não "por que fazer"

---

### 2.3 Camada DOMAINS (`resources/domains/`)

**Responsabilidade:** Fluxos de negócio e casos de uso compostos.

**Arquivos:**
- `pessoas.resource` — Cadastro e gestão de pessoas

**Exemplo (pessoas.resource):**
```robot
*** Settings ***
Resource    ../apps/uauxt.resource
Resource    ../data/pessoas_data.resource

*** Keywords ***
Cadastrar Pessoa Basica
    [Arguments]    ${perfil}=padrao
    ${pessoa}=      Obter Dados Pessoa    ${perfil}
    Acessar Menu Pessoas
    Clicar Em Novo Cadastro De Pessoa
    Preencher Cadastro De Pessoa    ${pessoa}
    Gravar Cadastro De Pessoa
    # Fluxo completo: combina keywords de apps/ com dados de negócio
```

**Regra:** Keywords em `domains/`:
1. Combinam `apps/` + dados de `data/`
2. Definem "o que" fazer, não "como fazer"
3. Legíveis para PO/analista, não apenas QA técnico
4. Reutilizáveis em testes, não contêm asserções

---

### 2.4 Camada DATA (`resources/data/`)

**Responsabilidade:** Centralizar dados, variáveis, locators e massas.

**Arquivos:**
- `compilador_data.resource` — Paths, locators, timeouts do compilador
- `vs_data.resource` — Paths, locators do Visual Studio
- `uauxt_data.resource` — Paths, locators, credenciais do UauXT
- `pessoas_data.resource` — Massa de pessoas, locators de formulário

**Exemplo (compilador_data.resource):**
```robot
*** Variables ***
${COMPILADOR_DIR}           C:/ProjetosTFS/UAU/10.06/Producao/Componentes
${COMPILADOR_EXE}           ${COMPILADOR_DIR}/UAUCompilador.exe
${COMPILADOR_JANELA}        executable:UAUCompilador.exe
${PASTA_SAIDA}              C:/UAU/UAU 10.06/Modulos

${ID_GRID_MODULOS}          id:gvModulos
${ID_CHECKBOX_MARCAR_MODULOS}    id:cbxMarcarModulos

${COMPILADOR_TIMEOUT_PADRAO}     30s
${COMPILADOR_TIMEOUT_COMPILACAO}  900s
```

**Regra:** Dados em `data/`:
1. **Nunca** contêm keywords ou lógica
2. **Sempre** prefixados com scope (ex: `${COMPILADOR_...}`, `${ID_...}`)
3. TODO_CONFIGURAR para campos não mapeados (forçam falha cedo)
4. Nomes descritivos, não abreviados

**Para CREDENCIAIS/SENSÍVEIS (futuro):**
Quando implementar config por ambiente:
```robot
Resource    ../config/${AMBIENTE}_vars.resource    # Carrega do config/dev.resource ou config/prod.resource
```

---

## 3. Convenções de Nomenclatura

## 3.1 Política de Libraries e Estratégia de Automação

Esta seção define de forma obrigatória quais bibliotecas podem ser usadas no projeto.

### Libraries permitidas

- RPA.Windows (biblioteca principal para automação de UI Windows)
- Process (controle e verificação de processos)
- String (normalização e manipulação de texto)
- Collections (listas e dicionários)
- BuiltIn (keywords nativas do Robot Framework)

### Libraries proibidas neste projeto

- RPA.Images
- RPA.Desktop com estratégia baseada em imagem
- Qualquer abordagem de clique/validação por screenshot, template matching ou OCR como mecanismo principal

### Regra mandatória de implementação

- Todos os locators devem ser baseados em árvore de acessibilidade do Windows via RPA.Windows (id, name, type, class, executable, handle, subname).
- Não usar reconhecimento de imagem para clicar, localizar ou validar elementos de interface.
- Exceção somente mediante aprovação explícita do responsável técnico do projeto e registro da justificativa no PR.

---

### Keywords

**Regra geral:** Começa com verbo, descreve ação, preposição opcional.

| Camada | Padrão | Exemplo |
|--------|--------|---------|
| CORE | `<Verbo> <Alvo>` | `Clicar Elemento`, `Digitar Texto Em Campo` |
| APPS | `<Verbo> [Nome App]` | `Abrir UAU Compilador`, `Configurar Opcoes Compilador` |
| DOMAINS | `<Verbo> <Entidade>` | `Cadastrar Pessoa Basica`, `Acessar Menu Pessoas` |
| TEST | `Fluxo <Nome Cenário>` | `Fluxo Basico Notepad`, `Cadastrar Pessoa Com CPF Invalido` |

**Evite:**
- Nomes genéricos demais: `Fazer Algo`, `Executar`
- Siglas sem contexto: `LM` em vez de `Logar No Sistema`
- Nomes muito longos (>10 palavras)

### Arquivos de teste

**Regra geral:** usar `NN_contexto_acao_objetivo.robot`.

**Exemplos:**
- `01_get_latest_visual_studio.robot`
- `02_compile_componentes_uau.robot`
- `01_uauxt_login_popup_inicial.robot`
- `01_pessoas_cadastro_basico.robot`

**Objetivo:** o nome do arquivo deve deixar claro:
1. Ordem de execução quando aplicável
2. Contexto funcional ou de pipeline
3. Ação principal
4. Resultado/objetivo do cenário

---

### Variáveis

**Padrão:** `${ESCOPO_NOME_DESCRITIVO}`

| Tipo | Prefixo | Exemplo |
|------|---------|---------|
| Path/URL | `${...}` | `${COMPILADOR_DIR}`, `${UAUXT_EXE}` |
| Locator | `${ID_...}` ou `${LOCATOR_...}` | `${ID_GRID_MODULOS}`, `${LOCATOR_BOTAO_SALVAR}` |
| Timeout | `${..._TIMEOUT_...}` | `${COMPILADOR_TIMEOUT_COMPILACAO}` |
| Dados | `${...}` + tipo | `${PESSOA_PADRAO}`, `&{CREDENCIAIS_PADRAO}` |
| TODO | `TODO_CONFIGURAR_...` | `${MENU_PESSOAS_LOCATOR}` → `TODO_CONFIGURAR_MENU_PESSOAS` |

---

### Log Prefixes

Use prefixos console para rastreabilidade em logs:

```robot
Log    [COMP] Status da compilacao    console=True    # Compilador
Log    [UAUXT] Login concluido        console=True    # UauXT
Log    [DOM-PESSOAS] Cadastro gravado console=True    # Domain Pessoas
Log    [SYNC] Aguardando elemento     console=True    # Sync
Log    [UI] Clicando em botao         console=True    # UI Helpers
```

---

## 4. Padrões de Organização

### 4.1 Quando Criar um Novo Resource

**Decisão árvore:**

```
Preciso de nova keyword?
├─ É técnica de UI genérica?        → core/ui_helpers.resource
├─ É sincronização/espera?          → core/sync.resource
├─ É para uma aplicação específica?
│  └─ Qual app? (compilador, vs, uauxt, desktop_tools)
│     → apps/{app}.resource
├─ É fluxo de negócio composto?
│  └─ Qual domínio? (pessoas, etc)
│     → domains/{dominio}.resource
└─ É dados/variáveis?              → data/{contexto}_data.resource
```

---

### 4.2 Quando Criar um Novo Teste

**Localização:**

| Tipo | Pasta | Quando |
|------|-------|--------|
| Pipeline base | `tests/01_pipeline_setup/` | Baixar versão, compilar, publicar e validar |
| Exemplos | `tests/90_examples/` | Referência executável para onboarding e reuso |
| Fluxos compostos | `tests/flows/` | Multi-etapa, multi-sistema (futuro) |

**Exemplo de novo teste em 90_examples:**

```robot
*** Settings ***
Documentation       Valida rejeicao de CPF invalido no cadastro de pessoa.
Resource            ../../resources/apps/uauxt.resource
Resource            ../../resources/domains/pessoas.resource
Test Tags           pessoas    validacao-cpf

Suite Setup         Abrir E Logar No UauXT

*** Test Cases ***
Rejeitar Cadastro Com CPF Invalido
    [Documentation]    Tenta cadastrar pessoa com CPF invalido; sistema deve rejeitar.
    Cadastrar Pessoa Basica    invalida_cpf
    ${msg_erro}=    Obter Mensagem Erro Sistema
    Should Contain    ${msg_erro}    CPF invalido
```

---

## 5. Exemplo Prático: Adicionar Novo Fluxo de Negócio

### Cenário
Precisamos adicionar funcionalidade "Alterar Status de Pessoa" no UauXT.

### Passo 1: Adicionar dados em `data/pessoas_data.resource`
```robot
${BOTAO_ALTERAR_STATUS_LOCATOR}     TODO_CONFIGURAR_BOTAO_ALTERAR_STATUS
${COMBO_NOVO_STATUS_LOCATOR}        TODO_CONFIGURAR_COMBO_STATUS
```

### Passo 2: Adicionar keyword técnica em `apps/uauxt.resource`
```robot
Selecionada Opcao Em Combo
    [Arguments]    ${locator_combo}    ${opcao}
    Log    [UAUXT] Selecionando opcao ${opcao} em combo...    console=True
    Click    ${locator_combo}
    Clicar Elemento Quando Disponivel    name:${opcao}
```

### Passo 3: Adicionar fluxo em `domains/pessoas.resource`
```robot
Alterar Status Pessoa
    [Arguments]    ${pessoa_id}    ${novo_status}
    Validar Locator Configurado    ${BOTAO_ALTERAR_STATUS_LOCATOR}    BOTAO_ALTERAR_STATUS_LOCATOR
    Log    [DOM-PESSOAS] Alterando status da pessoa ${pessoa_id} para ${novo_status}    console=True
    Localizar E Abrir Pessoa    ${pessoa_id}
    Clicar Elemento Quando Disponivel    ${BOTAO_ALTERAR_STATUS_LOCATOR}
    Selecionada Opcao Em Combo    ${COMBO_NOVO_STATUS_LOCATOR}    ${novo_status}
    Gravar Cadastro De Pessoa
```

### Passo 4: Criar teste em `tests/90_examples/04_pessoas_alterar_status.robot`
```robot
*** Settings ***
Resource            ../../resources/domains/pessoas.resource
Test Tags           pessoas    funcional

Suite Setup         Abrir E Logar No UauXT

*** Test Cases ***
Alterar Status Pessoa De Ativa Para Inativa
    [Documentation]    Valida transicao de status pessoa.
    ${pessoa}=    Obter Dados Pessoa    padrao
    Cadastrar Pessoa Basica    padrao
    Alterar Status Pessoa    ${pessoa}[id]    Inativa
```

---

## 6. Checklist para Revisão de Código

Antes de fazer commit, verifique:

- [ ] **Imports corretos**: Cada resource importa apenas da próxima camada baixo (core < apps < domains)
- [ ] **Nomes descritivos**: Keywords e variáveis seguem convenção
- [ ] **Logs informativos**: Cada ação tem `Log ... console=True` com prefixo apropriado
- [ ] **TODO_CONFIGURAR**: Locators novos começam com `TODO_CONFIGURAR_` (forçam falha cedo)
- [ ] **Sem Sleep arbitrário**: Use `Pausa Controlada` ou `Wait Until Keyword Succeeds`
- [ ] **Sem hardcode**: Paths/timeouts estão em `data/`
- [ ] **Sem automação por imagem**: Toda interação de UI deve usar locator de `RPA.Windows`
- [ ] **Documentação**: Cada keyword tem `[Documentation]`
- [ ] **Tags corretas**: Test cases têm tags apropriadas (setup, smoke, pessoas, etc)
- [ ] **Idempotência**: Testes não deixam estado que quebra execução seguinte

---

## 7. Troubleshooting Comum

### "Locator não encontrado"

**Checklist:**
1. [ ] Está em `data/{app}_data.resource`?
2. [ ] Começa com `TODO_CONFIGURAR_`? (sim = mape o locator real)
3. [ ] Use `Print Tree    ${app_window}    log_as_warnings=True` para inspecionar hierarquia

### "Keyword não encontrada"

**Checklist:**
1. [ ] Resource importado corretamente? (`Resource    ../../resources/apps/...`)
2. [ ] Caminho relativo correto? (contar `../` certo)
3. [ ] Keyword está no resource correto? (core para genérico, apps para app-específico)

### "Teste flaky (inconsistente)"

**Checklist:**
1. [ ] Há sleeps hardcoded? Trocar por `Aguardar Elemento Com Log`
2. [ ] Falta sincronização entre janelas? Adicionar `Garantir Janela Em Foco`
3. [ ] UI demora para atualizar? Aumentar timeout em `Aguardar Resultado Compilacao`

---

## 8. Próximas Melhorias

- [ ] Criar `config/dev.resource` e `config/prod.resource` para variáveis por ambiente
- [ ] Integrar logger customizado para relatórios HTML melhorados
- [ ] Implementar retry automático para keywords de UI flaky
- [ ] Criar biblioteca Python customizada para helpers de grid/tabela

---

## 9. Exemplos de Uso de Recursos Reutilizáveis

Para manter este guia objetivo, os exemplos operacionais foram movidos para locais dedicados:

- Leitura e padrões: `docs/examples.md`
- Execução prática: `tests/90_examples/`

Comandos úteis:

- `./robot-runner.ps1 examples` para rodar somente os exemplos
- `./robot-runner.ps1 tag examples` para rodar por tag

---

**Versão:** 1.0  
**Data:** 22 de Abril de 2026  
**Autor:** Tim QA Automation  
