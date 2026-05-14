# Setup do Self-Hosted Runner no Windows (GitHub Actions)

## Pre-requisitos na maquina VW

- Windows com usuario dedicado para automacao (ex: `robot-agent`)
- Auto-login configurado para esse usuario
- Python 3.13 instalado e acessivel

---

## 1. Instalar o runner

No GitHub: **Settings > Actions > Runners > New self-hosted runner > Windows**

Siga as instrucoes geradas — os comandos serao algo como:

```powershell
mkdir C:\actions-runner ; cd C:\actions-runner
# Baixar runner (use o link gerado pelo GitHub)
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.x.x/actions-runner-win-x64-2.x.x.zip -OutFile runner.zip
Expand-Archive runner.zip -DestinationPath .
```

Na configuracao, use labels: `self-hosted,windows,uau-automation`

```powershell
.\config.cmd --url https://github.com/<org>/<repo> --token <TOKEN_GERADO> --labels uau-automation
```

---

## 2. CRITICO: Rodar como processo interativo, NAO como servico

UI automation (RPA.Windows) exige sessao de desktop ativa.
**Nao instale o runner como servico Windows.**

Em vez disso, configure para iniciar automaticamente no logon do usuario:

### Opcao A: Pasta Startup (mais simples)

Crie um atalho para `C:\actions-runner\run.cmd` em:
```
C:\Users\robot-agent\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
```

### Opcao B: Task Scheduler (mais robusto)

```powershell
$action = New-ScheduledTaskAction -Execute "C:\actions-runner\run.cmd" -WorkingDirectory "C:\actions-runner"
$trigger = New-ScheduledTaskTrigger -AtLogOn -User "VW\robot-agent"
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 0) -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName "GH-Runner-UAU" -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest
```

---

## 3. Configurar Secrets no GitHub

Em **Settings > Secrets and variables > Actions**, adicionar:

| Secret             | Valor                            |
|--------------------|----------------------------------|
| `UAUXT_USUARIO`    | usuario do UAU XT                |
| `UAUXT_SENHA`      | senha do UAU XT                  |
| `UAUXT_EXE`        | caminho do UauXT.exe             |
| `COMPILADOR_DIR`   | pasta dos componentes            |
| `COMPILADOR_PASTA_SAIDA` | pasta de saida dos modulos |
| `VS_EXE`           | caminho do devenv.exe            |
| `TFS_SERVIDOR`     | nome do servidor TFS             |
| `TFS_PROJETO`      | nome do projeto TFS              |
| `TFS_BRANCH`       | branch (ex: 10.06)               |
| `TFS_PASTA_ALVO`   | pasta alvo (ex: Producao)        |

---

## 4. Maquina pode ficar com tela bloqueada?

**Sim, na maioria dos casos.** `Win+L` (tela bloqueada) mantem a sessao ativa.
O runner continua funcionando.

**Nao funciona:** Desligar/reiniciar sem auto-login, ou fazer logoff.

---

## 5. Ver resultados

Apos cada execucao: **GitHub > Actions > run > Artifacts > robot-results-N**

Baixe o zip e abra o `log.html` no browser para ver o relatorio completo.
