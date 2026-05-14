*** Settings ***
Documentation       Dados e configuracoes da aplicacao Visual Studio via TFVC.
...                 Responsabilidade: centralizar caminhos, locators e constantes.

*** Variables ***
# Caminhos e executaveis
# Sobrescreva via variaveis de ambiente ou .env (ver .env.example)
${VS_EXE}                   %{VS_EXE=C:/Program Files (x86)/Microsoft Visual Studio/2019/Professional/Common7/IDE/devenv.exe}
${VS_JANELA_PRINCIPAL}      executable:devenv.exe

# Configuracoes TFVC
# Sobrescreva via variaveis de ambiente para nao expor dados do servidor
${TFS_SERVIDOR}             %{TFS_SERVIDOR=Globaltec}
${TFS_PROJETO}              %{TFS_PROJETO=UAU}
${TFS_BRANCH}               %{TFS_BRANCH=10.06}
${TFS_PASTA_ALVO}           %{TFS_PASTA_ALVO=Producao}

# Locators de UI (principais)
${ID_EXPLORER_SCC}          id:ExplorerScc

# Timeouts padrao
${VS_TIMEOUT_PADRAO}        30s
${VS_TIMEOUT_CARREGAMENTO}  120s
${VS_TIMEOUT_GET}           900s
