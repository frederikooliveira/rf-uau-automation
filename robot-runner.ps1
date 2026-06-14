param(
    [Parameter(Position=0)]
    [string]$Task = "help",
    [Parameter(Position=1)]
    [string]$Arg = ""
)

$ErrorActionPreference = "Stop"

# ============================================================================
# Robot Framework Test Runner - Projeto UAU
# ============================================================================
# Este script orquestra a execução de testes Robot Framework.
# 
# Arquitetura de recursos: CORE > APPS > DOMAINS > DATA
# - resources/core/         : Helpers técnicos genéricos (UI, Sync)
# - resources/apps/         : Keywords por aplicação (compilador, vs, uauxt, desktop_tools)
# - resources/domains/      : Fluxos de negócio (pessoas, etc)
# - resources/data/         : Centralizacao de variáveis, locators, massas
#
# Estrutura de testes:
# - tests/01_pipeline_setup/ : Pipeline base: baixar, compilar, publicar, validar
# - tests/90_examples/      : Exemplos reutilizaveis para onboarding QA
# - tests/flows/            : Fluxos compostos multi-sistema (futuro)
#
# Consulte CONTRIBUTING.md para padrões de contribuição.
# ============================================================================

$python = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $python)) {
    Write-Error "Python da venv nao encontrado em .venv\Scripts\python.exe. Rode: py -3.13 -m venv .venv"
    exit 1
}

# Carrega variaveis de ambiente do arquivo .env local (nao versionado)
$envFile = Join-Path $PSScriptRoot ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object { $_ -match '^\s*[^#]\w+=.+' } | ForEach-Object {
        $parts = $_ -split '=', 2
        [System.Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim(), 'Process')
    }
    Write-Host "[ENV] Variaveis carregadas de .env" -ForegroundColor DarkGray
    if ($env:UAUXT_EXE) {
        Write-Host "[ENV] UAUXT_EXE efetivo: $($env:UAUXT_EXE)" -ForegroundColor DarkGray
    }
}

# Executa o robot em uma pasta ou arquivo e para o pipeline em caso de falha.
function Invoke-Robot {
    param([string]$Caminho)
    & $python -m robot --outputdir results --variable "UAUXT_EXE:$($env:UAUXT_EXE)" $Caminho
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

switch ($Task.ToLowerInvariant()) {

    # --- Dependencias ---
    "deps" {
        & $python -m pip install -r requirements.txt
    }

    # --- Etapas individuais ---
    "setup" {
        # Etapa 1: baixar versao + Etapa 2: compilar componentes + Etapa 3: compilar modulos + Etapa 4: mover arquivos
        & $python -m robot --outputdir results --variable "UAUXT_EXE:$($env:UAUXT_EXE)" --exitonfailure tests\01_pipeline_setup
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    "modulos" {
        # Etapa 3: compilacao especifica dos modulos UAU
        Invoke-Robot "tests\01_pipeline_setup\03_compile_modulos_uau.robot"
    }
    "mover-arquivos" {
        # Etapa 4: configurar local de saida dos arquivos compilados
        Invoke-Robot "tests\01_pipeline_setup\04_publish_modulos_arquivos.robot"
    }
    "examples" {
        # Suite de exemplos reutilizaveis para referencia e onboarding
        Invoke-Robot "tests\90_examples"
    }
    "smoke" {
        # Testes de verificacao rapida do ambiente
        & $python -m robot --outputdir results --variable "UAUXT_EXE:$($env:UAUXT_EXE)" --include smoke tests
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    "funcional" {
        # Fluxos funcionais padrao (1 caso = 1 comportamento)
        & $python -m robot --outputdir results --variable "UAUXT_EXE:$($env:UAUXT_EXE)" --include funcional tests
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    "integracao" {
        # Suite de integracao entre dominios/telas (por tag)
        & $python -m robot --outputdir results --variable "UAUXT_EXE:$($env:UAUXT_EXE)" --include integracao tests
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    "regressao" {
        # Suite de regressao (por tag)
        & $python -m robot --outputdir results --variable "UAUXT_EXE:$($env:UAUXT_EXE)" --include regressao tests
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    "all-suites" {
        # Roda tudo de uma vez (Robot gera um unico relatorio consolidado)
        Invoke-Robot "tests"
    }

    # --- Execucao por tag (exemplos) ---
    # .\robot-runner.ps1 tag examples   -> roda apenas testes com tag "examples"
    "tag" {
        if (-not $Arg) { Write-Error "Informe a tag. Ex: .\robot-runner.ps1 tag funcional"; exit 1 }
        & $python -m robot --outputdir results --variable "UAUXT_EXE:$($env:UAUXT_EXE)" --include $Arg tests
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }

    # --- Aguardar compilacao ---
    "aguardar" {
        # Aguarda o resultado da compilacao ja iniciada no UAUCompilador
        & $python -m robot --outputdir results --variable "UAUXT_EXE:$($env:UAUXT_EXE)" --test "Aguardar Compilacao" tests\01_pipeline_setup\02_compile_componentes_uau.robot
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    "aguardar-modulos" {
        # Aguarda o resultado da compilacao dos modulos UAU ja iniciada
        & $python -m robot --outputdir results --variable "UAUXT_EXE:$($env:UAUXT_EXE)" --test "Aguardar Compilacao Modulos" tests\01_pipeline_setup\03_compile_modulos_uau.robot
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    "compilar-modulos" {
        # Aguarda compilacao de componentes, compila modulos e aguarda
        Invoke-Robot "tests\01_pipeline_setup\03_compile_modulos_uau.robot"
    }
    "validar-grid" {
        # Valida o grid de modulos apos compilacao
        Invoke-Robot "tests\01_pipeline_setup\05_validate_grid_modulos.robot"
    }

    default {
        Write-Host ""
        Write-Host "Uso: .\robot-runner.ps1 <comando>"
        Write-Host ""
        Write-Host "  Dependencias:"
        Write-Host "    deps          Instala dependencias do requirements.txt"
        Write-Host ""
        Write-Host "  Etapas individuais:"
        Write-Host "    setup         Etapas 1+2+3+4 - Setup completo (baixar versao + compilar + mover)"
        Write-Host "    modulos       Etapa 3 - Compilacao especifica dos modulos UAU"
        Write-Host "    mover-arquivos Etapa 4 - Configurar local de saida dos arquivos"
        Write-Host "    examples      Suite de exemplos reutilizaveis para QA"
        Write-Host "    smoke         Suite smoke por tag smoke"
        Write-Host "    funcional     Suite funcional por tag funcional"
        Write-Host "    integracao    Suite integracao por tag integracao"
        Write-Host "    regressao     Suite regressao por tag regressao"
        Write-Host ""
        Write-Host "  Aguardar:"
        Write-Host "    aguardar      Aguarda compilacao dos componentes terminar"
        Write-Host "    aguardar-modulos  Aguarda compilacao dos modulos terminar"
        Write-Host "    compilar-modulos   Aguarda componentes, compila modulos e aguarda"
        Write-Host "    validar-grid       Valida o grid de modulos apos compilacao"
        Write-Host ""
        Write-Host "  Grupos:"
        Write-Host "    all-suites    Tudo em um unico relatorio consolidado"
        Write-Host ""
        Write-Host "  Por tag:"
        Write-Host "    tag <nome>    Ex: .\robot-runner.ps1 tag examples"
        Write-Host ""
        exit 1
    }
}
