*** Settings ***
Documentation       Smoke test para validar estrutura minima, governanca e padrao do repositorio.
Library             OperatingSystem
Test Tags           smoke

*** Variables ***
@{DIRETORIOS_OBRIGATORIOS}
...    resources
...    resources${/}core
...    resources${/}apps
...    resources${/}domains
...    resources${/}data
...    tests
...    tests${/}01_pipeline_setup
...    tests${/}02_pipeline_smoke
...    tests${/}10_functional_desktop
...    tests${/}11_functional_uauxt
...    tests${/}12_functional_pessoas
...    tests${/}90_examples

@{ARQUIVOS_OBRIGATORIOS}
...    README.md
...    CONTRIBUTING.md
...    robot-runner.ps1
...    robot.toml
...    requirements.txt
...    .github${/}copilot-instructions.md
...    resources${/}core${/}ui_helpers.resource
...    resources${/}core${/}sync.resource
...    resources${/}apps${/}compilador.resource
...    resources${/}apps${/}visual_studio.resource
...    resources${/}apps${/}uauxt.resource
...    resources${/}apps${/}desktop_tools.resource
...    resources${/}domains${/}pessoas.resource

@{ARQUIVOS_LEGADOS_PROIBIDOS}
...    resources${/}compilador_keywords.resource
...    resources${/}desktop_keywords.resource
...    resources${/}pessoas_keywords.resource
...    resources${/}vs_keywords.resource
...    resources${/}pessoas.resource

*** Test Cases ***
Smoke Estrutura Base Do Repositorio
    [Documentation]    Garante que a estrutura oficial de pastas do projeto existe.
    FOR    ${diretorio}    IN    @{DIRETORIOS_OBRIGATORIOS}
        Directory Should Exist    ${diretorio}
    END

Smoke Arquivos Obrigatorios De Governanca E Recursos
    [Documentation]    Garante que arquivos centrais de governanca, runner e resources existem.
    FOR    ${arquivo}    IN    @{ARQUIVOS_OBRIGATORIOS}
        File Should Exist    ${arquivo}
    END

Smoke Nao Deve Haver Resources Legados Na Raiz
    [Documentation]    Evita regressao para nomes antigos de resources fora da arquitetura em camadas.
    FOR    ${arquivo_legado}    IN    @{ARQUIVOS_LEGADOS_PROIBIDOS}
        File Should Not Exist    ${arquivo_legado}
    END
